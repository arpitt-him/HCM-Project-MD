# ADR-012 — Benefit Election Temporal Integrity Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.1 |
| **Status** | Accepted |
| **Owner** | Benefits Module |
| **Location** | `docs/ADR/ADR-012_Benefit_Election_Temporal_Integrity.md` |
| **Date** | May 2026 |
| **Related Documents** | `docs/SPEC/Benefits_Minimum_Module.md`, `docs/STATE/STATE-DED_Benefits_Deductions.md`, `docs/architecture/core/Benefit_Deduction_Election_Model.md`, `ADR-004_Data_Access_Strategy.md`, `ADR-005_Background_Job_Execution.md` |

---

## Context

The benefits module was initially implemented as a minimum viable foundation — the primary goal was to get deduction amounts into the payroll calculation pipeline. As the module matured toward production use, a cluster of related temporal integrity questions surfaced that required deliberate decisions:

1. Elections can be created with a future `effective_start_date` and are assigned `PENDING` status at creation time. Nothing in the original implementation promoted them to `ACTIVE` when their date arrived.

2. The same scheduled-activation gap exists across multiple entities in the system, not only benefit elections. The leave request module had already solved it correctly with `LeaveStatusTransitionJob`. No equivalent job existed for elections, employment activation, compensation records, or org structure entities.

3. The system supports a Test Date Override (TDO) facility (`ITemporalContext` / `OverridableTemporalContext`) that allows the operative date to be shifted for testing. The interaction between TDO forward and backward shifts and activation jobs required explicit rules.

4. The `status` column in `benefit_deduction_election` represents current state, not point-in-time state. Retroactive payroll runs for past periods — a design goal of the system — cannot rely on `status = 'ACTIVE'` filtering because a `TERMINATED` or `SUPERSEDED` election was genuinely active during its effective period.

5. Nothing in the original implementation prevented two elections for the same employee and deduction code from having overlapping effective date ranges. The `GetActiveByCodeAsync` query used `LIMIT 1` to paper over the gap rather than preventing it.

6. The bulk import workflow validated record format and DB reference integrity but did not detect intra-batch overlaps (two rows in the same file for the same employee and code with overlapping dates) or overlaps with existing database elections.

These questions are interconnected: the right overlap prevention strategy affects whether the `SUPERSEDED` status remains a query discriminator or becomes purely descriptive, which in turn affects how the amendment workflow and bulk import logic should be structured.

---

## Decisions

### Decision 1 — Scheduled activation jobs are required for all date-gated entities

Every entity with a PENDING state that activates on a future date requires a background job following the `LeaveStatusTransitionJob` pattern:

- Inject `ITemporalContext` and use `temporalContext.GetOperativeDate()` as the operative date — never `DateTime.UtcNow` directly.
- Use `IServiceScopeFactory` for scoped DI within the job cycle.
- Use `Guid.Empty` as the system actor identity for all status transitions made by the job.
- Log each transition at Information level; log failures at Error level and continue to the next record.

Entities requiring activation jobs, in priority order:

| Entity | Transition | Trigger |
|---|---|---|
| Benefit Elections | `PENDING` → `ACTIVE` | `effective_start_date <= operativeDate` |
| Employment | pending start → `ACTIVE` | `employment_start_date <= operativeDate` AND onboarding blocking tasks cleared |
| Compensation Records | `APPROVED` → `ACTIVE` | `effective_start_date <= operativeDate` |
| Org Units / Jobs / Positions | `PENDING_*` → `ACTIVE` | `effective_start_date <= operativeDate` |

The leave request job (`LeaveStatusTransitionJob`) is the reference implementation and the only currently correct instance of this pattern.

### Decision 2 — Activation jobs are forward-only; backward TDO shifts do not trigger activation

Each activation job tracks the operative date from its last completed cycle. If the current operative date is earlier than the last-run date, the job skips the activation write cycle entirely. It may still log and report, but it does not write status changes.

This prevents database state from accumulating inconsistencies when a TDO is shifted backward: a record that was promoted to `ACTIVE` during a forward-shifted period remains `ACTIVE` in the database, but the dual-filter pattern in queries (`status = 'ACTIVE' AND effective_start_date <= @AsOf`) naturally excludes it from results when the operative date is before its effective start.

TDO backward shifts are to be treated as read-only time travel — appropriate for verifying what queries return at a given date, not for resetting the database to a prior state. For genuine rollback to an earlier state, a database snapshot/restore is the correct tool.

### Decision 3 — Activation jobs must react to TDO forward shifts immediately

When a TDO forward shift is applied via `ITemporalOverrideService.OnChanged`, each activation job must immediately run a cycle rather than waiting for its next 24-hour tick. The implementation uses a volatile flag set by the `OnChanged` handler, combined with a short-interval polling loop inside the 24-hour wait:

```csharp
// OnChanged handler sets _tdo = true
// ExecuteAsync loop:
var deadline = DateTime.UtcNow.AddHours(24);
while (!ct.IsCancellationRequested && !_tdo && DateTime.UtcNow < deadline)
    await Task.Delay(TimeSpan.FromSeconds(10), ct);
```

