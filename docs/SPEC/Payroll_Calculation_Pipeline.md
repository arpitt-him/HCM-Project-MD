# SPEC — Payroll Calculation Pipeline

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll / Tax |
| **Location** | `docs/SPEC/Payroll_Calculation_Pipeline.md` |
| **Related Documents** | SPEC/Payroll_Core_Module §8 (ordered computation flow), ADR-011_Module_Boundary_Tax, PRD-0600_Jurisdiction_Model, SPEC/Benefits_Minimum_Module, `file-xchg/Payroll Tax Rules Reference - Barbados, Canada-Fed, US-Fed, NY, CA and GA.docx` |

---

## Purpose

Defines the implementation-ready specification for the Payroll Calculation Pipeline — the ordered, data-driven system that calculates employee and employer tax withholdings, social insurance contributions, and pre/post-tax deductions during a payroll run.

The pipeline replaces the four stub calls in `Payroll_Core_Module.md §8` (Steps 3, 6, 7, 8) with a single `IPayrollPipelineService.RunAsync` invocation. It is implemented in the `AllWorkHRIS.Module.Tax` module. The pipeline is jurisdiction-agnostic at the Core level — jurisdiction behaviour is expressed entirely through data-driven `ICalculationStep` objects loaded from the database.

This document covers: module assembly structure, Core contracts, the seven step type implementations, pipeline assembly (jurisdiction steps + benefit steps), the sequence number convention, the database schema (thirteen tables), cap tracking, jurisdiction seed configuration for the six jurisdictions in scope, integration with `CalculationEngine`, the `IBenefitStepProvider` seam for Benefits module integration, and test cases.

---

## 1. Module Assembly Structure

```
AllWorkHRIS.Module.Tax/
│
├── TaxModule.cs                              # IPlatformModule implementation
│
├── Domain/
│   ├── CalculationStep.cs                    # Base record — shared fields for all step types
│   ├── StepAppliesTo.cs                      # Enum — Employee | Employer | Both
│   └── TaxJurisdiction.cs                    # Jurisdiction reference record
│
├── Steps/
│   ├── StandardDeductionStep.cs              # Subtracts fixed annual amount / pay periods
│   ├── AllowanceStep.cs                      # Subtracts per-allowance annual amount / pay periods
│   ├── ProgressiveBracketStep.cs             # Annualise → bracket lookup → de-annualise
│   ├── CreditStep.cs                         # Reduces computed tax by annual credit / pay periods
│   ├── FlatRateStep.cs                       # rate × taxable base; period and annual cap support
│   ├── TieredFlatStep.cs                     # NIS / CPP / CPP2 — rate applies within wage tier
│   └── PercentageOfPriorResultStep.cs        # rate × StepResults[dependsOnStepCode]
│
├── Services/
│   ├── PayrollPipelineService.cs             # IPayrollPipelineService implementation
│   └── TaxRateRepository.cs                 # Loads effective-dated step config from DB
│
├── Repositories/
│   ├── ITaxRateRepository.cs
│   └── ITaxFormSubmissionRepository.cs      # Loads employee_tax_form_submission + detail tables
│
└── Queries/
    └── TaxQueryTypes.cs                      # BracketRow, FlatRateRow, AllowanceRow, CreditRow, EmployeeFilingProfile
```

---

## 2. TaxModule Registration

```csharp
[Export(typeof(IPlatformModule))]
public sealed class TaxModule : IPlatformModule
{
    public void Register(ContainerBuilder builder)
    {
        builder.RegisterType<TaxRateRepository>()
               .As<ITaxRateRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<TaxFormSubmissionRepository>()
               .As<ITaxFormSubmissionRepository>()
               .InstancePerLifetimeScope();

        builder.RegisterType<PayrollPipelineService>()
               .As<IPayrollPipelineService>()
               .InstancePerLifetimeScope();
    }

    public IEnumerable<MenuContribution> GetMenuContributions() =>
    [
        new MenuContribution
        {
            Label        = "Tax Rates",
            Href         = "/config/tax-rates",
            Icon         = "icon-tax",
            SortOrder    = 5,
            ParentLabel  = "Configuration",
            RequiredRole = "SystemAdmin"
        }
    ];
}
```

---

## 3. Core Contracts

All types in this section are defined in `AllWorkHRIS.Core`. No type in this section may reference any type in `AllWorkHRIS.Module.Tax` or any other module.

### 3.1 ICalculationStep

```csharp
public interface ICalculationStep
{
    string StepCode { get; }
    int SequenceNumber { get; }
    StepAppliesTo AppliesTo { get; }

    Task<CalculationContext> ExecuteAsync(CalculationContext ctx, CancellationToken ct = default);
}

public enum StepAppliesTo { Employee, Employer, Both }
```

### 3.2 CalculationContext

`CalculationContext` is an immutable record. Each step returns a new instance via `with` expressions. No step mutates a shared object.

Multiple wage bases are maintained separately because not all pre-tax deductions reduce the same bases. A traditional 401(k) reduces `IncomeTaxableWages` only; a Section 125 health premium reduces both. FICA steps must read `FicaTaxableWages`, not `IncomeTaxableWages`. Both are initialised to `GrossPayPeriod` at context creation; pre-tax steps (Phase 6) update them via the mutators below.

```csharp
public sealed record CalculationContext
{
    // Identity
    public Guid EmployeeId        { get; init; }
    public Guid PayrollContextId  { get; init; }
    public Guid PeriodId          { get; init; }
    public DateOnly PayDate       { get; init; }
    public int PayPeriodsPerYear  { get; init; }

    // Jurisdiction
    public string JurisdictionCode { get; init; } = string.Empty;

    // Wage figures — initialised at context creation; updated by pre-tax phase steps
    public decimal GrossPayPeriod     { get; init; }   // period gross before any deductions; unchanged throughout
    public decimal AnnualizedGross    { get; init; }   // GrossPayPeriod × PayPeriodsPerYear
    public decimal IncomeTaxableWages { get; init; }   // reduced by income-tax-reducing pre-tax steps; used by ProgressiveBracketStep and income-tax FlatRateStep
    public decimal FicaTaxableWages   { get; init; }   // reduced by FICA-reducing pre-tax steps; used by social-insurance FlatRateStep and TieredFlatStep
    public decimal DisposableIncome   { get; init; }   // updated after Tax phase; used by garnishment steps (Phase 6+)

    // Running totals
    public decimal ComputedTax  { get; init; }   // sum of all employee tax amounts so far
    public decimal NetPay       { get; init; }   // GrossPayPeriod − all employee-side deductions so far
    public decimal EmployerCost { get; init; }   // employer-side costs accumulator; does not reduce NetPay

    // Named results for cross-step reads (e.g. Yonkers reading NY state tax)
    public ImmutableDictionary<string, decimal> StepResults { get; init; }
        = ImmutableDictionary<string, decimal>.Empty;

    // YTD accumulator balances for cap enforcement
    public ImmutableDictionary<string, decimal> YtdBalances { get; init; }
        = ImmutableDictionary<string, decimal>.Empty;

    // Employee filing profile — resolved from employee_tax_form_submission and employee_tax_form_detail.
    // Common promoted columns (all form types):
    public string? FilingStatusCode      { get; init; }
    public int     AllowanceCount        { get; init; }
    public decimal AdditionalWithholding { get; init; }  // extra per-period withholding (W-4 Step 4c, TD1 extra tax)
    public bool    ExemptFlag            { get; init; }
    public bool    IsLegacyForm          { get; init; }  // TRUE for pre-2020 W-4 submissions

    // Form-specific columns from employee_tax_form_detail — zero/null when not applicable to form type:
    public decimal OtherIncomeAmount { get; init; }  // W-4 2020+ Step 4a — added to annualised income base before bracket walk
    public decimal DeductionsAmount  { get; init; }  // W-4 2020+ Step 4b — subtracted from annualised income base before bracket walk
    public decimal CreditsAmount     { get; init; }  // W-4 2020+ Step 3 — reduces annual tax after bracket walk
    public int?    ClaimCode         { get; init; }  // TD1 — CRA standard code 1–10; null when TotalClaimAmount is used
    public decimal TotalClaimAmount  { get; init; }  // TD1 — custom worksheet total; zero when ClaimCode is used

    // Convenience mutators — return new instances

    // Called by income-tax-reducing pre-tax steps (e.g. traditional 401k, Section 125 health premium)
    public CalculationContext WithReducedIncomeTaxableWages(decimal reduction)
        => this with
        {
            IncomeTaxableWages = Math.Max(0, IncomeTaxableWages - reduction),
            NetPay             = NetPay - reduction
        };

    // Called by FICA-reducing pre-tax steps (e.g. Section 125 health premium — reduces both bases)
    public CalculationContext WithReducedFicaTaxableWages(decimal reduction)
        => this with { FicaTaxableWages = Math.Max(0, FicaTaxableWages - reduction) };

    // Called by employee-side tax and deduction steps
    public CalculationContext WithStepResult(string stepCode, decimal amount)
        => this with
        {
            StepResults = StepResults.SetItem(stepCode, amount),
            ComputedTax = ComputedTax + amount,
            NetPay      = NetPay - amount
        };

    // Called by employer-only steps — does not reduce NetPay
    public CalculationContext WithEmployerStepResult(string stepCode, decimal amount)
        => this with
        {
            StepResults  = StepResults.SetItem(stepCode, amount),
            EmployerCost = EmployerCost + amount
        };
}
```

