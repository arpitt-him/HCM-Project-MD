# AllWorkHRIS — Build Sequence Plan

| Field | Detail |
|---|---|
| **Document Type** | Build Planning |
| **Version** | v0.2 |
| **Status** | Active |
| **Owner** | Core Platform |
| **Location** | `docs/build/Build_Sequence_Plan.md` |
| **Date** | April 2026 |
| **Related Documents** | ADR-009_Authentication_Identity_Strategy, ADR-010_Tenant_Isolation_Strategy, ADR-011_Module_Independence_Principle, SPEC/Host_Application_Shell, SPEC/HRIS_Core_Module, SPEC/HRIS_Leave_and_Absence, SPEC/HRIS_Document_Management, SPEC/Payroll_Core_Module, SPEC/Benefits_Minimum_Module, SPEC/Time_Attendance_Minimum_Module, SPEC/Reporting_Minimum_Module |

---

## Purpose

Defines the sequenced build order for the AllWorkHRIS platform. Each phase has a clear completion gate — a working, runnable state that proves the foundation before the next phase builds on it. No phase begins until its predecessor's gate is passed.

The sequence is designed so that after Phase 2, a minimum working HRIS application exists that each subsequent module can be developed from. Phase 2 ends with a formal HRIS Standalone Test that proves the HRIS module operates correctly with no other modules present — no Payroll schema, no Payroll module, no cross-module dependencies.

---

## Guiding Principles

**Build in vertical slices, not horizontal layers.** Each phase delivers a working feature end-to-end — not a layer of plumbing waiting for another layer to become useful.

**Every phase ends with a runnable application.** After each phase the application starts, authenticates a user, renders the shell, and the completed features work. No phase ends with a partially wired system.

**Security from day one.** Authentication and tenant isolation are wired in Phase 1. No phase operates without them.

**Database before code.** The HRIS schema is applied in Phase 0 and the HRIS application runs against it alone through Phases 0–3. The Payroll schema is applied at the start of Phase 4 — not before.

**Module independence is a gate, not an aspiration.** Phase 2 does not complete until the HRIS Standalone Test passes. This test proves per ADR-011 that HRIS is independently deployable.

**Test cases are phase deliverables.** Each phase lists the test cases from the relevant SPEC that must pass before the phase is considered complete.

---

## Phase Overview

| Phase | Name | Schema State | Module State | Gate |
|---|---|---|---|---|
| 0 | Infrastructure | HRIS schema only | No modules | PostgreSQL running; Keycloak running; HRIS schema applied; payroll schema absent |
| 1 | Core + Host Shell | HRIS schema only | No modules | Shell renders; authentication works; empty nav menu displays |
| 2 | HRIS Core | HRIS schema only | HRIS module only | Hire employee; view list; HRIS Standalone Test (8 steps) passes |
| 3 | HRIS Supporting | HRIS schema + leave_balance + legal_hold_flag | HRIS module only | Submit leave; upload document; onboarding plan created on hire |
| 4 | Payroll Core | HRIS + Payroll schemas | HRIS + Payroll modules | Initiate run; calculation completes; pay register renders |
| 5 | Benefits | HRIS + Payroll schemas | HRIS + Payroll + Benefits | Elections appear in payroll calculation |
| 6 | Time & Attendance | HRIS + Payroll schemas | HRIS + Payroll + T&A | Approved time flows into payroll run |
| 7 | Reporting | HRIS + Payroll schemas | All modules | PAY-RPT-001 runs; XLSX export correct; HR-RPT-001 runs |
| 8 | Hardening | Full schema | All modules | All 165 TC-* test cases passing; security audit complete |

Note: Phases 5, 6, and 7 can be developed in parallel once Phase 4 is complete. They are independent of each other. Phase 8 requires all of 1–7.

---

## Dependency Map

```
Phase 0 (Infrastructure)
    └── Phase 1 (Core + Host Shell)
            └── Phase 2 (HRIS Core)         ← Minimum Working Application
                    │                          ← HRIS Standalone Test gate
                    ├── Phase 3 (HRIS Supporting)
                    │       └── Phase 4 (Payroll Core)
                    │               ├── Phase 5 (Benefits)      ─┐
                    │               ├── Phase 6 (T&A)            ├─ parallel
                    │               └── Phase 7 (Reporting)     ─┘
                    │                       └── Phase 8 (Hardening)
                    └── Phase 4 can begin in parallel with Phase 3
```

