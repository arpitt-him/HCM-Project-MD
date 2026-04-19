# PRD-000 — Core Vision

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Platform Vision |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0000_Core_Vision.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` (monolithic — now split across PRD-000 through PRD-900) |
| **Related Documents** | PRD-0100_Architecture_Principles, PRD-0200_Core_Entity_Model, index.md |

## Purpose

This document serves two roles:

1. **Platform vision** — defines what the HCM platform is, what it must be capable of, and the initial scope of delivery.
2. **Documentation orientation** — explains how the documentation is structured, how document types relate to each other, and where a reader should start depending on their role or concern.

It is the intended entry point for anyone new to the project.

---

## 1. System Vision

Build a modular Human Capital Management (HCM) platform capable of supporting:

- Payroll
- Benefits Administration
- Recruiting
- Time & Attendance
- Performance Management
- Learning & Development
- Workforce Analytics

The platform shall:

**REQ-PLT-001**
The platform shall support multiple jurisdictions for payroll calculation and compliance reporting.

**REQ-PLT-002**
The platform shall allow modular deployment — customers may purchase and deploy any subset of modules independently.

**REQ-PLT-003**
The platform shall scale from small employers to enterprise-level PEO operations without architectural change.

**REQ-PLT-004**
The platform shall maintain deterministic replayability of payroll calculations. Given the same inputs, rules, and effective dates, the system must produce identical results.

**REQ-PLT-005**
The platform shall support configurable workflows and approval governance across all modules.

## 2. Initial Module Focus

Payroll (U.S.-based first implementation).

Payroll establishes core object models, jurisdiction handling, and accumulator logic early. HRIS is the second module in scope, providing the authoritative system of record for people, employment relationships, and HR lifecycle events that Payroll consumes.

## 3. Module Roadmap

### In Scope (v1)

| Module | Status |
|---|---|
| Payroll | Active — primary delivery |
| HRIS | Active — foundational record system |

### Planned (Future)

| Module | Notes |
|---|---|
| Benefits Administration | Depends on HRIS eligibility model |
| Time & Attendance | Produces worked time consumed by Payroll |
| Recruiting | Produces candidate-to-hire transitions for HRIS |
| Performance Management | Linked to HRIS employment records |
| Learning & Development | Linked to HRIS employment records |
| Workforce Analytics | Consumes data feeds from all modules |

## 4. Deployment Model

**REQ-PLT-006**
The platform shall support multiple employers within a single deployment.

**REQ-PLT-007**
The platform shall support PEO-style client structures with isolated tenant data domains on shared infrastructure.

**REQ-PLT-008**
Tenant data isolation shall be enforced at the data layer, not only at the application layer.

## 5. Data Entry Channels

Employee data entry must be possible through all of the following channels:

**REQ-PLT-009**
The platform shall support manual data entry via an HR administrator user interface.

**REQ-PLT-010**
The platform shall support XML file import for employee data.

**REQ-PLT-011**
The platform shall support API-based intake for employee data (synchronous, per-record).

**REQ-PLT-012**
The platform shall support batch file intake for employee data.

## 6. Future Expansion Considerations

Planned future areas beyond v1 scope:

- Multi-country payroll
- Benefits engines
- Reporting engines
- Workforce analytics
- Compliance rule engines

---

## 7. Module Relationships

The platform is event-driven. Modules do not call each other directly — they publish and subscribe to events. The data ownership and event flow at v1 is:

```
HRIS  ──publishes──▶  Employee Events  ──consumed by──▶  Payroll
                                        ──consumed by──▶  Benefits (future)
                                        ──consumed by──▶  Time & Attendance (future)

Recruiting (future)  ──publishes──▶  Candidate-to-Hire Events  ──consumed by──▶  HRIS

Time & Attendance (future)  ──publishes──▶  Worked Time Records  ──consumed by──▶  Payroll
```

**HRIS** is the upstream source of record for all people, employment, compensation, and lifecycle data. It owns Person and Employment records. It does not calculate pay.

**Payroll** consumes HRIS data but does not own it. It owns calculation results, accumulators, liabilities, and pay statements. It does not write back to HRIS records.

**Future modules** plug into this event fabric without requiring changes to existing module internals. This is the practical meaning of modular architecture as defined in `PRD-0100_Architecture_Principles.md` and `ADR-001_Event_Driven_Architecture.md`.

---

## 8. Documentation Structure

The repository is organised into the following document types. Each type has a distinct role:

| Type | Folder | Role |
|---|---|---|
| **PRD** | `docs/PRD/` | What the system must do and why. Functional scope and requirements. |
| **NFR** | `docs/NFR/` | How the system must behave operationally — performance, availability, security, integrity. |
| **ADR** | `docs/ADR/` | Why the architecture is the way it is. Significant decisions, context, and rejected alternatives. |
| **DATA** | `docs/DATA/` | Canonical entity definitions — attributes, status values, relationships, governance. |
| **SPEC** | `docs/SPEC/` | Detailed behavioural specifications for specific features or integration patterns. |
| **Architecture Models** | `docs/architecture/` | How the system implements the requirements. Entity structures, design principles, model relationships. |

### How they relate

```
PRD  ──defines requirements──▶  Architecture Models  ──implement──▶  DATA entities
 │                                      │
 └──informs──▶  ADR                     └──detail via──▶  SPEC
