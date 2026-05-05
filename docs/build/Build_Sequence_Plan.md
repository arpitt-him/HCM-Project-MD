# AllWorkHRIS — Build Sequence Plan

| Field | Detail |
|---|---|
| **Document Type** | Build Planning |
| **Version** | v1.0 |
| **Status** | Active |
| **Owner** | Core Platform |
| **Location** | `docs/build/Build_Sequence_Plan.md` |
| **Date** | May 2026 |
| **Related Documents** | ADR-009_Authentication_Identity_Strategy, ADR-010_Tenant_Isolation_Strategy, ADR-011_Module_Independence_Principle, SPEC/Host_Application_Shell, SPEC/HRIS_Core_Module, SPEC/HRIS_Leave_and_Absence, SPEC/HRIS_Document_Management, SPEC/Payroll_Core_Module, SPEC/Payroll_Calculation_Pipeline, SPEC/Benefits_Minimum_Module, SPEC/Time_Attendance_Minimum_Module, SPEC/Reporting_Minimum_Module |

---

## Purpose

Defines the sequenced build order for the AllWorkHRIS platform. Each phase has a clear completion gate — a working, runnable state that proves the foundation before the next phase builds on it. No phase begins until its predecessor's gate is passed.

The sequence is designed so that after Phase 2, a minimum working HRIS application exists that each subsequent module can be developed from. Phase 2 ends with a formal HRIS Standalone Test that proves the HRIS module operates correctly with no other modules present — no Payroll schema, no Payroll module, no cross-module dependencies.

---

## Implementation Notes (v0.5)

The following decisions were made during implementation and differ from the original v0.4 plan:

**Project naming:** The Blazor Server host project is named `AllWorkHRIS.Host`, not `AllWorkHRIS.Web` as originally specified. All namespaces follow `AllWorkHRIS.Host.*` accordingly.

**HRIS namespace structure:** HRIS code is organised module-first rather than layer-first. Namespaces are `AllWorkHRIS.Host.Hris.Domain`, `AllWorkHRIS.Host.Hris.Repositories`, `AllWorkHRIS.Host.Hris.Services`, etc. This supports future module addition more cleanly than the layer-first approach in v0.4.

**Blazor render mode:** All HRIS pages require `@rendermode InteractiveServer` to enable event handling. This is a .NET 9 Blazor requirement that was not reflected in the original spec.

**ITemporalContext:** Added to `AllWorkHRIS.Core/Temporal/` as a prerequisite for effective-date resolution in services and repositories. Registered as `SystemTemporalContext` singleton in `Program.cs`.

**employee_event table:** The `employee_event` table was absent from the original schema. Added to `hcm_hris.dbml` and regenerated during Phase 2.

**Keycloak role mapping:** Realm roles must be explicitly mapped to the ID token via a User Realm Role mapper in the Keycloak client scope. The claim name must be `roles` to match the `RoleClaimType` setting in `Program.cs`. Additionally, `HrisViewer` must be assigned to admin users in addition to `HrisAdmin` — the two roles are not hierarchical in the current implementation.

**NavMenu role checking:** `IsInRole()` does not work reliably with Keycloak realm roles when `MapInboundClaims = false`. Role checks in `NavMenu.razor` use direct claim inspection (`Claims.Any(c => c.Type == "roles" && c.Value == role)`) instead.

**PostgreSQL enum mapping:** Dapper does not automatically map PostgreSQL enum types to C# enums. The `GlobalTypeMapper` API was removed in Npgsql 8+. The implemented solution casts enum columns to `::text` on reads in SQL queries and passes string values on writes with PostgreSQL type casts (e.g. `@Status::employment_status`). C# enum properties on domain records are populated via `Enum.Parse<T>()` in factory methods. This is a known interim approach — see **Known Issue: PostgreSQL enum portability** below.

**DateOnly parameter binding:** Dapper/Npgsql does not natively support `DateOnly` as a query parameter. All `DateOnly` values passed as Dapper parameters must be converted to `DateTime` using `.ToDateTime(TimeOnly.MinValue)`.

**OrgUnitType enum-to-string mapping:** PostgreSQL enum values use snake_case (e.g. `LEGAL_ENTITY`, `BUSINESS_UNIT`) while C# enum names are PascalCase (e.g. `LegalEntity`, `BusinessUnit`). A `ToDbEnum()` helper method is required in `OrgUnitRepository` to produce the correct PostgreSQL string value.

**Reference data seed scripts:** Seed scripts are at `schemas/seed-data/postgres/dev/`. Run `hris_lookups_seed_data.sql`, then `hris_initial_org_seed_data.sql`, then `hris_seed_documents.sql` in order against `allworkhris_dev` before Phase 2/3 gate testing.

**`ILookupCache` singleton:** A `LookupCache` implementation loads all `lkp_*` tables at startup into a `ConcurrentDictionary`. Provides `GetId(table, code)`, `GetCode(table, id)`, `GetAll(table)`, and `GetLabel(table, id)` methods. Registered as `SingleInstance` in `Program.cs`. `LookupTables` is a static class of string constants for table names (e.g. `LookupTables.EmploymentType`). All HRIS services and the hire panel use the cache to resolve lookup IDs and labels without per-request DB round-trips.

**`org_unit.legal_entity_id` schema addition:** A `legal_entity_id UUID` column was added to the `org_unit` table during Phase 2. For `LEGAL_ENTITY`-type org units the column is self-referential (`legal_entity_id = org_unit_id`). For all other types it records the ID of the owning legal entity. This enables filtering the org hierarchy tree by legal entity context. Applied to `allworkhris_dev` via migration script; existing rows backfilled. `CreateOrgUnitAsync` enforces this: non-LEGAL_ENTITY types require a `LegalEntityId` parameter; LEGAL_ENTITY types set it to their own new `org_unit_id`.

**Salary removed from employee grid:** `EmploymentListItem` does not include compensation fields (`BaseRate`, `RateType`, `PayFrequency`). Salary-level data is not appropriate for grid-level exposure where values are visible in comparison. `LocationName` was added in place — sourced via `LEFT JOIN org_unit l ON l.org_unit_id = a.location_id`. TC-HRS-014/015 (salary column role-gating) are superseded by this decision.

**Npgsql nullable `Guid` parameter:** The pattern `@param IS NULL OR col = @param` fails with Npgsql type inference when the parameter value is null. Repository methods that accept optional `Guid?` filters must use conditional SQL branches (`if (param.HasValue) { const string sql = "... WHERE col = @Param"; } else { const string sql = "... (no filter)"; }`) rather than a single parameterised `IS NULL OR` clause.

**Location dimension separated from org hierarchy tree:** `OrgUnit` rows of type `LOCATION` are not rendered in the org hierarchy tree on `OrgPage.razor`. They are displayed as a separate flat "Locations" panel below the tree. Location is a physical dimension orthogonal to the organisational hierarchy (Division → Department). A single department can have employees at multiple locations; adding locations to the hierarchy tree would require duplicating department nodes, which is wrong. The `assignment` table already captures both dimensions independently via `department_id` and `location_id`.

**`--check-db` early-exit handler:** `Program.cs` checks `args.Contains("--check-db")` immediately after `app.Build()`. If present it opens a DB connection, prints a result, and calls `return` (or `Environment.Exit(1)` on failure) before `app.Run()`. Without this handler `dotnet run -- --check-db` starts the full web server indefinitely, locking the compiled exe and blocking subsequent builds.

**Org hierarchy tree auto-expand:** On `OrgPage.razor`, `SelectLegalEntityAsync` adds all org units (excluding LOCATION type) to `_expanded` on load, so the full hierarchy is visible immediately. Individual branches can be collapsed manually. Clicking a node row also adds it to `_expanded` so its children become visible at the same time as the workforce panel is shown.

---

## Forward Impact Notes (v0.6)

The following implementation decisions made in Phases 0–2 have known forward impact on Phases 3–8:

**@rendermode InteractiveServer — all future UI pages:** Every Blazor page in every future module (Payroll, Benefits, T&A, Reporting) must declare `@rendermode InteractiveServer`. Child components embedded in a page inherit the render mode and must NOT declare it themselves. This requirement applies to all UI deliverables in Phases 3–7 and has been added to those phase descriptions below.

**DateOnly parameter binding — all future repositories:** All `DateOnly` values passed as Dapper parameters must be converted to `DateTime` using `.ToDateTime(TimeOnly.MinValue)`. This applies to every repository written in Phases 3–7 wherever date parameters appear in SQL queries.

**PostgreSQL enum snake_case mapping — all future repositories:** Any repository that queries a PostgreSQL enum column by value must use a `ToDbEnum()` style helper to convert C# PascalCase enum names to the correct snake_case PostgreSQL enum string. If the Phase 2.10 schema review resolves to `varchar` + CHECK constraints or code tables, this requirement is eliminated for Phase 3 onwards.

**Phase 2.10 schema review is a hard prerequisite for Phase 3:** Phase 3 adds new tables to the HRIS schema. If the decision is to switch to `varchar` + CHECK constraints, Phase 3 schema design must follow the new pattern. Phase 3 must not begin until Phase 2.10 is resolved.

**HRIS lives in AllWorkHRIS.Host — not a separate module assembly:** Phase 3 additions (leave, documents, onboarding) are added directly to `AllWorkHRIS.Host/Hris/`. The original v0.4 plan referenced `AllWorkHRIS.Module.Hris` for Phase 3; that reference is incorrect and has been updated in the Phase 3 description below.

**Phase 4+ module assemblies must not reference AllWorkHRIS.Host:** ADR-011 requires that module assemblies reference only `AllWorkHRIS.Core`. Since HRIS now lives in `AllWorkHRIS.Host`, this constraint is stronger than originally stated. `AllWorkHRIS.Module.Payroll`, `AllWorkHRIS.Module.Benefits`, `AllWorkHRIS.Module.TimeAttendance`, and `AllWorkHRIS.Module.Reporting` must not reference `AllWorkHRIS.Host` in any form. All cross-module communication must flow through `AllWorkHRIS.Core` event payloads and the `IEventPublisher` bus.

**Keycloak role assignments for future modules:** When Payroll, Benefits, T&A, and Reporting modules are added, the corresponding roles (`PayrollOperator`, `PayrollAdmin`, `BenefitsAdmin`, `TimeAdmin`, `ReportViewer`, `ReportAdmin`) must be assigned to test users in Keycloak before those modules' menu items will appear. The User Realm Role mapper configured in Phase 0.3 will automatically include any newly assigned roles — no Keycloak mapper reconfiguration is needed.

**NavMenu role filtering applies to all future module menu contributions:** All `MenuContribution` entries that specify `RequiredRole` will be filtered using direct claim inspection (`Claims.Any(c => c.Type == "roles" && c.Value == role)`). `IsInRole()` must not be used in any Blazor component in this platform.

**Lazy-load tab pattern — all future detail pages:** Multi-tab detail pages (Employee Detail, and future Payroll Run Detail, Benefits Election Detail, etc.) must use the lazy-load pattern established in `EmployeeDetail.razor`: a boolean `_*Loaded` guard per tab, a `SwitchTabAsync` dispatcher, and a dedicated `Load*Async` method per tab. This prevents unnecessary DB round-trips on page load and keeps initial render fast. The pattern also isolates tab-level errors without breaking adjacent tabs.

---

## Implementation Notes (v0.9)

The following decisions were made during Phase 4 implementation and are relevant to Phases 5–8:

**`IAuditService` / `NullAuditService` registration pattern:** `NullAuditService` is registered in Autofac before the module loop; `AuditService` (Host implementation) is registered after. Autofac last-registration-wins means all scoped resolutions in the live host receive the real `AuditService`, while module integration tests that build their own containers receive `NullAuditService` without any Host dependency. All new modules must accept `IAuditService` as a constructor parameter in any repository or service that performs write operations.

**`IHttpContextAccessor` null safety in Blazor Server:** After the initial SignalR circuit connection, `IHttpContextAccessor.HttpContext` is null in Blazor Server components. `AuditService` handles this with null-conditional operators throughout — actor fields fall back to `Guid.Empty` / null when no HTTP context is present. This is the correct and expected behaviour; do not attempt to store the HttpContext in a field.

**`[LoggerMessage]` source generator requirement:** The `.editorconfig` enforces `CA2254` as an error — interpolated strings and non-constant templates in `ILogger` calls are rejected at build time. Any service added in Phases 5–8 that logs inside a loop or hot path must use `[LoggerMessage]` partial methods. One-off informational calls outside loops may use named-placeholder templates directly.

**`PayrollRunJob` channel-per-test pattern:** Integration tests that exercise `PayrollRunJob` must create a fresh `Channel<Guid>`, write the target run ID, and call `channel.Writer.Complete()` before starting the job. The job's `ReadAllAsync` loop exits naturally when the channel is completed. Do not pass the same channel instance used by `PayrollRunService` — that channel is long-lived and would block the test.

**`BackgroundService.ExecuteTask` (net9.0):** The `ExecuteTask` property is public in .NET 9. Tests await `job.ExecuteTask!` after `StartAsync` to block until the job finishes naturally. This pattern is safe only when the channel is pre-completed before `StartAsync` is called.

**Autofac container in gate tests:** Gate tests that run `PayrollRunJob` build a minimal Autofac container per test. `ILogger<CalculationEngine>` must be registered as a specific typed instance (`NullLogger<CalculationEngine>.Instance`) because generic open registrations require `RegisterGeneric`. All repository types are `InstancePerLifetimeScope`; all singletons (`IConnectionFactory`, `IAuditService`, `ITemporalContext`, `ILogger<CalculationEngine>`) are `SingleInstance`.

**Period ID hygiene in payroll gate tests:** Each gate test that initiates a `PayrollRun` must use a distinct `period_id` with no pre-existing non-terminal runs. The `HasOpenRunForPeriodAsync` guard treats DRAFT, OPEN, CALCULATING, CALCULATED, UNDER_REVIEW, APPROVED, and RELEASING as "open" (only CLOSED, CANCELLED, FAILED are terminal). Gate tests that leave runs in the DB between sessions will cause false-positive failures in TC-PAY-001/002.

**ANSI-only SQL for new tables:** Migration `007_platform_audit_event.sql` uses only ANSI SQL syntax (no PostgreSQL-specific constructs). All future migrations must follow this constraint per the portability requirement in ADR-004.

---

## Known Issues

