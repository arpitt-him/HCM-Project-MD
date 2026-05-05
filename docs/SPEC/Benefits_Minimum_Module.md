# SPEC — Benefits Minimum Module

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.4 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/Benefits_Minimum_Module.md` |
| **Related Documents** | PRD-1000_Benefits_Boundary, ADR-007_Module_Composition_DI_Lifetime, ADR-012_Benefit_Election_Temporal_Integrity, SPEC/Payroll_Core_Module, docs/architecture/core/Benefit_Deduction_Election_Model.md, docs/architecture/core/Benefit_and_Deduction_Configuration_Model.md, docs/STATE/STATE-DED_Benefits_Deductions.md, docs/EXC/EXC-DED_Benefits_Deductions_Exceptions.md, SPEC/API_Surface_Map.md INT-BEN-001 |

**v0.4 changes from v0.3:** Section 17 — Timing Alignment Model added. `PipelineRequest` and `CalculationContext` extended with pay period boundary fields. `IBenefitStepProvider` signature changed to accept full `PipelineRequest`. `GetElectionsOverlappingPeriodAsync` added to `IBenefitElectionRepository`. `BenefitStepProvider` refactored to compute coverage fraction per election. `PostTaxPctBenefitStep` and `MatchBenefitStep` new step types added. Pipeline phase boundary added: `DisposableIncome` captured after tax phase (seq < 800), before post-tax deductions (seq ≥ 800).

**v0.3 changes from v0.2:** Deduction table renamed from `deduction_code` to `deduction`. Full rule-based calculation model added — six calculation modes, rate tables, employer match rules. Election record extended with mode-specific parameters. `employee_amount` is always populated (computed reference value for rule-based modes). Overlap enforcement via serializable transaction. Batch import uses `employee_number` not `employee_id`; sort-and-sweep overlap resolution. Retroactive payroll boundary clarified.

---

## Purpose

Defines the implementation-ready specification for the Benefits (minimum) module — the platform's v1 capability for configuring benefit deductions, managing employee elections, and delivering computed deduction amounts to payroll.

This module configures and computes deductions. It does not administer benefit plans.

The scope boundary is precise:
- **This module owns:** Deduction configuration (including calculation rules and rate tables), employer match rules, deduction elections, election lifecycle, payroll calculation delivery
- **This module does not own:** Plan design, open enrollment, carrier integration, dependent management, COBRA, ACA reporting

---

## 1. Calculation Modes

Every deduction record carries a `calculation_mode` that governs how the per-period deduction amount is derived. The payroll benefit step dispatches to the appropriate calculator at run time.

### 1.1 FIXED\_ANNUAL — Annual Amount Prorated Per Pay Period

```
per_period = annual_election_amount / context.annual_pay_periods
```

Used for: annual life insurance premiums, annual union dues, annual employer-paid benefits, annual professional fees.

The per-period amount is stable for a given pay frequency. It is computed at election creation and stored in `employee_amount` / `employer_contribution_amount`.

### 1.2 FIXED\_MONTHLY — Monthly Amount Applied in Active Pay Months

```
per_period = monthly_election_amount / pay_dates_in_calendar_month(payroll_context, pay_period)
```

Used for: health, dental, vision premiums; employer health contributions; parking/commuter benefits; gym memberships.

The pay-dates-in-month count is determined from the pay calendar:
- Semi-monthly: always 2
- Biweekly: 2 in most months, 3 in months with three pay dates
- Weekly: 4 in most months, 5 in months with five pay dates

When the count is 3 (or 5), behaviour is governed by `payroll_context.three_paycheck_month_rule`:
- `PRORATE` — divide by 3 (or 5); deduction is lighter in that period
- `SKIP` — deduction is zero on the extra pay date; employee is not charged in that period

`employee_amount` on the election record stores `monthly_election_amount / 2` (semi-monthly reference) as a display estimate. The payroll step overwrites it with the exact computed value after each run.

### 1.3 FIXED\_PER\_PERIOD — Flat Per-Pay-Period Amount

```
per_period = employee_amount  (stored directly)
```

Used for: flat union dues, garnishment admin fees, flat employer-paid benefits. This is the simplest mode and the only one where `employee_amount` on the election record is the direct input rather than a computed or reference value.

### 1.4 PCT\_PRE\_TAX — Percentage of Eligible Pre-Tax Gross

```
per_period = eligible_gross(wage_base) × contribution_pct
```

Used for: 401(k), 403(b), 457(b), HSA percentage contributions, pension plans, pre-tax union dues.

`wage_base` on the deduction record controls which earnings lines are included in the gross base:
- `ALL` — total gross wages including overtime, bonus, commission
- `REGULAR_ONLY` — regular pay only; overtime and supplemental excluded
- `ELIGIBLE_ONLY` — earnings types tagged as eligible for this deduction class
- `OT_ONLY` — overtime pay only (rare)

The employer match sub-step runs after the employee contribution is computed. See §4.

### 1.5 PCT\_POST\_TAX — Percentage of Post-Tax Wages

```
per_period = post_deduction_gross × contribution_pct
```

Used for: Roth 401(k), after-tax retirement contributions, some post-tax union dues, some supplemental insurance plans.

`post_deduction_gross` is the gross remaining after all pre-tax deductions have been applied by earlier pipeline steps. Employer contributions are typically absent for post-tax modes but are supported if configured.

### 1.6 COVERAGE\_BASED — Rate Table Lookup

```
per_period = rate_table_lookup(rate_type, dimension_value) × coverage_factor
```

Used for: medical/dental/vision coverage tiers, group life insurance (age-banded), salary-banded disability insurance.

The lookup dimension varies by `rate_type` on the rate table:

| rate_type | Dimension | employee_rate meaning |
|---|---|---|
| `COVERAGE_TIER` | `coverage_tier` on the election | Monthly flat amount for that tier |
| `AGE_BAND` | Employee age (per `age_as_of_rule`) | Rate per $1,000 of `annual_coverage_amount` |
| `SALARY_BAND` | Employee annual compensation | Rate per $1 of annual salary, or flat amount |

For `COVERAGE_TIER`, the employer contribution is often structured as: employer pays the `EE_ONLY` rate regardless of the employee's tier; the employee pays the difference. This is modelled as `employer_rate = EE_ONLY rate` on every tier entry; the UI renders it accordingly.

`age_as_of_rule` on the deduction record:
- `JAN_1` — employee's age as of 1 January of the plan year (industry standard for group life)
- `PAY_DATE` — employee's age on the pay date

---

## 2. Module Assembly Structure

```
AllWorkHRIS.Module.Benefits/
│
├── BenefitsModule.cs
│
├── Domain/
│   ├── Elections/
│   │   ├── BenefitDeductionElection.cs
│   │   ├── ElectionStatus.cs
│   │   └── TaxTreatment.cs
│   ├── Deductions/
│   │   ├── Deduction.cs
│   │   ├── DeductionStatus.cs
│   │   ├── CalculationMode.cs
│   │   ├── WageBase.cs
│   │   ├── DeductionRateTable.cs
│   │   ├── DeductionRateEntry.cs
│   │   └── DeductionEmployerMatch.cs
│   └── Calculators/
│       ├── IDeductionCalculator.cs
│       ├── FixedAnnualCalculator.cs
│       ├── FixedMonthlyCalculator.cs
│       ├── FixedPerPeriodCalculator.cs
│       ├── PctPreTaxCalculator.cs
│       ├── PctPostTaxCalculator.cs
│       ├── CoverageBasedCalculator.cs
│       └── DeductionCalculatorFactory.cs
│
├── Commands/
│   ├── CreateElectionCommand.cs
│   ├── AmendElectionCommand.cs
│   ├── TerminateElectionCommand.cs
│   ├── SuspendElectionCommand.cs
│   ├── CreateDeductionCommand.cs
│   ├── UpdateDeductionCommand.cs
│   ├── CreateRateTableCommand.cs
│   └── CreateMatchRuleCommand.cs
│
├── Queries/
│   ├── ElectionListQuery.cs
│   └── BenefitQueryTypes.cs       (ElectionListItem, BatchValidationResult, …)
│
├── Repositories/
│   ├── IDeductionRepository.cs
│   ├── IDeductionRateTableRepository.cs
│   ├── IDeductionEmployerMatchRepository.cs
│   └── IBenefitElectionRepository.cs
│
└── Services/
    ├── IBenefitElectionService.cs
    └── IBenefitElectionImportService.cs
