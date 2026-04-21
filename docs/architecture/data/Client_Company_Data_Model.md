# Client_Company_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Commercial / Governance Domain |
| **Location** | docs/architecture/data/Client_Company_Data_Model.md |
| **Domain** | Client Company / Tenant Structure / Reporting Segmentation |
| **Related Documents** | Platform_Composition_and_Extensibility_Model.md, Legal_Entity_Data_Model.md, Organizational_Structure_Model.md, Employment_and_Person_Identity_Model.md |

---

# Purpose

This document defines the core data structure for **Client Company** as a first-class grouping and administrative construct within the platform.

Client Company represents the business/customer relationship layer that sits between Tenant and Legal Entity.

It exists to support:

- reporting aggregation
- billing segmentation
- payroll grouping
- governance delegation
- administrative scoping
- PEO customer structure
- multi-entity client organization

Client Company is not a statutory employer boundary.

That role belongs to Legal Entity.

---

# Core Structural Role

```text
Tenant
    ↓
Client Company
    ↓
Legal Entity
    ↓
Employment
```

Client Company is the structural layer that groups one or more Legal Entities into a coherent business relationship within a tenant.

It is the natural level for:

- customer identity
- client-facing administration
- commercial segmentation
- service scoping
- consolidated client reporting

---

# 1. Client Company Definition

A **Client Company** represents a distinct business relationship or employer grouping operating within a Tenant.

A Client Company may represent:

- a direct employer customer
- a PEO-serviced employer
- a regional operating company
- a consolidated administrative grouping for multiple Legal Entities
- an internal managed business unit in special platform deployments

A Client Company shall be modeled as distinct from:

- Tenant
- Legal Entity
- Department
- Cost Center
- Business Unit
- Location

---

# 2. Client Company Primary Attributes

| Field Name | Description |
|---|---|
| Client_Company_ID | Unique identifier |
| Tenant_ID | Parent Tenant reference |
| Client_Company_Code | Business or system code |
| Client_Company_Name | Primary display or business name |
| Client_Company_Legal_Name | Optional consolidated legal/business name |
| Client_Company_Type | Direct Employer, PEO Client, Internal Managed Group, Other |
| Parent_Client_Company_ID | Optional hierarchical parent for grouped clients |
| Client_Status | Pending, Active, Suspended, Inactive, Closed |
| Effective_Start_Date | Date client becomes active in the platform |
| Effective_End_Date | Date client ceases active use in the platform |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Client Company Functional Attributes

| Field Name | Description |
|---|---|
| Billing_Profile_ID | Billing and commercial configuration reference |
| Reporting_Profile_ID | Reporting aggregation configuration reference |
| Default_Currency_Code | Default commercial/reporting currency |
| Default_Language_Code | Default language context |
| Service_Model_Type | Direct, PEO, Managed Service, Hybrid |
| Payroll_Grouping_Mode | Defines client-level payroll segmentation behavior |
| Benefits_Grouping_Mode | Defines client-level benefits grouping behavior |
| Self_Service_Enabled_Flag | Indicates client participation in self-service |
| Consolidated_Reporting_Flag | Indicates whether client-level reporting rollups are enabled |
| Notes | Administrative notes |

---

# 4. Client Company Structural Responsibilities

Client Company is responsible for grouping and organizing business relationships within a tenant.

Client Company supports:

- grouping one or more Legal Entities
- payroll and reporting aggregation
- governance delegation boundaries
- client-level administrative segmentation
- billing segmentation
- operational scoping

Client Company shall not define:

- employer-of-record identity
- statutory jurisdiction
- direct tax responsibility
- remittance authority

Those responsibilities remain with Legal Entity and its registrations.

---

# 5. Relationship to Tenant

```text
Tenant
    └── Client Company (1..n)
```

Constraints:

- Each Client Company must belong to exactly one Tenant.
- A Tenant may contain one or more Client Companies.
- A Client Company may not span multiple Tenants.
- Tenant remains the primary security and isolation boundary.

Client Company exists within the Tenant boundary and does not replace it.

---

# 6. Relationship to Legal Entity

```text
Client Company
    └── Legal Entity (1..n)
```

Constraints:

