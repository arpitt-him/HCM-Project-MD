# SPEC — HRIS Leave and Absence

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/SPEC/HRIS_Leave_and_Absence.md` |
| **Related Documents** | HRIS_Module_PRD §11, SPEC/HRIS_Core_Module, docs/DATA/Entity_Leave_Request.md, docs/STATE/STATE-LEV_Leave_Request.md, docs/architecture/core/Leave_and_Absence_Management_Model.md, docs/architecture/core/Accrual_and_Entitlement_Model.md, docs/architecture/core/Employee_Event_and_Status_Change_Model.md |

---

## Purpose

Defines the implementation-ready specification for leave and absence management within the HRIS module — leave request submission, manager approval, balance tracking, payroll impact signal publication, return to work handling, and the Blazor component specifications for leave-related UI.

HRIS owns leave requests and leave balances. Payroll consumes leave state signals but does not own or calculate leave. The boundary is absolute: HRIS publishes leave impact signals; Payroll applies them to earnings computation.

---

## 1. Module Assembly Additions

The following additions are made to the `BlazorHR.Module.Hris` assembly structure from `SPEC/HRIS_Core_Module`:

```
BlazorHR.Module.Hris/
│
├── Domain/
│   └── Leave/
│       ├── LeaveRequest.cs
│       ├── LeaveType.cs               # Enum — PTO, VACATION, SICK, etc.
│       ├── LeaveStatus.cs             # Enum — STATE-LEV-001 through 007
│       ├── PayrollImpactType.cs       # Enum — PAID_SUBSTITUTION, etc.
│       └── LeaveBalance.cs
│
├── Commands/
│   ├── SubmitLeaveRequestCommand.cs
│   ├── ApproveLeaveRequestCommand.cs
│   ├── DenyLeaveRequestCommand.cs
│   ├── CancelLeaveRequestCommand.cs
│   └── ReturnFromLeaveCommand.cs
│
├── Repositories/
│   ├── ILeaveRequestRepository.cs
│   └── ILeaveBalanceRepository.cs
│
└── Services/
    └── ILeaveService.cs
```

---

## 2. Domain Commands

```csharp
// Commands/SubmitLeaveRequestCommand.cs
public sealed record SubmitLeaveRequestCommand
{
    public required Guid     EmploymentId      { get; init; }
    public required string   LeaveType         { get; init; }
    public required DateOnly LeaveStartDate    { get; init; }
    public required DateOnly LeaveEndDate      { get; init; }
    public required string   LeaveReasonCode   { get; init; }
    public required Guid     SubmittedBy       { get; init; }
    public string?           Notes             { get; init; }
}

// Commands/ApproveLeaveRequestCommand.cs
public sealed record ApproveLeaveRequestCommand
{
    public required Guid   LeaveRequestId  { get; init; }
    public required Guid   ApprovedBy      { get; init; }
    public string?         Notes           { get; init; }
}

// Commands/ReturnFromLeaveCommand.cs
public sealed record ReturnFromLeaveCommand
{
    public required Guid     EmploymentId      { get; init; }
    public required DateOnly ReturnDate        { get; init; }
    public required Guid     InitiatedBy       { get; init; }
}
```

---

## 3. Repository Interfaces

```csharp
// Repositories/ILeaveRequestRepository.cs
public interface ILeaveRequestRepository
{
    Task<LeaveRequest?>              GetByIdAsync(Guid leaveRequestId);
    Task<IEnumerable<LeaveRequest>>  GetByEmploymentIdAsync(Guid employmentId);
    Task<IEnumerable<LeaveRequest>>  GetPendingApprovalByManagerAsync(Guid managerEmploymentId);
    Task<IEnumerable<LeaveRequest>>  GetActiveByDateRangeAsync(DateOnly from, DateOnly to,
                                         Guid? legalEntityId = null);
    Task<Guid>                       InsertAsync(LeaveRequest request, IUnitOfWork uow);
    Task                             UpdateStatusAsync(Guid leaveRequestId, string status,
                                         Guid actorId, IUnitOfWork uow);
    Task                             SetReturnDateAsync(Guid leaveRequestId,
                                         DateOnly returnDate, IUnitOfWork uow);
}