`NullTemporalOverrideService` (registered in production) has a no-op `OnChanged` event; the subscription costs nothing in production.

`LeaveStatusTransitionJob` does not yet implement this pattern and should be updated to match.

### Decision 4 — Retroactive payroll must not filter by `status = 'ACTIVE'`

The `status` column reflects the current state of a record. A `TERMINATED` election was genuinely active during its effective period; a `SUPERSEDED` election was active before it was amended. Filtering by `status = 'ACTIVE'` in retroactive payroll queries excludes elections that should be included for the period being calculated.

Two distinct query modes apply:

**Current / forward-looking queries** (dashboard, current payroll run, eligibility checks):
Filter `status = 'ACTIVE'` combined with effective date overlap. Fast, simple, correct because status and effective dates agree for currently active records.

**Retroactive payroll calculation** (corrective runs, period recalculation):
Filter by effective date overlap only, exclude `SUPERSEDED` records, and separately test for leave suspension:

```sql
WHERE e.effective_start_date <= @PayPeriodEnd
  AND (e.effective_end_date IS NULL OR e.effective_end_date >= @PayPeriodStart)
  AND e.status NOT IN ('SUPERSEDED')
  AND NOT EXISTS (
      SELECT 1 FROM leave_request lr
      WHERE lr.employment_id    = e.employment_id
        AND lr.leave_start_date <= @PayPeriodEnd
        AND (lr.leave_end_date IS NULL OR lr.leave_end_date >= @PayPeriodStart)
        -- filter to statuses indicating leave was in effect
  )
```

`SUPERSEDED` is the only status excluded by name. All other statuses (`PENDING`, `ACTIVE`, `SUSPENDED`, `TERMINATED`) are handled correctly by effective date overlap alone — a `TERMINATED` election has `effective_end_date` set and is excluded by the date filter when appropriate; a `PENDING` election has a future `effective_start_date` and is excluded by the date filter.

`SUSPENDED` is the exception that requires explicit leave-check logic: a suspension does not modify `effective_end_date`, so date-range filtering alone would incorrectly include a suspended election during a leave period.

### Decision 5 — Non-overlapping date ranges are enforced at the application layer using serializable transactions

Two elections for the same `employment_id` and `deduction_code` must not have overlapping effective date ranges (with the controlled exception described in Decision 6).

Enforcement uses an application-level overlap check inside a `SERIALIZABLE` transaction. The check queries all non-`SUPERSEDED` elections for the same employment and code before inserting or amending:

```sql
SELECT COUNT(*) FROM benefit_deduction_election
WHERE employment_id  = @EmploymentId
  AND deduction_code = @DeductionCode
  AND status        != 'SUPERSEDED'
  AND (effective_end_date   IS NULL OR effective_end_date   >= @NewStart)
  AND (@NewEnd              IS NULL OR effective_start_date <= @NewEnd)
  AND election_id           != @ElectionId
```

`SERIALIZABLE` isolation is part of the SQL standard and prevents the phantom-read race condition where two concurrent inserts both pass the check and then both succeed. This is the ANSI-portable choice consistent with ADR-004's database portability commitment.

If PostgreSQL is ever committed to as the database engine, replacing this check with a `EXCLUDE USING GIST (daterange WITH &&)` constraint at the storage layer would be strictly preferable — it enforces the rule regardless of which code path writes to the table.

### Decision 6 — Amendment workflow and the role of SUPERSEDED

**When `amendment_start > original_start`** (the common case — amending a mid-period election):

The original election's `effective_end_date` is trimmed to `amendment_start - 1 day`. The trimmed original is marked `SUPERSEDED`. The amendment record is inserted with `effective_start_date = amendment_start`. No date ranges overlap; date filtering alone gives an unambiguous result for any point in time.

**When `amendment_start = original_start`** (correcting an election from its inception):

Trimming to `amendment_start - 1 day` would produce a record where `effective_end_date < effective_start_date`, which is invalid. There is no prior period to preserve — the original election never had any effective period distinct from the correction. The preferred handling is an **in-place update**: the existing election's fields are corrected directly and a correction entry is written to the audit log. No new election record is created; no SUPERSEDED transition occurs.

If strict immutability is required for the correction case, the alternative is to retain the original record with its dates intact, mark it `SUPERSEDED`, and insert the correcting record with the same start date — accepting a controlled same-start-date overlap. In this case `SUPERSEDED` remains a structural discriminator (not merely descriptive) for this specific scenario.

**Consequence for SUPERSEDED status:**

With non-overlapping date enforcement and the in-place update rule for same-start-date corrections, `SUPERSEDED` becomes a descriptive label rather than a query discriminator. Date ranges alone give an unambiguous answer for any point in time. `SUPERSEDED` is retained for readability — it visibly distinguishes "replaced by an amendment" from "naturally expired" (`effective_end_date` reached) or "deliberately terminated" — but it is no longer structurally required for query correctness.

If in-place updates are not adopted for same-start-date corrections (i.e., the controlled overlap alternative is chosen), `SUPERSEDED` retains structural significance for that case.

### Decision 7 — Bulk import resolves intra-batch overlaps via sort-and-sweep

