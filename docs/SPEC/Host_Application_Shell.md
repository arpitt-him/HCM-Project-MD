# SPEC — Host Application Shell

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.4 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/Host_Application_Shell.md` |
| **Related Documents** | ADR-003_UI_Technology_Stack, ADR-006_UI_Component_Library, ADR-007_Module_Composition_DI_Lifetime, ADR-008_API_Surface_Architecture, PRD-0100_Architecture_Principles, docs/SPEC/API_Contract_Standards.md, docs/architecture/governance/Security_and_Access_Control_Model.md |

---

## Purpose

Defines the implementation-ready specification for the AllWorkHRIS host application shell — the foundation on which all platform modules are composed. This document covers solution structure, startup sequence, module composition contracts, shell layout, navigation, authentication scaffold, CSS design tokens, environment configuration, and test cases.

The host application shell contains no business logic. It is the runtime container that discovers modules, composes the DI container, renders the shell UI, and routes to module-owned pages.

---

## 1. Solution Structure

```
AllWorkHRIS.sln
│
├── src/
│   ├── AllWorkHRIS.Web/                  # Blazor Server host application
│   │   ├── Program.cs
│   │   ├── App.razor
│   │   ├── _Host.cshtml
│   │   ├── Layout/
│   │   │   ├── MainLayout.razor          # Shell layout — sidebar + content area
│   │   │   ├── NavMenu.razor             # Dynamic nav from module contributions
│   │   │   └── TopBar.razor              # App name, user identity, tenant context
│   │   ├── Pages/
│   │   │   ├── Index.razor               # Home / dashboard landing
│   │   │   └── Error.razor               # Error boundary page
│   │   ├── Auth/
│   │   │   └── AuthenticationStateHelper.cs
│   │   ├── Components/
│   │   │   └── Icons/                    # Module icon Razor components
│   │   │       ├── HrisIcon.razor
│   │   │       ├── PayrollIcon.razor
│   │   │       ├── TimeAttendanceIcon.razor
│   │   │       ├── BenefitsIcon.razor
│   │   │       ├── ReportingIcon.razor
│   │   │       ├── RecruitingIcon.razor
│   │   │       └── PerformanceIcon.razor
│   │   └── wwwroot/
│   │       ├── css/
│   │       │   └── app.css               # CSS custom properties (design tokens)
│   │       └── favicon.ico
│   │
│   ├── AllWorkHRIS.Core/                 # Shared contracts and base types
│   │   ├── Composition/
│   │   │   ├── IPlatformModule.cs
│   │   │   └── MenuContribution.cs
│   │   ├── Data/
│   │   │   ├── IConnectionFactory.cs
│   │   │   └── IUnitOfWork.cs
│   │   ├── Domain/
│   │   │   └── IAuditableEntity.cs
│   │   ├── Security/
│   │   │   └── ClaimsPrincipalExtensions.cs
│   │   └── Events/
│   │       ├── IEventPublisher.cs
│   │       ├── InProcessEventBus.cs
│   │       ├── HireEventPayload.cs
│   │       ├── RehireEventPayload.cs
│   │       ├── TerminationEventPayload.cs
│   │       ├── CompensationChangeEventPayload.cs
│   │       ├── LeaveApprovedPayload.cs
│   │       └── ReturnToWorkPayload.cs
│   │
│   └── modules/                          # Module assemblies drop folder
│       └── (deployed module .dlls)
│
└── tests/
    └── AllWorkHRIS.Web.Tests/
