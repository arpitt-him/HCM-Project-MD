# Person_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Identity Domain |
| **Location** | docs/architecture/data/Person_Data_Model.md |
| **Domain** | Person / Identity / Durable Human Record |
| **Related Documents** | Employment_Data_Model.md, Employment_and_Person_Identity_Model.md, Legal_Entity_Data_Model.md, Client_Company_Data_Model.md, Tenant_Data_Model.md, Security_and_Access_Control_Model.md, Document_Model.md |

---

# Purpose

This document defines the core data structure for **Person** as the durable human identity record within the platform.

Person is not Employment.

Person is not Assignment.

Person is not User Account.

Person is the enduring identity construct representing the human individual across one or more Employment relationships over time.

This model exists to support:

- rehire scenarios
- concurrent employments
- cross-entity movement
- historical continuity of identity
- document linkage
- self-service identity continuity
- secure handling of personally identifiable information

without confusing human identity with operational employment relationships.

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
Person
```

Operationally, Employment attaches to Legal Entity.

Identity-wise, Employment attaches upward to Person.

A Person may exist before Employment, during Employment, and after all Employment relationships have ended.

---

# 1. Person Definition

A **Person** represents a distinct human being known to the platform.

A Person may:

- have no Employment yet
- have one active Employment
- have multiple concurrent Employments
- have prior terminated Employments
- return through rehire under the same or a different Legal Entity

Person shall be modeled as distinct from:

- Employment
- Assignment
- User Account
- Payroll record
- Position
- Job
- Tenant
- Client Company
- Legal Entity

Person is the identity anchor, not the employer relationship.

---

# 2. Person Primary Attributes

| Field Name | Description |
|---|---|
| Person_ID | Unique identifier |
| Person_Number | Optional human-facing or integration-facing identifier |
| Legal_First_Name | Legal first name |
| Legal_Middle_Name | Optional legal middle name |
| Legal_Last_Name | Legal last name |
| Name_Suffix | Optional suffix |
| Preferred_Name | Optional preferred/given name |
| Date_of_Birth | Date of birth |
| Country_of_Birth | Optional country of birth |
| Person_Status | Active, Inactive, Deceased, Restricted, Archived |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Person Sensitive Identity Attributes

The platform may also hold sensitive identity attributes where legally and operationally required.

| Field Name | Description |
|---|---|
| National_Identifier | SSN, SIN, NIN, or equivalent |
| National_Identifier_Type | Jurisdiction-specific identifier type |
| Secondary_Identifier | Optional alternate identifier |
| Gender_or_Sex_Code | Optional, governed by jurisdiction and policy |
| Pronouns | Optional self-identified value |
| Citizenship_Status | Optional citizenship or national status |
| Work_Authorization_Status | Optional work eligibility indicator |
| Work_Authorization_Expiration_Date | Optional expiration date |

Sensitive identity attributes must be protected using encryption, access controls, masking, and audit trails.

---

# 4. Person Contact and Demographic Attributes

| Field Name | Description |
|---|---|
| Primary_Email_Address | Preferred primary email |
| Primary_Phone_Number | Preferred primary phone |
| Secondary_Phone_Number | Optional secondary phone |
| Primary_Address_ID | Reference to primary address record |
| Mailing_Address_ID | Reference to mailing address record |
| Emergency_Contact_Profile_ID | Emergency contact reference |
| Marital_Status | Optional status where relevant |
| Language_Preference | Preferred language |
| Disability_Status | Optional, governed by compliance and privacy rules |
| Veteran_Status | Optional, governed by compliance and privacy rules |

The platform may choose to normalize some of these into related profile structures rather than storing them directly on Person.

---

# 5. Person as Durable Identity Anchor

Person is the enduring record that persists across all Employment relationships.

The platform shall preserve Person identity even when:

- Employment ends
- Legal Entity changes
- Client Company changes
- Tenant relationship changes, where cross-tenant identity strategies are supported
- rehire occurs after long gaps

Person shall not be recreated merely because an Employment relationship ends and later resumes.

Where platform policy requires tenant-local isolation of Person identity, such policy shall be explicit and governed rather than assumed.

---

# 6. Relationship to Employment

```text
Person
    └── Employment (1..n)
```

Constraints:

- A Person may have zero, one, or many Employment records.
- Employment records must reference exactly one Person.
- A Person may have multiple concurrent Employments where allowed.
- Rehire shall generally create a new Employment, not a new Person.
- Historical Employment records shall remain linked to the same Person identity.

This supports:

- durable identity continuity
- payroll and service history linkage
- workforce analytics continuity
- document continuity
- self-service continuity

---

# 7. Relationship to Legal Entity, Client Company, and Tenant

Person does not attach directly to Legal Entity as the primary structural anchor.

Instead:

```text
Person
    ← Employment
        → Legal Entity
            → Client Company
                → Tenant
