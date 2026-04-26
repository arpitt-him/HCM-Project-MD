# SPEC — HRIS Core Module

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.3 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/SPEC/HRIS_Core_Module.md` |
| **Related Documents** | HRIS_Module_PRD, ADR-007_Module_Composition_DI_Lifetime, ADR-004_Data_Access_Strategy, SPEC/Host_Application_Shell, docs/DATA/Entity_Person.md, docs/DATA/Entity_Employee.md, docs/DATA/Entity_Assignment.md, docs/DATA/Entity_Compensation_Record.md, docs/DATA/Entity_Org_Unit.md, docs/DATA/Entity_Job.md, docs/DATA/Entity_Position.md, docs/STATE/STATE-EMP_Employment_Lifecycle.md, docs/STATE/STATE-WFL_Workflow_Approval.md, docs/architecture/core/Employee_Event_and_Status_Change_Model.md |

---

## Purpose

Defines the implementation-ready specification for the HRIS Core module — the platform's system of record for person identity, employment, organisational structure, job and position management, compensation, and lifecycle events.

This document covers the module assembly structure, repository interfaces, service contracts, domain commands, event publication, Blazor component specifications for core HRIS screens, and test cases.

The HRIS module does not calculate pay, manage accumulators, or own deduction elections. It publishes governed lifecycle events that downstream modules consume.

---

## 1. Module Assembly Structure

```
AllWorkHRIS.Module.Hris/
│
├── HrisModule.cs                         # IPlatformModule implementation
│
├── Domain/
│   ├── Person/
│   │   ├── Person.cs                     # Domain record type
│   │   └── PersonAddress.cs
│   ├── Employment/
│   │   ├── Employment.cs
│   │   └── EmploymentStatus.cs           # Enum — STATE-EMP-010 through 015
│   ├── Assignment/
│   │   └── Assignment.cs
│   ├── Compensation/
│   │   └── CompensationRecord.cs
│   ├── OrgUnit/
│   │   ├── OrgUnit.cs
│   │   └── OrgUnitType.cs
│   ├── Job/
│   │   └── Job.cs
│   ├── Position/
│   │   └── Position.cs
│   └── Events/
│       ├── EmployeeEvent.cs              # Lifecycle event record
│       └── EmployeeEventType.cs          # Enum of event types
│
├── Commands/
│   ├── HireEmployeeCommand.cs
│   ├── RehireEmployeeCommand.cs
│   ├── TerminateEmployeeCommand.cs
│   ├── ChangeCompensationCommand.cs
│   ├── TransferEmployeeCommand.cs
│   ├── UpdatePersonCommand.cs
│   └── ChangeManagerCommand.cs
│
├── Repositories/
│   ├── IPersonRepository.cs
│   ├── IEmploymentRepository.cs
│   ├── IAssignmentRepository.cs
│   ├── ICompensationRepository.cs
│   ├── IOrgUnitRepository.cs
│   ├── IJobRepository.cs
│   ├── IPositionRepository.cs
│   └── IEmployeeEventRepository.cs
│
├── Services/
│   ├── IPersonService.cs
│   ├── IEmploymentService.cs
│   ├── ILifecycleEventService.cs
│   ├── ICompensationService.cs
│   ├── IOrgStructureService.cs
│   └── IEventPublisher.cs
│
└── Queries/
    ├── EmployeeListQuery.cs
    ├── EmployeeDetailQuery.cs
    └── OrgHierarchyQuery.cs