```

---

## 2. Environment Configuration

The following environment variables are required at startup. The application shall fail fast with a descriptive error message if any required variable is absent.

| Variable | Required | Description |
|---|---|---|
| `DATABASE_CONNECTION_STRING` | Yes | ADO.NET connection string for the primary database |
| `DATABASE_PROVIDER` | Yes | `postgresql`, `sqlserver`, or `mysql` |
| `APP_ENVIRONMENT` | Yes | `Development`, `Staging`, or `Production` |
| `TEMPORAL_OVERRIDE_ENABLED` | No | `true` to enable Temporal Override capability; defaults to `false`; must be `false` in Production |
| `AUTH_AUTHORITY` | Yes | OAuth2 / OIDC authority URL |
| `AUTH_CLIENT_ID` | Yes | OAuth2 client ID |
| `AUTH_CLIENT_SECRET` | Yes | OAuth2 client secret |
| `MODULES_PATH` | No | Path to module assemblies folder; defaults to `./modules` |
| `APP_DISPLAY_NAME` | No | Display name shown in the shell top bar; defaults to `AllWorkHRIS` |

For local development, environment variables are declared in `launchSettings.json` under `environmentVariables`. This file shall not contain production credential values.

## 2.1 User-secret Configuration

The `Syncfusion:LicenseKey` label represents the Syncfusion license key.
Its registration in the application is required for use of the Syncfusion Essential Studio UI components.
Its value will be stored as a .Net user-secret in the development environment.  This is being done so that it does not end up as a raw string in the GitHub repo.

---

## 3. Program.cs Startup Sequence

The startup sequence is strictly ordered. Each step must complete successfully before the next begins.

```csharp
// 1. Create builder — must be first in the sequence to load Syncfusion license key from user-secrets
var builder = WebApplication.CreateBuilder(args);

// 2. Retrieve Syncfusion license key from configuration (originated as user-secret)
var syncfusionKey = builder.Configuration["Syncfusion:LicenseKey"]
    ?? throw new InvalidOperationException(
        "Syncfusion:LicenseKey user-secret is not configured.");

// 3. Register Syncfusion license - must occur before any component renders
Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense(syncfusionKey);

// 4. Validate required environment variables
EnvironmentValidator.ValidateRequired(
    "DATABASE_CONNECTION_STRING",
    "DATABASE_PROVIDER",
    "APP_ENVIRONMENT",
    "AUTH_AUTHORITY",
    "AUTH_CLIENT_ID",
    "AUTH_CLIENT_SECRET");

// 5. Discover modules via MEF
var modulesPath = Environment.GetEnvironmentVariable("MODULES_PATH") ?? "./modules";
var platformModules = ModuleDiscovery.DiscoverModules(modulesPath);

// 6. Build Autofac container
builder.Host.UseServiceProviderFactory(new AutofacServiceProviderFactory());
builder.Host.ConfigureContainer<ContainerBuilder>(autofacBuilder =>
{
    // Register core platform services
    autofacBuilder.RegisterType<ConnectionFactory>()
                  .As<IConnectionFactory>()
                  .SingleInstance();

    // Register each discovered module
    foreach (var module in platformModules)
        module.Register(autofacBuilder);
});

// 6a. Register InProcessEventBus as singleton — before modules register handlers
	autofacBuilder.RegisterType<InProcessEventBus>()
				  .As<IEventPublisher>()
				  .SingleInstance();

// 7. Collect menu contributions and register as singleton
var menuContributions = platformModules
    .SelectMany(m => m.GetMenuContributions())
    .OrderBy(c => c.SortOrder)
    .ToList();
builder.Services.AddSingleton(menuContributions);

// 8. Register Syncfusion services
builder.Services.AddSyncfusionBlazor();

// 9. Register Blazor Server
builder.Services.AddRazorComponents()
                .AddInteractiveServerComponents();

// 10. Register authentication
builder.Services.AddAuthentication(...)
                .AddOpenIdConnect(...);
builder.Services.AddAuthorization();
builder.Services.AddCascadingAuthenticationState();

// 11. Build application
var app = builder.Build();

// 12. Configure middleware pipeline
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

// 13. Register Minimal API endpoints
HrisEndpoints.Map(app);
PayrollEndpoints.Map(app);
// Additional module endpoints registered here as modules are built

// 14. Map Blazor hub and fallback
app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