**Known Issue: PostgreSQL enum portability (logged Phase 2.9)**
The HRIS schema uses PostgreSQL native enum types throughout. SQL Server and MySQL do not support equivalent named enum types. When DDL is generated for non-PostgreSQL targets, enum columns will require a different approach (CHECK constraints or code tables). ADR-004 requires DBMS portability. The current schema is not portable as-is. Options to be discussed in Phase 2.9 before Phase 3 begins: (1) replace PostgreSQL enums with `varchar` + CHECK constraints, (2) replace with code tables. Development is proceeding on PostgreSQL only pending this decision.

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
| 2.9 | Schema Review | HRIS schema (revised) | HRIS module only | PostgreSQL enum portability decision made; schema updated if required |
| 3 | HRIS Supporting | HRIS schema + leave_balance + legal_hold_flag | HRIS module only | Submit leave; upload document; onboarding plan created on hire |
| 4 | Payroll Core | HRIS + Payroll schemas | HRIS + Payroll modules | Initiate run; calculation completes; pay register renders — **Complete** |
| 5 | Tax Engine | HRIS + Payroll + Tax schemas | HRIS + Payroll + Tax modules | TC-TAX-001–019 pass; real tax withholding flows through payroll run — **Complete** |
| 6 | Benefits | HRIS + Payroll + Tax schemas | HRIS + Payroll + Tax + Benefits | Elections appear in payroll calculation; TC-PAY-007 passes — **Complete** |
| 6B | Benefits Calculation Model | +migrations 011/012 (deduction model + timing) | Benefits revamp | Multi-mode deductions, rate tables, employer match, timing alignment — **In Progress** |
| 7 | Dashboard & Navigation | No schema change | All existing modules | Dashboard renders role-filtered tasks; entity lock/unlock works; dynamic nav replaces static markup |
| 8 | Time & Attendance | HRIS + Payroll + Tax schemas | HRIS + Payroll + Tax + T&A | Approved time flows into payroll run |
| 9 | Pay Register Drilldown | No schema change | Payroll module | Year → Month → Run → Employee drilldown; accounting totals at each level |
| 10 | Accumulators Drilldown | No schema change | Payroll module | Year → Month → Employee drilldown by accumulator family; YTD balance progression |
| 11 | Reporting | HRIS + Payroll + Tax schemas | All modules | PAY-RPT-001 runs; XLSX export correct; HR-RPT-001 runs |
| 12 | Hardening | Full schema | All modules | All TC-* test cases passing; security audit complete |

Note: Phase 5 (Tax Engine) must precede Phase 6 (Benefits) because TC-PAY-007 (pre-tax deductions reduce taxable wages) requires both modules to be wired. Phase 6B extends Phase 6 with the full calculation model (rule-based modes, rate tables, employer match, timing alignment) and is a prerequisite for Phase 7. Phase 7 (Dashboard & Navigation) is a prerequisite for Phase 8 (T&A) — the dashboard must exist before T&A contributes tasks to it. Phases 9 and 10 (Pay Register and Accumulators drilldowns) require Phases 4–6B complete; they can be built independently of Phase 7. Phase 11 (Reporting) can begin once Phase 5 is complete. Phase 12 (Hardening) requires all of 1–11.

---

## Dependency Map

```
Phase 0 (Infrastructure)
    └── Phase 1 (Core + Host Shell)
            └── Phase 2 (HRIS Core)         ← Minimum Working Application
                    │                          ← HRIS Standalone Test gate
                    ├── Phase 2.9 (Schema Review)  ← Must complete before Phase 3
                    ├── Phase 3 (HRIS Supporting)
                    │       └── Phase 4 (Payroll Core)
                    │               └── Phase 5 (Tax Engine)
                    │                       ├── Phase 6 (Benefits)
                    │                       │       └── Phase 6B (Benefits Calc Model)
                    │                       │               └── Phase 7 (Dashboard & Navigation)
                    │                       │                       ├── Phase 8 (T&A)  ─┐
                    │                       │               │                    ├─ parallel
                    │                       │               └── Phase 9 (Reporting) ─┘
                    │                       │                       └── Phase 10 (Hardening)
                    └── Phase 4 can begin in parallel with Phase 3
```

---

## Phase 0 — Infrastructure

**Goal:** Local development environment is fully operational before a line of application code is written.

### Deliverables

**0.1 — PostgreSQL**
- Install PostgreSQL locally or via Docker:
  ```
  docker run -e POSTGRES_PASSWORD=dev -p 5432:5432 postgres:16
  ```
- Create development database: `allworkhris_dev`
- Apply HRIS schema only: `schemas/ddl/postgres/hris_schema.sql`
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
  - `admin@test.com` — roles: `HrisAdmin`, `HrisViewer`, `PayrollAdmin`, `ReportAdmin`
  - `hr@test.com` — roles: `HrisAdmin`, `HrisViewer`
  - `payroll@test.com` — roles: `PayrollOperator`, `PayrollAdmin`
  - `manager@test.com` — roles: `Manager`, `HrisViewer`
  - `employee@test.com` — roles: `Employee`
- Add `tenant_id` claim to token — value: `00000000-0000-0000-0000-000000000001` (dev tenant)
- **Add User Realm Role mapper** to the `allworkhris-app` client scope: Token Claim Name = `roles`, add to ID token, access token, and userinfo
- Note authority URL, client ID, and client secret for `launchSettings.json`

**0.4 — Solution scaffold**
- Create `AllWorkHRIS.sln`
- Create projects (empty, no code yet):
  - `src/AllWorkHRIS.Core` (class library)
  - `src/AllWorkHRIS.Host` (Blazor Server) ← named Host, not Web
  - `tests/AllWorkHRIS.Host.Tests` (xUnit)
- Add NuGet packages to `AllWorkHRIS.Core`:
  - `Autofac`
  - `Dapper`
  - `Npgsql` (v10+)
  - `Microsoft.Data.SqlClient`
  - `MySql.Data`
- Add NuGet packages to `AllWorkHRIS.Host`:
  - `Autofac.Extensions.DependencyInjection`
  - `Syncfusion.Blazor` (version 33.1.44)
  - `Microsoft.AspNetCore.Authentication.OpenIdConnect`

**0.5 — Environment configuration**
- Create `launchSettings.json` with all required environment variables:
  - `DATABASE_CONNECTION_STRING` = `Host=localhost;Database=allworkhris_dev;Username=postgres;Password=dev`
  - `DATABASE_PROVIDER` = `postgresql`
  - `APP_ENVIRONMENT` = `Development`
  - `AUTH_AUTHORITY` = `http://localhost:8080/realms/allworkhris`
  - `AUTH_CLIENT_ID` = `allworkhris-app`
  - `AUTH_CLIENT_SECRET` = (from Keycloak client configuration)
  - `TEMPORAL_OVERRIDE_ENABLED` = `true`

**0.6 — User-secret configuration**
- Store the `Syncfusion:LicenseKey` as a .NET user-secret for project `AllWorkHRIS.Host`

### Gate
- PostgreSQL starts and accepts connections
- HRIS schema (`hris_schema.sql`) applies without errors — `employment` table exists
- Payroll schema is NOT present — `payroll_run` table does not exist
- Keycloak starts and issues tokens for all five test users with roles claim present in token
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
3. `IConnectionFactory` interface and `ConnectionFactory` implementation — both in `IConnectionFactory.cs`
4. `IUnitOfWork` interface and `UnitOfWork` implementation — both in `IUnitOfWork.cs`
5. `IAuditableEntity` interface
6. `ClaimsPrincipalExtensions` — `GetTenantId()`, `GetEmploymentId()`, `GetDisplayName()`
7. `EnvironmentValidator` static class
8. `Events/IEventPublisher` interface — `PublishAsync<T>` and `RegisterHandler<T>`
9. `Events/InProcessEventBus` implementation — `ConcurrentDictionary`-backed; zero-subscriber no-op
10. `Temporal/ITemporalContext` interface and `SystemTemporalContext` implementation
11. All event payload types in `Events/`:
    - `HireEventPayload` — includes `EventId`, `LegalEntityId`, `FlsaStatus`
    - `RehireEventPayload` — includes `EventId`, `PriorEmploymentId`
    - `TerminationEventPayload` — includes `EventId`, `TerminationDate`, `EventType`, `ReasonCode`
    - `CompensationChangeEventPayload` — includes `EventId`, `NewBaseRate`, `PayFrequency`, `IsRetroactive`
    - `LeaveApprovedPayload`
    - `ReturnToWorkPayload`

**1.2 — AllWorkHRIS.Host**

Implement in order:
1. `Program.cs` — full startup sequence per `SPEC/Host_Application_Shell` §3:
   - Syncfusion license registration from user secrets via `builder.Configuration`
   - `EnvironmentValidator`
   - MEF module discovery (no modules yet — empty scan is correct)
   - Autofac container — `ConnectionFactory`, `InProcessEventBus`, `SystemTemporalContext` as singletons
   - Menu contributions singleton (empty list at this stage — HRIS items added in Phase 2.6)
   - Syncfusion services
   - Blazor Server with `AddRazorComponents().AddInteractiveServerComponents()`
   - OIDC authentication per ADR-009 — `MapInboundClaims = false`, `RequireHttpsMetadata = false` for dev
   - `TenantConnectionMiddleware` per ADR-010 (single dev tenant)
   - Middleware pipeline in correct order
   - `app.MapRazorComponents<App>().AddInteractiveServerRenderMode()` — .NET 9 style
2. `App.razor` — `AuthorizeRouteView` wrapping all routes
3. `_Host.cshtml` — standard Blazor Server host page (if applicable to project structure)
4. `MainLayout.razor` — dark sidebar + content area per SPEC §9
5. `NavMenu.razor` — renders menu contributions; role check uses direct claim inspection not `IsInRole()`
6. `TopBar.razor` — app display name + authenticated user name
7. `app.css` — full CSS design token set per SPEC §11
8. `Home.razor` — branded home page with icon, wordmark, tagline, welcome message (replaces `Index.razor`)
9. `Error.razor` — error boundary page

**1.3 — Tenant middleware**

Implement `TenantConnectionMiddleware` and `TenantRegistry` per ADR-010:
- Phase 1: single dev tenant resolved from `DATABASE_CONNECTION_STRING` environment variable
- Middleware reads `tenant_id` claim from JWT; unauthenticated requests pass through without tenant resolution
- `TenantRegistry` and `TenantConfig` defined in `AllWorkHRIS.Host` namespace

### Gate — TC-HST test cases
- TC-HST-001: Application starts with all required environment variables and user secrets set ✓
- TC-HST-002: Missing `Syncfusion:LicenseKey` user secret causes fail-fast ✓
- TC-HST-003: Missing `DATABASE_CONNECTION_STRING` causes fail-fast ✓
- TC-HST-008: Unauthenticated user redirected to OIDC login page ✓
- TC-HST-009: `DATABASE_PROVIDER = postgresql` returns `NpgsqlConnection` ✓
- TC-HST-015/016: `APP_DISPLAY_NAME` displays correctly ✓
- TC-HST-017: Unauthenticated access blocked ✓

**Manually verified:**
- Login with `admin@test.com` — shell renders with dark sidebar and top bar
- Branded home page renders with icon, wordmark, tagline, and welcome message
- CSS design tokens applied correctly

---

## Phase 2 — HRIS Core

**Goal:** A working HR administrator can hire an employee, view the employee list, and open the employee detail page. Phase 2 ends with the HRIS Standalone Test proving full module independence.

**Spec:** `SPEC/HRIS_Core_Module`
**Project:** `AllWorkHRIS.Host` — HRIS code lives directly in the host application
**Database:** HRIS schema already applied in Phase 0, with `employee_event` table added during this phase

### Deliverables

**2.1 — HRIS folder structure in AllWorkHRIS.Host**
- Create folder structure under `src/AllWorkHRIS.Host/Hris/`
- Module-first namespace organisation:
  - `AllWorkHRIS.Host.Hris.Domain`
  - `AllWorkHRIS.Host.Hris.Commands`
  - `AllWorkHRIS.Host.Hris.Queries`
  - `AllWorkHRIS.Host.Hris.Repositories`
  - `AllWorkHRIS.Host.Hris.Services`
- UI pages under `Components/Pages/Hris/`
- Shared UI components under `Components/Shared/`

**2.1a — Schema addition: employee_event table**
- Add `employee_event` table and `employee_event_type` enum to `hcm_hris.dbml`
- Regenerate `hris_schema.sql` and apply additive change to `allworkhris_dev`

**2.1b — Schema addition: org_unit.legal_entity_id**
- Add `legal_entity_id UUID` column to `org_unit` table
- For `LEGAL_ENTITY`-type rows: `legal_entity_id = org_unit_id` (self-referential)
- For all other types: `legal_entity_id` = the owning legal entity's `org_unit_id`
- Apply column addition and backfill existing rows to `allworkhris_dev`
- Enables legal-entity-scoped filtering of org units in the hierarchy view

**2.2 — Domain types**
All domain records as `sealed record` types with static factory methods:
- `Person` — `CreateNew(HireEmployeeCommand)`
- `PersonAddress`, `PersonEmergencyContact`
- `Employment` — `CreateFromHire(HireEmployeeCommand, Guid personId)`
- `Assignment` — `CreateInitial(HireEmployeeCommand, Guid employmentId)`
- `CompensationRecord` — `CreateInitial(HireEmployeeCommand, Guid employmentId)`
- `OrgUnit`, `Job`, `Position`
- `EmployeeEvent` — `CreateHire(...)`, `CreateTermination(...)`, `CreateCompensationChange(...)`
- All enums in `Enums.cs`

**2.3 — Commands**
All in `HrisCommands.cs`:
- `HireEmployeeCommand` — `PayrollContextId` is `Guid?` (nullable) per ADR-011
- `RehireEmployeeCommand`
- `TerminateEmployeeCommand`
- `ChangeCompensationCommand`
- `UpdatePersonCommand`
- `ChangeManagerCommand`
- `TransferEmployeeCommand`

**2.4 — Query types**
In `HrisQueryTypes.cs`:
- `PagedResult<T>`
- `EmployeeListQuery`
- `EmploymentListItem` — fields: `EmploymentId`, `PersonId`, `LegalFirstName`, `LegalLastName`, `PreferredName`, `EmployeeNumber`, `EmploymentStatus`, `EmploymentType`, `EmploymentStartDate`, `JobTitle`, `DepartmentName`, `LocationName`; no compensation fields (salary not exposed at list level)
- `HireResult`
- `EmployeeStatCards`
- `OrgUnitEmployee` — workforce panel read model; fields: `EmploymentId`, `PersonId`, `EmployeeNumber`, `LegalFirstName`, `LegalLastName`, `PreferredName`, `JobTitle`, `FullPartTime`, `FlsaStatus`, `AnnualEquivalent`, `RateType`, `PayFrequency`, `DepartmentName`, `EmploymentStartDate`

