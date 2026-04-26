# ADR-011 — Module Independence Principle

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.2 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-011_Module_Independence_Principle.md` |
| **Date** | April 2026 |
| **Related Documents** | ADR-001_Event_Driven_Architecture, ADR-007_Module_Composition_DI_Lifetime, ADR-010_Tenant_Isolation_Strategy, SPEC/Host_Application_Shell, SPEC/HRIS_Core_Module, SPEC/Payroll_Core_Module |

---

## Context

The platform is designed as a set of independently deployable modules — HRIS, Payroll, Benefits, T&A, and Reporting. The architectural intent is that any module can be deployed without any other module being present. Specifically, the HRIS module must be deployable as a standalone application with no Payroll, Benefits, T&A, or Reporting modules present — and the application must function correctly in that configuration.

During the specification phase, several coupling points were identified that would prevent true module independence:

**Coupling point 1 — `PayrollContextId` required on `HireEmployeeCommand`.**
The hire command requires a `PayrollContextId` field, forcing the operator to supply payroll-specific context even when the Payroll module is not deployed. In an HRIS-only deployment, no payroll contexts exist and this field has no valid value.

**Coupling point 2 — Event payloads defined in module assemblies.**
`HireEventPayload`, `TerminationEventPayload`, `CompensationChangeEventPayload`, `LeaveApprovedPayload`, and `ReturnToWorkPayload` are defined in `AllWorkHRIS.Module.Hris`. The Payroll module's `IPayrollEventSubscriber` references these types — giving Payroll a compile-time dependency on HRIS. This violates the independence principle: if HRIS is not deployed, Payroll cannot compile.

**Coupling point 3 — Event publisher calls module subscribers directly.**
The HRIS event publisher was specified to "notify in-process subscribers (Payroll module service, T&A module service) synchronously post-commit." This means HRIS has runtime knowledge of Payroll and T&A — it must reference their subscriber interfaces to call them. If those modules are absent, the call fails.

**Coupling point 4 — Schema application order.**
The build plan applied both the HRIS and Payroll schemas together in Phase 0, making it impossible to run an HRIS-only deployment without the Payroll schema also being present.

These coupling points were not intentional design decisions — they emerged from specification decisions that did not fully account for the module independence requirement. This ADR formally states the independence principle and the rules that prevent future coupling of the same kind.

---

## Decision

**Each platform module shall be deployable independently. No module shall have a compile-time or runtime dependency on any other module. The only shared dependency is `AllWorkHRIS.Core`.**

### Rule 1 — No cross-module project references

A module assembly (`AllWorkHRIS.Module.X`) shall reference only `AllWorkHRIS.Core` and standard NuGet packages. It shall never reference another module assembly (`AllWorkHRIS.Module.Y`). Violation of this rule is a build error.

### Rule 2 — Event payloads live in AllWorkHRIS.Core

All inter-module event payloads are defined in `AllWorkHRIS.Core/Events/`. Any module that publishes or subscribes to an event references the payload type from `AllWorkHRIS.Core` — never from another module.

```
AllWorkHRIS.Core/
└── Events/
    ├── HireEventPayload.cs
    ├── TerminationEventPayload.cs
    ├── RehireEventPayload.cs
    ├── CompensationChangeEventPayload.cs
    ├── LeaveApprovedPayload.cs
    └── ReturnToWorkPayload.cs
```

### Rule 3 — Event publisher is a no-op bus with zero-subscriber safety

The `IEventPublisher` is implemented as an in-process event bus registered in `AllWorkHRIS.Core`. Modules register handlers at startup when present. If no handlers are registered for a given event type, publication is a silent no-op — not an exception.

```csharp
// AllWorkHRIS.Core/Events/IEventPublisher.cs
public interface IEventPublisher
{
    Task PublishAsync<T>(T payload) where T : class;

    /// <summary>
    /// Registers a handler for event type T.
    /// Called by modules at startup via IPlatformModule.Register.
    /// If no handlers are registered for T, PublishAsync is a no-op.
    /// </summary>
    void RegisterHandler<T>(Func<T, Task> handler) where T : class;
}

// AllWorkHRIS.Core/Events/InProcessEventBus.cs
public sealed class InProcessEventBus : IEventPublisher
{
    private readonly ConcurrentDictionary<Type, List<Func<object, Task>>> _handlers = new();

    public void RegisterHandler<T>(Func<T, Task> handler) where T : class
    {
        _handlers.GetOrAdd(typeof(T), _ => [])
                 .Add(payload => handler((T)payload));
    }