// Repositories/ILeaveBalanceRepository.cs
public interface ILeaveBalanceRepository
{
    Task<LeaveBalance?>             GetByEmploymentAndTypeAsync(Guid employmentId,
                                        string leaveType, DateOnly asOf);
    Task<IEnumerable<LeaveBalance>> GetAllByEmploymentIdAsync(Guid employmentId,
                                        DateOnly asOf);
    Task                            DeductBalanceAsync(Guid employmentId, string leaveType,
                                        decimal days, Guid leaveRequestId, IUnitOfWork uow);
    Task                            RestoreBalanceAsync(Guid employmentId, string leaveType,
                                        decimal days, Guid leaveRequestId, IUnitOfWork uow);
}
```

---

## 4. Service Interface

```csharp
// Services/ILeaveService.cs
public interface ILeaveService
{
    /// <summary>
    /// Submits a leave request. Validates balance availability for paid leave types.
    /// Creates the LeaveRequest record in REQUESTED state.
    /// Notifies the manager via the work queue.
    /// </summary>
    Task<Guid> SubmitLeaveRequestAsync(SubmitLeaveRequestCommand command);

    /// <summary>
    /// Approves a leave request. Transitions to APPROVED.
    /// Deducts balance for paid leave types.
    /// Publishes LEAVE_APPROVED signal.
    /// </summary>
    Task ApproveLeaveRequestAsync(ApproveLeaveRequestCommand command);

    /// <summary>
    /// Denies a leave request. Transitions to DENIED.
    /// Restores balance if previously deducted.
    /// </summary>
    Task DenyLeaveRequestAsync(DenyLeaveRequestCommand command);

    /// <summary>
    /// Cancels a leave request before it becomes ACTIVE.
    /// Restores balance if previously deducted.
    /// </summary>
    Task CancelLeaveRequestAsync(Guid leaveRequestId, Guid cancelledBy);

    /// <summary>
    /// Records the employee's return from leave.
    /// Transitions leave to COMPLETED.
    /// Publishes RETURN_TO_WORK lifecycle event.
    /// Triggers payroll reactivation signal.
    /// </summary>
    Task ReturnFromLeaveAsync(ReturnFromLeaveCommand command);

