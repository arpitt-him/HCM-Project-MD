# ADR-001 — Event-Driven Architecture

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.2 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-001_Event_Driven_Architecture.md` |
| **Date** | April 2026 |
| **Related Documents** | PRD-0100_Architecture_Principles, PRD-0900_Integration_Model, docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md, docs/architecture/core/Employee_Event_and_Status_Change_Model.md |

---

## Context

The HCM platform is designed as a set of independently deployable modules (Payroll, HRIS, Benefits, Time & Attendance, etc.) that must share data and react to each other's state changes without creating tight runtime dependencies.

Early design decisions identified several integration problems that needed to be resolved:

- Payroll must know when an employee is hired, transferred, compensated differently, or terminated — but Payroll should not need to poll HRIS or be directly called by HRIS internals.
- Benefits enrollment must react to hire and status change events — but should not require Benefits to be deployed alongside HRIS.
- External earnings (commissions, residuals) must enter the payroll processing pipeline from source systems that have no knowledge of payroll run timing.
- Configuration changes, corrections, and HR actions all need to propagate downstream in a controlled, auditable way.

A direct point-to-point call model between modules would create coupling that contradicts the platform's modularity requirement. A shared-database model would create schema coupling and prevent independent deployment.

---

## Decision

**All meaningful state changes within the HCM platform shall be represented as events.**

Events are the integration contract between modules. A module that owns a domain publishes events when significant state changes occur. Modules that need to react subscribe to those events and act within their own boundaries.

### Key Rules

**Publishers do not orchestrate consumers.** When HRIS publishes a `HIRE` event, it does not call Payroll, Benefits, or any other module. It publishes the event and its responsibility ends. Downstream modules are responsible for their own reactions.

**Consumers are autonomous.** Payroll reacts to `HIRE` by establishing a payroll profile. Benefits reacts by evaluating eligibility. Each does so independently, on its own schedule, within its own transaction boundary.

**Events are durable.** Events must be persisted and replayable. A module that is temporarily unavailable must be able to consume events it missed upon recovery without data loss.

**Events carry effective dates.** Every event includes the date on which the change becomes effective for each consuming domain. This allows downstream modules to apply the change on their own processing schedule — a compensation change effective 1st of the month should not affect a payroll period that closed before that date.

**Events are not commands.** An event records that something happened, not an instruction to another module. Consumers decide what to do with events based on their own rules.

### Canonical Event Attributes

All platform events shall carry at minimum:

| Attribute | Purpose |
|---|---|
| Event_ID | Unique identifier for deduplication and replay |
| Event_Type | Classification (HIRE, TERMINATION, COMPENSATION_CHANGE, etc.) |
| Event_Date | Date the event was recorded |
| Effective_Date | Date the change becomes effective for payroll |
| Source_Module | Module that published the event |
| Entity_Reference | Person_ID and/or Employment_ID |
| Event_Status | Workflow state (Draft → Approved → Effective) |
| Initiated_By | Actor responsible for initiating the event |
| Approved_By | Actor who approved the event (if workflow-governed) |

---

## Consequences

### Positive

- Modules can be deployed, upgraded, and scaled independently.
- A failure in Benefits does not block Payroll from processing.
- The event log provides a complete, auditable history of all meaningful state changes.
- New modules can be added by subscribing to existing events without modifying publishers.
- Replay of events supports system recovery, retroactive corrections, and testing.

### Negative / Tradeoffs

- Eventual consistency: downstream modules may briefly lag behind the event source. This must be accounted for in operational windows and payroll cutoff design.
- Event schema changes require coordinated versioning across all subscribers.
- Debugging distributed event flows requires strong observability tooling.
- Developers must think in terms of event reactions, not procedure calls — this is a steeper onboarding curve.

---

## Alternatives Considered

**Direct synchronous API calls between modules.** Rejected. Creates tight coupling, introduces cascading failures, and prevents independent deployment.

**Shared canonical database.** Rejected. Creates schema coupling, prevents independent module evolution, and violates the multi-tenant isolation model.

**Batch file exchange between modules.** Rejected as the primary pattern. Retained as a supplementary mechanism for bulk historical intake and external system integration only (see `Integration_and_Data_Exchange_Model`).

---

## Compliance

Architecture models and module designs must reference this ADR when defining cross-module data flows. Any cross-module integration that bypasses the event model requires a new ADR documenting the exception and its justification.
