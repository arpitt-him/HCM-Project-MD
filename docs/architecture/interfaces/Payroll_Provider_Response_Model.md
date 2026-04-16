Document Title: Payroll_Provider_Response_Model

Document Version: 0.1

Status: Draft

Last Updated: 2026-04-15

Description:

Defines the structure, lifecycle, and processing rules for inbound
responses from downstream payroll providers, including acknowledgments,
acceptance results, partial acceptance outcomes, rejections, and
response-to-export correlation.

# 1. Purpose

This document defines the inbound response model for downstream payroll
providers.

The Payroll Provider Response Model establishes how provider
acknowledgments, acceptance outcomes, rejection details, and partial
processing results are represented, validated, correlated, and used to
drive reconciliation and corrective workflows.

# 2. Core Design Principles

Provider response handling shall follow these principles:

• Every outbound export shall be eligible for a correlated inbound
provider response.\
• Provider responses shall be represented as first-class operational
records.\
• Responses shall be traceable to Export_ID and Payroll_Context_ID.\
• Partial acceptance and rejection outcomes shall remain visible and
auditable.\
• Provider responses shall trigger reconciliation, exception handling,
and corrective workflows where required.\
• Response handling shall support multi-client and multi-company
operation.

# 3. Response Scope

Provider responses may occur at multiple scopes.

Typical response scopes include:

• Export-level acknowledgment\
• Export-level acceptance or rejection\
• Record-level employee acceptance or rejection\
• Totals-level confirmation\
• Warning or advisory response

The model shall support representation of each scope independently and
in combination.

# 4. Provider Response Definition

A Provider Response represents an inbound message or file returned by
the payroll provider after export submission.

Recommended Provider_Response fields:

• Provider_Response_ID\
• Export_ID\
• Payroll_Context_ID\
• Provider_ID\
• Response_Type\
• Response_Status\
• Received_Timestamp\
• Provider_Reference_ID (optional)\
• Response_File_Name or Message_Reference (optional)\
• Client_ID (optional if applicable)\
• Company_ID (optional if applicable)

Provider responses represent authoritative downstream processing
feedback.

# 5. Response Type Classification

Provider responses shall be classified by type.

Typical Response_Type values include:

• Transmission Acknowledgment\
• Accepted\
• Rejected\
• Partially Accepted\
• Accepted with Warnings\
• Totals Confirmation\
• Error Detail Response

Classification supports correct operational routing and follow-up
behavior.

# 6. Response Status Model

Provider responses shall maintain lifecycle status.

Typical Response_Status values include:

• Received\
• Parsed\
• Validated\
• Matched\
• Variance Detected\
• Exception Raised\
• Closed

Status progression shall remain visible to operations and audit users.

# 7. Correlation to Export

Every provider response shall be correlated to an outbound export
whenever possible.

Primary correlation keys may include:

• Export_ID\
• Provider_Reference_ID\
• Payroll_Context_ID\
• Period_ID\
• Pay_Date\
• Transmission timestamp range

Unmatched responses shall be isolated for operational review and shall
not be silently discarded.

# 8. Record-Level Response Structure

Where provider responses include record-level outcomes, those outcomes
shall be represented explicitly.

Recommended Provider_Response_Record fields:

• Provider_Response_Record_ID\
• Provider_Response_ID\
• Employment_ID\
• Response_Record_Status\
• Provider_Payable_Code\
• Provider_Amount\
• Response_Reason_Code\
• Response_Reason_Description\
• Warning_Flag

Record-level response visibility supports targeted correction and
partial acceptance handling.

# 9. Totals-Level Response Structure

Where provider responses include summary totals, those totals shall be
represented explicitly.

Typical totals categories include:

• Employee count\
• Gross pay total\
• Tax totals\
• Deduction totals\
• Net pay total\
• Employer contribution totals

Totals-level responses support totals-first reconciliation workflows.

# 10. Acceptance and Rejection Handling

Provider responses may communicate full acceptance, full rejection, or
mixed outcomes.

Handling behaviors include:

• Fully accepted exports proceed to reconciliation closure flow.\
• Fully rejected exports enter correction and retransmission workflow.\
• Partially accepted exports preserve successful records while isolating
failed records.\
• Warning-only responses remain visible for operator review but may not
block closure depending on policy.

# 11. Partial Acceptance Model

Partial acceptance shall be supported as a first-class operating state.

Behavior includes:

• Accepted employee records remain valid.\
• Rejected employee records are isolated.\
• Rejected records may generate exception queue entries.\
• Corrective exports may be generated for failed records only.\
• Original provider response remains preserved for audit and
traceability.

# 12. Rejection Reason Handling

Provider rejection reasons shall be captured in structured form where
possible.

Typical rejection categories include:

• Invalid employee identifier\
• Invalid payable code\
• Invalid amount\
• Missing required field\
• Duplicate submission\
• Provider-side processing error\
• Regulatory validation failure

Structured rejection reasons support faster correction and trend
analysis.

# 13. Warning and Advisory Handling

Provider responses may contain warnings that do not constitute
rejection.

Typical warning scenarios include:

• Rounding adjustments\
• Non-blocking code translations\
• Informational processing notes\
• Secondary validation advisories

Warnings shall remain visible and auditable even when exports are
accepted.

# 14. Multi-Client and Multi-Company Support

Provider response handling shall support multi-client and multi-company
operation.

Required segmentation dimensions include:

• Client_ID\
• Company_ID\
• Payroll_Context_ID

Operational visibility and access shall be scoped appropriately so that
one client or company does not see another\'s provider response data
without authorization.

# 15. Response Parsing and Validation

Inbound responses shall be parsed and validated before they are
considered operationally usable.

Validation behaviors include:

• Confirm provider identity\
• Validate response format\
• Confirm correlation eligibility\
• Parse employee and totals data\
• Detect malformed or incomplete responses

Invalid provider responses shall enter exception handling workflows.

# 16. Interaction with Reconciliation

Provider responses are primary inputs to reconciliation.

Behavior includes:

• Totals-first comparison\
• Employee-level drilldown when variances exist\
• Exception generation for mismatches\
• Closure only after validated response handling

Reconciliation shall not rely on assumed acceptance when explicit
provider responses are expected.

# 17. Interaction with Correction and Immutability

Provider responses may trigger correction workflows.

Behavior includes:

• Rejected exports may require correction and retransmission\
• Partially accepted results may require targeted adjustments\
• Accepted responses do not permit silent overwrite of prior released
data\
• Corrective actions must preserve audit lineage

Provider response handling shall align with correction and immutability
rules.

# 18. Operational Visibility

Provider response activity shall be visible through operational
dashboards.

Typical visibility indicators include:

• Responses pending parsing\
• Responses awaiting reconciliation\
• Rejected exports\
• Partially accepted exports\
• Open provider-response exceptions\
• Aging unmatched responses

Visibility supports timely payroll recovery and completion.

# 19. Audit and Traceability

All provider response handling shall be auditable.

Required audit elements include:

• Provider response receipt\
• Parsing results\
• Correlation decisions\
• Status transitions\
• Exception creation\
• Reconciliation linkage\
• Correction linkage

Auditability supports payroll assurance and compliance transparency.

# 20. Key Design Principle

Outbound payroll export is only half of the provider interaction.

Provider responses complete the interface loop by confirming,
qualifying, or rejecting downstream payroll processing outcomes, and
must be modeled as authoritative operational inputs.