---

## Phase 0 — Infrastructure

**Goal:** Local development environment is fully operational before a line of application code is written.

### Deliverables

**0.1 — PostgreSQL**
- Install PostgreSQL 16 locally or via Docker:
  ```
  docker run -e POSTGRES_PASSWORD=dev -p 5432:5432 postgres:16
  ```
- Create development database: `allworkhris_dev`
- Apply HRIS schema only: `schemas/ddl/hris_schema.sql`
- Verify schema applied cleanly with no errors
- **Do NOT apply `payroll_core_schema.sql` at this stage** — Payroll schema is applied at the start of Phase 4

**0.2 — Verify HRIS-only schema state**
- Confirm `employment` table exists
- Confirm `payroll_run` table does NOT exist
- This confirms a clean HRIS-only baseline

**0.3 — Keycloak (OIDC provider)**
- Run Keycloak in Docker:
  ```
  docker run -p 8080:8080 \
    -e KEYCLOAK_ADMIN=admin \
    -e KEYCLOAK_ADMIN_PASSWORD=admin \
    quay.io/keycloak/keycloak:latest start-dev
  ```
- Create realm: `allworkhris`
- Create client: `allworkhris-app` with Authorization Code flow, set redirect URI to `https://localhost:5001/*`
- Create test users with platform roles as JWT claims:
  - `admin@test.com` — roles: `HrisAdmin`, `PayrollAdmin`, `ReportAdmin`
  - `hr@test.com` — roles: `HrisAdmin`, `HrisViewer`
  - `payroll@test.com` — roles: `PayrollOperator`, `PayrollAdmin`
  - `manager@test.com` — roles: `Manager`, `HrisViewer`
  - `employee@test.com` — roles: `Employee`
- Add `tenant_id` claim to token — value: `00000000-0000-0000-0000-000000000001` (dev tenant)
- Note authority URL, client ID, and client secret for `launchSettings.json`

**0.4 — Solution scaffold**
- Create `AllWorkHRIS.sln`
- Create projects (empty, no code yet):
  - `src/AllWorkHRIS.Core` (class library)
  - `src/AllWorkHRIS.Host` (Blazor Server)
  - `tests/AllWorkHRIS.Host.Tests` (xUnit)
- Add NuGet packages to `AllWorkHRIS.Core`:
  - `Autofac`
  - `Dapper`
  - `Npgsql`
  - `Microsoft.Data.SqlClient`
  - `MySql.Data`
- Add NuGet packages to `AllWorkHRIS.Host`:
  - `Autofac.Extensions.DependencyInjection`
  - `Syncfusion.Blazor` (version 33.1.44)
  - `Microsoft.AspNetCore.Authentication.OpenIdConnect`

**0.5 — Environment configuration**
- Create `launchSettings.json` with all required environment variables:
  - `SYNCFUSION_LICENSE_KEY`
  - `DATABASE_CONNECTION_STRING` = `Host=localhost;Database=allworkhris_dev;Username=postgres;Password=dev`
  - `DATABASE_PROVIDER` = `postgresql`
  - `APP_ENVIRONMENT` = `Development`
  - `AUTH_AUTHORITY` = `http://localhost:8080/realms/allworkhris`
  - `AUTH_CLIENT_ID` = `allworkhris-app`
  - `AUTH_CLIENT_SECRET` = (from Keycloak client configuration)
  - `TEMPORAL_OVERRIDE_ENABLED` = `true`

### Gate
- PostgreSQL starts and accepts connections
- HRIS schema (`hris_schema.sql`) applies without errors — `employment` table exists
- Payroll schema is NOT present — `payroll_run` table does not exist
- Keycloak starts and issues tokens for all five test users
- Solution builds (empty projects, no errors)

---

## Phase 1 — Core + Host Shell

**Goal:** A running Blazor Server application that authenticates users, renders the shell layout with an empty nav menu, and proves the MEF + Autofac composition pipeline works end to end.

