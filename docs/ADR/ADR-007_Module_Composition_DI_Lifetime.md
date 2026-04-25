# ADR-007 — Module Composition and DI Lifetime Strategy: MEF + Autofac

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.1 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-007_Module_Composition_DI_Lifetime.md` |
| **Date** | April 2026 |
| **Related Documents** | ADR-003_UI_Technology_Stack, ADR-005_Background_Job_Execution, ADR-006_UI_Component_Library, PRD-0100_Architecture_Principles |

---

## Context

The platform is designed as a set of independently deployable modules (HRIS, Payroll, Benefits, T&A, Reporting) that must be composable at runtime without the host application having compile-time knowledge of which modules are present. This is the practical meaning of the modularity principle in PRD-0100.

Two .NET composition technologies were available:

**MEF (Managed Extensibility Framework)** — an assembly scanner and composition engine designed for plugin architectures. It can discover types across assemblies at runtime using export/import attribute declarations. However, MEF manages its own object graph and has no native concept of DI lifetimes compatible with Blazor Server's scoped/transient/singleton model.

**Autofac** — a DI container that manages object lifetimes explicitly and integrates cleanly with .NET Core's `IServiceCollection` and Blazor Server's component injection model. It does not natively discover plugins across assemblies.

Using either technology alone leaves a gap. Using both naively — allowing MEF to instantiate services that Autofac should own, or allowing Autofac to register types without knowing which modules are present — creates two competing object graphs with incoherent lifetime management. This was identified as a real risk by an experienced .NET developer reviewing the planned stack.

A proof of concept application was built that validated a combined approach. The PoC also validated that modules can contribute items to the main application navigation menu at startup, allowing the host application to have no hardcoded menu structure.

---

## Decision

**MEF shall be used exclusively as an assembly scanner for module discovery. Autofac shall own all service registrations, lifetime management, and object resolution. MEF shall never instantiate a service or manage a lifetime.**

Each platform module is an independently compiled assembly containing:
1. A class implementing `IPlatformModule` decorated with `[Export(typeof(IPlatformModule))]`
2. All business logic services, data access classes, and domain types for that module
3. No Blazor UI components — these are compiled into the main host assembly

The `IPlatformModule` contract defines two responsibilities:

```csharp
public interface IPlatformModule
{
    void Register(ContainerBuilder builder);
    IEnumerable<MenuContribution> GetMenuContributions();
}
```

---

## Startup Composition Pattern

At application startup, before the Autofac container is built:

1. MEF scans the configured modules folder for all assemblies containing `[Export(typeof(IPlatformModule))]` exports
2. MEF instantiates only the `IPlatformModule` registration classes — these are lightweight, stateless, and hold no application state
3. For each discovered module, `Register(builder)` is called — the module declares all its services, repositories, and background services into the Autofac `ContainerBuilder`
4. `GetMenuContributions()` is called on each module — the collected menu items are assembled, sorted, and registered as a singleton in Autofac
5. Autofac builds the container from all registrations
6. MEF's role is complete — it is not used again after startup

From this point on, all object resolution flows through Autofac. Blazor components, background services, Dapper repositories, and domain services all receive dependencies through standard constructor injection via the Autofac-backed DI container.

---

## Service Registration Pattern

Each module's `Register` method explicitly declares its services and their lifetimes:

```csharp
[Export(typeof(IPlatformModule))]
public class PayrollModule : IPlatformModule
{
    public void Register(ContainerBuilder builder)
    {
        // Scoped per user session / Blazor circuit
        builder.RegisterType<PayrollRunService>()
               .As<IPayrollRunService>()
               .InstancePerLifetimeScope();

        // Scoped per user session
        builder.RegisterType<AccumulatorService>()
               .As<IAccumulatorService>()
               .InstancePerLifetimeScope();

        // Singleton — stateless, shared safely
        builder.RegisterType<PayrollCalendarResolver>()
               .As<IPayrollCalendarResolver>()
               .SingleInstance();

        // Transient — new instance each resolution
        builder.RegisterType<PayrollRunValidator>()
               .As<IPayrollRunValidator>()
               .InstancePerDependency();
    }