### 3.3 IPayrollPipelineService

```csharp
public interface IPayrollPipelineService
{
    /// <summary>
    /// Assembles and executes all applicable steps for the employee's jurisdiction,
    /// merged with any registered IBenefitStepProvider steps, ordered by SequenceNumber.
    /// Returns the final CalculationContext after all steps have run.
    /// </summary>
    Task<CalculationContext> RunAsync(CalculationContext ctx, CancellationToken ct = default);

    /// <summary>
    /// Returns the ordered list of steps that would be executed for the given jurisdiction
    /// and effective date. Used by the Tax Rate Reference UI and for diagnostics.
    /// </summary>
    Task<IReadOnlyList<ICalculationStep>> GetStepsForJurisdictionAsync(
        string jurisdictionCode, DateOnly asOf, CancellationToken ct = default);
}
```

### 3.4 IBenefitStepProvider

The Benefits module implements this interface and registers it in Autofac. `PayrollPipelineService` resolves all registered `IBenefitStepProvider` implementations and calls each one during step assembly. This decouples the Tax module from the Benefits module.

```csharp
public interface IBenefitStepProvider
{
    Task<IReadOnlyList<ICalculationStep>> GetStepsForEmployeeAsync(
        Guid employeeId, DateOnly asOf, CancellationToken ct = default);
}
```

### 3.5 NullPayrollPipelineService

Registered by `Host/Program.cs` as the fallback. Returns the context unchanged, logs a warning that no pipeline is registered. This allows the Payroll module to build and run without the Tax module present.

```csharp
public sealed class NullPayrollPipelineService : IPayrollPipelineService
{
    private readonly ILogger<NullPayrollPipelineService> _logger;

    public NullPayrollPipelineService(ILogger<NullPayrollPipelineService> logger)
        => _logger = logger;

    public Task<CalculationContext> RunAsync(CalculationContext ctx, CancellationToken ct = default)
    {
        _logger.LogWarning("No IPayrollPipelineService registered — tax and deduction pipeline skipped for employee {EmployeeId}", ctx.EmployeeId);
        return Task.FromResult(ctx);
    }

    public Task<IReadOnlyList<ICalculationStep>> GetStepsForJurisdictionAsync(
        string jurisdictionCode, DateOnly asOf, CancellationToken ct = default)
        => Task.FromResult<IReadOnlyList<ICalculationStep>>(Array.Empty<ICalculationStep>());
}
```

---

## 4. Step Type Implementations

All seven step types implement `ICalculationStep`. Each is instantiated by `PayrollPipelineService` after loading the relevant rate row(s) from the database.

### 4.1 StandardDeductionStep

Reduces `IncomeTaxableWages` by a fixed annual amount divided by pay periods. Used for US standard deduction, Barbados personal allowance, etc.

```csharp
public sealed class StandardDeductionStep : ICalculationStep
{
    public string StepCode      { get; }
    public int SequenceNumber   { get; }
    public StepAppliesTo AppliesTo => StepAppliesTo.Employee;

    private readonly decimal _annualAmount;

    public StandardDeductionStep(string stepCode, int sequenceNumber, decimal annualAmount)
    {
        StepCode       = stepCode;
        SequenceNumber = sequenceNumber;
        _annualAmount  = annualAmount;
    }

    public Task<CalculationContext> ExecuteAsync(CalculationContext ctx, CancellationToken ct = default)
    {
        if (ctx.ExemptFlag) return Task.FromResult(ctx);
        var periodDeduction = _annualAmount / ctx.PayPeriodsPerYear;
        return Task.FromResult(ctx.WithReducedIncomeTaxableWages(periodDeduction));
    }
}
```

### 4.2 AllowanceStep

Reduces `IncomeTaxableWages` by (allowance count × per-allowance annual amount) / pay periods. Used for US W-4 allowances (legacy format) and equivalent state allowance forms.

```csharp
public sealed class AllowanceStep : ICalculationStep
{
    public string StepCode      { get; }
    public int SequenceNumber   { get; }
    public StepAppliesTo AppliesTo => StepAppliesTo.Employee;

    private readonly decimal _annualAmountPerAllowance;

    public AllowanceStep(string stepCode, int sequenceNumber, decimal annualAmountPerAllowance)
    {
        StepCode                  = stepCode;
        SequenceNumber            = sequenceNumber;
        _annualAmountPerAllowance = annualAmountPerAllowance;
    }

    public Task<CalculationContext> ExecuteAsync(CalculationContext ctx, CancellationToken ct = default)
    {
        if (ctx.ExemptFlag || ctx.AllowanceCount == 0) return Task.FromResult(ctx);
        var periodDeduction = ctx.AllowanceCount * _annualAmountPerAllowance / ctx.PayPeriodsPerYear;
        return Task.FromResult(ctx.WithReducedIncomeTaxableWages(periodDeduction));
    }
}
```

### 4.3 ProgressiveBracketStep

Annualises the period `IncomeTaxableWages`, applies progressive brackets, de-annualises the result to a period withholding amount. Brackets are filtered by `FilingStatusCode` when present.

**Form-specific adjustments:** `OtherIncomeAmount` and `DeductionsAmount` (from `employee_tax_form_detail`, promoted to `CalculationContext`) are added/subtracted from the annualised base before the bracket walk, per IRS Pub 15-T (W-4 2020+ Steps 4a/4b). `CreditsAmount` (W-4 Step 3) is subtracted from the computed annual tax after the bracket walk. These fields default to zero for employees who filed legacy W-4s or forms that do not use these fields, so the same step implementation handles all form variants without branching.

```csharp
public sealed class ProgressiveBracketStep : ICalculationStep
{
    public string StepCode      { get; }
    public int SequenceNumber   { get; }
    public StepAppliesTo AppliesTo => StepAppliesTo.Employee;

    private readonly IReadOnlyList<BracketRow> _brackets;  // ordered by lower_limit ascending

    public ProgressiveBracketStep(string stepCode, int sequenceNumber, IReadOnlyList<BracketRow> brackets)
    {
        StepCode       = stepCode;
        SequenceNumber = sequenceNumber;
        _brackets      = brackets;
    }

    public Task<CalculationContext> ExecuteAsync(CalculationContext ctx, CancellationToken ct = default)
    {
        if (ctx.ExemptFlag) return Task.FromResult(ctx);

        // Annualise income-taxable wages; adjust with form-specific other income and deductions
        var annualTaxable = ctx.IncomeTaxableWages * ctx.PayPeriodsPerYear
                            + ctx.OtherIncomeAmount
                            - ctx.DeductionsAmount;
        annualTaxable = Math.Max(0, annualTaxable);

        var annualTax = 0m;
        foreach (var bracket in _brackets)
        {
            if (annualTaxable <= bracket.LowerLimit) break;
            var top    = bracket.UpperLimit.HasValue ? Math.Min(annualTaxable, bracket.UpperLimit.Value) : annualTaxable;
            var slice  = top - bracket.LowerLimit;
            annualTax += slice * bracket.Rate;
        }

        // Subtract form-declared credits from annual tax before de-annualising (non-refundable: floor at 0)
        annualTax = Math.Max(0, annualTax - ctx.CreditsAmount);

        var periodTax = annualTax / ctx.PayPeriodsPerYear + ctx.AdditionalWithholding;
        return Task.FromResult(ctx.WithStepResult(StepCode, Math.Max(0, periodTax)));
    }
}

public sealed record BracketRow(decimal LowerLimit, decimal? UpperLimit, decimal Rate);
```

### 4.4 CreditStep

Reduces the already-computed tax by an annual credit amount divided by pay periods. The credit cannot reduce tax below zero. Used for Canada's BPA credit.

```csharp
public sealed class CreditStep : ICalculationStep
{
    public string StepCode      { get; }
    public int SequenceNumber   { get; }
    public StepAppliesTo AppliesTo => StepAppliesTo.Employee;

    private readonly decimal _annualCredit;
    private readonly decimal _creditRate;   // credit = annualCredit × creditRate; used for BPA (15%)

    public CreditStep(string stepCode, int sequenceNumber, decimal annualCredit, decimal creditRate)
    {
        StepCode       = stepCode;
        SequenceNumber = sequenceNumber;
        _annualCredit  = annualCredit;
        _creditRate    = creditRate;
    }

    public Task<CalculationContext> ExecuteAsync(CalculationContext ctx, CancellationToken ct = default)
    {
        if (ctx.ExemptFlag) return Task.FromResult(ctx);
        var periodCreditValue = _annualCredit * _creditRate / ctx.PayPeriodsPerYear;
        // Credit reduces computed tax — stored as a negative step result
        var effectiveCredit = Math.Min(periodCreditValue, ctx.ComputedTax);
        return Task.FromResult(ctx.WithStepResult(StepCode, -effectiveCredit));
    }
}
```

### 4.5 FlatRateStep

