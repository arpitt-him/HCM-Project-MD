# ADR-010 — Tenant Isolation Strategy: Autofac-Resolved IConnectionFactory

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.1 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-010_Tenant_Isolation_Strategy.md` |
| **Date** | April 2026 |
| **Related Documents** | ADR-004_Data_Access_Strategy, ADR-007_Module_Composition_DI_Lifetime, ADR-009_Authentication_Identity_Strategy, SPEC/Host_Application_Shell, docs/architecture/governance/Security_and_Access_Control_Model.md |

---

## Context

The platform supports multi-tenant operation — multiple client companies may run on the same platform instance, each with their own employment records, payroll data, and configuration. The architecture must ensure that one tenant's data is never accessible to another tenant's users under any circumstance, including misuse of filter parameters or application bugs.

Three isolation models exist for multi-tenant database architectures:

**Option 1 — Separate database per tenant.** Each client company has its own database. Complete physical isolation. No possibility of cross-tenant data leakage at the query level. Connection management is simple — each tenant has a distinct connection string.

**Option 2 — Shared database, tenant_id column on every table.** All tenants share one database. Every table has a `tenant_id` column. Every query must filter by `tenant_id`. Risk: one missing filter in any query leaks cross-tenant data.

**Option 3 — Shared database, separate schema per tenant.** Each tenant has their own PostgreSQL schema within one database. Connection routing sets `search_path` to the correct schema per request. Cross-tenant queries are possible within the same database but require explicit schema qualification.

**Cross-tenant reporting** was evaluated as a platform concern and explicitly excluded. A PEO operator who needs aggregate data across client companies does so in Excel or a BI tool — the platform does not provide federated reporting across tenants. This removes the primary advantage of Options 2 and 3 over Option 1.

**The platform must support all three models** as deployment options offered to prospective clients based on their data isolation requirements, compliance obligations, and risk appetite. This is a product positioning decision — not all clients have the same isolation requirements, and the platform should not impose a single model.

The key architectural challenge is therefore not choosing one model but enabling all three from the same application codebase without conditional logic scattered through repositories and services.

---

## Decision

**All three isolation models shall be supported as deployment options. The isolation model is a deployment-time configuration choice made per client engagement. The application code is identical in all three models.**

**The mechanism that enables this is Autofac's per-request lifetime scope resolution of `IConnectionFactory`. Repositories and services are completely unaware of which isolation model is in use.**

### How It Works

At request startup, ASP.NET Core middleware reads the `tenant_id` claim from the authenticated JWT (established by ADR-009). Autofac resolves the correct `IConnectionFactory` implementation for that tenant within the request's lifetime scope. All repositories and services in that request resolve `IConnectionFactory` from Autofac and receive the tenant-correct connection automatically.

```csharp
// Middleware — runs on every authenticated request
public class TenantConnectionMiddleware
{
    public async Task InvokeAsync(HttpContext context, ILifetimeScope scope)
    {
        var tenantId = context.User.FindFirst("tenant_id")?.Value
            ?? throw new UnauthorizedException("tenant_id claim missing from token.");

        // Resolve the correct connection factory for this tenant
        var factory = _tenantRegistry.ResolveFactory(tenantId);

        // Register it in the per-request Autofac lifetime scope
        // All IConnectionFactory resolutions in this request get this instance
        scope.BeginLifetimeScope(builder =>
            builder.RegisterInstance(factory).As<IConnectionFactory>());

        await _next(context);
    }
}
```

Repositories receive `IConnectionFactory` through constructor injection and call `CreateConnection()`. They have no knowledge of which tenant they are serving, which database they are connecting to, or which isolation model is in use.

```csharp
// Repository — completely unaware of tenant context
public sealed class EmploymentRepository : IEmploymentRepository
{
    private readonly IConnectionFactory _connectionFactory;

