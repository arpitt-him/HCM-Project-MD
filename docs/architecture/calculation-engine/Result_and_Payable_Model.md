# Result_and_Payable_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/calculation-engine/Result_and_Payable_Model.md` |
| **Domain** | Calculation Engine |
| **Related Documents** | DATA/Entity-Payroll-Item.md, ADR-002-Deterministic-Replayability.md, Calculation_Engine, Earnings_and_Deductions_Computation_Model, Accumulator_and_Balance_Model, Payroll_Run_Model, Correction_and_Immutability_Model |

## Purpose

Defines the structure and behaviour of calculation results and payable records produced by the payroll calculation engine. Governs how calculated amounts are summarised, stored, approved, released, and transmitted to payroll processing systems.

---

# 1. Core Design Principles

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

# 2. Result Record Definition

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

# 3. Result Granularity Rules

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

# 4. Payable Record Definition

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

# 5. Result Status Lifecycle

Result records shall move through defined lifecycle states.

Typical Result Status values:

• Calculated\
• Validated\
• Approved\
• Released\
• Adjusted\
• Superseded

Status transitions shall align with calculation run lifecycle stages.

# 6. Relationship to Accumulators

Results shall feed accumulator updates.

For each summarized result:

• Corresponding accumulator balances shall be updated.\
• Contribution history shall be recorded.\
• Accumulator updates shall follow recalculation and adjustment
policies.

Accumulators store persistent balances, while results represent
transactional outcomes.

# 7. Adjustment and Correction Handling

Results may require adjustment after initial calculation.

Adjustment handling rules:

• Adjustments shall generate new result records, not overwrite existing ones.\
• Original results shall be marked Superseded.\
• Adjustment records shall carry linkage to superseded originals.\
• Accumulator corrections shall follow the Correction_and_Immutability_Model.

# 8. Payable Release Controls

Payable records require explicit release authorization.

Release controls include:

• Approval workflow completion before release\
• Release authorization by designated role\
• Release timestamp and actor recorded\
• Released payables become available for transmission

# 9. Traceability Requirements

Every result and payable must be traceable to its origin.

Traceability links include:

• Source calculation run\
• Source batch or event\
• Input data snapshot\
• Rule versions applied\
• Approval chain

# 10. Relationship to Other Models

This model integrates with:\
\
Calculation_Engine\
Accumulator_and_Balance_Model\
Payroll_Run_Model\
Payroll_Check_Model\
Payroll_Interface_and_Export_Model\
Correction_and_Immutability_Model\
Code_Classification_and_Mapping_Model