Applies a flat rate to a period wage base (or annual wage base ceiling, whichever produces the lower period amount). Enforces an optional per-period cap and an optional annual cap via YTD balances. Used for EI, MCTMT, PFL, SDI.

`useFicaTaxableWages` controls which wage base is read from context. Social-insurance steps (sequence 500–599) set this flag and read `FicaTaxableWages`; income-tax flat-rate steps read `IncomeTaxableWages`. The flag is determined at pipeline assembly time from the step's `calculation_category`.

```csharp
public sealed class FlatRateStep : ICalculationStep
{
    public string StepCode      { get; }
    public int SequenceNumber   { get; }
    public StepAppliesTo AppliesTo { get; }

    private readonly decimal  _rate;
    private readonly decimal? _wageBase;
    private readonly decimal? _periodCap;
    private readonly decimal? _annualCap;
    private readonly bool     _useFicaTaxableWages;

    public FlatRateStep(string stepCode, int sequenceNumber, StepAppliesTo appliesTo,
        decimal rate, decimal? wageBase, decimal? periodCap, decimal? annualCap,
        bool useFicaTaxableWages = false)
    {
        StepCode             = stepCode;
        SequenceNumber       = sequenceNumber;
        AppliesTo            = appliesTo;
        _rate                = rate;
        _wageBase            = wageBase;
        _periodCap           = periodCap;
        _annualCap           = annualCap;
        _useFicaTaxableWages = useFicaTaxableWages;
    }

    public Task<CalculationContext> ExecuteAsync(CalculationContext ctx, CancellationToken ct = default)
    {
        if (ctx.ExemptFlag) return Task.FromResult(ctx);

        var periodWages = _useFicaTaxableWages ? ctx.FicaTaxableWages : ctx.IncomeTaxableWages;

        var base_ = _wageBase.HasValue
            ? Math.Min(periodWages, _wageBase.Value / ctx.PayPeriodsPerYear)
            : periodWages;

        var raw = base_ * _rate;

        // Apply period cap
        if (_periodCap.HasValue)
            raw = Math.Min(raw, _periodCap.Value);

        // Apply annual cap via YTD balance
        if (_annualCap.HasValue && ctx.YtdBalances.TryGetValue(StepCode, out var ytd))
        {
            var remaining = Math.Max(0, _annualCap.Value - ytd);
            raw = Math.Min(raw, remaining);
        }

        return Task.FromResult(
            AppliesTo == StepAppliesTo.Employer
                ? ctx.WithEmployerStepResult(StepCode, Math.Max(0, raw))
                : ctx.WithStepResult(StepCode, Math.Max(0, raw)));
    }
}
```

### 4.6 TieredFlatStep

Applies a flat rate only within a wage tier (lower_limit to upper_limit). Enforces period and annual caps. Used for NIS (Barbados), CPP, CPP2 (Canada). Multiple tier rows may exist per step — each row applies the rate to the slice of wages within that tier.

Tier thresholds are annual amounts. The step annualises `FicaTaxableWages` for the bracket walk (social insurance contributions apply to FICA-adjusted earnings, not full gross), then de-annualises the result.

```csharp
public sealed class TieredFlatStep : ICalculationStep
{
    public string StepCode      { get; }
    public int SequenceNumber   { get; }
    public StepAppliesTo AppliesTo { get; }

    private readonly IReadOnlyList<TieredBracketRow> _tiers;

    public TieredFlatStep(string stepCode, int sequenceNumber, StepAppliesTo appliesTo,
        IReadOnlyList<TieredBracketRow> tiers)
    {
        StepCode       = stepCode;
        SequenceNumber = sequenceNumber;
        AppliesTo      = appliesTo;
        _tiers         = tiers;
    }

    public Task<CalculationContext> ExecuteAsync(CalculationContext ctx, CancellationToken ct = default)
    {
        if (ctx.ExemptFlag) return Task.FromResult(ctx);

        var annualGross = ctx.FicaTaxableWages * ctx.PayPeriodsPerYear;
        var total       = 0m;

        foreach (var tier in _tiers)
        {
            if (annualGross <= tier.LowerLimit) continue;
            var top   = tier.UpperLimit.HasValue ? Math.Min(annualGross, tier.UpperLimit.Value) : annualGross;
            var slice = top - tier.LowerLimit;
            var raw   = slice * tier.Rate;

            if (tier.PeriodCap.HasValue)
                raw = Math.Min(raw, tier.PeriodCap.Value * ctx.PayPeriodsPerYear);

            total += raw;

            if (tier.AnnualCap.HasValue)
                total = Math.Min(total, tier.AnnualCap.Value);
        }

        var periodAmount = total / ctx.PayPeriodsPerYear;

        // Apply annual cap via YTD
        if (_tiers.Any(t => t.AnnualCap.HasValue))
        {
            var annualCap = _tiers.Select(t => t.AnnualCap).Where(c => c.HasValue).Max()!.Value;
            if (ctx.YtdBalances.TryGetValue(StepCode, out var ytd))
                periodAmount = Math.Min(periodAmount, Math.Max(0, annualCap - ytd));
        }

        return Task.FromResult(
            AppliesTo == StepAppliesTo.Employer
                ? ctx.WithEmployerStepResult(StepCode, Math.Max(0, periodAmount))
                : ctx.WithStepResult(StepCode, Math.Max(0, periodAmount)));
    }
}

public sealed record TieredBracketRow(
    decimal LowerLimit, decimal? UpperLimit, decimal Rate, decimal? PeriodCap, decimal? AnnualCap);
```

### 4.7 PercentageOfPriorResultStep

Reads the result of a prior step from `ctx.StepResults` and applies a rate to it. Used for the Yonkers surcharge (16.75% of NY state income tax). The `DependsOnStepCode` must correspond to a step with a lower `SequenceNumber`.

```csharp
public sealed class PercentageOfPriorResultStep : ICalculationStep
{
    public string StepCode          { get; }
    public int SequenceNumber       { get; }
    public StepAppliesTo AppliesTo  => StepAppliesTo.Employee;

    private readonly string  _dependsOnStepCode;
    private readonly decimal _rate;

    public PercentageOfPriorResultStep(string stepCode, int sequenceNumber,
        string dependsOnStepCode, decimal rate)
    {
        StepCode           = stepCode;
        SequenceNumber     = sequenceNumber;
        _dependsOnStepCode = dependsOnStepCode;
        _rate              = rate;
    }

    public Task<CalculationContext> ExecuteAsync(CalculationContext ctx, CancellationToken ct = default)
    {
        if (ctx.ExemptFlag) return Task.FromResult(ctx);
        if (!ctx.StepResults.TryGetValue(_dependsOnStepCode, out var base_))
            return Task.FromResult(ctx);  // dependency step not in context — skip silently
        var amount = base_ * _rate;
        return Task.FromResult(ctx.WithStepResult(StepCode, Math.Max(0, amount)));
    }
}
```

---

## 5. Sequence Number Convention

Sequence numbers define the execution order of steps within the pipeline. Steps across modules (Tax, Benefits) are merged into a single ordered list. No two active steps for the same jurisdiction may share a sequence number.

| Range | Category | Examples |
|---|---|---|
| 100–199 | Pre-tax benefit deductions | Health premium, RRSP/401k contribution |
| 200–299 | Standard deductions and allowances | US standard deduction, BPA, personal allowance |
| 300–399 | Federal/national income tax | US Federal income tax, Canada income tax, Barbados income tax |
| 400–499 | Non-refundable credits | Canada BPA credit |
| 500–599 | Social insurance and flat levies | SS, Medicare, CPP, EI, NIS, Resilience Fund |
| 600–699 | Sub-national income tax | New York State, California, Georgia |
| 700–799 | Derived taxes (tax-on-tax) | Yonkers surcharge (% of NY state), MCTMT |
| 800–899 | Post-tax deductions | Post-tax benefit premiums, garnishments |
| 900–999 | Employer-only contributions | Employer CPP, Employer EI, Employer NIS |

**Invariant:** A `PercentageOfPriorResultStep` at sequence N must declare a `DependsOnStepCode` whose step has a sequence number less than N. This is enforced at seed-data time by convention; no runtime check is required.

---

## 6. Pipeline Assembly

`PayrollPipelineService.RunAsync` assembles the step list as follows:

1. Resolve the employee's jurisdiction code from `ctx.JurisdictionCode`.
2. Load all active `payroll_calculation_steps` for the jurisdiction effective as of `ctx.PayDate`.
3. For each step row, load the relevant rate data (brackets, flat rates, allowances, credits, tiered brackets) and instantiate the appropriate `ICalculationStep` implementation.
4. Resolve all `IBenefitStepProvider` registrations from the DI container and call `GetStepsForEmployeeAsync` on each. Merge the returned steps into the jurisdiction step list.
5. Sort the combined list by `SequenceNumber` ascending.
6. Execute each step in order, threading the `CalculationContext` through immutable `with` returns.
7. Return the final `CalculationContext`.