**Spec:** `SPEC/Host_Application_Shell`
**Projects:** `AllWorkHRIS.Core`, `AllWorkHRIS.Host`

### Deliverables

**1.1 — AllWorkHRIS.Core**

Implement in order:
1. `IPlatformModule` interface
2. `MenuContribution` sealed record
3. `IConnectionFactory` interface and `ConnectionFactory` implementation
4. `IUnitOfWork` interface and `UnitOfWork` implementation
5. `IAuditableEntity` interface
6. `ClaimsPrincipalExtensions` — `GetTenantId()`, `GetEmploymentId()`, `GetDisplayName()`
7. `EnvironmentValidator` static class
8. `Events/IEventPublisher` interface — `PublishAsync<T>` and `RegisterHandler<T>`
9. `Events/InProcessEventBus` implementation — `ConcurrentDictionary`-backed; zero-subscriber no-op
10. All event payload types in `Events/`:
    - `HireEventPayload`
    - `RehireEventPayload`
    - `TerminationEventPayload`
    - `CompensationChangeEventPayload`
    - `LeaveApprovedPayload`
    - `ReturnToWorkPayload`

**1.2 — AllWorkHRIS.Host**

Implement in order:
1. `Program.cs` — full startup sequence per `SPEC/Host_Application_Shell` §3:
   - Syncfusion license registration from environment variable
   - `EnvironmentValidator`
   - MEF module discovery (no modules yet — empty scan is correct)
   - Autofac container — `ConnectionFactory`, `InProcessEventBus` as singletons
   - Menu contributions singleton (empty list is correct)
   - Syncfusion services
   - Blazor Server
   - OIDC authentication per ADR-009
   - `TenantConnectionMiddleware` per ADR-010 (single dev tenant)
   - Middleware pipeline in correct order
   - Blazor hub and fallback
2. `App.razor` — `AuthorizeRouteView` wrapping all routes
3. `_Host.cshtml` — standard Blazor Server host page
4. `MainLayout.razor` — dark sidebar + content area per SPEC §9
5. `NavMenu.razor` — renders menu contributions; empty list = empty nav
6. `TopBar.razor` — app display name + authenticated user name
7. `app.css` — full CSS design token set per SPEC §11
8. `Index.razor` — minimal home page
9. `Error.razor` — error boundary page

**1.3 — Tenant middleware**

Implement `TenantConnectionMiddleware` and `TenantRegistry` per ADR-010:
- Phase 1: single dev tenant resolved from `DATABASE_CONNECTION_STRING` environment variable
- Middleware reads `tenant_id` claim from JWT and registers the correct `IConnectionFactory` in the Autofac per-request lifetime scope

### Gate — TC-HST test cases
- TC-HST-001: Application starts with all required environment variables set ✓
- TC-HST-002: Missing `SYNCFUSION_LICENSE_KEY` causes fail-fast ✓
- TC-HST-003: Missing `DATABASE_CONNECTION_STRING` causes fail-fast ✓
- TC-HST-008: Unauthenticated user redirected to OIDC login page ✓
- TC-HST-009: `DATABASE_PROVIDER = postgresql` returns `NpgsqlConnection` ✓
- TC-HST-015/016: `APP_DISPLAY_NAME` displays correctly ✓
- TC-HST-017: Unauthenticated API request returns HTTP 401 ✓

**Manually verified:**
- Login with `admin@test.com` — shell renders with dark sidebar and top bar
- Login with `employee@test.com` — shell renders with empty nav (no modules yet)
- CSS design tokens applied correctly; Caribbean pastel palette visible

---

## Phase 2 — HRIS Core

**Goal:** A working HR administrator can hire an employee, view the employee list, and open the employee detail page. Phase 2 ends with the HRIS Standalone Test proving full module independence.

**Spec:** `SPEC/HRIS_Core_Module`
**Project:** `AllWorkHRIS.Web` — HRIS repositories, services, domain types, and UI pages implemented directly in the host application
**Database:** HRIS schema already applied in Phase 0 — no changes

### Deliverables

