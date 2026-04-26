# SPEC — Payroll Core Module

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll |
| **Location** | `docs/SPEC/Payroll_Core_Module.md` |
| **Related Documents** | PRD-0300_Payroll_Calendar, PRD-0400_Earnings_Model, PRD-0500_Accumulator_Strategy, PRD-0600_Jurisdiction_Model, ADR-007_Module_Composition_DI_Lifetime, ADR-004_Data_Access_Strategy, ADR-005_Background_Job_Execution, SPEC/Host_Application_Shell, SPEC/HRIS_Core_Module, docs/architecture/processing/Payroll_Run_Model.md, docs/architecture/processing/Payroll_Run_Result_Set_Model.md, docs/architecture/processing/Employee_Payroll_Result_Model.md, docs/architecture/calculation-engine/Earnings_and_Deductions_Computation_Model.md, docs/architecture/processing/Accumulator_Impact_Model.md, docs/STATE/STATE-RUN_Payroll_Run.md |

---

## Purpose

Defines the implementation-ready specification for the Payroll Core module — the platform's calculation engine, run lifecycle management, result set production, accumulator mutation, and payroll operator UI.

This document covers the module assembly structure, service contracts, run initiation and lifecycle, the ordered computation flow, result line generation, accumulator mutation chain, the async job execution pattern for payroll runs, Blazor component specifications for the payroll operator UI, and test cases.

The Payroll module consumes HRIS events and data but does not own them. It owns calculation results, accumulators, liabilities, and pay statements. It does not write back to HRIS records.

---

## 1. Module Assembly Structure

```
AllWorkHRIS.Module.Payroll/
│
├── PayrollModule.cs                      # IPlatformModule implementation
│
├── Domain/
│   ├── Run/
│   │   ├── PayrollRun.cs
│   │   ├── PayrollRunStatus.cs           # Enum — STATE-RUN states
│   │   └── PayrollRunType.cs             # Enum — REGULAR, SUPPLEMENTAL, etc.
│   ├── ResultSet/
│   │   ├── PayrollRunResultSet.cs
│   │   └── ResultSetStatus.cs
│   ├── Results/
│   │   ├── EmployeePayrollResult.cs
│   │   ├── EarningsResultLine.cs
│   │   ├── DeductionResultLine.cs
│   │   ├── TaxResultLine.cs
│   │   └── EmployerContributionResultLine.cs
│   ├── Accumulators/
│   │   ├── AccumulatorDefinition.cs
│   │   ├── AccumulatorImpact.cs
│   │   ├── AccumulatorContribution.cs
│   │   └── AccumulatorBalance.cs
│   ├── Calendar/
│   │   ├── PayrollContext.cs
│   │   └── PayrollPeriod.cs
│   └── Events/
│       ├── HireEventHandler.cs           # Subscribes to HRIS HIRE event
│       ├── TerminationEventHandler.cs    # Subscribes to HRIS TERMINATION event
│       ├── CompensationChangeHandler.cs  # Subscribes to HRIS COMPENSATION_CHANGE event
│       └── LeaveApprovedHandler.cs       # Subscribes to HRIS LEAVE_APPROVED event
│
├── Commands/
│   ├── InitiatePayrollRunCommand.cs
│   ├── ApprovePayrollRunCommand.cs
│   ├── ReleasePayrollRunCommand.cs
│   └── CancelPayrollRunCommand.cs
│
├── Repositories/
│   ├── IPayrollRunRepository.cs
│   ├── IPayrollRunResultSetRepository.cs
│   ├── IEmployeePayrollResultRepository.cs
│   ├── IResultLineRepository.cs
│   ├── IAccumulatorRepository.cs
│   └── IPayrollContextRepository.cs
│
├── Services/
│   ├── IPayrollRunService.cs
│   ├── ICalculationEngine.cs
│   ├── IAccumulatorService.cs
│   └── IPayrollEventSubscriber.cs
│
└── Jobs/
    └── PayrollRunJob.cs                  # IHostedService background job
```

---

## 2. PayrollModule Registration