```csharp
public async Task<CalculationContext> RunAsync(CalculationContext ctx, CancellationToken ct = default)
{
    var jurisdictionSteps = await BuildJurisdictionStepsAsync(ctx.JurisdictionCode, ctx.PayDate, ct);

    var allBenefitSteps = new List<ICalculationStep>();
    foreach (var provider in _benefitStepProviders)
        allBenefitSteps.AddRange(await provider.GetStepsForEmployeeAsync(ctx.EmployeeId, ctx.PayDate, ct));

    var ordered = jurisdictionSteps
        .Concat(allBenefitSteps)
        .OrderBy(s => s.SequenceNumber)
        .ToList();

    foreach (var step in ordered)
    {
        if (step.AppliesTo == StepAppliesTo.Employer) continue;  // employee pass
        ctx = await step.ExecuteAsync(ctx, ct);
    }

    return ctx;
}
```

The employer pass (Step 9 in `CalculationEngine`) is handled identically but filters `AppliesTo == Employer || Both`.

---

## 7. Integration with CalculationEngine

`Payroll_Core_Module.md §8` defines the ordered computation flow. Steps 3, 6, 7, and 8 are the stubs that the pipeline fills. The wiring change is a single replacement in `CalculationEngine.CalculateEmployeeAsync`:

**Before (stubs):**
```csharp
// Step 3 — Pre-tax deductions
resultLines.AddRange(await _deductionCalculator.CalculatePreTaxDeductionsAsync(context));
// Step 5 — Taxable wage determination
var taxableWages = TaxableWageCalculator.Calculate(resultLines, context);
// Step 6 — Tax withholdings
resultLines.AddRange(await _taxCalculator.CalculateTaxWithholdingsAsync(context, taxableWages));
// Step 7 — Post-tax deductions
resultLines.AddRange(await _deductionCalculator.CalculatePostTaxDeductionsAsync(context));
// Step 8 — Employer contributions
resultLines.AddRange(await _deductionCalculator.CalculateEmployerContributionsAsync(context));
```

**After (pipeline):**
```csharp
// Steps 3, 5, 6, 7 — employee pipeline (pre-tax deductions, allowances, taxes, post-tax deductions)
var pipelineCtx = BuildCalculationContext(employee, grossPay, period, ytdBalances);
var finalCtx    = await _pipelineService.RunAsync(pipelineCtx, ct);
resultLines.AddRange(ProjectToResultLines(finalCtx));

// Step 8 — employer pipeline (employer contributions, employer taxes)
var employerCtx = await _pipelineService.RunEmployerPassAsync(pipelineCtx, ct);
resultLines.AddRange(ProjectEmployerLines(employerCtx));
```

`_pipelineService` is injected as `IPayrollPipelineService` — `NullPayrollPipelineService` is used if the Tax module is not registered.

---

## 8. Integration with Benefits

Phase 6 (Benefits module) implements `IBenefitStepProvider` and registers it in `BenefitsModule.Register`:

```csharp
// BenefitsModule.cs — Phase 6 addition
builder.RegisterType<BenefitStepProvider>()
       .As<IBenefitStepProvider>()
       .InstancePerLifetimeScope();
```

`BenefitStepProvider.GetStepsForEmployeeAsync` loads the employee's active benefit elections from `benefit_deduction_election`, creates `StandardDeductionStep` instances (sequence 100–199 for pre-tax, 800–899 for post-tax) using the election amounts, and returns them.

This resolves TC-PAY-007 ("Pre-tax deduction reduces taxable wage base; taxes calculated on reduced base; post-tax deduction does not affect taxable wages") — pre-tax benefit steps at sequence 1xx execute before tax steps at 3xx; post-tax steps at 8xx execute after.

---

## 9. Database Schema

Sixteen tables. All SQL is ANSI-standard. Integer PKs for configuration/reference tables; UUID PKs for employee-level records.

Tables 9.1–9.8 are jurisdiction configuration tables — shared across all employees. Tables 9.9–9.11 are employee-level: a lookup table, a base submission record, and a single consolidated detail table covering all form families. Tables 9.12–9.14 are the form field definition registry and the configuration audit log, which together support the data-driven form renderer and the configuration approval workflow.

### 9.1 tax_jurisdiction

```sql
CREATE TABLE tax_jurisdiction (
    jurisdiction_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jurisdiction_code VARCHAR(20)  NOT NULL,
    jurisdiction_name VARCHAR(100) NOT NULL,
    country_code      CHAR(2)      NOT NULL,
    is_active         BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_tax_jurisdiction_code UNIQUE (jurisdiction_code)
);
```

### 9.2 payroll_calculation_steps

```sql
CREATE TABLE payroll_calculation_steps (
    step_id                  INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jurisdiction_id          INTEGER      NOT NULL REFERENCES tax_jurisdiction (jurisdiction_id),
    step_code                VARCHAR(50)  NOT NULL,
    step_name                VARCHAR(100) NOT NULL,
    step_type                VARCHAR(30)  NOT NULL,
    calculation_category     VARCHAR(40)  NOT NULL,
    sequence_number          INTEGER      NOT NULL,
    applies_to               VARCHAR(10)  NOT NULL,
    reduces_income_tax_wages BOOLEAN      NOT NULL DEFAULT FALSE,
    reduces_fica_wages       BOOLEAN      NOT NULL DEFAULT FALSE,
    status_code              VARCHAR(30)  NOT NULL DEFAULT 'DRAFT',
    is_active                BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_calculation_step_code UNIQUE (step_code),
    CONSTRAINT chk_step_type CHECK (step_type IN (
        'STANDARD_DEDUCTION', 'ALLOWANCE', 'PROGRESSIVE_BRACKET',
        'CREDIT', 'FLAT_RATE', 'TIERED_FLAT', 'PERCENTAGE_OF_PRIOR')),
    CONSTRAINT chk_applies_to CHECK (applies_to IN ('EMPLOYEE', 'EMPLOYER', 'BOTH')),
    CONSTRAINT chk_step_status CHECK (status_code IN (
        'DRAFT', 'PENDING_REVIEW', 'APPROVED', 'ACTIVE', 'ARCHIVED'))
);
```

**Column notes:**

| Column | Purpose |
|---|---|
| `calculation_category` | Pipeline assembly hint. Values: `PRETAX_BENEFIT`, `DEDUCTION_ALLOWANCE`, `INCOME_TAX`, `CREDIT`, `SOCIAL_INSURANCE`, `SUBNATIONAL_TAX`, `DERIVED_TAX`, `POSTTAX`, `EMPLOYER_CONTRIBUTION`. Maps to named pipeline phase; also controls `useFicaTaxableWages` in `FlatRateStep` and `TieredFlatStep`. |
| `reduces_income_tax_wages` | TRUE for pre-tax steps that reduce `IncomeTaxableWages` (e.g. traditional 401(k), health FSA). |
| `reduces_fica_wages` | TRUE for pre-tax steps that also reduce `FicaTaxableWages` (e.g. Section 125 health premiums). Both flags may be TRUE. |
| `status_code` | Configuration approval state. New steps start as DRAFT; must reach ACTIVE before inclusion in live pipeline queries. |

### 9.3 tax_filing_status

```sql
CREATE TABLE tax_filing_status (
    filing_status_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    jurisdiction_id    INTEGER     NOT NULL REFERENCES tax_jurisdiction (jurisdiction_id),
    filing_status_code VARCHAR(20) NOT NULL,
    filing_status_name VARCHAR(50) NOT NULL,
    CONSTRAINT uq_filing_status UNIQUE (jurisdiction_id, filing_status_code)
);
```

### 9.4 tax_brackets

Holds bracket rows for `PROGRESSIVE_BRACKET` steps. All amounts in annual terms. `filing_status_code` is NULL for jurisdictions that do not vary by filing status.

```sql
CREATE TABLE tax_brackets (
    bracket_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    step_code          VARCHAR(50)   NOT NULL REFERENCES payroll_calculation_steps (step_code),
    filing_status_code VARCHAR(20),
    effective_from     DATE          NOT NULL,
    effective_to       DATE,
    lower_limit        NUMERIC(18,4) NOT NULL,
    upper_limit        NUMERIC(18,4),
    rate               NUMERIC(10,6) NOT NULL,
    CONSTRAINT chk_bracket_limits CHECK (upper_limit IS NULL OR upper_limit > lower_limit)
);
```

### 9.5 tax_flat_rates

Holds rate rows for `FLAT_RATE` and `PERCENTAGE_OF_PRIOR` steps. `wage_base` is the annual wage ceiling for the rate (e.g. SS). `period_cap_amount` caps the per-period deduction (e.g. NY SDI $0.60/week). `annual_cap_amount` caps the annual total (e.g. NY PFL $411.91/year). `depends_on_step_code` is set only for `PERCENTAGE_OF_PRIOR` steps.

```sql
CREATE TABLE tax_flat_rates (
    flat_rate_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    step_code             VARCHAR(50)   NOT NULL REFERENCES payroll_calculation_steps (step_code),
    effective_from        DATE          NOT NULL,
    effective_to          DATE,
    rate                  NUMERIC(10,6) NOT NULL,
    wage_base             NUMERIC(18,4),
    period_cap_amount     NUMERIC(18,4),
    annual_cap_amount     NUMERIC(18,4),
    depends_on_step_code  VARCHAR(50)
);
```

### 9.6 tax_tiered_brackets

Holds tier rows for `TIERED_FLAT` steps (NIS, CPP, CPP2). All amounts in annual terms.