```

---

## 3. Domain Commands

```csharp
// Commands/CreateElectionCommand.cs
public sealed record CreateElectionCommand
{
    public required Guid      EmploymentId             { get; init; }
    public required Guid      DeductionId              { get; init; }
    public required DateOnly  EffectiveStartDate       { get; init; }
    public DateOnly?          EffectiveEndDate         { get; init; }
    public required string    Source                   { get; init; }  // MANUAL | IMPORT | API
    public required Guid      CreatedBy                { get; init; }

    // Mode-specific inputs — only the fields relevant to the deduction's mode are set.
    // employee_amount and employer_contribution_amount are computed by the service
    // from these inputs and stored on the election as the reference per-period value.
    public decimal?   EmployeeAmount           { get; init; }  // FIXED_PER_PERIOD input
    public decimal?   EmployerAmount           { get; init; }  // FIXED_PER_PERIOD input
    public decimal?   AnnualElectionAmount     { get; init; }  // FIXED_ANNUAL input
    public decimal?   AnnualEmployerAmount     { get; init; }  // FIXED_ANNUAL input
    public decimal?   MonthlyElectionAmount    { get; init; }  // FIXED_MONTHLY input
    public decimal?   MonthlyEmployerAmount    { get; init; }  // FIXED_MONTHLY input
    public decimal?   ContributionPct          { get; init; }  // PCT_* input
    public string?    CoverageTier             { get; init; }  // COVERAGE_BASED input
    public decimal?   AnnualCoverageAmount     { get; init; }  // AGE_BAND input
}

// Commands/AmendElectionCommand.cs
// Supersedes a prior election: trims prior record's effective_end_date to
// AmendmentStartDate - 1 day, creates new versioned record from AmendmentStartDate.
// For same-start-date corrections use in-place update (see §6).
public sealed record AmendElectionCommand
{
    public required Guid     PriorElectionId          { get; init; }
    public required DateOnly AmendmentStartDate       { get; init; }
    public required string   CorrectionType           { get; init; }
    public required Guid     AmendedBy                { get; init; }

    // Supply only the fields that change; omit to inherit from prior election.
    public decimal?  EmployeeAmount           { get; init; }
    public decimal?  EmployerAmount           { get; init; }
    public decimal?  AnnualElectionAmount     { get; init; }
    public decimal?  AnnualEmployerAmount     { get; init; }
    public decimal?  MonthlyElectionAmount    { get; init; }
    public decimal?  MonthlyEmployerAmount    { get; init; }
    public decimal?  ContributionPct          { get; init; }
    public string?   CoverageTier             { get; init; }
    public decimal?  AnnualCoverageAmount     { get; init; }
    public DateOnly? EffectiveEndDate         { get; init; }
}

