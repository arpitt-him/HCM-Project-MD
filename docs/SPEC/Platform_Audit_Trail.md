# Platform Audit Trail

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/Platform_Audit_Trail.md` |
| **Date** | May 2026 |
| **Related Documents** | NFR/HCM_NFR_Specification, EXC/EXC-AUD_Audit_Retention_Exceptions, governance/Security_and_Access_Control_Model, governance/Data_Retention_and_Archival_Model |

---

## 1. Two Distinct Concerns

Application observability in AllWorkHRIS is served by two independent mechanisms with different audiences, retention requirements, and query patterns. They must not be conflated.

| | Operational Logging | Audit Trail |
|---|---|---|
| **Tool** | Serilog | `platform_audit_event` table |
| **Audience** | Developers, DevOps | HR, Payroll, Compliance, Legal |
| **Purpose** | System health, errors, performance | Who did what, when, and to what |
| **Retention** | 90 days rolling | 7 years (payroll compliance minimum) |
| **Queryable by** | Log aggregator (Seq, CloudWatch, etc.) | SQL; future audit report UI |
| **Format** | Structured log events | Relational rows with JSON change payload |
| **Written by** | `ILogger<T>` in services | `IAuditService` in services |

---

## 2. Operational Logging — Serilog

### 2.1 Package Set

Added to `AllWorkHRIS.Host.csproj`:

```
Serilog.AspNetCore          — ASP.NET Core integration, request logging
Serilog.Sinks.Console       — structured console output
Serilog.Sinks.File          — rolling file sink
Serilog.Enrichers.Environment — MachineName, EnvironmentName enrichers
Serilog.Enrichers.Thread    — ThreadId enricher
```

Optional (recommended for dev): `Serilog.Sinks.Seq`

### 2.2 Startup Wiring

`Program.cs` — add before `builder.Build()`:

```csharp
builder.Host.UseSerilog((ctx, cfg) =>
    cfg.ReadFrom.Configuration(ctx.Configuration)
       .Enrich.FromLogContext()
       .Enrich.WithMachineName()
       .Enrich.WithEnvironmentUserName());
```

### 2.3 Configuration (`appsettings.json`)

```json
{
  "Serilog": {
    "Using": ["Serilog.Sinks.Console", "Serilog.Sinks.File"],
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "Microsoft.AspNetCore": "Warning",
        "System": "Warning"
      }
    },
    "WriteTo": [
      { "Name": "Console" },
      {
        "Name": "File",
        "Args": {
          "path": "logs/allworkhris-.log",
          "rollingInterval": "Day",
          "retainedFileCountLimit": 30,
          "outputTemplate": "{Timestamp:yyyy-MM-dd HH:mm:ss} [{Level:u3}] {SourceContext}: {Message:lj}{NewLine}{Exception}"
        }
      }
    ]
  }
}
```

### 2.4 Usage Pattern

- Inject `ILogger<T>` into services and repositories — never into Razor pages.
- Log at the right level:
  - `Debug` — SQL parameter values, cache hits/misses, calculation step entry/exit
  - `Information` — user-initiated actions that succeed (run initiated, period generated, employee hired)
  - `Warning` — unusual but handled conditions (53rd period detected, cutoff date in the past, validation failure on user input)
  - `Error` — unhandled exceptions, DB errors, external service failures
  - `Fatal` — startup failures only

### 2.5 Structured Property Convention

Always use named message-template placeholders. The placeholder name becomes a first-class searchable property in every structured log aggregator (Seq, CloudWatch Insights, ELK, Splunk). String interpolation bakes the value into the rendered string and destroys its identity as a queryable field.

```csharp
// Correct — {RunId} and {ContextId} are indexable properties; filter by them in Seq
_logger.LogInformation("Payroll run {RunId} initiated for context {ContextId}", runId, contextId);

