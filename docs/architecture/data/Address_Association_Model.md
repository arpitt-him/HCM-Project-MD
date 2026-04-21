# Address_Association_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Shared Reference & Identity Domain |
| **Location** | docs/architecture/data/Address_Association_Model.md |
| **Domain** | Address Association / Effective-Dated Ownership / Historical Address Use |
| **Related Documents** | Address_Data_Model.md, Person_Data_Model.md, Employment_Data_Model.md, Legal_Entity_Data_Model.md, Client_Company_Data_Model.md, Tenant_Data_Model.md, Organizational_Structure_Model.md, Jurisdiction_Registration_and_Profile_Data_Model.md |

---

# Purpose

This document defines the core data structure for **Address Association** as the effective-dated linkage between a governed owning object and an Address record.

Address itself is a reusable location reference.

Address Association defines:

- who the address belongs to
- how the address is used
- when the address is effective
- whether the address is primary for that use
- how historical address usage is preserved

This model exists to prevent address history from being handled as naive overwrite or document-style versioning.

---

# Core Structural Role

```text
Person / Employment / Legal Entity / Client Company / Tenant / Org Unit
    ↓
Address Association
    ↓
Address
```

Address Association is the historical and semantic ownership layer.

Address stores the reusable location structure.

Address Association stores:

- owner linkage
- address role
- effective dating
- primary designation
- owner-specific usage meaning

---

# 1. Address Association Definition

An **Address Association** represents the governed relationship between an owning object and an Address.

An Address Association may represent:

- a person's home address
- a person's mailing address
- an employment-specific correspondence address
- a legal entity's registered office
- a legal entity's principal place of business
- a client company's billing address
- a tenant's headquarters address
- an org unit's worksite address

Address Association shall be modeled as distinct from:

- Address
- Person
- Employment
- Legal Entity
- Client Company
- Tenant
- Org Unit

It is the relationship layer, not the address value itself.

---

# 2. Address Association Primary Attributes

| Field Name | Description |
|---|---|
| Address_Association_ID | Unique identifier |
| Owner_Object_Type | Person, Employment, Legal Entity, Client Company, Tenant, Org Unit, Other |
| Owner_Object_ID | Owning object reference |
| Address_ID | Referenced Address |
| Address_Role | Home, Mailing, Registered, Operational, Billing, Worksite, Service_of_Process, Other |
| Association_Status | Pending, Active, Superseded, Inactive, Historical, Restricted |
| Effective_Start_Date | Date association becomes effective |
| Effective_End_Date | Date association ceases to be effective |
| Primary_For_Role_Flag | Indicates primary address for this owner/role context |
| Source_Type | Manual Entry, Import, Integration, Workflow, Generated |
| Notes | Administrative notes |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Address Association Functional Attributes

| Field Name | Description |
|---|---|
| Jurisdiction_Relevance_Flag | Indicates address may affect compliance or tax context |
| Payroll_Relevance_Flag | Indicates address may affect payroll handling |
| Correspondence_Eligible_Flag | Indicates address may be used for official correspondence |
| Confidentiality_Level | Standard, Confidential, Restricted |
| Validation_Required_Flag | Indicates validation required before active use |
| Validation_Status | Not_Validated, Validated, Validation_Failed, Warning |
| Validation_Date | Date of last validation |
| Owner_Comment | Optional owner-specific context |
| Governance_Hold_Flag | Prevents change/removal without review |

---

# 4. Why Address Association Exists

Address should not be treated as a document-style versioned object.

Address changes are normally modeled as time-based changes in usage or ownership context.

For example:

```text
Person
    ├── Home Address Association
    │       Effective: Jan 1 – Jun 30
    │       Address: 123 Oak Street
    └── Home Address Association
            Effective: Jul 1 – Present
            Address: 456 Pine Avenue
```

This is not “version 2” of the same address record.

It is a new effective-dated ownership association.

Address Association preserves that distinction.

---

# 5. Ownership Patterns

Supported patterns include:

```text
Person
    └── Address Association (1..n)
            └── Address

Employment
    └── Address Association (0..n)
            └── Address

Legal Entity
    └── Address Association (1..n)
            └── Address

Client Company
    └── Address Association (0..n)
            └── Address

Tenant
    └── Address Association (0..n)
            └── Address

Org Unit
    └── Address Association (0..n)
            └── Address
```

Each owner may have one or more address associations over time.

The same Address record may be reused by more than one owner where governance allows, but each usage must remain explicitly associated.

---

# 6. Address Role Model

Address_Role defines how the owner uses the address.

Suggested roles include:

| Address Role | Meaning |
|---|---|
| Home | Primary residential address |
| Mailing | Postal correspondence address |
| Registered | Registered office or legal address |
| Operational | Active operating address |
| Billing | Billing or invoicing address |
| Worksite | Work location address |
| Service_of_Process | Legal notice / service address |
| Tax_Registration | Authority registration address |
| Other | Governed custom role |

