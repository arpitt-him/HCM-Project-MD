# Tenant_Client_Company_Legal_Entity_and_Jurisdiction_Structural_Relationship_Map

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Governance Domain |
| **Location** | docs/architecture/core/Tenant_Client_Company_Legal_Entity_and_Jurisdiction_Structural_Relationship_Map.md |
| **Domain** | Core Platform Structure |
| **Related Documents** | Tenant_Data_Model.md, Client_Company_Data_Model.md, Legal_Entity_Data_Model.md, Jurisdiction_Registration_and_Profile_Data_Model.md, Platform_Composition_and_Extensibility_Model.md, Jurisdiction_and_Compliance_Rules_Model.md |

---

## Purpose

This document ties together four core structural models that define the administrative, statutory, and compliance backbone of the platform:

- Tenant
- Client Company
- Legal Entity
- Jurisdiction Registration and Jurisdiction Profile

These models are individually defined in separate data-model documents.

This document exists to make their combined structural meaning explicit.

It defines:

- the hierarchy between the four constructs
- which boundary each construct owns
- which responsibilities belong at each level
- which responsibilities do **not** belong at each level
- how employment and jurisdiction resolution traverse the structure

---

## 1. Structural Hierarchy Overview

The platform structure is:

```text
Platform Deployment
    ↓
Tenant
    ↓
Client Company
    ↓
Legal Entity
    ↓
Jurisdiction Registration
    ↓
Jurisdiction Profile
    ↓
Rule Resolution / Payroll / Compliance / Reporting
```

This hierarchy separates:

- operational isolation
- customer grouping
- employer-of-record identity
- compliance presence
- statutory rule context

Each layer exists for a different reason and must not be collapsed casually.

---

## 2. Boundary Ownership by Level

### 2.1 Tenant

Tenant is the primary:

- security boundary
- isolation boundary
- configuration boundary
- operational boundary
- billing/account boundary

Tenant is **not** the:

- employer-of-record boundary
- statutory nexus boundary
- payroll tax authority boundary

---

### 2.2 Client Company

Client Company is the primary:

- business/customer grouping boundary
- reporting aggregation boundary
- billing segmentation boundary
- client-level governance boundary

Client Company is **not** the:

- employer-of-record boundary
- statutory jurisdiction boundary
- remittance authority boundary

---

### 2.3 Legal Entity

Legal Entity is the primary:

- employer-of-record boundary
- statutory identity boundary
- payroll liability boundary
- reporting identity boundary
- compliance accountability boundary

Legal Entity is the point at which the platform can answer:

> Who is the company of record?

Legal Entity is **not** merely:

- a tenant
- a client grouping
- a department or cost center
- a geography label

---

### 2.4 Jurisdiction Registration

Jurisdiction Registration is the primary:

- operational compliance presence boundary
- authority registration boundary
- employer registration boundary
- local statutory footprint boundary

Jurisdiction Registration records how a Legal Entity is registered or recognized within a governed jurisdiction.

Jurisdiction Registration is **not** merely:

- a country label
- a work location
- a tax classification code

---

### 2.5 Jurisdiction Profile

Jurisdiction Profile is the primary:

- statutory rule context
- remittance context
- reporting context
- compliance calendar context
- rule-pack assignment context

Jurisdiction Profile determines how the platform resolves applicable rule logic for a given jurisdiction registration.

---

## 3. Parent–Child Relationship Map

### 3.1 Platform Deployment → Tenant

```text
Platform Deployment
    └── Tenant (1..n)
```

A platform deployment may contain one or more Tenants.

Each Tenant belongs to exactly one deployment context.

---

### 3.2 Tenant → Client Company

```text
Tenant
    └── Client Company (1..n)
```

A Tenant may contain one or more Client Companies.

Each Client Company belongs to exactly one Tenant.

A Client Company may not span multiple Tenants.

---

### 3.3 Client Company → Legal Entity

```text
Client Company
    └── Legal Entity (1..n)
```

A Client Company may group one or more Legal Entities.

Each Legal Entity belongs to exactly one Client Company.

A Client Company may exist before any Legal Entity exists.

---

### 3.4 Legal Entity → Jurisdiction Registration

```text
Legal Entity
    └── Jurisdiction Registration (1..n)
```

A Legal Entity may hold one or more Jurisdiction Registrations.

Each Jurisdiction Registration belongs to exactly one Legal Entity.

This supports:

- multi-state operation
- multi-authority registration
- foreign employer registration
- local statutory presence

---

### 3.5 Jurisdiction Registration → Jurisdiction Profile

```text
Jurisdiction Registration
    └── Jurisdiction Profile (1..n, effective-dated)
```

A Jurisdiction Registration may have one or more Jurisdiction Profiles across time.

Exactly one active Jurisdiction Profile should govern a given registration at a given effective date unless the downstream resolution model explicitly supports parallel profiles.

---

## 4. Employment Traversal Through the Structure

Employment does not attach at every level.

Employment attaches to Legal Entity.

The structural traversal is:

```text
Employment
    → Legal Entity
        → Client Company
            → Tenant
```

For compliance and rule resolution, the traversal continues:

