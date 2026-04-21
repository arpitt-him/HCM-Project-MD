# Platform Composition and Extensibility Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Architecture Team |
| **Domain** | Core Platform Architecture |
| **Proposed Location** | docs/architecture/core/Platform_Composition_and_Extensibility_Model.md |
| **Related Documents** | PRD-0000_Core_Vision.md, PRD-0100_Architecture_Principles.md, Employment_and_Person_Identity_Model.md, Organizational_Structure_Model.md, Integration_and_Data_Exchange_Model.md, Jurisdiction_and_Compliance_Rules_Model.md |

---

# 1. Purpose

This document defines how the platform is structurally composed and how extensibility is achieved across the system.

The model establishes:

- HRIS Core System as the canonical platform center
- Optional plug-in modules as domain extensions
- Client Company as a first-class grouping construct
- Legal Entity as the statutory compliance boundary
- Jurisdiction resolution anchored to Employer-of-Record entities
- Internal extension seams supporting jurisdictional and provider variability

The goal is to create a platform that supports:

- Direct employers
- Multi-entity employers
- Multi-country operations
- PEO operating environments
- Future jurisdiction expansion
- Modular feature deployment

without architectural redesign.

---

# 2. Platform Composition Model

The platform consists of a **Platform Core** and optional **plug-in modules**.

```text
Platform Core
└── HRIS Core System
    ├── Identity
    ├── Employment
    ├── Org Structure
    ├── Workflow
    ├── Documents
    ├── Leave
    ├── Self-Service
    └── Integration Surface

Optional Plug-In Modules
├── Payroll
├── Benefits Administration
├── Time & Attendance
├── Recruiting
├── Performance Management
├── Learning & Development
└── Workforce Analytics
```

The HRIS Core System provides canonical system-of-record capabilities.

Optional modules extend platform functionality through published integration contracts.

Modules are deployable independently.

---

# 3. HRIS Core System Responsibilities

The HRIS Core System owns canonical platform records.

These records represent stable enterprise identity and employment relationships.

## 3.1 Core Domains

The HRIS Core System includes:

- Identity
- Employment
- Org Structure
- Workflow
- Documents
- Leave
- Self-Service
- Integration Surface

These domains form the canonical platform backbone.

---

## 3.2 Canonical Ownership Rule

The HRIS Core System is the authoritative source of truth for:

- Person identity
- Employment relationships
- Organizational hierarchy
- Legal entity structure
- Workflow-governed changes

Plug-in modules may read canonical records.

They shall not assume ownership of canonical state.

---

## 3.3 Core Stability Principle

The HRIS Core System shall remain stable across platform evolution.

Jurisdiction-specific logic shall not be embedded directly into the canonical core unless universally applicable.

---

# 4. Plug-In Module Model

Plug-in modules provide optional domain capabilities.

They extend platform functionality without destabilizing the core.

## 4.1 Plug-In Definition

A plug-in module:

- is independently deployable
- consumes canonical platform data
- owns derived domain data
- executes domain-specific processing
- publishes outputs and events

Examples:

- Payroll
- Benefits
- Time & Attendance
- Recruiting

---

## 4.2 Plug-In Integration Boundary

Plug-ins integrate with the platform through:

- Event contracts
- Query interfaces
- Import contracts
- Output contracts

Plug-ins must not depend on internal implementation details of other modules.

---

# 5. Integration Surface Model

The Integration Surface defines the formal boundary between the HRIS Core System and plug-in modules.

## 5.1 Integration Components

The Integration Surface includes:

- Event publication contracts
- Controlled read interfaces
- Import pipelines
- Reference data interfaces
- Output channels

---

## 5.2 Event-Driven Principle

The platform uses event-driven propagation for state changes.

Modules respond to published events.

Query interfaces provide controlled read access.

Mutation rights remain governed.

---

# 6. Internal Extensibility Model

Extensibility is required both between modules and within modules.

This is critical for:

- jurisdiction variation
- provider integration
- regulatory changes
- formatting differences
- localization requirements

---

## 6.1 Extensibility Principle

Pluggability is an architectural property.

It does not require immediate deployment-level modularization.

Initial extensibility may be achieved using:

- class inheritance
- interfaces
- strategy patterns
- provider adapters
- configuration selection

The critical requirement is:

**clear separation between stable logic and replaceable logic.**

---

## 6.2 Typical Extension Areas

Typical extension seams include:

- jurisdiction rule packs
- tax calculation handlers
- leave logic handlers
- payment providers
- banking adapters
- reporting generators
- template engines
- remittance processors

---

# 7. Employer-of-Record and Jurisdiction Model

Jurisdictional responsibility originates from statutory nexus boundaries.

The platform must align with legal accountability structures.

---

## 7.1 Primary Statutory Boundary

**The Employer-of-Record Legal Entity shall be the primary statutory boundary for:**

- taxation
- remittance
- reporting
- payroll rule selection
- compliance enforcement

This reflects the regulatory question:

**"Who is the company of record?"**

---

## 7.2 Legal Entity as Nexus Anchor

Legal Entity represents:

- employer-of-record
- statutory filing responsibility
- regulatory accountability

Legal Entity shall not be treated merely as hierarchy metadata.

---

## 7.3 Jurisdiction Resolution Sequence

Jurisdiction resolution follows:

1. Legal Entity
2. Work Location
3. Employee Residence
4. Additional statutory rules

Country labels alone are insufficient.

---

## 7.4 Multi-Jurisdiction Support

The platform must support:

- multiple jurisdictions
- concurrent rule execution
- mixed country operations

within a single deployment.

---

# 8. Tenancy, Client Company, and Legal Entity Boundaries

The platform distinguishes structural layers explicitly.

## 8.1 Structural Hierarchy

```text
Platform Deployment
└── Tenant
    └── Client Company
        └── Legal Entity
            └── Employment
```

---

## 8.2 Tenant Boundary

Tenant defines:

- security boundary
- configuration boundary
- operational isolation

Tenant does not determine jurisdiction.

---

## 8.3 Client Company Boundary

Client Company is a **first-class structural entity**.

It represents the business relationship grouping within a tenant.

Client Company supports:

- reporting segmentation
- billing segmentation
- payroll segmentation
- administrative delegation
- governance grouping
- audit tracking

Client Company groups one or more Legal Entities.

---

## 8.4 Legal Entity Boundary

Legal Entity defines:

- employer-of-record identity
- statutory nexus
- taxation responsibility
- reporting authority

Legal Entity is the compliance anchor.

---

# 9. Supported Operating Models

The platform supports multiple real-world structures.

---

## 9.1 Direct Employer Model

Tenant represents a direct employer.

Multiple Legal Entities may exist within the tenant.

---

## 9.2 Multi-Entity Employer Model

A tenant contains:

- multiple legal entities
- multiple jurisdictions

under one corporate structure.

---

## 9.3 PEO Operating Model

Tenant represents a PEO.

Client Companies represent serviced employers.

Legal Entities represent employer-of-record structures.

---

## 9.4 Multi-Tenant Regional Model

Multiple tenants may operate within a shared deployment.

Regional group relationships may exist above tenant boundaries.

Tenant isolation remains intact.

---

# 10. Module Extensibility by Jurisdiction

Modules must support jurisdiction-driven variation.

## 10.1 Payroll Example

Payroll module structure:

```text
Payroll
├── Payroll Core
├── Jurisdiction Packs
├── Provider Connectors
├── Reporting Packs
├── Statement Templates
└── Remittance Engines
```

New jurisdictions are introduced through extensions.

Not new modules.

---

# 11. Architectural Constraints

## 11.1 Canonical Ownership Constraint

Canonical HRIS records remain authoritative.

---

## 11.2 No Hidden Ownership

Modules shall not silently assume control of external records.

---

## 11.3 Nexus-Based Resolution

Jurisdiction resolution must rely on nexus structures.

Not geography labels alone.

---

## 11.4 Graceful Degradation

Optional modules must not destabilize core behavior.

---

# 12. Acceptance Criteria

| Requirement | Acceptance |
|---|---|
| Platform composition defined | Core vs plug-in separation exists |
| HRIS Core ownership clear | Canonical ownership defined |
| Client Company first-class | Client-level grouping supported |
| Legal Entity statutory role defined | Employer-of-record anchor established |
| Multi-jurisdiction capability defined | Concurrent jurisdiction support described |
| PEO support defined | Client and entity segmentation supported |

---

# 13. Summary

This document establishes the structural truth of the platform:

- HRIS Core System is the canonical platform center.
- Client Company is a first-class grouping structure.
- Legal Entity is the statutory compliance anchor.
- Plug-in modules extend platform functionality.
- Jurisdiction resolution follows statutory nexus.
- Internal extensibility supports jurisdiction and provider variation.
- The platform supports PEO, multi-entity, and multinational models without redesign.