```

---

## 2. HrisModule Registration

```csharp
[Export(typeof(IPlatformModule))]
public sealed class HrisModule : IPlatformModule
{
    public void Register(ContainerBuilder builder)
    {
        // Repositories — scoped per user session
        builder.RegisterType<PersonRepository>()
               .As<IPersonRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<EmploymentRepository>()
               .As<IEmploymentRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<AssignmentRepository>()
               .As<IAssignmentRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<CompensationRepository>()
               .As<ICompensationRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<OrgUnitRepository>()
               .As<IOrgUnitRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<JobRepository>()
               .As<IJobRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<PositionRepository>()
               .As<IPositionRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<EmployeeEventRepository>()
               .As<IEmployeeEventRepository>()
               .InstancePerLifetimeScope();

        // Services — scoped per user session
        builder.RegisterType<PersonService>()
               .As<IPersonService>()
               .InstancePerLifetimeScope();

        builder.RegisterType<EmploymentService>()
               .As<IEmploymentService>()
               .InstancePerLifetimeScope();

        builder.RegisterType<LifecycleEventService>()
               .As<ILifecycleEventService>()
               .InstancePerLifetimeScope();

        builder.RegisterType<CompensationService>()
               .As<ICompensationService>()
               .InstancePerLifetimeScope();

        builder.RegisterType<OrgStructureService>()
               .As<IOrgStructureService>()
               .InstancePerLifetimeScope();

        // The InProcessEventBus is registered as a singleton in AllWorkHRIS.Host Program.cs.
        // The HRIS module does not register the bus — it resolves it to register its own
        // outbound event handler registrations if needed.
        // Per ADR-011: HRIS publishes events; other modules register handlers.
        // HRIS has no knowledge of who is listening.
	}
	
	Note — IEventPublisher registration: The InProcessEventBus singleton is registered in
	AllWorkHRIS.Host Program.cs, not in any module.  Modules resolve IEventPublisher from the
	container to publish events. Subscribing modules (Payroll, T&A, Benefits) register their
	own handlers on the bus in their own Register methods. HRIS never references subscriber
	interfaces from other modules.

    public IEnumerable<MenuContribution> GetMenuContributions() =>
    [
        new MenuContribution
        {
            Label       = "Employees",
            Icon        = "hris-employees-icon",
            SortOrder   = 10,
            AccentColor = "var(--color-accent-teal)",
            BadgeLabel  = "HRIS",
            RequiredRole = "HrisViewer"
        },
        new MenuContribution
        {
            Label        = "Employees",
            Href         = "/hris/employees",
            Icon         = "icon-people",
            SortOrder    = 1,
            ParentLabel  = "Employees",
            RequiredRole = "HrisViewer"
        },
        new MenuContribution
        {
            Label        = "Organisation",
            Href         = "/hris/org",
            Icon         = "icon-hierarchy",
            SortOrder    = 2,
            ParentLabel  = "Employees",
            RequiredRole = "HrisViewer"
        },
        new MenuContribution
        {
            Label        = "Jobs & Positions",
            Href         = "/hris/jobs",
            Icon         = "icon-briefcase",
            SortOrder    = 3,
            ParentLabel  = "Employees",
            RequiredRole = "HrisAdmin"
        }
    ];
}
```

---

## 3. Domain Commands

Commands are the input model for all write operations. They are plain C# records — no business logic. Services validate and execute them.

```csharp
// Commands/HireEmployeeCommand.cs
public sealed record HireEmployeeCommand
{
    // Person identity
    public required string LegalFirstName    { get; init; }
    public required string LegalLastName     { get; init; }
    public string?         LegalMiddleName   { get; init; }
    public string?         PreferredName     { get; init; }
    public required DateOnly DateOfBirth     { get; init; }
    public required string NationalIdentifier { get; init; }  // Encrypted at rest

    // Employment
    public required Guid   LegalEntityId         { get; init; }
    public required string EmployeeNumber         { get; init; }
    public required string EmploymentType         { get; init; }  // EMPLOYEE, CONTRACTOR, etc.
    public required DateOnly EmploymentStartDate  { get; init; }
    public required string FlsaStatus             { get; init; }  // EXEMPT / NON_EXEMPT
    public required string FullOrPartTimeStatus   { get; init; }
    public Guid?           PayrollContextId       { get; init; }
    // Null in HRIS-only deployments where Payroll module is not present.
    // When Payroll is deployed, this value is carried in the HireEventPayload
    // and used by the Payroll module to assign the employment to a pay group.