```

This distinction matters.

Person is a human identity record.

Employment is the legal and operational relationship.

Client Company and Tenant are grouping and isolation layers, not the identity anchor.

Derived or materialized references may exist for reporting or search optimization, but the authoritative relationship shall remain through Employment.

---

# 8. Relationship to User Account and Self-Service

Person is not the same as a user account.

A Person may have:

- no user account
- one user account
- multiple identity-provider relationships, where supported
- changing authentication credentials over time

User account or authentication constructs shall attach to Person or a dedicated identity-access layer, but they shall not replace the Person record.

This supports:

- employee self-service
- former employee access patterns where permitted
- account migration
- identity provider changes
- access revocation without loss of identity history

---

# 9. Relationship to Documents

Documents may attach to Person where they represent durable human identity or personal record material.

Examples:

- identity documents
- tax forms
- work authorization documents
- licenses and certifications
- emergency documentation

Typical structure:

```text
Person
    └── Document (1..n)
```

Some documents may also attach to Employment where they are relationship-specific rather than person-specific.

---

# 10. Person Status Model

Suggested Person_Status values:

| Status | Meaning |
|---|---|
| Active | Person has at least one relevant active relationship or is operationally current |
| Inactive | Person has no current active relationship but record remains valid |
| Deceased | Person record preserved for legal/history purposes |
| Restricted | Access-restricted person record |
| Archived | Long-term retained historical record with limited operational use |

Status transitions shall be governed and auditable.

A Person may remain Inactive or Archived long after all Employment records have ended.

---

# 11. Person Merge, Duplicate, and Identity Resolution Considerations

The platform shall support identity-resolution controls for duplicate or fragmented person records.

Potential scenarios include:

- duplicate creation during onboarding
- rehire created as a new person by mistake
- imported record collision
- multi-source integration mismatch

The model shall support:

- duplicate detection
- governed merge review
- controlled merge execution
- audit preservation of pre-merge identity references

Person merges shall never silently destroy historical references.

---

# 12. Effective Dating and Historical Preservation

Person shall support historical preservation of identity-relevant changes.

Changes that may require historical tracking include:

- legal name changes
- preferred name changes
- status changes
- contact changes
- identifier changes
- work authorization changes

Where effective dating is not applied directly on Person, equivalent historical preservation must still exist through subordinate history records or audit structures.

Silent overwrite is not permitted for materially important identity attributes.

---

# 13. Validation Rules

Examples of validation rules:

- Legal_First_Name is required
- Legal_Last_Name is required
- Date_of_Birth is required where jurisdiction and policy require it
- Person_Status is required
- National_Identifier must conform to applicable format rules where present
- Restricted records require governed access classification
- Deceased records may not receive new active Employment without formal correction review
- Duplicate detection must be triggered on configurable identity matching rules

These validations may be enforced through validation frameworks, workflow controls, and security policies.

---

# 14. Audit and Traceability Requirements

The system shall preserve:

- Person creation history
- name change history
- status transition history
- identifier change history
- contact change history
- duplicate/merge history
- Employment linkage history
- document linkage history

This supports:

- legal audit
- payroll replay context
- compliance review
- dispute handling
- identity resolution traceability

---

# 15. Privacy and Security Requirements

Person records contain highly sensitive data.

The platform shall support:

- encryption of sensitive identifiers
- field-level access control
- masking of protected values
- privacy-aware audit logging
- restricted access workflows
- retention and archival controls
- jurisdiction-aware privacy handling where required

Identity visibility shall be role-scoped and purpose-limited.

---

# 16. Relationship to Other Models

This model integrates with:

- Employment_Data_Model
- Employment_and_Person_Identity_Model
- Legal_Entity_Data_Model
- Client_Company_Data_Model
- Tenant_Data_Model
- Security_and_Access_Control_Model
- Document_Model

---

# 17. Summary

This model establishes Person as the durable human identity construct of the platform.

Key principles:

- Person is distinct from Employment, Assignment, and User Account
- Person persists across rehire, termination, and entity changes
- Employment attaches to Person and to Legal Entity
- Person identity continuity must be preserved
- Sensitive identity data requires strong protection
- Duplicate and merge handling must be governed and auditable
- Historical integrity and privacy controls are mandatory