```csharp
[Export(typeof(IPlatformModule))]
public sealed class PayrollModule : IPlatformModule
{
    public void Register(ContainerBuilder builder)
    {
        // Repositories
        builder.RegisterType<PayrollRunRepository>()
               .As<IPayrollRunRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<PayrollRunResultSetRepository>()
               .As<IPayrollRunResultSetRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<EmployeePayrollResultRepository>()
               .As<IEmployeePayrollResultRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<ResultLineRepository>()
               .As<IResultLineRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<AccumulatorRepository>()
               .As<IAccumulatorRepository>()
               .InstancePerLifetimeScope();

        // Services
        builder.RegisterType<PayrollRunService>()
               .As<IPayrollRunService>()
               .InstancePerLifetimeScope();

        builder.RegisterType<CalculationEngine>()
               .As<ICalculationEngine>()
               .InstancePerLifetimeScope();

        builder.RegisterType<AccumulatorService>()
               .As<IAccumulatorService>()
               .InstancePerLifetimeScope();

        // HRIS event subscriber — singleton; stateless
        builder.RegisterType<PayrollEventSubscriber>()
               .As<IPayrollEventSubscriber>()
               .SingleInstance();
    }

    public IEnumerable<MenuContribution> GetMenuContributions() =>
    [
        new MenuContribution
        {
            Label        = "Payroll",
            Icon         = "payroll-icon",
            SortOrder    = 20,
            AccentColor  = "var(--color-accent-coral)",
            BadgeLabel   = "PAY",
            RequiredRole = "PayrollOperator"
        },
        new MenuContribution
        {
            Label        = "Payroll Runs",
            Href         = "/payroll/runs",
            Icon         = "icon-run",
            SortOrder    = 1,
            ParentLabel  = "Payroll",
            RequiredRole = "PayrollOperator"
        },
        new MenuContribution
        {
            Label        = "Pay Register",
            Href         = "/payroll/register",
            Icon         = "icon-register",
            SortOrder    = 2,
            ParentLabel  = "Payroll",
            RequiredRole = "PayrollOperator"
        },
        new MenuContribution
        {
            Label        = "Accumulators",
            Href         = "/payroll/accumulators",
            Icon         = "icon-accumulator",
            SortOrder    = 3,
            ParentLabel  = "Payroll",
            RequiredRole = "PayrollAdmin"
        }
    ];
}
```

---

## 3. HRIS Event Subscription

The Payroll module subscribes to HRIS lifecycle events. These subscriptions are wired at startup through the `IPayrollEventSubscriber` singleton.

```csharp
public interface IPayrollEventSubscriber
{
    // Called by the event publisher after a HIRE event is committed in HRIS
    Task HandleHireAsync(HireEventPayload payload);

    // Called by the event publisher after a TERMINATION event
    Task HandleTerminationAsync(TerminationEventPayload payload);

    // Called by the event publisher after a COMPENSATION_CHANGE event
    Task HandleCompensationChangeAsync(CompensationChangeEventPayload payload);

    // Called by the event publisher after a LEAVE_APPROVED event from HRIS
    Task HandleLeaveApprovedAsync(LeaveApprovedPayload payload);

    // Called by the event publisher after a RETURN_TO_WORK event
    Task HandleReturnToWorkAsync(ReturnToWorkPayload payload);
}
```

**On HIRE:** Payroll module creates a `PayrollProfile` record for the new Employment_ID, linking it to the `PayrollContext` declared in the hire event. The employment becomes eligible for inclusion in the next payroll run after onboarding blocking tasks complete.

**On TERMINATION:** Payroll module flags the Employment_ID as pending final pay. Final pay calculation is included in the next run or an off-cycle run depending on jurisdiction rules.

**On COMPENSATION_CHANGE:** If retroactive, the module creates a recalculation work queue item for the affected periods. If prospective, the new rate becomes effective at the start of the next payroll period after the effective date.

**On LEAVE_APPROVED:** The module records the leave impact signal against the Employment_ID for consumption during the next payroll calculation for the affected period.

---

## 4. Domain Commands

```csharp
// Commands/InitiatePayrollRunCommand.cs
public sealed record InitiatePayrollRunCommand
{
    public required Guid   PayrollContextId  { get; init; }
    public required Guid   PeriodId          { get; init; }
    public required string RunType           { get; init; }  // REGULAR, SUPPLEMENTAL, etc.
    public string?         RunDescription    { get; init; }
    public required Guid   InitiatedBy       { get; init; }
}

// Commands/ApprovePayrollRunCommand.cs
public sealed record ApprovePayrollRunCommand
{
    public required Guid RunId       { get; init; }
    public required Guid ApprovedBy  { get; init; }
    public string?       Notes       { get; init; }
}

// Commands/ReleasePayrollRunCommand.cs
public sealed record ReleasePayrollRunCommand
{
    public required Guid RunId      { get; init; }
    public required Guid ReleasedBy { get; init; }
}
```