    // Initial assignment
    public required Guid   JobId                  { get; init; }
    public Guid?           PositionId             { get; init; }
    public required Guid   DepartmentId           { get; init; }
    public required Guid   LocationId             { get; init; }
    public Guid?           ManagerEmploymentId    { get; init; }

    // Initial compensation
    public required string   RateType             { get; init; }  // HOURLY, SALARY, etc.
    public required decimal  BaseRate             { get; init; }
    public required string   PayFrequency         { get; init; }
    public required string   ChangeReasonCode     { get; init; }

    // Metadata
    public required Guid   InitiatedBy            { get; init; }
}

// Commands/TerminateEmployeeCommand.cs
public sealed record TerminateEmployeeCommand
{
    public required Guid     EmploymentId         { get; init; }
    public required DateOnly TerminationDate      { get; init; }
    public required string   EventType            { get; init; }  // TERMINATION or VOLUNTARY_RESIGNATION
    public required string   ReasonCode           { get; init; }
    public required Guid     InitiatedBy          { get; init; }
    public string?           Notes                { get; init; }
}

// Commands/ChangeCompensationCommand.cs
public sealed record ChangeCompensationCommand
{
    public required Guid     EmploymentId         { get; init; }
    public required string   RateType             { get; init; }
    public required decimal  NewBaseRate          { get; init; }
    public required string   PayFrequency         { get; init; }
    public required DateOnly EffectiveDate        { get; init; }
    public required string   ChangeReasonCode     { get; init; }
    public required Guid     InitiatedBy          { get; init; }
}
```

---

## 4. Repository Interfaces

All repositories use Dapper over `IConnectionFactory`. Repositories are read/write — they do not contain business logic.

```csharp
// Repositories/IPersonRepository.cs
public interface IPersonRepository
{
    Task<Person?>            GetByIdAsync(Guid personId);
    Task<Person?>            GetByEmploymentIdAsync(Guid employmentId);
    Task<Guid>               InsertAsync(Person person, IUnitOfWork uow);
    Task                     UpdateAsync(Person person, IUnitOfWork uow);
    Task<IEnumerable<Person>> SearchAsync(string searchTerm, int page, int pageSize);
}

// Repositories/IEmploymentRepository.cs
public interface IEmploymentRepository
{
    Task<Employment?>              GetByIdAsync(Guid employmentId);
    Task<IEnumerable<Employment>>  GetByPersonIdAsync(Guid personId);
    Task<IEnumerable<Employment>>  GetActiveByLegalEntityAsync(Guid legalEntityId, DateOnly asOf);
    Task<Guid>                     InsertAsync(Employment employment, IUnitOfWork uow);
    Task                           UpdateStatusAsync(Guid employmentId, string status,
                                       DateOnly effectiveDate, IUnitOfWork uow);
    Task<PagedResult<EmploymentListItem>> GetPagedListAsync(EmployeeListQuery query);
}

// Repositories/IEmployeeEventRepository.cs
public interface IEmployeeEventRepository
{
    Task<EmployeeEvent?>             GetByIdAsync(Guid eventId);
    Task<IEnumerable<EmployeeEvent>> GetByEmploymentIdAsync(Guid employmentId);
    Task<Guid>                       InsertAsync(EmployeeEvent employeeEvent, IUnitOfWork uow);
    Task                             UpdateStatusAsync(Guid eventId, string status, IUnitOfWork uow);
}

