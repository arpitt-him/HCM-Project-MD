# PRD-000 — Core Vision

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Platform Vision |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0000_Core_Vision.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` (monolithic — now split across PRD-000 through PRD-900) |
| **Related Documents** | PRD-0100_Architecture_Principles, PRD-0200_Core_Entity_Model, docs/index.md |

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

- Support multiple jurisdictions
- Allow modular deployment
- Scale from small employers to enterprise-level PEO operations
- Maintain deterministic replayability of payroll calculations
- Support configurable workflows and approval governance

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

The platform shall support:

- Multiple employers
- PEO-style client structures
- Shared infrastructure with isolated tenant data domains
- Modular deployment — customers may purchase any subset of modules

## 5. Data Entry Channels

Employee data entry must be possible through:

- Manual entry
- XML import
- API intake
- Batch file intake

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

The full document list with one-line summaries is in `docs/index.md`.

---

## 9. Reader's Guide

| If you are... | Start here |
|---|---|
| New to the project — need orientation | This document, then `docs/index.md` |
| Reviewing platform scope and requirements | `PRD-100` through `PRD-900` |
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