---

## 5. Service Interfaces

```csharp
// Services/IPayrollRunService.cs
public interface IPayrollRunService
{
    /// <summary>
    /// Validates the run can be initiated (no duplicate open run for period),
    /// creates the PayrollRun record in DRAFT state, submits the
    /// PAYROLL_RUN_CALCULATION async job, and returns the run ID and Job_ID.
    /// </summary>
    Task<InitiateRunResult> InitiateRunAsync(InitiatePayrollRunCommand command);

    Task ApproveRunAsync(ApprovePayrollRunCommand command);
    Task ReleaseRunAsync(ReleasePayrollRunCommand command);
    Task CancelRunAsync(Guid runId, Guid cancelledBy, string reason);

    Task<PayrollRun?> GetRunAsync(Guid runId);
    Task<PagedResult<PayrollRunSummary>> GetRunsAsync(Guid payrollContextId,
        int page, int pageSize);
}

// Services/ICalculationEngine.cs
public interface ICalculationEngine
{
    /// <summary>
    /// Executes the full ordered computation for a single Employment_ID
    /// within a run context. Returns the employee payroll result with
    /// all result lines, tax impacts, and accumulator impacts.
    /// Called by PayrollRunJob for each employee in the run population.
    /// </summary>
    Task<EmployeeCalculationResult> CalculateEmployeeAsync(
        Guid runId, Guid employmentId, CancellationToken ct);
}

// Services/IAccumulatorService.cs
public interface IAccumulatorService
{
    /// <summary>
    /// Applies accumulator impacts from result lines to the four-layer
    /// accumulator chain (Definition → Impact → Contribution → Balance).
    /// All four writes are atomic within the provided unit of work.
    /// </summary>
    Task ApplyImpactsAsync(Guid employeePayrollResultId,
        IEnumerable<ResultLineAccumulatorInput> inputs, IUnitOfWork uow);

    Task<IEnumerable<AccumulatorBalance>> GetBalancesAsync(
        Guid employmentId, string periodContext, DateOnly asOf);
}
```

---

## 6. Run Initiation and Async Job Pattern

Payroll run calculation is the canonical example of the async job pattern from ADR-005 and `SPEC/Host_Application_Shell`.

```csharp
public async Task<InitiateRunResult> InitiateRunAsync(
    InitiatePayrollRunCommand command)
{
    // 1. Validate — no open run for this context/period
    var existing = await _runRepository.GetOpenRunAsync(
        command.PayrollContextId, command.PeriodId);
    if (existing is not null)
        throw new DomainException(
            $"An open payroll run already exists for this period: {existing.RunId}");

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        // 2. Create run record in DRAFT state
        var run = PayrollRun.CreateNew(command);
        await _runRepository.InsertAsync(run, uow);

        // 3. Create Platform_Job record — QUEUED
        var job = PlatformJob.CreateForPayrollRun(run.RunId, command.InitiatedBy);
        await _jobRepository.InsertAsync(job, uow);

        uow.Commit();

        // 4. Enqueue to background processing channel AFTER commit
        _jobChannel.Writer.TryWrite(job.JobId);

        return new InitiateRunResult(run.RunId, job.JobId);
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

The response to the UI is immediate — `RunId` and `JobId` returned within the HTTP response. The UI subscribes to job status updates via SignalR.

---

## 7. PayrollRunJob — Background Service

```csharp
public class PayrollRunJob : BackgroundService
{
    protected override async Task ExecuteAsync(CancellationToken ct)
    {
        await foreach (var jobId in _jobChannel.Reader.ReadAllAsync(ct))
        {
            await ProcessJobAsync(jobId, ct);
        }
    }