// 15. Run
app.Run();
```

---

## 4. Module Discovery

```csharp
public static class ModuleDiscovery
{
    public static IReadOnlyList<IPlatformModule> DiscoverModules(string modulesPath)
    {
        if (!Directory.Exists(modulesPath))
            return [];

        var catalog = new DirectoryCatalog(modulesPath, "AllWorkHRIS.Module.*.dll");
        var container = new CompositionContainer(catalog);

        try
        {
            var modules = container
                .GetExportedValues<IPlatformModule>()
                .ToList();

            // Log discovered modules
            foreach (var module in modules)
                Console.WriteLine($"[ModuleDiscovery] Loaded: {module.GetType().Assembly.GetName().Name}");

            return modules;
        }
        catch (CompositionException ex)
        {
            throw new InvalidOperationException(
                $"Module composition failed: {ex.Message}", ex);
        }
    }
}
```

Module assembly naming convention: `AllWorkHRIS.Module.{ModuleName}.dll`
Examples: `AllWorkHRIS.Module.Hris.dll`, `AllWorkHRIS.Module.Payroll.dll`

---

## 5. IPlatformModule Contract

```csharp
// AllWorkHRIS.Core/Composition/IPlatformModule.cs
using Autofac;

namespace AllWorkHRIS.Core.Composition;

public interface IPlatformModule
{
    /// <summary>
    /// Registers all module services, repositories, and domain types
    /// into the Autofac container builder.
    /// Called once at startup before the container is built.
    /// Must be stateless — do not store any application state here.
    /// </summary>
    void Register(ContainerBuilder builder);

    /// <summary>
    /// Returns the navigation menu items this module contributes
    /// to the host application shell.
    /// Called once at startup to build the assembled menu singleton.
    /// </summary>
    IEnumerable<MenuContribution> GetMenuContributions();
}
```

---

## 6. MenuContribution Contract

```csharp
// AllWorkHRIS.Core/Composition/MenuContribution.cs
namespace AllWorkHRIS.Core.Composition;

public sealed class MenuContribution
{
    /// <summary>Display label for the menu item.</summary>
    public required string Label { get; init; }

    /// <summary>
    /// Navigation href. Null for parent/group items that have no
    /// direct navigation target.
    /// </summary>
    public string? Href { get; init; }

    /// <summary>Icon identifier. Resolves to a CSS class or SVG reference.</summary>
    public string? Icon { get; init; }

    /// <summary>
    /// Sort order within the menu. Lower numbers appear first.
    /// Host-owned items use 0–9. Module items start at 10.
    /// </summary>
    public int SortOrder { get; init; }

    /// <summary>
    /// Role required to see this item.
    /// Null means visible to all authenticated users.
    /// </summary>
    public string? RequiredRole { get; init; }

    /// <summary>
    /// Label of the parent menu group.
    /// Null means this is a top-level item.
    /// </summary>
    public string? ParentLabel { get; init; }

    /// <summary>
    /// Accent color for the module badge on the menu item.
    /// CSS color value e.g. "#4ECDC4" or "var(--module-teal)".
    /// </summary>
    public string? AccentColor { get; init; }

    /// <summary>
    /// Short badge label displayed on the menu item
    /// e.g. "HRIS", "PAY", "T&A".
    /// </summary>
    public string? BadgeLabel { get; init; }
}
```

---

## 7. IConnectionFactory Contract

```csharp
// AllWorkHRIS.Core/Data/IConnectionFactory.cs
using System.Data;

namespace AllWorkHRIS.Core.Data;

public interface IConnectionFactory
{
    /// <summary>
    /// Creates and returns an open IDbConnection using the configured
    /// database provider and connection string.
    /// Caller is responsible for disposing the connection.
    /// </summary>
    IDbConnection CreateConnection();
}

// Implementation registered as SingleInstance in Program.cs
public sealed class ConnectionFactory : IConnectionFactory
{
    private readonly string _connectionString;
    private readonly string _provider;

    public ConnectionFactory()
    {
        _connectionString = Environment.GetEnvironmentVariable("DATABASE_CONNECTION_STRING")
            ?? throw new InvalidOperationException("DATABASE_CONNECTION_STRING not set.");
        _provider = Environment.GetEnvironmentVariable("DATABASE_PROVIDER")
            ?? throw new InvalidOperationException("DATABASE_PROVIDER not set.");
    }

