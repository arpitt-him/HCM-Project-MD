# ADR-008 — API Surface Architecture: Minimal API

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.1 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-008_API_Surface_Architecture.md` |
| **Date** | April 2026 |
| **Related Documents** | ADR-003_UI_Technology_Stack, ADR-007_Module_Composition_DI_Lifetime, PRD-0900_Integration_Model, docs/SPEC/API_Surface_Map.md, docs/SPEC/API_Contract_Standards.md |

---

## Context

The platform requires an HTTP API surface to support:

- Inbound integration endpoints — batch file submissions, per-record API intake for employee records, time entries, benefit elections, external earnings, and legal orders (as defined in `SPEC/API_Surface_Map.md`)
- Async job submission endpoints — operators and integrating systems submit long-running operations and receive a `Job_ID` in response (as defined in `Async_Job_Execution_Model.md`)
- Outbound webhook and event delivery endpoints where external systems need to receive platform-initiated notifications
- Future external API access for client-developed integrations

The platform UI is implemented in Blazor Server (ADR-003), which handles all interactive user-facing functionality directly through the .NET Core process. The UI does not require an API layer — Blazor components call services directly through the Autofac DI container.

ASP.NET Core MVC was originally considered as the framework for both UI and API surfaces, primarily due to familiarity. Following the decision to adopt Blazor Server for the UI, MVC's role was reconsidered. Coexisting MVC and Blazor Server in the same application introduces routing conflicts, layout interference, middleware ordering complexity, and competing conventions — risks identified in the stack review.

---

## Decision

**ASP.NET Core MVC shall not be used. The HTTP API surface shall be implemented using .NET Core Minimal API.**

The platform application has a clean two-layer HTTP surface:

- **Blazor Server** — all interactive UI, rendered server-side, communicating over SignalR
- **Minimal API** — all programmatic HTTP endpoints for integration intake, job submission, and external API access

There is no MVC layer. There are no MVC controllers. There are no Razor views or MVC layouts.

---

## Minimal API Pattern

Integration endpoints are declared as Minimal API route handlers, organised by domain:

```csharp
// Program.cs or a dedicated endpoint registration class
app.MapPost("/api/employees/import", async (
    IEmployeeBatchImportService importService,
    IFormFile file,
    CancellationToken ct) =>
{
    var jobId = await importService.SubmitBatchAsync(file, ct);
    return Results.Accepted($"/api/jobs/{jobId}", new { JobId = jobId });
})
.RequireAuthorization("hris:employees:write")
.WithName("SubmitEmployeeBatchImport");

app.MapGet("/api/jobs/{jobId}", async (
    Guid jobId,
    IJobStatusService jobStatusService) =>
{
    var status = await jobStatusService.GetStatusAsync(jobId);
    return status is null ? Results.NotFound() : Results.Ok(status);
})
.RequireAuthorization()
.WithName("GetJobStatus");
```

Endpoint handlers are thin — they validate the request, call a service resolved from the Autofac container, and return a result. No business logic lives in endpoint handlers.

---

## Endpoint Organisation

Minimal API endpoints shall be organised into endpoint group classes by domain, following the module structure:

```csharp
public static class HrisEndpoints
{
    public static void Map(WebApplication app)
    {
        var group = app.MapGroup("/api/hris")
                       .RequireAuthorization();

        group.MapPost("/employees/import", SubmitEmployeeBatchImport);
        group.MapPost("/employees", CreateEmployee);
        group.MapGet("/employees/{employmentId}", GetEmployee);
        group.MapPost("/events", SubmitLifecycleEvent);
    }
}

