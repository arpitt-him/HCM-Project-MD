# Entity — Document

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Document.md` |
| **Related Documents** | DATA/Entity_Person.md, DATA/Entity_Employee.md, HRIS_Module_PRD.md §12, docs/STATE/STATE-DOC_Document.md, docs/architecture/governance/Data_Retention_and_Archival_Model.md |

## Purpose

Defines the Document entity — an HR document associated with a Person or Employment record. Documents are versioned, date-stamped, and retained per regulatory requirements. Access is governed by role and employment scope.

---

## 1. Design Principles

- Documents are versioned. A new upload of the same document type creates a new version; the prior version is superseded, not deleted.
- Documents may be associated with a Person, an Employment, or both.
- Expiration tracking supports compliance alerting for time-sensitive documents (e.g., I-9, certifications).
- Access is governed by role and employment scope per the Security_and_Access_Control_Model.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Document_ID | UUID | Yes | System-generated. Immutable. |
| Person_ID | UUID | Yes | Always associated with a Person |
| Employment_ID | UUID | No | Null for person-level documents; required for employment-scoped documents |
| Document_Type | Enum | Yes | See values below |
| Document_Name | String | Yes | Display name for the document |
| Document_Version | Integer | Yes | Auto-incremented per document type per person/employment |
| Document_Status | Enum | Yes | References STATE-DOC; see values below |
| Effective_Date | Date | Yes | Date the document takes effect |
| Expiration_Date | Date | No | Null for non-expiring documents |
| Storage_Reference | String | Yes | Secure reference to the stored file |
| File_Format | String | Yes | PDF, DOCX, PNG, etc. |
| Upload_Date | Datetime | Yes | System-generated |
| Uploaded_By | UUID | Yes | User who uploaded the document |
| Verified_By | UUID | No | User who verified document authenticity |
| Verification_Date | Datetime | No | |
| Superseded_By_Document_ID | UUID | No | Reference to newer version |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | System-generated |

---

## 3. Document_Type Values

| Value | Description | Expiration Required |
|---|---|---|
| I9 | Employment Eligibility Verification | Yes (re-verification) |
| W4 | Federal Tax Withholding | No |
| STATE_TAX_FORM | State equivalent of W-4 | No |
| OFFER_LETTER | Signed offer letter | No |
| EMPLOYMENT_AGREEMENT | Signed employment contract | No |
| NDA | Non-Disclosure Agreement | No |
| POA | Power of Attorney | Yes |
| LICENSE | Professional license or certification | Yes |
| CERTIFICATION | Compliance or training certification | Yes |
| PERFORMANCE_REVIEW | Annual or periodic performance documentation | No |
| DISCIPLINARY | Disciplinary action record | No |
| OTHER | Other HR document | No |

---

## 4. Document_Status Values (references STATE-DOC)

| Value | STATE-DOC Reference | Description |
|---|---|---|
| ACTIVE | STATE-DOC-001 | Current version in use |
| SUPERSEDED | STATE-DOC-002 | Replaced by newer version |
| EXPIRED | STATE-DOC-003 | Past expiration date |
| ARCHIVED | STATE-DOC-004 | Retained for compliance; no longer active |

---

## 5. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Document → Person | Many-to-one | Always required |
| Document → Employment | Many-to-one | Optional |
| Document → Superseding Document | One-to-one | Optional; links version chain |

---

## 6. Expiration and Compliance Alerting

Documents with an Expiration_Date generate compliance alerts as expiration approaches. Alert thresholds are configurable per Document_Type. Missing I-9 documentation past the legally required window generates EXC-VAL-013.

---

## 7. Governance

- Documents may only be uploaded through authorised intake channels.
- Document_Status may only transition through valid STATE-DOC paths.
- Prior document versions are never deleted; they are superseded.
- Documents under legal hold may not be archived or purged.
- All document actions are audit-logged with timestamp and actor.

---

## 8. Related Architecture Models

| Model | Relevance |
|---|---|
| Data_Retention_and_Archival_Model | Retention periods and archival lifecycle |
| Security_and_Access_Control_Model | Role-based document access |