- Each Legal Entity must reference exactly one Client Company.
- A Client Company may group one or more Legal Entities.
- A Client Company may exist before any Legal Entity is created.
- Legal Entity remains the employer-of-record and statutory boundary.

This relationship supports:

- multi-entity employer structures
- regional client operations
- PEO customer segmentation
- consolidated reporting

---

# 7. Relationship to Employment

Client Company does not directly own Employment records.

Employment attaches to Legal Entity.

However, Client Company may be used as a reporting and segmentation layer for Employment analytics and administration.

Typical reporting patterns include:

```text
Client Company
    ↓
Legal Entity
    ↓
Employment
```

This supports client-level visibility without weakening the employer-of-record boundary.

---

# 8. Relationship to Organizational Structure

Client Company may be represented in organizational hierarchy views where useful for reporting, navigation, or governance.

However, Client Company is not required to be modeled as an Org Unit unless the broader organizational structure framework explicitly supports such a pattern.

Client Company retains an independent business and commercial meaning even when reflected in hierarchy.

---

# 9. Client Company Status Model

Suggested Client_Status values:

| Status | Meaning |
|---|---|
| Pending | Created but not yet operational |
| Active | Authorized for active operational use |
| Suspended | Operationally restricted |
| Inactive | Retained historically, not used operationally |
| Closed | Relationship ended; retained for audit and history |

Status transitions shall be governed and auditable.

No Closed or Inactive Client Company may receive new Legal Entities or commercial activity without explicit reactivation.

---

# 10. Effective Dating and Historical Preservation

Client Company shall support effective-dated lifecycle management.

Changes that may require effective dating include:

- name changes
- service model changes
- billing profile changes
- reporting profile changes
- status changes
- parent-child hierarchy changes

Historical values must be preserved.

Silent overwrite is not permitted for commercially or operationally significant attributes.

---

# 11. PEO and Multi-Entity Support

The model shall support the following patterns:

## 11.1 Direct Employer Pattern

```text
Tenant
    └── Client Company
            └── Legal Entity
```

A direct employer may use a single Client Company with one or more Legal Entities.

## 11.2 Multi-Entity Employer Pattern

```text
Tenant
    └── Client Company
            ├── Legal Entity A
            ├── Legal Entity B
            └── Legal Entity C
```

A single client relationship may encompass multiple Legal Entities.

## 11.3 PEO Pattern

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

This pattern supports client-specific segmentation inside a shared PEO tenant.

---

# 12. Reporting and Billing Segmentation

Client Company is the preferred structural level for:

- billing rollups
- service invoicing
- consolidated workforce reporting
- client-level payroll summaries
- operational dashboards
- delegated administrative views

Legal Entity reporting remains necessary for statutory and tax purposes.

Client Company reporting supports business and service management purposes.

---

# 13. Validation Rules

Examples of validation rules:

- Tenant_ID is required
- Client_Company_Name is required
- Effective_Start_Date is required
- Closed Client Companies may not receive new Legal Entities
- Suspended Client Companies may not initiate new payroll grouping activity without override authorization
- Parent_Client_Company_ID may not create cycles in client hierarchy

These validations may be enforced through validation frameworks and approval workflows.

---

# 14. Audit and Traceability Requirements

The system shall preserve:

- Client Company creation history
- attribute change history
- hierarchy change history
- status transition history
- Legal Entity linkage history
- billing/reporting profile assignment history

This supports:

- customer relationship reconstruction
- billing auditability
- operational change review
- delegated administration traceability

---

# 15. Relationship to Other Models

This model integrates with:

- Platform_Composition_and_Extensibility_Model
- Legal_Entity_Data_Model
- Organizational_Structure_Model
- Employment_and_Person_Identity_Model
- Jurisdiction_and_Compliance_Rules_Model

---

# 16. Summary

This model establishes Client Company as a first-class business and administrative construct.

Key principles:

- Client Company is distinct from Tenant and Legal Entity
- Client Company groups one or more Legal Entities
- Client Company supports reporting, billing, governance, and segmentation
- Client Company is not the employer-of-record boundary
- Employment attaches to Legal Entity, not Client Company
- The model supports direct employer, multi-entity, and PEO operating patterns