**2.5 — Repositories**
All in `HrisRepositories.cs`. Key implementation notes:
- All `DateOnly` values passed as Dapper parameters must use `.ToDateTime(TimeOnly.MinValue)`
- PostgreSQL enum writes use type cast syntax: `@Status::employment_status`
- PostgreSQL enum reads cast to `::text` for Dapper string mapping
- `OrgUnitRepository` includes `ToDbEnum(OrgUnitType)` helper for snake_case conversion

Repositories:
- `IPersonRepository` / `PersonRepository`
- `IEmploymentRepository` / `EmploymentRepository` — includes `GetPagedListAsync` (with location join, no compensation join), `GetStatCardsAsync`, `GetActiveByLegalEntityAsync`
- `IAssignmentRepository` / `AssignmentRepository`
- `ICompensationRepository` / `CompensationRepository`
- `IOrgUnitRepository` / `OrgUnitRepository` — includes `GetByTypeAsync`, `GetAllActiveAsync(Guid? legalEntityId = null)` (conditional SQL branches for nullable Guid), `GetWorkforceByOrgUnitAsync(Guid orgUnitId)` (recursive CTE spanning employment/person/assignment/job/compensation tables)
- `IJobRepository` / `JobRepository` — includes `GetByLegalEntityAsync(Guid legalEntityId)` for entity-scoped job lists; `GetAllActiveAsync()` retained for admin use only
- `IPositionRepository` / `PositionRepository`
- `IEmployeeEventRepository` / `EmployeeEventRepository` — events are immutable; `UpdateStatusAsync` throws `NotSupportedException`

**2.6 — Services**
All in `HrisServices.cs`. Includes `DomainException` and `ValidationException`:
- `IPersonService` / `PersonService`
- `IEmploymentService` / `EmploymentService` — `HireEmployeeAsync` atomic pattern; publishes `HireEventPayload` after commit; includes `GetPagedListAsync` and `GetStatCardsAsync`
- `ILifecycleEventService` / `LifecycleEventService` — approve/reject deferred to Phase 3
- `ICompensationService` / `CompensationService`
- `IOrgStructureService` / `OrgStructureService` — methods: `GetOrgUnitByIdAsync`, `GetLegalEntitiesAsync`, `GetDepartmentsAsync`, `GetLocationsAsync`, `GetChildrenAsync`, `GetAllActiveAsync(Guid? legalEntityId)`, `GetOrgUnitWorkforceAsync(Guid orgUnitId)`, `CreateOrgUnitAsync`; constructor resolves and caches `_legalEntityTypeId`, `_departmentTypeId`, `_locationTypeId`, `_activeStatusId` from `ILookupCache`; `CreateOrgUnitAsync` enforces legal entity context for non-LEGAL_ENTITY types and sets self-referential `legal_entity_id` for LEGAL_ENTITY types
- `ILookupCache` / `LookupCache` — singleton; loads all `lkp_*` tables at startup

**2.7 — Register HRIS services in Program.cs**
- Add all HRIS repository and service registrations to Autofac container as `InstancePerLifetimeScope`
- `ILookupCache` / `LookupCache` registered as `SingleInstance` — loaded once at startup
- `IConnectionFactory` / `ConnectionFactory` registered as `SingleInstance`
- Add HRIS menu contributions as a fixed list (Employees parent + Employees, Organisation, Jobs & Positions children)
- Menu items use direct claim check for role gating — not `RequiredRole` + `IsInRole()`
- `SystemTemporalContext` registered as `ITemporalContext` singleton
- `--check-db` early-exit handler after `app.Build()` — opens connection, prints result, exits; prevents orphaned server processes from locking the exe during development rebuilds

