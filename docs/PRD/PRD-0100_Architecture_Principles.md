# PRD-100 — Architecture Principles

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Architecture Principles |
| **Version** | v1.0 |
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
All functional capabilities shall be modular. Customers may purchase any subset of modules. No module shall create a hard runtime dependency on another module's internal implementation.

### Plug-and-Play Composition
Modules shall be independently deployable and loosely coupled. A module that is not deployed shall not prevent other modules from operating.

### Event-Driven Processing
All meaningful state changes shall be represented as events. Events are the integration contract between modules. Modules publish events; downstream modules subscribe and act. No module shall orchestrate another module's internal behavior.

### Deterministic Replayability
Historical payroll results shall be reproducible using historical inputs and rules. The system must be able to answer: *given this exact context at that historical moment, what was the result and why?* See ADR-002.

### Effective-Dated Data
All payroll-relevant and HR-relevant data must support effective start and end dates. Point-in-time resolution shall be deterministic. No silent overwrites of historical records are permitted.

### Approval Workflow Governance
Changes to configuration, employment records, and payroll must follow configurable approval workflows before becoming effective. Self-service actions initiate workflow events rather than writing directly to canonical records.

### Post-Calculation Validation
All payroll results shall pass through a validation phase that is explicitly separate from the calculation phase. Validation authorizes results for durable mutation. Posting shall not occur without completed validation.

### Audit and Historical Preservation
All record changes shall be preserved historically. Corrections do not overwrite history — they generate compensating records. Audit trails must identify source, timestamp, and responsible actor for every mutation.

## 2. Module Catalogue

Core modules identified for the platform:

| Module | Category |
|---|---|
| HRIS | Core — People & Employment |
| Payroll | Core — Compensation Processing |
| Benefits Administration | Future |
| Time & Attendance | Future |
| Recruiting & Applicant Tracking | Future |
| Onboarding | Future |
| Performance Management | Future |
| Learning & Development | Future |
| Workforce Analytics | Future |

## 3. Compliance with Principles

Architecture models must reference the principles they implement. ADRs must be filed when a principle is constrained, adapted, or deliberately traded off for a specific design decision.