    public IEnumerable<MenuContribution> GetMenuContributions() =>
    [
        new MenuContribution
        {
            Label = "Payroll",
            Icon = "payroll-icon",
            SortOrder = 20,
            RequiredRole = "PayrollOperator"
        },
        new MenuContribution
        {
            Label = "Run Payroll",
            Href = "/payroll/run",
            Icon = "run-icon",
            SortOrder = 1,
            ParentLabel = "Payroll",
            RequiredRole = "PayrollOperator"
        },
        new MenuContribution
        {
            Label = "Payroll History",
            Href = "/payroll/history",
            Icon = "history-icon",
            SortOrder = 2,
            ParentLabel = "Payroll",
            RequiredRole = "PayrollOperator"
        }
    ];
}
```

---

## Menu Contribution Model

The `MenuContribution` type defines a navigation entry that a module declares at startup:

```csharp
public class MenuContribution
{
    public string Label { get; set; }
    public string Href { get; set; }          // null for parent/group items
    public string Icon { get; set; }
    public int SortOrder { get; set; }
    public string RequiredRole { get; set; }  // null = visible to all authenticated users
    public string ParentLabel { get; set; }   // null = top-level item
}
```

The host application's nav component resolves the assembled menu from Autofac and renders it filtered by the current user's roles. The host assembly contains no hardcoded menu items. A module that is not deployed contributes no menu items and its navigation entries simply do not appear.

---

## Lifetime Rules

The following lifetime rules apply to all module service registrations:

| Service Type | Required Lifetime | Rationale |
|---|---|---|
| Stateless domain services, resolvers, calculators | `SingleInstance` or `InstancePerLifetimeScope` | Safe to share if truly stateless |
| Services that hold per-user or per-request state | `InstancePerLifetimeScope` | Scoped to Blazor circuit |
| Services that must never be shared | `InstancePerDependency` | New instance per resolution |
| Background services (`IHostedService`) | Registered separately in `IServiceCollection` | Not through Autofac module registration |
| MEF `IPlatformModule` registration classes | Instantiated by MEF at startup only | Stateless; never injected into application code |

**MEF parts shall never be injected directly into Blazor components.** Components receive services through Autofac-registered interfaces only.

**MEF parts shall hold no application state.** `IPlatformModule` implementations are stateless registration helpers. All application state lives in Autofac-managed services.

---

## UI Component Rule

**Blazor UI components shall not live in module assemblies.** Blazor Server cannot dynamically load Razor components from assemblies discovered at runtime — components must be compiled into the main host assembly. Module assemblies contain services, domain logic, and data access only. UI components for each module's features are organised in the host assembly by module namespace.

---

## Syncfusion License Registration

Per ADR-006, the Syncfusion license key shall be registered in `Program.cs` before the host is built — not inside any MEF part or Autofac module:

```csharp
// Program.cs — before builder.Build()
Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense("YOUR_KEY");
```

Registering the license inside a MEF part or Autofac module is not supported and will cause silent component failures or runtime exceptions.

---

## Consequences

**Positive:**
- MEF's complexity is contained to a single startup scan — no MEF attributes anywhere in the service layer or UI layer after startup
- Autofac owns all lifetimes — Blazor Server's circuit scoping, singleton services, and transient services are all managed consistently through one container
- Modules are truly independent — adding a module requires dropping an assembly in the modules folder; removing it requires removing the assembly; the host application requires no code changes
- Menu structure is fully dynamic — the host nav component has no hardcoded entries; the navigation reflects exactly the modules that are deployed
- Role-gated navigation is declared by modules alongside their menu contributions — access control and navigation are co-located
- Validated by proof of concept — the pattern is confirmed to work in the target stack

**Constraints to manage:**
- Blazor UI components must be compiled into the host assembly — module UI cannot be loaded dynamically; feature organisation in the host assembly must follow a clear module-namespace convention to maintain separation
- MEF startup scan adds a small application startup cost — acceptable for a server application that starts infrequently
- Module assemblies must be deployed to the correct folder — deployment procedures must account for module assembly placement
- Circular dependencies between modules are not detected by MEF — Autofac will surface them at container build time; module dependency direction must be governed (lower-level modules must not reference higher-level modules)

**Future consideration:**
- If a future module requires truly optional runtime loading (loading a module without restarting the application), a more sophisticated MEF composition model or a dedicated plugin host can be introduced without changing the core pattern — the `IPlatformModule` contract remains stable

---

## Alternatives Considered

**Pure Autofac with manual module registration**
Explicit `builder.RegisterAssemblyTypes(...)` calls for each known module in the host application. Rejected — requires the host to have compile-time knowledge of all modules; defeats the modularity goal; adding a module requires changing the host.

**Pure MEF composition**
MEF owns all service creation and wiring. Rejected — MEF has no concept of DI lifetimes compatible with Blazor Server's circuit model; MEF-created services cannot participate in Autofac's scoped lifetime management; leads to the lifetime hazards identified in the stack review.

**Autofac MEF integration package (Autofac.Mef)**
Autofac provides an official MEF integration package that registers MEF exports directly into Autofac. Evaluated — adds complexity without clear benefit over the simpler pattern of using MEF only for discovery and calling `Register(builder)` explicitly; the explicit registration pattern is more readable and debuggable.

**No MEF — convention-based assembly scanning**
Autofac's `RegisterAssemblyTypes` with interface conventions, scanning a modules folder. A viable alternative that eliminates MEF entirely. Not selected because the PoC was built with MEF and the `[Export]` attribute model provides an explicit, intentional declaration of module entry points that convention scanning does not.