    public async Task PublishAsync<T>(T payload) where T : class
    {
        if (_handlers.TryGetValue(typeof(T), out var handlers))
            foreach (var handler in handlers)
                await handler(payload);
        // No handlers registered = silent no-op
        // This is the correct and expected behaviour in HRIS-only deployments
    }
}
```

The `InProcessEventBus` is registered as a singleton in `AllWorkHRIS.Host` `Program.cs`. Each module registers its handlers in its `Register(ContainerBuilder builder)` method.

### Rule 4 — Module-optional fields use nullable types

Any command field that is only meaningful when a specific module is deployed shall be nullable (`Guid?`, `string?`) rather than required. The HRIS module must not enforce the presence of Payroll-specific context when Payroll is not deployed.

Specifically: `PayrollContextId` on `HireEmployeeCommand` is `Guid?` — optional. When the Payroll module is present and processes the `HireEventPayload`, it reads this value if present. When the Payroll module is absent, the field is simply not populated.

### Rule 5 — Schemas are applied per module, not together

Each module owns its own schema file. Schemas are applied in deployment order — only the schemas for deployed modules are applied. An HRIS-only deployment applies `hris_schema.sql` only. Adding Payroll to the deployment applies `payroll_core_schema.sql` as an additive step. No schema file may contain references to tables owned by another module's schema.

### Rule 6 — Module handler registration pattern

When a module subscribes to events from another module, it registers its handlers in its own `Register` method — not in the publishing module. The publishing module has no knowledge of who is listening.

```csharp
// In PayrollModule.Register — Payroll registers its own handlers
public void Register(ContainerBuilder builder)
{
    // ... repository and service registrations ...

    // Register HRIS event handlers — called only when Payroll module is present
    var eventBus = // resolve from builder
    eventBus.RegisterHandler<HireEventPayload>(
        async payload => await _payrollEventSubscriber.HandleHireAsync(payload));
    eventBus.RegisterHandler<TerminationEventPayload>(
        async payload => await _payrollEventSubscriber.HandleTerminationAsync(payload));
    // etc.
}
```

When the Payroll module is absent, no handlers are registered for these event types. HRIS publishes and the bus silently discards — correct behaviour.

---

## Proof of Independence

The following test at the end of Phase 2 formally proves HRIS module independence:

**HRIS Standalone Test:**
1. Apply `hris_schema.sql` only — no payroll schema
2. Deploy `AllWorkHRIS.Module.Hris.dll` only — no other modules in `./modules`
3. Start the application
4. Authenticate and navigate to the Employee List page
5. Hire a new employee — `PayrollContextId` left null
6. Verify the hire succeeds — Person, Employment, Assignment, Compensation, and EmployeeEvent records created
7. Verify `HireEventPayload` is published — no exception raised despite zero subscribers
8. Verify the employee appears in the Employee List grid

All 8 steps must pass before Phase 2 is considered complete.

---

## Consequences

**Positive:**
- Any module can be sold, licensed, and deployed independently — HRIS without Payroll, Payroll without T&A, Reporting without Benefits
- Adding a module to an existing deployment is a drop-DLL + apply-schema operation with no changes to existing module code
- Removing a module is a remove-DLL operation — no other module fails
- The in-process event bus is the sole integration point between modules — a clean, testable seam
- Future message broker adoption (RabbitMQ, Azure Service Bus) requires only replacing `InProcessEventBus` with a broker-backed implementation — `IEventPublisher` contract unchanged

**Constraints to manage:**
- All new inter-module event payload types must be added to `AllWorkHRIS.Core/Events/` — never to a module assembly
- New command fields that are module-specific must always be nullable — no required fields that reference another module's concepts
- Schema files must be reviewed at creation time to ensure no cross-module table references exist
- The `InProcessEventBus` handlers list must be thread-safe — `ConcurrentDictionary` is used for this reason

**Future consideration:**
- As the platform scales, the `InProcessEventBus` can be replaced with a persistent event store (outbox pattern) to support exactly-once delivery guarantees and event replay — without changing the `IEventPublisher` interface or any module code

---

## Amendments to existing SPECs

**SPEC/HRIS_Core_Module.md** — amended by companion patch:
- `PayrollContextId` on `HireEmployeeCommand` changed from `required Guid` to `Guid?`
- Event payloads moved to `AllWorkHRIS.Core/Events/`
- `IEventPublisher` description updated to reference `InProcessEventBus` with zero-subscriber no-op behaviour
- `EmployeeEventPublisher` registration replaced with `InProcessEventBus` singleton in `HrisModule.Register`

**SPEC/Payroll_Core_Module.md** — amended by companion patch:
- `IPayrollEventSubscriber` handlers registered via `InProcessEventBus` in `PayrollModule.Register`
- Payroll module no longer referenced from HRIS in any form

**docs/build/Build_Sequence_Plan.md** — amended by companion patch:
- Phase 0 applies HRIS schema only
- Phase 2 gate includes formal HRIS Standalone Test
- Payroll schema applied at start of Phase 4 only

---

## Alternatives Considered

**Allow module-to-module references with optional loading**
Modules reference each other but use null checks and feature flags to handle absent modules. Rejected — compile-time dependencies between modules mean all modules must be present for any to compile; deployment independence is impossible.

**Shared Events assembly (AllWorkHRIS.Events) separate from AllWorkHRIS.Core**
Event payloads in their own assembly rather than in Core. Rejected — adds a third assembly every module must reference without meaningful benefit over putting events in Core; Core is already the universal shared dependency.

**Message broker from day one**
Replace the in-process event bus with RabbitMQ or Azure Service Bus immediately. Rejected — adds infrastructure dependencies that conflict with on-premises portability; the in-process bus is sufficient at v1 scale and can be replaced later without touching module code.
