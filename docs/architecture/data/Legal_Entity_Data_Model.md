# Legal_Entity_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Governance Domain |
| **Location** | docs/architecture/data/Legal_Entity_Data_Model.md |
| **Domain** | Legal Entity / Compliance / Organizational Structure |
| **Related Documents** | Organizational_Structure_Model.md, Employment_and_Person_Identity_Model.md, Jurisdiction_and_Compliance_Rules_Model.md, Jurisdiction_Registration_and_Profile_Data_Model.md, Platform_Composition_and_Extensibility_Model.md |

---

# Purpose

This document defines the core data structure for **Legal Entity** as a first-class organizational and compliance construct within the platform.

Legal Entity is not merely an org-structure node.

It is the primary anchor for:

- employer-of-record identity
- statutory compliance
- payroll jurisdiction resolution
- employer registration relationships
- remittance and reporting accountability

This model exists to ensure that Legal Entity can support:

- direct employer operations
- multi-entity organizations
- PEO environments
- multi-state payroll
- multi-country and foreign-employer registration scenarios

without requiring redesign of the core platform data structure.

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
    ↓
Jurisdiction Registration
    ↓
Jurisdiction Profile
```

Legal Entity is the key boundary between:

- organizational structure
- employment responsibility
- statutory accountability
- jurisdictional rule resolution

---

# 1. Legal Entity Definition

A **Legal Entity** represents a legally recognized organization capable of acting as an employer-of-record or otherwise carrying statutory compliance obligations.

A Legal Entity may:

- employ workers directly
- register with tax and labor authorities
- file statutory reports
- remit payroll-related obligations
- hold employer registration numbers
- operate in one or more jurisdictions through registrations

A Legal Entity shall be modeled as distinct from:

- Tenant
- Client Company
- Department
- Cost Center
- Location
- Business Unit

---

# 2. Legal Entity Primary Attributes

| Field Name | Description |
|---|---|
| Legal_Entity_ID | Unique identifier |
| Client_Company_ID | Parent Client Company reference |
| Org_Unit_ID | Optional link to Organizational Structure node where modeled as an org unit |
| Legal_Entity_Code | Business or system code |
| Legal_Entity_Name | Full registered legal name |
| Legal_Entity_Short_Name | Optional short display name |
| Legal_Entity_Type | Corporation, LLC, Partnership, Government Unit, Nonprofit, etc. |
| Country_of_Incorporation | Country of legal formation |
| State_or_Province_of_Incorporation | Optional sub-jurisdiction of formation |
| Registration_Number | Primary legal registration number |
| Tax_Identification_Number | Primary tax identification number |
| Employer_Status | Active, Inactive, Suspended, Dissolved, Pending |
| Effective_Start_Date | Date entity becomes active in the platform |
| Effective_End_Date | Date entity ceases active use in the platform |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Legal Entity Functional Attributes

Legal Entity may also require the following operational attributes:

| Field Name | Description |
|---|---|
| Base_Currency_Code | Default operating currency |
| Default_Language_Code | Default language context |
| Reporting_Calendar_ID | Default reporting calendar |
| Payroll_Enabled_Flag | Indicates payroll usage |
| Benefits_Enabled_Flag | Indicates benefits usage |
| Time_Enabled_Flag | Indicates time & attendance usage |
| Self_Service_Enabled_Flag | Indicates self-service participation |
| Employer_of_Record_Flag | Indicates entity may act as employer-of-record |
| PEO_Relationship_Type | Direct Employer, PEO Client, PEO Internal Entity, Other |
| Consolidation_Group_ID | Optional financial or reporting grouping |
| Notes | Administrative notes |

---

# 4. Legal Entity as Employer-of-Record

Legal Entity is the primary employer-of-record anchor.

Every Employment record must reference exactly one employer-of-record Legal Entity.

This reference determines the starting point for:

- statutory jurisdiction resolution
- payroll tax responsibility
- employer contribution liability
- remittance accountability
- employment compliance obligations
- reporting identity

A Client Company may group multiple Legal Entities.

A Tenant may contain multiple Client Companies.

Neither Client Company nor Tenant replaces Legal Entity as the employer-of-record boundary.

---

# 5. Relationship to Employment

```text
Legal Entity
    └── Employment (1..n)
```

Constraints:

- Each Employment must reference one active Legal Entity.
- A Legal Entity may support many Employment records.
- A rehire under a different Legal Entity creates a new Employment relationship under that entity.
- Historical Employment records must retain their original Legal Entity reference.

This supports:

- deterministic payroll replay
- employer liability reconstruction
- audit traceability
- multi-entity workforce management

---

# 6. Relationship to Client Company

```text
Client Company
    └── Legal Entity (1..n)
