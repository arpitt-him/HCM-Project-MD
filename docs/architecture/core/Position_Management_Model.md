# Position_Management_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/architecture/core/Position_Management_Model.md` |
| **Domain** | Core |
| **Related Documents** | DATA/Entity_Position.md, DATA/Entity_Org_Unit.md, DATA/Entity_Assignment.md, docs/architecture/core/Organizational_Structure_Model.md, HRIS_Module_PRD.md §8 |

## Purpose

Defines the operational model for position management — headcount budgeting, vacancy tracking, position control rules, and the position lifecycle as it relates to hiring, transfers, and terminations. Position management in v1 operates in advisory mode: the system surfaces warnings but does not hard-block hires or transfers when position constraints are exceeded.

---

## 1. Core Design Principles

Position control is advisory in v1. Exceeding headcount budget generates a warning, not a hard stop. Headcount is tracked at both the position level and the department level. Position vacancy is a derived state — it reflects the relationship between position slots and active assignments, not a stored flag. All position changes are effective-dated and historically preserved.

---

### 1.1 Position Identity Stability Principle

Position records represent structural employment capacity and shall remain identity-stable across lifecycle transitions.

Position identity shall:

- persist across vacancy and occupancy cycles
- remain effective-dated rather than destructively replaced
- preserve historical assignment relationships
- remain queryable across organizational restructuring

Position records shall not be deleted when vacated or restructured.

Where structural meaning changes materially, a new effective-dated position definition shall be created rather than modifying historical identity.

---

## 2. Headcount Tracking Model

Headcount is tracked at two levels simultaneously:

**Position level:**
- Each Position record carries a Headcount_Budget (approved slots).
- Headcount_Filled is derived: count of active Assignments where Position_ID matches and Assignment_Status = ACTIVE.
- Headcount_Vacant = Headcount_Budget − Headcount_Filled.

**Department level:**
- Department_Headcount_Budget is stored on the Org_Unit record for units of type DEPARTMENT.
- Department_Headcount_Filled is derived: count of active Assignments where Department_ID matches.
- Department_Headcount_Vacant = Department_Headcount_Budget − Department_Headcount_Filled.

Both levels are computed on demand. Neither requires a separate stored counter subject to concurrency risk.

---

### 2.1 Organizational Lineage Awareness

Position headcount calculations shall respect organizational lineage.

Derived headcount values must resolve against:

- effective organizational hierarchy
- effective department membership
- effective legal entity structure

Headcount reporting shall remain reconstructable across:

- organizational restructuring events
- department realignments
- legal entity transitions

Organizational lineage integrity ensures point-in-time headcount accuracy.

---

## 3. Position Control Rules (Advisory Mode)

The following conditions generate warnings but do not block processing:

| Condition | Severity | Exception Code |
|---|---|---|
| Hire assignment would exceed position Headcount_Budget | Warning | EXC-HRS-002 |
| Hire assignment would exceed department Headcount_Budget | Warning | EXC-HRS-003 |
| Transfer into a FROZEN position | Warning | EXC-HRS-004 |
| Position has no active Headcount_Budget defined | Informational | EXC-HRS-005 |

All warnings are surfaced to the approving HR administrator and logged. The administrator may proceed with documented acknowledgement.

---

## 4. Vacancy Tracking

A position is considered vacant when:
- Position_Status = OPEN and Headcount_Filled < Headcount_Budget

A position is considered at-capacity when:
- Headcount_Filled >= Headcount_Budget

A position is over-capacity when:
- Headcount_Filled > Headcount_Budget (advisory mode permits this; generates EXC-HRS-002)

Vacancy reporting supports:
- Open positions by department, location, job family
- Days vacant (derived from last date a position was fully filled)
- Headcount vs budget variance by org unit

Vacancy status shall be derived deterministically using effective-dated assignment state.

Vacancy state shall not be stored independently where derivation is possible.

Derived vacancy state must remain reconstructable during replay and audit analysis.

---

## 5. Position Lifecycle Integration

| Event | Position Effect |
|---|---|
| HIRE | Assignment created → Position_Status evaluated → Headcount_Filled incremented |
| TRANSFER IN | Assignment updated → Headcount_Filled incremented at new position |
| TRANSFER OUT | Prior assignment closed → Headcount_Filled decremented at old position |
| TERMINATION | Assignment closed → Headcount_Filled decremented → Position may become OPEN |
| Position FROZEN | New hire assignments warned (EXC-HRS-004); existing occupants unaffected |
| Position CLOSED | Cannot be assigned; existing occupants must be transferred or terminated first |

Frozen status transitions shall require explicit governance approval.

Freeze events shall record:

- Freeze_Reason_Code
- Freeze_Effective_Date
- Freeze_Authority

Frozen status shall not retroactively invalidate existing assignments.

Position lifecycle transitions shall reference assignment lineage.

Assignment state changes impacting position capacity must remain traceable through:

- Assignment_ID
- Assignment_Lineage_ID
- Effective_Date sequence

Position lifecycle behavior shall remain reconstructable across assignment correction and replay workflows.

---

## 6. Department Headcount Budget Attributes

Added to Org_Unit for DEPARTMENT type units:

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Headcount_Budget | Integer | No | Approved FTE budget for the department |
| Headcount_Budget_Effective_Date | Date | No | When this budget came into effect |
| Headcount_Budget_Approved_By | UUID | No | Approver of the budget |

Department headcount budgets shall follow governed approval lifecycle controls.

Budget changes shall:

- be effective-dated
- preserve prior approved values
- record approval authority
- remain historically auditable

Silent overwriting of approved headcount budgets is not permitted.

---

## 7. Reporting Outputs

Position management supports the following operational reports:

- Open positions and days vacant
- Headcount vs budget by department
- Over-capacity departments and positions
- Position fill rate by period
- Vacancy trend over time

All reports resolve at an effective date for point-in-time accuracy.

All reporting outputs shall remain deterministic when evaluated against effective-dated data.

Historical reporting must resolve using:

- effective-dated position definitions
- effective-dated assignments
- effective organizational hierarchy

Later changes shall not reinterpret historical headcount values.

---

### 7.1 Structural Invariants

The following structural invariants shall be preserved:

- Headcount_Filled remains derived, not stored
- Vacancy state remains derived, not stored
- Position identity remains stable across lifecycle transitions
- Department budgets remain historically auditable
- Assignment-driven occupancy remains authoritative

Violation of these invariants introduces data integrity risk and shall not be permitted.

---

## 8. Future Expansion

Advisory-only position control is the v1 design. Future releases may introduce:
- Hard position control (cannot hire without an open, unfrozen position)
- Requisition-to-position workflow integration
- FTE vs headcount tracking (part-time weighting)
- Position budgeting integration with financial planning systems

---

## 9. Dependencies

This model depends on:

- Organizational_Structure_Model
- Employee_Assignment_Model
- Employee_Event_and_Status_Change_Model
- Employment_and_Person_Identity_Model
- Jurisdiction_and_Compliance_Rules_Model
- Configuration_and_Metadata_Management_Model
- Release_and_Approval_Model

---

## 10. Relationship to Other Models

This model integrates with:

- Organizational_Structure_Model
- Employee_Assignment_Model
- Employee_Event_and_Status_Change_Model
- Employment_and_Person_Identity_Model
- Operational_Reporting_and_Analytics_Model
- Workflow_Model
- Release_and_Approval_Model
- Configuration_and_Metadata_Management_Model
