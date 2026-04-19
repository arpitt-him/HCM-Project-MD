# SPEC — External Earnings Import

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/SPEC/External_Earnings.md` |
| **Related Documents** | PRD-0400_Earnings_Model.md, PRD-0900_Integration_Model.md, SPEC/Residual_Commissions.md, DATA/Entity_Payroll_Item.md, docs/architecture/calculation-engine/External_Result_Import_Specification.md |

## Purpose

Specifies the import format, validation rules, processing workflow, and audit requirements for externally calculated earnings entering the payroll platform. This document applies to all external earning types. Residual commission-specific behaviour is detailed further in `SPEC/Residual_Commissions.md`.

---

## 1. Scope

External earnings are earnings amounts calculated outside the HCM platform and imported for inclusion in a payroll run. Common sources include:

- Commission management systems
- Revenue and billing systems
- Incentive compensation systems
- Metering and usage systems

The platform accepts summarised external earnings — one record per employee per earning type per period. Transaction-level detail remains in the source system.

---

## 2. Supported Import Methods

| Method | Status |
|---|---|
| Manual CSV file upload | Supported (v0.1) |
| Scheduled file-drop ingestion | Planned |
| API-based ingestion | Planned |

All methods follow the same validation, staging, and approval workflow regardless of transport.

---

## 3. Record Granularity

One import record is required per:

```
Participant_ID + Earning_Type + Period_ID
```

Multiple earning types per employee in the same period are supported and expected. Transaction-level detail must remain in the source system.

---

## 4. CSV File Structure

### Required Fields

| Field | Type | Notes |
|---|---|---|
| Participant_ID | String | Must match an active Employment_ID in the platform |
| Earning_Type | String | Must map to a valid canonical earning code |
| Period_ID | String | Format: YYYY-MM; must match an open payroll period |
| Amount | Decimal | Positive or negative; two decimal places |
| Source_System | String | Identifier of the originating system |
| Source_Batch_ID | String | Unique identifier for this submission batch |

### Recommended Fields

| Field | Type | Notes |
|---|---|---|
| Source_Record_Count | Integer | Number of source transactions summarised |
| Description | String | Appears on pay statement; must fit within character limit |
| Source_Total_Basis_Amount | Decimal | Basis amount for reconciliation (e.g., revenue base for residual) |
| Currency_Code | String | Defaults to USD if omitted in single-currency environments |

### Example File

```csv
Participant_ID,Earning_Type,Period_ID,Amount,Source_System,Source_Batch_ID,Source_Record_Count,Description
10025,RESIDUAL,2026-01,3104.22,COMM_SYS,BATCH-2026-01-RES,417,January residual commissions
10025,COMMISSION,2026-01,9842.55,COMM_SYS,BATCH-2026-01-COM,126,January direct commissions
10025,RECOVERY,2026-01,-420.00,COMM_SYS,BATCH-2026-01-ADJ,3,Chargeback adjustments
```

---

## 5. Adjustment Model

Multiple submissions for the same `Participant_ID + Earning_Type + Period_ID` are permitted. Each subsequent record is treated as an **adjustment**, not a replacement.

- Original records are never overwritten.
- Adjustment records may carry positive or negative amounts.
- Each adjustment must reference its own `Source_Batch_ID`.
- The net effect across all batches for a given combination represents the final import position.

This preserves audit history and prevents silent data replacement.

---

## 6. Processing Workflow

```
Upload → Validate → Stage → Approve → Commit
```

| Stage | Description |
|---|---|
| Upload | File received and fingerprinted for deduplication |
| Validate | Schema, field, and referential integrity checks run |
| Stage | Records held in temporary state; not yet available to payroll |
| Approve | Authorised user reviews validation results and confirms |
| Commit | Records become available for inclusion in the payroll run |

Partial posting is not permitted. A file must either fully commit or be rejected for correction and resubmission.

---

## 7. Validation Rules

| Rule | Level | Behaviour on Failure |
|---|---|---|
| All required fields present | Row | Row rejected |
| Amount is valid decimal | Row | Row rejected |
| Period_ID format is YYYY-MM | Row | Row rejected |
| Earning_Type maps to valid canonical code | Row | Row rejected; routes to exception queue |
| Participant_ID matches active Employment | Row | Row rejected; routes to exception queue |
| Duplicate record within same batch | Row | Row rejected |
| Control total matches batch sum (if provided) | File | File rejected |
| File is structurally valid CSV | File | File rejected |

---

## 8. Error Handling

**File-level errors** (structural failures) reject the entire file. No records are staged.

**Row-level errors** reject individual records. Behaviour for partially valid files (some rows pass, some fail) is configurable per deployment policy — default is reject all.

Rejected records must be corrected in the source system and resubmitted. The platform does not provide a UI for editing imported records directly.

---

## 9. Reconciliation Controls

Each batch should supply reconciliation anchors:

| Control | Purpose |
|---|---|
| Source_Batch_ID | Deduplication and replay tracking |
| Source_Record_Count | Confirms expected number of summarised transactions |
| Source_Total_Basis_Amount (optional) | Allows verification of the basis used in the source system |

The platform retains the batch fingerprint to prevent duplicate ingestion of the same file.

---

## 10. Audit Requirements

The platform records the following for every import batch:

- Uploaded file name and fingerprint
- Upload timestamp and uploading user
- Validation results (pass/fail per row)
- Staging timestamp
- Approval timestamp and approving user
- Commit timestamp
- Record counts (submitted, accepted, rejected)
- Batch identifiers

Audit records are retained per the `Data_Retention_and_Archival_Model`.

---

## 11. Security

- Upload and approval functions are restricted to authorised roles per the `Security_and_Access_Control_Model`.
- Imported files containing employee financial data are encrypted at rest and in transit.
- Access to staged records before approval is limited to the uploading user and designated approvers.

---

## 12. Future Expansion

Future enhancements planned but not in v0.1 scope:

- Scheduled file-drop ingestion (SFTP)
- API-based per-record or batch ingestion
- Real-time validation feedback
- Enhanced reconciliation dashboards

These enhancements will not alter the core summarised-record model or the staging/approval workflow.