    public IDbConnection CreateConnection()
    {
        IDbConnection connection = _provider.ToLowerInvariant() switch
        {
            "postgresql"  => new Npgsql.NpgsqlConnection(_connectionString),
            "sqlserver"   => new Microsoft.Data.SqlClient.SqlConnection(_connectionString),
            "mysql"       => new MySql.Data.MySqlClient.MySqlConnection(_connectionString),
            _ => throw new InvalidOperationException($"Unsupported database provider: {_provider}")
        };

        connection.Open();
        return connection;
    }
}
```

---

## 8. IUnitOfWork Contract

```csharp
// AllWorkHRIS.Core/Data/IUnitOfWork.cs
using System.Data;

namespace AllWorkHRIS.Core.Data;

public interface IUnitOfWork : IDisposable
{
    IDbConnection Connection { get; }
    IDbTransaction Transaction { get; }
    void Commit();
    void Rollback();
}

public sealed class UnitOfWork : IUnitOfWork
{
    public IDbConnection Connection { get; }
    public IDbTransaction Transaction { get; }

    public UnitOfWork(IConnectionFactory connectionFactory)
    {
        Connection = connectionFactory.CreateConnection();
        Transaction = Connection.BeginTransaction();
    }

    public void Commit() => Transaction.Commit();
    public void Rollback() => Transaction.Rollback();

    public void Dispose()
    {
        Transaction.Dispose();
        Connection.Dispose();
    }
}
```

Usage pattern in a service:

```csharp
public async Task<Guid> CreateEmploymentAsync(CreateEmploymentCommand command)
{
    using var uow = new UnitOfWork(_connectionFactory);
    try
    {
        var employmentId = await _repository.InsertAsync(command, uow);
        await _eventRepository.InsertAsync(new HireEvent(employmentId), uow);
        uow.Commit();
        return employmentId;
    }
    catch
    {
        uow.Rollback();
        throw;
    }
}
```

---

## 9. Shell Layout

### MainLayout.razor

```razor
@inherits LayoutComponentBase
@inject IReadOnlyList<MenuContribution> MenuItems
@inject AuthenticationStateProvider AuthStateProvider

<div class="shell-container">
    <nav class="shell-sidebar">
        <div class="shell-brand">
            <span class="shell-brand-name">
                @AppDisplayName
            </span>
        </div>
        <NavMenu Items="MenuItems" />
    </nav>

    <div class="shell-main">
        <TopBar />
        <div class="shell-content">
            <ErrorBoundary>
                <ChildContent>
                    @Body
                </ChildContent>
                <ErrorContent Context="ex">
                    <ErrorDisplay Exception="ex" />
                </ErrorContent>
            </ErrorBoundary>
        </div>
    </div>
</div>

@code {
    private string AppDisplayName =>
        Environment.GetEnvironmentVariable("APP_DISPLAY_NAME") ?? "AllWorkHRIS";
}
```

### Layout CSS classes

| Class | Element | Description |
|---|---|---|
| `shell-container` | Root div | Full viewport flex container |
| `shell-sidebar` | Left nav | Fixed width dark sidebar |
| `shell-brand` | Top of sidebar | App name / logo area |
| `shell-main` | Right content area | Flex column: top bar + content |
| `shell-content` | Page content area | Scrollable content region |

---

## 10. NavMenu Component

The NavMenu component renders the assembled `List<MenuContribution>` filtered by the current user's roles. It supports one level of nesting — top-level items and their children.

```razor
@* NavMenu.razor *@
@inject AuthenticationStateProvider AuthStateProvider

@foreach (var parent in TopLevelItems)
{
    <div class="nav-group">
        <div class="nav-item nav-parent">
            <span class="nav-icon @parent.Icon"></span>
            <span class="nav-label">@parent.Label</span>
            @if (parent.BadgeLabel is not null)
            {
                <span class="nav-badge"
                      style="background-color: @parent.AccentColor">
                    @parent.BadgeLabel
                </span>
            }
        </div>
        @foreach (var child in ChildrenOf(parent.Label))
        {
            <NavLink class="nav-item nav-child"
                     href="@child.Href"
                     Match="NavLinkMatch.Prefix">
                <span class="nav-icon @child.Icon"></span>
                <span class="nav-label">@child.Label</span>
            </NavLink>
        }
    </div>
}

