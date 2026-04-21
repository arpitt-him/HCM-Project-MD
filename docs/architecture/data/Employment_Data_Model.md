# Employment_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Employment Domain |
| **Location** | docs/architecture/data/Employment_Data_Model.md |
| **Domain** | Employment / Worker Relationship / Employer-of-Record Attachment |
| **Related Documents** | Employment_and_Person_Identity_Model.md, Legal_Entity_Data_Model.md, Client_Company_Data_Model.md, Tenant_Data_Model.md, Employee_Assignment_Model.md, Compensation_and_Pay_Rate_Model.md, Jurisdiction_Registration_and_Profile_Data_Model.md, Tenant_Client_Company_Legal_Entity_and_Jurisdiction_Structural_Relationship_Map.md |

---

# Purpose

This document defines the core data structure for **Employment** as the operational relationship between a Person and an employer-of-record Legal Entity.

Employment is not the Person.

Employment is not the assignment.

Employment is not the payroll result.

Employment is the durable operational relationship that establishes:

- who employs the person
- under which Legal Entity they are employed
- when the employment began and ended
- what employment status applies
- which downstream payroll, compliance, and reporting contexts derive from that relationship

This model exists to support:

- rehire scenarios
- concurrent employments
- transfers between Legal Entities
- effective-dated employment history
- deterministic payroll and compliance replay
- multi-entity and PEO operating patterns

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
Assignment / Compensation / Payroll Context / Jurisdiction Resolution
```

Employment is the point at which a Person becomes operationally attached to an employer-of-record Legal Entity.

Downstream operational structures may refine Employment, but they do not replace it.

---

# 1. Employment Definition

An **Employment** represents a discrete employer relationship between a Person and a Legal Entity.

An Employment may represent:

- an active employee relationship
- a pending hire relationship
- a terminated historical relationship
- a rehire under a new employment record
- one of multiple concurrent employment relationships

An Employment shall be modeled as distinct from:

- Person
- Assignment
- Position
- Job
- Compensation record
- Payroll result
- Tenant
- Client Company
- Legal Entity

Employment is the operational worker relationship.

---

# 2. Employment Primary Attributes

| Field Name | Description |
|---|---|
| Employment_ID | Unique identifier |
| Person_ID | Parent Person reference |
| Legal_Entity_ID | Employer-of-record Legal Entity reference |
| Client_Company_ID | Derived or stored reference for reporting convenience where needed |
| Tenant_ID | Derived or stored reference for scoping convenience where needed |
| Employment_Number | Employer-facing or platform-facing employment identifier |
| Employment_Type | Employee, Contractor, Temporary, Intern, Seasonal, Other |
| Employment_Status | Pending, Active, On_Leave, Suspended, Terminated, Closed |
| Employment_Start_Date | Effective start of employment |
| Employment_End_Date | Effective end of employment where applicable |
| Original_Hire_Date | Original first hire date with this employer relationship where policy requires |
| Termination_Date | Date employment terminated where applicable |
| Rehire_Flag | Indicates employment is a rehire relationship |
| Prior_Employment_ID | Prior employment reference where this employment results from rehire |
| Primary_Flag | Indicates primary employment where multiple concurrent employments exist |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Employment Functional Attributes

| Field Name | Description |
|---|---|
| Worker_Category | Full-Time, Part-Time, Temporary, Seasonal, Contract, Other |
| FLSA_or_Local_Labor_Class | Labor classification relevant to jurisdiction |
| Payroll_Eligibility_Flag | Indicates payroll participation eligibility |
| Benefits_Eligibility_Flag | Indicates benefits eligibility |
| Time_Tracking_Required_Flag | Indicates whether time entry is required |
| Manager_Self_Service_Eligible_Flag | Indicates manager workflow applicability |
| Employee_Self_Service_Eligible_Flag | Indicates employee self-service applicability |
| Default_Work_Location_ID | Default operational work location |
| Default_Department_ID | Default department reference |
| Default_Position_ID | Default position reference where applicable |
| Default_Job_ID | Default job reference where applicable |
| Payroll_Context_ID | Payroll execution context reference where applicable |
| Notes | Administrative notes |

---

# 4. Employment as Person-to-Legal-Entity Relationship

Employment is the formal bridge between:

```text
Person
    ↓
Employment
    ↓
Legal Entity
```

This is the minimum structure required to answer:

- who is the worker
- who employs them
- when the employment relationship exists
- which employer-of-record carries responsibility

Client Company and Tenant may be derived from Legal Entity lineage, but they do not replace the Legal Entity attachment.

---

# 5. Relationship to Person

```text
Person
    └── Employment (1..n)
```

Constraints:

- A Person may have one or more Employment records over time.
- A Person may have multiple concurrent Employment records where allowed by platform policy.
- Employment records must remain historically preserved even after termination or closure.
- Rehire under a renewed relationship shall generally create a new Employment record rather than overwriting a prior one.

This supports:

- employment history
- concurrent employment
- rehire traceability
- audit reconstruction

---

# 6. Relationship to Legal Entity

```text
Legal Entity
    └── Employment (1..n)
```

Constraints:

- Each Employment must reference exactly one Legal Entity.
- Legal Entity is the employer-of-record anchor for that Employment.
- Transfer from one Legal Entity to another shall create a new Employment relationship unless a special legal continuity rule explicitly permits otherwise.
- Historical Employment records must retain the original Legal Entity reference.

This relationship determines the starting point for:

- jurisdiction resolution
- payroll liability
- employer compliance
- remittance identity
- reporting accountability

---

# 7. Relationship to Client Company and Tenant

Client Company and Tenant exist above Employment through Legal Entity lineage.

Typical hierarchy:

```text
Tenant
    ↓