**2.1 — HRIS folder structure in AllWorkHRIS.Web**
- Create HRIS folder structure within `AllWorkHRIS.Web` per `SPEC/HRIS_Core_Module` §1
- No separate project or class library — HRIS lives in the host application
- Namespaces: `AllWorkHRIS.Web.Domain.Hris`, `AllWorkHRIS.Web.Repositories.Hris`,
  `AllWorkHRIS.Web.Services.Hris`, `AllWorkHRIS.Web.Commands.Hris`,
  `AllWorkHRIS.Web.Queries.Hris`

**2.2 — Domain types**
- `Person`, `PersonAddress` records
- `Employment`, `EmploymentStatus` enum
- `Assignment`
- `CompensationRecord`
- `OrgUnit`, `OrgUnitType` enum
- `Job`, `Position`
- `EmployeeEvent`, `EmployeeEventType` enum

**2.3 — Commands**
- `HireEmployeeCommand` — `PayrollContextId` is `Guid?` (nullable) per ADR-011
- `TerminateEmployeeCommand`
- `ChangeCompensationCommand`
- `UpdatePersonCommand`
- `ChangeManagerCommand`
- `TransferEmployeeCommand`
- `RehireEmployeeCommand`

**2.4 — Repositories**
Implement against HRIS schema using Dapper:
- `IPersonRepository` / `PersonRepository`
- `IEmploymentRepository` / `EmploymentRepository`
- `IAssignmentRepository` / `AssignmentRepository`
- `ICompensationRepository` / `CompensationRepository`
- `IOrgUnitRepository` / `OrgUnitRepository`
- `IJobRepository` / `JobRepository`
- `IPositionRepository` / `PositionRepository`
- `IEmployeeEventRepository` / `EmployeeEventRepository`

**2.5 — Services**
- `IPersonService` / `PersonService`
- `IEmploymentService` / `EmploymentService` — `HireEmployeeAsync` atomic pattern per SPEC §6; publishes `HireEventPayload` after commit with nullable `PayrollContextId`
- `ILifecycleEventService` / `LifecycleEventService`
- `ICompensationService` / `CompensationService`
- `IOrgStructureService` / `OrgStructureService`

**2.6 — Register HRIS services in Program.cs**
- Add HRIS repository and service registrations to the Autofac container build in
  `Program.cs` per `SPEC/HRIS_Core_Module` §2
- Add HRIS menu contributions as a fixed list prepended to module-discovered items
  per `SPEC/HRIS_Core_Module` §2
- No `HrisModule` class; no `IPlatformModule` implementation for HRIS

**2.7 — UI components (in AllWorkHRIS.Web)**

Organised under `Pages/Hris/` namespace:
- `Shared/DateRangeFilter.razor` — platform-wide reusable component per ADR-006
- `EmployeeList.razor` — Syncfusion Grid with stat cards, role-filtered salary column
- `EmployeeDetail.razor` — tabbed: Profile, Employment, Assignment, Compensation, History
- `OrgPage.razor` — hierarchy view + list view
- `HireEmployeePanel.razor` — multi-step hire form; `PayrollContextId` field optional/hidden when Payroll module absent

**2.8 — Verify HRIS registration**
- Start the application
- Verify Employees menu items appear in nav with teal accent colour
- Verify `./modules` folder is empty — no plug-in module DLLs present
- Confirm HRIS repositories and services resolve correctly from the Autofac container

### Gate — TC-HRS test cases
- TC-HRS-001: Hire command creates Person, Employment, Assignment, Compensation, Event atomically ✓
- TC-HRS-002: Duplicate employee number throws DomainException ✓
- TC-HRS-003: Missing required field throws ValidationException ✓
- TC-HRS-010: Point-in-time query returns correct historical state ✓
- TC-HRS-012: UnitOfWork rollback on exception leaves database clean ✓
- TC-HRS-013: Employee List renders with correct stat cards and pagination ✓
- TC-HRS-014/015: Salary column visible to HrisAdmin; hidden from HrisViewer ✓
- TC-HRS-016: Date-range filter on Start Date column works ✓
- TC-HRS-017/018: Add Employee button role-gated correctly ✓
- TC-HRS-019: Multi-step hire form submits successfully ✓
- TC-HRS-024: Hire with PayrollContextId = null succeeds ✓
- TC-HRS-025: HireEventPayload published with no subscribers — no exception ✓
- TC-HRS-026: HRIS module starts with no other modules present — application functional ✓