```sql
CREATE TABLE tax_tiered_brackets (
    tiered_bracket_id  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    step_code          VARCHAR(50)   NOT NULL REFERENCES payroll_calculation_steps (step_code),
    effective_from     DATE          NOT NULL,
    effective_to       DATE,
    lower_limit        NUMERIC(18,4) NOT NULL,
    upper_limit        NUMERIC(18,4),
    rate               NUMERIC(10,6) NOT NULL,
    period_cap_amount  NUMERIC(18,4),
    annual_cap_amount  NUMERIC(18,4),
    CONSTRAINT chk_tiered_limits CHECK (upper_limit IS NULL OR upper_limit > lower_limit)
);
```

### 9.7 tax_allowances

Holds allowance amounts for `STANDARD_DEDUCTION` and `ALLOWANCE` steps. `annual_amount` is divided by `PayPeriodsPerYear` at runtime.

```sql
CREATE TABLE tax_allowances (
    allowance_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    step_code       VARCHAR(50)   NOT NULL REFERENCES payroll_calculation_steps (step_code),
    effective_from  DATE          NOT NULL,
    effective_to    DATE,
    annual_amount   NUMERIC(18,4) NOT NULL
);
```

### 9.8 tax_credits

Holds credit definitions for `CREDIT` steps. `annual_amount` is the gross credit base (e.g. BPA amount). `credit_rate` is the rate applied to that base to derive the credit value (e.g. 15% for Canada BPA).

```sql
CREATE TABLE tax_credits (
    credit_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    step_code        VARCHAR(50)   NOT NULL REFERENCES payroll_calculation_steps (step_code),
    effective_from   DATE          NOT NULL,
    effective_to     DATE,
    annual_amount    NUMERIC(18,4) NOT NULL,
    credit_rate      NUMERIC(10,6) NOT NULL,
    is_refundable    BOOLEAN       NOT NULL DEFAULT FALSE
);
```

### 9.9 lkp_tax_form_type

Lookup table following the standard `lkp_*` pattern. Managed by `ILookupCache`. Add `LookupTables.TaxFormType` constant.

```sql
CREATE TABLE lkp_tax_form_type (
    id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT uq_lkp_tax_form_type_code UNIQUE (code)
);
```

Seed values: `W4_2020` (US Federal W-4 2020+), `W4_LEGACY` (US Federal W-4 pre-2020), `IT_2104` (New York), `DE_4` (California), `G_4` (Georgia), `TD1` (Canada federal), `TD1X` (Canada additional), `BB_TD4` (Barbados).

### 9.10 employee_tax_form_submission

Base record for each withholding certificate filed by an employee. One row per filing event (a new W-4 mid-year creates a new row with `effective_from` = the change date). `source_document_id` links to the scanned form in the HRIS document store — nullable because forms may be entered manually before the scan is attached.

```sql
CREATE TABLE employee_tax_form_submission (
    submission_id      UUID         NOT NULL,
    employment_id      UUID         NOT NULL,
    jurisdiction_id    INTEGER      NOT NULL REFERENCES tax_jurisdiction (jurisdiction_id),
    form_type_id       INTEGER      NOT NULL REFERENCES lkp_tax_form_type (id),
    source_document_id UUID,
    submitted_date     DATE         NOT NULL,
    exempt_flag        BOOLEAN      NOT NULL DEFAULT FALSE,
    effective_from     DATE         NOT NULL,
    effective_to       DATE,
    created_by         VARCHAR(100) NOT NULL,
    creation_timestamp TIMESTAMPTZ  NOT NULL,
    CONSTRAINT pk_employee_tax_form_submission PRIMARY KEY (submission_id)
);
```

### 9.11 employee_tax_form_detail

Single consolidated detail record covering all Phase 5 form families: US Federal W-4 (2020+ and legacy), all state withholding certificates (IT-2104, DE-4, G-4, and any future state with the same allowance structure), Canada TD1, TD1X, and BB-TD4. One row per `submission_id`; unused columns default to zero or NULL.

**Design rationale:** A single table eliminates schema churn when adding new jurisdictions or form types that reuse existing column semantics. `form_field_definition` (§9.12) records which columns are active for each `form_type_code`, enforces required/optional rules, and drives the configuration UI renderer — making new form families a data operation, not a DDL change.

**Column mapping by form type:**

| Column | W-4 2020+ | W-4 Legacy | IT-2104 / DE-4 / G-4 | TD1 / TD1X / BB-TD4 |
|---|---|---|---|---|
| `filing_status_code` | Step 1c | Step 1c | If applicable | NULL |
| `allowance_count` | 0 | Step 5 | Allowances | 0 |
| `additional_withholding` | Step 4c | Step 6 | Extra withholding | 0 |
| `is_legacy_form` | FALSE | TRUE | FALSE | FALSE |
| `other_income_amount` | Step 4a | 0 | 0 | 0 |
| `deductions_amount` | Step 4b | 0 | 0 | 0 |
| `credits_amount` | Step 3 | 0 | 0 | 0 |
| `claim_code` | NULL | NULL | NULL | CRA code 1–10 |
| `total_claim_amount` | NULL | NULL | NULL | Custom worksheet total |
| `additional_tax_amount` | 0 | 0 | 0 | Additional tax per period |

**TD1 XOR rule:** Exactly one of `claim_code` or `total_claim_amount` must be non-null for TD1/TD1X/BB-TD4 submissions. This is enforced by the save service (application layer) — a cross-row partial constraint cannot be expressed in ANSI SQL against shared nullable columns.

```sql
CREATE TABLE employee_tax_form_detail (
    submission_id          UUID          NOT NULL
        REFERENCES employee_tax_form_submission (submission_id),
    filing_status_code     VARCHAR(20),
    allowance_count        INTEGER       NOT NULL DEFAULT 0,
    additional_withholding NUMERIC(18,4) NOT NULL DEFAULT 0,
    is_legacy_form         BOOLEAN       NOT NULL DEFAULT FALSE,
    other_income_amount    NUMERIC(18,4) NOT NULL DEFAULT 0,
    deductions_amount      NUMERIC(18,4) NOT NULL DEFAULT 0,
    credits_amount         NUMERIC(18,4) NOT NULL DEFAULT 0,
    claim_code             SMALLINT,
    total_claim_amount     NUMERIC(18,4),
    additional_tax_amount  NUMERIC(18,4) NOT NULL DEFAULT 0,
    CONSTRAINT pk_employee_tax_form_detail PRIMARY KEY (submission_id)
);
```

### 9.12 form_field_definition

Data-driven registry of fields per form type. One row per field per form type per effective period. Drives the configuration UI form renderer and enforces per-form-type required/optional rules at save time — without code changes when a new jurisdiction or form type is added.

`detail_column_name` maps the field to its physical column in `employee_tax_form_detail`. `promotes_to_column` identifies which `CalculationContext` property receives the value at pipeline load time (for columns that are promoted rather than read through the detail table query). `status_code` follows the same `DRAFT → PENDING_REVIEW → APPROVED → ACTIVE → ARCHIVED` workflow as `payroll_calculation_steps`.

```sql
CREATE TABLE form_field_definition (
    field_definition_id   INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    form_type_code        VARCHAR(20)  NOT NULL,
    effective_from        DATE         NOT NULL,
    effective_to          DATE,
    field_key             VARCHAR(80)  NOT NULL,
    display_label         VARCHAR(200) NOT NULL,
    field_type            VARCHAR(40)  NOT NULL,
    section_key           VARCHAR(80),
    section_label         VARCHAR(160),
    display_order         INTEGER      NOT NULL,
    is_required           BOOLEAN      NOT NULL DEFAULT FALSE,
    detail_column_name    VARCHAR(80),
    promotes_to_column    VARCHAR(80),
    validation_rules_json TEXT,
    visibility_rule_json  TEXT,
    enum_values_json      TEXT,
    default_value_text    VARCHAR(200),
    help_text             TEXT,
    status_code           VARCHAR(30)  NOT NULL DEFAULT 'DRAFT',
    is_active             BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uq_form_field_eff UNIQUE (form_type_code, field_key, effective_from),
    CONSTRAINT chk_field_type CHECK (field_type IN (
        'TEXT', 'INTEGER', 'DECIMAL', 'BOOLEAN', 'ENUM', 'DATE')),
    CONSTRAINT chk_field_status CHECK (status_code IN (
        'DRAFT', 'PENDING_REVIEW', 'APPROVED', 'ACTIVE', 'ARCHIVED'))
);
```

### 9.13 configuration_audit_log

Append-only log of all status transitions on configuration entities (`payroll_calculation_steps`, rate tables, `form_field_definition`). Written by the configuration save service on every status change. Never updated or deleted — the source of truth for compliance review.

`entity_name` is the table name (e.g. `payroll_calculation_steps`). `entity_id_text` is the string representation of the entity's PK (e.g. step code or integer ID). `snapshot_json` is the full serialised row state at the time of the transition, stored as TEXT for portability.

