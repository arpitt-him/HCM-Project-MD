# Document_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Document Governance Domain |
| **Location** | docs/architecture/data/Document_Data_Model.md |
| **Domain** | Document / Recordkeeping / Compliance Evidence |
| **Related Documents** | Person_Data_Model.md, Employment_Data_Model.md, Legal_Entity_Data_Model.md, Data_Retention_and_Archival_Model.md, Security_and_Access_Control_Model.md, Platform_Composition_and_Extensibility_Model.md |

---

# Purpose

This document defines the core data structure for **Document** as a governed record object within the platform.

A Document represents an electronic or referenced record associated with a governed platform object such as:

- Person
- Employment
- Legal Entity
- Client Company
- Tenant
- Onboarding process
- Compliance workflow

Document exists to support:

- statutory recordkeeping
- employment documentation
- tax and payroll documentation
- onboarding and offboarding evidence
- legal and audit support
- secure attachment of governed artifacts
- versioned record preservation

This model ensures that documents are handled as governed records rather than as generic files.

---

# Core Structural Role

```text
Tenant / Client Company / Legal Entity / Person / Employment
    ↓
Document
    ↓
Version / Retention / Access Control / Audit
```

Document may attach to multiple types of governing objects, but always through explicit reference.

The Document layer provides:

- attachment semantics
- document typing
- version history
- access governance
- retention handling
- audit traceability

---

# 1. Document Definition

A **Document** represents a governed record or file reference stored in or linked through the platform.

A Document may represent:

- an uploaded file
- a generated file
- a signed agreement
- a tax form
- a scanned record
- an identity document
- a certification
- a compliance artifact
- a legal notice
- a workflow-generated document package

Document shall be modeled as distinct from:

- Person
- Employment
- Legal Entity
- User Account
- Workflow Event
- Audit Record
- Storage Blob

Document is the business-level governed record, not the storage implementation.

---

# 2. Document Primary Attributes

| Field Name | Description |
|---|---|
| Document_ID | Unique identifier |
| Document_Number | Optional business-facing identifier |
| Document_Type | I-9, W-4, Offer Letter, Contract, Certification, Attachment, Other |
| Document_Category | Identity, Tax, Employment, Compliance, Payroll, Legal, Other |
| Document_Title | Human-readable title |
| Document_Description | Optional descriptive text |
| Document_Status | Draft, Active, Superseded, Archived, Expired, Deleted_Logical |
| Effective_Date | Date document becomes effective where applicable |
| Expiration_Date | Date document expires where applicable |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Document Functional Attributes

| Field Name | Description |
|---|---|
| Owner_Object_Type | Governing object type (Person, Employment, Legal Entity, etc.) |
| Owner_Object_ID | Governing object reference |
| Storage_Reference | Blob/object store/path/reference identifier |
| File_Name | Original or generated file name |
| File_Format | PDF, DOCX, JPG, PNG, etc. |
| MIME_Type | MIME content type |
| File_Size_Bytes | File size |
| Language_Code | Optional document language |
| Source_Type | Uploaded, Generated, Imported, External Reference |
| Confidentiality_Level | Public_Internal, Confidential, Restricted, Highly_Restricted |
| Signature_Status | Unsigned, Signed, Partially_Signed, Not_Applicable |
| Template_ID | Optional source template reference |
| Generated_Flag | Indicates system-generated document |
| Notes | Administrative notes |

---

# 4. Document Ownership Model

A Document must attach to a governed owning object.

Supported ownership patterns include:

```text
Person
    └── Document (1..n)

Employment
    └── Document (1..n)

Legal Entity
    └── Document (1..n)

Client Company
    └── Document (1..n)

Tenant
    └── Document (1..n)
```

Document ownership must be explicit.

A document may support cross-reference to multiple related objects, but one primary owner shall always be identified for governance purposes.

---

# 5. Relationship to Person

Documents may attach to Person where they represent durable human identity or personal record materials.

Examples:

- identity documents
- licenses
- certifications
- immigration/work authorization records
- personal tax forms where person-based handling is required

Person-linked documents persist across Employment changes where applicable.

---

# 6. Relationship to Employment

Documents may attach to Employment where they are specific to an employer relationship.

Examples:

- offer letters
- employment agreements
- compensation notices
- disciplinary records
- leave approvals
- onboarding packages
- termination notices

Employment-linked documents remain attached to the Employment record even after termination for historical and compliance purposes.

---

# 7. Relationship to Legal Entity, Client Company, and Tenant

Documents may also attach above the worker level.

### 7.1 Legal Entity Documents

Examples:

- registration certificates
- tax authority correspondence
- insurance certificates
- policy acknowledgements
- labor authority notices

### 7.2 Client Company Documents

Examples:

- service agreements
- client onboarding documents
- billing agreements
- client policy documents

### 7.3 Tenant Documents

