# Payroll_Interface_and_Export_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/interfaces/Payroll_Interface_and_Export_Model.md` |
| **Domain** | Interfaces |
| **Related Documents** | PRD-900-Integration-Model.md, Result_and_Payable_Model, Payroll_Run_Model, Integration_and_Data_Exchange_Model, Correction_and_Immutability_Model, Payroll_Reconciliation_Model |

## Purpose

Defines the structure, lifecycle, and operational behaviour governing outbound payroll interfaces and export processing.

Controls how approved payroll execution outputs are prepared, formatted, transmitted, retried, confirmed, and reconciled with downstream payroll systems or third-party providers.

This model governs export processing for outputs derived from:

- Payroll_Run
- Payroll_Run_Result_Set
- Employee_Payroll_Result
- Result and payable structures
- Net pay and related outbound payment obligations

The model ensures that outbound payroll transmission remains traceable, idempotent, auditable, and consistent with reconciliation and correction workflows.

---

## 1. Core Design Principles

Export processing shall occur only after results are approved for release. Export units shall be traceable to payroll context and period. Transmission failures shall be retriable without duplicating delivered data. Successful exports shall not be retransmitted unintentionally.

## 2. Export Unit Definition

Export_ID\ 
Payroll_Context_ID\ 
Period_ID\ 
Pay_Date\ 
Export_Type\ 
Source_Run_ID\
Payroll_Run_Result_Set_ID\ 
Run_Scope_ID\
Export_Status\ 
Creation_Timestamp\ 
Prepared_By

## 3. Export Record Structure

Export_Record_ID\ 
Participant_ID\ 
Payable_Type\ 
Payable_Amount\ 
Currency_Code\ 
Pay_Date\ 
Payroll_Context_ID\ 
Period_ID\ 
External_Payroll_Code\ 
Record_Status\ 
Employee_Payroll_Result_ID (optional)\ 
Employment_ID (optional)\ 
Person_ID (optional)\ 
Net_Pay_Disbursement_ID (optional)

## 3.1 Export Source Lineage

Every export unit and export record shall preserve linkage to the governed payroll artifacts from which it was derived.

At minimum, export lineage may include:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID where worker-level traceability is required
- Net_Pay_Disbursement_ID where payment export is involved
- payable or liability reference where applicable

This ensures that downstream confirmations, rejections, adjustments, and reconciliation variances can be traced back to authoritative payroll execution outputs rather than to exported payloads alone.

## 4. Supported Export Formats

CSV, Fixed-Width Files, XML, JSON, Secure API Transmission, SFTP File Delivery. Export format selection shall be configurable per payroll context.

## 4.1 Export Type Classification

Export_Type defines the operational purpose of the outbound interface.

Supported export types may include:

- Payroll Provider Submission
- Net Pay Payment Export
- Statutory Remittance Export
- Benefit or Provider Export
- Garnishment Export
- Audit or Reconciliation Export
- Correction or Adjustment Export

Export type shall remain explicit because formatting, transport, approval, reconciliation, and retry rules may differ materially by export type.

## 5. Export Status Lifecycle

Prepared, Ready, Sent, Delivered, Failed, Retrying, Confirmed, Closed. Status transitions shall be recorded for audit and operational visibility.

## 6. Transmission Processing

Target system identification, secure authentication handling, transmission attempt logging, delivery acknowledgment capture, error detection and reporting. Transmission shall not occur without valid export readiness approval.

## 7. Retry and Recovery Handling

Retry behaviour shall address transient external failures. Retry attributes: Retry_Count, Last_Retry_Timestamp, Max_Retry_Limit, Retry_Status. Retries shall not duplicate successfully delivered records.

Retry and recovery handling shall distinguish between:

- retransmission of the same export unit
- generation of a corrected replacement export
- additive correction export associated with a later Payroll Run

These scenarios must remain explicitly distinguishable to prevent duplication, replay ambiguity, or reconciliation drift.

## 8. Idempotency Controls

Each export unit carries a fingerprint. Resubmission of an already-delivered export shall be detected and blocked. Idempotency keys include: Export_ID, Transmission_Fingerprint, Delivery_Confirmation_Reference.

Idempotency controls shall also preserve distinction between:

- original export
- retried transmission of the same export
- corrected replacement export
- additive follow-up export generated from a correction run

Replacement or additive exports must not be blocked incorrectly as duplicates when they are governed descendants of prior exported results.

## 9. Audit and Traceability

All transmission events shall be logged: attempt timestamp, response received, delivery status, actor. Export history shall remain permanently accessible.

Audit and traceability shall also preserve:

- Payroll_Run_Result_Set linkage
- Employee_Payroll_Result linkage where applicable
- Net_Pay_Disbursement linkage where applicable
- provider response linkage
- reconciliation linkage
- correction and rerun lineage

## 10. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Result_and_Payable_Model
- Net_Pay_and_Disbursement_Model
- Net_Pay_Disbursement_Data_Model
- Payroll_Provider_Response_Model
- Integration_and_Data_Exchange_Model
- Payroll_Reconciliation_Model
- Payroll_Exception_Model
- Payroll_Adjustment_and_Correction_Model
- General_Ledger_and_Accounting_Export_Model
- Correction_and_Immutability_Model