// Commands/TerminateElectionCommand.cs
public sealed record TerminateElectionCommand
{
    public required Guid     ElectionId        { get; init; }
    public required Guid     TerminatedBy      { get; init; }
    public DateOnly?         EffectiveEndDate  { get; init; }  // defaults to operative date
    public string?           TerminationReason { get; init; }
    public Guid?             SourceEventId     { get; init; }
}
```

---

## 4. Repository Interfaces

```csharp
// Repositories/IDeductionRepository.cs
public interface IDeductionRepository
{
    Task<Deduction?>             GetByIdAsync(Guid deductionId, CancellationToken ct = default);
    Task<Deduction?>             GetByCodeAsync(string code, CancellationToken ct = default);
    Task<IEnumerable<Deduction>> GetActiveAsync(CancellationToken ct = default);
    Task<Guid>                   InsertAsync(Deduction deduction, IUnitOfWork uow);
    Task                         UpdateAsync(Deduction deduction, IUnitOfWork uow);
}

// Repositories/IDeductionRateTableRepository.cs
public interface IDeductionRateTableRepository
{
    Task<DeductionRateTable?>             GetByIdAsync(Guid rateTableId, CancellationToken ct = default);
    Task<IEnumerable<DeductionRateTable>> GetByDeductionAsync(Guid deductionId, DateOnly asOf, CancellationToken ct = default);
    Task<IEnumerable<DeductionRateEntry>> GetEntriesAsync(Guid rateTableId, CancellationToken ct = default);
    Task<Guid>                            InsertTableAsync(DeductionRateTable table, IUnitOfWork uow);
    Task<Guid>                            InsertEntryAsync(DeductionRateEntry entry, IUnitOfWork uow);
}

// Repositories/IDeductionEmployerMatchRepository.cs
public interface IDeductionEmployerMatchRepository
{
    Task<DeductionEmployerMatch?> GetActiveMatchAsync(
        Guid deductionId, Guid? employeeGroupId, DateOnly asOf, CancellationToken ct = default);
}

// Repositories/IBenefitElectionRepository.cs
public interface IBenefitElectionRepository
{
    Task<BenefitDeductionElection?>             GetByIdAsync(Guid electionId, CancellationToken ct = default);
    Task<IEnumerable<BenefitDeductionElection>> GetByEmploymentIdAsync(Guid employmentId, CancellationToken ct = default);

    // Current-mode query: status = ACTIVE + effective date overlap
    Task<IEnumerable<BenefitDeductionElection>> GetActiveByEmploymentIdAsync(
        Guid employmentId, DateOnly asOf, CancellationToken ct = default);

    // Retroactive-mode query: effective date overlap only, excludes SUPERSEDED
    Task<IEnumerable<BenefitDeductionElection>> GetByEmploymentIdAtDateAsync(
        Guid employmentId, DateOnly asOf, CancellationToken ct = default);

    Task<IEnumerable<BenefitDeductionElection>> GetNonSupersededByEmploymentIdsAsync(
        Guid[] employmentIds, CancellationToken ct = default);

    Task<bool>                                  HasOverlapAsync(
        Guid employmentId, Guid deductionId,
        DateOnly start, DateOnly? end, Guid? excludeElectionId,
        CancellationToken ct = default);

    Task<Guid>                                  InsertAsync(
        BenefitDeductionElection election, IUnitOfWork uow);

    Task                                        UpdateStatusAsync(
        Guid electionId, string status, IUnitOfWork uow);

    Task                                        UpdateStatusWithEventAsync(
        Guid electionId, string status, Guid sourceEventId, IUnitOfWork uow);

    Task                                        TerminateAsync(
        Guid electionId, DateOnly effectiveEndDate, IUnitOfWork uow);

    Task                                        TerminateWithEventAsync(
        Guid electionId, DateOnly effectiveEndDate, Guid sourceEventId, IUnitOfWork uow);

    Task                                        TrimEndDateAsync(
        Guid electionId, DateOnly newEndDate, IUnitOfWork uow);

    Task<PagedResult<ElectionListItem>>         GetPagedListAsync(
        ElectionListQuery query, CancellationToken ct = default);
}
```

---

## 5. Service Interfaces

```csharp
// Services/IBenefitElectionService.cs
public interface IBenefitElectionService
{
    /// Creates a new election inside a SERIALIZABLE transaction.
    /// Validates deduction existence, mode-specific inputs, and absence of
    /// date-range overlap with non-SUPERSEDED elections for the same deduction.
    Task<Guid> CreateElectionAsync(
        CreateElectionCommand command, CancellationToken ct = default);

    /// Supersedes a prior election and creates a new versioned record from
    /// AmendmentStartDate. For same-start-date corrections, use
    /// CorrectElectionAsync instead.
    Task<Guid> AmendElectionAsync(
        AmendElectionCommand command, CancellationToken ct = default);

    /// In-place correction for same-start-date amendments.
    /// Updates the existing election's fields and writes an audit entry.
    /// Does not create a new election record.
    Task CorrectElectionAsync(
        AmendElectionCommand command, CancellationToken ct = default);

    /// Terminates an election. Sets effective_end_date to command.EffectiveEndDate
    /// or operative date if not supplied.
    Task TerminateElectionAsync(
        TerminateElectionCommand command, CancellationToken ct = default);

    /// Suspends an election (e.g. employee on unpaid leave).
    Task SuspendElectionAsync(
        Guid electionId, Guid sourceEventId, CancellationToken ct = default);

    /// Reinstates a suspended election.
    Task ReinstateElectionAsync(
        Guid electionId, Guid sourceEventId, CancellationToken ct = default);
}

