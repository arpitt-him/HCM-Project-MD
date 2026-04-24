# STATE-DOC — Document States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/STATE/STATE-DOC_Document.md` |
| **Applies To** | All HR documents associated with Person or Employment records |
| **Related Documents** | HRIS_Module_PRD.md §12, docs/architecture/governance/Data_Retention_and_Archival_Model.md |

## Purpose

Defines the lifecycle states for HR documents from upload through archival.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-DOC-001 | Active | Current version; in use and accessible | No |
| STATE-DOC-002 | Superseded | Replaced by a newer version; retained for audit | Yes |
| STATE-DOC-003 | Expired | Past its expiration date; compliance alert triggered | No |
| STATE-DOC-004 | Archived | Retained for compliance; no longer operationally active | Yes |

**Terminal states:** STATE-DOC-002 (Superseded), STATE-DOC-004 (Archived).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-DOC-001 | STATE-DOC-002 | New version of same document uploaded | New document version accepted; prior version automatically superseded |
| STATE-DOC-001 | STATE-DOC-003 | Expiration date reached | System-triggered; compliance alert generated |
| STATE-DOC-001 | STATE-DOC-004 | Document archived per retention policy or manual action | Retention period elapsed or HR admin action |
| STATE-DOC-003 | STATE-DOC-001 | Document renewed or re-verified | New version uploaded; expiration date updated |
| STATE-DOC-003 | STATE-DOC-004 | Archived without renewal | Retention policy triggered or HR admin action |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-DOC-002 | Any | Superseded is terminal; a new document upload creates a fresh Active record |
| STATE-DOC-004 | Any | Archived is terminal; documents under legal hold cannot be deleted |
| STATE-DOC-003 | STATE-DOC-002 | An expired document cannot be superseded; it must be renewed first |