### HRIS Standalone Test (mandatory gate — proves ADR-011 compliance)

All 8 steps must pass before Phase 2 is considered complete:

1. Confirm `payroll_run` table does NOT exist in `allworkhris_dev`
2. Confirm `./modules` folder is empty — no plug-in module DLLs present
3. Start the application — verify it starts without errors
4. Authenticate as `admin@test.com` — verify shell renders; only HRIS menu items present
5. Hire a new employee with `PayrollContextId` left blank/null — verify hire succeeds
6. Verify Person, Employment, Assignment, CompensationRecord, and EmployeeEvent records created in the database
7. Verify `HireEventPayload` was published — no exception raised despite zero subscribers
8. Verify the hired employee appears in the Employee List grid with correct columns

All 8 steps passing = HRIS module independence confirmed. Phase 2 complete.

---

## Phase 3 — HRIS Supporting Features

**Goal:** Leave management, document upload, and onboarding workflow are operational within the HRIS module. The application is now a complete minimum HRIS suitable for client use.

**Specs:** `SPEC/HRIS_Leave_and_Absence`, `SPEC/HRIS_Document_Management`, `SPEC/Onboarding_Workflow`
**Project:** Additions to `AllWorkHRIS.Module.Hris`
**Database:** HRIS schema only — two additive changes

### Deliverables

**3.1 — Schema additions**
- Add `leave_balance` table to `hcm_hris.dbml` per `HRIS_Leave_and_Absence` §12
- Add `legal_hold_flag` column to `document` table per `HRIS_Document_Management` §13
- Regenerate `hris_schema.sql` and apply additive changes to `allworkhris_dev`
- Verify HRIS schema still works end to end after additions

**3.2 — Leave and Absence**
- Domain: `LeaveRequest`, `LeaveBalance`, `LeaveType`, `LeaveStatus`, `PayrollImpactType`
- Commands: `SubmitLeaveRequestCommand`, `ApproveLeaveRequestCommand`, `DenyLeaveRequestCommand`, `CancelLeaveRequestCommand`, `ReturnFromLeaveCommand`
- Repositories: `ILeaveRequestRepository`, `ILeaveBalanceRepository`
- Service: `ILeaveService` / `LeaveService` — full lifecycle per SPEC §5
- Publishes `LeaveApprovedPayload` and `ReturnToWorkPayload` via `IEventPublisher` after commit (no-op if Payroll absent)
- UI: Leave tab on Employee Detail, leave submission form, manager approval panel

**3.3 — Document Management**
- Domain: `HrDocument`, `DocumentType`, `DocumentStatus`
- Commands: `UploadDocumentCommand`, `VerifyDocumentCommand`, `SupersedeDocumentCommand`, `ArchiveDocumentCommand`
- Repository: `IDocumentRepository`
- Services: `IDocumentService`, `IDocumentStorageService` (filesystem implementation for dev)
- Background job: `DocumentExpirationCheckJob` as `IHostedService`
- UI: Documents tab on Employee Detail, upload panel, expiration report page

**3.4 — Onboarding**
- Wire `OnboardingPlanCreated` event publication to `HireEmployeeAsync` after commit
- Onboarding plan auto-creation on hire
- Onboarding task tracking on Employee Detail — Onboarding tab

### Gate — TC-LEV and TC-DOC test cases
- TC-LEV-001 through TC-LEV-007: Leave request lifecycle ✓
- TC-LEV-012/013: Event publication timing (after commit, not on rollback) ✓
- TC-DOC-001/002: Document upload and supersession ✓
- TC-DOC-005/006/007/008: I-9 verification gate ✓
- TC-DOC-012/013: Download audit logging enforced ✓

**Manually verified:**
- Submit PTO request — approve as manager — balance deducted
- Upload I-9 — verify it — employment activation gated correctly
- Hire new employee — onboarding plan created automatically with blocking tasks

---

## Phase 4 — Payroll Core

