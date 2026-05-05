# Lookup Cache Service — Implementation Spec

| Field | Detail |
|---|---|
| **Document Type** | Implementation Specification |
| **Version** | v0.1 |
| **Status** | Ready for Implementation |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/LookupCache_Spec.md` |

---

## Purpose

Replace all PostgreSQL enum types in the HRIS and Payroll schemas with integer FK columns referencing `lkp_*` lookup tables. Introduce a `ILookupCache` service that loads all lookup tables into memory at startup and provides fast `code → id` and `id → code` resolution throughout the application without per-request database joins.

---

## Context

The schema has been revised (v0.2) to replace all PostgreSQL enum type columns with `integer` FK columns referencing `lkp_*` tables. For example:

```
-- Was:
employment_status  employment_status  NOT NULL

-- Now:
employment_status_id  integer  NOT NULL  -- FK → lkp_employment_status.id
```

All `lkp_*` tables follow a standard structure:
- `id` — SERIAL integer primary key
- `code` — varchar(50), unique — machine-readable value (e.g. `"ACTIVE"`)
- `label` — varchar(100) — display name
- Additional domain-specific columns

Entity tables store the integer `id`. Application code works with `code` strings. The `ILookupCache` is the bridge between the two.

---

## 1. LookupEntry Record

Location: `src/AllWorkHRIS.Core/Lookups/LookupEntry.cs`

```csharp
namespace AllWorkHRIS.Core.Lookups;

public sealed record LookupEntry
{
    public int    Id    { get; init; }
    public string Code  { get; init; } = default!;
    public string Label { get; init; } = default!;
}
```

---

## 2. LookupTables Constants

Location: `src/AllWorkHRIS.Core/Lookups/LookupTables.cs`

One constant per lookup table. Must match the exact database table name.

```csharp
namespace AllWorkHRIS.Core.Lookups;

public static class LookupTables
{
    // HRIS
    public const string PersonStatus           = "lkp_person_status";
    public const string EmployeeEventType      = "lkp_employee_event_type";
    public const string EmploymentType         = "lkp_employment_type";
    public const string EmploymentStatus       = "lkp_employment_status";
    public const string FullPartTimeStatus     = "lkp_full_part_time_status";
    public const string RegularTemporaryStatus = "lkp_regular_temporary_status";
    public const string FlsaClassification     = "lkp_flsa_classification";
    public const string FlsaStatus             = "lkp_flsa_status";
    public const string EeoCategory            = "lkp_eeo_category";
    public const string AssignmentType         = "lkp_assignment_type";
    public const string AssignmentStatus       = "lkp_assignment_status";
    public const string CompensationRateType   = "lkp_compensation_rate_type";
    public const string CompensationStatus     = "lkp_compensation_status";
    public const string PayFrequency           = "lkp_pay_frequency";
    public const string PayrollImpactType      = "lkp_payroll_impact_type";
    public const string ApprovalStatus         = "lkp_approval_status";
    public const string LeaveType              = "lkp_leave_type";
    public const string LeaveStatus            = "lkp_leave_status";
    public const string DocumentType           = "lkp_document_type";
    public const string DocumentStatus         = "lkp_document_status";
    public const string OnboardingPlanStatus   = "lkp_onboarding_plan_status";
    public const string OnboardingTaskType     = "lkp_onboarding_task_type";
    public const string OnboardingTaskStatus   = "lkp_onboarding_task_status";
    public const string OrgUnitType            = "lkp_org_unit_type";
    public const string OrgStatus              = "lkp_org_status";
    public const string WorkLocationType       = "lkp_work_location_type";
    public const string JobStatus              = "lkp_job_status";
    public const string PositionStatus         = "lkp_position_status";

    // Payroll
    public const string ResultClass              = "lkp_result_class";
    public const string RunType                  = "lkp_run_type";
    public const string RunStatus                = "lkp_run_status";
    public const string ResultSetType            = "lkp_result_set_type";
    public const string ResultSetStatus          = "lkp_result_set_status";
    public const string EmployeeResultStatus     = "lkp_employee_result_status";
    public const string ItemStatus               = "lkp_item_status";
    public const string PaymentMethod            = "lkp_payment_method";
    public const string PaymentContext           = "lkp_payment_context";
    public const string CheckStatus              = "lkp_check_status";
    public const string ImpactStatus             = "lkp_impact_status";
    public const string ImpactSourceType         = "lkp_impact_source_type";
    public const string PostingDirection         = "lkp_posting_direction";
    public const string ContributionType         = "lkp_contribution_type";
    public const string AccumulatorFamily        = "lkp_accumulator_family";
    public const string AccumulatorScopeType     = "lkp_accumulator_scope_type";
    public const string AccumulatorBalanceStatus = "lkp_accumulator_balance_status";
    public const string PeriodContext            = "lkp_period_context";
    public const string ScopeType               = "lkp_scope_type";
    public const string ScopeStatus             = "lkp_scope_status";
    public const string PopulationMethod         = "lkp_population_method";
    public const string FundingStatus            = "lkp_funding_status";
    public const string RemittanceStatus         = "lkp_remittance_status";
    public const string DisbursementStatus       = "lkp_disbursement_status";
}
```

---

## 3. ILookupCache Interface

Location: `src/AllWorkHRIS.Core/Lookups/ILookupCache.cs`

```csharp
namespace AllWorkHRIS.Core.Lookups;