    private async Task ProcessJobAsync(Guid jobId, CancellationToken ct)
    {
        var job = await _jobRepository.GetByIdAsync(jobId);
        var run = await _runRepository.GetByIdAsync(job.SourceEntityId);

        try
        {
            // Transition run to CALCULATING
            await UpdateJobProgressAsync(jobId, JobStatus.Running, 0,
                "Resolving run population...", 0, 0);

            // Resolve eligible employee population
            var population = await ResolvePopulationAsync(run);
            var total = population.Count;

            await UpdateJobProgressAsync(jobId, JobStatus.Running, 5,
                $"Calculating {total} employees...", total, 0);

            // Create result set
            var resultSet = PayrollRunResultSet.CreateForRun(run.RunId);
            await _resultSetRepository.InsertAsync(resultSet);

            int processed = 0;
            int failed = 0;

            // Calculate each employee
            foreach (var employmentId in population)
            {
                ct.ThrowIfCancellationRequested();

                try
                {
                    var result = await _calculationEngine
                        .CalculateEmployeeAsync(run.RunId, employmentId, ct);

                    using var uow = new UnitOfWork(_connectionFactory);
                    try
                    {
                        // Write employee result and all result lines atomically
                        await _resultRepository.InsertWithLinesAsync(result, uow);

                        // Apply accumulator impacts (4-layer chain) atomically
                        await _accumulatorService.ApplyImpactsAsync(
                            result.EmployeePayrollResultId,
                            result.AccumulatorInputs, uow);

                        uow.Commit();
                        processed++;
                    }
                    catch
                    {
                        uow.Rollback();
                        failed++;
                        await _exceptionService.RecordCalculationFailureAsync(
                            run.RunId, employmentId, ex);
                    }
                }
                catch (Exception ex)
                {
                    // Employee-level failure — isolated; continue run
                    failed++;
                    await _exceptionService.RecordCalculationFailureAsync(
                        run.RunId, employmentId, ex);
                }

                // Update progress every 10 employees or 5%
                if (processed % 10 == 0 || processed % (total / 20) == 0)
                {
                    var pct = (int)((processed + failed) * 100.0 / total);
                    await UpdateJobProgressAsync(jobId, JobStatus.Running,
                        pct, $"Calculated {processed} of {total}...",
                        total, processed, failed);
                }
            }

            // Transition run to CALCULATED
            await _runRepository.UpdateStatusAsync(run.RunId,
                PayrollRunStatus.Calculated);

            await UpdateJobProgressAsync(jobId, JobStatus.Completed, 100,
                $"Complete — {processed} calculated, {failed} failed",
                total, processed, failed);
        }
        catch (Exception ex)
        {
            await _runRepository.UpdateStatusAsync(run.RunId,
                PayrollRunStatus.Failed);
            await UpdateJobProgressAsync(jobId, JobStatus.FailedPermanent, 0,
                $"Run failed: {ex.Message}", 0, 0, 0);
        }
    }
}
```

**Key design decisions:**
- Employee-level failures are isolated — one employee's failure does not stop the run
- Each employee's result writes are atomic (result lines + accumulator impacts in one transaction)
- Progress is pushed to the SignalR hub after every 10 employees for real-time operator visibility
- Run transitions to CALCULATED only after all employees complete

---

## 8. Ordered Computation Flow

Per `Earnings_and_Deductions_Computation_Model` §5, each employee is computed in strict order:

```csharp
public async Task<EmployeeCalculationResult> CalculateEmployeeAsync(
    Guid runId, Guid employmentId, CancellationToken ct)
{
    // Resolve context
    var context = await _contextResolver.ResolveAsync(runId, employmentId);

    var resultLines = new List<ResultLine>();

    // Step 1 — Base earnings (regular/salary)
    resultLines.AddRange(await _earningsCalculator
        .CalculateBaseEarningsAsync(context));

    // Step 2 — Premium earnings (overtime, holiday, shift differential)
    resultLines.AddRange(await _earningsCalculator
        .CalculatePremiumEarningsAsync(context));

    // Step 3 — Pre-tax deductions (reduce taxable wage base)
    resultLines.AddRange(await _deductionCalculator
        .CalculatePreTaxDeductionsAsync(context));

    // Step 4 — Imputed income (increase taxable wage base)
    resultLines.AddRange(await _earningsCalculator
        .CalculateImputedIncomeAsync(context));

    // Step 5 — Taxable wage determination
    var taxableWages = TaxableWageCalculator.Calculate(resultLines, context);

    // Step 6 — Tax withholdings (federal, state, local)
    resultLines.AddRange(await _taxCalculator
        .CalculateTaxWithholdingsAsync(context, taxableWages));

    // Step 7 — Post-tax deductions
    resultLines.AddRange(await _deductionCalculator
        .CalculatePostTaxDeductionsAsync(context));

    // Step 8 — Employer contributions
    resultLines.AddRange(await _deductionCalculator
        .CalculateEmployerContributionsAsync(context));

    // Step 9 — Net pay
    var netPay = NetPayCalculator.Calculate(resultLines);

    // Step 10 — Resolve accumulator impacts per result line
    var accumulatorInputs = _accumulatorResolver
        .ResolveImpacts(resultLines, context);

    return new EmployeeCalculationResult(
        RunId:                    runId,
        EmploymentId:             employmentId,
        ResultLines:              resultLines,
        NetPay:                   netPay,
        AccumulatorInputs:        accumulatorInputs,
        TaxableWages:             taxableWages,
        EmployeePayrollResultId:  Guid.NewGuid()
    );
}
```

The computation context includes: employment record, assignment, compensation rate (as of pay period), approved time entries (from T&A), active benefit deduction elections, leave impact signals, jurisdiction rules (effective-dated), and accumulator balances (for wage base limit evaluation).

---

## 9. Accumulator Mutation Chain

Per the four-layer accumulator model, each result line generates impacts that flow through all four layers atomically:

```
Result Line
    ↓