**Goal:** A payroll operator can initiate a regular payroll run for employees hired in Phases 2/3, watch it calculate in real time, review the pay register, and approve the run.

**Spec:** `SPEC/Payroll_Core_Module`
**Project:** `AllWorkHRIS.Module.Payroll` (new class library)

### Deliverables

**4.0 — Apply Payroll schema**
- Apply `schemas/ddl/payroll_core_schema.sql` to `allworkhris_dev`
- Verify schema applied cleanly — `payroll_run` table now exists
- Verify HRIS tables are unaffected — smoke query against `employment` table

**4.1 — Module project setup**
- Create `AllWorkHRIS.Module.Payroll` class library
- Add project reference to `AllWorkHRIS.Core` only — no reference to `AllWorkHRIS.Module.Hris`
- Create folder structure per `SPEC/Payroll_Core_Module` §1

**4.2 — Domain types**
All domain types per SPEC §1 folder structure

**4.3 — HRIS event handlers**
- `IPayrollEventSubscriber` / `PayrollEventSubscriber`
- Handlers registered on `IEventPublisher` (InProcessEventBus) in `PayrollModule.Register` per ADR-011 Rule 6:
  - `HandleHireAsync` — registered for `HireEventPayload`
  - `HandleTerminationAsync` — registered for `TerminationEventPayload`
  - `HandleCompensationChangeAsync` — registered for `CompensationChangeEventPayload`
  - `HandleLeaveApprovedAsync` — registered for `LeaveApprovedPayload`
  - `HandleReturnToWorkAsync` — registered for `ReturnToWorkPayload`

**4.4 — Repositories**
- `IPayrollRunRepository`, `IPayrollRunResultSetRepository`
- `IEmployeePayrollResultRepository`, `IResultLineRepository`
- `IAccumulatorRepository`, `IPayrollContextRepository`

**4.5 — Calculation Engine**
- `ICalculationEngine` / `CalculationEngine` — 9-step ordered computation per SPEC §8
- `IAccumulatorService` / `AccumulatorService` — 4-layer mutation chain per SPEC §9

**4.6 — Run Service and Background Job**
- `IPayrollRunService` / `PayrollRunService` — `InitiateRunAsync` pattern per SPEC §6
- `PayrollRunJob` — `IHostedService` with `Channel<Guid>` queue per SPEC §7
- SignalR hub for real-time progress updates

**4.7 — PayrollModule registration**
- `PayrollModule` implementing `IPlatformModule`
- `Register` — all repositories, services, and HRIS event handler registrations
- Menu contributions: Payroll Runs, Pay Register, Accumulators

**4.8 — UI components**
- `PayrollRunList.razor` — run list with stat cards
- `RunProgressPanel.razor` — real-time SignalR progress
- `RunDetail.razor` — tabbed: Summary, Pay Register, Exceptions, Variance
- `PayRegisterGrid.razor` — Syncfusion Grid with drill-down
- `NewRunForm.razor` — run initiation form

### Gate — TC-PAY test cases
- TC-PAY-001: Initiate run returns RunId and JobId immediately ✓
- TC-PAY-002: Duplicate open run for period rejected ✓
- TC-PAY-003: Job transitions run to CALCULATING; progress updates published ✓
- TC-PAY-004: Employee calculation produces correct result lines and accumulator impacts ✓
- TC-PAY-005: Employee-level failure isolated; run continues ✓
- TC-PAY-006: Accumulator mutation atomic — rollback on failure ✓
- TC-PAY-007: Pre-tax deduction reduces taxable wages; taxes on reduced base ✓
- TC-PAY-011: 250-employee run completes with progress = 100% ✓
- TC-PAY-012: Progress visible in UI during calculation ✓
- TC-PAY-020/021: HRIS events received and handled correctly ✓

**Manually verified:**
- Hire 5 test employees with varying pay types and rates
- Initiate a REGULAR payroll run
- Watch progress panel update in real time
- Review pay register — gross/net totals correct
- Approve the run

---

## Phase 5 — Benefits (Minimum)

**Goal:** HR administrator can configure deduction codes, enter employee benefit elections, and verify those deductions appear correctly in the payroll run.

