# SPEC — Host Application Shell

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/Host_Application_Shell.md` |
| **Related Documents** | ADR-003_UI_Technology_Stack, ADR-006_UI_Component_Library, ADR-007_Module_Composition_DI_Lifetime, ADR-008_API_Surface_Architecture, PRD-0100_Architecture_Principles, docs/SPEC/API_Contract_Standards.md, docs/architecture/governance/Security_and_Access_Control_Model.md |

---

## Purpose

Defines the implementation-ready specification for the BlazorHR host application shell — the foundation on which all platform modules are composed. This document covers solution structure, startup sequence, module composition contracts, shell layout, navigation, authentication scaffold, CSS design tokens, environment configuration, and test cases.

The host application shell contains no business logic. It is the runtime container that discovers modules, composes the DI container, renders the shell UI, and routes to module-owned pages.

---

## 1. Solution Structure

```
BlazorHR.sln
│
├── src/
│   ├── BlazorHR.Host/                    # Blazor Server host application
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
│   │   └── wwwroot/
│   │       ├── css/
│   │       │   └── app.css               # CSS custom properties (design tokens)
│   │       └── favicon.ico
│   │
│   ├── BlazorHR.Core/                    # Shared contracts and base types
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
│	│   └── Events/
│	│       ├── IEventPublisher.cs
│	│       ├── InProcessEventBus.cs
│	│       ├── HireEventPayload.cs
│	│       ├── RehireEventPayload.cs
│	│       ├── TerminationEventPayload.cs
│	│       ├── CompensationChangeEventPayload.cs
│	│       ├── LeaveApprovedPayload.cs
│	│       └── ReturnToWorkPayload.cs
│   │
│   └── modules/                          # Module assemblies drop folder
│       └── (deployed module .dlls)
│
└── tests/
    └── BlazorHR.Host.Tests/
```

---

## 2. Environment Configuration

The following environment variables are required at startup. The application shall fail fast with a descriptive error message if any required variable is absent.

| Variable | Required | Description |
|---|---|---|
| `SYNCFUSION_LICENSE_KEY` | Yes | Syncfusion Essential Studio license key |
| `DATABASE_CONNECTION_STRING` | Yes | ADO.NET connection string for the primary database |
| `DATABASE_PROVIDER` | Yes | `postgresql`, `sqlserver`, or `mysql` |
| `APP_ENVIRONMENT` | Yes | `Development`, `Staging`, or `Production` |
| `TEMPORAL_OVERRIDE_ENABLED` | No | `true` to enable Temporal Override capability; defaults to `false`; must be `false` in Production |
| `AUTH_AUTHORITY` | Yes | OAuth2 / OIDC authority URL |
| `AUTH_CLIENT_ID` | Yes | OAuth2 client ID |
| `AUTH_CLIENT_SECRET` | Yes | OAuth2 client secret |
| `MODULES_PATH` | No | Path to module assemblies folder; defaults to `./modules` |
| `APP_DISPLAY_NAME` | No | Display name shown in the shell top bar; defaults to `BlazorHR` |

For local development, environment variables are declared in `launchSettings.json` under `environmentVariables`. This file shall not contain production credential values.

---

## 3. Program.cs Startup Sequence

The startup sequence is strictly ordered. Each step must complete successfully before the next begins.

```csharp
// 1. Register Syncfusion license — must be first, before any component renders
var syncfusionKey = Environment.GetEnvironmentVariable("SYNCFUSION_LICENSE_KEY")
    ?? throw new InvalidOperationException(
        "SYNCFUSION_LICENSE_KEY environment variable is not set.");
Syncfusion.Licensing.SyncfusionLicenseProvider.RegisterLicense(syncfusionKey);

// 2. Create builder
var builder = WebApplication.CreateBuilder(args);

// 3. Validate required environment variables
EnvironmentValidator.ValidateRequired(
    "DATABASE_CONNECTION_STRING",
    "DATABASE_PROVIDER",
    "APP_ENVIRONMENT",
    "AUTH_AUTHORITY",
    "AUTH_CLIENT_ID",
    "AUTH_CLIENT_SECRET");

// 4. Discover modules via MEF
var modulesPath = Environment.GetEnvironmentVariable("MODULES_PATH") ?? "./modules";
var platformModules = ModuleDiscovery.DiscoverModules(modulesPath);

// 5. Build Autofac container
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

// 5a. Register InProcessEventBus as singleton — before modules register handlers
	autofacBuilder.RegisterType<InProcessEventBus>()
				  .As<IEventPublisher>()
				  .SingleInstance();

