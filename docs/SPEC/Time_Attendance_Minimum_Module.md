# SPEC — Time & Attendance Minimum Module

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/Time_Attendance_Minimum_Module.md` |
| **Related Documents** | PRD-1100_Time_and_Attendance, ADR-007_Module_Composition_DI_Lifetime, SPEC/Payroll_Core_Module, SPEC/HRIS_Core_Module, docs/STATE/STATE-TIM_Time_Entry.md, docs/EXC/EXC-TIM_Time_Attendance_Exceptions.md, docs/architecture/core/Time_Entry_and_Worked_Time_Model.md, docs/architecture/core/Overtime_and_Premium_Pay_Model.md |

---

## Purpose

Defines the implementation-ready specification for the Time & Attendance (minimum) module — time entry capture, manager approval, overtime detection, FLSA compliance, and payroll handoff.

This module is the authoritative source of approved worked time consumed by Payroll. Payroll shall not accept unapproved time entries and shall not independently source worked time.

The scope is deliberately minimal — manual entry, batch import, approval workflow, overtime detection, and payroll handoff. Advanced scheduling, biometric capture, and union rules are out of scope for v1.

---

## 1. Module Assembly Structure

```
BlazorHR.Module.TimeAttendance/
│
├── TimeAttendanceModule.cs               # IPlatformModule implementation
│
├── Domain/
│   ├── TimeEntry/
│   │   ├── TimeEntry.cs
│   │   ├── TimeEntryStatus.cs            # Enum — STATE-TIM-001 through 007
│   │   ├── TimeCategory.cs               # Enum — REGULAR, OVERTIME, etc.
│   │   └── EntryMethod.cs                # Enum — MANUAL, IMPORT, API, SELF_SERVICE
│   └── Schedule/
│       ├── WorkSchedule.cs
│       └── ShiftDefinition.cs
│
├── Commands/
│   ├── SubmitTimeEntryCommand.cs
│   ├── ApproveTimeEntryCommand.cs
│   ├── RejectTimeEntryCommand.cs
│   ├── CorrectTimeEntryCommand.cs
│   └── VoidTimeEntryCommand.cs
│
├── Repositories/
│   ├── ITimeEntryRepository.cs
│   └── IWorkScheduleRepository.cs
│
├── Services/
│   ├── ITimeEntryService.cs
│   ├── IOvertimeDetectionService.cs
│   └── IPayrollHandoffService.cs
│
└── Jobs/
    └── PayrollHandoffJob.cs              # Delivers approved time to Payroll
```

---

## 2. TimeAttendanceModule Registration

```csharp
[Export(typeof(IPlatformModule))]
public sealed class TimeAttendanceModule : IPlatformModule
{
    public void Register(ContainerBuilder builder)
    {
        builder.RegisterType<TimeEntryRepository>()
               .As<ITimeEntryRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<WorkScheduleRepository>()
               .As<IWorkScheduleRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<TimeEntryService>()
               .As<ITimeEntryService>()
               .InstancePerLifetimeScope();

        builder.RegisterType<OvertimeDetectionService>()
               .As<IOvertimeDetectionService>()
               .InstancePerLifetimeScope();

        builder.RegisterType<PayrollHandoffService>()
               .As<IPayrollHandoffService>()
               .InstancePerLifetimeScope();
    }

    public IEnumerable<MenuContribution> GetMenuContributions() =>
    [
        new MenuContribution
        {
            Label        = "Time & Attendance",
            Icon         = "ta-icon",
            SortOrder    = 25,
            AccentColor  = "var(--color-accent-lavender)",
            BadgeLabel   = "T&A",
            RequiredRole = "TimeViewer"
        },
        new MenuContribution
        {
            Label        = "Timecards",
            Href         = "/ta/timecards",
            Icon         = "icon-timecard",
            SortOrder    = 1,
            ParentLabel  = "Time & Attendance",
            RequiredRole = "TimeViewer"
        },
        new MenuContribution
        {
            Label        = "My Timecard",
            Href         = "/ta/my-timecard",
            Icon         = "icon-clock",
            SortOrder    = 2,
            ParentLabel  = "Time & Attendance",
            RequiredRole = "Employee"
        },
        new MenuContribution
        {
            Label        = "Payroll Handoff",
            Href         = "/ta/handoff",
            Icon         = "icon-handoff",
            SortOrder    = 3,
            ParentLabel  = "Time & Attendance",
            RequiredRole = "TimeAdmin"
        }
    ];
}
```

---

## 3. Domain Commands

```csharp
// Commands/SubmitTimeEntryCommand.cs
public sealed record SubmitTimeEntryCommand
{
    public required Guid        EmploymentId    { get; init; }
    public required DateOnly    WorkDate        { get; init; }
    public required string      TimeCategory    { get; init; }
    public required decimal     Duration        { get; init; }  // Hours
    public TimeOnly?            StartTime       { get; init; }  // Optional — punch-based
    public TimeOnly?            EndTime         { get; init; }  // Optional — punch-based
    public Guid?                ShiftId         { get; init; }
    public required Guid        PayrollPeriodId { get; init; }
    public required string      EntryMethod     { get; init; }
    public required Guid        SubmittedBy     { get; init; }
    public string?              Notes           { get; init; }
}

