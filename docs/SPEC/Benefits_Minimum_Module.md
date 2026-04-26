# SPEC — Benefits Minimum Module

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/Benefits_Minimum_Module.md` |
| **Related Documents** | PRD-1000_Benefits_Boundary, ADR-007_Module_Composition_DI_Lifetime, SPEC/Payroll_Core_Module, docs/architecture/core/Benefit_Deduction_Election_Model.md, docs/architecture/core/Benefit_and_Deduction_Configuration_Model.md, docs/STATE/STATE-DED_Benefits_Deductions.md, docs/EXC/EXC-DED_Benefits_Deductions_Exceptions.md, SPEC/API_Surface_Map.md INT-BEN-001 |

---

## Purpose

Defines the implementation-ready specification for the Benefits (minimum) module — the platform's v1 capability for managing benefit deduction elections and delivering them to payroll for processing.

This module does not administer benefit plans. It receives election amounts — manually or from an external system — and ensures they are correctly applied to payroll calculations as pre-tax or post-tax deductions.

The scope boundary is precise:
- **This module owns:** Deduction codes, deduction elections, election lifecycle, payroll delivery
- **This module does not own:** Plan design, open enrollment, carrier integration, dependent management, COBRA, ACA reporting

---

## 1. Module Assembly Structure

```
AllWorkHRIS.Module.Benefits/
│
├── BenefitsModule.cs                     # IPlatformModule implementation
│
├── Domain/
│   ├── Elections/
│   │   ├── BenefitDeductionElection.cs
│   │   ├── ElectionStatus.cs             # Enum — STATE-DED states
│   │   └── TaxTreatment.cs               # Enum — PRE_TAX, POST_TAX
│   └── Codes/
│       ├── DeductionCode.cs
│       └── DeductionCodeStatus.cs
│
├── Commands/
│   ├── CreateElectionCommand.cs
│   ├── UpdateElectionCommand.cs
│   ├── TerminateElectionCommand.cs
│   └── SuspendElectionCommand.cs
│
├── Repositories/
│   ├── IDeductionCodeRepository.cs
│   └── IBenefitElectionRepository.cs
│
└── Services/
    ├── IBenefitElectionService.cs
    └── IBenefitElectionImportService.cs
```

---

## 2. BenefitsModule Registration

```csharp
[Export(typeof(IPlatformModule))]
public sealed class BenefitsModule : IPlatformModule
{
    public void Register(ContainerBuilder builder)
    {
        builder.RegisterType<DeductionCodeRepository>()
               .As<IDeductionCodeRepository>()
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
    }

    public IEnumerable<MenuContribution> GetMenuContributions() =>
    [
        new MenuContribution
        {
            Label        = "Benefits",
            Icon         = "benefits-icon",
            SortOrder    = 30,
            AccentColor  = "var(--color-accent-sage)",
            BadgeLabel   = "BEN",
            RequiredRole = "HrisAdmin"
        },
        new MenuContribution
        {
            Label        = "Deduction Codes",
            Href         = "/benefits/codes",
            Icon         = "icon-code",
            SortOrder    = 1,
            ParentLabel  = "Benefits",
            RequiredRole = "HrisAdmin"
        },
        new MenuContribution
        {
            Label        = "Elections",
            Href         = "/benefits/elections",
            Icon         = "icon-elections",
            SortOrder    = 2,
            ParentLabel  = "Benefits",
            RequiredRole = "HrisAdmin"
        },
        new MenuContribution
        {
            Label        = "Import Elections",
            Href         = "/benefits/import",
            Icon         = "icon-import",
            SortOrder    = 3,
            ParentLabel  = "Benefits",
            RequiredRole = "HrisAdmin"
        }
    ];
}
```

---

## 3. Domain Commands

```csharp
// Commands/CreateElectionCommand.cs
public sealed record CreateElectionCommand
{
    public required Guid     EmploymentId               { get; init; }
    public required string   DeductionCode              { get; init; }
    public required decimal  EmployeeAmount             { get; init; }
    public decimal?          EmployerContributionAmount { get; init; }
    public required DateOnly EffectiveStartDate         { get; init; }
    public DateOnly?         EffectiveEndDate           { get; init; }
    public required string   Source                     { get; init; }  // MANUAL, IMPORT, API
    public required Guid     CreatedBy                  { get; init; }
}

// Commands/UpdateElectionCommand.cs
public sealed record UpdateElectionCommand
{
    public required Guid     ElectionId                 { get; init; }
    public required decimal  EmployeeAmount             { get; init; }
    public decimal?          EmployerContributionAmount { get; init; }
    public required DateOnly EffectiveStartDate         { get; init; }
    public DateOnly?         EffectiveEndDate           { get; init; }
    public required string   CorrectionType             { get; init; }  // AMOUNT_CHANGE, DATE_CHANGE
    public required Guid     UpdatedBy                  { get; init; }
}