// 6. Collect menu contributions and register as singleton
var menuContributions = platformModules
    .SelectMany(m => m.GetMenuContributions())
    .OrderBy(c => c.SortOrder)
    .ToList();
builder.Services.AddSingleton(menuContributions);

// 7. Register Syncfusion services
builder.Services.AddSyncfusionBlazor();

// 8. Register Blazor Server
builder.Services.AddRazorComponents()
                .AddInteractiveServerComponents();

// 9. Register authentication
builder.Services.AddAuthentication(...)
                .AddOpenIdConnect(...);
builder.Services.AddAuthorization();
builder.Services.AddCascadingAuthenticationState();

// 10. Build application
var app = builder.Build();

// 11. Configure middleware pipeline
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

// 12. Register Minimal API endpoints
HrisEndpoints.Map(app);
PayrollEndpoints.Map(app);
// Additional module endpoints registered here as modules are built

// 13. Map Blazor hub and fallback
app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

// 14. Run
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

        var catalog = new DirectoryCatalog(modulesPath, "BlazorHR.Module.*.dll");
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

Module assembly naming convention: `BlazorHR.Module.{ModuleName}.dll`
Examples: `BlazorHR.Module.Hris.dll`, `BlazorHR.Module.Payroll.dll`

---

## 5. IPlatformModule Contract

```csharp
// BlazorHR.Core/Composition/IPlatformModule.cs
using Autofac;

namespace BlazorHR.Core.Composition;

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
// BlazorHR.Core/Composition/MenuContribution.cs
namespace BlazorHR.Core.Composition;

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
// BlazorHR.Core/Data/IConnectionFactory.cs
using System.Data;

namespace BlazorHR.Core.Data;

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
// BlazorHR.Core/Data/IUnitOfWork.cs
using System.Data;

namespace BlazorHR.Core.Data;

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
        Environment.GetEnvironmentVariable("APP_DISPLAY_NAME") ?? "BlazorHR";
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
/* app.css — BlazorHR design tokens */
:root {
    /* Brand palette — muted Caribbean pastels */
    --color-primary:          #5B8FA8;   /* Muted Caribbean blue */
    --color-primary-light:    #A8C5D6;   /* Light blue */
    --color-primary-dark:     #3D6478;   /* Deep blue */

    --color-accent-teal:      #4ECDC4;   /* HRIS module */
    --color-accent-coral:     #F4A98A;   /* Payroll module */
    --color-accent-sage:      #8DB596;   /* Benefits module */
    --color-accent-lavender:  #A89BC2;   /* T&A module */
    --color-accent-sand:      #C9B99A;   /* Reporting module */

    /* Semantic colours */
    --color-success:          #5BA85B;
    --color-warning:          #C9A84C;
    --color-danger:           #C96B6B;
    --color-info:             #5B8FA8;

    /* Shell layout */
    --sidebar-bg:             #1E2430;   /* Dark sidebar background */
    --sidebar-width:          220px;
    --sidebar-text:           #CBD5E0;
    --sidebar-text-active:    #FFFFFF;
    --sidebar-item-hover:     #2D3748;
    --topbar-bg:              #FFFFFF;
    --topbar-height:          56px;
    --content-bg:             #F7F9FC;

    /* Typography */
    --font-family-base:       'Inter', 'Segoe UI', system-ui, sans-serif;
    --font-size-base:         14px;
    --font-size-sm:           12px;
    --font-size-lg:           16px;
    --font-weight-normal:     400;
    --font-weight-medium:     500;
    --font-weight-semibold:   600;

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
    --sf-primary: var(--color-primary);
}
```

---

## 12. Module Accent Colors

Each module declares its accent color in its `MenuContribution` entries. The standard module palette:

| Module | AccentColor token | BadgeLabel |
|---|---|---|
| HRIS | `var(--color-accent-teal)` | `HRIS` |
| Payroll | `var(--color-accent-coral)` | `PAY` |
| Benefits | `var(--color-accent-sage)` | `BEN` |
| Time & Attendance | `var(--color-accent-lavender)` | `T&A` |
| Reporting | `var(--color-accent-sand)` | `RPT` |
| Host (Home, Diagnostics) | `none` | `HOST` |

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
| TC-HST-001 | Application starts with all required environment variables set | Application starts successfully; Syncfusion license registered; all modules discovered and registered |
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
| TC-HST-016 | `APP_DISPLAY_NAME` not set | Shell top bar displays default `BlazorHR` |
| TC-HST-017 | Minimal API endpoint receives request without authentication token | Returns HTTP 401 |
| TC-HST-018 | NavMenu renders with two modules contributing items | Items from both modules appear in nav, sorted by SortOrder, with correct AccentColor badges |