```

Client Company is a first-class grouping construct above Legal Entity.

Client Company supports:

- reporting aggregation
- billing segmentation
- payroll grouping
- governance delegation

But Client Company does not define statutory employer identity.

That responsibility remains with Legal Entity.

---

# 7. Relationship to Organizational Structure

Legal Entity may be represented as a top-level or intermediate node in the organizational structure.

Where the platform models Legal Entity as an Org Unit:

- Org_Unit_Type shall support Legal Entity
- org hierarchy relationships shall preserve legal accountability boundaries
- lower organizational units shall roll up to a governing Legal Entity where applicable

Organizational structure may support reporting and navigation, but Legal Entity retains its own independent compliance meaning.

---

# 8. Relationship to Jurisdiction Registration

```text
Legal Entity
    └── Jurisdiction Registration (1..n)
```

A Legal Entity may hold one or more Jurisdiction Registrations.

This supports:

- multi-state operations
- foreign employer registrations
- multiple tax authority relationships
- local labor authority registrations
- special-purpose authority registration

Each Jurisdiction Registration represents an operational compliance footprint for that Legal Entity within a governed jurisdiction.

---

# 9. Relationship to Jurisdiction Profile

```text
Legal Entity
    └── Jurisdiction Registration
            └── Jurisdiction Profile (effective-dated)
```

Legal Entity does not directly resolve rules from a country label.

Instead:

- Legal Entity establishes statutory identity
- Jurisdiction Registration establishes local compliance presence
- Jurisdiction Profile establishes rule-resolution context

This layered structure supports realistic employer compliance modeling.

---

# 10. Legal Entity Status Model

Suggested Employer_Status values:

| Status | Meaning |
|---|---|
| Pending | Created but not yet operational |
| Active | Authorized for active operational use |
| Suspended | Temporarily restricted from operational use |
| Inactive | Retained historically but not used operationally |
| Dissolved | Legally closed; retained for historical and audit purposes |

Status transitions shall be governed and auditable.

No dissolved or inactive Legal Entity may be used for new Employment creation unless explicitly reactivated through governance controls.

---

# 11. Effective Dating and Historical Preservation

Legal Entity shall support effective-dated lifecycle management.

Changes that may require effective dating include:

- name changes
- status changes
- registration changes
- EOR eligibility changes
- calendar or currency changes
- legal restructuring

Historical values must be preserved.

Silent overwrite is not permitted for compliance-relevant attributes.

---

# 12. PEO and Multi-Entity Support

The model shall support:

- one Tenant serving multiple Client Companies
- one Client Company serving multiple Legal Entities
- one Legal Entity serving many workers
- one PEO tenant managing multiple employer clients

Examples:

## 12.1 Direct Employer Pattern

```text
Tenant
    └── Client Company
            └── Legal Entity
```

## 12.2 Multi-Entity Employer Pattern

```text
Tenant
    └── Client Company
            ├── Legal Entity A
            ├── Legal Entity B
            └── Legal Entity C
```

## 12.3 PEO Pattern

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

---

# 13. Multi-Country and Foreign Employer Support

The model shall support the common case:

- separate local Legal Entities per country

and the exception case:

- one Legal Entity holding employer registrations in more than one country where law permits

This shall be supported without changing the Legal Entity structure itself.

The distinction is handled through Jurisdiction Registration, not by redefining Legal Entity.

---

# 14. Suggested Validation Rules

Examples of validation rules:

- Legal_Entity_Name is required
- Client_Company_ID is required
- Country_of_Incorporation is required
- Effective_Start_Date is required
- Employer_of_Record_Flag must be true before Employment records may attach
- Dissolved entities may not receive new Jurisdiction Registrations
- Suspended entities may not initiate payroll without explicit override authorization

These validations may be implemented through validation packs and approval workflows.

---

# 15. Audit and Traceability Requirements

The system shall preserve:

- Legal Entity creation history
- attribute changes over time
- status transition history
- employer-of-record eligibility history
- jurisdiction registration linkage history
- employment linkage history

This supports:

- statutory audit
- payroll replay
- dispute resolution
- organizational change reconstruction

---

# 16. Relationship to Other Models

This model integrates with:

- Organizational_Structure_Model
- Employment_and_Person_Identity_Model
- Jurisdiction_and_Compliance_Rules_Model
- Jurisdiction_Registration_and_Profile_Data_Model
- Platform_Composition_and_Extensibility_Model
- Rule_Pack_Model

---

# 17. Summary

This model establishes Legal Entity as a first-class operational and statutory construct.

Key principles:

- Legal Entity is the employer-of-record anchor
- Legal Entity is distinct from Tenant and Client Company
- Employment always attaches to Legal Entity
- Jurisdiction Registration attaches to Legal Entity
- Jurisdiction Profile resolves from registration, not geography alone
- Historical integrity and effective dating are mandatory
- The model supports direct employer, multi-entity, PEO, and limited foreign-employer scenarios
