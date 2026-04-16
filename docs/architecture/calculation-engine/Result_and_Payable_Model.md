# 1. Purpose

This document defines the structure and behavior of calculation results
and payable records produced by the payroll calculation engine.

The Result and Payable Model governs how calculated amounts are
summarized, stored, approved, released, and transmitted to payroll
processing systems. The model emphasizes summarized participant-level
payable values rather than detailed transaction-level commission
breakdowns.

# 2. Core Design Principles

The Result and Payable Model shall follow these principles:

• Payroll results shall be summarized at participant-period level.\
• Detailed upstream transactions (such as commissions) shall not be
expanded into payroll-level detail.\
• Each participant shall have one summarized payable result per earning
or deduction type per period.\
• Results shall align to payroll calendar context.\
• Results shall support approval, release, and adjustment workflows.\
• Payable records shall remain traceable to calculation runs and input
sources.

# 3. Result Record Definition

A Result Record represents a calculated summarized amount for a
participant within a payroll period.

Recommended Result Fields:

• Result_ID\
• Payroll_Context_ID\
• Period_ID\
• Participant_ID\
• Result_Type\
• Amount\
• Currency_Code\
• Source_Run_ID\
• Source_Batch_ID\
• Result_Status\
• Creation_Timestamp

Result records represent the summarized outputs of calculation
processing.

# 4. Result Granularity Rules

Results shall be summarized at the following minimum level:

Participant_ID + Result_Type + Period_ID

Only one active summarized result shall exist for each unique
combination.

Examples of Result_Type values:

• Regular Earnings\
• Commission Earnings\
• Bonus Earnings\
• Federal Tax\
• State Tax\
• Retirement Deduction\
• Employer Contribution

Detailed underlying transaction-level information shall remain in
upstream systems and shall not be expanded into payroll result detail.

# 5. Payable Record Definition

A Payable Record represents an approved result that is eligible for
payroll processing or payment.

Recommended Payable Fields:

• Payable_ID\
• Result_ID\
• Payroll_Context_ID\
• Period_ID\
• Participant_ID\
• Payable_Type\
• Payable_Amount\
• Pay_Date\
• Release_Status\
• Release_Timestamp

Payable records represent payment-ready outcomes derived from
calculation results.

# 6. Result Status Lifecycle

Result records shall move through defined lifecycle states.

Typical Result Status values:

• Calculated\
• Validated\
• Approved\
• Released\
• Adjusted\
• Superseded

Status transitions shall align with calculation run lifecycle stages.

# 7. Relationship to Accumulators

Results shall feed accumulator updates.

For each summarized result:

• Corresponding accumulator balances shall be updated.\
• Contribution history shall be recorded.\
• Accumulator updates shall follow recalculation and adjustment
policies.

Accumulators store persistent balances, while results represent
transactional outcomes.

# 8. Adjustment Handling

Adjustments to results shall follow defined recalculation and correction
policies.

Adjustment scenarios include:

• Prior-period correction\
• Supplemental payroll adjustment\
• Retroactive change\
• Policy-driven recalculation

Adjustments shall produce new result records or correction entries
rather than silently overwriting released results.

# 9. Partial Completion Behavior

When partial completion occurs:

• Successful participant results shall proceed through approval when
policy allows.\
• Failed participant results shall remain unresolved until corrected.\
• Payable creation shall include only successful results.\
• Exception records shall remain visible and actionable.

Partial completion shall not compromise result integrity.

# 10. External Payroll Interface Alignment

Payable records shall be structured to support integration with
downstream payroll systems.

Typical interface requirements include:

• Participant identifier mapping\
• Payable type mapping\
• Currency alignment\
• Pay-date consistency\
• Payroll system compatibility

Result formatting shall prioritize summarized payroll-ready values.

# 11. Audit and Traceability

Result and Payable records shall support full traceability.

Required audit relationships include:

• Result linked to Source_Run_ID\
• Result linked to Source_Batch_ID\
• Payable linked to Result_ID\
• Payable linked to Payroll_Context_ID\
• Adjustment linkage tracking

Audit traceability ensures payment verification and regulatory
compliance.

# 12. Performance Considerations

Result storage shall support efficient retrieval and reporting.

Design considerations include:

• Indexed participant-level queries\
• Efficient period-based retrieval\
• Controlled record growth\
• Fast lookup for payroll generation

Performance optimizations shall not compromise data correctness.

# 13. Key Design Principle

Payroll systems operate on summarized payable outcomes rather than
detailed transaction-level data.

The Result and Payable Model ensures that summarized participant-level
values are produced, approved, and delivered accurately while
maintaining alignment with calculation, accumulator, and payroll
lifecycle controls.