// Wrong — value lost inside rendered string; not filterable
_logger.LogInformation($"Payroll run {runId} initiated");
```

**Enforced at build time via Roslyn rule CA2254.** Add to `.editorconfig` at the solution root:

```ini
[*.cs]
dotnet_diagnostic.CA2254.severity = error
```

CA2254 ships in the .NET SDK analyzer set (`Microsoft.CodeAnalysis.NetAnalyzers`) — no additional NuGet package required. Any `ILogger` call that receives an interpolated string or a non-constant template fails the build. `string.Format(...)` is equally prohibited.

**Placeholder naming rules:**
- Use `PascalCase` — `{EmployeeId}`, `{RunId}`, `{ContextId}`, `{Status}`
- Match the domain name, not the local variable name — `{EmployeeId}` not `{id}`
- Qualify when the name alone is ambiguous — `{PayrollPeriodId}` not `{PeriodId}`

**High-frequency hot paths** (calculation engine inner loop) should use the `[LoggerMessage]` source generator instead of `LogInformation(...)` directly. This produces a zero-allocation log call and enforces the structured template at compile time — no CA2254 risk at runtime:

```csharp
public static partial class PayrollLogMessages
{
    [LoggerMessage(Level = LogLevel.Debug,
        Message = "Calculating earnings for employee {EmployeeId} in period {PeriodId}")]
    public static partial void CalculatingEarnings(
        this ILogger logger, Guid employeeId, Guid periodId);
}
```

---

## 3. Audit Trail — `platform_audit_event`

### 3.1 Scope — What Is Audited

The following operations produce an audit event. Events NOT in this list are not audited here — they may be covered by existing domain tables (see §3.2).

**Authentication**
- User login (success and failure)
- User logout

**HRIS**
- Employment status changes (hire, terminate, rehire, leave, return)
- Compensation record changes
- Role assignment changes
- Document download (in addition to existing `document_download_audit` — see note in §3.2)

**Payroll**
- Payroll context: create, status change, delete
- Payroll period: generate (batch), individual run-date edit, status change
- Payroll run: initiate, approve, cancel, release
- Payroll profile: enroll, disenroll

**System / Admin**
- Any action that modifies configuration or reference data accessible to only one role

**Sensitive Data Access**
- SSN / national identifier views
- Salary / compensation rate views by non-HR roles
- Any export of a dataset containing PII

### 3.2 What Is Not Double-Audited

These events are already captured in dedicated domain tables and do not need a parallel `platform_audit_event` row:

| Event | Covered By |
|---|---|
| Employee lifecycle events (hire, terminate, comp change) | `employee_event` table |
| Document download | `document_download_audit` table |
| Payroll result lines | Immutable accumulator chain; result lineage is self-auditing |
| Leave request lifecycle | `leave_request` status history (status + timestamps on the row) |

### 3.3 Table Design

```dbml
Table platform_audit_event {
  audit_event_id      uuid         [pk, not null,   note: "System-generated"]
  tenant_id           uuid         [not null,       note: "Owning tenant"]
  event_timestamp     timestamptz  [not null,       note: "Server UTC time of the event"]
  event_type          varchar(50)  [not null,       note: "Verb: CREATE | UPDATE | DELETE | STATUS_CHANGE | VIEW | EXPORT | LOGIN | LOGOUT | LOGIN_FAILED | ENROLL | DISENROLL"]
  module_name         varchar(30)  [null,           note: "HRIS | PAYROLL | BENEFITS | TIME | REPORTING | PLATFORM"]
  entity_type         varchar(100) [not null,       note: "Domain object name: PayrollRun, PayrollContext, Employment, CompensationRecord, etc."]
  entity_id           uuid         [null,           note: "PK of the affected record; null for login events"]
  parent_entity_type  varchar(100) [null,           note: "Owning entity type for context, e.g. PayrollContext when entity is PayrollPeriod"]
  parent_entity_id    uuid         [null,           note: "PK of the owning record"]
  actor_user_id       uuid         [not null,       note: "Keycloak subject claim of the authenticated user"]
  actor_display_name  varchar(200) [null,           note: "Denormalised display name at time of event"]
  change_summary      varchar(500) [null,           note: "Human-readable one-line description of what changed"]
  before_state_json   text         [null,           note: "JSON snapshot of changed fields before the operation"]
  after_state_json    text         [null,           note: "JSON snapshot of changed fields after the operation"]
  outcome             varchar(20)  [not null,       note: "SUCCESS | FAILURE | PARTIAL"]
  failure_reason      varchar(500) [null,           note: "Populated when outcome = FAILURE"]
  ip_address          varchar(45)  [null,           note: "IPv4 or IPv6 of the client connection"]
  session_id          varchar(200) [null,           note: "Blazor circuit ID or HTTP session ID"]

  indexes {
    tenant_id
    event_timestamp
    actor_user_id
    (entity_type, entity_id)
    (tenant_id, event_timestamp)
    (tenant_id, entity_type, entity_id)
  }
}
```

### 3.4 JSON Change Payload Convention

`before_state_json` and `after_state_json` carry only the fields that are relevant to the event — not a full entity snapshot. For a status change on a payroll period:

```json
// before_state_json
{ "calendar_status": "OPEN", "calculation_date": null }