    public EmploymentRepository(IConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    public async Task<Employment?> GetByIdAsync(Guid employmentId)
    {
        using var conn = _connectionFactory.CreateConnection();
        return await conn.QueryFirstOrDefaultAsync<Employment>(
            "SELECT * FROM employment WHERE employment_id = @Id",
            new { Id = employmentId });
    }
}
```

### The Three IConnectionFactory Implementations

Each isolation model has its own `IConnectionFactory` implementation. The `TenantRegistry` resolves the correct one per tenant based on deployment configuration.

**Option 1 — Separate database:**

```csharp
public sealed class DedicatedDatabaseConnectionFactory : IConnectionFactory
{
    private readonly string _connectionString;
    private readonly string _provider;

    public DedicatedDatabaseConnectionFactory(
        string connectionString, string provider)
    {
        _connectionString = connectionString;
        _provider         = provider;
    }

    public IDbConnection CreateConnection()
    {
        var connection = ProviderFactory.Create(_provider, _connectionString);
        connection.Open();
        return connection;
    }
}
```

Each tenant has a distinct connection string pointing to their dedicated database. The `TenantRegistry` maps `tenant_id` to the correct connection string.

**Option 2 — Shared database, tenant_id filtering:**

```csharp
public sealed class SharedDatabaseConnectionFactory : IConnectionFactory
{
    private readonly string _connectionString;
    private readonly string _provider;
    private readonly Guid   _tenantId;

    public SharedDatabaseConnectionFactory(
        string connectionString, string provider, Guid tenantId)
    {
        _connectionString = connectionString;
        _provider         = provider;
        _tenantId         = tenantId;
    }

    public IDbConnection CreateConnection()
    {
        var connection = ProviderFactory.Create(_provider, _connectionString);
        connection.Open();
        return new TenantScopedConnection(connection, _tenantId);
    }
}
```

`TenantScopedConnection` wraps the underlying connection and enforces `tenant_id` filtering. All queries executed through this connection automatically include `AND tenant_id = @TenantId`. This is the governed mechanism that prevents cross-tenant leakage for Option 2 — enforcement is at the connection layer, not the query layer.

**Option 3 — Separate schema:**

```csharp
public sealed class SchemaIsolatedConnectionFactory : IConnectionFactory
{
    private readonly string _connectionString;
    private readonly string _schemaName;

    public SchemaIsolatedConnectionFactory(
        string connectionString, string schemaName)
    {
        _connectionString = connectionString;
        _schemaName       = schemaName;
    }

    public IDbConnection CreateConnection()
    {
        // PostgreSQL: include schema in connection string or set after open
        var connection = new NpgsqlConnection(
            $"{_connectionString};Search Path={_schemaName},public");
        connection.Open();
        return connection;
    }
}
```

Each tenant has their own PostgreSQL schema. The `search_path` is set on connection open, routing all queries to the correct schema automatically.

### TenantRegistry

```csharp
public sealed class TenantRegistry
{
    private readonly Dictionary<string, IConnectionFactory> _factories;

    public TenantRegistry(IEnumerable<TenantConfig> configs)
    {
        _factories = configs.ToDictionary(
            c => c.TenantId,
            c => BuildFactory(c));
    }

    public IConnectionFactory ResolveFactory(string tenantId)
    {
        if (_factories.TryGetValue(tenantId, out var factory))
            return factory;

        throw new UnauthorizedException(
            $"Unknown tenant: {tenantId}");
    }