```sql
CREATE TABLE configuration_audit_log (
    audit_log_id      INTEGER      GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entity_name       VARCHAR(80)  NOT NULL,
    entity_id_text    VARCHAR(200) NOT NULL,
    action_code       VARCHAR(40)  NOT NULL,
    prior_status_code VARCHAR(30),
    new_status_code   VARCHAR(30),
    changed_by        VARCHAR(100) NOT NULL,
    changed_at        TIMESTAMP    NOT NULL,
    approval_note     TEXT,
    snapshot_json     TEXT,
    CONSTRAINT chk_action_code CHECK (action_code IN (
        'CREATED', 'SUBMITTED_FOR_REVIEW', 'APPROVED', 'ACTIVATED',
        'ARCHIVED', 'REJECTED', 'EDITED'))
);
```

---

## 10. Cap Tracking

Two distinct cap mechanisms exist:

| Mechanism | Column | Example | Enforcement |
|---|---|---|---|
| **Period cap** | `period_cap_amount` | NY SDI max $0.60/week | Enforced within `FlatRateStep.ExecuteAsync` by clamping `raw` to `period_cap_amount` |
| **Annual cap** | `annual_cap_amount` | NY PFL max $411.91/year | Enforced via `ctx.YtdBalances[StepCode]` — step reads YTD, deducts from remaining annual cap |

YTD balance population: `CalculationEngine` must load the employee's accumulator balances by step code before constructing the `CalculationContext`. The `IAccumulatorService` (Phase 4) already owns these balances; the `YtdBalances` dictionary is populated from `AccumulatorBalance` rows where `accumulator_code = step_code`.

---

## 11. Jurisdiction Seed Configuration

The following six jurisdictions, their steps, and their 2025/2026 rate data are required for the Phase 5 gate tests. Seed data files live under `HCM-Project-MD/schemas/seed-data/postgres/dev/`.

### 11.1 Barbados (BB)

| Step Code | Step Type | Seq | Applies To | Key Rate |
|---|---|---|---|---|
| `BB_INCOME_TAX` | PROGRESSIVE_BRACKET | 310 | EMPLOYEE | 12.5% on first BBD 50,000; 28.5% on remainder |
| `BB_NIS` | TIERED_FLAT | 510 | BOTH | 11% on earnings up to BBD 46,000/year (max BBD 5,060 per year) |
| `BB_RESILIENCE_FUND` | FLAT_RATE | 520 | EMPLOYEE | 0.3%, no cap |

### 11.2 Canada Federal (CA-FED)

| Step Code | Step Type | Seq | Applies To | Key Rate / Notes |
|---|---|---|---|---|
| `CA_FED_INCOME_TAX` | PROGRESSIVE_BRACKET | 300 | EMPLOYEE | 5 brackets: 15%/20.5%/26%/29%/33% (2025) |
| `CA_FED_BPA_CREDIT` | CREDIT | 410 | EMPLOYEE | BPA CAD 16,129; credit rate 15% |
| `CA_FED_CPP` | TIERED_FLAT | 500 | BOTH | 5.95% on earnings from CAD 3,500 to 68,500; max CAD 3,867.50/year |
| `CA_FED_CPP2` | TIERED_FLAT | 501 | BOTH | 4.00% on earnings from CAD 68,500 to 73,200; max CAD 188.00/year |
| `CA_FED_EI` | FLAT_RATE | 505 | EMPLOYEE | 1.66% up to CAD 63,200/year; max CAD 1,049.12/year |
| `CA_FED_EI_ER` | FLAT_RATE | 905 | EMPLOYER | 1.4 × employee EI rate (2.324%) |

### 11.3 United States Federal (US-FED)

| Step Code | Step Type | Seq | Applies To | Key Rate / Notes |
|---|---|---|---|---|
| `US_FED_INCOME_TAX` | PROGRESSIVE_BRACKET | 300 | EMPLOYEE | 7 brackets × 4 filing statuses (SINGLE, MFJ, MFS, HOH) — 2025 rates |
| `US_FED_SS` | FLAT_RATE | 510 | BOTH | 6.2%; wage base USD 176,100/year (2025) |
| `US_FED_MEDICARE` | FLAT_RATE | 511 | BOTH | 1.45%, no cap |
| `US_FED_MEDICARE_ADDL` | FLAT_RATE | 512 | EMPLOYEE | 0.9% on wages above USD 200,000/year (annual threshold) |

Filing status codes for US-FED: `SINGLE`, `MFJ` (Married Filing Jointly), `MFS` (Married Filing Separately), `HOH` (Head of Household).

### 11.4 Georgia (US-GA)

| Step Code | Step Type | Seq | Applies To | Key Rate / Notes |
|---|---|---|---|---|
| `US_GA_STD_DEDUCTION` | STANDARD_DEDUCTION | 210 | EMPLOYEE | USD 5,400 single / USD 7,100 MFJ (2025) — two rows in tax_allowances, filtered by filing status |
| `US_GA_INCOME_TAX` | FLAT_RATE | 600 | EMPLOYEE | 5.19% (2025) — rate subject to annual revenue trigger confirmation; update each December |

> **Note:** Georgia completed migration from a progressive bracket system to a flat income tax (HB 1437, 2022). The flat rate is subject to annual revenue-trigger reductions, declared by the DOR typically in October–November. Once the legislated target rate is reached the revenue-trigger mechanism expires and the rate stabilises — verify each October whether the trigger schedule is still active or whether the rate is now fixed. Seed data must be updated each year once the DOR publishes. Because the publication falls within the October form format sweep window, Georgia's rate can be confirmed and staged before the December 15 rate deployment deadline. A warning note is displayed on the Tax Rate Reference page for any step flagged `revenue_trigger = TRUE` (an advisory flag, not a schema column — implement as a description prefix convention).

### 11.5 New York (US-NY)

| Step Code | Step Type | Seq | Applies To | Key Rate / Notes |
|---|---|---|---|---|
| `US_NY_STATE_INCOME` | PROGRESSIVE_BRACKET | 610 | EMPLOYEE | 9 brackets; filing status: SINGLE, MFJ, MFS, HOH |
| `US_NY_CITY_INCOME` | PROGRESSIVE_BRACKET | 620 | EMPLOYEE | 4 NYC brackets; applies only to NYC residents (`IsResident = true`) |
| `US_NY_YONKERS` | PERCENTAGE_OF_PRIOR | 710 | EMPLOYEE | 16.75% of `StepResults["US_NY_STATE_INCOME"]` |
| `US_NY_MCTMT` | FLAT_RATE | 720 | EMPLOYEE | 0.34%; no cap |
| `US_NY_SDI` | FLAT_RATE | 730 | EMPLOYEE | 0.5%; period cap USD 0.60/week (USD 1.20/bi-weekly period) |
| `US_NY_PFL` | FLAT_RATE | 740 | EMPLOYEE | 0.388%; annual cap USD 411.91/year |

### 11.6 California (US-CA)

| Step Code | Step Type | Seq | Applies To | Key Rate / Notes |
|---|---|---|---|---|
| `US_CA_INCOME_TAX` | PROGRESSIVE_BRACKET | 600 | EMPLOYEE | 9 brackets; filing status: SINGLE, MFJ, MFS, HOH |
| `US_CA_MENTAL_HEALTH` | FLAT_RATE | 601 | EMPLOYEE | 1% on annual income exceeding USD 1,000,000; period threshold USD 1M/pay_periods |
| `US_CA_SDI` | FLAT_RATE | 730 | EMPLOYEE | 1.1%; no cap (as of 2024 SB 951) |

---

## 12. UI — Tax Configuration Management

The configuration management UI is a first-class Phase 5 deliverable. It enables `TaxAdmin` and `ComplianceReviewer` roles to create, review, and publish rate changes and form field definitions without developer SQL access to configuration tables. The URL root is `/config/tax`.

### 12.1 Calculation Definition Editor

Located at `/config/tax/steps`. Displays all `payroll_calculation_steps` rows for the selected jurisdiction, grouped by pipeline phase and ordered by `sequence_number`.

**Step detail panel** — selecting a step opens an inline editor for the step's rate data:

| Step type | Editor |
|---|---|
| `PROGRESSIVE_BRACKET` | Bracket grid — one row per bracket; columns: lower limit, upper limit, rate, effective from, effective to. Add / edit / clone rows. |
| `FLAT_RATE` | Flat rate form — rate, wage base, period cap, annual cap, effective from/to. |
| `TIERED_FLAT` | Tiered bracket grid — same columns as bracket grid plus tier caps. |
| `STANDARD_DEDUCTION` / `ALLOWANCE` | Annual amount form — amount, effective from/to. |
| `CREDIT` | Credit form — annual amount, credit rate, refundable flag, effective from/to. |
| `PERCENTAGE_OF_PRIOR` | Derived rate form — depends-on step selector, rate, effective from/to. |

**Effective dating:** New-year rate rows are entered with `effective_from = 2026-01-01` well before year-end. The engine activates them automatically on that date. This is the primary mechanism for the December 15 rate deployment deadline.

**Status workflow for rate row changes:** Changes to rate data (bracket rows, flat rates, etc.) follow the step's `status_code` lifecycle:

```
DRAFT → PENDING_REVIEW → APPROVED → ACTIVE → ARCHIVED
```