@code {
    [Parameter] public IReadOnlyList<MenuContribution> Items { get; set; } = [];

    private ClaimsPrincipal? _user;

    protected override async Task OnInitializedAsync()
    {
        var authState = await AuthStateProvider.GetAuthenticationStateAsync();
        _user = authState.User;
    }

    private IEnumerable<MenuContribution> TopLevelItems =>
        Items.Where(i => i.ParentLabel is null
                      && IsAuthorised(i));

    private IEnumerable<MenuContribution> ChildrenOf(string parentLabel) =>
        Items.Where(i => i.ParentLabel == parentLabel
                      && IsAuthorised(i));

    private bool IsAuthorised(MenuContribution item) =>
        item.RequiredRole is null || (_user?.IsInRole(item.RequiredRole) ?? false);
}
```

---

## 11. CSS Design Tokens

All colours, spacing, and typography values are expressed as CSS custom properties in `app.css`. Module and component styles reference these tokens — never hardcoded values.

```css
/* app.css — AllWorkHRIS design tokens */
:root {
    /* Brand palette — AllWorkHRIS */
    --aw-brown:   #8A5A38;   /* warm earth */
    --aw-blue:    #5B87A5;   /* calm sky */
    --aw-green:   #6AAE63;   /* fresh growth */
    --aw-coral:   #E9836B;   /* energetic warmth */
    --aw-purple:  #6657B5;   /* creative depth */
    --aw-teal:    #2F9C9E;   /* trusted stability */
    --aw-gold:    #C79A55;   /* valued reward */
    --aw-navy:    #2F4350;   /* HR anchor / sidebar */

    /* Module accent assignments */
    --module-hris:        var(--aw-teal);
    --module-payroll:     var(--aw-coral);
    --module-ta:          var(--aw-blue);
    --module-benefits:    var(--aw-green);
    --module-reporting:   var(--aw-gold);
    --module-recruiting:  var(--aw-purple);
    --module-performance: var(--aw-brown);

    /* Semantic colours */
    --color-success:      #6AAE63;   /* aligned with --aw-green */
    --color-warning:      #C79A55;   /* aligned with --aw-gold */
    --color-danger:       #E9836B;   /* aligned with --aw-coral */
    --color-info:         #5B87A5;   /* aligned with --aw-blue */

    /* Shell layout */
    --sidebar-bg:         var(--aw-navy);
    --sidebar-width:      220px;
    --sidebar-text:       #CBD5E0;
    --sidebar-text-active:#FFFFFF;
    --sidebar-item-hover: #3D5464;
    --topbar-bg:          #FFFFFF;
    --topbar-height:      56px;
    --content-bg:         #F7F9FC;

    /* Typography */
    --font-family-base:   'Inter', 'Segoe UI', system-ui, sans-serif;
    --font-size-base:     14px;
    --font-size-sm:       12px;
    --font-size-lg:       16px;
    --font-weight-normal: 400;
    --font-weight-medium: 500;
    --font-weight-semibold: 600;

    /* Spacing scale */
    --space-1:    4px;
    --space-2:    8px;
    --space-3:    12px;
    --space-4:    16px;
    --space-5:    20px;
    --space-6:    24px;
    --space-8:    32px;
    --space-10:   40px;

    /* Border radius */
    --radius-sm:  4px;
    --radius-md:  6px;
    --radius-lg:  8px;
    --radius-xl:  12px;

    /* Elevation / shadow */
    --shadow-sm:  0 1px 3px rgba(0,0,0,0.08);
    --shadow-md:  0 2px 8px rgba(0,0,0,0.12);
    --shadow-lg:  0 4px 16px rgba(0,0,0,0.16);

    /* Syncfusion theme alignment */
    --sf-primary: var(--aw-teal);

    /* Icon background opacity for decorated module icons */
    --icon-bg-opacity: 0.15;
}
```

---
## 12.1 Module Icon Components

All module icons are Razor components located in `AllWorkHRIS.Web/Components/Icons/`. Each component:
- Uses a decorated Tabler SVG icon with a soft circular background fill
- Accepts a `Size` parameter (default 24) for use at both nav menu and larger display sizes
- Uses CSS custom properties for colour — never hardcoded hex values
- Scales cleanly from 20px (nav menu) to 96px (landing pages, empty states)

### Icon decoration pattern

Each icon applies the same two-layer decoration:
1. A soft circular background at `--icon-bg-opacity` (0.15) in the module colour
2. The Tabler icon path stroked at full module colour intensity

### HrisIcon.razor — Tabler `user`

```razor
@* AllWorkHRIS.Web/Components/Icons/HrisIcon.razor *@
<svg xmlns="http://www.w3.org/2000/svg"
     width="@Size" height="@Size"
     viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="11"
          fill="var(--module-hris)"
          opacity="var(--icon-bg-opacity)"/>
  <path stroke="var(--module-hris)"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
        d="M8 7a4 4 0 1 0 8 0a4 4 0 0 0-8 0
           M6 21v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/>