public interface ILookupCache
{
    /// <summary>
    /// Resolve a code string to its integer id.
    /// Throws InvalidOperationException if the code is not found.
    /// </summary>
    int GetId(string tableName, string code);

    /// <summary>
    /// Resolve an integer id to its code string.
    /// Throws InvalidOperationException if the id is not found.
    /// </summary>
    string GetCode(string tableName, int id);

    /// <summary>
    /// Get the full LookupEntry for a given code.
    /// Throws InvalidOperationException if the code is not found.
    /// </summary>
    LookupEntry Get(string tableName, string code);

    /// <summary>
    /// Get all active entries for a table, ordered by sort_order.
    /// Used to populate dropdowns and selection lists.
    /// </summary>
    IReadOnlyList<LookupEntry> GetAll(string tableName);

    /// <summary>
    /// Reload all lookup tables from the database.
    /// For admin use — allows new lookup values to be visible
    /// without an application restart.
    /// </summary>
    Task RefreshAsync();
}
```

---

## 4. LookupCache Implementation

Location: `src/AllWorkHRIS.Core/Lookups/LookupCache.cs`

```csharp
using Dapper;
using AllWorkHRIS.Core.Data;

namespace AllWorkHRIS.Core.Lookups;

public sealed class LookupCache : ILookupCache
{
    private readonly IConnectionFactory _connectionFactory;

    // Outer key: table name. Inner key: code. Value: LookupEntry.
    private Dictionary<string, Dictionary<string, LookupEntry>> _byCode = new();

    // Outer key: table name. Inner key: id. Value: LookupEntry.
    private Dictionary<string, Dictionary<int, LookupEntry>> _byId = new();