// Commands/CorrectTimeEntryCommand.cs
public sealed record CorrectTimeEntryCommand
{
    public required Guid        OriginalTimeEntryId { get; init; }
    public required DateOnly    WorkDate            { get; init; }
    public required string      TimeCategory        { get; init; }
    public required decimal     Duration            { get; init; }
    public TimeOnly?            StartTime           { get; init; }
    public TimeOnly?            EndTime             { get; init; }
    public required string      CorrectionReason    { get; init; }
    public required Guid        CorrectedBy         { get; init; }
    public bool                 RetroactiveFlag     { get; init; }
}
```

---

## 4. Repository Interface

```csharp
// Repositories/ITimeEntryRepository.cs
public interface ITimeEntryRepository
{
    Task<TimeEntry?>              GetByIdAsync(Guid timeEntryId);
    Task<IEnumerable<TimeEntry>>  GetByEmploymentAndPeriodAsync(
                                      Guid employmentId, Guid payrollPeriodId);
    Task<IEnumerable<TimeEntry>>  GetPendingApprovalByManagerAsync(
                                      Guid managerEmploymentId, Guid payrollPeriodId);
    Task<IEnumerable<TimeEntry>>  GetApprovedForHandoffAsync(
                                      Guid payrollPeriodId);
    Task<IEnumerable<TimeEntry>>  GetWorkweekEntriesAsync(
                                      Guid employmentId, DateOnly weekStart);
    Task<Guid>                    InsertAsync(TimeEntry entry, IUnitOfWork uow);
    Task                          UpdateStatusAsync(Guid timeEntryId, string status,
                                      Guid actorId, IUnitOfWork uow);
    Task                          LockAsync(Guid timeEntryId,
                                      Guid payrollRunId, IUnitOfWork uow);
}
```

---

## 5. Service Interfaces

```csharp
// Services/ITimeEntryService.cs
public interface ITimeEntryService
{
    /// <summary>
    /// Submits a time entry. Validates Employment_ID, period,
    /// and that the employee is not submitting for another person.
    /// Creates entry in SUBMITTED state.
    /// Notifies manager via work queue.
    /// </summary>
    Task<Guid> SubmitTimeEntryAsync(SubmitTimeEntryCommand command);

    Task ApproveTimeEntryAsync(ApproveTimeEntryCommand command);
    Task RejectTimeEntryAsync(RejectTimeEntryCommand command);
    Task VoidTimeEntryAsync(Guid timeEntryId, Guid voidedBy, string reason);

    /// <summary>
    /// Creates a correction for a Locked entry.
    /// New entry linked via Original_Time_Entry_ID.
    /// Retroactive flag triggers payroll recalculation work queue item.
    /// </summary>
    Task<Guid> CorrectTimeEntryAsync(CorrectTimeEntryCommand command);

    Task<IEnumerable<TimeEntry>> GetPeriodEntriesAsync(
        Guid employmentId, Guid payrollPeriodId);
}

// Services/IOvertimeDetectionService.cs
public interface IOvertimeDetectionService
{
    /// <summary>
    /// Evaluates all approved time entries for a workweek and reclassifies
    /// hours above the FLSA or jurisdiction threshold from REGULAR to OVERTIME.
    /// Returns the reclassified entries. Does not write to database directly —
    /// caller commits the changes.
    /// </summary>
    Task<OvertimeDetectionResult> DetectAndReclassifyAsync(
        Guid employmentId, DateOnly workweekStart, IUnitOfWork uow);
}

