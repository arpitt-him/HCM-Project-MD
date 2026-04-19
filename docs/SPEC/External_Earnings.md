# SPEC — External Earnings Import

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/SPEC/External_Earnings.md` |
| **Related Documents** | PRD-0400_Earnings_Model.md, PRD-0900_Integration_Model.md, SPEC/Residual_Commissions.md, DATA/Entity_Payroll_Item.md, docs/architecture/calculation-engine/External_Result_Import_Specification.md |

## Purpose

Specifies the import format, validation rules, processing workflow, inputs, outputs, and audit requirements for externally calculated earnings entering the payroll platform. This document applies to all external earning types. Residual commission-specific behaviour is detailed further in `SPEC/Residual_Commissions.md`.

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

## 4. Inputs

### 4.1 File Upload Inputs

| Field | Type | Required | Validation | Notes |
|---|---|---|---|---|
| Participant_ID | String | Yes | Must match an active Employment_ID | Internal platform key |
| Earning_Type | String | Yes | Must map to a valid canonical earning code | See Code_Classification_and_Mapping_Model |
| Period_ID | String | Yes | Format YYYY-MM; must match an open payroll period | Closed periods reject the record |
| Amount | Decimal | Yes | Valid decimal; two decimal places; positive or negative | Negative values represent recoveries or chargebacks |
| Source_System | String | Yes | Non-empty string | Identifier of the originating system |
| Source_Batch_ID | String | Yes | Non-empty string; unique within submission | Used for deduplication and replay |
| Source_Record_Count | Integer | No | Positive integer | Number of source transactions summarised |
| Description | String | No | Must fit within pay statement character limit | Appears on pay statement if provided |
| Source_Total_Basis_Amount | Decimal | No | Valid decimal | Basis amount for reconciliation |
| Currency_Code | String | No | ISO 4217; defaults to USD | Required in multi-currency environments |

### 4.2 Approval Action Inputs

| Field | Type | Required | Notes |
|---|---|---|---|
| Approver_User_ID | String | Yes | Must hold the Import Approver role |
| Approval_Timestamp | Datetime | Yes | System-generated at approval action |
| Approval_Decision | Enum | Yes | APPROVE or REJECT |
| Rejection_Reason | String | Conditional | Required if Approval_Decision = REJECT |

### 4.3 Example File

```csv
Participant_ID,Earning_Type,Period_ID,Amount,Source_System,Source_Batch_ID,Source_Record_Count,Description
10025,RESIDUAL,2026-01,3104.22,COMM_SYS,BATCH-2026-01-RES,417,January residual commissions
10025,COMMISSION,2026-01,9842.55,COMM_SYS,BATCH-2026-01-COM,126,January direct commissions
10025,RECOVERY,2026-01,-420.00,COMM_SYS,BATCH-2026-01-ADJ,3,Chargeback adjustments
```

---

## 5. Processing Workflow

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

## 6. Success Outputs

### 6.1 Records Created

| Output | Entity | Description |
|---|---|---|
| Staged Earning Record | External_Earning_Staging | One record per accepted import row, held pending approval |
| Committed Earning Record | Payroll_Item (External) | Created at commit; one per Participant_ID + Earning_Type + Period_ID |
| Batch Receipt | Import_Batch_Receipt | Created at each stage transition; contains record counts and totals |
| Audit Record | Import_Audit_Log | Created at upload, validation, approval, and commit |

### 6.2 Events Published

| Event | Trigger | Consumers |
|---|---|---|
| ExternalEarningsStaged | Records pass validation and enter staging | Payroll run eligibility check |
| ExternalEarningsApproved | Approver confirms batch | Payroll calculation engine |
| ExternalEarningsCommitted | Records committed to payroll period | Payroll run, accumulator engine |

### 6.3 Side Effects

| Side Effect | Description |
|---|---|
| Payroll period availability | Committed records become available for inclusion in the next payroll run for the matching Period_ID |
| Batch fingerprint retained | File fingerprint stored to prevent duplicate ingestion of the same file |
| Pay statement line reserved | Description field reserved for display on employee pay statement at calculation time |

### 6.4 Accumulator Impact (at payroll calculation)

| Earning Type | Accumulator | Direction |
|---|---|---|
| Any positive earning code | Gross Wages (PTD, QTD, YTD, LTD) | Positive |
| Any negative earning code (e.g. RECOVERY) | Gross Wages (PTD, QTD, YTD, LTD) | Negative |

Note: accumulators are updated at payroll posting, not at import commit.

---

## 7. Error Outputs

### 7.1 File-Level Errors

| Error Code | Condition | Behaviour | Output Record |
|---|---|---|---|
| ERR-EXT-001 | File is not valid CSV | Entire file rejected; no records staged | Import_Error_Log with error code and description |
| ERR-EXT-002 | Required header columns missing | Entire file rejected | Import_Error_Log |
| ERR-EXT-003 | Control total mismatch (if provided) | Entire file rejected | Import_Error_Log with submitted vs computed totals |
| ERR-EXT-004 | Duplicate file fingerprint detected | Entire file rejected as duplicate | Import_Error_Log with reference to prior submission |

### 7.2 Row-Level Errors

| Error Code | Field | Condition | Behaviour |
|---|---|---|---|
| ERR-EXT-010 | Participant_ID | No active Employment record found | Row rejected; routes to exception queue |
| ERR-EXT-011 | Earning_Type | Does not map to a valid canonical code | Row rejected; routes to exception queue |
| ERR-EXT-012 | Period_ID | Format invalid (not YYYY-MM) | Row rejected |
| ERR-EXT-013 | Period_ID | Period is closed or does not exist | Row rejected; routes to exception queue |
| ERR-EXT-014 | Amount | Not a valid decimal value | Row rejected |
| ERR-EXT-015 | Source_Batch_ID | Missing or empty | Row rejected |
| ERR-EXT-016 | Description | Exceeds pay statement character limit | Row accepted with warning; description truncated |
| ERR-EXT-017 | (row) | Duplicate Participant_ID + Earning_Type + Period_ID within same batch | Row rejected |

### 7.3 Error Record Structure

Each error produces an Import_Error_Record containing:

| Field | Description |
|---|---|
| Error_ID | Unique identifier |
| Batch_ID | Source_Batch_ID from the submission |
| Row_Number | CSV row number (file-level errors: 0) |
| Error_Code | ERR-EXT-NNN |
| Error_Message | Human-readable description |
| Offending_Value | The field value that caused the failure (where applicable) |
| Severity | FILE_REJECT / ROW_REJECT / WARNING |
| Timestamp | When the error was detected |

---

## 8. Adjustment Model

Multiple submissions for the same `Participant_ID + Earning_Type + Period_ID` are permitted. Each subsequent record is treated as an **adjustment**, not a replacement.

- Original records are never overwritten.
- Adjustment records may carry positive or negative amounts.
- Each adjustment must reference its own `Source_Batch_ID`.
- The net effect across all batches for a given combination represents the final import position.

This preserves audit history and prevents silent data replacement.

---

## 9. Validation Rules

| Rule | Level | Error Code | Behaviour on Failure |
|---|---|---|---|
| All required fields present | Row | ERR-EXT-010 to 015 | Row rejected |
| Amount is valid decimal | Row | ERR-EXT-014 | Row rejected |
| Period_ID format is YYYY-MM | Row | ERR-EXT-012 | Row rejected |
| Earning_Type maps to valid canonical code | Row | ERR-EXT-011 | Row rejected; routes to exception queue |
| Participant_ID matches active Employment | Row | ERR-EXT-010 | Row rejected; routes to exception queue |
| Duplicate record within same batch | Row | ERR-EXT-017 | Row rejected |
| Control total matches batch sum (if provided) | File | ERR-EXT-003 | File rejected |
| File is structurally valid CSV | File | ERR-EXT-001 | File rejected |

---

## 10. Reconciliation Controls

Each batch should supply reconciliation anchors:

| Control | Purpose |
|---|---|
| Source_Batch_ID | Deduplication and replay tracking |
| Source_Record_Count | Confirms expected number of summarised transactions |
| Source_Total_Basis_Amount (optional) | Allows verification of the basis used in the source system |

The platform retains the batch fingerprint to prevent duplicate ingestion of the same file.

---

## 11. Audit Requirements

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

## 12. Security

- Upload and approval functions are restricted to authorised roles per the `Security_and_Access_Control_Model`.
- Imported files containing employee financial data are encrypted at rest and in transit.
- Access to staged records before approval is limited to the uploading user and designated approvers.

---

## 13. Future Expansion

Future enhancements planned but not in v0.1 scope:

- Scheduled file-drop ingestion (SFTP)
- API-based per-record or batch ingestion
- Real-time validation feedback
- Enhanced reconciliation dashboards

These enhancements will not alter the core summarised-record model or the staging/approval workflow.
