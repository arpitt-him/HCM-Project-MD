# Result_and_Payable_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
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
• Payroll_Run_Result_Set_ID\
• Result_Lineage_Sequence\
• Parent_Result_ID\
• Root_Result_ID\
• Source_Batch_ID\
• Result_Status\
• Creation_Timestamp\
• Run_Scope_ID\
• Scope_Type

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
• Release_Timestamp\
• Source_Result_Lineage_Sequence\
• Parent_Payable_ID\
• Root_Payable_ID

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

Accumulator updates shall reference:

- Accumulator_Definition_ID
- Accumulator_Impact_ID
- Result_Lineage_Sequence
- Source_Run_ID

Accumulator mutation shall remain traceable to the originating Result and Payable lineage.

Accumulator updates shall never occur without lineage traceability.

# 7. Adjustment and Correction Handling

Results may require adjustment after initial calculation.

Adjustment handling rules:

• Adjustments shall generate new result records, not overwrite existing ones.\
• Original results shall be marked Superseded.\
• Adjustment records shall carry linkage to superseded originals.\
• Accumulator corrections shall follow the Correction_and_Immutability_Model.

Adjustment-generated results shall:

- reference Parent_Result_ID
- inherit Root_Result_ID
- increment Result_Lineage_Sequence
- preserve Source_Run_ID lineage continuity

Superseded results shall remain queryable and auditable.

# 8. Result Lineage Model

Result records shall participate in governed lineage chains.

Each Result shall support:

- Parent_Result_ID
- Root_Result_ID
- Result_Lineage_Sequence
- Source_Run_ID lineage traceability

Result lineage supports:

- additive correction handling
- replay reconstruction
- supersession tracking
- audit lineage validation

Result lineage shall remain reconstructable across:

- correction runs
- replay operations
- partial recalculation sequences

# 9. Payable Release Controls

Payable records require explicit release authorization.

Release controls include:

• Approval workflow completion before release\
• Release authorization by designated role\
• Release timestamp and actor recorded\
• Released payables become available for transmission

Traceability shall also include:

- Payroll_Run_Result_Set linkage
- Run_Scope linkage
- Accumulator mutation linkage
- Result lineage chain reconstruction capability

# 10. Traceability Requirements

Every result and payable must be traceable to its origin.

Traceability links include:

• Source calculation run\
• Source batch or event\
• Input data snapshot\
• Rule versions applied\
• Approval chain

# 11. Deterministic Replay Requirements

Result and Payable generation shall remain deterministic across replay operations.

Replay shall:

- reconstruct identical Result records
- reconstruct identical Payable records
- preserve lineage continuity
- preserve accumulator mutation sequence

Later configuration or rule changes shall not reinterpret historical Result behavior.

# 12. Dependencies

This model depends on:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Run_Scope_Model
- Run_Lineage_Model
- Earnings_and_Deductions_Computation_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Accumulator_Model_Detailed
- Payroll_Adjustment_and_Correction_Model
- Correction_and_Immutability_Model

# 13. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Run_Scope_Model
- Run_Lineage_Model
- Earnings_and_Deductions_Computation_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Accumulator_Model_Detailed
- Payroll_Interface_and_Export_Model
- Payroll_Adjustment_and_Correction_Model
- Correction_and_Immutability_Model
- Code_Classification_and_Mapping_Model