    private static IConnectionFactory BuildFactory(TenantConfig config) =>
        config.IsolationModel switch
        {
            IsolationModel.DedicatedDatabase =>
                new DedicatedDatabaseConnectionFactory(
                    config.ConnectionString, config.Provider),

            IsolationModel.SharedDatabase =>
                new SharedDatabaseConnectionFactory(
                    config.ConnectionString, config.Provider,
                    Guid.Parse(config.TenantId)),

            IsolationModel.SeparateSchema =>
                new SchemaIsolatedConnectionFactory(
                    config.ConnectionString, config.SchemaName),

            _ => throw new InvalidOperationException(
                $"Unknown isolation model: {config.IsolationModel}")
        };
}
```

The `TenantRegistry` is registered as a singleton in Autofac at startup. Tenant configurations are loaded from the platform configuration store (a `tenants` table in a small platform-level management database, or from environment-based config for single-tenant deployments).

### Single-Tenant Deployments

For a single-tenant on-premises deployment, the `TenantRegistry` contains exactly one entry. The `tenant_id` claim in every JWT maps to that one entry. The middleware resolves the same factory on every request. The multi-tenant machinery is present but invisible.

For development, a single tenant with a local database is the standard configuration.

---

## Isolation Model Selection Guide

This guide is for use in client engagement conversations:

| Scenario | Recommended Model |
|---|---|
| Small to mid-size client, standard compliance requirements, cost-sensitive | Option 2 — Shared database |
| Client with strict data sovereignty or regulatory isolation requirements | Option 1 — Dedicated database |
| Client requiring logical isolation with cross-client reporting by the PEO operator | Option 3 — Separate schemas |
| On-premises single-tenant deployment | Option 1 — Dedicated database (simplest) |
| SaaS multi-tenant deployment, mixed client profile | Options 1 and 2 mixed — per client configuration |

---

## Consequences

**Positive:**
- Repository and service code is completely isolation-model agnostic — no conditional logic, no tenant_id parameters scattered through domain code
- All three models are supported from the same codebase — the isolation model is a deployment configuration choice, not an application architecture choice
- Adding a new tenant is an operational task (add a `TenantConfig` entry and provision the database/schema) — no code change required
- Autofac's per-request lifetime scope ensures the correct factory is used for every database interaction in a request — there is no way for a request to accidentally resolve the wrong factory
- The `TenantScopedConnection` wrapper for Option 2 enforces `tenant_id` filtering at the connection level — it cannot be bypassed by a developer writing a query that forgets the filter
- Validated by prior production experience with the Autofac multi-database routing pattern

**Constraints to manage:**
- For Option 2, the `TenantScopedConnection` wrapper must be tested exhaustively — it is the single point of cross-tenant isolation and any bug in it has serious consequences
- For Option 3, `search_path` must be verified on every connection checkout from the pool — a pooled connection that retains a prior session's `search_path` would route queries to the wrong schema
- Schema migrations must be applied to all tenant databases (Option 1) or all tenant schemas (Option 3) — migration tooling must handle this at deployment time
- The `tenant_id` JWT claim is the trust anchor — if the identity provider issues incorrect `tenant_id` values, isolation breaks. Identity provider configuration must be validated at onboarding time

**Future consideration:**
- For PEO deployments where the PEO operator needs administrative visibility across all client tenants, a superuser authentication path with an elevated `tenant_scope = ALL` claim can be implemented without changing the core pattern. The `TenantRegistry` resolves a special aggregate factory for this claim.

---

## Amendments to Host_Application_Shell SPEC

The `IConnectionFactory` implementation in `SPEC/Host_Application_Shell.md` §7 shows a simple single-tenant implementation using `DATABASE_CONNECTION_STRING` and `DATABASE_PROVIDER` environment variables. This remains correct for single-tenant and development deployments. For multi-tenant deployments, the `TenantRegistry` pattern described in this ADR replaces the singleton `ConnectionFactory` registration at startup. The `IConnectionFactory` interface is unchanged — only the registration and resolution mechanism differs.

---

## Alternatives Considered

**Choose one isolation model for all deployments**
Simplest implementation — one model, no switching logic. Rejected — constrains the product's commercial flexibility; different clients have legitimately different isolation requirements and the platform should not impose a single model when supporting all three is achievable through the `IConnectionFactory` abstraction at no cost to repository or service code.

**Row-level security in the database (PostgreSQL RLS)**
Database enforces tenant isolation through row-level security policies without application-layer filtering. Provides strong isolation guarantee. Rejected — not supported equivalently across all three target DBMS providers (PostgreSQL, SQL Server, MySQL); adds database-specific logic that conflicts with the DBMS portability goal in ADR-004; harder to test and debug than application-layer isolation.

**Tenant_id parameter on every repository method**
Every repository method signature includes a `tenantId` parameter. Simple and explicit. Rejected — pollutes every method signature in the codebase; relies on developer discipline to include it correctly in every call; does not prevent a developer from accidentally omitting it; the Autofac lifetime scope pattern achieves the same result without any pollution of the domain layer.