    Task<IEnumerable<LeaveBalance>> GetBalancesAsync(Guid employmentId, DateOnly asOf);
    Task<IEnumerable<LeaveRequest>> GetHistoryAsync(Guid employmentId);
}
```

---

## 5. Leave Request Lifecycle Implementation

### 5.1 Submit Leave Request

```csharp
public async Task<Guid> SubmitLeaveRequestAsync(SubmitLeaveRequestCommand command)
{
    // 1. Validate dates
    if (command.LeaveEndDate < command.LeaveStartDate)
        throw new ValidationException("Leave end date cannot be before start date.");

    // 2. Check for overlapping leave requests
    var overlapping = await _leaveRequestRepository
        .GetActiveByDateRangeAsync(command.LeaveStartDate, command.LeaveEndDate);
    if (overlapping.Any(r => r.EmploymentId == command.EmploymentId))
        throw new DomainException("An overlapping leave request already exists.");

    // 3. Validate balance for paid leave types
    var leaveType = LeaveTypeConfig.Get(command.LeaveType);
    if (leaveType.IsPaid)
    {
        var balance = await _leaveBalanceRepository.GetByEmploymentAndTypeAsync(
            command.EmploymentId, command.LeaveType,
            DateOnly.FromDateTime(_temporalContext.GetOperativeDate()));

        var requestedDays = CalculateWorkingDays(
            command.LeaveStartDate, command.LeaveEndDate);

        if (balance is null || balance.AvailableBalance < requestedDays)
            throw new InsufficientLeaveBalanceException(
                command.LeaveType, requestedDays,
                balance?.AvailableBalance ?? 0);
    }

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        var request = LeaveRequest.Create(command);
        var leaveRequestId = await _leaveRequestRepository.InsertAsync(request, uow);
        uow.Commit();

        // Notify manager after commit
        await _workQueueService.CreateLeaveApprovalTaskAsync(
            leaveRequestId, command.EmploymentId);

        return leaveRequestId;
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

### 5.2 Approve Leave Request

Approval transitions the request to APPROVED, deducts the leave balance, and publishes the payroll impact signal when the leave period begins.

```csharp
public async Task ApproveLeaveRequestAsync(ApproveLeaveRequestCommand command)
{
    var request = await _leaveRequestRepository.GetByIdAsync(command.LeaveRequestId)
        ?? throw new NotFoundException(nameof(LeaveRequest), command.LeaveRequestId);

    if (request.Status != LeaveStatus.Requested)
        throw new InvalidStateTransitionException(
            request.Status.ToString(), LeaveStatus.Approved.ToString());

    var requestedDays = CalculateWorkingDays(
        request.LeaveStartDate, request.LeaveEndDate);

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        // Transition status
        await _leaveRequestRepository.UpdateStatusAsync(
            command.LeaveRequestId, LeaveStatus.Approved.ToString(),
            command.ApprovedBy, uow);

        // Deduct balance for paid leave
        var leaveType = LeaveTypeConfig.Get(request.LeaveType);
        if (leaveType.IsPaid)
        {
            await _leaveBalanceRepository.DeductBalanceAsync(
                request.EmploymentId, request.LeaveType,
                requestedDays, command.LeaveRequestId, uow);
        }

        uow.Commit();

        // Publish payroll impact signal after commit
        await _eventPublisher.PublishAsync(new LeaveApprovedPayload(
            LeaveRequestId:    command.LeaveRequestId,
            EmploymentId:      request.EmploymentId,
            LeaveType:         request.LeaveType,
            LeaveStartDate:    request.LeaveStartDate,
            LeaveEndDate:      request.LeaveEndDate,
            PayrollImpactType: leaveType.PayrollImpactType,
            ApprovedBy:        command.ApprovedBy
        ));
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

### 5.3 Return From Leave

```csharp
public async Task ReturnFromLeaveAsync(ReturnFromLeaveCommand command)
{
    // Find the active leave for this employment
    var activeLeave = (await _leaveRequestRepository
        .GetByEmploymentIdAsync(command.EmploymentId))
        .FirstOrDefault(r => r.Status == LeaveStatus.Active)
        ?? throw new DomainException(
            $"No active leave found for Employment {command.EmploymentId}");

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        // Update leave to COMPLETED with actual return date
        await _leaveRequestRepository.SetReturnDateAsync(
            activeLeave.LeaveRequestId, command.ReturnDate, uow);

        await _leaveRequestRepository.UpdateStatusAsync(
            activeLeave.LeaveRequestId, LeaveStatus.Completed.ToString(),
            command.InitiatedBy, uow);

        uow.Commit();

        // Publish RETURN_TO_WORK lifecycle event — triggers payroll reactivation
        await _eventPublisher.PublishAsync(new ReturnToWorkPayload(
            EmploymentId:   command.EmploymentId,
            ReturnDate:     command.ReturnDate,
            LeaveRequestId: activeLeave.LeaveRequestId,
            InitiatedBy:    command.InitiatedBy
        ));
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

---

## 6. Payroll Impact Signals

When a leave request is approved, the HRIS module publishes a `LeaveApprovedPayload` event. The Payroll module subscribes and uses this signal to determine earnings treatment for the covered period.

| PayrollImpactType | Payroll Behaviour |
|---|---|
| `PAID_SUBSTITUTION` | Payroll generates earnings substitution result lines for the leave period (PTO, Vacation, Sick, etc.) |
| `UNPAID_SUPPRESSION` | Payroll suppresses scheduled earnings for the leave period (LOA, unpaid leave) |
| `DISABILITY_PAY` | Payroll generates special disability pay code result lines (STD, LTD) |
| `NO_IMPACT` | No payroll earnings change (Jury Duty where full pay continues, some holidays) |

**Payroll shall not independently determine leave treatment.** It consumes the `PayrollImpactType` from the published signal. HRIS owns the classification.

### Leave Event Payloads

```csharp
public sealed record LeaveApprovedPayload(
    Guid     LeaveRequestId,
    Guid     EmploymentId,
    string   LeaveType,
    DateOnly LeaveStartDate,
    DateOnly LeaveEndDate,
    string   PayrollImpactType,
    Guid     ApprovedBy);

public sealed record ReturnToWorkPayload(
    Guid     EmploymentId,
    DateOnly ReturnDate,
    Guid     LeaveRequestId,
    Guid     InitiatedBy);

public sealed record LeaveBalanceUpdatedPayload(
    Guid     EmploymentId,
    string   LeaveType,
    decimal  PriorBalance,
    decimal  NewBalance,
    string   ChangeReason);
```

---

## 7. Leave Balance Display

Leave balances are stored in the `leave_balance` table (not yet in the schema — see §12 below) and updated when leave is approved, cancelled, or adjusted.

Each balance record carries:

| Field | Description |
|---|---|
| `employment_id` | The employment this balance belongs to |
| `leave_type` | The leave type |
| `available_balance` | Days available to take |
| `pending_balance` | Days in submitted but not-yet-approved requests |
| `used_balance` | Days used YTD |
| `as_of_date` | Effective date of this balance snapshot |

Balances are displayed on:
- The **Employee Detail page** Leave tab (all balance types for one employee)
- The **Employee List grid** leave progress bar column (used/available for primary leave type)
- The **Manager Dashboard** team leave summary

---

## 8. Blazor Component Specifications

### 8.1 Leave Request Submission (Employee Self-Service)

Available via ESS from the employee's own record. Requires `Employee` or higher role for own record.

**Form fields:**

| Field | Input Type | Validation |
|---|---|---|
| Leave Type | Dropdown — configured leave types | Required |
| Start Date | SfDatePicker | Required; cannot be in the past beyond configurable grace period |
| End Date | SfDatePicker | Required; must be ≥ Start Date |
| Reason | Dropdown — reason codes per leave type | Required |
| Notes | Textarea | Optional |

**On change of date range:** Calculate and display estimated working days and projected balance impact inline — "This request would use 3 days. Remaining balance: 12 days."

**On submit:** Calls `SubmitLeaveRequestAsync`. Success shows confirmation with request ID. Insufficient balance shows inline error with current balance.

---

### 8.2 Leave Approval (Manager Self-Service)

Available from the manager's work queue and from the employee detail page Leave tab.

**Approval card displays:**

- Employee name and avatar
- Leave type and dates
- Duration in working days
- Current balance (for paid leave)
- Reason code and notes
- Approve / Deny buttons with optional notes field

**On Approve:** Calls `ApproveLeaveRequestAsync`. Work queue item resolved. Employee notified.

**On Deny:** Requires denial reason. Calls `DenyLeaveRequestAsync`. Work queue item resolved. Employee notified.

---

### 8.3 Leave Balance Display (Employee Detail — Leave Tab)

Syncfusion Grid or card layout showing all leave types with balances.

| Column | Source |
|---|---|
| Leave Type | `leave_type` display name |
| Available | `available_balance` days |
| Pending | `pending_balance` days |
| Used YTD | `used_balance` days |
| Entitlement | Total annual entitlement (from accrual plan) |
| Progress | Visual progress bar — used / entitlement |

Below the balance table: leave request history grid with columns for Type, Start, End, Duration, Status, Submitted Date.

---

### 8.4 Leave Calendar (Future — v2)

A calendar view showing team leave by month is out of scope for v1. The list-based leave history and balance display covers the v1 requirement.

---

## 9. Working Days Calculation

Leave duration is expressed in working days, not calendar days. The calculation excludes weekends and configured company holidays.

```csharp
public static decimal CalculateWorkingDays(DateOnly start, DateOnly end,
    IEnumerable<DateOnly>? companyHolidays = null)
{
    decimal days = 0;
    var current = start;
    var holidays = companyHolidays?.ToHashSet() ?? [];

    while (current <= end)
    {
        if (current.DayOfWeek != DayOfWeek.Saturday
         && current.DayOfWeek != DayOfWeek.Sunday
         && !holidays.Contains(current))
        {
            days++;
        }
        current = current.AddDays(1);
    }

    return days;
}
```

Holiday exclusion uses the `Holiday_and_Special_Calendar_Model` calendar for the employee's work location.

---

## 10. State Transition Rules

| From | To | Trigger | Guard |
|---|---|---|---|
| REQUESTED | APPROVED | Manager approves | Actor holds LeaveApprover or HrisAdmin role; within reporting scope |
| REQUESTED | DENIED | Manager denies | Actor holds LeaveApprover or HrisAdmin role |
| REQUESTED | CANCELLED | Employee or HR admin cancels | Before approval decision |
| APPROVED | ACTIVE | Leave start date reached | System-triggered on governed operative date |
| APPROVED | CANCELLED | Employee or HR admin cancels | Before leave start date |
| ACTIVE | COMPLETED | Return from leave recorded | `ReturnFromLeaveAsync` called |
| ACTIVE | COMPLETED | Leave end date reached | System-triggered if no early return recorded |

STATE-LEV-003 (DENIED) and STATE-LEV-007 (CANCELLED) are terminal — no further transitions permitted.

---

## 11. Role Definitions for Leave

| Role | Capability |
|---|---|
| `Employee` | Submit own leave requests; view own balances and history |
| `Manager` | Approve/deny direct report leave requests; view team leave balances |
| `HrisAdmin` | Full access — submit, approve, deny, cancel for any employment in scope |
| `LeaveApprover` | Approve/deny leave requests for assigned employees (configurable delegation) |

---

## 12. Schema Addition Required

The `leave_balance` table is not yet in the HRIS schema. The following table must be added to `hris_schema.sql` and `hcm_hris.dbml`:

```sql
CREATE TABLE "leave_balance" (
    "leave_balance_id"    uuid            PRIMARY KEY NOT NULL,
    "employment_id"       uuid            NOT NULL,
    "leave_type"          leave_type      NOT NULL,
    "available_balance"   decimal(10,4)   NOT NULL DEFAULT 0,
    "pending_balance"     decimal(10,4)   NOT NULL DEFAULT 0,
    "used_balance"        decimal(10,4)   NOT NULL DEFAULT 0,
    "entitlement_total"   decimal(10,4)   NOT NULL DEFAULT 0,
    "plan_year_start"     date            NOT NULL,
    "plan_year_end"       date            NOT NULL,
    "last_accrual_date"   date,
    "last_updated_run_id" uuid,
    "created_timestamp"   timestamptz     NOT NULL,
    "last_update_timestamp" timestamptz   NOT NULL
);

CREATE INDEX ON "leave_balance" ("employment_id");
CREATE INDEX ON "leave_balance" ("employment_id", "leave_type", "plan_year_start");
```

Add to `hcm_hris.dbml` under the `workforce_management` TableGroup.

---

## 13. Test Cases

| ID | Description | Expected Result |
|---|---|---|
| TC-LEV-001 | Submit valid PTO request with sufficient balance | LeaveRequest created in REQUESTED state; manager work queue item created; balance not yet deducted |
| TC-LEV-002 | Submit PTO request exceeding available balance | `InsufficientLeaveBalanceException` thrown; no record created |
| TC-LEV-003 | Submit overlapping leave request | `DomainException` thrown; no record created |
| TC-LEV-004 | Submit unpaid LOA request | LeaveRequest created in REQUESTED state; no balance check performed |
| TC-LEV-005 | Approve PTO request | Status transitions to APPROVED; balance deducted; `LeaveApprovedPayload` published post-commit |
| TC-LEV-006 | Approve unpaid LOA request | Status transitions to APPROVED; no balance deducted; `LeaveApprovedPayload` published with `UNPAID_SUPPRESSION` |
| TC-LEV-007 | Deny leave request | Status transitions to DENIED; balance restored if previously deducted |
| TC-LEV-008 | Cancel approved leave before start date | Status transitions to CANCELLED; balance restored |
| TC-LEV-009 | Cancel leave after it becomes ACTIVE | `InvalidStateTransitionException` thrown; leave remains ACTIVE |
| TC-LEV-010 | Return from leave before scheduled end date | Leave transitions to COMPLETED with actual return date; `ReturnToWorkPayload` published |
| TC-LEV-011 | ReturnFromLeaveAsync called with no active leave | `DomainException` thrown |
| TC-LEV-012 | `LeaveApprovedPayload` published after commit | Payload contains correct EmploymentId, LeaveType, PayrollImpactType, dates |
| TC-LEV-013 | `LeaveApprovedPayload` NOT published on rollback | No payload published on failed transaction |
| TC-LEV-014 | Leave Balance tab displays all leave types with correct balances | Grid renders available, pending, used, entitlement, and progress bar per type |
| TC-LEV-015 | Leave request form shows projected balance impact on date change | "This request would use N days. Remaining balance: X days" displayed inline |
| TC-LEV-016 | Manager approval card shows current balance for paid leave | Balance displayed; Approve/Deny buttons present |
| TC-LEV-017 | Manager cannot approve leave for employee outside their scope | `AuthorizationException` thrown; request remains REQUESTED |
| TC-LEV-018 | `CalculateWorkingDays` excludes weekends | 5-day week Mon-Fri returns 5; same period Sat-Sun excluded |
| TC-LEV-019 | `CalculateWorkingDays` excludes company holidays | Period containing a configured holiday returns n-1 days |
| TC-LEV-020 | Leave balance query uses governed operative date | With Temporal Override active, balance resolved as of override date |