</svg>

@code {
    [Parameter] public int Size { get; set; } = 24;
}
```

### PayrollIcon.razor — Tabler `report-money`

```razor
@* AllWorkHRIS.Web/Components/Icons/PayrollIcon.razor *@
<svg xmlns="http://www.w3.org/2000/svg"
     width="@Size" height="@Size"
     viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="11"
          fill="var(--module-payroll)"
          opacity="var(--icon-bg-opacity)"/>
  <path stroke="var(--module-payroll)"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
        d="M9 5H7a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2
           M9 5a2 2 0 0 0 2 2h2a2 2 0 0 0 2-2
           M9 5a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2
           M9 14l2 2l4-4
           M9 17h4"/>
</svg>

@code {
    [Parameter] public int Size { get; set; } = 24;
}
```

### TimeAttendanceIcon.razor — Tabler `clock`

```razor
@* AllWorkHRIS.Web/Components/Icons/TimeAttendanceIcon.razor *@
<svg xmlns="http://www.w3.org/2000/svg"
     width="@Size" height="@Size"
     viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="11"
          fill="var(--module-ta)"
          opacity="var(--icon-bg-opacity)"/>
  <circle cx="12" cy="12" r="7"
          stroke="var(--module-ta)"
          stroke-width="1.5"
          fill="none"/>
  <path stroke="var(--module-ta)"
        stroke-width="1.5"
        stroke-linecap="round"
        fill="none"
        d="M12 9v3l2 2"/>
</svg>

@code {
    [Parameter] public int Size { get; set; } = 24;
}
```

### BenefitsIcon.razor — Tabler `heart-handshake`

```razor
@* AllWorkHRIS.Web/Components/Icons/BenefitsIcon.razor *@
<svg xmlns="http://www.w3.org/2000/svg"
     width="@Size" height="@Size"
     viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="11"
          fill="var(--module-benefits)"
          opacity="var(--icon-bg-opacity)"/>
  <path stroke="var(--module-benefits)"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
        d="M19.5 12.572L12 20l-7.5-7.428
           A5 5 0 1 1 12 6.006a5 5 0 1 1 7.5 6.572
           M12 6l-1.5 2.5L8 10l2.5 1.5L12 14l1.5-2.5L16 10l-2.5-1.5Z"/>
</svg>

@code {
    [Parameter] public int Size { get; set; } = 24;
}
```

### ReportingIcon.razor — Tabler `chart-bar`

```razor
@* AllWorkHRIS.Web/Components/Icons/ReportingIcon.razor *@
<svg xmlns="http://www.w3.org/2000/svg"
     width="@Size" height="@Size"
     viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="11"
          fill="var(--module-reporting)"
          opacity="var(--icon-bg-opacity)"/>
  <path stroke="var(--module-reporting)"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
        d="M3 12h4v7H3z
           M10 8h4v11h-4z
           M17 4h4v15h-4z
           M3 21h18"/>
</svg>