**Spec:** `SPEC/Benefits_Minimum_Module`
**Project:** `AllWorkHRIS.Module.Benefits` (new class library)

### Deliverables
- Module project setup — references `AllWorkHRIS.Core` only
- `DeductionCode`, `BenefitDeductionElection` domain types
- `IDeductionCodeRepository`, `IBenefitElectionRepository`
- `IBenefitElectionService` — full lifecycle including versioning pattern per SPEC §7
- `IBenefitElectionImportService` — batch import with dry-run
- HRIS event handlers registered on `IEventPublisher` in `BenefitsModule.Register`:
  - Termination → terminate all active elections
  - Leave → suspend all active elections
  - ReturnToWork → reinstate suspended elections
- `BenefitsModule` registration and menu contributions
- UI: Deduction Codes page, Elections page, Employee Benefits tab, Import page

### Gate — TC-BEN test cases
- TC-BEN-001 through TC-BEN-010: Election lifecycle and HRIS event integration ✓
- TC-BEN-011/012: Batch import dry-run and commit ✓
- TC-BEN-013/014/015: Payroll consumption of pre-tax, post-tax, employer contribution ✓
- TC-BEN-016/017: Suspended and expired elections not consumed ✓

**Manually verified:**
- Create 401k deduction code (PRE_TAX); create health insurance (POST_TAX)
- Enter elections for a test employee
- Run payroll — deductions appear on correct result lines
- Terminate employee — elections terminated automatically

---

## Phase 6 — Time & Attendance (Minimum)

**Goal:** Employees can submit time, managers can approve it, overtime is correctly detected, and approved time flows into payroll calculation.

**Spec:** `SPEC/Time_Attendance_Minimum_Module`
**Project:** `AllWorkHRIS.Module.TimeAttendance` (new class library)

### Deliverables
- Module project setup — references `AllWorkHRIS.Core` only
- `TimeEntry`, `TimeEntryStatus`, `TimeCategory` domain types
- `ITimeEntryRepository`, `IWorkScheduleRepository`
- `ITimeEntryService` — submit/approve/reject/correct lifecycle
- `IOvertimeDetectionService` — FLSA 40-hour threshold, reclassification from most-recent entries first
- `IPayrollHandoffService` — lock entries and record `PayrollRunId`
- HRIS event handlers registered in `TimeAttendanceModule.Register`:
  - Termination → close open entries
  - Leave → suppress time entry requirement
  - ReturnToWork → resume time entry requirement
- `TimeAttendanceModule` registration and menu contributions
- UI: My Timecard, Timecards, Timecard Detail, Payroll Handoff pages

### Gate — TC-TA test cases
- TC-TA-001 through TC-TA-006: Time entry lifecycle ✓
- TC-TA-007/008: FLSA overtime — non-exempt and exempt ✓
- TC-TA-009/010: Payroll handoff — delivered and not redelivered ✓
- TC-TA-011/012: Locked entry correction with retroactive flag ✓
- TC-TA-018: Overtime reclassification from most-recent entries first ✓

**Manually verified:**
- Employee submits 45 hours in a workweek
- Manager approves — 5 hours reclassified to OVERTIME
- Run payroll — REGULAR and OVERTIME result lines generated correctly

---

## Phase 7 — Reporting (Minimum)

**Goal:** All 16 pre-built operational reports are accessible, filterable, and exportable in CSV, XLSX, and PDF formats. Report execution history is recorded and queryable.

**Spec:** `SPEC/Reporting_Minimum_Module` (v0.2)
**Project:** `AllWorkHRIS.Module.Reporting` (new class library)
**NuGet packages:** `ClosedXML`, `QuestPDF`

### Deliverables
- Module project setup — references `AllWorkHRIS.Core` only
- `ReportExecutionHistory` domain type
- All 16 report query classes (8 payroll + 8 HR) per SPEC §7
- `IReportHistoryRepository` / `ReportHistoryRepository`
- `CsvExporter` (no library), `XlsxExporter` (ClosedXML), `PdfExporter` (QuestPDF) per SPEC §6
- `IReportService` (v0.2 — includes `GetRecentExecutionsAsync`, `ReRunAsync`), `IReportExportService` (v0.2 — `ExportResult` return type, `ReDownloadAsync`), `IScheduledReportService`
- `ReportingModule` registration and menu contributions
- UI: Payroll Reports hub, HR Reports hub, `ReportRunner` shared component, `ReportHistoryGrid`, all 16 individual report pages, Scheduled Reports page