The platform may allow controlled extension of role values where policy permits.

---

# 7. Primary Address Rules

Primary designation is contextual.

An owner may have:

- one primary Home address
- one primary Mailing address
- one primary Registered address
- one primary Billing address

Primary_For_Role_Flag shall be interpreted within the owner + address role + effective date context.

The model shall prevent ambiguous duplicate primary addresses for the same role where policy requires uniqueness.

---

# 8. Effective Dating and Historical Preservation

Address Association is the primary historical mechanism for address usage.

It shall support:

- effective start date
- effective end date
- owner-role transitions
- supersession behavior
- historical preservation

Historical address associations must remain queryable for:

- payroll replay
- tax analysis
- correspondence disputes
- audit review
- legal discovery
- compliance reconstruction

Silent overwrite is not permitted where address usage has payroll, compliance, legal, or reporting significance.

---

# 9. Relationship to Person

For Person, Address Association supports durable identity-related address history.

Examples:

- home address history
- mailing address history
- protected-address handling
- temporary address during leave or relocation

A Person may have multiple simultaneous address associations for different roles.

---

# 10. Relationship to Employment

For Employment, Address Association supports relationship-specific address usage.

Examples:

- employment-specific mailing override
- remote work address
- assignment-related correspondence address
- payroll delivery override address

Employment address associations do not replace person identity addresses unless explicitly reused.

---

# 11. Relationship to Legal Entity

For Legal Entity, Address Association supports multiple concurrent business address roles.

Examples:

- registered office
- principal place of business
- service-of-process address
- remittance correspondence address
- tax registration address

Legal Entity address history may be compliance-relevant and must remain auditable.

---

# 12. Relationship to Client Company, Tenant, and Org Unit

Address Association supports business and administrative structures above and beside the employment layer.

### 12.1 Client Company

Examples:

- headquarters address
- billing correspondence address
- client notice address

### 12.2 Tenant

Examples:

- master billing address
- commercial notice address
- tenant administrative address

### 12.3 Org Unit

Examples:

- branch office
- warehouse location
- worksite reference

Each of these shall remain structurally distinct even if the same physical Address record is reused.

---

# 13. Relationship to Jurisdiction and Compliance

Address Association may carry jurisdictional relevance.

For example:

- a Person home address may affect withholding refinement
- an Employment worksite address may affect local labor rules
- a Legal Entity registered address may affect authority alignment
- a tax registration address may support filing context

However, Address Association does not replace the broader statutory chain:

```text
Employment
    → Legal Entity
        → Jurisdiction Registration
            → Jurisdiction Profile
```

Address Association refines context.

It does not replace employer-of-record or registration-based compliance anchors.

---

# 14. Association Status Model

Suggested Association_Status values:

| Status | Meaning |
|---|---|
| Pending | Created but not yet effective |
| Active | Currently governing association |
| Superseded | Replaced by a later association |
| Inactive | No longer active but retained |
| Historical | Preserved purely for historical reference |
| Restricted | Access-restricted association |

Status transitions shall be governed and auditable.

---

# 15. Validation Rules

Examples of validation rules:

- Owner_Object_Type is required
- Owner_Object_ID is required
- Address_ID is required
- Address_Role is required
- Effective_Start_Date is required
- Effective_End_Date may not precede Effective_Start_Date
- Only one primary address per owner/role/effective context may exist where policy requires
- Restricted associations may not be exposed outside approved scopes
- Validation_Required_Flag may require successful validation before activation where policy requires

These validations may be enforced through workflow, validation frameworks, and external address services.

---

# 16. Audit and Traceability Requirements

The system shall preserve:

- association creation history
- owner linkage history
- role change history
- primary designation changes
- effective-date change history
- validation status history
- confidentiality classification history

This supports:

- payroll replay
- compliance audit
- tax dispute handling
- correspondence tracking
- privacy review

---

# 17. Relationship to Other Models

This model integrates with:

- Address_Data_Model
- Person_Data_Model
- Employment_Data_Model
- Legal_Entity_Data_Model
- Client_Company_Data_Model
- Tenant_Data_Model
- Organizational_Structure_Model
- Jurisdiction_Registration_and_Profile_Data_Model

---

# 18. Summary

This model establishes Address Association as the effective-dated ownership and usage layer for address records.

Key principles:

- Address stores reusable location structure
- Address Association stores owner, role, and time-based usage
- Address history is modeled through effective-dated associations, not naive overwrite
- Primary address semantics are contextual by owner and role
- Address associations may refine compliance context but do not replace Legal Entity and registration-based statutory anchors
- Historical integrity, validation, confidentiality, and auditability are mandatory
