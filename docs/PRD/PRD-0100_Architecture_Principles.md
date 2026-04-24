# PRD-100 — Architecture Principles

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Architecture Principles |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0100_Architecture_Principles.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §2, §3 |
| **Related Documents** | PRD-0000_Core_Vision, ADR-001_Event_Driven_Architecture, ADR-002_Deterministic_Replayability |

## Purpose

Defines the non-negotiable architectural principles that govern all platform design decisions. All modules and architecture models must comply with these principles. Deviations require an ADR.

---

## 1. Core Architectural Principles

### Modular Architecture
**REQ-PLT-020**
All functional capabilities shall be modular. Customers may purchase any subset of modules. No module shall create a hard runtime dependency on another module's internal implementation.

### Plug-and-Play Composition
**REQ-PLT-021**
Modules shall be independently deployable and loosely coupled. A module that is not deployed shall not prevent other modules from operating.

### Event-Driven Processing
**REQ-PLT-022**
All meaningful state changes shall be represented as events. Events are the integration contract between modules. Modules publish events; downstream modules subscribe and act. No module shall orchestrate another module's internal behaviour.

### Deterministic Replayability
**REQ-PLT-023**
Historical payroll results shall be reproducible using historical inputs and rules. The system must be able to answer: *given this exact context at that historical moment, what was the result and why?* See ADR-002_Deterministic_Replayability.

### Effective-Dated Data
**REQ-PLT-024**
All payroll-relevant and HR-relevant data must support effective start and end dates. Point-in-time resolution shall be deterministic.

**REQ-PLT-025**
Silent overwrites of historical records are not permitted under any circumstance.

### Approval Workflow Governance
**REQ-PLT-026**
Changes to configuration, employment records, and payroll must follow configurable approval workflows before becoming effective.

**REQ-PLT-027**
Self-service actions shall initiate workflow events rather than writing directly to canonical records.

### Post-Calculation Validation
**REQ-PLT-028**
All payroll results shall pass through a validation phase that is explicitly separate from the calculation phase.

**REQ-PLT-029**
Posting shall not occur without completed validation. Validation authorises results for durable mutation.

### Audit and Historical Preservation
**REQ-PLT-030**
All record changes shall be preserved historically. Corrections shall generate compensating records rather than overwriting history.

**REQ-PLT-031**
Audit trails must identify source, timestamp, and responsible actor for every mutation.

## 2. Module Catalogue

Core modules identified for the platform:

| Module | Category |
|---|---|
| HRIS | v1 — People & Employment |
| Payroll | v1 — Compensation Processing |
| Benefits Administration (minimum) | v1 — Deduction elections; manual or externally sourced |
| Time & Attendance (minimum) | v1 — Worked time capture and payroll handoff |
| Reporting (minimum) | v1 — Operational reports |
| Benefits Administration (advanced) | Future — Plan design, carrier integration, open enrollment, COBRA, ACA |
| Time & Attendance (advanced) | Future — Scheduling optimisation, workforce analytics, biometric capture, union rules |
| Recruiting & Applicant Tracking | Future |
| Performance Management | Future |
| Learning & Development | Future |
| Workforce Analytics | Future |
| Organization Structure (advanced) | Future |
| Employee Self-Service (advanced) | Future |
| Reporting (advanced) | Future |

## 3. Compliance with Principles

**REQ-PLT-032**
All architecture models must reference the principles they implement.

**REQ-PLT-033**
An ADR must be filed whenever a principle is constrained, adapted, or deliberately traded off for a specific design decision.

---

## 4. Scope Boundaries

### In Scope — v1

**REQ-PLT-034**
All eight architectural principles defined in §1 are non-negotiable and apply to all v1 modules without exception.

**REQ-PLT-035**
All architecture models produced for v1 shall reference the principles they implement and shall be reviewed against this document before approval.

### Out of Scope — v1

**REQ-PLT-036**
Multi-country architectural extensions — localisation frameworks, country-specific rule engines, non-U.S. jurisdiction hierarchies — are out of scope for v1. The principles defined here must not preclude their future addition.

**REQ-PLT-037**
Real-time streaming event architectures (e.g. Apache Kafka, event sourcing at infrastructure level) are not mandated by v1. The event-driven principle (REQ-PLT-022) governs module integration contracts, not the underlying messaging infrastructure choice.

---

## 5. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-PLT-020 | Removing module B from a deployment does not cause module A to fail to start, fail to process, or produce errors referencing module B. |
| REQ-PLT-021 | Module A can be deployed, started, and operated without module B being present in the environment. |
| REQ-PLT-022 | No module contains a direct synchronous call to another module's internal service. All cross-module communication is via events. Verified by architecture review and dependency scan. |
| REQ-PLT-023 | A payroll run executed against a historical period using archived inputs and rule versions produces results identical to the original run. Verified by replay test suite. |
| REQ-PLT-024 | A point-in-time query against any payroll or HR record for any historical date returns the correct state as of that date without ambiguity. |
| REQ-PLT-025 | No update operation on any payroll or HR record replaces a prior value without preserving the prior value in an auditable history. Verified by mutation test suite. |
| REQ-PLT-026 | No configuration change, employment record change, or payroll action reaches an effective state without passing through at least one approval workflow step. |
| REQ-PLT-027 | A self-service action (leave request, contact update, onboarding task) does not directly modify the canonical record. It produces a workflow event that, upon approval, modifies the record. |
| REQ-PLT-028 | The calculation engine and the validation engine are independently deployable and independently testable components. |
| REQ-PLT-029 | A payroll result that fails validation cannot be found in the posted results table. No posting occurs for a result with an unresolved Hard Stop exception. |
| REQ-PLT-030 | A correction to a posted payroll record produces a compensating record. The original record remains unchanged and queryable. |
| REQ-PLT-031 | Every mutation to a financial or HR record has a corresponding audit log entry containing: actor, timestamp, before value, after value, and source action. |
| REQ-PLT-032 | Every architecture model document contains a section referencing which principles from this document it implements. |
| REQ-PLT-033 | Every deviation from a principle in this document has a corresponding ADR in `docs/ADR/`. |

---

## 6. Non-Functional Requirements

The architectural principles in this document impose the following non-functional constraints on all platform components.

### Audit Log Performance

**REQ-PLT-040**
Audit log writes shall not increase the latency of the triggering operation by more than 10% under normal load conditions.

### Replay Performance

**REQ-PLT-041**
A full deterministic replay of a single payroll period for up to 25,000 employees shall complete within the standard payroll calculation SLA defined in `docs/NFR/HCM_NFR_Specification.md`.

### Event Delivery

**REQ-PLT-042**
Cross-module events shall be delivered to all subscribers within 5 minutes of the originating state change under normal operating conditions.

### Validation Phase Duration

**REQ-PLT-043**
The validation phase shall complete within 10% of the total payroll calculation time for the same employee population. Validation shall not be the bottleneck in payroll close.