// Services/IBenefitElectionImportService.cs
public interface IBenefitElectionImportService
{
    /// Validates a batch import file without posting (dry run).
    /// Runs sort-and-sweep overlap resolution; reports SupersededCount and warnings.
    Task<BatchValidationResult> ValidateBatchAsync(
        Stream fileContent, string fileFormat, CancellationToken ct = default);

    /// Submits a validated batch. Resolves overlaps via sort-and-sweep before
    /// inserting. Returns Job_ID; processing is synchronous in v1.
    Task<Guid> SubmitBatchAsync(
        Stream fileContent, string fileFormat, Guid submittedBy,
        CancellationToken ct = default);
}
```

---

## 6. Create Election — Implementation Pattern

```csharp
public async Task<Guid> CreateElectionAsync(
    CreateElectionCommand command, CancellationToken ct = default)
{
    var deduction = await _deductionRepo.GetByIdAsync(command.DeductionId, ct)
        ?? throw new DomainException("Deduction not found or inactive.");

    ValidateModeInputs(command, deduction);   // throws ValidationException on bad input

    // Compute reference per-period amounts from mode inputs
    var (eeAmount, erAmount) = ComputeReferenceAmounts(command, deduction);

    // Overlap check + insert in a single SERIALIZABLE transaction
    using var conn  = _connectionFactory.CreateConnection();
    conn.Open();
    using var tx    = conn.BeginTransaction(IsolationLevel.Serializable);
    var uow         = new UnitOfWork(conn, tx);
    try
    {
        var overlaps = await _electionRepo.HasOverlapAsync(
            command.EmploymentId, command.DeductionId,
            command.EffectiveStartDate, command.EffectiveEndDate,
            excludeElectionId: null, ct);

        if (overlaps)
            throw new InvalidOperationException(
                $"An election for this deduction already covers the requested date range.");

        var election = BenefitDeductionElection.Create(command, deduction, eeAmount, erAmount);
        var id       = await _electionRepo.InsertAsync(election, uow);
        uow.Commit();
        return id;
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

`ValidateModeInputs` enforces that the fields required by the deduction's `calculation_mode` are present and valid (e.g. `contribution_pct` is required and > 0 for PCT modes; `coverage_tier` is required and matches a valid tier for `COVERAGE_BASED`).

`ComputeReferenceAmounts` returns the best available per-period estimate for storage on the election record:
- `FIXED_ANNUAL` → `annual_election_amount / context.AnnualPayPeriods`
- `FIXED_MONTHLY` → `monthly_election_amount / 2` (semi-monthly reference)
- `FIXED_PER_PERIOD` → `employee_amount` directly
- `PCT_*` → `null` (zero until first payroll run)
- `COVERAGE_BASED` → rate table lookup using today's age/salary as a reference estimate

---

## 7. Amend Election — Implementation Pattern

```csharp
public async Task<Guid> AmendElectionAsync(
    AmendElectionCommand command, CancellationToken ct = default)
{
    var prior = await _electionRepo.GetByIdAsync(command.PriorElectionId, ct)
        ?? throw new NotFoundException(nameof(BenefitDeductionElection), command.PriorElectionId);

    if (command.AmendmentStartDate == prior.EffectiveStartDate)
        throw new InvalidOperationException(
            "Use CorrectElectionAsync for same-start-date corrections.");

    var deduction = await _deductionRepo.GetByIdAsync(prior.DeductionId, ct)!;
    var amended   = BenefitDeductionElection.CreateAmendment(prior, command, deduction);

    using var conn = _connectionFactory.CreateConnection();
    conn.Open();
    using var tx   = conn.BeginTransaction(IsolationLevel.Serializable);
    var uow        = new UnitOfWork(conn, tx);
    try
    {
        // Trim prior record's end date and mark superseded
        await _electionRepo.TrimEndDateAsync(
            prior.ElectionId,
            command.AmendmentStartDate.AddDays(-1), uow);
        await _electionRepo.UpdateStatusAsync(
            prior.ElectionId, ElectionStatus.Superseded, uow);

        // Overlap check for the new record (excluding prior, now trimmed)
        var overlaps = await _electionRepo.HasOverlapAsync(
            prior.EmploymentId, prior.DeductionId,
            command.AmendmentStartDate, amended.EffectiveEndDate,
            excludeElectionId: prior.ElectionId, ct);

        if (overlaps)
            throw new InvalidOperationException(
                "Amendment date range overlaps an existing election.");

        var id = await _electionRepo.InsertAsync(amended, uow);
        uow.Commit();
        return id;
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

---

## 8. Payroll Calculator Dispatch

The payroll benefit step calls `DeductionCalculatorFactory.GetCalculator(calculationMode)` to obtain the appropriate strategy, then calls `calculator.Compute(election, context)`.

```csharp
public interface IDeductionCalculator
{
    /// Returns (employeeAmount, employerAmount) for the given pay period.
    (decimal ee, decimal er) Compute(
        BenefitDeductionElection election,
        DeductionRateTable?      rateTable,
        DeductionEmployerMatch?  matchRule,
        PayrollCalculationContext context);
}
```

`PayrollCalculationContext` provides:
- `PayPeriodStart`, `PayPeriodEnd` — dates for the current pay period
- `PayDate` — the pay date
- `AnnualPayPeriods` — total pay periods in the year for this context
- `PayDatesInMonth(year, month)` — count from the pay calendar
- `ThreePaycheckMonthRule` — from `payroll_context`
- `EligibleGross(WageBase)` — accumulated gross filtered by wage base classification
- `PostDeductionGross` — gross after all pre-tax deductions applied so far
- `EmployeeAge(AgeAsOfRule)` — employee's age per the rule
- `AnnualCompensationRate` — from the compensation record as of pay period end date

**Employer match sub-step** runs immediately after the employee contribution is written:

```csharp
if (matchRule is not null)
{
    var capAmount = matchRule.MatchCapPctOfGross.HasValue
        ? context.EligibleGross(WageBase.All) * matchRule.MatchCapPctOfGross.Value
        : matchRule.MatchCapAnnualAmount!.Value / context.AnnualPayPeriods;

    var matchEr = Math.Min(eeAmount, capAmount) * matchRule.MatchRate;
    // Write as separate ER contribution result line
}
```

---

## 9. HRIS Event Integration

| HRIS Event | Benefits Module Action |
|---|---|
| `TERMINATION` | Terminate all ACTIVE/PENDING elections; set `effective_end_date` = termination date |
| `LEAVE_OF_ABSENCE` | Suspend all ACTIVE elections → STATE-DED-004 |
| `RETURN_TO_WORK` | Reinstate all SUSPENDED elections → STATE-DED-003 |

---

## 10. Batch Import (INT-BEN-001)

### 10.1 CSV Format

One row per election. Header row required.

| Column | Format | Required | Notes |
|---|---|---|---|
| `employee_number` | String | Yes | Resolved to `employment_id` at import time |
| `deduction_code` | String | Yes | Must match active deduction record |
| `contribution_pct` | Decimal | Mode | Required for PCT_PRE_TAX, PCT_POST_TAX |
| `coverage_tier` | String | Mode | Required for COVERAGE_BASED with COVERAGE_TIER rate type |
| `annual_coverage_amount` | Decimal | Mode | Required for COVERAGE_BASED with AGE_BAND rate type |
| `annual_election_amount` | Decimal | Mode | Required for FIXED_ANNUAL |
| `monthly_election_amount` | Decimal | Mode | Required for FIXED_MONTHLY |
| `employee_amount` | Decimal | Mode | Required for FIXED_PER_PERIOD |
| `employer_contribution_amount` | Decimal | No | For FIXED_PER_PERIOD ER override |
| `effective_start_date` | YYYY-MM-DD | Yes | |
| `effective_end_date` | YYYY-MM-DD | No | |

### 10.2 Overlap Resolution (Sort-and-Sweep)

Before validation or posting, the import service applies overlap resolution:

1. **Sort** all parsed rows by `(employee_number, deduction_code, effective_start_date ASC, effective_end_date ASC [NULL last], row_position ASC)`.
2. **Group** by `(employee_number, deduction_code)`. Prepend existing non-SUPERSEDED DB elections for those employee+code combinations as if they were earlier rows.
3. **Sweep** left to right within each group. When adjacent rows overlap, the earlier-start-date row loses → status `SUPERSEDED`; the later-start-date row continues as the candidate.
4. **Tiebreaker** when start dates are equal: later `effective_end_date` wins; if identical, last row in file wins.
5. **Status** for surviving rows: `ACTIVE` if `effective_start_date <= operativeDate`; `PENDING` otherwise.
6. **Lineage**: survivor's `parent_election_id` → immediately preceding superseded row; `original_election_id` → first in chain.

A **warning** (not error) is raised when a superseded row has a date range that extends before its overlap with the winner — meaning a prior period will be uncovered after the import.

### 10.3 Validation Result

```csharp
public sealed record BatchValidationResult
{
    public int                  TotalRecords    { get; init; }
    public int                  ValidCount      { get; init; }   // will be inserted as ACTIVE or PENDING
    public int                  SupersededCount { get; init; }   // will be inserted as SUPERSEDED
    public int                  InvalidCount    { get; init; }   // will be rejected
    public List<RecordError>    Errors          { get; init; }   // blocking errors
    public List<RecordWarning>  Warnings        { get; init; }   // non-blocking (uncovered period, etc.)
}
```

---

## 11. Activation Job

`BenefitElectionActivationJob` runs as a `BackgroundService`. Each cycle promotes PENDING elections to ACTIVE when `effective_start_date <= operativeDate`.

Behaviour follows `LeaveStatusTransitionJob` as the reference pattern:
- Injects `ITemporalContext` for the operative date
- Subscribes to `ITemporalOverrideService.OnChanged` to react immediately to TDO forward shifts
- Tracks last-cycle date and skips write operations on TDO backward shifts
- Uses `Guid.Empty` as the system actor

See ADR-012 §Decision 1 and §Decision 3 for full specification.

---

## 12. Payroll Boundary

Benefits delivers elections to Payroll through `IBenefitElectionRepository`. Two distinct read modes are supported:

**Current payroll run** → `GetActiveByEmploymentIdAsync(employmentId, payDate)`:
Filters `status = 'ACTIVE' AND effective_start_date <= @PayDate AND (effective_end_date IS NULL OR effective_end_date >= @PayDate)`. Correct for current-period runs.

**Retroactive payroll run** → `GetByEmploymentIdAtDateAsync(employmentId, payDate)`:
Filters by effective date overlap only; excludes `SUPERSEDED`; separately excludes elections suspended by leave at that date. See ADR-012 §Decision 4.

The payroll step calls `DeductionCalculatorFactory` with the election and context. It never calls Benefits services — only the repository. `employee_amount` on the election is a display reference; the authoritative per-period amount for a given run is computed by the calculator and written to the payroll result.

---

## 13. BenefitsModule Registration

```csharp
public void Register(ContainerBuilder builder)
{
    builder.RegisterType<DeductionRepository>()
           .As<IDeductionRepository>()
           .InstancePerLifetimeScope();

    builder.RegisterType<DeductionRateTableRepository>()
           .As<IDeductionRateTableRepository>()
           .InstancePerLifetimeScope();

    builder.RegisterType<DeductionEmployerMatchRepository>()
           .As<IDeductionEmployerMatchRepository>()
           .InstancePerLifetimeScope();

    builder.RegisterType<BenefitElectionRepository>()
           .As<IBenefitElectionRepository>()
           .InstancePerLifetimeScope();

    builder.RegisterType<BenefitElectionService>()
           .As<IBenefitElectionService>()
           .InstancePerLifetimeScope();

    builder.RegisterType<BenefitElectionImportService>()
           .As<IBenefitElectionImportService>()
           .InstancePerLifetimeScope();

    builder.RegisterType<DeductionCalculatorFactory>()
           .AsSelf()
           .InstancePerLifetimeScope();

    builder.RegisterType<BenefitElectionActivationJob>()
           .As<IHostedService>()
           .SingleInstance();
}
```

---

## 14. Role Definitions

| Role | Capabilities |
|---|---|
| `HrisAdmin` | Full access — create/amend/terminate elections; manage deductions, rate tables, match rules; import |
| `BenefitsAdmin` | Create/amend/terminate elections; view deductions and rate tables; import |
| `PayrollOperator` | Read-only access to elections (for payroll register reconciliation) |
| `Employee` | View own active elections via ESS — no write access |

---

## 15. Blazor Component Specifications

### 15.1 Deductions Page (`/benefits/codes`)

Grid — all deduction records.

**Columns:** Code, Description, Calculation Mode (badge), Tax Treatment, Status, Effective Start, Effective End, Actions (Edit, Manage Rate Table).

**+ Add Deduction button:** Form — Code, Description, Calculation Mode (dropdown), Tax Treatment, Wage Base (shown only for PCT modes), Age As-Of Rule (shown only for COVERAGE_BASED), Effective Start Date.

**Manage Rate Table:** Opens rate table editor for COVERAGE_BASED deductions. Allows adding/editing rate entries (tier codes, age/salary bands, employee and employer rates). Shows effective date range for the rate table.

**Manage Match Rule:** Opens match rule editor for PCT mode deductions. Fields: Match Rate (%), Cap Type (% of gross or annual amount), Cap Value, Employee Group (optional), Effective dates.

---

### 15.2 Elections Page (`/benefits/elections`)

Grid — all elections across all employees. Filterable by Code, Status, Effective Date range.

**Columns:** Employee, Code, Mode (badge), Treatment, Emp Amount (reference), ER Amount (reference), Effective Start, Effective End, Status, Source, Actions.

**+ Add Election button:** Mode-aware form. Fields rendered depend on the selected deduction's calculation mode:
- `FIXED_PER_PERIOD` → Employee Amount, Employer Amount
- `FIXED_ANNUAL` → Annual Employee Amount, Annual Employer Amount
- `FIXED_MONTHLY` → Monthly Employee Amount, Monthly Employer Amount
- `PCT_PRE_TAX` / `PCT_POST_TAX` → Contribution % (employer match auto-computed from match rule)
- `COVERAGE_BASED / COVERAGE_TIER` → Coverage Tier (dropdown from rate table entries)
- `COVERAGE_BASED / AGE_BAND` → Annual Coverage Amount

All modes show: Employee search, Deduction Code dropdown, Effective Start, Effective End (optional).

The form shows a computed reference amount for the selected mode and inputs so the user can confirm the expected deduction before saving.

---

### 15.3 Import Elections Page (`/benefits/import`)

Two-step flow.

**Step 1 — Upload and Validate:**
File upload → Validate button → `ValidateBatchAsync` dry run.

Result summary:
```
Total Records:     25
Valid / Active:    18
Valid / Pending:    4
Will Supersede:     2
Errors:             1
Warnings:           1
```

Error grid: Row, Field, Message.
Warning grid: Row, Message (non-blocking).

**Step 2 — Confirm and Import:**
"Import N Records" button (N = ValidCount + SupersededCount). Triggers `SubmitBatchAsync`.

---

## 16. Test Cases

| ID | Description | Expected Result |
|---|---|---|
| TC-BEN-001 | Create FIXED_PER_PERIOD election | Election created; `employee_amount` = input amount; status PENDING if future start |
| TC-BEN-002 | Create election with invalid deduction ID | DomainException — not found |
| TC-BEN-003 | Create election with negative amount | ValidationException |
| TC-BEN-004 | Create election with end date before start date | ValidationException |
| TC-BEN-005 | Create election overlapping existing non-SUPERSEDED election | InvalidOperationException — overlap detected |
| TC-BEN-006 | Create FIXED_ANNUAL election | `employee_amount` = annual / pay_periods; stored as reference |
| TC-BEN-007 | Create FIXED_MONTHLY election (biweekly, 2-paycheck month) | `employee_amount` stored as monthly / 2 reference |
| TC-BEN-008 | Create PCT_PRE_TAX election (401k, 6%) | `contribution_pct` = 0.06; `employee_amount` null until first run |
| TC-BEN-009 | Create COVERAGE_BASED / COVERAGE_TIER election (EE_ONLY) | `coverage_tier` stored; amount resolved at payroll time from rate table |
| TC-BEN-010 | Create COVERAGE_BASED / AGE_BAND election | `annual_coverage_amount` stored; rate per $1,000 looked up at payroll time |
| TC-BEN-011 | Create COVERAGE_BASED / SALARY_BAND election | Annual compensation read from compensation record at payroll time |
| TC-BEN-012 | Amend election mid-period | Prior trimmed to AmendmentStartDate−1; SUPERSEDED; new record created; no gap or overlap |
| TC-BEN-013 | Amend election with same start date | InvalidOperationException — use CorrectElectionAsync |
| TC-BEN-014 | CorrectElectionAsync same-start-date | In-place update; no new record; audit entry written |
| TC-BEN-015 | Terminate election (manual) | `effective_end_date` = operative date; status TERMINATED |
| TC-BEN-016 | Terminate election with supplied end date | `effective_end_date` = supplied date |
| TC-BEN-017 | HRIS TERMINATION event | All ACTIVE/PENDING elections terminated with termination date |
| TC-BEN-018 | HRIS LEAVE_OF_ABSENCE event | All ACTIVE elections suspended |
| TC-BEN-019 | HRIS RETURN_TO_WORK event | All SUSPENDED elections reinstated |
| TC-BEN-020 | Activation job promotes PENDING on effective date | Election transitions PENDING → ACTIVE when operativeDate >= effective_start_date |
| TC-BEN-021 | Activation job skips on TDO backward shift | No status changes written when operative date moves backward |
| TC-BEN-022 | PCT_PRE_TAX payroll calculation | Deduction = eligible_gross × contribution_pct; pre-tax gross reduced accordingly |
| TC-BEN-023 | PCT_PRE_TAX with employer match | Match = min(ee_contribution, cap) × match_rate; separate ER result line |
| TC-BEN-024 | PCT_POST_TAX payroll calculation | Deduction = post_deduction_gross × rate; taxable wages unaffected |
| TC-BEN-025 | FIXED_MONTHLY biweekly PRORATE 3-paycheck month | Amount = monthly / 3 on each of the three pay dates |
| TC-BEN-026 | FIXED_MONTHLY biweekly SKIP 3-paycheck month | Amount = monthly / 2 on first two pay dates; zero on third |
| TC-BEN-027 | COVERAGE_BASED AGE_BAND — age computed JAN_1 rule | Rate looked up using employee age as of 1 Jan of plan year |
| TC-BEN-028 | Retroactive payroll includes TERMINATED election within its effective period | TERMINATED election returned by GetByEmploymentIdAtDateAsync; deduction applied |
| TC-BEN-029 | Retroactive payroll excludes SUPERSEDED election | SUPERSEDED record not returned; amended record returned instead |
| TC-BEN-030 | Batch import — intra-batch overlap resolved by sweep | Earlier-start-date row inserted SUPERSEDED; later-start-date row inserted ACTIVE/PENDING |
| TC-BEN-031 | Batch import — overlap with existing DB election | DB election updated to SUPERSEDED, trimmed; import row inserted as winner |
| TC-BEN-032 | Batch import — validation surfaces SupersededCount and warnings | BatchValidationResult shows correct counts before commit |
| TC-BEN-033 | Suspended election excluded from current payroll run | Deduction not generated while election is SUSPENDED |
| TC-BEN-034 | Suspended election excluded from retroactive run during leave period | Leave check in retroactive query correctly excludes suspension period |

---

## 17. Timing Alignment Model

### 17.1 Background

The original pipeline assumed 100% coverage for every active election on the pay date. This produced incorrect amounts in five real-world scenarios:

1. **Monthly premiums on biweekly/weekly payrolls** — a flat monthly amount must be split across two or three pay dates in the month; in a 3-paycheck month the split can be either equal (PRORATE) or zero on the extra date (SKIP).
2. **Annual premiums on weekly payrolls** — a flat annual amount divided by 52 per period; in a 5-paycheck month the fifth period still divides by 52, which is correct.
3. **Employer match timing** — PER_PERIOD match stops when the employee stops contributing; ANNUAL_TRUE_UP pays best-effort per period and catches up on the last payroll.
4. **Mid-period hire / termination** — an election starting 10 days into a 14-day period should carry only `10/14` of the full-period deduction.
5. **Mid-period coverage change** — an amendment effective mid-period means the old rate applies for the first part and the new rate for the second part.

All five scenarios reduce to the same root problem: the pipeline needs to know the pay period boundaries and apply a **coverage fraction** to each election.

---

### 17.2 Pay Period Boundaries in the Pipeline

`PipelineRequest` now carries:

| Property | Type | Default | Purpose |
|---|---|---|---|
| `PayPeriodStart` | `DateOnly` | `default` → treated as PayDate | Start of the pay period |
| `PayPeriodEnd` | `DateOnly` | `default` → treated as PayDate | End of the pay period |
| `PayDatesInPeriodMonth` | `int` | `2` | How many pay dates fall in the calendar month of PayDate |
| `PayDateOrdinalInMonth` | `int` | `1` | Which occurrence this pay date is in its month (1-based) |
| `PartialPeriodRule` | `string` | `"PRORATE_DAYS"` | From `payroll_context.partial_period_rule` |
| `ThreePaycheckMonthRule` | `string` | `"PRORATE"` | From `payroll_context.three_paycheck_month_rule` |

The caller (the payroll run service, not the pipeline itself) is responsible for populating these fields from the pay calendar and `payroll_context`. When a caller does not set `PayPeriodStart` / `PayPeriodEnd`, both default to `PayDate` — the provider treats the period as a single day and produces a coverage fraction of 1.0 for all elections, preserving the original behaviour.

`CalculationContext` mirrors all six fields so that downstream steps can read them without receiving the request directly.

---

### 17.3 Election Query Strategy

`BenefitStepProvider` now calls `GetElectionsOverlappingPeriodAsync(employmentId, periodStart, periodEnd)` instead of the point-in-time `GetActiveByEmploymentIdAsync`. The new query returns all non-SUPERSEDED elections whose date range overlaps the pay period:

```sql
WHERE employment_id        = @EmploymentId
  AND status              != 'SUPERSEDED'
  AND effective_start_date <= @PeriodEnd
  AND (effective_end_date IS NULL OR effective_end_date >= @PeriodStart)
```

This captures elections that start mid-period (hire) and elections that end mid-period (termination or coverage change) — neither of which a point-in-time query on pay date would return.

---

### 17.4 Coverage Fraction Computation

For each election returned by the overlapping-period query, the provider computes a coverage fraction before building the pipeline step:

```
if election covers the full period:
    fraction = 1.0

else if PartialPeriodRule = FULL_PERIOD:
    fraction = 1.0

else if PartialPeriodRule = FIRST_FULL_PERIOD:
    fraction = 0.0   → step is omitted for this period

else (PRORATE_DAYS):
    coverage_start = max(election.EffectiveStartDate, periodStart)
    coverage_end   = min(election.EffectiveEndDate ?? periodEnd, periodEnd)
    fraction       = (coverage_end − coverage_start + 1) / (periodEnd − periodStart + 1)
    fraction       = min(1.0, fraction)
```

`FULL_PERIOD` charges the full amount even if the election started or ended within the period (e.g. always collect a full biweekly premium regardless of hire date). `FIRST_FULL_PERIOD` waives the deduction entirely in any partial period (no charge until the first fully-covered period). `PRORATE_DAYS` (the default) charges in proportion to the number of calendar days covered.

The fraction is applied to `election.EmployeeAmount` and `election.EmployerContributionAmount` before passing the amounts to the step. When `fraction = 0`, the step is skipped entirely.

---

### 17.5 Pipeline Phase Boundary

The pipeline now executes in two passes to enable `DisposableIncome` computation at the correct point:

**Pass 1 — Sequence < 800** (pre-tax benefits + all tax steps):
All pre-tax benefit deductions (seq 100–199) reduce `IncomeTaxableWages` and `NetPay`. Tax steps (seq 200–799) read the reduced taxable wages and write to `ComputedTax`.

**Phase boundary**:
```
DisposableIncome = ctx.NetPay   // net pay after taxes, before post-tax deductions
```

`DisposableIncome` is the base for garnishment calculations (seq 900–999, not yet implemented). Federal and state garnishment caps are expressed as percentages of disposable income.

**Pass 2 — Sequence ≥ 800** (post-tax benefits + employer-only steps):
Post-tax benefit deductions reduce `NetPay` but not `IncomeTaxableWages`. Employer-only steps write to `EmployerCost` only.

---

### 17.6 New Step Types

**`PostTaxPctBenefitStep`** (seq 800–899)

Used for `PCT_POST_TAX` mode (Roth 401k, after-tax contributions). Unlike `PostTaxBenefitStep` which takes a pre-computed fixed amount, this step reads `ctx.IncomeTaxableWages` at execute time to capture whatever post-deduction gross resulted from the pre-tax steps that ran before it:

```
amount = ctx.IncomeTaxableWages × rate × coverageFraction
```

`IncomeTaxableWages` at seq 800+ equals gross minus all pre-tax deductions — the correct post-deduction gross base.

**`MatchBenefitStep`** (seq 110–199, immediately after the employee PCT contribution step)

Computes the employer match on the employee's actual per-period contribution. The employee step result is read from `ctx.StepResults` at execute time:

```
matchable   = min(ctx.StepResults[eeStepCode], periodCap)
matchAmount = matchable × matchRate
```

`periodCap` is pre-computed by the provider from the match rule:
- If `MatchCapPctOfGross` is set: `cap = eligibleGross × matchCapPct` (approximated as `GrossPayPeriod × matchCapPct` in the current implementation)
- If `MatchCapAnnualAmount` is set: `cap = matchCapAnnualAmount / payPeriodsPerYear`

**YTD True-Up for `ANNUAL_TRUE_UP`**: The per-period match is paid at `PER_PERIOD` rate throughout the year. On the last payroll of the year, an additional `BenefitElectionActivationJob`-style service computes:

```
entitlement = min(ytd_ee_contribution, annual_cap) × matchRate
true_up     = max(0, entitlement − ytd_match_paid)
```

The true-up is written as a separate result line. This logic is deferred to when the YTD balance accumulator service is wired into the pipeline.

---

### 17.7 Partial Period Rules Reference

| Rule | Meaning | Typical Use |
|---|---|---|
| `PRORATE_DAYS` | Deduction = full × (coverage\_days / period\_days) | Default; most benefit types |
| `FIRST_FULL_PERIOD` | No deduction in any partial period; full deduction starts with first fully-covered period | Some insurance carriers; reduces admin complexity |
| `FULL_PERIOD` | Always charge full period regardless of hire / term date | Union dues; flat admin fees |

These values live on `payroll_context.partial_period_rule` and are carried into `PipelineRequest` by the caller.

---

### 17.8 FIXED\_MONTHLY Calendar Resolution

For `FIXED_MONTHLY` deductions, the per-period amount is:

```
if ThreePaycheckMonthRule = SKIP and PayDateOrdinalInMonth > 2:
    amount = 0   (extra pay date — deduction waived)
else:
    amount = monthly_election_amount / PayDatesInPeriodMonth
```

`PayDatesInPeriodMonth` and `PayDateOrdinalInMonth` are populated by the caller from the pay calendar. The coverage fraction still applies on top of this computed amount if the election does not cover the full period.

This logic lives in the `FixedMonthlyCalculator` (part of the `IDeductionCalculator` strategy pattern, deferred to the calculator build phase). The current `BenefitStepProvider` uses the stored `employee_amount` reference value for all modes; the calculator-based dispatch replaces this in the next phase.