- `TaxAdmin` creates or edits rows; step moves to DRAFT.
- `TaxAdmin` submits for review; step moves to PENDING_REVIEW.
- `ComplianceReviewer` approves or rejects. Approval moves step to APPROVED.
- Approved steps are promoted to ACTIVE by the pipeline query on or after `effective_from`.
- Superseded configurations are ARCHIVED automatically.

All transitions write a row to `configuration_audit_log` — who acted, prior state, new state, timestamp, optional note, full row snapshot.

### 12.2 Form Field Definition Editor

Located at `/config/tax/form-fields`. Displays all `form_field_definition` rows grouped by `form_type_code`. Allows `TaxAdmin` to:

- Add a new field definition for a form type (new jurisdiction using an existing column).
- Change `is_required` for an existing field — i.e., make an optional field mandatory or vice versa — for a future effective period.
- Edit display labels, help text, section grouping, and display order.
- Set `validation_rules_json` and `visibility_rule_json` (displayed as a structured rule builder; stored as TEXT).
- Submit changes for ComplianceReviewer approval.

Changes follow the same `DRAFT → PENDING_REVIEW → APPROVED → ACTIVE` workflow and are logged in `configuration_audit_log`. Changing `is_required = TRUE` takes effect from the new `effective_from` date — existing submissions that predate the change are not retroactively invalidated.

### 12.3 Review and Approval Panel

`ComplianceReviewer` sees a dashboard at `/config/tax/review` listing all items in `PENDING_REVIEW` status across both calculation steps and form field definitions. Each item shows:

- What changed (prior vs proposed row diff)
- Who submitted and when
- An approval note field
- Approve / Reject buttons

Approval records a `configuration_audit_log` row and advances the status. Rejection returns the item to DRAFT with the rejection note visible to the submitter.

### 12.4 Preview Sandbox

A preview panel allows `ComplianceReviewer` to run a hypothetical calculation against APPROVED (not yet ACTIVE) rate rows before activating them. Inputs: jurisdiction, filing status, gross pay, pay periods, form values. Output: step-by-step pipeline trace showing which effective-dated rows were applied.

This is a read-only simulation — no payroll run record is created.

### 12.5 Rate Reference View

The read-only rate reference view at `/config/tax/reference` (visible to `SystemAdmin` and `PayrollAdmin`) displays the currently ACTIVE configuration for each jurisdiction, grouped by step, with effective-date history. This replaces the original read-only reference page.

A **Georgia advisory callout** is displayed when the US-GA jurisdiction is selected, reminding the administrator to verify the flat rate each October–November when the Georgia DOR publishes the annual revenue-trigger determination.

---

## 13. Test Cases

All tests are xUnit integration tests against `allworkhris_dev` with 2025 seed data loaded. Each test constructs a `CalculationContext` with representative inputs, calls `IPayrollPipelineService.RunAsync`, and asserts on specific `StepResults` values.

| ID | Jurisdiction | Scenario | Key Assert |
|---|---|---|---|
| TC-TAX-001 | Barbados | Gross BBD 40,000/year — income tax at 12.5% bracket | `StepResults["BB_INCOME_TAX"]` ≈ expected period amount |
| TC-TAX-002 | Barbados | Gross BBD 80,000/year — income tax spans both brackets | `StepResults["BB_INCOME_TAX"]` = (50k × 12.5% + 30k × 28.5%) / 26 |
| TC-TAX-003 | Barbados | NIS — gross BBD 50,000/year; verify annual cap not exceeded | `StepResults["BB_NIS"]` × pay_periods ≤ 5,060 |
| TC-TAX-004 | Barbados | Resilience Fund — flat 0.3%, no cap | `StepResults["BB_RESILIENCE_FUND"]` = period_gross × 0.003 |
| TC-TAX-005 | Canada Fed | Single earner CAD 90,000/year — income tax, 5 brackets | `StepResults["CA_FED_INCOME_TAX"]` matches manual calculation |
| TC-TAX-006 | Canada Fed | BPA credit reduces tax; verify non-refundable (cannot go below zero) | `StepResults["CA_FED_BPA_CREDIT"]` = −(16129 × 15% / pay_periods) capped at computed tax |
| TC-TAX-007 | Canada Fed | CPP — gross CAD 75,000/year; verify CPP and CPP2 both apply | `StepResults["CA_FED_CPP"]` at max; `StepResults["CA_FED_CPP2"]` on slice above 68,500 |
| TC-TAX-008 | Canada Fed | EI — gross CAD 63,200/year; verify annual cap enforced across periods | Cumulative after 26 periods ≤ 1,049.12 |
| TC-TAX-009 | US Fed | Single filer, gross USD 70,000/year — income tax | `StepResults["US_FED_INCOME_TAX"]` matches 2025 bracket table |
| TC-TAX-010 | US Fed | MFJ filer, gross USD 120,000/year — income tax different from Single | `StepResults["US_FED_INCOME_TAX"]` differs from TC-TAX-009 for same gross |
| TC-TAX-011 | US Fed | SS — wage base cap enforced; gross USD 200,000/year | Cumulative SS after wage base period = max (176,100 × 6.2%); zero thereafter |
| TC-TAX-012 | US Fed | Medicare additional 0.9% — gross above USD 200k threshold | `StepResults["US_FED_MEDICARE_ADDL"]` > 0 above threshold; zero below |
| TC-TAX-013 | Georgia | Single filer, gross USD 60,000/year — flat 5.19% after standard deduction | `StepResults["US_GA_INCOME_TAX"]` = (60,000 − 5,400) × 5.19% / 26 |
| TC-TAX-014 | New York | NY state income tax — single filer, gross USD 85,000/year | `StepResults["US_NY_STATE_INCOME"]` matches 9-bracket table |
| TC-TAX-015 | New York | NYC income tax — NYC resident vs non-resident | Non-resident: `StepResults["US_NY_CITY_INCOME"]` absent; resident: present |
| TC-TAX-016 | New York | Yonkers surcharge reads NY state result via PercentageOfPriorResult | `StepResults["US_NY_YONKERS"]` = `StepResults["US_NY_STATE_INCOME"]` × 0.1675 |
| TC-TAX-017 | New York | SDI period cap — bi-weekly payroll; period cap USD 1.20 | `StepResults["US_NY_SDI"]` ≤ 1.20 regardless of gross |
| TC-TAX-018 | New York | PFL annual cap — 26 bi-weekly periods; cumulative ≤ 411.91 | YTD balance consumed; final periods produce zero |
| TC-TAX-019 | California | 9-bracket income tax + Mental Health surtax on gross above USD 1M/year | `StepResults["US_CA_MENTAL_HEALTH"]` > 0 only for high earners; normal earner = 0 |

---

## 14. Role Definitions

| Role | Configuration Access | Payroll Access |
|---|---|---|
| `TaxAdmin` | Create and edit rate rows, form field definitions; submit for review (DRAFT → PENDING_REVIEW); view audit log | Read-only pay register |
| `ComplianceReviewer` | Approve or reject PENDING_REVIEW items; run preview sandbox; view audit log | Read-only pay register |
| `BenefitsAdmin` | Create and edit benefit step definitions (pre-tax deduction steps only); submit for review | Read-only pay register |
| `PayrollAdmin` | Read-only: Rate Reference view, form field reference | Initiate runs; view pipeline results and pay register |
| `PayrollOperator` | None | View pay register |
| `SystemAdmin` | Full read access to all configuration pages | View pay register |

No role may directly update configuration tables via SQL in production. All changes go through the Configuration UI and the `status_code` approval workflow. `configuration_audit_log` provides the complete change history for compliance.

---

## 15. US State Form Coverage

**Purpose:** This section is a pre-certification requirement. Every US state and DC must be assigned to a form category before Phase 5 gates. The assignment determines which detail table stores the employee's withholding profile for that jurisdiction. No state may remain unresolved at gate time.

**Survey date:** 2026-05-02 (initial survey completed — Phase 5.9 deliverable). The matrix must be re-verified annually as a standing operational process. Two separate deadlines apply each year because the two concerns have different lead times:

| What | Deadline | Why |
|---|---|---|
| **Form format changes** — any state moving category or requiring a new detail table | End of October | Schema changes need development, testing, and deployment time before year-end; discovering a structural change in December leaves no runway |
| **Rate data updates** — new brackets, revised flat rates, updated caps, new wage bases | December 15 | Payroll runs for a January 1 pay date may be initiated as early as December 26 for ACH pre-funding; new-year rates must be live in the system before the first such run, not merely before December 31 |

States typically publish revised forms and rates in October–December. Monitoring sources: IRS Publication 15-T (federal), each state revenue department's withholding guide, and payroll tax service bulletins.

### 15.1 Category Definitions

