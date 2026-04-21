# Payroll_Provider_Response_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/interfaces/Payroll_Provider_Response_Model.md` |
| **Domain** | Interfaces |
| **Related Documents** | Payroll_Interface_and_Export_Model, Payroll_Reconciliation_Model, Exception_and_Work_Queue_Model, Correction_and_Immutability_Model, Run_Visibility_and_Dashboard_Model |

## Purpose

Defines the structure, lifecycle, and processing rules for inbound responses from downstream payroll providers, including acknowledgments, acceptance results, partial acceptance outcomes, rejections, and response-to-export correlation.

---

## 1. Core Design Principles

Every outbound export shall be eligible for a correlated inbound provider response. Provider responses shall be represented as first-class operational records. Responses shall be traceable to Export_ID and Payroll_Context_ID. Partial acceptance and rejection outcomes shall remain visible and auditable. Provider responses shall trigger reconciliation, exception handling, and corrective workflows where required.

Provider responses shall also remain traceable to the governed payroll execution outputs from which the corresponding export was derived.

Where applicable, lineage shall preserve:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID
- Run_Scope_ID

## 2. Response Scope

Export-level acknowledgment, export-level acceptance or rejection, record-level employee acceptance or rejection, totals-level confirmation, warning or advisory response. The model shall support representation of each scope independently and in combination.

## 3. Provider Response Definition

Provider_Response_ID, Export_ID, Payroll_Context_ID, Provider_ID, Response_Type, Response_Status, Received_Timestamp, Provider_Reference_ID (optional), Response_File_Name or Message_Reference (optional), Client_ID (optional), Company_ID (optional).

Additional lineage fields may include:

- Payroll_Run_ID (optional)
- Payroll_Run_Result_Set_ID (optional)
- Source_Period_ID (optional)
- Execution_Period_ID (optional)
- Run_Scope_ID (optional)

## 4. Response Type Classification

Transmission Acknowledgment, Accepted, Rejected, Partially Accepted, Accepted with Warnings, Totals Confirmation, Error Detail Response.

## 5. Response Status Model

Received, Parsed, Validated, Matched, Variance Detected, Exception Raised, Closed.

## 6. Correlation to Export

Primary correlation keys: Export_ID, Provider_Reference_ID, Payroll_Context_ID, Period_ID, Pay_Date, Transmission timestamp range. Unmatched responses shall be isolated for operational review and shall not be silently discarded.

Where available, correlation may also use:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Run_Scope_ID

These keys support more precise correlation in environments with:

- multiple exports per period
- additive correction exports
- scoped reruns
- partial-record retransmissions

## 6.1 Response Lineage Classification

Provider responses may relate to different export and correction scenarios.

Typical response-lineage patterns include:

- Original response to original export
- Response to retried transmission of the same export
- Response to corrected replacement export
- Response to additive follow-up export generated from a correction run
- Response to targeted partial-record correction export

These scenarios must remain explicitly distinguishable.

Provider response handling shall not treat all repeated or later responses as duplicates, because some responses may legitimately correspond to governed correction or adjustment activity.

## 7. Record-Level Response Structure

Provider_Response_Record_ID, Provider_Response_ID, Employment_ID, Response_Record_Status, Provider_Payable_Code, Provider_Amount, Response_Reason_Code, Response_Reason_Description, Warning_Flag.

Additional record-level lineage fields may include:

- Employee_Payroll_Result_ID (optional)
- Person_ID (optional)
- Net_Pay_Disbursement_ID (optional)

These fields support worker-level reconciliation, payment confirmation analysis, and targeted correction handling.

## 8. Totals-Level Response Structure

Employee count, gross pay total, tax totals, deduction totals, net pay total, employer contribution totals. Supports totals-first reconciliation workflows.

## 9. Acceptance and Rejection Handling

Fully accepted exports proceed to reconciliation closure. Fully rejected exports enter correction and retransmission workflow. Partially accepted exports preserve successful records while isolating failed records. Warning-only responses remain visible but may not block closure depending on policy.

## 10. Partial Acceptance Model

Accepted employee records remain valid. Rejected records are isolated and may generate exception queue entries. Corrective exports may be generated for failed records only. Original provider response is preserved for audit.

## 11. Rejection Reason Handling

Typical rejection categories: invalid employee identifier, invalid payable code, invalid amount, missing required field, duplicate submission, provider-side processing error, regulatory validation failure. Structured rejection reasons support faster correction and trend analysis.

## 12. Warning and Advisory Handling

Typical warning scenarios: rounding adjustments, non-blocking code translations, informational processing notes, secondary validation advisories. Warnings shall remain visible and auditable even when exports are accepted.

## 13. Multi-Client and Multi-Company Support

Segmentation dimensions: Client_ID, Company_ID, Payroll_Context_ID. One client or company shall not see another's provider response data without authorisation.

## 14. Response Parsing and Validation

Confirm provider identity, validate response format, confirm correlation eligibility, parse employee and totals data, detect malformed or incomplete responses. Invalid responses shall enter exception handling workflows.

## 15. Interaction with Reconciliation

Provider responses are primary inputs to reconciliation.

Reconciliation may operate at multiple levels, including:

- export-level confirmation
- totals-level comparison
- employee-level comparison
- disbursement-level comparison where payment confirmation is relevant

Reconciliation shall remain traceable to:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID where applicable
- Export_ID
- Provider_Response_ID

Typical reconciliation sequence:

- totals-first comparison
- employee-level drilldown when variances exist
- exception generation for mismatches
- correction initiation where required
- closure only after validated response handling

## 16. Interaction with Correction and Immutability

Rejected exports may require correction and retransmission. Partially accepted results may require targeted adjustments. Accepted responses do not permit silent overwrite of prior released data. Corrective actions must preserve audit lineage.

Corrective actions initiated from provider responses shall remain traceable through Payroll_Adjustment_and_Correction_Model.

This includes linkage between:

- original provider response
- detected variance or rejection
- corrective export or retransmission
- follow-up provider response
- final reconciliation closure

## 17. Operational Visibility

Typical dashboard indicators: responses pending parsing, responses awaiting reconciliation, rejected exports, partially accepted exports, open provider-response exceptions, aging unmatched responses.

## 18. Audit and Traceability

All provider response handling shall be auditable: response receipt timestamp, parsing outcomes, correlation decisions, reconciliation linkage, correction activity triggered, responsible user or system.

Audit and traceability shall also preserve:

- Payroll_Run_Result_Set linkage
- Employee_Payroll_Result linkage where applicable
- export lineage classification
- retransmission vs correction distinction
- exception linkage
- correction lineage
- final reconciliation outcome

## 19. Relationship to Other Models

This model integrates with:

- Payroll_Interface_and_Export_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Payroll_Reconciliation_Model
- Payroll_Exception_Model
- Payroll_Adjustment_and_Correction_Model
- Exception_and_Work_Queue_Model
- Correction_and_Immutability_Model
- Run_Visibility_and_Dashboard_Model
- Integration_and_Data_Exchange_Model