```

PRDs define *what* is needed. Architecture models define *how* it is built. ADRs explain *why* key design decisions were made. DATA and SPEC documents provide detail below the level of the PRD but above the level of implementation code.

The full document list with one-line summaries is in `index.md`.

---

## 9. Reader's Guide

| If you are... | Start here |
|---|---|
| New to the project — need orientation | This document, then `index.md` |
| Reviewing platform scope and requirements | `PRD-0100` through `PRD-0900` |
| Reviewing HRIS module requirements | `docs/PRD/HRIS_Module_PRD.md` |
| Reviewing non-functional requirements | `docs/NFR/HCM_NFR_Specification.md` |
| Understanding why the architecture is event-driven | `docs/ADR/ADR-001_Event_Driven_Architecture.md` |
| Understanding replayability requirements | `docs/ADR/ADR-002_Deterministic_Replayability.md` |
| Working on person or employment data models | `docs/DATA/Entity_Person.md`, `docs/DATA/Entity_Employee.md` |
| Working on payroll calculation | `docs/architecture/calculation-engine/` |
| Working on rules and tax | `docs/rules/` |
| Working on external earnings or commissions | `docs/SPEC/External_Earnings.md`, `docs/SPEC/Residual_Commissions.md` |
| Checking architecture coverage against PRD | `docs/architecture/PRD_to_Architecture_Coverage_Map.md` |
| Looking for a specific model | `docs/architecture/Architecture_Model_Inventory.md` |

---

## 10. Scope Boundaries

### In Scope — v1

**REQ-PLT-020**
The platform shall deliver Payroll and HRIS as the two v1 modules.

**REQ-PLT-021**
The platform shall support U.S.-based employment structures and U.S. tax jurisdictions in v1.

**REQ-PLT-022**
The platform shall support PEO-style multi-client, multi-employer operating environments in v1.

**REQ-PLT-023**
The platform shall support all four data entry channels defined in §5 in v1.

### Out of Scope — v1

**REQ-PLT-024**
Multi-country payroll structures are explicitly out of scope for v1. The platform architecture must not preclude future multi-country support, but no multi-country logic shall be implemented in v1.

**REQ-PLT-025**
Benefits Administration, Time & Attendance, Recruiting, Performance Management, Learning & Development, and Workforce Analytics modules are out of scope for v1.

**REQ-PLT-026**
Benefits plan configuration and enrollment processing are out of scope for v1, even though HRIS will publish the eligibility events that a future Benefits module will consume.

---

## 11. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-PLT-001 | The platform calculates correct payroll results for employees in at least two simultaneous U.S. jurisdictions without manual intervention. |
| REQ-PLT-002 | A deployment with only the Payroll module active does not require HRIS to be deployed. A deployment with only HRIS active does not require Payroll to be deployed. |
| REQ-PLT-003 | The platform processes a payroll run for 500 employees and a payroll run for 50,000 employees using the same codebase and configuration model without architectural change. |
| REQ-PLT-004 | Given identical inputs, rules, and effective dates, two independent payroll runs for the same period produce byte-for-byte identical results. |
| REQ-PLT-005 | At least three distinct workflow types (payroll approval, HR lifecycle event, leave request) are configurable by an administrator without code changes. |
| REQ-PLT-006 | A single deployment hosts two employers with no cross-employer data visibility between operators scoped to each employer. |
| REQ-PLT-007 | A PEO client's data cannot be accessed by operators scoped to a different client, verified by access control test. |
| REQ-PLT-008 | A direct database query on the tenant data store cannot return records belonging to a different tenant without explicit cross-tenant authorisation. |
| REQ-PLT-009 | An HR administrator can create a new employee record via the UI without requiring a file upload or API call. |
| REQ-PLT-010 | An XML file conforming to the documented schema is accepted and produces correct Employment records. |
| REQ-PLT-011 | An API call with a valid payload creates an Employment record and returns a 200-series response within the specified SLA. |
| REQ-PLT-012 | A batch file containing 10,000 employee records is fully processed and produces correct Employment records within the batch processing SLA. |

---

## 12. Non-Functional Requirements

NFRs for this platform are governed by `docs/NFR/HCM_NFR_Specification.md`. The following platform-level SLAs apply specifically to the capabilities defined in this document.

### Availability

**REQ-PLT-030**
The HRIS module shall achieve 99.9% uptime measured monthly, excluding approved maintenance windows.

**REQ-PLT-031**
The Payroll engine shall achieve 99.95% uptime during payroll processing weeks.

**REQ-PLT-032**
The payment processing subsystem shall achieve 99.99% uptime during active payment windows.

### Disaster Recovery

**REQ-PLT-033**
The platform shall achieve a Recovery Point Objective (RPO) of no more than 15 minutes — no more than 15 minutes of committed data shall be lost in a disaster scenario.

**REQ-PLT-034**
The platform shall achieve a Recovery Time Objective (RTO) of no more than 1 hour — the platform shall be restored to operational state within 1 hour of a declared disaster.

### Data Consistency

**REQ-PLT-035**
HRIS data changes shall be available to the Payroll module within 5 minutes of the change becoming effective.

**REQ-PLT-036**
Payroll results shall be available to GL, Tax, and Vendor downstream systems within 15 minutes of payroll posting.

### Scalability

**REQ-PLT-037**
The platform shall support 10–20% of the total workforce accessing the system concurrently during peak events (e.g., open enrollment, payroll self-service).

**REQ-PLT-038**
The platform shall support 100% of the payroll team accessing the system concurrently during payroll close.

**REQ-PLT-039**
The platform shall process more than 100,000 time entries per minute during peak batch processing.

**REQ-PLT-040**
The platform shall process more than 10,000 job changes per hour during high-volume HR events.

**REQ-PLT-041**
The platform shall process more than 5,000 payroll adjustments per minute during adjustment processing windows.