// Commands/TerminateElectionCommand.cs
public sealed record TerminateElectionCommand
{
    public required Guid   ElectionId        { get; init; }
    public required Guid   TerminatedBy      { get; init; }
    public string?         TerminationReason { get; init; }
    /// <summary>
    /// Source HRIS event that triggered termination (e.g. Employment termination).
    /// Null for manual terminations.
    /// </summary>
    public Guid?           SourceEventId     { get; init; }
}
```

---

## 4. Repository Interfaces

```csharp
// Repositories/IBenefitElectionRepository.cs
public interface IBenefitElectionRepository
{
    Task<BenefitDeductionElection?>             GetByIdAsync(Guid electionId);
    Task<IEnumerable<BenefitDeductionElection>> GetByEmploymentIdAsync(Guid employmentId);
    Task<IEnumerable<BenefitDeductionElection>> GetActiveByEmploymentIdAsync(
                                                    Guid employmentId, DateOnly asOf);
    Task<BenefitDeductionElection?>             GetActiveByCodeAsync(
                                                    Guid employmentId,
                                                    string deductionCode, DateOnly asOf);
    Task<Guid>                                  InsertAsync(
                                                    BenefitDeductionElection election,
                                                    IUnitOfWork uow);
    Task                                        UpdateStatusAsync(Guid electionId,
                                                    string status, IUnitOfWork uow);
    Task<PagedResult<ElectionListItem>>         GetPagedListAsync(
                                                    ElectionListQuery query);
}

// Repositories/IDeductionCodeRepository.cs
public interface IDeductionCodeRepository
{
    Task<DeductionCode?>             GetByCodeAsync(string code);
    Task<IEnumerable<DeductionCode>> GetActiveCodesAsync();
    Task<Guid>                       InsertAsync(DeductionCode code, IUnitOfWork uow);
    Task                             UpdateAsync(DeductionCode code, IUnitOfWork uow);
}
```

---

## 5. Service Interfaces

```csharp
// Services/IBenefitElectionService.cs
public interface IBenefitElectionService
{
    /// <summary>
    /// Creates a new election. Validates deduction code, amounts, and
    /// checks for overlapping elections for the same code.
    /// Records Source = MANUAL.
    /// </summary>
    Task<Guid> CreateElectionAsync(CreateElectionCommand command);

    /// <summary>
    /// Updates an existing election by creating a new versioned record
    /// and closing the prior record. Never overwrites history.
    /// </summary>
    Task<Guid> UpdateElectionAsync(UpdateElectionCommand command);

    /// <summary>
    /// Terminates an election. Transitions to STATE-DED-005.
    /// Records SourceEventId where triggered by HRIS lifecycle event.
    /// </summary>
    Task TerminateElectionAsync(TerminateElectionCommand command);

    /// <summary>
    /// Suspends an election (e.g. employee on unpaid leave).
    /// Transitions to STATE-DED-004.
    /// Triggered by HRIS LEAVE_OF_ABSENCE event.
    /// </summary>
    Task SuspendElectionAsync(Guid electionId, Guid sourceEventId);

    /// <summary>
    /// Reinstates a suspended election.
    /// Triggered by HRIS RETURN_TO_WORK event.
    /// </summary>
    Task ReinstateElectionAsync(Guid electionId, Guid sourceEventId);

    Task<IEnumerable<BenefitDeductionElection>> GetElectionsAsync(
        Guid employmentId, DateOnly asOf);
}

// Services/IBenefitElectionImportService.cs
public interface IBenefitElectionImportService
{
    /// <summary>
    /// Validates a batch import file without posting (dry-run).
    /// Returns a ValidationResult with per-record pass/fail.
    /// </summary>
    Task<BatchValidationResult> ValidateBatchAsync(Stream fileContent,
        string fileFormat, CancellationToken ct = default);