AccumulatorImpact     (mutation event — what changed and by how much)
    ↓
AccumulatorContribution (persisted history — the balance-affecting record)
    ↓
AccumulatorBalance    (current authoritative state — updated in place)
```

```csharp
public async Task ApplyImpactsAsync(Guid employeePayrollResultId,
    IEnumerable<ResultLineAccumulatorInput> inputs, IUnitOfWork uow)
{
    foreach (var input in inputs)
    {
        // 1. Get current balance
        var balance = await _accumulatorRepository
            .GetOrCreateBalanceAsync(input.AccumulatorDefinitionId,
                input.EmploymentId, input.PeriodContext, uow);

        var priorValue = balance.CurrentValue;
        var newValue   = priorValue + input.DeltaValue;

        // 2. Create Impact record (Layer 2)
        var impact = AccumulatorImpact.Create(
            input, employeePayrollResultId, priorValue, newValue);
        await _accumulatorRepository.InsertImpactAsync(impact, uow);

        // 3. Create Contribution record (Layer 3)
        var contribution = AccumulatorContribution.Create(
            balance.AccumulatorId, impact.AccumulatorImpactId,
            input, priorValue, newValue);
        await _accumulatorRepository.InsertContributionAsync(contribution, uow);

        // 4. Update Balance (Layer 4)
        await _accumulatorRepository.UpdateBalanceAsync(
            balance.AccumulatorId, newValue,
            employeePayrollResultId, uow);
    }
}
```

All four writes occur within the same `IUnitOfWork` transaction as the employee result lines — they succeed or fail together.

---

## 10. Repository Interfaces

```csharp
// Repositories/IPayrollRunRepository.cs
public interface IPayrollRunRepository
{
    Task<PayrollRun?>    GetByIdAsync(Guid runId);
    Task<PayrollRun?>    GetOpenRunAsync(Guid payrollContextId, Guid periodId);
    Task<Guid>           InsertAsync(PayrollRun run, IUnitOfWork uow);
    Task                 UpdateStatusAsync(Guid runId, PayrollRunStatus status);
    Task<PagedResult<PayrollRunSummary>> GetPagedAsync(
        Guid payrollContextId, int page, int pageSize);
}

// Repositories/IEmployeePayrollResultRepository.cs
public interface IEmployeePayrollResultRepository
{
    Task<EmployeePayrollResult?> GetByIdAsync(Guid resultId);
    Task<IEnumerable<EmployeePayrollResult>> GetByRunIdAsync(Guid runId);
    Task<EmployeePayrollResult?> GetByRunAndEmploymentAsync(
        Guid runId, Guid employmentId);
    Task InsertWithLinesAsync(EmployeeCalculationResult result, IUnitOfWork uow);
}