// Registered in Program.cs
HrisEndpoints.Map(app);
PayrollEndpoints.Map(app);
TimeAttendanceEndpoints.Map(app);
```

Each module's endpoints are registered by the host application. Unlike service registrations (which modules declare themselves via `IPlatformModule.Register`), API endpoint registration is explicit in the host — this is intentional, as the host owns the API surface contract.

---

## Relationship to Blazor Server

Blazor components do not call API endpoints. They call services directly through the Autofac DI container. The Minimal API layer exists exclusively for:

- External system integration (batch imports, per-record API intake)
- Async job submission from UI actions that cross the HTTP boundary
- Future external API consumers (client-developed integrations)

The `app.MapBlazorHub()` registration and the Minimal API registrations coexist cleanly in the same `.NET Core` application with no routing conflicts — Blazor's SignalR hub is at `/_blazor` and API endpoints are under `/api`. There is no MVC fallback route that could intercept either.

---

## Middleware Order

```csharp
// Program.cs — correct middleware order
app.UseStaticFiles();
app.UseRouting();
app.UseAuthentication();
app.UseAuthorization();

app.MapBlazorHub();           // Blazor SignalR hub
app.MapFallbackToPage("/_Host");  // Blazor host page
// Minimal API endpoints registered above fallback
HrisEndpoints.Map(app);
PayrollEndpoints.Map(app);
// etc.
```

`MapBlazorHub()` is placed before the fallback. Minimal API endpoints are explicit routes that resolve before the Blazor fallback. There is no MVC middleware in the pipeline.

---

## Consequences

**Positive:**
- No routing conflicts — Blazor Server and Minimal API coexist cleanly with no competing routing conventions
- No MVC overhead — no controller base classes, no action filters, no view engine, no MVC middleware in the pipeline
- Minimal API's explicit route declarations are consistent with the platform's preference for explicit over convention-based patterns (ADR-004)
- Endpoint handlers are thin by design — business logic in services, not controllers
- OpenAPI / Swagger documentation is supported natively via `app.MapOpenApi()` without MVC
- Familiar enough for any .NET Core developer — Minimal API is now the recommended pattern for new .NET Core API development

**Constraints to manage:**
- Endpoint registration is explicit in the host — modules cannot self-register their API endpoints the way they self-register services via `IPlatformModule`. This is intentional but means the host must be updated when a new module's endpoints are added
- Complex request binding (multipart forms, custom model binders) requires slightly more explicit handling in Minimal API than MVC — manageable but requires awareness
- Minimal API lacks MVC's built-in model validation pipeline — validation must be implemented explicitly in service layer or via a filter/middleware

**Future consideration:**
- If the external API surface grows significantly — versioning, complex content negotiation, extensive OpenAPI documentation — a dedicated API project separate from the Blazor Server host application may be warranted. The Minimal API endpoints can be migrated to a separate project without changing the service layer.

---

## Amendments to ADR-003

ADR-003 (UI Technology Stack) is updated by this decision. The following clarification applies:

**MVC is not used.** The platform application contains Blazor Server for UI and Minimal API for HTTP endpoints only. ASP.NET Core MVC — including controllers, Razor views, and the MVC middleware pipeline — is explicitly excluded. This eliminates the routing conflicts, layout interference, and middleware ordering complexity identified in the stack review.

---

## Alternatives Considered

**ASP.NET Core MVC**
Originally considered due to familiarity. Rejected — coexistence with Blazor Server introduces routing conflicts, competing layout conventions, and middleware ordering complexity. MVC's strengths (convention-based controller discovery, Razor views, action filters) are not relevant to an API-only surface. Minimal API is simpler, lighter, and introduces none of the coexistence risks.

**Separate API project (Web API)**
A dedicated ASP.NET Core Web API project separate from the Blazor Server host. Viable architecture — clean separation of UI and API. Not selected for v1 because: adds a second deployable project and its associated operational complexity; cross-project service sharing requires additional packaging; the integration endpoints at v1 scale do not justify the separation. Documented as a future option if the API surface grows.

**gRPC**
High-performance RPC framework. Rejected — batch file intake, webhook delivery, and standard REST integration patterns are the primary use cases; gRPC adds complexity and tooling requirements without benefit for these patterns; external integrating systems expect HTTP/REST, not gRPC.