@code {
    [Parameter] public int Size { get; set; } = 24;
}
```

### RecruitingIcon.razor — Tabler `user-search` (future module)

```razor
@* AllWorkHRIS.Web/Components/Icons/RecruitingIcon.razor *@
<svg xmlns="http://www.w3.org/2000/svg"
     width="@Size" height="@Size"
     viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="11"
          fill="var(--module-recruiting)"
          opacity="var(--icon-bg-opacity)"/>
  <path stroke="var(--module-recruiting)"
        stroke-width="1.5"
        stroke-linecap="round"
        stroke-linejoin="round"
        fill="none"
        d="M8 7a4 4 0 1 0 8 0a4 4 0 0 0-8 0
           M6 21v-2a4 4 0 0 1 4-4h2
           M16.5 18.5m-2.5 0a2.5 2.5 0 1 0 5 0a2.5 2.5 0 0 0-5 0
           M21 21l-1.5-1.5"/>
</svg>

@code {
    [Parameter] public int Size { get; set; } = 24;
}
```

### PerformanceIcon.razor — Tabler `target` (future module)

```razor
@* AllWorkHRIS.Web/Components/Icons/PerformanceIcon.razor *@
<svg xmlns="http://www.w3.org/2000/svg"
     width="@Size" height="@Size"
     viewBox="0 0 24 24">
  <circle cx="12" cy="12" r="11"
          fill="var(--module-performance)"
          opacity="var(--icon-bg-opacity)"/>
  <circle cx="12" cy="12" r="7"
          stroke="var(--module-performance)"
          stroke-width="1.5"
          fill="none"/>
  <circle cx="12" cy="12" r="3"
          stroke="var(--module-performance)"
          stroke-width="1.5"
          fill="none"/>
  <path stroke="var(--module-performance)"
        stroke-width="1.5"
        stroke-linecap="round"
        fill="none"
        d="M12 3v2M12 19v2M3 12h2M19 12h2"/>
</svg>

@code {
    [Parameter] public int Size { get; set; } = 24;
}
```

### Usage in NavMenu

```razor
@* Size=20 for nav menu items *@
<HrisIcon Size="20" />
<PayrollIcon Size="20" />

@* Size=48 for module landing page cards *@
<HrisIcon Size="48" />
```

### Usage in MenuContribution

The `Icon` field on `MenuContribution` carries the component name as a string identifier. The `NavMenu.razor` component resolves this to the correct Razor component using a `RenderFragment` lookup:

```razor
@* NavMenu.razor — icon resolution *@
private RenderFragment? ResolveIcon(string? iconName, int size) => iconName switch
{
    "HrisIcon"            => @<HrisIcon Size="@size" />,
    "PayrollIcon"         => @<PayrollIcon Size="@size" />,
    "TimeAttendanceIcon"  => @<TimeAttendanceIcon Size="@size" />,
    "BenefitsIcon"        => @<BenefitsIcon Size="@size" />,
    "ReportingIcon"       => @<ReportingIcon Size="@size" />,
    "RecruitingIcon"      => @<RecruitingIcon Size="@size" />,
    "PerformanceIcon"     => @<PerformanceIcon Size="@size" />,
    _                     => null
};
```

## 12. Module Accent Colors

Each module declares its accent color in its `MenuContribution` entries. The standard module palette:

| Module | AccentColor token | Icon | BadgeLabel |
|---|---|---|
| HRIS | `var(--module-hris)` | `HrisIcon` | `HRIS` |
| Payroll | `var(--module-payroll)` | `PayrollIcon` | `PAY` |
| Benefits | `var(--module-benefits)` | `BenefitsIcon` | `BEN` |
| Time & Attendance | `var(--module-ta)` | `TimeAttendanceIcon` | `T&A` |
| Reporting | `var(--module-reporting)` | `ReportingIcon` | `RPT` |
| Recruiting (future) | `var(--module-recruiting)` | `RecruitingIcon` | `REC` |
| Performance (future) | `var(--module-performance)` | `PerformanceIcon` | `PRF` |
| Host (Home, Diagnostics) | `none` | `none` | `HOST` |

---

## 13. Authentication Scaffold

Authentication in v1 uses ASP.NET Core's built-in authentication middleware with OpenID Connect. The full authentication implementation is deferred to a dedicated auth spec. The scaffold establishes the integration points:

```csharp
// Program.cs — authentication registration (scaffold)
builder.Services.AddAuthentication(options =>
{
    options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
})
.AddCookie()
.AddOpenIdConnect(options =>
{
    options.Authority    = Environment.GetEnvironmentVariable("AUTH_AUTHORITY");
    options.ClientId     = Environment.GetEnvironmentVariable("AUTH_CLIENT_ID");
    options.ClientSecret = Environment.GetEnvironmentVariable("AUTH_CLIENT_SECRET");
    options.ResponseType = "code";
    options.SaveTokens   = true;
    options.Scope.Add("openid");
    options.Scope.Add("profile");
    options.Scope.Add("roles");
});