| Category | Detail Table | Active Columns | Description |
|---|---|---|---|
| **A — No income tax** | None | — | State levies no personal income tax on wages. No step, no form, no detail record. |
| **A+ — Payroll levy, no income tax** | None for income; `FLAT_RATE` step only | — | State has no income tax but levies a separate payroll contribution (e.g. WA Cares LTC). No employee withholding certificate; step seeded with rate and cap. |
| **B — Flat rate, no form** | None | — | State applies a flat income tax rate with no employee withholding certificate required. A `FLAT_RATE` step is seeded; no detail record is created for the employee. |
| **C — Simple allowance form** | `employee_tax_form_detail` | `filing_status_code`, `allowance_count`, `additional_withholding` | State withholding certificate uses filing status, allowance count, and optional additional withholding. Covers the majority of US states. |
| **D — W-4 2020+ worksheet** | `employee_tax_form_detail` | `filing_status_code`, `other_income_amount`, `deductions_amount`, `credits_amount`, `additional_withholding`, `is_legacy_form` | State form uses income adjustments and credit dollar amounts in the same structure as the federal W-4 2020+. Confirm field mapping before assigning this category. |
| **E — Unresolved / requires review** | TBD | — | Form structure does not clearly map to existing columns in `employee_tax_form_detail`. New columns or a schema review may be required. Must be resolved before Phase 5 gates. |

### 15.2 State Coverage Matrix

States are ordered alphabetically. In-scope jurisdictions from Phase 5 seed data are marked **★**.

| State | Code | Category | Detail Table | Notes |
|---|---|---|---|---|
| Alabama | AL | C | `employee_tax_form_detail` | Form A-4; allowances + additional withholding |
| Alaska | AK | A | None | No state income tax |
| Arizona | AZ | C | `employee_tax_form_detail` | Form A-4; flat rate with withholding percentage election |
| Arkansas | AR | C | `employee_tax_form_detail` | Form AR4EC; allowances |
| California ★ | CA | C | `employee_tax_form_detail` | Form DE-4; allowances + additional withholding |
| Colorado | CO | C | `employee_tax_form_detail` | Form DR 0004 (2022); allowances + additional withholding — verify against current form before finalising |
| Connecticut | CT | C | `employee_tax_form_detail` | Form CT-W4; filing status + withholding code maps to allowance equivalent |
| Delaware | DE | C | `employee_tax_form_detail` | Form W-4; uses federal form; filing status + allowances |
| District of Columbia | DC | C | `employee_tax_form_detail` | Form D-4; allowances + additional withholding |
| Florida | FL | A | None | No state income tax |
| Georgia ★ | GA | C | `employee_tax_form_detail` | Form G-4; filing status + allowances |
| Hawaii | HI | C | `employee_tax_form_detail` | Form HW-4; allowances |
| Idaho | ID | C | `employee_tax_form_detail` | Form ID W-4; allowances + additional withholding |
| Illinois | IL | C | `employee_tax_form_detail` | Form IL-W-4; additional allowances only (flat 4.95%) |
| Indiana | IN | C | `employee_tax_form_detail` | Form WH-4; exemptions (county tax also applies — see §15.3) |
| Iowa | IA | C | `employee_tax_form_detail` | Form IA W-4; allowances — verify after 2023 form revision |
| Kansas | KS | C | `employee_tax_form_detail` | Form K-4; allowances |
| Kentucky | KY | B | None | Flat 4.5%; no withholding certificate required |
| Louisiana | LA | C | `employee_tax_form_detail` | Form L-4; exemptions + additional withholding |
| Maine | ME | C | `employee_tax_form_detail` | Form W-4ME; allowances |
| Maryland | MD | C | `employee_tax_form_detail` | Form MW507; exemptions + additional withholding (county tax stacked on state — see §15.3) |
| Massachusetts | MA | C | `employee_tax_form_detail` | Form M-4; exemptions; flat 5% |
| Michigan | MI | C | `employee_tax_form_detail` | Form MI-W4; exemptions; flat rate (city taxes also apply in some cities) |
| Minnesota | MN | C | `employee_tax_form_detail` | Form W-4MN; allowances |
| Mississippi | MS | C | `employee_tax_form_detail` | Form 89-350; exemptions + additional withholding |
| Missouri | MO | C | `employee_tax_form_detail` | Form MO W-4; allowances |
| Montana | MT | C | `employee_tax_form_detail` | Form MT-R; allowances |
| Nebraska | NE | C | `employee_tax_form_detail` | Form W-4N; allowances |
| Nevada | NV | A | None | No state income tax |
| New Hampshire | NH | A | None | No wage income tax (I&D tax eliminated 2025) |
| New Jersey | NJ | C | `employee_tax_form_detail` | Form NJ-W4; filing status maps to withholding rate table — allowance equivalent |
| New Mexico | NM | C | `employee_tax_form_detail` | Form PIT-1; withholding certificate with allowances |
| New York ★ | NY | C | `employee_tax_form_detail` | Form IT-2104; allowances + additional withholding |
| North Carolina | NC | C | `employee_tax_form_detail` | Form NC-4; allowances + additional withholding |
| North Dakota | ND | C | `employee_tax_form_detail` | Uses federal W-4; filing status + allowances |
| Ohio | OH | C | `employee_tax_form_detail` | Form IT 4; exemptions (municipal/school district taxes also apply — see §15.3) |
| Oklahoma | OK | C | `employee_tax_form_detail` | Form OK-W-4; allowances |
| Oregon | OR | C | `employee_tax_form_detail` | Form OR-W-4; allowances + additional withholding |
| Pennsylvania | PA | B | None | Flat 3.07%; no state withholding certificate (local EIT separate — see §15.3) |
| Rhode Island | RI | C | `employee_tax_form_detail` | Form RI W-4; allowances |
| South Carolina | SC | C | `employee_tax_form_detail` | Form SC W-4; allowances |
| South Dakota | SD | A | None | No state income tax |
| Tennessee | TN | A | None | No wage income tax (Hall Tax eliminated 2021) |
| Texas | TX | A | None | No state income tax |
| Utah | UT | C | `employee_tax_form_detail` | Form TC-40A; withholding allowances |
| Vermont | VT | C | `employee_tax_form_detail` | Form W-4VT; allowances |
| Virginia | VA | C | `employee_tax_form_detail` | Form VA-4; personal exemptions + additional withholding |
| Washington | WA | A+ | None (income); `FLAT_RATE` step for WA Cares | No income tax; WA Cares LTC Fund levy: 0.58%, annual cap ~$1,542 (2025); employees may file for exemption |
| West Virginia | WV | C | `employee_tax_form_detail` | Form WV/IT-104; exemptions |
| Wisconsin | WI | C | `employee_tax_form_detail` | Form WT-4; exemptions + additional withholding |
| Wyoming | WY | A | None | No state income tax |

### 15.3 Special Cases

**Indiana county taxes:** Indiana imposes county income tax on top of the flat state rate. County is determined by the employee's county of residence on 1 January each year. A separate `FLAT_RATE` step per county is required rather than a single state step. Seed data scope must be confirmed before Phase 5 gates — 92 counties, each with a distinct rate.

**Maryland county taxes:** Maryland counties and Baltimore City each impose a local income tax (2.25%–3.20%). Like Indiana, these are stacked on the state tax, not replacing it. A `FLAT_RATE` step per county is required. 24 jurisdictions (23 counties + Baltimore City).

**Ohio municipal / school district taxes:** Ohio has 600+ municipal and school district income tax jurisdictions. These are employer-registered local taxes, not employee-elected withholding. Scope confirmation required before Phase 5 gates — may be deferred to a separate local tax phase.

**Pennsylvania local EIT:** Pennsylvania Earned Income Tax is levied by over 2,600 local municipalities and school districts through Act 32 collectors. Like Ohio municipal taxes, scope confirmation required — likely deferred.

**Washington WA Cares exemptions:** Employees may file for exemption from the WA Cares LTC Fund levy (e.g. if they have private LTC insurance, are military spouses, non-immigrant visa holders, etc.). The `exempt_flag` on `employee_tax_form_submission` handles this — an approved exemption creates a submission row with `exempt_flag = TRUE` for the WA Cares step jurisdiction.

### 15.4 Pre-Certification Confirmation Checklist

Before Phase 5 gates:

- [x] All 50 states + DC assigned to a category (no Category E rows remaining) — completed 2026-05-02
- [x] Colorado DR 0004 current form verified — **Category C confirmed** (DR 0004 2022 revision retains allowances + additional withholding; no reclassification needed)
- [x] Iowa IA W-4 post-2023 revision verified — **Category C confirmed** (2023 form revision retained allowance/exemption structure; no reclassification needed)
- [x] Indiana county tax scope decision recorded — **deferred** (92 county rates; deferred to local tax phase; state-level `US-IN` jurisdiction seeded)
- [x] Maryland county tax scope decision recorded — **deferred** (24 jurisdictions; deferred to local tax phase; state-level `US-MD` jurisdiction seeded)
- [x] Ohio municipal tax scope decision recorded — **deferred** (600+ jurisdictions; deferred to local tax phase; state-level `US-OH` jurisdiction seeded)
- [x] Pennsylvania local EIT scope decision recorded — **deferred** (2,600+ municipalities; deferred to local tax phase; state-level `US-PA` jurisdiction seeded with 3.07% state flat rate)
- [x] WA Cares rate and cap seeded for 2025 — 0.58%, annual cap $1,542 seeded in `tax_pipeline_seed_data.sql`; **2026 row placeholder left in seed file** — insert after WA Cares Fund publishes annual rate (typically October)
- [x] Survey date recorded at top of §15 — 2026-05-02
- [ ] Annual re-verification process owner confirmed; calendar reminders set for October (form format sweep) and December 15 (rate data deployment deadline)