```text
Employment
    → Legal Entity
        → Jurisdiction Registration
            → Jurisdiction Profile
                → Rule Resolution
```

This distinction is critical.

Employment reporting may aggregate upward to Client Company and Tenant.

But employer-of-record and jurisdiction logic resolve downward from Legal Entity into registration and profile context.

---

## 5. Why the Layers Must Remain Distinct

### 5.1 Tenant must remain separate from Client Company

Because one Tenant may contain:

- one direct employer
- many PEO clients
- multiple business relationships

If Tenant and Client Company are collapsed, customer segmentation and PEO structure become weak.

---

### 5.2 Client Company must remain separate from Legal Entity

Because one Client Company may contain:

- one Legal Entity
- many Legal Entities
- regional operating entities
- distinct employer-of-record structures

If Client Company and Legal Entity are collapsed, statutory accountability becomes ambiguous.

---

### 5.3 Legal Entity must remain separate from Jurisdiction Registration

Because one Legal Entity may register with:

- multiple states
- multiple provinces
- multiple local authorities
- multiple countries in exception cases

If Legal Entity and Jurisdiction Registration are collapsed, foreign-employer and multi-state registration patterns become hard to model.

---

### 5.4 Jurisdiction Registration must remain separate from Jurisdiction Profile

Because registration presence and rule context are related but not identical.

A registration states that the entity is recognized by an authority.

A profile states which operational statutory rules apply for a given effective period.

Separating these concepts supports:

- legislative change
- effective dating
- audit replay
- profile replacement without losing registration history

---

## 6. Supported Operating Patterns

### 6.1 Direct Employer Pattern

```text
Tenant
    └── Client Company
            └── Legal Entity
                    └── Jurisdiction Registration
                            └── Jurisdiction Profile
```

---

### 6.2 Multi-Entity Employer Pattern

```text
Tenant
    └── Client Company
            ├── Legal Entity A
            │       └── Jurisdiction Registration(s)
            ├── Legal Entity B
            │       └── Jurisdiction Registration(s)
            └── Legal Entity C
                    └── Jurisdiction Registration(s)
```

---

### 6.3 PEO Pattern

```text
Tenant (PEO)
    ├── Client Company A
    │       ├── Legal Entity A1
    │       └── Legal Entity A2
    ├── Client Company B
    │       └── Legal Entity B1
    └── Client Company C
            ├── Legal Entity C1
            └── Legal Entity C2
```

Each Legal Entity may hold its own registrations and profiles.

---

### 6.4 Foreign Employer Exception Pattern

```text
Tenant
    └── Client Company
            └── Legal Entity
                    ├── Jurisdiction Registration: Country A
                    ├── Jurisdiction Registration: Country B
                    └── Jurisdiction Registration: Country C
```

This supports the limited cases where one Legal Entity is permitted to register as an employer across multiple countries without forming separate subsidiaries.

---

## 7. Responsibility Matrix

| Layer | Primary Responsibility | Must Not Be Used As |
|---|---|---|
| Tenant | Isolation, security, configuration, billing account | Employer-of-record or tax nexus |
| Client Company | Business grouping, reporting aggregation, billing segmentation | Statutory employer identity |
| Legal Entity | Employer-of-record, statutory identity, liability anchor | Tenant substitute or geography label |
| Jurisdiction Registration | Authority registration and operational compliance footprint | Mere location tag |
| Jurisdiction Profile | Rule-resolution and compliance context | Generic country shorthand |

---

## 8. Core Structural Rules

The following rules shall govern the combined structure:

1. Tenant is the highest operational boundary inside a deployment.
2. Client Company exists within Tenant and may group one or more Legal Entities.
3. Legal Entity is the primary employer-of-record and statutory boundary.
4. Jurisdiction Registration records a Legal Entity’s compliance presence within a governed jurisdiction.
5. Jurisdiction Profile defines the rule context applied to a registration.
6. Employment must attach to Legal Entity, not to Client Company or Tenant.
7. Jurisdiction resolution must traverse through Legal Entity and Jurisdiction Registration, not through tenant-level geography settings.
8. Reporting may aggregate upward, but statutory accountability must remain anchored at Legal Entity and registration level.

---

## 9. Relationship to Other Models

This structural map integrates with:

- Tenant_Data_Model
- Client_Company_Data_Model
- Legal_Entity_Data_Model
- Jurisdiction_Registration_and_Profile_Data_Model
- Platform_Composition_and_Extensibility_Model
- Jurisdiction_and_Compliance_Rules_Model
- Rule_Pack_Model
- Employment_and_Person_Identity_Model

---

## 10. Summary

This document makes explicit the combined structural meaning of four critical platform constructs.

Key principles:

- Tenant is the isolation boundary
- Client Company is the business grouping boundary
- Legal Entity is the employer-of-record and statutory boundary
- Jurisdiction Registration is the compliance presence boundary
- Jurisdiction Profile is the rule-resolution boundary
- Employment attaches to Legal Entity
- Rule resolution traverses from Legal Entity into registration and profile context
- The layers must remain distinct to support PEO, multi-entity, multi-state, and limited foreign-employer scenarios