The import service resolves overlapping rows within a single import file before touching the database, using the following algorithm:

**Step 1 — Sort**

Sort all parsed rows by:
```
(employee_number ASC, deduction_code ASC, effective_start_date ASC, effective_end_date ASC [NULL last], row_position ASC)
```

**Step 2 — Group and sweep**

Group by `(employee_number, deduction_code)`. Within each group, sweep left to right. When an adjacent pair overlaps, the earlier-start-date row loses and is marked `SUPERSEDED`. The later-start-date row continues as the candidate. If the candidate overlaps the next row, it too is marked `SUPERSEDED`. The final surviving row in the group is the winner.

Tiebreaker when start dates are equal: later `effective_end_date` wins. If end dates are also equal, the row appearing later in the file wins.

**Step 3 — Status assignment for survivors**

```
effective_start_date <= operativeDate  →  ACTIVE
effective_start_date >  operativeDate  →  PENDING
```

**Step 4 — Lineage**

The survivor's `parent_election_id` is set to the immediately preceding `SUPERSEDED` row's `election_id`. `original_election_id` is set to the first election in the chain. This preserves the amendment trail within the batch.

**Step 5 — Existing DB elections**

Before the sweep, existing non-`SUPERSEDED` elections for all affected employee+code combinations are loaded and prepended to each group as if they were earlier rows in the file. If an import row overlaps an existing DB election, the DB election loses. Its `effective_end_date` is trimmed to `import_start - 1 day` (where a genuine prior period exists) and its status is updated to `SUPERSEDED`. The import row is inserted as the survivor. This gives the import the semantics of a carrier-feed amendment — a full replacement dataset that supersedes what was previously held.

**Step 6 — Validation surfacing**

`ValidateBatchAsync` runs the same sort-and-sweep and reports the resolution to the user before they commit:

```
Total Records:     25
Valid / Active:    18
Valid / Pending:    4
Will Supersede:     3
Errors:             0
```

A warning (not a blocking error) is raised when a `SUPERSEDED` row has a date range that extends before its overlap with the winning row — meaning a period exists that no election will cover after the import. This is a data quality signal for the operator to investigate.

---

## Consequences

**Positive:**
- Retroactive payroll runs produce correct results regardless of the current status of elections; historical periods are fully recoverable from effective date ranges.
- Non-overlapping date ranges mean any point-in-time query returns at most one election per employee+code without requiring status-based tiebreaking.
- Bulk import handles real-world carrier feed data that may include overlapping or superseding rows, without requiring the source system to be perfectly clean.
- Activation jobs follow a single consistent pattern (`LeaveStatusTransitionJob`) across all affected entities; TDO behaviour is uniform and predictable.
- Backward TDO shifts are safely bounded — no unwanted demotions; read-only verification is reliable.

**Constraints to manage:**
- The serializable transaction for overlap checking has higher isolation overhead than the default read-committed level. This is acceptable given the low write frequency of benefit election records.
- The amendment workflow is now two-phase for mid-period amendments (trim old, insert new). Both writes must occur in the same unit of work.
- The import sweep requires loading all existing elections for affected employees before processing. For large imports this is a bulk pre-fetch, not per-row query.
- Validation surfacing of the sweep resolution adds complexity to `BatchValidationResult` — a `SupersededCount` and a warning list must be added alongside the existing error list.
- The in-place update rule for same-start-date corrections relaxes strict immutability for that case. If immutability is later mandated for all corrections, the controlled-overlap alternative must be adopted and `SUPERSEDED` must be re-elevated to a structural role.

**Future considerations:**
- All other date-gated entities (employment, compensation, org structure) need their activation jobs written. The benefit election activation job, once built, serves as the reference implementation for those.
- If PostgreSQL is committed as the database engine, the application-level overlap check should be replaced or supplemented with a `EXCLUDE USING GIST` constraint.
- The import sweep logic (sort, group, sweep, lineage assignment) is general enough to extract into a shared `ElectionOverlapResolver` utility usable by both the import service and future API ingestion paths.

---

## Alternatives Considered

**Reject all overlapping import rows as errors**
Simpler import logic, but incompatible with real-world carrier feed data that routinely sends overlapping rows as part of a replacement dataset. Rejected — too brittle for production use.

**PostgreSQL `EXCLUDE USING GIST (daterange WITH &&)` constraint**
The most robust overlap prevention mechanism available. Rejected for current implementation — database-engine-specific and incompatible with the ANSI SQL portability commitment in ADR-004. Retained as the preferred future option if PostgreSQL is committed.

**Keep `SUPERSEDED` as a structural query discriminator**
The original approach — overlapping date ranges permitted, SUPERSEDED as the tiebreaker. Rejected because it makes retroactive payroll queries dependent on status rather than dates, which conflicts with the system's stated goal of correct retroactive payroll calculation from effective date ranges.

**In-place updates for all amendments (full relaxation of immutability)**
Simpler amendment workflow — no SUPERSEDED records, no date trimming. Rejected — immutability and lineage traceability are design principles of the election model. In-place updates are adopted only for the narrow same-start-date correction case where creating a new record would produce an invalid date range.