// Repositories/IAccumulatorRepository.cs
public interface IAccumulatorRepository
{
    Task<AccumulatorBalance> GetOrCreateBalanceAsync(
        Guid accumulatorDefinitionId, Guid employmentId,
        string periodContext, IUnitOfWork uow);
    Task InsertImpactAsync(AccumulatorImpact impact, IUnitOfWork uow);
    Task InsertContributionAsync(AccumulatorContribution contribution, IUnitOfWork uow);
    Task UpdateBalanceAsync(Guid accumulatorId, decimal newValue,
        Guid lastUpdatedResultId, IUnitOfWork uow);
    Task<IEnumerable<AccumulatorBalance>> GetBalancesAsync(
        Guid employmentId, string periodContext, DateOnly asOf);
}
```

---

## 11. Blazor Component Specifications

### 11.1 Payroll Run List Page (`/payroll/runs`)

Summary stat cards at top:

| Card | Value |
|---|---|
| Open Runs | Count of runs in DRAFT / CALCULATING / CALCULATED / UNDER_REVIEW |
| Next Pay Date | Nearest upcoming pay date across active payroll contexts |
| Last Released | Most recent released run pay date |
| Pending Approval | Count of runs in APPROVED awaiting release |

Syncfusion Grid — columns:

| Column | Notes |
|---|---|
| Run ID / Description | Links to run detail |
| Period | Pay period start — end |
| Pay Date | |
| Run Type | Badge — REGULAR, SUPPLEMENTAL, etc. |
| Status | Colour-coded badge per STATE-RUN |
| Employees | Count in run population |
| Calculated | Count successfully calculated |
| Exceptions | Count with exceptions — links to exception list |
| Initiated By | |
| Actions | Open; Approve; Release; Cancel — contextual per status |

**+ New Run button** (PayrollAdmin): Opens run initiation form. On submit, returns JobId; UI subscribes to progress.

---

### 11.2 Run Progress Panel

Displayed during CALCULATING state. Shown inline above the run grid or as a persistent panel.

Powered by SignalR subscription to `Platform_Job` updates for the active run.

**Displays:**
- Job status badge (QUEUED / RUNNING / COMPLETED / FAILED)
- Progress bar — `progress_percent`
- "Calculated N of M employees" — `processed_records` / `total_records`
- "N failed" — `failed_records` (amber if > 0)
- Elapsed time
- Current progress message — `progress_message`

Updates in real time without page refresh. The operator can continue using other parts of the UI while the run calculates.

---

### 11.3 Run Detail Page (`/payroll/runs/{runId}`)

Tabbed layout:

| Tab | Content |
|---|---|
| Summary | Run metadata, status, pay date, population count, gross/net totals |
| Pay Register | Employee-level register grid — see §11.4 |
| Exceptions | Exception list for this run with severity, status, resolution |
| Variance | Period-over-period variance report — flagged employees |
| Accumulators | Aggregated YTD accumulator summary for this run |
| Actions | Approve / Release / Cancel buttons with confirmation |

---

### 11.4 Pay Register Grid (`/payroll/runs/{runId}/register`)

Syncfusion Grid — high-density read-only view of all employee results for the run.

**Columns:**

| Column | Source |
|---|---|
| Employee | Legal name + Employment_ID |
| Gross Pay | `gross_pay_amount` |
| Pre-Tax Deductions | Sum of `DEDUCTION_PRE_TAX` result lines |
| Taxable Wages | Derived |
| Employee Taxes | Sum of `TAX_WITHHOLDING` result lines |
| Post-Tax Deductions | Sum of `DEDUCTION_POST_TAX` result lines |
| Net Pay | `net_pay_amount` |
| Status | `result_status` badge |
| Exceptions | Count — links to employee exceptions |

**Drill-down:** Click a row to open the employee pay detail panel — full result line breakdown, accumulator impacts, and exception detail for that employee in this run.

**Export:** CSV export of full register. PDF export of formatted register. Requires PayrollOperator role.

**Date-range filter** on pay date column uses the platform standard DateRangeFilter component per ADR-006.

---

### 11.5 New Run Initiation Form

Simple form — not multi-step.

| Field | Input | Notes |
|---|---|---|
| Payroll Context | Dropdown | Required; populated from active payroll contexts |
| Pay Period | Dropdown | Required; populated from open calendar periods for selected context |
| Run Type | Dropdown | REGULAR, SUPPLEMENTAL, ADJUSTMENT, CORRECTION |
| Description | Text | Optional |

On submit: calls `InitiateRunAsync`. Returns immediately with Job_ID. Run progress panel activates automatically.

---

## 12. Run State Transitions

Key transitions governed by STATE-RUN:

| Trigger | From | To | Service Method |
|---|---|---|---|
| Operator initiates | — | DRAFT | `InitiateRunAsync` |
| Job picks up | DRAFT | CALCULATING | `PayrollRunJob` |
| Calculation completes | CALCULATING | CALCULATED | `PayrollRunJob` |
| Operator approves | CALCULATED | APPROVED | `ApproveRunAsync` |
| Operator releases | APPROVED | RELEASING | `ReleaseRunAsync` |
| Release completes | RELEASING | RELEASED | `PayrollRunJob` |
| Any failure | Any | FAILED | `PayrollRunJob` |
| Operator cancels | DRAFT / CALCULATED | CANCELLED | `CancelRunAsync` |

A run in RELEASED or CLOSED state is immutable. Corrections require a new run with `ParentRunId` referencing the original.

---

## 13. Role Definitions

| Role | Capabilities |
|---|---|
| `PayrollViewer` | Read-only access to runs, register, accumulators |
| `PayrollOperator` | Initiate runs, view register, manage exceptions |
| `PayrollAdmin` | Approve and release runs, access compensation-sensitive data |
| `PayrollSupervisor` | Cancel running jobs, initiate correction runs |

---

## 14. Test Cases

| ID | Description | Expected Result |
|---|---|---|
| TC-PAY-001 | Initiate regular payroll run | PayrollRun created in DRAFT; PlatformJob created in QUEUED; RunId and JobId returned immediately |
| TC-PAY-002 | Initiate run when open run already exists for same period | DomainException thrown; no duplicate run created |
| TC-PAY-003 | PayrollRunJob picks up job and begins calculation | Run transitions to CALCULATING; progress updates published via SignalR |
| TC-PAY-004 | Employee calculation succeeds | EmployeePayrollResult created with all result lines; accumulator impacts applied; all four accumulator layers written atomically |
| TC-PAY-005 | Employee-level calculation failure | Failed employee recorded in exception queue; run continues for remaining population |
| TC-PAY-006 | Accumulator mutation is atomic | If balance update fails after impact insert, entire transaction rolls back; no partial accumulator state |
| TC-PAY-007 | Ordered computation produces correct result | Pre-tax deduction reduces taxable wage base; taxes calculated on reduced base; post-tax deduction does not affect taxable wages |
| TC-PAY-008 | Hourly employee with overtime | Regular hours at base rate; hours above threshold at 1.5x rate; separate OT result line generated |
| TC-PAY-009 | Salaried employee on approved PTO | PAID_SUBSTITUTION leave signal consumed; PTO earnings result line generated; regular salary suppressed for leave days |
| TC-PAY-010 | Pre-tax 401k deduction reduces federal taxable wages | Federal taxable wages = gross - pre-tax deduction; tax calculated on reduced base |
| TC-PAY-011 | Run with 250 employees completes | All 250 employees calculated; run transitions to CALCULATED; final progress = 100% |
| TC-PAY-012 | Progress updates visible in UI during calculation | Every 10 employees, progress_percent and processed_records updated; SignalR pushes update to operator dashboard |
| TC-PAY-013 | Approve calculated run | Run transitions to APPROVED; approval logged with approver identity and timestamp |
| TC-PAY-014 | Release approved run | Run transitions to RELEASING then RELEASED; pay statement generation initiated |
| TC-PAY-015 | Cancel run in DRAFT state | Run transitions to CANCELLED; job cancelled; no results preserved |
| TC-PAY-016 | Cancel running job | PayrollRunJob receives cancellation; run transitions to CANCELLED; partial results discarded |
| TC-PAY-017 | Pay register grid loads for 250-employee run | All 250 result rows rendered; gross/net totals correct; export available |
| TC-PAY-018 | Employee pay detail drill-down | Full result line breakdown displayed for selected employee; accumulator impacts shown |
| TC-PAY-019 | Variance report flags employees with >10% gross pay change | Employees with variance above threshold flagged; prior and current period comparison shown |
| TC-PAY-020 | HRIS HIRE event received | PayrollProfile created for new Employment_ID; employment eligible for next run |
| TC-PAY-021 | HRIS COMPENSATION_CHANGE event received (retroactive) | Recalculation work queue item created for affected prior periods |
| TC-PAY-022 | Temporal Override active during run | All effective-date queries in calculation use override date; accumulator resets evaluated against override date |
| TC-PAY-023 | Duplicate accumulator impact prevented | Rerunning calculation for same employee does not double-post accumulator contributions |