// Repositories/ICompensationRepository.cs
public interface ICompensationRepository
{
    Task<CompensationRecord?>             GetActiveByEmploymentIdAsync(Guid employmentId, DateOnly asOf);
    Task<IEnumerable<CompensationRecord>> GetHistoryByEmploymentIdAsync(Guid employmentId);
    Task<Guid>                            InsertAsync(CompensationRecord record, IUnitOfWork uow);
    Task                                  CloseCurrentAsync(Guid employmentId,
                                              DateOnly endDate, IUnitOfWork uow);
}
```

---

## 5. Service Interfaces

Services contain all business logic. They validate commands, orchestrate repository calls within a unit of work, and publish lifecycle events.

```csharp
// Services/IEmploymentService.cs
public interface IEmploymentService
{
    /// <summary>
    /// Creates a Person record, Employment record, initial Assignment,
    /// and initial CompensationRecord in a single atomic transaction.
    /// Publishes a HIRE lifecycle event on success.
    /// </summary>
    Task<HireResult> HireEmployeeAsync(HireEmployeeCommand command);

    /// <summary>
    /// Creates a new Employment record for an existing Person.
    /// Validates that prior Employment is in Terminated state.
    /// Publishes a REHIRE lifecycle event on success.
    /// </summary>
    Task<HireResult> RehireEmployeeAsync(RehireEmployeeCommand command, Guid personId);

    /// <summary>
    /// Transitions Employment to Terminated state.
    /// Validates direct reports are reassigned (EXC-HRS-001).
    /// Publishes a TERMINATION lifecycle event on success.
    /// </summary>
    Task TerminateEmployeeAsync(TerminateEmployeeCommand command);
}

// Services/ILifecycleEventService.cs
public interface ILifecycleEventService
{
    Task<EmployeeEvent> InitiateEventAsync(Guid employmentId,
        string eventType, string reasonCode, Guid initiatedBy);

    Task ApproveEventAsync(Guid eventId, Guid approvedBy);
    Task RejectEventAsync(Guid eventId, Guid rejectedBy, string reason);
    Task<EmployeeEvent?> GetPendingEventAsync(Guid employmentId, string eventType);
}

// Services/ICompensationService.cs
public interface ICompensationService
{
    /// <summary>
    /// Closes the current active CompensationRecord (sets Effective_End_Date)
    /// and creates a new record with the new rate.
    /// Validates approval workflow completion before taking effect.
    /// Publishes COMPENSATION_CHANGE lifecycle event on success.
    /// </summary>
    Task<Guid> ChangeCompensationAsync(ChangeCompensationCommand command);

