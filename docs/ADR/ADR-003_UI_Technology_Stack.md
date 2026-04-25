# ADR-003 — UI Technology Stack: Blazor Server

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.2 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-003_UI_Technology_Stack.md` |
| **Date** | April 2026 |
| **Related Documents** | PRD-0100_Architecture_Principles, ADR-004_Data_Access_Strategy, ADR-007_Module_Composition_DI_Lifetime, ADR-008_API_Surface_Architecture, docs/architecture/processing/Async_Job_Execution_Model.md |

---

## Context

The platform requires a web-based UI for HR administrators, payroll operators, managers, and employees. The UI layer must support complex data-entry workflows, approval processes, real-time job status visibility, and self-service capabilities.

Several factors shaped the technology evaluation:

- The platform is built on .NET Core throughout — a UI technology that shares the same language and type system reduces the surface area for serialisation errors, model divergence, and context switching
- The development team has deep C# expertise and limited JavaScript experience — a JavaScript-heavy frontend framework would introduce a sustained productivity and maintenance burden
- The initial deployment target is a single client with approximately 250 employees, with growth to PEO-scale deployments of low thousands of concurrent users
- The platform's domain logic is complex — shared models between frontend and backend eliminate a class of bugs that arise from maintaining parallel representations of the same domain concepts
- The Async Job Execution Model requires real-time job status feedback to operators — the UI must support live progress updates without requiring polling infrastructure separate from the application

Blazor Server was evaluated as the primary candidate. Blazor WebAssembly, ASP.NET MVC with a JavaScript SPA, and pure ASP.NET MVC were also considered.

---

## Decision

**The platform UI shall be implemented using Blazor Server on .NET Core.**

Blazor Server renders components on the server and communicates UI updates to the browser over a persistent SignalR connection. The application logic, domain model, and data access all run on the server in C#. The browser receives and applies UI diffs.

### Key Rationale

**End-to-end C#.** The entire stack — domain model, calculation engine, data access, UI components — is written in C#. Shared types, shared validation logic, and shared domain models eliminate serialisation boundaries and model drift between frontend and backend. This is a sustained productivity advantage for a small team building a complex domain.

**Scale profile match.** The target concurrent user count — a few hundred at launch, low thousands at PEO scale for a single instance — is well within Blazor Server's comfortable operating range without requiring a managed SignalR backplane or special infrastructure. The SignalR scaling concern that applies at tens of thousands of concurrent users is not material at the platform's intended deployment scale.

**Real-time job status.** The persistent SignalR connection that Blazor Server maintains is directly useful for the Async Job Execution Model — job status events can be pushed to the operator's UI without polling, using the same connection infrastructure that the UI framework already requires.

**Proof of concept validated.** A Blazor Server proof of concept has been built and validated. The component model, routing, and server-side rendering behaviour are confirmed as appropriate for the platform's UI requirements.

**MEF + Autofac composition compatibility.** Blazor Server integrates cleanly with .NET Core's dependency injection system, which is the foundation for the MEF + Autofac module composition model. UI components can consume module services through the same DI container that governs the domain layer.

---

## Consequences

**Positive:**
- Single language and type system throughout the stack
- Shared domain models between UI and business logic layers
- Real-time UI updates via existing SignalR infrastructure
- No JavaScript build toolchain required
- Reduced context switching and maintenance burden for C#-focused development

**Constraints to manage:**
- Each connected user maintains a server-side circuit consuming memory — circuit state must be kept lean, particularly for list and grid components operating over large data sets
- Blazor Server requires sticky sessions when deployed behind a load balancer — infrastructure must be configured accordingly for multi-instance deployments
- Long-running operations (payroll runs, batch imports) must not execute synchronously in the UI request cycle — this is enforced by the Async Job Execution Model and is a firm architectural requirement regardless of UI framework choice

**Future consideration:**
- If the platform ever targets significantly higher concurrent user counts (tens of thousands), migration to Blazor WebAssembly or a hybrid render mode should be evaluated. The .NET Core backend and C# domain model remain unchanged in that scenario — only the rendering layer changes. The modularity of the architecture means this migration path is available without a full rewrite.

---

## Alternatives Considered

**Blazor WebAssembly**
Eliminates server-side circuit state — each user's component state runs in the browser. Removes the SignalR scaling concern. Rejected because: initial load time is higher; browser memory constraints apply; server-side rendering is lost; all data access requires explicit API calls rather than direct service invocation, adding API surface area at a stage where the backend architecture is still being established. Remains a viable future migration path.

**ASP.NET MVC + React / Angular / Vue**
Most scalable option — stateless server, full SPA on the client. Rejected because: requires sustained JavaScript expertise the team does not have; introduces a serialisation boundary between C# domain model and JavaScript UI model that must be maintained; adds a separate build toolchain and dependency ecosystem; does not serve the end-to-end C# goal that is a core architectural value of this platform.

**ASP.NET MVC (Razor Pages / Views only)**
Server-rendered, no persistent connection. Rejected because: lacks real-time update capability needed for job status feedback; page-reload model is a poor fit for the complex multi-step workflows the platform requires.

**Blazor United / .NET 8 Auto render mode**
Per-component choice of server or WebAssembly rendering. Rejected for v1 because: adds complexity without material benefit at the current scale; the component boundary decisions required add design overhead; can be evaluated in a future version if the hybrid approach becomes warranted.

## Amendment — ADR-008

ASP.NET Core MVC is explicitly not used in this platform. ADR-008 documents this decision and the adoption of Minimal API for the HTTP endpoint surface. The coexistence risks between MVC and Blazor Server identified in the stack review are eliminated by this decision.
