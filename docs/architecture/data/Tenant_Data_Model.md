# Tenant_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Tenancy / Governance Domain |
| **Location** | docs/architecture/data/Tenant_Data_Model.md |
| **Domain** | Tenant / Isolation / Operational Boundary |
| **Related Documents** | Platform_Composition_and_Extensibility_Model.md, Client_Company_Data_Model.md, Legal_Entity_Data_Model.md, Security_and_Access_Control_Model.md, Configuration_and_Metadata_Management_Model.md |

---

# Purpose

This document defines the core data structure for **Tenant** as the primary security, configuration, and operational isolation boundary within the platform.

Tenant is the top-level customer or operator boundary inside a shared platform deployment.

Tenant exists to support:

- data isolation
- security scoping
- configuration ownership
- operational separation
- billing separation
- environment-level governance
- module enablement and service activation

Tenant is not a statutory employer boundary.

That role belongs to Legal Entity.

Tenant is not a substitute for Client Company.

That role belongs to the client/grouping layer within the tenant.

---

# Core Structural Role

```text
Platform Deployment
    ↓
Tenant
    ↓
Client Company
    ↓
Legal Entity
    ↓
Employment
```

Tenant is the top-level organizational boundary inside the platform deployment.

It provides the framework within which:

- Client Companies are organized
- Legal Entities are administered
- module capabilities are enabled
- operators are scoped
- data access is isolated

---

# 1. Tenant Definition

A **Tenant** represents an isolated operating boundary within the platform.

A Tenant may represent:

- a direct employer customer
- a PEO operator
- a managed services customer
- an internal enterprise operating environment
- a regional platform participant inside a broader deployment

Tenant is the first-class boundary for:

- security
- access control
- configuration scope
- operational segmentation
- billing/account ownership
- data partitioning

Tenant shall be modeled as distinct from:

- Client Company
- Legal Entity
- Department
- Business Unit
- Environment
- Jurisdiction

---

# 2. Tenant Primary Attributes

| Field Name | Description |
|---|---|
| Tenant_ID | Unique identifier |
| Tenant_Code | Business or system code |
| Tenant_Name | Primary display name |
| Tenant_Legal_Name | Optional legal/commercial name |
| Tenant_Type | Direct Employer, PEO, Managed Service, Internal, Other |
| Tenant_Status | Pending, Active, Suspended, Inactive, Closed |
| Primary_Contact_ID | Primary business/administrative contact |
| Effective_Start_Date | Date tenant becomes active in platform |
| Effective_End_Date | Date tenant ceases active use |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Tenant Functional Attributes

| Field Name | Description |
|---|---|
| Billing_Account_ID | Billing/account ownership reference |
| Security_Profile_ID | Security and access model reference |
| Configuration_Profile_ID | Default configuration scope reference |
| Default_Currency_Code | Default commercial/reporting currency |
| Default_Language_Code | Default language context |
| Time_Zone_Code | Default time zone |
| Self_Service_Enabled_Flag | Indicates tenant-level self-service enablement |
| Payroll_Module_Enabled_Flag | Indicates payroll module enablement |
| Benefits_Module_Enabled_Flag | Indicates benefits module enablement |
| Time_Module_Enabled_Flag | Indicates time & attendance enablement |
| Recruiting_Module_Enabled_Flag | Indicates recruiting enablement |
| Reporting_Module_Enabled_Flag | Indicates analytics/reporting enablement |
| Data_Residency_Profile_ID | Optional data residency / hosting policy reference |
| Notes | Administrative notes |

---

# 4. Tenant Responsibilities

Tenant is responsible for:

- security isolation
- operator and role scoping
- module activation boundaries
- top-level configuration scope
- billing account ownership
- environment-level governance
- service-level reporting scope

Tenant shall not define:

- employer-of-record identity
- statutory jurisdiction
- tax nexus
- payroll remittance authority

Those responsibilities remain below the tenant layer.

---

# 5. Relationship to Platform Deployment

```text
Platform Deployment
    └── Tenant (1..n)
```

Constraints:

- A platform deployment may contain one or more Tenants.
- Each Tenant exists within exactly one platform deployment context.
- Tenants must remain isolated from one another unless explicit cross-tenant governance is supported.
- Cross-tenant visibility shall be exceptional, controlled, and auditable.