Client Company
    ↓
Legal Entity
    ↓
Employment
```

Client_Company_ID and Tenant_ID may be materialized on Employment for reporting, filtering, or operational performance reasons, but the authoritative structural relationship remains through Legal Entity.

Employment shall not attach directly to Client Company or Tenant as its employer-of-record anchor.

---

# 8. Relationship to Assignment

Employment is not the same as Assignment.

Employment answers:

- who employs the person

Assignment answers:

- where and how the worker is operationally placed

Typical structure:

```text
Employment
    └── Assignment (1..n, effective-dated)
```

A single Employment may have many Assignments over time.

Assignments may change:

- department
- location
- job
- position
- manager
- reporting context

without changing the underlying Employment.

---

# 9. Relationship to Compensation

Compensation records attach to Employment.

```text
Employment
    └── Compensation Record (1..n, effective-dated)
```

A single Employment may have multiple compensation records over time and, where supported, multiple simultaneous compensation components.

Compensation changes do not replace the Employment relationship.

---

# 10. Relationship to Jurisdiction Resolution

Employment does not directly own jurisdiction.

Jurisdiction resolves through Legal Entity and downstream registration/profile context.

Typical traversal:

```text
Employment
    → Legal Entity
        → Jurisdiction Registration
            → Jurisdiction Profile
                → Rule Resolution
```

Employment may contribute refinement context such as:

- work location
- labor classification
- worker category
- payroll context

But Employment does not replace the primary statutory anchor established by Legal Entity.

---

# 11. Employment Status Model

Suggested Employment_Status values:

| Status | Meaning |
|---|---|
| Pending | Created but not yet effective |
| Active | Currently active employment |
| On_Leave | Employment remains active but worker is on leave |
| Suspended | Employment temporarily restricted |
| Terminated | Employment ended, retained for history |
| Closed | Employment fully closed and no longer operational |

Status transitions shall be governed and auditable.

No Terminated or Closed Employment may receive new operational assignments, payroll activity, or compensation changes without formal correction or reactivation logic.

---

# 12. Rehire and Prior Employment Handling

Rehire shall generally create a new Employment record.

This preserves:

- prior legal entity attachment
- prior compensation history
- prior payroll history
- prior jurisdiction context
- prior termination context

Suggested linkage:

```text
Prior_Employment_ID
```

This enables historical continuity without overwriting prior records.

Policies may also retain:

- Original_Hire_Date
- Service_Bridge_Flag
- Rehire_Eligibility_Status

where required by employer or statutory rules.

---

# 13. Concurrent Employment Support

The model shall support a Person having multiple simultaneous Employment records where legally and operationally valid.

Examples:

- separate part-time employments under different Legal Entities
- separate employments under the same Client Company
- secondary employment under a different business line
- PEO-managed concurrent worker relationships

Where concurrent Employment exists:

- each Employment must have its own Legal Entity anchor
- each Employment may have its own payroll context
- one Employment may be flagged as primary where required for operational purposes

---

# 14. Effective Dating and Historical Preservation

Employment shall support effective-dated lifecycle management.

Changes that may require effective dating include:

- start date changes
- status changes
- legal entity transfer
- payroll eligibility changes
- labor classification changes
- primary employment designation changes

Historical values must be preserved.

Silent overwrite is not permitted for compliance-relevant or payroll-relevant employment attributes.

---

# 15. Validation Rules

Examples of validation rules:

- Person_ID is required
- Legal_Entity_ID is required
- Employment_Start_Date is required
- Employment_Status is required
- Employment_End_Date may not be earlier than Employment_Start_Date
- Prior_Employment_ID may not reference the same Employment_ID
- Primary_Flag rules must be validated when concurrent employments exist
- Payroll_Eligibility_Flag may not be true where employer-of-record configuration disallows payroll
- Closed or Terminated Employment may not receive new active compensation without governed correction

These rules may be enforced through validation frameworks and approval workflows.

---

# 16. Audit and Traceability Requirements

The system shall preserve:

- Employment creation history
- status transition history
- legal entity linkage history
- rehire linkage history
- assignment linkage history
- compensation linkage history
- payroll context linkage history

This supports:

- audit reconstruction
- payroll replay
- compliance review
- dispute handling
- historical workforce reporting

---

# 17. Relationship to Other Models

This model integrates with:

- Employment_and_Person_Identity_Model
- Legal_Entity_Data_Model
- Client_Company_Data_Model
- Tenant_Data_Model
- Employee_Assignment_Model
- Compensation_and_Pay_Rate_Model
- Jurisdiction_Registration_and_Profile_Data_Model
- Tenant_Client_Company_Legal_Entity_and_Jurisdiction_Structural_Relationship_Map

---

# 18. Summary

This model establishes Employment as the operational worker relationship between Person and Legal Entity.

Key principles:

- Employment is distinct from Person, Assignment, and Compensation
- Employment attaches directly to Legal Entity
- Employment derives Client Company and Tenant context through Legal Entity lineage
- Rehire generally creates a new Employment record
- Concurrent employments are supported where valid
- Jurisdiction resolution traverses from Employment through Legal Entity into registration/profile context
- Historical integrity and effective dating are mandatory