// Services/IPayrollHandoffService.cs
public interface IPayrollHandoffService
{
    /// <summary>
    /// Delivers all PENDING approved time entries for a payroll period
    /// to the Payroll module. Transitions delivered entries to CONSUMED.
    /// Returns handoff summary with entry count and total hours.
    /// </summary>
    Task<HandoffResult> ExecuteHandoffAsync(Guid payrollPeriodId,
        Guid payrollRunId, CancellationToken ct = default);
}
```

---

## 6. Time Entry Lifecycle Implementation

### 6.1 Submit Time Entry

```csharp
public async Task<Guid> SubmitTimeEntryAsync(SubmitTimeEntryCommand command)
{
    // 1. Validate Employment_ID exists
    if (!await _employmentRepository.ExistsAsync(command.EmploymentId))
        throw new DomainException($"Employment {command.EmploymentId} not found.")
            { ExceptionCode = "EXC-TIM-001" };

    // 2. Employee cannot submit for another person
    if (command.EntryMethod == EntryMethod.SelfService.ToString()
     && command.SubmittedBy != command.EmploymentId)
        throw new AuthorizationException(
            "Employees may only submit time for their own employment.");

    // 3. Validate payroll period is open
    var period = await _periodRepository.GetByIdAsync(command.PayrollPeriodId)
        ?? throw new DomainException("Payroll period not found.");

    if (period.Status == PeriodStatus.Closed)
        throw new DomainException("Cannot submit time for a closed payroll period.")
            { ExceptionCode = "EXC-TIM-004" };

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        var entry = TimeEntry.Create(command);
        var entryId = await _timeEntryRepository.InsertAsync(entry, uow);
        uow.Commit();

        // Notify manager after commit
        await _workQueueService.CreateTimeApprovalTaskAsync(
            entryId, command.EmploymentId);

        return entryId;
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

### 6.2 Approve Time Entry

```csharp
public async Task ApproveTimeEntryAsync(ApproveTimeEntryCommand command)
{
    var entry = await _timeEntryRepository.GetByIdAsync(command.TimeEntryId)
        ?? throw new NotFoundException(nameof(TimeEntry), command.TimeEntryId);

    if (entry.Status != TimeEntryStatus.Submitted
     && entry.Status != TimeEntryStatus.Corrected)
        throw new InvalidStateTransitionException(
            entry.Status.ToString(), TimeEntryStatus.Approved.ToString());

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        await _timeEntryRepository.UpdateStatusAsync(
            command.TimeEntryId, TimeEntryStatus.Approved.ToString(),
            command.ApprovedBy, uow);

        uow.Commit();

        // Run overtime detection for the workweek after approval
        var weekStart = GetWorkweekStart(entry.WorkDate);
        await _overtimeService.DetectAndReclassifyAsync(
            entry.EmploymentId, weekStart, uow);
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

### 6.3 Correct Locked Time Entry

```csharp
public async Task<Guid> CorrectTimeEntryAsync(CorrectTimeEntryCommand command)
{
    var original = await _timeEntryRepository.GetByIdAsync(
        command.OriginalTimeEntryId)
        ?? throw new NotFoundException(nameof(TimeEntry),
            command.OriginalTimeEntryId);

    if (original.Status != TimeEntryStatus.Locked)
        throw new DomainException(
            "Only Locked entries can be corrected through the correction workflow.");

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        // Create new versioned entry linked to original
        var correction = TimeEntry.CreateCorrection(original, command);
        var correctionId = await _timeEntryRepository.InsertAsync(correction, uow);
        uow.Commit();

        // If retroactive, trigger payroll recalculation review
        if (command.RetroactiveFlag)
            await _workQueueService.CreateRetroCalculationReviewAsync(
                correctionId, original.EmploymentId,
                original.PayrollPeriodId);

        return correctionId;
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

---

## 7. Overtime Detection

FLSA weekly overtime threshold: 40 hours per workweek for non-exempt employees.

```csharp
public async Task<OvertimeDetectionResult> DetectAndReclassifyAsync(
    Guid employmentId, DateOnly workweekStart, IUnitOfWork uow)
{
    // Get FLSA classification from HRIS
    var employment = await _employmentRepository.GetByIdAsync(employmentId);

    // Exempt employees — no overtime evaluation
    if (employment.FlsaStatus == FlsaStatus.Exempt)
        return OvertimeDetectionResult.NotApplicable(employmentId);

    var weekEnd = workweekStart.AddDays(6);
    var weekEntries = await _timeEntryRepository.GetWorkweekEntriesAsync(
        employmentId, workweekStart);

    // Only evaluate APPROVED entries
    var approved = weekEntries
        .Where(e => e.Status == TimeEntryStatus.Approved
                 && e.TimeCategory == TimeCategory.Regular)
        .OrderBy(e => e.WorkDate)
        .ToList();

    var totalRegularHours = approved.Sum(e => e.Duration);

    if (totalRegularHours <= 40)
        return OvertimeDetectionResult.NoOvertime(employmentId, totalRegularHours);

    // Reclassify hours above threshold
    var overtimeHours = totalRegularHours - 40;
    var reclassified = new List<Guid>();

    // Reclassify from most recent entries first
    decimal remaining = overtimeHours;
    foreach (var entry in approved.OrderByDescending(e => e.WorkDate))
    {
        if (remaining <= 0) break;

        var hoursToReclassify = Math.Min(entry.Duration, remaining);

        if (hoursToReclassify == entry.Duration)
        {
            // Reclassify entire entry
            await _timeEntryRepository.ReclassifyAsync(
                entry.TimeEntryId, TimeCategory.Overtime.ToString(), uow);
        }
        else
        {
            // Split entry — reclassify partial hours
            await SplitAndReclassifyAsync(entry, hoursToReclassify, uow);
        }

        reclassified.Add(entry.TimeEntryId);
        remaining -= hoursToReclassify;
    }

    // Generate EXC-TIM-003 warning
    await _workQueueService.CreateOvertimeWarningAsync(
        employmentId, workweekStart, overtimeHours);

    return OvertimeDetectionResult.OvertimeDetected(
        employmentId, totalRegularHours, overtimeHours, reclassified);
}
```

---

## 8. Payroll Handoff

The payroll handoff delivers all approved, PENDING time entries to the Payroll module before calculation begins.

```csharp
public async Task<HandoffResult> ExecuteHandoffAsync(Guid payrollPeriodId,
    Guid payrollRunId, CancellationToken ct = default)
{
    var entries = await _timeEntryRepository
        .GetApprovedForHandoffAsync(payrollPeriodId);

    int delivered = 0;
    int failed = 0;

    foreach (var entry in entries)
    {
        ct.ThrowIfCancellationRequested();

        using var uow = new UnitOfWork(_connectionFactory);
        try
        {
            // Lock the entry and record the consuming run
            await _timeEntryRepository.LockAsync(
                entry.TimeEntryId, payrollRunId, uow);

            uow.Commit();
            delivered++;
        }
        catch (Exception ex)
        {
            uow.Rollback();
            failed++;
            await _exceptionService.RecordHandoffFailureAsync(
                entry.TimeEntryId, payrollRunId, ex);
        }
    }

    return new HandoffResult(
        PeriodId:      payrollPeriodId,
        PayrollRunId:  payrollRunId,
        Delivered:     delivered,
        Failed:        failed,
        TotalHours:    entries.Where(e => e.PayrollConsumptionStatus == "CONSUMED")
                              .Sum(e => e.Duration)
    );
}
```

The Payroll module calls `IPayrollHandoffService.ExecuteHandoffAsync` as part of run initiation, before calculation begins. Only entries transitioned to Locked status are included in earnings computation.

---

## 9. Batch Import (INT-TIM-001)

Batch time entry import supports CSV and XLSX. Each record represents one time entry for one employee on one date.

**Required columns:**

| Column | Format | Notes |
|---|---|---|
| `employment_id` | UUID | Must reference active employment |
| `work_date` | YYYY-MM-DD | Required |
| `time_category` | String | Must match valid TimeCategory enum value |
| `duration` | Decimal | Hours; required if no start/end time |
| `start_time` | HH:MM | Optional — punch-based |
| `end_time` | HH:MM | Optional — punch-based |
| `payroll_period_id` | UUID | Required |

All imported entries arrive as SUBMITTED and follow the standard approval workflow.

---

## 10. HRIS Event Integration

| HRIS Event | T&A Action |
|---|---|
| `TERMINATION` | Close any DRAFT or SUBMITTED time entries for the Employment_ID; generate EXC-TIM-002 for any unapproved entries in the current period |
| `LEAVE_OF_ABSENCE` | Suppress time entry requirement for the leave duration; flag if entries submitted during leave period |
| `RETURN_TO_WORK` | Resume normal time entry requirement from return date |

---

## 11. Blazor Component Specifications

### 11.1 Timecards Page (`/ta/timecards`)

Manager and HR Admin view — all timecards across direct reports or full scope.

**Summary stat cards:**
| Card | Value |
|---|---|
| Approved | Count of approved entries for current period |
| Pending Approval | Count awaiting approval |
| Unapproved at Cutoff Risk | Count approaching deadline |
| Overtime Alerts | Count with EXC-TIM-003 |

**Syncfusion Grid — columns:**

| Column | Notes |
|---|---|
| Employee | Name + avatar |
| Period | Payroll period |
| Total Hours | Sum of approved hours |
| Regular | Sum of REGULAR category |
| Overtime | Sum of OVERTIME category — amber if > 0 |
| Status | Overall timecard status badge |
| Exceptions | Count — links to exception detail |
| Actions | Approve All / View |

**Filters:** Department, Period, Status. Custom date-range filter on Work Date per ADR-006.

---

### 11.2 My Timecard (`/ta/my-timecard`)

Employee self-service time entry page.

**Weekly view:** Grid showing Mon–Sun for the current payroll period. Each row is one time entry.

| Column | Notes |
|---|---|
| Date | Work date |
| Category | Time category dropdown |
| Start Time | Optional — time picker |
| End Time | Optional — time picker |
| Duration | Hours — auto-calculated if start/end provided |
| Status | Entry status badge |
| Notes | Optional text |

**+ Add Entry button:** Adds a new row for the selected date.

**Submit button:** Submits all DRAFT entries for the period. Calls `SubmitTimeEntryAsync` for each.

**Overtime indicator:** Running total displayed at bottom — "Week total: 43.5 hrs — 3.5 hrs overtime". Turns amber when threshold exceeded.

---

### 11.3 Timecard Detail / Approval Panel

Opened from the Timecards grid or manager work queue. Shows all entries for one employee for one period.

**Entry list:** Each entry with date, category, duration, status badge, and Approve/Reject actions.

**Approve All button:** Approves all SUBMITTED entries in one action.

**Overtime summary:** If overtime detected, shows the reclassification breakdown — "40 hrs REGULAR / 3.5 hrs OVERTIME".

---

### 11.4 Payroll Handoff Page (`/ta/handoff`)

HR Admin / Payroll Operator view. Shows handoff status for each payroll period.

**Grid columns:** Period, Pay Date, Approved Entries, Total Hours, Handoff Status, Handoff Date.

**Manual Trigger button:** Initiates handoff for selected period as async job — shows progress via SignalR.

---

## 12. Role Definitions

| Role | Capabilities |
|---|---|
| `Employee` | Submit and view own time entries |
| `TimeViewer` | Read-only access to all timecards in scope |
| `Manager` | Approve/reject direct report timecards |
| `TimeAdmin` | Full access — approve any timecard; correct locked entries; trigger handoff |
| `PayrollOperator` | View handoff status; read-only timecard access |

---

## 13. Test Cases

| ID | Description | Expected Result |
|---|---|---|
| TC-TA-001 | Employee submits time entry for own employment | Entry created in SUBMITTED state; manager work queue item created |
| TC-TA-002 | Employee submits time entry for another employment | AuthorizationException thrown; no entry created |
| TC-TA-003 | Submit time entry without valid Employment_ID | DomainException with EXC-TIM-001; no entry created |
| TC-TA-004 | Submit time entry for closed payroll period | DomainException with EXC-TIM-004; no entry created |
| TC-TA-005 | Manager approves time entry | Entry transitions to APPROVED; overtime detection runs for workweek |
| TC-TA-006 | Manager rejects time entry | Entry transitions to REJECTED; employee notified |
| TC-TA-007 | Non-exempt employee accumulates 45 hours in workweek | 5 hours reclassified from REGULAR to OVERTIME; EXC-TIM-003 warning generated |
| TC-TA-008 | FLSA-exempt employee accumulates 50 hours | No overtime reclassification; all 50 hours remain REGULAR |
| TC-TA-009 | Payroll handoff delivers all PENDING approved entries | Entries transition to LOCKED with PayrollRunId; HandoffResult shows correct counts |
| TC-TA-010 | Payroll handoff excludes previously consumed entries | Entries with CONSUMED status not redelivered |
| TC-TA-011 | Correct a Locked time entry | New entry created with Original_Time_Entry_ID; original remains LOCKED |
| TC-TA-012 | Correct a Locked entry with RetroactiveFlag = true | Payroll recalculation review work queue item created |
| TC-TA-013 | Duration-only entry (no start/end time) | Accepted and processed identically to punch-based entry of same duration |
| TC-TA-014 | Batch import with valid entries | All valid entries created in SUBMITTED state; invalid entries in exception queue |
| TC-TA-015 | HRIS TERMINATION event received | Open DRAFT and SUBMITTED entries for employment closed; EXC-TIM-002 for any unapproved entries |
| TC-TA-016 | My Timecard shows running overtime indicator | When week total exceeds 40 hours, indicator displays amber with overtime hours |
| TC-TA-017 | Timecards page shows unapproved entries count | Pending Approval count accurate for current period |
| TC-TA-018 | Overtime reclassification from most recent entries first | Most recent entries reclassified before earlier entries |
| TC-TA-019 | Unapproved entries at payroll cutoff | EXC-TIM-002 generated; entries excluded from payroll run |
| TC-TA-020 | Temporal Override active during overtime detection | Workweek boundaries evaluated relative to override date |