**2.8 — UI components**
All pages require `@rendermode InteractiveServer`:
- `Components/Shared/DateRangeFilter.razor` — platform-wide reusable date range filter per ADR-006
- `Components/Pages/Hris/EmployeeList.razor` — stat cards (Active, On Leave, Contractors, Departments), employee table (Name, Job Title, Department, Location, Status, Start Date, View link), empty state, "+ Add Employee" button (HrisAdmin only); no salary column
- `Components/Pages/Hris/EmployeeDetail.razor` — tabbed: Profile, Employment, Assignment, Compensation, Leave, Documents, Onboarding, History. Each data-heavy tab (Assignment, Leave, Documents, Onboarding) is lazy-loaded on first switch via `SwitchTabAsync` — a boolean `_*Loaded` guard prevents repeat fetches. Assignment tab resolves job title + code (`IJobRepository.GetByIdAsync`), department and location names (`IOrgStructureService.GetOrgUnitByIdAsync`), and manager name (`IPersonService.GetByEmploymentIdAsync` via `Employment.ManagerEmploymentId`). History tab is a placeholder — lifecycle event display is deferred to Phase 8 Hardening once the full event model is complete.
- `Components/Pages/Hris/OrgPage.razor` — legal entity context selector (tabs for ≤8 entities; searchable scrollable list for >8); Hierarchy / List view toggle; hierarchy tree auto-expands all nodes on load, collapses manually; LOCATION-type units shown in a separate "Locations" panel below the tree (not in the hierarchy); clicking a node row selects it and expands its children; workforce composition panel appears on node selection showing summary cards (headcount, FT/PT split, FLSA exempt*/non-exempt count, total annualized cost) and employee table (name, #, job title, department, FT/PT badge, FLSA badge, annual cost); FLSA exempt count matches all codes beginning with `EXEMPT`
- `Components/Pages/Hris/HireEmployeePanel.razor` — 6-step hire form: Step 1 Identity, Step 2 Contact (phone, personal email, full address), Step 3 Employment (legal entity, employee number, type, start date, FLSA, FT/PT), Step 4 Assignment (job, department, location, manager), Step 5 Compensation (rate type, base rate, pay frequency, change reason), Step 6 Review; `@rendermode` not declared on component — inherits from parent page
- `Components/Pages/Hris/JobsPage.razor` — two sections: Jobs and Positions. Both sections are scoped to the legal entity selected in the HRIS shell header. Stat cards for Active Jobs and Active Positions (entity-scoped). Jobs table: Code, Title, Family, Level, FLSA Classification, EEO Category, Effective Date. HrisAdmin "+ Add Job" form (Code, Title, Family, Level, FLSA Classification, EEO Category, Effective Date; Legal_Entity_ID defaults to selected entity and is not user-editable). Positions table: Job, Department, Position Title, Headcount Budget, Status badge, Effective Date. HrisAdmin "+ Add Position" form (Job dropdown populated from the selected entity's jobs only; Department dropdown scoped to selected entity's org units; optional title and headcount budget, Effective Date; disabled until at least one job exists for the selected entity). Service layer: `IJobService`/`JobService` and `IPositionService`/`PositionService` added to `HrisServices.cs`; `CreateJobCommand`/`CreatePositionCommand` added to `HrisCommands.cs`; `IPositionRepository.GetAllActiveAsync()` added; both services registered in `Program.cs`.
  - **Schema change required:** `job` table must have `legal_entity_id UUID NOT NULL` column added via migration. Existing job rows must be assigned to the appropriate legal entity as part of migration. The column carries a foreign key to `org_unit` where `org_unit_type_id` corresponds to `LEGAL_ENTITY`.

**2.9 — Reference data seed**
- Seed scripts live under `schemas/seed-data/postgres/dev/` (reorganised from original `schemas/seed/`)
- `hris_lookups_seed_data.sql` — all lookup tables (document types, leave types, onboarding task types, etc.)
- `hris_initial_org_seed_data.sql` — 1 legal entity, 1 division, 1 department, 1 location, 3 jobs (each carrying the seeded legal entity's ID), 5 employees
- `hris_seed_documents.sql` — 10 sample HR documents with mixed expiration dates for testing Document Expiration Report
- Run all three in order against `allworkhris_dev` before gate testing

**2.10 — Schema review (enum portability)**
- Discuss and decide: PostgreSQL native enums vs `varchar` + CHECK constraints vs code tables
- Decision must be made before Phase 3 begins schema additions
- See Known Issue above

**2.11 — Permission schema design (prerequisite for Phase 4)**
- Design and apply the `platform_role`, `platform_permission`, `role_permission`, and `role_assignment` tables
- The current implementation uses Keycloak realm roles as the sole authorization mechanism (coarse access gate only)
- The spec (`Role_and_Permission_Model.md`, `Security_and_Access_Control_Model.md`) requires a two-layer model:
  - **Layer 1 (implemented):** Keycloak realm roles — controls module-level access (HrisAdmin, HrisViewer, etc.)
  - **Layer 2 (not yet built):** Platform permission model — controls discrete capabilities within a module (view SSN, approve leave, export documents, etc.) scoped to Tenant / Legal Entity / Department
- An `IPlatformAuthorizationService` must be designed to evaluate whether the current user holds a given permission within a given scope; enforcement at the service layer, not just UI
- Role Assignments must be effective-dated (Effective_Start_Date, Effective_End_Date) and fully auditable
- Custom/tenant-configurable roles (Custom_Role_Flag) must be supported for PEO deployments
- **This schema must be designed before Phase 4 begins** — payroll scope-based access (PayrollAdmin scoped to one legal entity) depends on it; implementing it post-Phase 4 requires retrofitting all payroll role checks
- UI for role assignment management deferred to Phase 10 Hardening; schema and service layer must be in place earlier

### Gate — TC-HRS test cases
- TC-HRS-001: Hire command creates Person, Employment, Assignment, Compensation, Event atomically
- TC-HRS-002: Duplicate employee number throws DomainException
- TC-HRS-003: Missing required field throws ValidationException
- TC-HRS-013: Employee List renders with correct stat cards
- TC-HRS-014: ~~Salary column visible to HrisAdmin~~ — superseded; salary is not present in the employee grid at any role level (removed as sensitive data)
- TC-HRS-015: ~~Salary column hidden from HrisViewer~~ — superseded; see TC-HRS-014 note
- TC-HRS-016: Employee List shows Location column populated from assignment location_id
- TC-HRS-017/018: Add Employee button role-gated correctly
- TC-HRS-019: 6-step hire form submits successfully; all fields persisted correctly
- TC-HRS-024: Hire with PayrollContextId = null succeeds
- TC-HRS-025: HireEventPayload published with no subscribers — no exception
- TC-HRS-026: HRIS module starts with no other modules present — application functional
- TC-HRS-027: Org hierarchy tree loads scoped to selected legal entity; LOCATION-type units absent from tree, shown in separate Locations panel
- TC-HRS-028: Clicking org node shows workforce panel with correct headcount, FT/PT split, and FLSA exempt count (all EXEMPT* codes included)
- TC-HRS-029: `/hris/jobs` renders without 404; active jobs table displays with correct FLSA Classification and EEO Category labels scoped to the selected legal entity
- TC-HRS-030: Assignment tab on Employee Detail displays active assignment with correct job title, department, location, and manager name resolved from FK IDs
- TC-HRS-031: HrisAdmin can create a new job from `/hris/jobs`; job appears in table immediately with correct FLSA and EEO labels; Active Jobs stat card increments; job is persisted with the selected legal entity's ID
- TC-HRS-032: HrisAdmin can create a new position from `/hris/jobs`; position appears in Positions table with correct job name, department, status badge, and headcount; Active Positions stat card increments; position's job picker shows only jobs belonging to the selected legal entity
- TC-HRS-033: Switching legal entity in the HRIS shell header causes Jobs and Positions tables to reload showing only that entity's records; a job created under Entity A does not appear when Entity B is selected
- TC-HRS-034: Attempting to create a position with a Job belonging to a different legal entity than the selected Org Unit is rejected with a validation error at the service layer

### HRIS Standalone Test (mandatory gate — proves ADR-011 compliance)

All 8 steps must pass before Phase 2 is considered complete:

1. Confirm `payroll_run` table does NOT exist in `allworkhris_dev`
2. Confirm `./modules` folder is empty — no plug-in module DLLs present
3. Start the application — verify it starts without errors
4. Authenticate as `admin@test.com` — verify shell renders; only HRIS menu items present
5. Hire a new employee with `PayrollContextId` left blank/null — verify hire succeeds
6. Verify Person, Employment, Assignment, CompensationRecord, and EmployeeEvent records created in the database
7. Verify `HireEventPayload` was published — no exception raised despite zero subscribers
8. Verify the hired employee appears in the Employee List with correct columns

All 8 steps passing = HRIS module independence confirmed. Phase 2 complete.

---

## Phase 3 — HRIS Supporting Features

**Goal:** Leave management, document upload, and onboarding workflow are operational within the HRIS module. The application is now a complete minimum HRIS suitable for client use.

**Specs:** `SPEC/HRIS_Leave_and_Absence`, `SPEC/HRIS_Document_Management`, `SPEC/Onboarding_Workflow`
**Project:** Additions to `AllWorkHRIS.Host/Hris/`
**Database:** HRIS schema only — two additive changes
**Status:** Complete — all UI deliverables built and verified.

**Completed deliverables:**
- 3.1 Schema additions applied (leave_balance, legal_hold_flag, document_download_audit)
- 3.2 Leave service layer complete; Leave tab on EmployeeDetail (submit) complete
- 3.3 Document service layer + DocumentExpirationCheckJob complete; Documents tab on EmployeeDetail (upload) complete
- 3.4 Onboarding service layer complete; Onboarding tab on EmployeeDetail complete
- 27 Phase 3 integration tests passing
- Work Queue page (`/hris/workqueue`) — leave approvals (2-step approve/deny), document expiration alerts, onboarding tasks; employee name column with name filter + due-date range filter; batch name lookup via `= ANY(@Ids)` (Npgsql pattern); `IPersonService.GetNamesByEmploymentIdsAsync` added
- Document Expiration Report page (`/hris/documents/expiring`) — stat cards (Expired / ≤30 days / 31–90 days); filters by employee name, document type, and status bucket; color-coded expiration dates and badges; download link per row; `IPersonService.GetNamesByPersonIdsAsync` added for person-level docs

**Deferred to later phase:**
- Integration tests TC-LEV, TC-DOC, TC-ONB — not yet written

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
- TC-LEV-001 through TC-LEV-007: Leave request lifecycle
- TC-LEV-012/013: Event publication timing (after commit, not on rollback)
- TC-DOC-001/002: Document upload and supersession
- TC-DOC-005/006/007/008: I-9 verification gate
- TC-DOC-012/013: Download audit logging enforced

**Manually verified:**
- Submit PTO request — approve as manager — balance deducted
- Upload I-9 — verify it — employment activation gated correctly
- Hire new employee — onboarding plan created automatically with blocking tasks

---

## Phase 4 — Payroll Core

**Goal:** A payroll operator can initiate a regular payroll run for employees hired in Phases 2/3, watch it calculate in real time, review the pay register, and approve the run.

**Spec:** `SPEC/Payroll_Core_Module`
**Project:** `AllWorkHRIS.Module.Payroll` (new class library)
**Status:** Complete — all deliverables 4.0–4.12 built and 90 tests passing as of 2026-05-01. TC-PAY-005/006/007/012 deferred to Phase 10 Hardening (fault injection, accumulator atomicity, pre-tax math stubs, UI/SignalR progress).

### Deliverables

**4.0 — Apply Payroll schema ✓ COMPLETE**
- Applied `schemas/ddl/postgres/payroll_core_schema.sql` to `allworkhris_dev` — `payroll_run` table exists
- Applied `schemas/ddl/postgres/payroll_lookups_schema.sql` to `allworkhris_dev` — all 24 `lkp_*` payroll lookup tables created
- Seed data: `schemas/seed-data/postgres/dev/payroll_lookups_seed_data.sql` — all 24 lookup tables seeded in dependency order (`lkp_result_class` first; `lkp_impact_source_type` and `lkp_accumulator_family` use subquery FKs to resolve `result_class_id`)
- HRIS tables unaffected — verified

**4.1 — Module project setup ✓ COMPLETE**
- `AllWorkHRIS.Module.Payroll` class library created and added to solution
- References `AllWorkHRIS.Core` only — no Host reference (ADR-011 compliant)
- NuGet: Autofac 9.1.0, Dapper 2.1.72, Npgsql 10.0.2, System.Composition, Microsoft.Extensions.Hosting.Abstractions
- Full folder structure created per SPEC §1: `Domain/{Run,ResultSet,Results,Accumulators,Calendar,Events}`, `Commands`, `Repositories`, `Services`, `Jobs`
- All domain types written (PayrollRun, PayrollRunResultSet, EmployeePayrollResult, all result line types, AccumulatorDefinition/Impact/Contribution/Balance, PayrollContext, PayrollPeriod)
- All command records written (Initiate, Approve, Release, Cancel)
- All repository interfaces written (IPayrollRunRepository, IPayrollRunResultSetRepository, IEmployeePayrollResultRepository, IResultLineRepository, IAccumulatorRepository, IPayrollContextRepository)
- All service interfaces written (IPayrollRunService, ICalculationEngine, IAccumulatorService, IPayrollEventSubscriber)
- Event handler stubs written (HireEventHandler, TerminationEventHandler, CompensationChangeHandler, LeaveApprovedHandler)
- PayrollEventSubscriber wires all four handlers on IEventPublisher
- PayrollRunJob (IHostedService + Channel&lt;Guid&gt; queue) stub written
- PayrollModule.cs with [Export] attribute, Register() with commented-out repo/service TODOs, and GetMenuContributions() (Payroll Runs, Pay Register, Accumulators)
- Solution builds clean (0 warnings, 0 errors)

**4.2 — Domain types ✓ COMPLETE**
All domain types delivered as part of 4.1 above.

**4.3 — HRIS event handlers ✓ COMPLETE (stubs)**
- `IPayrollEventSubscriber` / `PayrollEventSubscriber` written and registered
- Handler stubs written for Hire, Termination, CompensationChange, LeaveApproved events
- Concrete handler logic (payroll enrollment, final pay flagging, retro flagging, leave pay impact) is TODO — to be implemented in 4.4–4.5 alongside repositories and calculation engine

**4.4 — Repositories ✓ COMPLETE**
- All 6 repository interfaces implemented: `PayrollRunRepository`, `PayrollRunResultSetRepository`, `EmployeePayrollResultRepository`, `ResultLineRepository`, `AccumulatorRepository`, `PayrollContextRepository`
- `PayrollContext` and `PayrollPeriod` domain types updated to match full schema (delta DBML + SQL generated and applied)
- All registered in `PayrollModule`

**4.5 — Calculation Engine ✓ COMPLETE**
- `CalculationEngine` — full 9-step ordered pipeline; sub-calculators are stubs pending compensation/tax rules (Phase 4.6+)
- `AccumulatorService` — full 4-layer mutation chain (Impact → Contribution → Balance); `ReverseAsync` deferred to correction flow
- Both registered in `PayrollModule`
- `IPlatformModule` extended with `ModuleName`, `ModuleVersion`, `ModuleDescription` (default interface implementations — no breaking changes)
- `PayrollModule` overrides metadata explicitly
- Post-build target copies module DLL to `AllWorkHRIS.Host/modules/` automatically on every build
- `ModuleDiscovery` fixed to resolve absolute paths before `AssemblyLoadContext.LoadFromAssemblyPath`
- Framework-aligned package versions corrected to 9.x (`System.Composition`, `Microsoft.Extensions.Hosting.Abstractions`) to match Host runtime
- `PayrollModuleCompositionTests` — 4 tests: MEF discovery, Autofac wiring, menu contributions, metadata — all passing (31/31 suite)
- `/about` page added — lists loaded modules with name, version, description, menu item count — verified working

**4.6 — Run Service and Background Job ✓ COMPLETE**
- `IPayrollRunService` / `PayrollRunService` — `InitiateRunAsync` pattern per SPEC §6
- `PayrollRunJob` — `IHostedService` with `Channel<Guid>` queue per SPEC §7
- `RunProgressNotifier` singleton + SignalR hub for real-time progress updates

**4.7 — PayrollModule registration ✓ COMPLETE**
- `PayrollModule` implementing `IPlatformModule`
- `Register` — all repositories, services, HRIS event handler registrations
- `PayrollContextLookup` registered as `IPayrollContextLookup` (Core abstraction — no HRIS→Payroll coupling)
- `PayrollEventSubscriber` registered as both `IPayrollEventSubscriber` and `IEventSubscriber`
- `IEventSubscriber` in Core: startup wiring hook; `Program.cs` resolves all registrations after build and calls `RegisterHandlers` on each — this is the fix that activated all payroll event handlers (hire auto-enrollment, termination, etc.) which had been silent no-ops since 4.3
- Menu contributions: Payroll Runs, Pay Register, Accumulators, Pay Calendars, Payroll Profiles

**4.8 — UI components ✓ COMPLETE**
All pages require `@rendermode InteractiveServer`:
- `PayrollRunsPage.razor` — run list, stat cards, New Run form (context + period + type), real-time polling, Approve/Cancel actions
- `PayrollRunDetailPage.razor` — tabbed run detail (Summary, Pay Register, Exceptions, Variance)
- `PayrollCalendarPage.razor` + `PayrollCalendarDetailPage.razor` — context management and period generation
- `PayrollProfilesPage.razor` — enrollment stat cards; bulk enroll form with Enrollment Settings section (context + effective date) + Filter Employees section (Division/Department/Location dropdowns + checkbox employee table + Select All/Deselect All); enrolled profiles table with Payroll Context column
- `PayRegisterPage.razor`, `AccumulatorsPage.razor` — stubs pointing to run-level detail
- `HireEmployeePanel.razor` Step 5 — Payroll Context dropdown (via `IPayrollContextLookup` Core abstraction; `Guid?` bind via string intermediary); shows "Enroll later" in review step when omitted

Implementation notes:
- Module decoupling: HRIS uses `IPayrollContextLookup` in Core; no direct Payroll type references. `NullPayrollContextLookup` registered in Host as fallback before module loop — Autofac last-registration-wins means module override works cleanly
- Blazor `Guid?` select binding: silently keeps null — all `Guid?` dropdowns use `string` intermediary + `Guid.TryParse` at submit time
- Razor inline `{ }` lambdas in `@onchange` attributes confuse the parser — all filter handlers extracted to named methods
- `IEnumerable<T>` injection in Blazor Autofac circuit scope can return null — inject single interface with guaranteed fallback instead
- Division resolved in SQL via `LEFT JOIN org_unit div ON div.org_unit_id = d.parent_org_unit_id AND div.org_unit_type_id = (SELECT id FROM lkp_org_unit_type WHERE code = 'DIVISION')`

**4.9 — Temporal Date Override UI ✓ COMPLETE**
- `ITemporalOverrideService` interface + `NullTemporalOverrideService` no-op in `AllWorkHRIS.Core/Temporal/`
- `OverridableTemporalContext` implements both `ITemporalContext` and `ITemporalOverrideService`; lock-guarded singleton
- `Program.cs` — conditional registration: when `TEMPORAL_OVERRIDE_ENABLED=true` registers `OverridableTemporalContext` as both interfaces; otherwise registers `SystemTemporalContext` + `NullTemporalOverrideService`
- `TemporalOverrideBar.razor` shared component — compact bar rendered in `MainLayout.razor` below TopBar; invisible when `IsEnabled=false`; neutral styling with system date when no override; amber styling with override date when active; date picker + Set / Clear buttons
- Satisfies TC-RPT-002 prerequisite (historical reports respect Temporal Override)

**Shared infrastructure added in Phase 4.8–4.9**
- `LegalEntitySelector.razor` shared component — all payroll pages scope their payroll context lists by legal entity; shows read-only badge if only one entity, tabs for ≤8, searchable list for >8; auto-selects first entity on init and fires `OnChanged` callback
- `Components/_Imports.razor` — added `@using AllWorkHRIS.Host.Components.Shared`
- `app.css` — added `.entity-badge`, `.entity-tab`, `.entity-search-*`, `.temporal-bar*`, `.form-section-label` classes

**4.10 — Onboarding Blocking Task Gate ✓ COMPLETE**

Deliverables completed:
1. `blocking_tasks_cleared BOOLEAN NOT NULL DEFAULT FALSE` column added to `payroll_profile` via migration `006_payroll_profile_blocking_tasks.sql`.
2. `OnboardingBlockingTasksCompletePayload` and `OnboardingPlanGatePayload` confirmed in `AllWorkHRIS.Core/Events/`.
3. `OnboardingBlockingTasksGateHandler` and `OnboardingPlanGateHandler` registered in `PayrollEventSubscriber`; set `blocking_tasks_cleared = TRUE` via `IPayrollProfileRepository.SetBlockingTasksClearedAsync`.
4. `PayrollRunJob` filters population to `WHERE blocking_tasks_cleared = TRUE`; blocked employees written to `payroll_run_exception` with code `BLOCKING_TASKS_INCOMPLETE`.
5. `HireEventHandler` sets `blocking_tasks_cleared = FALSE` at enrollment; gate is cleared only when the `OnboardingBlockingTasksCompletePayload` event fires.

**4.11 — Operational Logging (Serilog) ✓ COMPLETE**

Deliverables completed:
1. NuGet packages added to `AllWorkHRIS.Host`: `Serilog.AspNetCore`, `Serilog.Sinks.Console`, `Serilog.Sinks.File`, `Serilog.Enrichers.Environment`, `Serilog.Enrichers.Thread`.
2. `builder.Host.UseSerilog(...)` wired in `Program.cs` with `ReadFrom.Configuration()` + `FromLogContext()` / `WithMachineName()` / `WithEnvironmentUserName()` enrichers.
3. Serilog configuration block in `appsettings.json`: `Information` default; `Warning` for Microsoft/System; Console sink; rolling File sink (`logs/allworkhris-.log`, 30-day retention).
4. `.editorconfig` at solution root: `dotnet_diagnostic.CA2254.severity = error` — all `ILogger` calls must use constant templates; verified clean at build.
5. `CalculationEngine` converted to `partial class`; three `[LoggerMessage]` source-generated methods added (`LogCalculationStart`, `LogCalculationComplete`, `LogCalculationFailed`) — zero-allocation structured logging in the inner calculation loop.

Spec: `docs/SPEC/Platform_Audit_Trail.md` §2

**4.12 — Platform Audit Trail ✓ COMPLETE**

Deliverables completed:
1. **DBML** — `schemas/dbml/hcm_platform.dbml` created; `platform_audit_event` (19 columns, 6 indexes) defined.
2. **DDL** — `schemas/ddl/postgres/platform_schema.sql` generated; migration `007_platform_audit_event.sql` applied to `allworkhris_dev`.
3. **Core contracts** — `AllWorkHRIS.Core/Audit/IAuditService.cs` (interface + `AuditEventRecord` sealed record) and `NullAuditService` (no-op) added.
4. **Host implementation** — `AllWorkHRIS.Host/Platform/Audit/AuditService.cs`: resolves actor from `IHttpContextAccessor` (`sub` → `actorUserId`; `name`/`preferred_username` → display name; `RemoteIpAddress`; `TraceIdentifier`); single-tenant placeholder (`00000000-…-0001`) for Phases 1–7; swallows write failures and logs at `Error`.
5. **Registration** — `NullAuditService` registered before module loop (module isolation); `AuditService` registered after (Autofac last-registration-wins). `IHttpContextAccessor` added via `builder.Services.AddHttpContextAccessor()`.
6. **Initial instrumentation** — audit calls wired to: `PayrollContextRepository` (CreateContext, DeleteContext, UpdateContextStatus, UpdatePeriodRunDate); `PayrollRunService` (InitiateRun, ApproveRun, CancelRun); `PayrollProfileRepository` (Enroll, Disenroll); `PayrollCalendarDetailPage` (batch period generation — one summary event per generation).
7. **Module independence** — `PayrollModuleCompositionTests` (6 tests) pass with `NullAuditService` injected — no platform schema required.

Spec: `docs/SPEC/Platform_Audit_Trail.md` §3

Test cases: TC-AUD-001 through TC-AUD-007 (formal xUnit tests deferred to Phase 10.1a Audit Trail UI and Verification)

### Gate — TC-PAY test cases

**Formal xUnit integration tests (passing — 90/90 suite):**
- TC-PAY-001: ✓ `InitiateRunAsync` creates `payroll_run` row with status DRAFT
- TC-PAY-002: ✓ Duplicate run for same period throws `InvalidOperationException`
- TC-PAY-003: ✓ `PayrollRunJob` transitions run status to CALCULATED
- TC-PAY-004: ✓ `employee_payroll_result` row and REG earnings line persisted per employee
- TC-PAY-011: ✓ 10-employee batch run — all receive result rows; `PercentComplete == 100` (250-employee scale test deferred to Phase 10.4)
- TC-PAY-020: ✓ `HireEventHandler.HandleAsync` creates `payroll_profile` with `enrollment_source = AUTO_HIRE` and `blocking_tasks_cleared = false`
- TC-PAY-022: ✓ Blocked employee excluded (exception row created); included after `SetBlockingTasksClearedAsync`

**Deferred to Phase 10 Hardening:**
- TC-PAY-005: Employee-level failure isolated; run continues (requires fault injection path not present in current stubs)
- TC-PAY-006: Accumulator mutation atomic — rollback on failure (requires transaction wiring not yet built)
- TC-PAY-007: Pre-tax deduction reduces taxable wages (stubs return empty — pending compensation rules in Phase 5/6)
- TC-PAY-012: Progress visible in UI during calculation (SignalR UI — manual verification only)

**Manually verified:**
- Hire employee — `payroll_profile` AUTO_HIRE record created automatically
- Bulk manual enrollment via Payroll Profiles page — MANUAL records created
- Initiate a REGULAR payroll run — verified end-to-end with Serilog output showing 8 employees calculated, 1 blocked (BLOCKING_TASKS_INCOMPLETE)
- Progress panel updates in real time
- Temporal override bar appears; setting override date persists across page navigation
- `platform_audit_event` rows verified in DB after payroll run initiation

---

## Phase 5 — Payroll Calculation Pipeline

**Goal:** Real payroll tax withholding is calculated for all supported jurisdictions on every payroll run. The calculation engine's tax stub is replaced with a composable, ordered pipeline of configurable `ICalculationStep` objects. Each jurisdiction defines a collection of these steps; the pipeline executes them in sequence number order, passing a shared `CalculationContext` through each step from gross pay to net pay. This same pipeline is extended in Phase 6 (Benefits) with pre-tax and post-tax benefit deduction steps — TC-PAY-007 resolves naturally at that point.

**Reference:** `Payroll Tax Rules Reference — Barbados, Canada-Fed, US-Fed, NY, CA and GA.docx` (May 2026)
**Spec:** `SPEC/Payroll_Calculation_Pipeline.md`
**Projects:** `AllWorkHRIS.Core` (pipeline contracts); `AllWorkHRIS.Module.Tax` (step implementations and tax data)
**Core interface:** `IPayrollPipelineService` in `AllWorkHRIS.Core` — injected into `CalculationEngine` with no module-to-module coupling

### Background — Why Phase 5 is required

Phase 4.5 (CalculationEngine) implemented a 9-step ordered pipeline with tax as an explicit step, but the step was a stub returning empty results. Every payroll run to date has had zero withholding, zero FICA, and no employee-side contributions. Accurate payroll is the core product promise; this phase closes that gap.

### Architecture — The Calculation Pipeline

The central idea is that every calculation applied to an employee's pay — whether a standard deduction, a progressive income tax bracket walk, a flat FICA rate, or a Phase 6 benefits pre-tax election — is a self-contained `ICalculationStep` object. Each step:

- Carries a **sequence number** that determines its position in the ordered execution
- Declares what it **applies to** (employee, employer, or both)
- Holds its own **configuration** (rates, caps, thresholds, filing-status parameters) loaded from effective-dated DB rows
- Receives the shared `CalculationContext`, performs its calculation, records its result by name, and returns the updated context

The pipeline for each employee is assembled from two sources sorted together by sequence number:

```
steps = jurisdictionSteps          // from Tax module — same for all employees in that jurisdiction
      + employeeSpecificSteps      // from Benefits module (Phase 6) — personal to this employee
        .OrderBy(s => s.SequenceNumber)
```

This means Benefits (Phase 6) adds new step types to the same sorted list — no second calculation pass, no separate deduction loop, and TC-PAY-007 (pre-tax elections reduce the taxable wage base) is automatic.

#### Sequence Number Convention

| Range | Category | Examples |
|-------|----------|---------|
| 100–199 | Pre-tax voluntary deductions | 401k, HSA, FSA, health premium (Phase 6) |
| 200–299 | Allowances and standard deductions | Standard deduction, BPA, G-4 dependent allowances |
| 300–399 | National / federal income tax | US Fed brackets, Canada Fed brackets, Barbados income |
| 400–499 | Tax credits | BPA credit (Canada), reverse tax credit (Barbados), child tax credit (US) |
| 500–599 | Social insurance and flat levies | FICA SS, Medicare, CPP, CPP2, EI, NIS, Resilience Fund |
| 600–699 | Sub-national income tax | NY state, CA state, GA flat, NYC local |
| 700–799 | Derived taxes | Yonkers surcharge (sequence 710 — after NY state at 610) |
| 800–899 | Post-tax voluntary deductions | Roth 401k, supplemental life, union dues (Phase 6) |
| 900–999 | Employer-side only | MCTMT, FUTA, SUI, employer CPP/NIS match |

The sequence number replaces the `depends_on_tax_id` topological sort. A `PercentageOfPriorResultStep` at sequence 710 simply reads the named result `"US_NY_STATE_INCOME"` from `CalculationContext.StepResults` — which is guaranteed to exist because step 610 ran first.

#### Concrete Step Types

| Step Type | Algorithm | Sequence Range | Examples |
|-----------|-----------|----------------|---------|
| `StandardDeductionStep` | Subtract fixed or filing-status-keyed amount from taxable base | 200–299 | US standard deduction, GA G-4 standard deduction, NY standard deduction |
| `AllowanceStep` | Subtract per-dependent or age-based amount from taxable base | 200–299 | GA $4,000/dependent, Canada BPA (as income reduction) |
| `ProgressiveBracketStep` | Annualize → walk brackets → de-annualize → add extra withholding | 300–399, 600–699 | US Fed income, Canada Fed income, Barbados income, NY state, CA state, NYC local |
| `CreditStep` | Subtract from computed tax, floored at zero | 400–499 | Canada BPA credit (BPA × 14%), Barbados reverse tax credit |
| `FlatRateStep` | `rate × wage_base`; enforces `cap_earnings_limit`, `annual_cap_amount`, `period_cap_amount`, `threshold_amount`, `is_uncapped` | 500–599 | FICA SS, Medicare, CPP, CPP2, EI, NIS, CA SDI, NY SDI, NY PFL, BB Resilience Fund |
| `TieredFlatStep` | Walk rate tiers against a quarterly payroll total; employer-only | 900–999 | NY MCTMT Zone 1 and Zone 2 |
| `PercentageOfPriorResultStep` | `rate × StepResults[dependsOnCode]` | 700–799 | Yonkers resident surcharge (16.75% of NY state result) |
| `PreTaxBenefitStep` | Subtract election amount from taxable base (Phase 6) | 100–199 | Health premium, 401k pre-tax, FSA |
| `PostTaxBenefitStep` | Subtract election amount after all tax is computed (Phase 6) | 800–899 | Roth 401k, supplemental life |

#### CalculationContext

The immutable record flowing through every step — see `SPEC §3.2` for the full definition. Key fields:

```csharp
sealed record CalculationContext
{
    decimal GrossPayPeriod      { get; init; }   // unchanged throughout
    decimal AnnualizedGross     { get; init; }   // GrossPayPeriod × PayPeriodsPerYear
    decimal IncomeTaxableWages  { get; init; }   // reduced by income-tax-reducing pre-tax steps
    decimal FicaTaxableWages    { get; init; }   // reduced by FICA-reducing pre-tax steps
    decimal DisposableIncome    { get; init; }   // updated after Tax phase (garnishment use)
    decimal ComputedTax         { get; init; }   // sum of all employee tax amounts so far
    decimal NetPay              { get; init; }   // GrossPayPeriod − all employee-side deductions so far
    decimal EmployerCost        { get; init; }   // employer-side costs; does not reduce NetPay
    ImmutableDictionary<string, decimal> StepResults { get; init; }
    ImmutableDictionary<string, decimal> YtdBalances  { get; init; }
    // ... identity, filing profile fields — see SPEC §3.2
}
```

Each step returns a new `CalculationContext` with its result recorded in `StepResults` under its own `StepCode` (e.g., `"US_NY_STATE_INCOME"`, `"US_FICA_SS"`) and the relevant running totals updated.

### Deliverables

**5.0 — Schema and seed data**

Create `schemas/dbml/hcm_tax_pipeline.dbml` with 16 tables per `SPEC §9`:

- **`tax_jurisdiction`** — one row per jurisdiction; `jurisdiction_code`, `country_code`, `is_active`
- **`payroll_calculation_steps`** — one row per step per jurisdiction; `step_code` (unique), `step_type`, `calculation_category`, `sequence_number`, `applies_to`, `reduces_income_tax_wages`, `reduces_fica_wages`, `status_code`, `is_active`
- **`tax_filing_status`** — per-jurisdiction valid filing status codes
- **`tax_brackets`** — effective-dated; keyed by `step_code`; `filing_status_code` (NULL for BB/CA-FED), `lower_limit`, `upper_limit`, `rate`
- **`tax_flat_rates`** — effective-dated; `rate`, `wage_base`, `period_cap_amount`, `annual_cap_amount`, `depends_on_step_code`
- **`tax_tiered_brackets`** — effective-dated; tier floor/ceiling, `rate`, `period_cap_amount`, `annual_cap_amount`
- **`tax_allowances`** — effective-dated; `annual_amount`, optional `filing_status_code`
- **`tax_credits`** — effective-dated; `annual_amount`, `credit_rate`, `is_refundable`
- **`lkp_tax_form_type`** — lookup: `W4_2020`, `W4_LEGACY`, `IT_2104`, `DE_4`, `G_4`, `TD1`, `TD1X`, `BB_TD4`
- **`employee_tax_form_submission`** — base record per employee filing event; `employment_id`, `jurisdiction_id`, `form_type_id`, `exempt_flag`, effective dates
- **`employee_tax_form_detail`** — single consolidated detail row per submission covering all Phase 5 form families (W-4 2020+, W-4 legacy, all Category C state forms, TD1/TD1X/BB-TD4); no form-type-specific tables
- **`form_field_definition`** — per-form-type, effective-dated field metadata; drives configuration UI renderer and enforces required/optional rules; `status_code` follows approval workflow
- **`configuration_audit_log`** — append-only log of all status transitions on configuration entities

Generate `schemas/ddl/postgres/tax_pipeline_schema.sql` and apply to `allworkhris_dev`.

Seed scripts under `schemas/seed-data/postgres/dev/`:
- `tax_jurisdictions_seed.sql` — jurisdiction rows for all 6 in-scope jurisdictions
- `tax_calculation_steps_seed.sql` — all steps across all 6 jurisdictions with sequence numbers, `calculation_category`, and wage-base flags per the convention table
- `tax_rates_2025_seed.sql` — brackets, flat rates, allowances, credits for 2025; all rows inserted with `status_code = 'ACTIVE'`
- `tax_rates_2026_seed.sql` — brackets, flat rates, allowances, credits for 2026 (Canada 14% lowest bracket, Georgia 5.09%, OBBBA adjustments); rows inserted with `status_code = 'APPROVED'` and `effective_from = 2026-01-01`; activated automatically by engine on that date
- `tax_accumulator_definitions_seed.sql` — accumulator rows for SS, CPP, CPP2, EI, PFL annual, SDI weekly (fed into existing AccumulatorService)
- `form_field_definitions_seed.sql` — one row per field per form type for all 8 `lkp_tax_form_type` codes; `status_code = 'ACTIVE'`

**5.1 — Core pipeline contracts**

In `AllWorkHRIS.Core/Pipeline/`:

```csharp
interface ICalculationStep
{
    string   StepCode        { get; }   // e.g. "US_FICA_SS"
    int      SequenceNumber  { get; }
    string   AppliesTo       { get; }   // "employee" | "employer" | "both"
    Task<CalculationContext> ExecuteAsync(CalculationContext ctx, CancellationToken ct);
}

interface IPayrollPipelineService
{
    Task<PipelineResult> RunAsync(PipelineRequest request, CancellationToken ct);
}

sealed record PipelineRequest(
    Guid       EmploymentId,
    DateOnly   PayDate,
    decimal    GrossPayPeriod,
    int        PayPeriodsPerYear,
    IReadOnlyDictionary<string, decimal> YtdAccumulatorBalances
);

sealed record PipelineResult(
    decimal    NetPay,
    IReadOnlyList<CalculationStepResult> StepResults   // one per step executed
);

sealed record CalculationStepResult(
    string   StepCode,
    string   AppliesTo,
    decimal  Amount,
    decimal  WageBase
);
```

- `NullPayrollPipelineService` — returns gross pay as net pay, empty step results; registered by Host before module loop as fallback
- Register `NullPayrollPipelineService` in `Program.cs` before module loop

**5.2 — Module project setup**

- `AllWorkHRIS.Module.Tax` class library — references `AllWorkHRIS.Core` only (ADR-011)
- NuGet: Autofac 9.1.0, Dapper 2.1.72, Npgsql 10.0.2, System.Composition, Microsoft.Extensions.Hosting.Abstractions
- Folder structure: `Domain/`, `Repositories/`, `Services/`, `Steps/`
- `TaxModule.cs` — `[Export]` attribute; `Register()` wires all repositories, services, and `IPayrollPipelineService`; menu contributions: Tax Profiles, Tax Rate Reference

**5.3 — Domain and repository layer**

Domain types (all `sealed record`):
- `Jurisdiction`, `PayrollCalculationStep` (with `StepType` enum matching the step type names), `TaxBracket`, `TaxFlatRate`, `TaxAllowance`, `TaxCredit`
- `EmployeeTaxProfile`, `EmployeeWorkLocation`

Repositories:
- `IJurisdictionRepository` — `GetAllActiveAsync()`, `GetByCodeAsync(string)`
- `ICalculationStepRepository` — `GetStepsForJurisdictionsAsync(string[] codes, DateOnly payDate)` — returns fully hydrated step graph (step definition + its type-specific config rows) for a given set of jurisdiction codes at the pay date; result is ordered by `sequence_number`
- `IEmployeeTaxProfileRepository` — `GetByEmploymentIdAsync(Guid employmentId, DateOnly asOf)` — one profile per applicable jurisdiction
- `IEmployeeWorkLocationRepository` — `GetByEmploymentIdAsync(Guid employmentId, DateOnly asOf)`

All repositories `InstancePerLifetimeScope` in `TaxModule`.

**5.4 — Concrete step implementations**

All under `Steps/`. Each class implements `ICalculationStep`:

- **`StandardDeductionStep`** — calls `ctx.WithReducedIncomeTaxableWages(annualAmount / payPeriods)`; floors at zero. See `SPEC §4.1`.
- **`AllowanceStep`** — calls `ctx.WithReducedIncomeTaxableWages(allowances × amountPerAllowance / payPeriods)`; floors at zero. See `SPEC §4.2`.
- **`ProgressiveBracketStep`** — annualizes `ctx.IncomeTaxableWages`; adjusts with `OtherIncomeAmount` / `DeductionsAmount`; walks brackets; subtracts `CreditsAmount`; de-annualizes; adds `AdditionalWithholding`. See `SPEC §4.3`.
- **`CreditStep`** — subtracts `annualCredit × creditRate / payPeriods` from `ctx.ComputedTax`; floors at zero (non-refundable). See `SPEC §4.4`.
- **`FlatRateStep`** — reads `ctx.FicaTaxableWages` (social insurance) or `ctx.IncomeTaxableWages` (income-tax flat), selected by `_useFicaTaxableWages` flag; applies `wage_base` annual cap, `period_cap_amount`, and `annual_cap_amount` via YTD. See `SPEC §4.5`.
- **`TieredFlatStep`** — annualizes `ctx.FicaTaxableWages`; walks rate tiers; applies per-tier caps and annual cap via YTD; de-annualizes. Used for NIS, CPP, CPP2. See `SPEC §4.6`.
- **`PercentageOfPriorResultStep`** — reads `ctx.StepResults[DependsOnCode]`; multiplies by `rate`; step's `DependsOnCode` configured in `payroll_calculation_steps`. See `SPEC §4.7`.

**5.5 — PayrollPipelineService**

`PayrollPipelineService` implements `IPayrollPipelineService`:

1. Load employee's work/residence jurisdiction codes from `IEmployeeWorkLocationRepository`
2. Load fully hydrated steps for those jurisdictions from `ICalculationStepRepository` — already ordered by `sequence_number`
3. Load `EmployeeTaxProfile` per jurisdiction from `IEmployeeTaxProfileRepository`
4. Build initial `CalculationContext` from `PipelineRequest` (annualize gross, set `FilingStatus` from profile)
5. Execute each step in sequence: `ctx = await step.ExecuteAsync(ctx, ct)`
6. After all steps, compute `NetPay = GrossPayPeriod − Σ(employee-side step amounts)`
7. Return `PipelineResult` with `NetPay` and all `CalculationStepResult` records

**5.6 — Wire into CalculationEngine**

- `CalculationEngine` receives `IPayrollPipelineService` as a constructor parameter (replaces tax stub)
- Replace step 7 (tax stub) with a call to `IPayrollPipelineService.RunAsync`
- Map `PipelineResult.StepResults` to result line domain records:
  - Employee income tax steps → `TaxResultLine` via `IResultLineRepository`
  - Flat levy/insurance steps → `TaxResultLine` (employee-side) or `EmployerContributionResultLine` (employer-side)
- Update `EmployeePayrollResult.GrossPay` and `NetPay` from pipeline output
- Update `PayrollRunResultSet` totals: `TotalEmployeeTax`, `TotalEmployerContribution` now populated from real data

**5.7 — Employee Tax Profile UI**

Page: `/payroll/tax-profiles` — `TaxProfilesPage.razor` (`@rendermode InteractiveServer`):
- Employee search field
- Per-jurisdiction accordion (one section per applicable jurisdiction from the employee's work/residence locations)
- Each section renders a jurisdiction-appropriate form:
  - US Federal: W-4 fields (filing status, Step 3 credits, Steps 4a/4b/4c amounts, exempt checkbox)
  - Georgia: G-4 fields (filing status A/B/C/D, dependents count)
  - New York: IT-2104 fields (filing status, allowances, NYC resident flag, Yonkers resident/non-resident flags, extra withholding)
  - California: DE-4 fields (filing status, regular allowances, additional allowances, extra withholding)
  - Canada: TD1 fields (BPA, age, pension, spousal, disability, tuition credit amounts, extra withholding per period)
  - Barbados: read-only summary — personal allowance and NIS are employer-managed
- Save per jurisdiction section; each save audit-logged via `IAuditService`

**5.8 — Tax Configuration Management UI**

Blazor pages under `/config/tax/` — `@rendermode InteractiveServer` throughout. Delivers the full configuration workflow described in `SPEC §12`. Requires `TaxAdmin` and `ComplianceReviewer` roles to be seeded and wired to the identity system.

Sub-pages:
- `/config/tax/steps` — Calculation Definition Editor: step list per jurisdiction, inline rate row editor (bracket grid, flat rate form, tiered bracket grid, allowance/credit form), effective-date entry
- `/config/tax/form-fields` — Form Field Definition Editor: field list per form type, required/optional toggle, display metadata, rule builder for `validation_rules_json` / `visibility_rule_json`
- `/config/tax/review` — Review and Approval Panel: dashboard of `PENDING_REVIEW` items with diff view and approve/reject workflow
- `/config/tax/preview` — Preview Sandbox: hypothetical calculation against APPROVED-but-not-yet-ACTIVE rows; produces step-by-step pipeline trace; no run record created
- `/config/tax/reference` — Rate Reference View (read-only): active configuration per jurisdiction, viewable by `PayrollAdmin` and `SystemAdmin`

All status transitions write a row to `configuration_audit_log`. The approve action on a rate row with a future `effective_from` does not immediately activate it — the pipeline query activates it automatically on that date. The December 15 rate deployment deadline is met by having 2026 rates reach APPROVED status (not ACTIVE) before December 15.

**5.9 — US State Form Coverage Survey**

The consolidated `employee_tax_form_detail` table covers all Phase 5 form families. Before Phase 5 gates, all 50 US states + DC must be categorised (A / A+ / B / C / D / E) and each state's withholding certificate structure confirmed against the columns available in `employee_tax_form_detail`. Assigning a state to Category E triggers a design review — the column may already exist under a different name, or a new column may be needed (a non-breaking addition).

Deliverables:
- Completed state form coverage matrix in `SPEC/Payroll_Calculation_Pipeline.md §15` — every state assigned to a category with no rows in Category E
- Any new `lkp_tax_form_type` seed rows required for form types not yet covered
- `form_field_definitions_seed.sql` additions for any new form types identified
- Step and rate seed data stubs for all US state jurisdictions added to scope — even zero-tax states require a jurisdiction row confirming no steps are needed
- Note added to `SPEC §15` recording the survey date; matrix must be re-verified annually against published state form revisions

Gate criterion: §15 matrix complete and all states resolved. No state may remain uncategorised when Phase 5 closes.

**5.10 — Configuration Management operability verification**

Before Phase 5 gates, demonstrate the full configuration management workflow end-to-end with a real rate change:

1. `TaxAdmin` logs in and creates a DRAFT bracket row for a 2027 test rate on `BB_INCOME_TAX`
2. `TaxAdmin` submits for review; row moves to PENDING_REVIEW; `configuration_audit_log` row written
3. `ComplianceReviewer` views the pending item in `/config/tax/review`; runs the preview sandbox against the proposed row
4. `ComplianceReviewer` approves; row moves to APPROVED; audit log row written
5. Verify: engine does NOT apply the 2027 row for a 2025 or 2026 pay date (effective-date gate)
6. `TaxAdmin` archives the test row; audit log row written

Gate criterion: All six workflow steps complete without error; `configuration_audit_log` contains four rows for the test rate's lifecycle; no payroll run is affected by the test row.

### Gate — TC-TAX test cases

All tests are xUnit integration tests against `allworkhris_dev` using the seeded 2025/2026 rate data. Each test verifies the full pipeline result, not an individual calculator.

| Test | Description | Assertion |
|------|-------------|-----------|
| TC-TAX-001 | US Fed single filer, $85K/year, biweekly pay | Annual income tax via pipeline = $10,314.00 ±$1 (reference doc §4.9) |
| TC-TAX-002 | US Fed MFJ, $100K household, semi-monthly pay | Correct bracket walk; MFJ 2025 table used |
| TC-TAX-003 | FICA SS caps at $176,100 wage base | `FlatRateStep` stops at cap; no SS on pay period crossing the cap |
| TC-TAX-004 | Additional Medicare triggers above $200K YTD | `FlatRateStep` threshold: 0.9% applied only above $200K accumulated |
| TC-TAX-005 | Barbados NIS caps at BBD $63,360 annual | `FlatRateStep` YTD check; NIS stops accruing after cap |
| TC-TAX-006 | Barbados income tax 2026 two-bracket progressive | `ProgressiveBracketStep` result = BBD $12,625.00 ±$1 (reference §3.3) |
| TC-TAX-007 | Canada BPA as credit (not deduction) — `CreditStep` at sequence 410 | Net federal tax = CAD $12,342.74 ±$1 (reference §5.9) |
| TC-TAX-008 | Canada CPP base + CPP2 two-tier — two `FlatRateStep` objects at sequences 510, 511 | CPP2 only applies above YMPE; both caps enforced independently |
| TC-TAX-009 | Georgia flat rate — single, $85K, 1 dependent, 2025 | `AllowanceStep` then single `FlatRateStep`; tax = $3,581.10 ±$1 (reference §6.8) |
| TC-TAX-010 | NY State 9-bracket progressive, single, $100K, 2025 | `ProgressiveBracketStep` at seq 610; result = $4,951.75 ±$1 (reference §7.11) |
| TC-TAX-011 | NYC local tax — NYC residence flag drives inclusion of seq-620 step | NYC `ProgressiveBracketStep` added; result = $3,441.09 ±$1 additional |
| TC-TAX-012 | Yonkers surcharge — `PercentageOfPriorResultStep` at seq 710 reads seq-610 result | Yonkers = NY state result × 0.1675; seq ordering enforces dependency |
| TC-TAX-013 | NY SDI weekly period cap ($0.60) — `FlatRateStep` with `period_cap_amount` | Period SDI = $0.60 regardless of gross pay |
| TC-TAX-014 | CA 9-bracket progressive, single, $100K, 2025 | `ProgressiveBracketStep` + `CreditStep` (personal exemption); net = $5,079.42 ±$1 (reference §8.14) |
| TC-TAX-015 | CA SDI uncapped — `FlatRateStep` with `is_uncapped = true` | SDI grows linearly with no cap; confirmed at two different salary levels |
| TC-TAX-016 | CA Mental Health surtax — second `ProgressiveBracketStep` at seq 631, threshold $1M | 1% applied only above $1,000,000; threshold not inflation-indexed |
| TC-TAX-017 | Employee `is_exempt = true` on profile for a jurisdiction | Steps for that jurisdiction skipped entirely; zero withholding for exempt jurisdiction |
| TC-TAX-018 | Effective-date rate lookup — same employee, Dec 2025 pay date vs Jan 2026 pay date | 2025 rates applied in Dec; 2026 rates (Canada 14%, GA 5.09%) applied in Jan; no code change |
| TC-TAX-019 | Pipeline step order observable — `PipelineResult.StepResults` ordered by sequence number | Step results list is in ascending sequence order; Yonkers appears after NY state |

---

## Phase 6 — Benefits (Minimum)

**Status:** Complete — all deliverables built and 17/17 gate tests (TC-BEN-001–017 + TC-PAY-007) passing as of 2026-05-02.

**Goal:** HR administrator can configure deduction codes, enter employee benefit elections, and verify those deductions appear correctly in the payroll run. Benefits plug into the existing `ICalculationStep` pipeline from Phase 5 — pre-tax elections land at sequence 100–199 (before income tax), post-tax elections at sequence 800–899 (after all withholding). TC-PAY-007 (pre-tax deductions reduce taxable wages) resolves automatically because the taxable base is already reduced before any `ProgressiveBracketStep` runs.

**Pipeline and audit log separation (architectural decision — May 2026):**

The `IPayrollPipelineService` remains a single shared orchestrator for both tax and benefit steps. Module separation is enforced at the configuration and UI layer, not at the pipeline execution layer:

- Tax configuration lives in `payroll_calculation_steps` and associated rate tables; access gated to `TaxAdmin` / `ComplianceReviewer`.
- Benefit configuration lives in benefit-specific tables introduced in this phase; access gated to `BenefitsAdmin` only.
- The pipeline cannot distinguish who configured a given step at runtime, nor should it need to — sequence ordering and wage-base flags are the only runtime concerns.

**Audit log:** Benefits introduces its own `benefit_configuration_audit_log` table rather than sharing the existing `configuration_audit_log` (which is owned by the Tax module). The schema is identical; the separation means each module's change history is independently queryable and exportable without surfacing the other module's rate data. A `PayrollAdmin` doing a full reconciliation queries both tables directly; no joined "super-audit" view is required in Phase 6.

**Benefit step interface constraint:** `IBenefitStepProvider` must return only steps that call `ctx.WithReducedIncomeTaxableWages` or `ctx.WithReducedFicaTaxableWages` (pre-tax) or subtract from `NetPay` directly (post-tax). Benefit steps must not call `ctx.WithStepResult` in a way that adds to `ComputedTax`. This is a convention enforced by code review; a typed `IBenefitDeductionStep` interface that restricts available mutations may be introduced in Phase 9 hardening if the convention proves insufficient.

**Spec:** `SPEC/Benefits_Minimum_Module`
**Project:** `AllWorkHRIS.Module.Benefits` (new class library)
**Dependency:** Phase 5 (Payroll Calculation Pipeline) must be complete — Benefits adds two new `ICalculationStep` implementations to the existing pipeline infrastructure.

### Deliverables
- Module project setup — references `AllWorkHRIS.Core` only
- `DeductionCode`, `BenefitDeductionElection` domain types
- `IDeductionCodeRepository`, `IBenefitElectionRepository`
- `IBenefitElectionService` — full lifecycle including versioning pattern per SPEC §7
- `IBenefitElectionImportService` — batch import with dry-run
- **`PreTaxBenefitStep`** — implements `ICalculationStep`; sequence 100–199; calls `ctx.WithReducedIncomeTaxableWages` and/or `ctx.WithReducedFicaTaxableWages` per the election's `reduces_income_tax_wages` / `reduces_fica_wages` flags before any `ProgressiveBracketStep` runs; one step instance per active pre-tax election per employee
- **`PostTaxBenefitStep`** — implements `ICalculationStep`; sequence 800–899; subtracts election amount from net pay after all tax is computed; one step instance per active post-tax election per employee
- `BenefitsModule.Register()` must supply election-derived `ICalculationStep` instances to the pipeline assembly — mechanism: `IBenefitStepProvider` interface in Core; Benefits module registers its implementation; `PayrollPipelineService` calls all registered `IBenefitStepProvider` instances when assembling the step list
- HRIS event handlers registered on `IEventPublisher` in `BenefitsModule.Register`
- `BenefitsModule` registration and menu contributions
- UI: Deduction Codes page, Elections page, Employee Benefits tab, Import page

### Gate — TC-BEN test cases
- TC-BEN-001 through TC-BEN-010: Election lifecycle and HRIS event integration
- TC-BEN-011/012: Batch import dry-run and commit
- TC-BEN-013: Pre-tax election reduces income-taxable base — `ProgressiveBracketStep` receives lower `IncomeTaxableWages`; confirmed via pipeline `StepResults`
- TC-BEN-014/015: Post-tax election reduces net pay — computed after all withholding; confirmed via `PipelineResult.NetPay`
- TC-BEN-016: Employer contribution election results in `EmployerContributionResultLine` — does not appear in employee-side step results
- TC-BEN-017: Suspended and expired elections not included in pipeline assembly
- TC-PAY-007: Pre-tax deduction reduces taxable wages — passes as a natural consequence of `PreTaxBenefitStep` sequence position (100–199 < 300–399 income tax)

---

## Phase 6B — Benefits Calculation Model

**Status:** In Progress — Tier 1 (domain objects, pipeline timing, migrations) complete as of 2026-05-04.

**Goal:** Extend the minimum Benefits module with a full rule-based calculation engine. Phase 6 established the election lifecycle and simple fixed-amount deductions. Phase 6B adds six calculation modes (fixed, percentage, coverage-based), employer match rules, rate tables, and pay-period timing alignment so that mid-period elections, three-paycheck months, and age-banded premiums are handled correctly.

**Schema changes:** Migrations 011 and 012 (both idempotent, applied to `allworkhris_dev`).
- Migration 011: renames `deduction_code` → `deduction`, adds `calculation_mode` / `wage_base` / `age_as_of_rule` columns; replaces `deduction_code` varchar FK on elections with `deduction_id` UUID FK; adds `deduction_rate_table`, `deduction_rate_entry`, `deduction_employer_match` tables; adds mode-specific election columns; adds `three_paycheck_month_rule` to `payroll_context`.
- Migration 012: adds `partial_period_rule` to `benefit_deduction_election`; adds `match_type` to `deduction_employer_match`.

**ADR:** ADR-012 (Benefit Election Temporal Integrity) documents the seven temporal decisions.
**SPEC:** `SPEC/Benefits_Minimum_Module` v0.4 (Section 17 — Timing Alignment Model).

### Tiers

| Tier | Status | Description |
|---|---|---|
| 1 | **Complete** | Migrations 011/012; domain objects (`Deduction`, `DeductionRateTable`, `DeductionRateEntry`, `DeductionEmployerMatch`); `IDeductionRepository`; `BenefitDeductionElection` new fields; `CreateElectionCommand` → `DeductionId`; `BenefitElectionRepository` JOIN-based SELECT; pipeline timing fields; `IBenefitStepProvider` signature; `GetElectionsOverlappingPeriodAsync`; `PostTaxPctBenefitStep`; `MatchBenefitStep`; two-pass pipeline execution; SPEC v0.4 §17; ADR-012 |
| 2 | Pending | Complete repository layer: `HasOverlapAsync`, `TrimEndDateAsync`, `GetByEmploymentIdAtDateAsync`, `GetNonSupersededByEmploymentIdsAsync`, `IDeductionRateTableRepository`, `IDeductionEmployerMatchRepository` |
| 3 | Pending | Rewrite `CreateElectionAsync` with SERIALIZABLE overlap check; replace `UpdateElectionAsync` with `AmendElectionAsync` + `CorrectElectionAsync` |
| 4 | Pending | Calculator strategy pattern — 6 calculators (`FixedAnnual`, `FixedMonthly`, `FixedPerPeriod`, `PctPreTax`, `PctPostTax`, `CoverageBased`) + factory + updated `BenefitStepProvider` dispatch |
| 5 | Pending | `BenefitElectionActivationJob` — promotes PENDING → ACTIVE on effective date |
| 6 | Pending | Bulk import sort-and-sweep with calculation-mode awareness |
| 7 | Pending | Mode-aware UI forms, rate table admin UI, match rule admin UI |

### Gate — Phase 6B complete when
- All 17 TC-BEN test cases still passing after Tier 3 SERIALIZABLE rewrite
- New TC-BEN-018+ covering each calculation mode (per SPEC §13)
- Activation job promotes PENDING elections without manual intervention
- Rate table UI allows creating and editing `COVERAGE_BASED` deductions end-to-end

---

## Phase 7 — Dashboard & Navigation

**Goal:** Every user lands on a role-appropriate dashboard that presents their outstanding, upcoming, and pending work items scoped to the legal entities they serve. Selecting an entity from the dashboard locks the session context for the duration of that workflow. The application nav is fully dynamic — driven by registered module contributors rather than static markup — and the per-page legal entity selector is removed from all module pages.

**Spec:** `SPEC/Host_Application_Shell` (§Dashboard, §Navigation)
**No new module project** — all work is in `AllWorkHRIS.Host` and `AllWorkHRIS.Core`

### Design decisions

**Entity lock is universal for operational users.** All users — including PEO staff serving multiple client entities — select one entity from the dashboard and lock onto it for their workflow. The dashboard is the only place an entity switch can occur. Navigating away from the dashboard without selecting an entity is not possible; deep-links without a locked context redirect to the dashboard.

**Three access patterns, not one:**

| Role | Entity Context |
|---|---|
| All operational users (incl. PEO staff) | Lock onto one entity; return to dashboard to switch |
| SystemAdmin | Global by default; can inspect any entity without locking |
| Operations Admin | Always global; no entity lock; aggregate monitoring view only |

**SystemAdmin access is context-dependent.** Global actions (user management, tax rate authoring, jurisdiction management) operate without an entity context. Entity-level inspection (reviewing tax profiles for a specific entity, verifying jurisdiction assignments) allows dropping into an entity view deliberately — but without the lock semantics that apply to operational users. The SystemAdmin can step back out without going through the dashboard flow.

**Operations Admin is defined but not fully built in this phase.** The role is acknowledged in the role model, its nav slot is reserved, and a placeholder dashboard stub is delivered. The full monitoring console (cross-entity run queue, job status, throughput metrics) is deferred to a future phase when an Operations Admin user exists to validate requirements.

**PEO deployment is supported by the existing data model.** In a PEO deployment, each client company is a legal entity in the same `org_unit` table. PEO staff users have access to all entities and see a longer entity list on their dashboard. No schema changes are required — the multi-entity model already handles this. Multi-tenancy at the PEO level is a deployment concern (separate instance per PEO client), not an application architecture concern.

**Dynamic nav replaces static `MainLayout.razor` markup.** Each module registers an `INavContributor` that declares its nav section title, required role, display order, and list of links. `MainLayout.razor` injects `IEnumerable<INavContributor>`, resolves which contributors are active for the current user's roles at session start, and renders from that cached list. `IsInRole()` is not used — role checks use direct claim inspection per the established pattern.

**Two nav surfaces:**

*Entity nav (shown after entity lock for operational users):*
```
← Switch Client
─────────────────
Dashboard
People
Payroll
Benefits
Tax Setup
Reports
Entity Settings
```

*SystemAdmin nav (shown for SystemAdmin role; no entity lock):*
```
← Back to Clients
─────────────────
Legal Entities
Jurisdictions
Tax Rates & Brackets
Form Definitions
User Management
System Settings
```

### Deliverables

**7.1 — Core interfaces**
- `IDashboardContributor` in `AllWorkHRIS.Core` — `GetItemsAsync(Guid? entityId, IEnumerable<string> roles)` returns `IReadOnlyList<DashboardItem>` (title, subtitle, entity name, route, urgency, module badge colour)
- `INavContributor` in `AllWorkHRIS.Core` — `NavSection` (title, requiredRole, order, links)
- `IEntityContextService` in `AllWorkHRIS.Core` — `SelectedEntityId`, `IsLocked`, `Lock(Guid entityId)`, `Unlock()`, `IsAdminMode` (true for SystemAdmin and Operations Admin)

**7.2 — Dashboard page (`/dashboard`)**
- Replaces `/` as the application root — unauthenticated users redirect to Keycloak; authenticated users without a locked entity land here
- Resolves all `IDashboardContributor` registrations for the current user's roles; fans out `GetItemsAsync` calls in parallel; merges and sorts results by urgency then module
- Task list grouped by entity (or flat list for single-entity users)
- Clicking a task: calls `IEntityContextService.Lock(entityId)`, then navigates to the task route
- Entity card section below task list: all entities the user has access to, with a "Go to [entity]" affordance that locks and navigates to the entity's dashboard without a specific task
- Empty state: "No outstanding items" with entity cards still present for navigation
- `@rendermode InteractiveServer`

**7.3 — SystemAdmin dashboard (`/admin`)**
- Separate landing page for `SystemAdmin` role — does not use entity lock
- Summary cards: total legal entities, active jurisdictions, pending user requests, recent configuration changes
- Quick-links to each admin nav section
- `@rendermode InteractiveServer`

**7.4 — Operations Admin dashboard stub (`/ops`)**
- Placeholder page for `OperationsAdmin` role — "Monitoring console coming soon"
- Establishes the route and role gate; no functional content in this phase
- `@rendermode InteractiveServer`

**7.5 — Dynamic nav**
- `INavContributor` implementations registered by each existing module: `HrisNavContributor`, `PayrollNavContributor`, `BenefitsNavContributor`, `TaxNavContributor`, `SystemAdminNavContributor`, `OperationsAdminNavContributor`
- `MainLayout.razor` refactored: resolves contributors at session start, caches for session, renders dynamically
- Entity nav shown when `IEntityContextService.IsLocked` is true and role is not SystemAdmin/OperationsAdmin
- SystemAdmin nav shown when role is SystemAdmin
- Operations Admin nav shown when role is OperationsAdmin (stub only)
- Static nav markup in `MainLayout.razor` removed

**7.6 — Entity lock middleware**
- `EntityContextGuard` — Blazor navigation interceptor; if user navigates to a module page without a locked entity context (and is not SystemAdmin/OperationsAdmin), redirects to `/dashboard`
- Deep-link handling: target route preserved in query string so dashboard can redirect after entity selection

**7.7 — Remove per-page `LegalEntitySelector`**
- `LegalEntitySelector.razor` component removed from all payroll, benefits, and tax pages
- Pages that currently read entity from the selector now read from `IEntityContextService.SelectedEntityId`
- `LegalEntitySelector.razor` component file deleted

**7.8 — Dashboard contributors for existing modules**
- `HrisDashboardContributor` — employees in onboarding incomplete, documents expiring within 30 days, upcoming contract end dates
- `PayrollDashboardContributor` — runs in PENDING_APPROVAL, upcoming pay dates (next 2 periods), runs in FAILED state
- `BenefitsDashboardContributor` — import batches validated but not submitted, elections with future effective dates pending review
- `LeaveDashboardContributor` — leave requests pending manager approval, employees returning from leave this week

### Gate — TC-DASH test cases
- **TC-DASH-001:** Dashboard renders for PayrollOperator — payroll task items present; HRIS and Benefits items absent (role not held)
- **TC-DASH-002:** Dashboard renders for BenefitsAdmin — benefits task items present; payroll items absent
- **TC-DASH-003:** Clicking a task locks `IEntityContextService` to the correct entity and navigates to the task route
- **TC-DASH-004:** Clicking an entity card (no task) locks entity and navigates to dashboard with entity context active
- **TC-DASH-005:** Entity nav renders after lock; "Switch Client" link present; entity name displayed
- **TC-DASH-006:** Deep-link to `/payroll/runs` without a locked context redirects to `/dashboard?returnUrl=/payroll/runs`
- **TC-DASH-007:** After entity selection from deep-link redirect, navigation completes to original target route
- **TC-DASH-008:** SystemAdmin user sees SystemAdmin nav; no entity lock prompt; can access `/config/legal-entities` directly
- **TC-DASH-009:** OperationsAdmin user sees stub page at `/ops`; entity nav not shown
- **TC-DASH-010:** `INavContributor` implementations for all existing modules registered and rendering correct links

---

## Phase 8 — Time & Attendance (Minimum)

**Goal:** Employees can submit time, managers can approve it, overtime is correctly detected, and approved time flows into payroll calculation.

**Spec:** `SPEC/Time_Attendance_Minimum_Module`
**Project:** `AllWorkHRIS.Module.TimeAttendance` (new class library)

### Deliverables
- Module project setup — references `AllWorkHRIS.Core` only
- `TimeEntry`, `TimeEntryStatus`, `TimeCategory` domain types
- `ITimeEntryRepository`, `IWorkScheduleRepository`
- `ITimeEntryService` — submit/approve/reject/correct lifecycle
- `IOvertimeDetectionService` — FLSA 40-hour threshold
- `IPayrollHandoffService` — lock entries and record `PayrollRunId`
- HRIS event handlers registered in `TimeAttendanceModule.Register`
- `TimeAttendanceModule` registration and menu contributions
- UI: My Timecard, Timecards, Timecard Detail, Payroll Handoff pages — all with `@rendermode InteractiveServer`

### Gate — TC-TA test cases
- TC-TA-001 through TC-TA-006: Time entry lifecycle
- TC-TA-007/008: FLSA overtime — non-exempt and exempt
- TC-TA-009/010: Payroll handoff — delivered and not redelivered
- TC-TA-011/012: Locked entry correction with retroactive flag
- TC-TA-018: Overtime reclassification from most-recent entries first

---

## Phase 9 — Pay Register Drilldown

**Spec:** `docs/SPEC/Pay_Register_Drilldown.md` (v0.1)

**Goal:** Accounting and payroll staff can view the full history of payroll financial activity at any level of aggregation — from company-level totals down to one employee's pay breakdown for a specific run — through a single coherent page. The standalone `PayRegisterPage.razor` (currently a stub) is replaced with this page.

**No new module project; no schema changes.** All data already exists in `payroll_run`, `employee_payroll_result`, and `result_line`. New aggregation queries are added to the Payroll module's repository layer.

**All work is in `AllWorkHRIS.Host` and `AllWorkHRIS.Module.Payroll`.**

### Design summary

See `SPEC/Pay_Register_Drilldown.md` for the complete page specification. Key points:

- **Run selection** via a Year/Month navigator on the left; only `APPROVED`/`COMPLETED` runs shown.
- **Three tabs per selected run:** Company Summary (full cost and liability breakdown including Total Cash Required for ACH prefunding), Org Rollup (by Department / Location / Job with inline employee expansion), Employee Detail (one row per employee result, expandable to individual result lines).
- Hours columns (`HOURS_REGULAR`, `HOURS_OT`, `HOURS_PTO`) are conditionally rendered — hidden until Phase 8 T&A flows into result lines.
- CSV export from each tab; "Export with Line Detail" from Employee Detail tab produces GL-import format (one row per result line).
- `BenefitsAdmin` role: Company Summary benefit section only; no Org Rollup or Employee Detail.

### Repository additions

New `IPayRegisterRepository` (or extension of `IPayrollRunRepository`) in `AllWorkHRIS.Module.Payroll`. All queries aggregate from `employee_payroll_result` joined to `result_line`; ANSI SQL only (ADR-004).

### Gate — TC-PREG test cases

Full test list: `SPEC/Pay_Register_Drilldown.md` §9 (TC-PREG-001 through TC-PREG-011).

---

## Phase 10 — Accumulators Drilldown

**Spec:** `docs/SPEC/Accumulator_Display.md` (v0.1)
**Architecture model:** `docs/accumulators/Accumulator_Model_Detailed.md` (v0.3, Approved)

**Goal:** Payroll and accounting staff have an operational window into the accumulator state machine — current balances, period history, cap status, and the impact line trail that produced each balance. The standalone `AccumulatorsPage.razor` (currently a stub) is replaced with this page.

**No new schema changes.** Data exists in the three-layer accumulator model: `accumulator_definition` (Definition), `accumulator_impact` / `accumulator_contribution` (Impact), `accumulator_balance` (Value). New queries are added to the Payroll module.

**All work is in `AllWorkHRIS.Host` and `AllWorkHRIS.Module.Payroll`.**

### Design summary

See `SPEC/Accumulator_Display.md` for the complete page specification. Key points:

- **Two primary views** selectable by top-level toggle: **By Family** (operational cap monitoring; serves Payroll Operations and Management Accounting) and **By Employee** (individual liability audit; serves Corporate Accounting, External Reporting, Carrier Reconciliation).
- **By Family:** Left-panel family selector → period navigator tabs (CALENDAR_YEAR or PLAN_YEAR labeled) → balance table with cap status indicators → inline impact line trail per employee row.
- **By Employee:** Employee search → accumulator summary across all families → family drill-in to impact trail.
- **Cap enforcement:** Amber ≤10% remaining; red CAP REACHED at 100%; red REVIEW REQUIRED for over-cap (reversal/correction artifact requiring administrator investigation).
- **Retroactivity:** REVERSAL and CORRECTION badges on impact lines; banner warning when balance has been affected by retroactive adjustments.
- **Reset History** at bottom of each family detail panel — audit trail of period resets.
- **Rollup behavior:** `DERIVED` accumulators show a **Derived** badge and no impact trail at the derived scope level (trail is at the source scope). `INDEPENDENT` and `HYBRID` accumulators show full impact trails.
- **Cross-scope validation:** A **SCOPE MISMATCH** banner surfaces on a family's panel when the validation layer detects discrepancies between scope levels.
- IRS calendar-year rule is baked into all tax accumulator period types; operative date (`ITemporalContext.GetOperativeDate()`) drives the current-period determination.

### Repository additions

Extension to the existing accumulator repository layer in `AllWorkHRIS.Module.Payroll`. All queries read from the Value and Impact layers; ANSI SQL only (ADR-004).

### Gate — TC-ACUM test cases

Full test list: `SPEC/Accumulator_Display.md` §10 (TC-ACUM-001 through TC-ACUM-014).

---

## Phase 11 — Reporting (Minimum)

**Goal:** All 16 pre-built operational reports are accessible, filterable, and exportable in CSV, XLSX, and PDF formats.

**Spec:** `SPEC/Reporting_Minimum_Module` (v0.2)
**Project:** `AllWorkHRIS.Module.Reporting` (new class library)
**NuGet packages:** `ClosedXML`, `QuestPDF`

### Deliverables
- Module project setup — references `AllWorkHRIS.Core` only
- `ReportExecutionHistory` domain type
- All 16 report query classes (8 payroll + 8 HR) per SPEC §7
- `IReportHistoryRepository` / `ReportHistoryRepository`
- `CsvExporter`, `XlsxExporter` (ClosedXML), `PdfExporter` (QuestPDF)
- `IReportService`, `IReportExportService`, `IScheduledReportService`
- `ReportingModule` registration and menu contributions
- UI: Payroll Reports hub, HR Reports hub, all 16 individual report pages, Scheduled Reports page — all with `@rendermode InteractiveServer`

### Gate — TC-RPT test cases
- TC-RPT-001: PAY-RPT-001 returns correct data for completed run
- TC-RPT-002: Historical report respects as-of date and Temporal Override
- TC-RPT-003: Unauthorised access rejected
- TC-RPT-005: Manager scope enforced — direct reports only
- TC-RPT-007/008/009: All three export formats download correctly
- TC-RPT-010: All exports audit logged

---

## Phase 12 — Hardening

**Goal:** The platform is production-ready. All test cases pass. Security audit complete. Performance validated at target scale.

### Deliverables

**9.1 — Full automated test suite**
- All TC-HST, TC-HRS, TC-LEV, TC-DOC, TC-PAY, TC-TAX, TC-BEN, TC-TA, TC-RPT test cases implemented as xUnit integration tests
- Integration tests run against real PostgreSQL instance using `Respawn` for database reset between tests
- All test cases passing in CI

**9.1a — Audit Trail UI and Verification**
- Implement `/platform/audit` report page — filter by date range, actor, entity type, event type, outcome; row detail expands before/after JSON; CSV export
- Access gated to `PlatformAdmin` role
- Verify TC-AUD-001 through TC-AUD-007 pass against `allworkhris_dev` data accumulated through Phases 4.12–8
- Verify 7-year retention policy is documented and archival script exists
- Expand audit instrumentation to cover HRIS compensation views, SSN access, and all report exports (TC-AUD-005)

**9.2 — Security hardening**
- OIDC token validation verified per provider
- All sensitive endpoints confirm role enforcement at service layer (not only UI layer)
- SSN / national identifier encryption at rest implemented
- Download audit logging verified for all document access paths
- `TenantScopedConnection` wrapper (ADR-010 Option 2) tested exhaustively for cross-tenant isolation
- `tenant_id` claim validated on every request; missing claim returns 401

**9.3 — Multi-tenant configuration store**
- `tenants` table in platform management database
- `TenantRegistry` reads from database rather than environment config
- All three isolation models (ADR-010) tested

**9.4 — Performance validation**
- 250-employee payroll run completes in under 60 seconds
- Employee List page loads in under 2 seconds with 250 employees
- Pay Register grid renders 250 rows without timeout

**9.5 — Deployment documentation**
- On-premises deployment guide (PostgreSQL + Keycloak)
- Environment variable reference
- Module deployment procedure (drop DLL into `./modules`, restart)
- Schema migration procedure (per-module schema files, apply in order)

### Gate
- All TC-* test cases passing in CI (including TC-TAX-001–019, TC-DASH-001–010)
- No open P1 or P2 security findings
- 250-employee end-to-end run (Hire → Time → Payroll with real tax → Reports) completes cleanly
- On-premises deployment guide validated against a clean machine

---

## Implementation Notes (v1.0)

The following design decisions were recorded when Phase 5 was added to the plan. They extend the v0.9 notes above.

**Pipeline pattern replaces dispatch-by-enum.** The calculation engine does not dispatch to different algorithm types based on a `calc_method` enum. Instead, each tax obligation is a concrete `ICalculationStep` object with a sequence number. The engine runs steps in sequence number order; no topological sort is needed — sequence position guarantees ordering. A `PercentageOfPriorResultStep` at sequence 710 simply reads the named result from `CalculationContext.StepResults` that was written by the step at sequence 610.

**`payroll_calculation_steps` is the unifying registry.** This table replaces the `jurisdiction_taxes` junction concept from the initial sketch. All step types (allowances, deductions, income tax brackets, flat rates, credits, derived taxes) are rows in this table with a `step_type` discriminator and a `sequence_number`. Type-specific configuration (brackets, rates, caps) lives in linked tables (`tax_brackets`, `tax_flat_rates`, `tax_allowances`, `tax_credits`).

**Two-source pipeline assembly.** `PayrollPipelineService` assembles the step list from two sources: (1) jurisdiction steps from `ICalculationStepRepository` — same for all employees in that jurisdiction; (2) employee-specific steps from registered `IBenefitStepProvider` implementations — personal to each employee. Both lists are merged and sorted by `sequence_number` before execution. This is how Benefits (Phase 6) slots its pre-tax elections at sequence 100–199 without any changes to the Tax module or the Payroll engine.

**`CalculationContext` is immutable between steps.** Each step receives a context record and returns a new one. Steps cannot mutate shared state directly; all communication is through `StepResults` (named results by step code) and the explicitly updated fields (`IncomeTaxableWages`, `FicaTaxableWages`, `ComputedTax`, `NetPay`, `EmployerCost`). This makes individual steps unit-testable in isolation with no side effects.

**Tax module is separate from Payroll; pipeline contract is in Core.** `AllWorkHRIS.Module.Tax` registers `IPayrollPipelineService` (Core interface) via Autofac. `NullPayrollPipelineService` is the Host fallback — the payroll engine degrades gracefully to gross=net rather than failing when the Tax module is absent.

**Period cap vs annual cap are distinct.** NY SDI is capped at $0.60 per week (period cap) — an employee paid weekly hits the cap 52 times at $0.60, totalling $31.20/year. NY PFL has an annual cap ($411.91) tracked cumulatively via YTD accumulators. `FlatRateStep` checks `period_cap_amount` first, then `annual_cap_amount` against `ctx.YtdBalances`, in that order.

**Georgia rate confirmation risk.** Georgia's flat rate reductions are revenue-trigger-conditional. The Georgia DOR publishes the confirmed rate typically in October–November each year. The 2026 rate (5.09%) cannot be hardcoded in advance. Seed data for each new Georgia tax year must be staged once the DOR publishes and deployed before December 15 — payroll runs for a January 1 pay date may be initiated as early as December 26 for ACH pre-funding, so new-year rates must be live well before December 31. Because the publication falls within the October form format sweep, Georgia's rate can be confirmed alongside the annual form review. The Tax Rate Reference UI should surface a visible note for Georgia's conditional reduction schedule.

**OBBBA tips and overtime deductions (US Federal) require a separate step.** Qualified Tips and Qualified Overtime reduce the federal income tax base but NOT the FICA base. In the pipeline, this is a `TaxableBaseAdjustmentStep` at sequence ~250 that calls `ctx.WithReducedIncomeTaxableWages(qualifiedAmount)` before the federal `ProgressiveBracketStep` at sequence 310. FICA steps at sequences 510–512 read `ctx.FicaTaxableWages`, which is NOT reduced by this adjustment. OBBBA path deferred to Phase 9 Hardening — step stub should log a warning when non-zero qualified amounts are passed.

**Employee work location drives jurisdiction selection, not step configuration.** `employee_work_locations` with `location_type = 'residence'` causes the NYC steps (sequences 620–629) to be included in the assembly. `location_type = 'work'` causes MCTMT steps (sequences 910–919) to be included for employer-side calculations. Yonkers uses both: the resident surcharge step (sequence 710) is included for residential Yonkers, the non-resident working-in-Yonkers step (sequence 711) for work-location-only Yonkers.

**Configuration changes go through the Configuration UI, not developer SQL.** Rate updates (bracket rows, flat rates, credits) and form field definition changes are managed through the `/config/tax/` UI with a `DRAFT → PENDING_REVIEW → APPROVED → ACTIVE` workflow. No direct SQL updates to configuration tables in production. This applies equally to annual year-end rate updates: `TaxAdmin` creates DRAFT rows with `effective_from = <new year>` months in advance; `ComplianceReviewer` approves them; the engine activates them automatically on `effective_from`. The December 15 deployment deadline requires APPROVED rows in the database — not ACTIVE — before December 15. A `configuration_audit_log` row is written for every status transition.

**Dual wage bases eliminate cross-step contamination.** `CalculationContext` carries `IncomeTaxableWages` and `FicaTaxableWages` as distinct fields. Pre-tax benefit steps set `reduces_income_tax_wages` and/or `reduces_fica_wages` on `payroll_calculation_steps`; the pipeline recalculates both bases at the end of the PreTax phase before running Tax phase steps. Traditional 401(k) contributions reduce `IncomeTaxableWages` only; Section 125 health premiums reduce both. `FlatRateStep` and `TieredFlatStep` for social insurance (sequences 500–599) read `FicaTaxableWages`; `ProgressiveBracketStep` and income-tax `FlatRateStep` read `IncomeTaxableWages`.

**`employee_tax_form_detail` consolidates all form families.** A single table with semantically named typed columns covers W-4 2020+, W-4 legacy, all Category C state withholding certificates, TD1, TD1X, and BB-TD4. Adding a new jurisdiction that uses the same form structure requires only rows in `form_field_definition` — no DDL change. Adding a jurisdiction with a genuinely new field requires a non-breaking column addition to `employee_tax_form_detail`, not a new table. `form_field_definition` controls which columns are active for each form type and enforces required/optional rules at save time.

---

## NuGet Package Reference

| Package | Version | Phase Introduced | Project |
|---|---|---|---|
| `Autofac` | Latest stable | 1 | Core, Host, all modules |
| `Autofac.Extensions.DependencyInjection` | Latest stable | 1 | Host |
| `Dapper` | Latest stable | 1 | Core, all modules |
| `Npgsql` | 10.0.2 | 1 | Core |
| `Microsoft.Data.SqlClient` | Latest stable | 1 | Core (portability) |
| `MySql.Data` | Latest stable | 1 | Core (portability) |
| `Syncfusion.Blazor` | 33.1.44 | 1 | Host |
| `Microsoft.AspNetCore.Authentication.OpenIdConnect` | Latest stable | 1 | Host |
| `Serilog.AspNetCore` | Latest stable | 4.11 | Host |
| `Serilog.Sinks.Console` | Latest stable | 4.11 | Host |
| `Serilog.Sinks.File` | Latest stable | 4.11 | Host |
| `Serilog.Enrichers.Environment` | Latest stable | 4.11 | Host |
| `Serilog.Enrichers.Thread` | Latest stable | 4.11 | Host |
| `ClosedXML` | Latest stable | 8 | Reporting module |
| `QuestPDF` | Latest stable | 8 | Reporting module |
| `xunit` | Latest stable | 1 | Test project |
| `Respawn` | Latest stable | 8 | Test project (database reset between tests) |