Examples:

- master service agreements
- tenant-level policy bundles
- platform operating agreements
- global compliance artifacts

These ownership levels support governance beyond worker-specific records.

---

# 8. Document Versioning Model

Documents shall support governed versioning.

A Document may have one or more Document Versions over time.

Typical structure:

```text
Document
    └── Document Version (1..n)
```

A version shall preserve:

- source file or rendered output
- creation timestamp
- author/uploader identity
- signature state where applicable
- supersession relationship

Versioning supports:

- corrected uploads
- revised forms
- renewed certifications
- signed vs unsigned versions
- template regeneration

Document versioning shall not silently overwrite prior versions.

---

# 9. Document Version Attributes

| Field Name | Description |
|---|---|
| Document_Version_ID | Unique version identifier |
| Document_ID | Parent document reference |
| Version_Number | Version sequence |
| Storage_Reference | Version-specific storage reference |
| File_Name | Version file name |
| File_Size_Bytes | Version file size |
| Checksum_Value | Optional integrity checksum |
| Uploaded_By | User/process that created the version |
| Uploaded_Timestamp | Version creation timestamp |
| Signature_Status | Version-specific signature state |
| Supersedes_Document_Version_ID | Prior version reference |
| Active_Version_Flag | Indicates governing active version |

---

# 10. Document Status Model

Suggested Document_Status values:

| Status | Meaning |
|---|---|
| Draft | Created but not yet final |
| Active | Current governed version in force |
| Superseded | Replaced by a later version |
| Archived | Retained but not operationally current |
| Expired | Validity period has ended |
| Deleted_Logical | Hidden from normal use but retained per policy |

Status transitions shall be governed and auditable.

Documents required for compliance shall not be physically removed unless retention rules explicitly allow it.

---

# 11. Effective Dating and Expiration Handling

Documents may carry:

- effective date
- expiration date
- issue date
- signed date
- received date

Different document types may use these differently.

Examples:

- a certification may expire
- a policy acknowledgement may become effective on a future date
- a contract amendment may supersede a prior effective date
- a tax form may apply to a specific period

Where applicable, effective and expiration handling shall be queryable and auditable.

---

# 12. Retention and Archival Requirements

Document retention shall follow governed policies based on:

- document type
- owner object type
- jurisdiction
- legal hold status
- employment lifecycle status
- compliance requirements

The model shall support:

- archival state
- retention schedule linkage
- legal hold flagging
- disposal eligibility tracking

No document subject to active legal hold or statutory retention may be disposed of.

---

# 13. Access Control and Confidentiality

Documents often contain highly sensitive information.

The platform shall support:

- role-based access control
- owner-scope restrictions
- field and file confidentiality classes
- document-type access rules
- download restrictions
- masking/redaction workflows where applicable
- audit logging of access and retrieval events

Confidentiality level shall influence who may:

- view metadata
- view content
- download content
- replace versions
- delete logically
- archive or release

---

# 14. Validation Rules

Examples of validation rules:

- Document_Type is required
- Owner_Object_Type is required
- Owner_Object_ID is required
- Storage_Reference is required for stored documents
- Active_Version_Flag must be unique per Document
- Expiration_Date may not precede Effective_Date where both exist
- Signed-only document categories may not be marked Active until Signature_Status is valid where policy requires
- Restricted documents may not be exposed outside authorized scopes

These validations may be enforced through workflow, security, and validation frameworks.

---

# 15. Audit and Traceability Requirements

The system shall preserve:

- document creation history
- ownership changes where permitted
- version history
- status transition history
- signature history
- access history
- archival and retention actions
- legal hold actions

This supports:

- statutory audit
- dispute resolution
- HR and payroll evidence
- compliance review
- legal discovery

---

# 16. Relationship to Workflow and Generated Documents

Some documents are produced through governed workflows.

Examples:

- generated offer letters
- payroll notices
- disciplinary letters
- onboarding checklists packaged as documents
- signed acknowledgements

Generated documents shall still become governed Document records once created.

Workflow origin may be retained as source metadata but shall not replace document governance.

---

# 17. Relationship to Other Models

This model integrates with:

- Person_Data_Model
- Employment_Data_Model
- Legal_Entity_Data_Model
- Client_Company_Data_Model
- Tenant_Data_Model
- Data_Retention_and_Archival_Model
- Security_and_Access_Control_Model
- Platform_Composition_and_Extensibility_Model

---

# 18. Summary

This model establishes Document as a governed record object rather than a generic file reference.

Key principles:

- Document is distinct from storage implementation
- Document must attach to an explicit governing owner object
- Document supports governed versioning
- Document supports effective, expiration, retention, and archival handling
- Document access must be strongly controlled
- Document history, access, and supersession must remain auditable
- The model supports person, employment, legal entity, client company, and tenant document ownership