    /// <summary>
    /// Submits a batch import as an async job.
    /// Returns Job_ID immediately; processing occurs in background.
    /// </summary>
    Task<Guid> SubmitBatchAsync(Stream fileContent,
        string fileFormat, Guid submittedBy, CancellationToken ct = default);
}
```

---

## 6. Create Election Implementation Pattern

```csharp
public async Task<Guid> CreateElectionAsync(CreateElectionCommand command)
{
    // 1. Validate deduction code exists and is active
    var code = await _codeRepository.GetByCodeAsync(command.DeductionCode)
        ?? throw new DomainException(
            $"Deduction code '{command.DeductionCode}' not found or inactive.");

    // 2. Validate amounts
    if (command.EmployeeAmount < 0)
        throw new ValidationException("Employee amount must be ≥ 0.");

    if (command.EmployerContributionAmount.HasValue
     && command.EmployerContributionAmount.Value < 0)
        throw new ValidationException("Employer contribution amount must be ≥ 0.");

    // 3. Validate effective dates
    if (command.EffectiveEndDate.HasValue
     && command.EffectiveEndDate.Value < command.EffectiveStartDate)
        throw new ValidationException(
            "Effective end date must be on or after effective start date.");

    // 4. Check for overlapping active election for same code
    var existing = await _electionRepository.GetActiveByCodeAsync(
        command.EmploymentId, command.DeductionCode,
        command.EffectiveStartDate);

    if (existing is not null)
    {
        // Warn but do not block — EXC-DED-002
        await _workQueueService.CreateDuplicateElectionWarningAsync(
            command.EmploymentId, command.DeductionCode, existing.ElectionId);
    }

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        var election = BenefitDeductionElection.Create(command, code.TaxTreatment);
        var electionId = await _electionRepository.InsertAsync(election, uow);
        uow.Commit();

        return electionId;
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

---

## 7. Update Election (Versioning Pattern)

Elections are never overwritten. An update creates a new versioned record and closes the prior:

```csharp
public async Task<Guid> UpdateElectionAsync(UpdateElectionCommand command)
{
    var prior = await _electionRepository.GetByIdAsync(command.ElectionId)
        ?? throw new NotFoundException(nameof(BenefitDeductionElection),
            command.ElectionId);

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        // Close prior record
        await _electionRepository.UpdateStatusAsync(
            prior.ElectionId, ElectionStatus.Superseded.ToString(), uow);

        // Create new versioned record linked to prior
        var updated = BenefitDeductionElection.CreateRevision(
            prior, command);
        var newElectionId = await _electionRepository.InsertAsync(updated, uow);

        uow.Commit();
        return newElectionId;
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

---

## 8. HRIS Event Integration

The Benefits module subscribes to HRIS lifecycle events that affect election state:

| HRIS Event | Benefits Module Action |
|---|---|
| `TERMINATION` | Terminate all active elections for the Employment_ID |
| `LEAVE_OF_ABSENCE` | Suspend all active elections (transition to STATE-DED-004) |
| `RETURN_TO_WORK` | Reinstate all suspended elections (transition to STATE-DED-003) |

These are handled by the same `IPayrollEventSubscriber` pattern used by Payroll — the Benefits module registers its own handlers at startup.

---

## 9. Batch Import (INT-BEN-001)

The batch import supports both CSV and XLSX formats. Each record represents one election for one employee.

**Required columns:**

| Column | Format | Notes |
|---|---|---|
| `employment_id` | UUID | Must reference active employment |
| `deduction_code` | String | Must reference active deduction code |
| `employee_amount` | Decimal | ≥ 0 |
| `employer_contribution_amount` | Decimal | Optional; ≥ 0 if provided |
| `effective_start_date` | YYYY-MM-DD | Required |
| `effective_end_date` | YYYY-MM-DD | Optional |

**Import flow:**

1. HR admin uploads file via the Import Elections page or API (INT-BEN-001)
2. File is validated record-by-record against the rules in `Benefit_Deduction_Election_Model` §5
3. Valid records are staged; invalid records route to exception queue
4. Dry-run mode returns validation results without posting
5. On confirmation, valid records are committed as elections with `Source = IMPORT`
6. Import job completes; summary shows accepted/rejected counts

**Batch import as async job:**

```csharp
// Minimal API endpoint — INT-BEN-001
app.MapPost("/api/benefits/elections/import", async (
    IFormFile file,
    IBenefitElectionImportService importService,
    ClaimsPrincipal user,
    CancellationToken ct) =>
{
    var jobId = await importService.SubmitBatchAsync(
        file.OpenReadStream(), file.ContentType,
        user.GetEmploymentId(), ct);

    return Results.Accepted($"/api/jobs/{jobId}", new { JobId = jobId });
})
.RequireAuthorization("benefits:elections:write");
```

---

## 10. Blazor Component Specifications

### 10.1 Deduction Codes Page (`/benefits/codes`)

Syncfusion Grid — all configured deduction codes.

**Columns:** Code, Description, Tax Treatment (PRE_TAX / POST_TAX badge), Status, Effective Start, Effective End, Actions (Edit).

**+ Add Code button:** Opens form — Code, Description, Tax Treatment (dropdown), Effective Start Date. Validates code uniqueness.

---

### 10.2 Elections Page (`/benefits/elections`)

Syncfusion Grid — all elections across all employees. Filterable by Employment, Deduction Code, Status, Effective Date range.

**Columns:** Employee Name, Employment ID, Deduction Code, Tax Treatment, Employee Amount, Employer Contribution, Effective Start, Effective End, Status badge, Source badge (MANUAL / IMPORT / API), Actions (Edit, Terminate).

**+ Add Election button:** Opens `CreateElectionCommand` form. Fields: Employee search, Deduction Code dropdown, Employee Amount, Employer Contribution (optional), Effective Start, Effective End (optional).

**Custom date-range filter** on Effective Start column uses platform standard `DateRangeFilter` component per ADR-006.

---

### 10.3 Employee Benefits Tab (Employee Detail page — Benefits tab)

Within the Employee Detail page, a Benefits tab shows elections for that specific employee.

**Active elections:** Card or simple grid per active election — deduction code, description, tax treatment, employee amount, employer contribution, effective dates, status.

**Election history:** Expandable section showing all prior versions of each election — amounts, dates, correction type, who made the change.

**+ Add Election / Terminate buttons:** Scoped to the current employee. Requires `HrisAdmin` role.

---

### 10.4 Import Elections Page (`/benefits/import`)

Two-step flow.

**Step 1 — Upload and Validate:**
- SfUploader component for CSV/XLSX file
- "Validate" button triggers `ValidateBatchAsync` (dry run)
- Validation results displayed: X records valid, Y records failed
- Failed records shown in a grid with error details

**Step 2 — Confirm and Import:**
- "Import N Valid Records" button — only enabled if at least one valid record
- Triggers `SubmitBatchAsync` — returns Job_ID
- Progress panel shows import job progress in real time via SignalR

---

## 11. Payroll Boundary

The Benefits module delivers elections to Payroll through the `IBenefitElectionRepository.GetActiveByEmploymentIdAsync` call made during payroll scope resolution. Payroll reads active elections at calculation time — Benefits does not push data to Payroll.

The boundary is clean:
- Benefits writes elections to the `benefit_deduction_election` table
- Payroll reads from that table during calculation
- No direct service call crosses the module boundary
- Benefits does not know when payroll runs
- Payroll does not know about election management workflows

---

## 12. Role Definitions

| Role | Capabilities |
|---|---|
| `HrisAdmin` | Full access — create, update, terminate elections; manage deduction codes; import elections |
| `PayrollOperator` | Read-only access to elections (for payroll register reconciliation) |
| `Employee` | View own active elections via ESS — no write access |

---

## 13. Test Cases

| ID | Description | Expected Result |
|---|---|---|
| TC-BEN-001 | Create election with valid deduction code and amounts | Election created in STATE-DED-001 (Pending); transitions to STATE-DED-003 on effective start date |
| TC-BEN-002 | Create election with invalid deduction code | DomainException thrown; no election created |
| TC-BEN-003 | Create election with negative employee amount | ValidationException thrown |
| TC-BEN-004 | Create election with end date before start date | ValidationException thrown |
| TC-BEN-005 | Create election overlapping existing active election for same code | EXC-DED-002 warning raised; election still created; operator notified |
| TC-BEN-006 | Update election amount | New versioned election created; prior election transitions to SUPERSEDED; lineage preserved via Parent_Election_ID |
| TC-BEN-007 | Terminate election | Election transitions to STATE-DED-005; no further deductions generated |
| TC-BEN-008 | HRIS TERMINATION event received | All active elections for employment transition to STATE-DED-005 |
| TC-BEN-009 | HRIS LEAVE_OF_ABSENCE event received | All active elections suspend to STATE-DED-004; no deductions during leave |
| TC-BEN-010 | HRIS RETURN_TO_WORK event received | Suspended elections reinstate to STATE-DED-003 |
| TC-BEN-011 | Batch import dry-run with mixed valid/invalid records | Returns validation result; no records posted; invalid records show error detail |
| TC-BEN-012 | Batch import commit posts valid records only | Valid records created as elections; invalid records in exception queue; job completes with summary |
| TC-BEN-013 | Pre-tax election consumed by payroll | Election deducted before tax calculation; federal taxable wages reduced by election amount |
| TC-BEN-014 | Post-tax election consumed by payroll | Election deducted after tax calculation; does not affect taxable wages |
| TC-BEN-015 | Employer contribution election consumed by payroll | Separate employer contribution result line generated; employee net pay unaffected |
| TC-BEN-016 | Suspended election not consumed by payroll | No deduction result line generated for employee on unpaid leave |
| TC-BEN-017 | Election with past effective end date not consumed | Election excluded from payroll scope resolution; no deduction generated |
| TC-BEN-018 | Election page date-range filter on effective start | Grid filters to elections whose start date falls within From/To range |
| TC-BEN-019 | Employee Benefits tab shows active elections only by default | Active elections displayed; history section collapsed; prior versions accessible on expand |
| TC-BEN-020 | Import progress visible in real time | SignalR pushes processed_records and progress_percent updates during batch import job |