// after_state_json
{ "calendar_status": "CLOSED", "calculation_date": "2027-01-21" }
```

For a CREATE event: `before_state_json` is null; `after_state_json` contains the initial field values.
For a DELETE event: `before_state_json` contains the last known values; `after_state_json` is null.

**Sensitive fields are never placed in the JSON payload.** SSN, bank account numbers, and salary rates must not appear as plain text in audit rows. Record that a sensitive field was changed, not what it changed to.

### 3.5 IAuditService Interface

Placed in `AllWorkHRIS.Core` so all module assemblies can consume it.

```csharp
// AllWorkHRIS.Core/Audit/IAuditService.cs

public sealed record AuditEventRecord(
    string   EventType,
    string   EntityType,
    Guid?    EntityId,
    string   ModuleName,
    string   ChangeSummary,
    string?  BeforeJson       = null,
    string?  AfterJson        = null,
    string?  ParentEntityType = null,
    Guid?    ParentEntityId   = null,
    string   Outcome          = "SUCCESS",
    string?  FailureReason    = null
);

public interface IAuditService
{
    Task LogAsync(AuditEventRecord auditEvent);
}
```

### 3.6 Implementation

`AuditService` lives in `AllWorkHRIS.Host` (access to `IConnectionFactory`, `IHttpContextAccessor`).

```csharp
public sealed class AuditService : IAuditService
{
    // Resolves: tenant_id, actor_user_id, actor_display_name,
    //           ip_address, session_id from context
    // Writes a single INSERT to platform_audit_event
    // On failure: logs to ILogger<AuditService> at Error level;
    //             does NOT rethrow — main operation is not rolled back
}
```

A `NullAuditService` (no-op) is registered in Core as the fallback. `AuditService` overrides it in Host, following the same Autofac last-registration-wins pattern used for `IPayrollContextLookup`.

### 3.7 Module Integration Pattern

Services call `IAuditService` after the primary operation completes (and commits). The audit write is fire-and-log — a failure to write the audit row is logged at `Error` level via Serilog but does not cause the main operation to fail or rollback.

```csharp
// Example: PayrollContextRepository.InsertContextAsync
await conn.ExecuteAsync(insertSql, ...);           // primary write
await _auditService.LogAsync(new AuditEventRecord( // audit write
    EventType:     "CREATE",
    EntityType:    "PayrollContext",
    EntityId:      context.PayrollContextId,
    ModuleName:    "PAYROLL",
    ChangeSummary: $"Created payroll context {context.PayrollContextCode}"
));
```

Services that already inject `ILogger<T>` do not need to duplicate the log entry — `AuditService` writes the DB row; Serilog writes the operational log.

### 3.8 Tenant ID Resolution

`tenant_id` on every audit row is resolved from the `tenant_id` claim in the authenticated user's JWT. The `AuditService` reads this from `IHttpContextAccessor.HttpContext.User`. If no tenant claim is present (system-initiated background job), `tenant_id` is set to the configured platform tenant ID.

### 3.9 Retention

- **Platform audit events: 7 years minimum** — required by payroll compliance (FLSA recordkeeping, IRS).
- Archival strategy: rows older than 7 years are moved to a `platform_audit_event_archive` table; never hard-deleted unless legal hold is lifted.
- Operational (Serilog) logs: 30-day rolling file retention; extended in production via log aggregator policy.

---

## 4. Audit Report UI

A minimal audit report page (`/platform/audit`) is planned for Phase 8 Hardening. It provides:

- Filter by: date range, actor, entity type, event type, outcome
- Sortable table: timestamp, actor, entity type, entity ID, event type, summary, outcome
- Row detail expand: shows before/after JSON side by side
- Export to CSV

Access: `PlatformAdmin` role only.

This page intentionally deferred — the audit data accumulates from Phase 4.12 onwards regardless of when the UI ships.

---

## 5. DBML File

The `platform_audit_event` table lives in a new DBML file:

```
schemas/dbml/hcm_platform.dbml
```

This file will also host future platform-level tables (tenant configuration, scheduled job log, etc.) that do not belong to any specific module schema.

---

## 6. Test Cases

| ID | Case |
|---|---|
| TC-AUD-001 | Creating a payroll context writes a CREATE audit event with correct entity_type, entity_id, actor, and module |
| TC-AUD-002 | Changing a payroll period run date writes an UPDATE event with before/after JSON showing the old and new dates |
| TC-AUD-003 | Initiating a payroll run writes an event; approving writes a second; cancelling writes a third |
| TC-AUD-004 | An AuditService write failure logs at Error level via Serilog but the primary operation outcome is unaffected |
| TC-AUD-005 | Salary fields do not appear in plain text in before/after JSON |
| TC-AUD-006 | Audit events are correctly scoped to tenant_id — cross-tenant query returns no rows |
| TC-AUD-007 | NullAuditService registered in isolation test — HRIS module functions with no audit table present |