builder.Services.AddAuthorization();
builder.Services.AddCascadingAuthenticationState();
```

All Blazor pages shall require authentication by default via a `<AuthorizeRouteView>` in `App.razor`. Unauthenticated users are redirected to the OIDC login page.

---

## 14. EnvironmentValidator

```csharp
public static class EnvironmentValidator
{
    public static void ValidateRequired(params string[] variableNames)
    {
        var missing = variableNames
            .Where(name => string.IsNullOrWhiteSpace(
                Environment.GetEnvironmentVariable(name)))
            .ToList();

        if (missing.Count > 0)
            throw new InvalidOperationException(
                $"Required environment variables are not set: " +
                $"{string.Join(", ", missing)}. " +
                $"Check your environment configuration before starting the application.");
    }
}
```

---

## 15. Test Cases

| ID | Description | Expected Result |
|---|---|---|
| TC-HST-001 | Application starts with all required environment variables and user-secrets set | Application starts successfully; Syncfusion license registered; all modules discovered and registered |
| TC-HST-002 | Application starts with `SYNCFUSION_LICENSE_KEY` missing | Application throws `InvalidOperationException` with message identifying the missing variable before rendering any UI |
| TC-HST-003 | Application starts with `DATABASE_CONNECTION_STRING` missing | `EnvironmentValidator` throws `InvalidOperationException` listing the missing variable |
| TC-HST-004 | Module assembly present in modules folder | Module is discovered, `Register` called, services available in DI container |
| TC-HST-005 | Module assembly removed from modules folder | Module's services and menu contributions absent; application starts without error |
| TC-HST-006 | Module declares menu contributions with `RequiredRole = "PayrollOperator"` | Menu item visible to users with PayrollOperator role; not visible to users without it |
| TC-HST-007 | Module declares menu contributions with `RequiredRole = null` | Menu item visible to all authenticated users |
| TC-HST-008 | Unauthenticated user navigates to any page | User redirected to OIDC login page |
| TC-HST-009 | `DATABASE_PROVIDER` set to `postgresql` | `ConnectionFactory.CreateConnection()` returns `NpgsqlConnection` |
| TC-HST-010 | `DATABASE_PROVIDER` set to `sqlserver` | `ConnectionFactory.CreateConnection()` returns `SqlConnection` |
| TC-HST-011 | `DATABASE_PROVIDER` set to unsupported value | `ConnectionFactory` throws `InvalidOperationException` with provider name in message |
| TC-HST-012 | Two modules both declare services; no circular dependency | Autofac container builds successfully; both modules' services resolve correctly |
| TC-HST-013 | `UnitOfWork` commits successfully | Both operations in the transaction are persisted; connection disposed |
| TC-HST-014 | `UnitOfWork` rolls back on exception | Neither operation in the transaction is persisted; connection disposed |
| TC-HST-015 | `APP_DISPLAY_NAME` environment variable set to custom value | Shell top bar displays custom name |
| TC-HST-016 | `APP_DISPLAY_NAME` not set | Shell top bar displays default `AllWorkHRIS` |
| TC-HST-017 | Minimal API endpoint receives request without authentication token | Returns HTTP 401 |
| TC-HST-018 | NavMenu renders with two modules contributing items | Items from both modules appear in nav, sorted by SortOrder, with correct AccentColor badges |