    public LookupCache(IConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task InitialiseAsync()
    {
        await LoadAsync();
    }

    public async Task RefreshAsync()
    {
        await LoadAsync();
    }

    private async Task LoadAsync()
    {
        var byCode = new Dictionary<string, Dictionary<string, LookupEntry>>(
            StringComparer.OrdinalIgnoreCase);
        var byId = new Dictionary<string, Dictionary<int, LookupEntry>>();

        using var conn = _connectionFactory.CreateConnection();

        foreach (var tableName in AllTables())
        {
            var sql = $"""
                SELECT id, code, label
                FROM {tableName}
                WHERE is_active = true
                ORDER BY sort_order, id
                """;

            var entries = await conn.QueryAsync<LookupEntry>(sql);

            var codeDict = new Dictionary<string, LookupEntry>(
                StringComparer.OrdinalIgnoreCase);
            var idDict = new Dictionary<int, LookupEntry>();

            foreach (var entry in entries)
            {
                codeDict[entry.Code] = entry;
                idDict[entry.Id]     = entry;
            }

            byCode[tableName] = codeDict;
            byId[tableName]   = idDict;
        }

        // Atomic swap — no partial state visible to other threads
        _byCode = byCode;
        _byId   = byId;
    }

    public int GetId(string tableName, string code)
    {
        if (_byCode.TryGetValue(tableName, out var table) &&
            table.TryGetValue(code, out var entry))
            return entry.Id;

        throw new InvalidOperationException(
            $"Lookup code '{code}' not found in table '{tableName}'.");
    }

    public string GetCode(string tableName, int id)
    {
        if (_byId.TryGetValue(tableName, out var table) &&
            table.TryGetValue(id, out var entry))
            return entry.Code;

        throw new InvalidOperationException(
            $"Lookup id '{id}' not found in table '{tableName}'.");
    }

    public LookupEntry Get(string tableName, string code)
    {
        if (_byCode.TryGetValue(tableName, out var table) &&
            table.TryGetValue(code, out var entry))
            return entry;

        throw new InvalidOperationException(
            $"Lookup code '{code}' not found in table '{tableName}'.");
    }

    public IReadOnlyList<LookupEntry> GetAll(string tableName)
    {
        if (_byCode.TryGetValue(tableName, out var table))
            return table.Values.ToList();

        throw new InvalidOperationException(
            $"Lookup table '{tableName}' not found in cache.");
    }

    private static IEnumerable<string> AllTables() =>
        typeof(LookupTables)
            .GetFields(System.Reflection.BindingFlags.Public |
                       System.Reflection.BindingFlags.Static)
            .Where(f => f.IsLiteral)
            .Select(f => (string)f.GetRawConstantValue()!);
}
```

---

## 5. Registration in Program.cs

Register as singleton and initialise before the app starts:

```csharp
// In Autofac container builder block:
autofacBuilder.RegisterType<LookupCache>()
              .As<ILookupCache>()
              .SingleInstance();

// After app.Build(), before app.Run():
var lookupCache = app.Services.GetRequiredService<ILookupCache>() as LookupCache;
await lookupCache!.InitialiseAsync();
```

---

## 6. Refactor Scope

The following files require changes after the lookup cache is in place:

### 6.1 Delete
- `src/AllWorkHRIS.Host/Hris/Domain/Enums.cs` — all C# enums removed

### 6.2 Domain records — replace enum properties with int FK properties
- `src/AllWorkHRIS.Host/Hris/Domain/Person.cs`
- `src/AllWorkHRIS.Host/Hris/Domain/EmploymentAssignmentCompensation.cs`
- `src/AllWorkHRIS.Host/Hris/Domain/EmployeeEvent.cs`
- `src/AllWorkHRIS.Host/Hris/Domain/OrgJobPosition.cs`

Pattern:
```csharp
// Was:
public EmploymentStatus EmploymentStatus { get; init; }
// Becomes:
public int EmploymentStatusId { get; init; }
```

### 6.3 Factory methods — replace Enum.Parse with ILookupCache.GetId
Factory methods on domain records (`CreateNew`, `CreateFromHire`, etc.) currently call `Enum.Parse<T>(command.SomeField)`. These become:

```csharp
// Was:
EmploymentStatus = Enum.Parse<EmploymentStatus>(command.EmploymentStatus, ignoreCase: true)
// Becomes:
EmploymentStatusId = _lookupCache.GetId(LookupTables.EmploymentStatus, command.EmploymentStatus)
```

Factory methods need `ILookupCache` injected or passed as a parameter. Recommend passing as a parameter to keep records free of dependencies:

```csharp
public static Employment CreateFromHire(
    HireEmployeeCommand command,
    Guid personId,
    ILookupCache lookupCache)
```

### 6.4 Repositories — remove all PostgreSQL enum casts
- `src/AllWorkHRIS.Host/Hris/Repositories/HrisRepositories.cs`

Remove all `::enum_type` casts from SQL. Integer columns need no casting:
```sql
-- Was:
@EmploymentStatus::employment_status
-- Becomes:
@EmploymentStatusId
```

Remove `ToDbEnum()` helper method from `OrgUnitRepository`.

Remove all `Enum.Parse<T>()` calls used for query parameters.

### 6.5 Services — replace enum comparisons with code string comparisons
- `src/AllWorkHRIS.Host/Hris/Services/HrisServices.cs`

Services currently compare against C# enum values. Replace with code string comparisons using the lookup cache:

```csharp
// Was:
if (employment.EmploymentStatus == EmploymentStatus.Active)
// Becomes:
if (_lookupCache.GetCode(LookupTables.EmploymentStatus, employment.EmploymentStatusId) == "ACTIVE")
```

Or cache the id values at service construction time:
```csharp
private readonly int _activeStatusId;

public EmploymentService(..., ILookupCache lookupCache)
{
    _activeStatusId = lookupCache.GetId(LookupTables.EmploymentStatus, "ACTIVE");
}

// Then:
if (employment.EmploymentStatusId == _activeStatusId)
```

The second approach is faster and cleaner — recommended.

### 6.6 HireEmployeePanel.razor — load dropdowns from lookup cache
Dropdowns currently bind to hardcoded string option values. Replace with dynamic lists from `ILookupCache.GetAll()`:

```razor
@inject ILookupCache LookupCache

<select @bind="_cmd.EmploymentTypeId">
    <option value="0">— Select —</option>
    @foreach (var entry in LookupCache.GetAll(LookupTables.EmploymentType))
    {
        <option value="@entry.Id">@entry.Label</option>
    }
</select>
```

Commands must be updated to carry integer IDs rather than string codes for fields that map to lookup tables.

### 6.7 Event payloads — no change required
Event payloads in `AllWorkHRIS.Core/Events/` use string fields (`FlsaStatus`, `RateType`, etc.) — these carry the code string, not the integer id. This is correct — events are the integration contract between modules and should carry human-readable codes, not database-specific integer ids. No changes needed.

---

## 7. Database Prerequisites

Before running the application after this refactor, the lookup tables must exist and be populated:

1. Generate DDL from `hcm_hris_lookups.dbml` and `hcm_payroll_lookups.dbml` via `dbml-cli`
2. Apply lookup table DDL to `allworkhris_dev`
3. Run seed data for all lookup tables
4. Regenerate entity DDL from revised `hcm_hris.dbml` and `hcm_payroll_core.dbml`
5. Drop and recreate entity tables (development only — no migration needed at this stage)

---

## 8. Refactor Verification

After the refactor, verify:

1. Application starts and `LookupCache.InitialiseAsync()` completes without error
2. All HRIS dropdowns in `HireEmployeePanel` populate from lookup tables
3. Hire workflow completes end-to-end — Person, Employment, Assignment, Compensation, EmployeeEvent all created with correct integer FK values
4. Employee list page renders correctly
5. No `::enum_type` casts remain in any SQL string
6. No `Enum.Parse<T>()` calls remain in any repository or service