### Gate — TC-RPT test cases
- TC-RPT-001: PAY-RPT-001 returns correct data for completed run ✓
- TC-RPT-002: Historical report respects as-of date and Temporal Override ✓
- TC-RPT-003: Unauthorised access rejected ✓
- TC-RPT-005: Manager scope enforced — direct reports only ✓
- TC-RPT-007/008/009: All three export formats download correctly ✓
- TC-RPT-010: All exports audit logged ✓
- TC-RPT-015: Scope filter bypass rejected ✓
- TC-RPT-019/020/021: Execution history created, completed, and failed correctly ✓
- TC-RPT-022/023: XLSX retained; CSV not retained ✓
- TC-RPT-027/028: History grid and auditor access ✓

**Manually verified:**
- Run PAY-RPT-001 for completed run — register matches Phase 4 pay register
- Export as XLSX — freeze panes, currency formatting, totals row correct
- Export as PDF — landscape, header block, page numbers correct
- Re-run from history — new execution created with same parameters
- Run HR-RPT-001 as Manager — only direct reports visible

---

## Phase 8 — Hardening

**Goal:** The platform is production-ready. All test cases pass. Security audit complete. Performance validated at target scale.

### Deliverables

**8.1 — Full automated test suite**
- All TC-HST, TC-HRS, TC-LEV, TC-DOC, TC-PAY, TC-BEN, TC-TA, TC-RPT test cases implemented as xUnit integration tests
- Integration tests run against real PostgreSQL instance using `Respawn` for database reset between tests
- All 165 test cases passing in CI

**8.2 — Security hardening**
- OIDC token validation verified per provider
- All sensitive endpoints confirm role enforcement at service layer (not only UI layer)
- SSN / national identifier encryption at rest implemented
- Download audit logging verified for all document access paths
- `TenantScopedConnection` wrapper (ADR-010 Option 2) tested exhaustively for cross-tenant isolation
- `tenant_id` claim validated on every request; missing claim returns 401

**8.3 — Multi-tenant configuration store**
- `tenants` table in platform management database
- `TenantRegistry` reads from database rather than environment config
- All three isolation models (ADR-010) tested with switching between Option 1 and Option 2

**8.4 — Performance validation**
- 250-employee payroll run completes in under 60 seconds
- Employee List page loads in under 2 seconds with 250 employees
- Pay Register grid renders 250 rows without timeout

**8.5 — Deployment documentation**
- On-premises deployment guide (PostgreSQL + Keycloak)
- Environment variable reference
- Module deployment procedure (drop DLL into `./modules`, restart)
- Schema migration procedure (per-module schema files, apply in order)

### Gate
- All 165 TC-* test cases passing in CI
- No open P1 or P2 security findings
- 250-employee end-to-end run (Hire → Time → Payroll → Reports) completes cleanly
- On-premises deployment guide validated against a clean machine

---

## NuGet Package Reference

| Package | Version | Phase Introduced | Project |
|---|---|---|---|
| `Autofac` | Latest stable | 1 | Core, Host, all modules |
| `Autofac.Extensions.DependencyInjection` | Latest stable | 1 | Host |
| `Dapper` | Latest stable | 1 | Core, all modules |
| `Npgsql` | Latest stable | 1 | Core |
| `Microsoft.Data.SqlClient` | Latest stable | 1 | Core (portability) |
| `MySql.Data` | Latest stable | 1 | Core (portability) |
| `Syncfusion.Blazor` | 33.1.44 | 1 | Host |
| `Microsoft.AspNetCore.Authentication.OpenIdConnect` | Latest stable | 1 | Host |
| `ClosedXML` | Latest stable | 7 | Reporting module |
| `QuestPDF` | Latest stable | 7 | Reporting module |
| `xunit` | Latest stable | 1 | Test project |
| `Respawn` | Latest stable | 8 | Test project (database reset between tests) |