This model supports shared-platform SaaS while preserving isolation.

---

# 6. Relationship to Client Company

```text
Tenant
    └── Client Company (1..n)
```

Constraints:

- Each Client Company must belong to exactly one Tenant.
- A Tenant may contain one or more Client Companies.
- A Client Company may not span multiple Tenants.

Client Company provides business/customer grouping inside the Tenant boundary.

Tenant remains the primary isolation and security scope.

---

# 7. Relationship to Legal Entity

Tenant does not directly replace Legal Entity.

A Tenant may contain many Legal Entities indirectly through Client Companies.

Typical hierarchy:

```text
Tenant
    ↓
Client Company
    ↓
Legal Entity
```

In exceptional simplified deployments, a Tenant may contain one Client Company and one Legal Entity, but these constructs remain conceptually distinct.

---

# 8. Relationship to Security and Access Control

Tenant is the primary access-control scoping boundary.

Security responsibilities include:

- user-to-tenant assignment
- role scoping
- data visibility boundaries
- administrative delegation controls
- cross-tenant restriction enforcement

Tenant-level access does not automatically imply unrestricted access to all Client Companies or Legal Entities inside that tenant.

Further scoping may still apply.

---

# 9. Relationship to Configuration and Metadata

Tenant defines the primary configuration ownership boundary for:

- enabled modules
- feature availability
- workflow defaults
- reporting defaults
- localization defaults
- integration defaults
- security defaults

Configuration may be further refined at lower levels, but tenant remains the top-level owning scope within the deployment.

---

# 10. Tenant Status Model

Suggested Tenant_Status values:

| Status | Meaning |
|---|---|
| Pending | Created but not yet operational |
| Active | Authorized for active platform use |
| Suspended | Operationally restricted |
| Inactive | Retained historically but not used operationally |
| Closed | Relationship ended; retained for audit/history |

Status transitions shall be governed and auditable.

Closed or Inactive Tenants may not receive new Client Companies, Legal Entities, or active users without formal reactivation.

---

# 11. Effective Dating and Historical Preservation

Tenant shall support effective-dated lifecycle management.

Changes that may require effective dating include:

- name changes
- status changes
- module enablement changes
- billing/account changes
- security profile changes
- configuration profile changes
- data residency changes

Historical values must be preserved.

Silent overwrite is not permitted for materially significant operational attributes.

---

# 12. Supported Operating Patterns

The model shall support multiple tenant patterns.

## 12.1 Direct Employer Tenant

```text
Tenant
    └── Client Company
            └── Legal Entity
```

## 12.2 Multi-Client PEO Tenant

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

## 12.3 Regional Multi-Tenant Deployment

```text
Platform Deployment
    ├── Tenant A
    ├── Tenant B
    └── Tenant C
```

This supports one shared system serving multiple isolated participants.

---

# 13. Validation Rules

Examples of validation rules:

- Tenant_Name is required
- Effective_Start_Date is required
- Tenant_Status is required
- Closed Tenants may not receive new Client Companies
- Suspended Tenants may not initiate new payroll cycles without explicit override authorization
- Module enablement dependencies must be validated where required by platform policy

These validations may be enforced through validation frameworks and governance controls.

---

# 14. Audit and Traceability Requirements

The system shall preserve:

- Tenant creation history
- attribute change history
- status transition history
- module enablement history
- security profile assignment history
- configuration profile assignment history
- Client Company linkage history

This supports:

- tenant audit
- billing review
- platform governance
- access review
- operational reconstruction

---

# 15. Relationship to Other Models

This model integrates with:

- Platform_Composition_and_Extensibility_Model
- Client_Company_Data_Model
- Legal_Entity_Data_Model
- Security_and_Access_Control_Model
- Configuration_and_Metadata_Management_Model

---

# 16. Summary

This model establishes Tenant as the primary isolation and governance boundary inside the platform.

Key principles:

- Tenant is the top-level operating boundary inside a deployment
- Tenant is distinct from Client Company and Legal Entity
- Tenant owns security, configuration, and operational scope
- Tenant does not define employer-of-record identity or statutory nexus
- Client Companies exist inside Tenants
- Legal Entities exist beneath Client Companies
- The model supports direct employer, PEO, and multi-tenant regional operating patterns