    Task<CompensationRecord?> GetCurrentRateAsync(Guid employmentId, DateOnly asOf);
    Task<IEnumerable<CompensationRecord>> GetRateHistoryAsync(Guid employmentId);
}
```

---

## 6. Lifecycle Event Service Implementation Pattern

Every write operation that changes employment state or compensation follows this pattern:

```csharp
public async Task<HireResult> HireEmployeeAsync(HireEmployeeCommand command)
{
    // 1. Validate command
    ValidateHireCommand(command);  // throws ValidationException on failure

    // 2. Check for duplicate employee number
    if (await _employmentRepository.ExistsWithNumberAsync(command.EmployeeNumber))
        throw new DomainException($"Employee number {command.EmployeeNumber} already exists.");

    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        // 3. Create Person
        var person = Person.CreateNew(command);
        var personId = await _personRepository.InsertAsync(person, uow);

        // 4. Create Employment
        var employment = Employment.CreateFromHire(command, personId);
        var employmentId = await _employmentRepository.InsertAsync(employment, uow);

        // 5. Create initial Assignment
        var assignment = Assignment.CreateInitial(command, employmentId);
        await _assignmentRepository.InsertAsync(assignment, uow);

        // 6. Create initial Compensation Record
        var compensation = CompensationRecord.CreateInitial(command, employmentId);
        await _compensationRepository.InsertAsync(compensation, uow);

        // 7. Record lifecycle event
        var hireEvent = EmployeeEvent.CreateHire(personId, employmentId, command);
        var eventId = await _eventRepository.InsertAsync(hireEvent, uow);

        // 8. Commit all writes atomically
        uow.Commit();

        // 9. Publish event AFTER commit — downstream modules consume asynchronously
        await _eventPublisher.PublishAsync(new HireEventPayload(
            EmploymentId: employmentId,
            PersonId: personId,
            EventId: eventId,
            EffectiveDate: command.EmploymentStartDate,
            LegalEntityId: command.LegalEntityId,
            PayrollContextId: command.PayrollContextId,
            FlsaStatus: command.FlsaStatus
        ));

        return new HireResult(personId, employmentId, eventId);
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

**Key rules enforced by this pattern:**
- All writes are atomic — Person, Employment, Assignment, Compensation, and Event all succeed or all fail
- Event publication happens AFTER commit — a failed commit never produces a dangling event
- Downstream modules (Payroll, T&A) consume the published event asynchronously on their own schedule

---

## 7. Event Publisher

The HRIS module publishes lifecycle events to the platform-wide `IEventPublisher` 
(implemented as `InProcessEventBus` in `AllWorkHRIS.Core`). The publisher has no knowledge 
of who is listening. If no modules are deployed that subscribe to a given event type, 
publication is a silent no-op — not an exception. This is the correct and expected 
behaviour in HRIS-only deployments.

Per ADR-011, all event payload types are defined in `AllWorkHRIS.Core/Events/` — not in 
the HRIS module. Both the publishing module (HRIS) and any subscribing modules (Payroll, 
T&A) reference the shared payload types from `AllWorkHRIS.Core`.

### Event payload types (defined in AllWorkHRIS.Core/Events/)

| Payload Type | Published When | Key Fields |
|---|---|---|
| `HireEventPayload` | After `HireEmployeeAsync` commits | EmploymentId, PersonId, EventId, EffectiveDate, LegalEntityId, PayrollContextId (nullable), FlsaStatus |
| `RehireEventPayload` | After `RehireEmployeeAsync` commits | EmploymentId, PersonId, EventId, EffectiveDate, PriorEmploymentId |
| `TerminationEventPayload` | After `TerminateEmployeeAsync` commits | EmploymentId, PersonId, EventId, TerminationDate, EventType, ReasonCode |
| `CompensationChangeEventPayload` | After `ChangeCompensationAsync` commits | EmploymentId, EventId, EffectiveDate, RateType, NewBaseRate, PayFrequency, IsRetroactive |

Leave-related payloads (`LeaveApprovedPayload`, `ReturnToWorkPayload`) are defined in 
`AllWorkHRIS.Core/Events/` and published by the HRIS Leave service — see 
`SPEC/HRIS_Leave_and_Absence`.

### IEventPublisher interface (defined in AllWorkHRIS.Core)

```csharp
// AllWorkHRIS.Core/Events/IEventPublisher.cs
public interface IEventPublisher
{
    /// <summary>
    /// Publishes an event to all registered handlers.
    /// If no handlers are registered for type T, this is a silent no-op.
    /// Must be called AFTER uow.Commit() — never before.
    /// </summary>
    Task PublishAsync<T>(T payload) where T : class;

    /// <summary>
    /// Registers a handler for event type T.
    /// Called by subscribing modules in their IPlatformModule.Register method.
    /// </summary>
    void RegisterHandler<T>(Func<T, Task> handler) where T : class;
}
```

### Publication pattern in HRIS services

```csharp
// After uow.Commit() — never before
await _eventPublisher.PublishAsync(new HireEventPayload(
    EmploymentId:    employmentId,
    PersonId:        personId,
    EventId:         eventId,
    EffectiveDate:   command.EmploymentStartDate,
    LegalEntityId:   command.LegalEntityId,
    PayrollContextId: command.PayrollContextId,  // nullable — null in HRIS-only deployments
    FlsaStatus:      command.FlsaStatus
));
// If Payroll module is present: its handler fires
// If Payroll module is absent: silent no-op — correct behaviour
```

---

## 8. Point-in-Time Query Pattern

All queries that retrieve employment state must support an `asOf` date parameter. This is the effective date — not the recorded date.

```csharp
// Effective-dated employment resolution
public async Task<Employment?> GetActiveEmploymentAsync(
    Guid employmentId, DateOnly? asOf = null)
{
    var effectiveDate = asOf ?? DateOnly.FromDateTime(
        _temporalContext.GetOperativeDate());  // Governed operative date — Temporal Override aware

    const string sql = """
        SELECT *
        FROM employment
        WHERE employment_id = @EmploymentId
          AND employment_start_date <= @AsOf
          AND (employment_end_date IS NULL OR employment_end_date >= @AsOf)
          AND employment_status NOT IN ('TERMINATED', 'CLOSED')
        """;

    using var conn = _connectionFactory.CreateConnection();
    return await conn.QueryFirstOrDefaultAsync<Employment>(sql,
        new { EmploymentId = employmentId, AsOf = effectiveDate });
}
```

**The `_temporalContext.GetOperativeDate()` call** routes through the governed operative date service (SPEC/Temporal_Override) so that all queries respect the Temporal Override when active in a non-production tenant.

---

## 9. Blazor Component Specifications

### 9.1 Employee List Page (`/hris/employees`)

Matches the PoC Employees page. Powered by Syncfusion Grid.

**Summary stat cards (above grid):**

| Card | Value | Source |
|---|---|---|
| Active | Count of Active employments | `employment.employment_status = 'ACTIVE'` |
| On Leave | Count of On Leave employments | `employment.employment_status = 'ON_LEAVE'` |
| Contractors | Count of CONTRACTOR type | `employment.employment_type = 'CONTRACTOR'` |
| Departments | Distinct department count | `assignment.department_id` distinct |

All counts resolved as of today's governed operative date.

**Grid columns:**

| Column | Source | Filterable | Sortable | Notes |
|---|---|---|---|---|
| Avatar | Person initials | No | No | 2-letter circle — first + last initial |
| Employee | Legal name | Yes — text | Yes | Links to employee detail |
| Job Title | Job.job_title via Assignment | Yes — text | Yes | |
| Department | OrgUnit.org_unit_name via Assignment | Yes — custom dropdown | Yes | |
| Status | employment_status | Yes — custom list | Yes | Colour-coded badge |
| Leave | leave_balance / leave_entitlement | No | No | Progress bar — used/total days |
| Start Date | employment_start_date | Yes — custom From/To | Yes | Custom date-range filter per ADR-006 |
| Salary | compensation_record.base_rate | No | Yes | Role-gated — HrisAdmin only |
| Actions | — | No | No | Edit button |

**Custom date-range filter component (Start Date column):**

```razor
@* Reusable component: DateRangeFilter.razor *@
<div class="date-range-filter">
    <SfDatePicker @bind-Value="FromDate"
                  Placeholder="From"
                  CssClass="filter-date-input" />
    <span class="filter-separator">–</span>
    <SfDatePicker @bind-Value="ToDate"
                  Placeholder="To"
                  CssClass="filter-date-input" />
    <button class="filter-apply-btn" @onclick="ApplyFilter">Apply</button>
    <button class="filter-clear-btn" @onclick="ClearFilter">Clear</button>
</div>

@code {
    [Parameter] public EventCallback<(DateOnly? From, DateOnly? To)> OnFilterChanged { get; set; }

    private DateTime? FromDate;
    private DateTime? ToDate;

    private async Task ApplyFilter()
    {
        var from = FromDate.HasValue ? DateOnly.FromDateTime(FromDate.Value) : (DateOnly?)null;
        var to   = ToDate.HasValue   ? DateOnly.FromDateTime(ToDate.Value)   : (DateOnly?)null;
        await OnFilterChanged.InvokeAsync((from, to));
    }

    private async Task ClearFilter()
    {
        FromDate = null;
        ToDate = null;
        await OnFilterChanged.InvokeAsync((null, null));
    }
}
```

This component is the platform-wide standard for date-range filtering on all grids per ADR-006.

**+ Add Employee button:** Opens the Add Employee side panel / modal. Requires `HrisAdmin` role.

---

### 9.2 Employee Detail Page (`/hris/employees/{employmentId}`)

Tabbed layout. Tabs:

| Tab | Content | Required Role |
|---|---|---|
| Profile | Person identity, contact info, emergency contact | HrisViewer |
| Employment | Employment record, status, type, FLSA, start/end dates | HrisViewer |
| Assignment | Current assignment — job, position, department, location, manager | HrisViewer |
| Compensation | Current rate, pay frequency, rate history table | HrisAdmin |
| Leave | Leave balances by type, request history | HrisViewer |
| Documents | Document list with upload, expiration tracking | HrisAdmin |
| History | Lifecycle event log — all events in chronological order | HrisViewer |

**Lifecycle action buttons (top right of page):**

| Button | Event Type | Required Role | Visible When |
|---|---|---|---|
| Edit Profile | — | HrisAdmin | Always |
| Change Compensation | COMPENSATION_CHANGE | HrisAdmin | Active employment |
| Transfer | DEPARTMENT_TRANSFER / LOCATION_TRANSFER | HrisAdmin | Active employment |
| Change Manager | MANAGER_CHANGE | HrisAdmin | Active employment |
| Place on Leave | LEAVE_OF_ABSENCE | HrisAdmin | Active employment |
| Return from Leave | RETURN_TO_WORK | HrisAdmin | On Leave employment |
| Terminate | TERMINATION | HrisAdmin | Active or On Leave |

Each button opens a workflow modal that collects the required command fields, submits to the appropriate service method, and refreshes the page on success.

---

### 9.3 Add/Edit Employee Side Panel

Opened from the Employee List `+ Add Employee` button or the detail page `Edit Profile` button. Implemented as a Syncfusion Sidebar or Dialog component.

**For Add Employee (Hire workflow):** Multi-step form.

| Step | Fields |
|---|---|
| 1 — Identity | Legal name, preferred name, date of birth, national identifier (masked input) |
| 2 — Employment | Legal entity, employee number, employment type, start date, FLSA status, full/part time |
| 3 — Assignment | Job, position (optional), department, location, manager |
| 4 — Compensation | Rate type, base rate, pay frequency, reason code |
| 5 — Review | Summary of all entries; Submit button triggers `HireEmployeeAsync` |

Validation runs client-side (required fields, date logic) and server-side (duplicate employee number, valid foreign keys). Server-side validation errors display inline at the relevant field.

---

### 9.4 Organisation Page (`/hris/org`)

Two views toggled by tab:

**Hierarchy view** — tree display of org units. Expandable nodes. Shows org unit name, type badge, and employee count. Powered by Syncfusion TreeView or custom recursive component.

**List view** — Syncfusion Grid of all org units with columns: Name, Type, Parent, Status, Effective Start, Employee Count. Filterable by Type and Status.

**+ Add Org Unit** button (HrisAdmin): opens a form for creating a new org unit with parent selection.

---

## 10. Effective Date and Retroactive Handling

**REQ-HRS-017 implementation:** Every record-mutating service method that accepts an `EffectiveDate` parameter must check whether the date is in the past relative to the governed operative date. If it is, the `Retroactive_Flag` is set on the lifecycle event and `EXC-VAL-014` is raised as a warning routed to the operator work queue.

```csharp
private bool IsRetroactive(DateOnly effectiveDate)
{
    var operativeDate = DateOnly.FromDateTime(_temporalContext.GetOperativeDate());
    return effectiveDate < operativeDate;
}
```

Retroactive events do not silently alter historical records. They generate a work queue item for the payroll operator to review impacted periods and initiate correction runs where needed.

---

## 11. Role Definitions

| Role | Description |
|---|---|
| `HrisViewer` | Read-only access to employee records and org structure |
| `HrisAdmin` | Full read/write access including lifecycle events and compensation |
| `Manager` | Read access scoped to direct reports; can initiate limited lifecycle events |
| `Employee` | Self-service access to own record only — governed by SPEC/Self_Service_Model |

Role assignments are managed through the platform's Security and Access Control model.

---

## 12. Test Cases

| ID | Description | Expected Result |
|---|---|---|
| TC-HRS-001 | Hire command with all valid fields | Person, Employment, Assignment, CompensationRecord created atomically; HIRE event published; HireResult returns all three IDs |
| TC-HRS-002 | Hire command with duplicate employee number | Service throws DomainException; no records created; no event published |
| TC-HRS-003 | Hire command missing required field | ValidationException thrown before any DB write |
| TC-HRS-004 | Terminate active employment | Employment transitions to Terminated; TERMINATION event published |
| TC-HRS-005 | Terminate employment with unresigned direct reports | EXC-HRS-001 raised as Hold; termination blocked until direct reports reassigned |
| TC-HRS-006 | Rehire terminated employee | New Employment_ID created; Person_ID unchanged; prior Employment record unmodified; REHIRE event published |
| TC-HRS-007 | Rehire attempt on active employment | Service throws DomainException — cannot rehire active employee |
| TC-HRS-008 | Compensation change with future effective date | New CompensationRecord created; prior record closed; COMPENSATION_CHANGE event published; non-retroactive |
| TC-HRS-009 | Compensation change with past effective date | Retroactive_Flag set on event; EXC-VAL-014 raised as warning; work queue item created |
| TC-HRS-010 | GetActiveEmploymentAsync with asOf date in past | Returns employment record active on that date, not current state |
| TC-HRS-011 | GetActiveEmploymentAsync with Temporal Override active | Governed operative date used for resolution, not system clock |
| TC-HRS-012 | UnitOfWork rolls back on exception mid-hire | Neither Person nor Employment created; database clean |
| TC-HRS-013 | Employee List page loads with 20 employees | Grid renders correct columns; stat cards show correct counts; pagination shows 2 pages |
| TC-HRS-014 | Salary column visible to HrisAdmin user | Salary column renders with compensation value |
| TC-HRS-015 | Salary column hidden from HrisViewer user | Salary column not rendered; no value visible |
| TC-HRS-016 | Date-range filter on Start Date column | Grid filters to employees whose start date falls within the From/To range |
| TC-HRS-017 | + Add Employee button visible to HrisAdmin | Button renders; side panel opens on click |
| TC-HRS-018 | + Add Employee button hidden from HrisViewer | Button not rendered |
| TC-HRS-019 | Multi-step hire form submitted with valid data | HireEmployeeAsync called; success message shown; employee appears in grid |
| TC-HRS-020 | Terminate button generates MANAGER_CHANGE gate | EXC-HRS-001 modal displays list of direct reports requiring reassignment |
| TC-HRS-021 | Org hierarchy page renders parent-child tree | Org units display in correct hierarchy; expand/collapse works |
| TC-HRS-022 | Event publisher called after uow.Commit() | Event payload contains correct EmploymentId, PersonId, EffectiveDate |
| TC-HRS-023 | Event publisher NOT called if uow.Rollback() | No event payload published on failed transaction |
| TC-HRS-024 | Hire employee with PayrollContextId = null (HRIS-only deployment) | Hire succeeds; Person, Employment, Assignment, Compensation, Event all created; HireEventPayload published with null PayrollContextId |
| TC-HRS-025 | HireEventPayload published with no Payroll module present | PublishAsync completes without exception; no handlers invoked; no error |
| TC-HRS-026 | HRIS module starts with no other modules in ./modules folder | Application starts; HRIS menu items appear; all HRIS pages functional |