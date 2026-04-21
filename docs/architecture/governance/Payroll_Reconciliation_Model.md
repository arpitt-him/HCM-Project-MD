# Payroll_Reconciliation_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Compliance Domain |
| **Location** | `docs/architecture/governance/Payroll_Reconciliation_Model.md` |
| **Domain** | Governance |
| **Related Documents** | Payroll_Run_Model, Result_and_Payable_Model, Payroll_Interface_and_Export_Model, Correction_and_Immutability_Model, Exception_and_Work_Queue_Model |

## Purpose

Defines the reconciliation framework between payroll execution outputs, outbound payroll interfaces, downstream payroll provider responses, funding outcomes, remittance outcomes, and disbursement confirmations.

Ensures that payroll results produced by the platform are verified as:

- transmitted correctly
- accepted or rejected correctly
- funded correctly
- remitted correctly
- disbursed correctly
- corrected where mismatches occur

This model establishes reconciliation as the governed process by which run results are proven to align with external financial, provider, and settlement outcomes.

---

## 1. Core Design Principles

Every export shall require downstream confirmation. Exported data shall be verified against provider response data. Discrepancies shall be detected and logged. No payroll cycle shall be considered complete without reconciliation.

## 1.1 Reconciliation Anchors

Reconciliation shall be anchored to governed payroll execution outputs.

At minimum, reconciliation shall remain traceable to:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID where worker-level reconciliation is required
- Export_ID where external interface transmission occurs
- Provider_Response_ID where external provider confirmation exists

This ensures that reconciliation operates against authoritative payroll results rather than against exported payloads alone.

## 2. Reconciliation Lifecycle

Export Prepared → Export Transmitted → Provider Receives → Provider Processes → Provider Returns Response → Response Validated → Totals Reconciled → Exceptions Identified → Corrections Initiated → Payroll Cycle Closed.

## 3. Provider Response Handling

Response types: Accepted, Rejected, Partially Accepted, Accepted with Warnings. Provider responses shall be captured and linked to Export_ID.

## 4. Reconciliation Matching Criteria

Employment_ID matching, payable totals matching, employee counts matching, deduction totals matching, tax totals matching, net pay totals matching. Discrepancies shall be flagged immediately.

Additional matching criteria may include:

- Payroll_Run_Result_Set totals matching outbound totals
- employee payroll result totals matching provider-accepted employee records
- disbursement totals matching expected net pay outputs
- remittance totals matching expected liability outputs
- funding totals matching expected payroll funding requirements

## 4.1 Financial Reconciliation Dimensions

Reconciliation may occur across multiple outbound financial dimensions, including:

- payroll export reconciliation
- funding reconciliation
- remittance reconciliation
- net pay disbursement reconciliation
- provider settlement reconciliation

Examples include:

- funded amount vs expected run liability
- remitted amount vs expected statutory liability
- employee disbursement total vs expected net pay total
- returned or rejected payments vs expected completed payments
- provider-accepted totals vs platform-produced totals

These reconciliation dimensions may share source results, but they must remain explicitly distinguishable.

## 5. Reconciliation Status Model

Pending, In Progress, Matched, Variance Detected, Correction Required, Corrected, Verified, Closed.

## 6. Variance Detection

Variance types: amount mismatch, missing employee record, unexpected employee record, tax mismatch, deduction mismatch, net pay mismatch.  Each variance shall generate a governed reconciliation exception record consistent with Payroll_Exception_Model, preserving linkage to the originating Payroll Run, Payroll Run Result Set, exported data, and downstream response or settlement record.

## 7. Exception Resolution Workflow

Exception detected → logged → root cause identified → correction method selected → adjustment calculated → correction executed → reconciliation repeated → exception closed. All steps shall remain auditable.

Correction activity initiated through reconciliation shall remain traceable through Payroll_Adjustment_and_Correction_Model.

Reconciliation shall preserve explicit linkage between:

- detected variance
- selected correction method
- executed adjustment or correction
- replacement or follow-up reconciliation outcome

## 8. Audit and Traceability

All reconciliation actions shall record: reconciliation run reference, matched and unmatched records, variance amounts, correction linkage, responsible user, timestamps.

Audit and traceability shall also preserve:

- Payroll_Run_Result_Set linkage
- Employee_Payroll_Result linkage where applicable
- Funding outcome linkage
- Remittance outcome linkage
- Net pay disbursement linkage
- provider response linkage
- correction and rerun lineage

## 9. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Payroll_Run_Funding_and_Remittance_Map
- Net_Pay_and_Disbursement_Model
- Payroll_Interface_and_Export_Model
- Payroll_Provider_Response_Model
- Payroll_Exception_Model
- Payroll_Adjustment_and_Correction_Model
- Correction_and_Immutability_Model
- Exception_and_Work_Queue_Model
- Accumulator_Impact_Model

