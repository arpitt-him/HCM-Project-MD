# Posting_Rules_and_Mutation_Semantics

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Rules Domain |
| **Location** | `docs/rules/Posting_Rules_and_Mutation_Semantics.md` |
| **Domain** | Rules / Financial Mutation |
| **Related Documents** | Policy_and_Rule_Execution_Model, Rule_Resolution_Engine, Employee_Payroll_Result_Model, Payroll_Run_Result_Set_Model, Accumulator_Impact_Model, Payroll_Adjustment_and_Correction_Model, Payroll_Exception_Model, Net_Pay_and_Disbursement_Model, General_Ledger_and_Accounting_Export_Model |

## Purpose

Define how validated payroll execution results become durable financial postings, how postings mutate accumulators and liabilities, how corrections behave before and after pay date, and how replay is controlled.

This model governs the mutation boundary between:

- Payroll_Run_Result_Set
- Employee_Payroll_Result
- Accumulator_Impact
- liability creation
- remittance-eligible state
- downstream disbursement and accounting consequences

Posting is the moment at which validated payroll outcomes become durable financial state.

# Contents

> 1\. Core principles and architectural invariants
>
> 2\. Lifecycle: calculation, validation, posting, finalization
>
> 3\. Posting trigger classes
>
> 4\. Atomic transaction boundary
>
> 5\. Multi-posting transaction model
>
> 6\. Accumulator and liability mutation order
>
> 7\. Correction behavior relative to pay date
>
> 8\. Replay and review controls
>
> 9\. Finalization semantics
>
> 10\. Open questions and near-term follow-ons

# 1. Core principles and architectural invariants

> **Payroll postings shall occur only after validation has completed
> successfully.** Calculation results prior to validation are
> provisional and shall not mutate durable accumulator, liability,
> remittance, or journal state.
>
> **Posting transactions shall be atomic at the employee level within
> the context of a payroll run.** All postings associated with a single
> employee in a payroll run shall succeed or fail as a unit.
>
> **Postings shall preserve ledger separation.** Employee-funded
> amounts, employer-funded amounts, jurisdiction liabilities, provider
> liabilities, and remittance events shall remain independently
> attributable.
>
> **Correction behavior changes at the pay-date boundary.** Before pay
> date, the system may reverse and replace. After pay date, the system
> shall preserve historical postings and generate compensating
> corrective transactions.
>
> **Replay is controlled regeneration of financial state.** Replay is
> driven by source events, posting rules, mutation rules, and required
> review controls; it is not merely a recalculation routine.

# 2. Lifecycle: calculation, validation, posting, finalization

**Operating sequence.** The current model for a payroll result is:

**Input / Source Event → Calculation → Validation → Posting →
Finalization → Pay Date → Possible Correction → Replay / Review**

  -----------------------------------------------------------------------
  **Stage**         **Meaning**       **Mutates durable **Produces
                                      state?**          event?**
  ----------------- ----------------- ----------------- -----------------
  Calculation       Produces proposed No                Yes
                    payroll results                     
                    from approved and                   
                    effective inputs.                   

  Validation        Tests proposed    No                Yes
                    results against                     
                    data, policy, and                   
                    exception rules.                    

  Posting           Creates durable   Yes               Yes
                    accumulator,                        
                    liability, and                      
                    related financial                   
                    mutations.                          

  Finalization      Closes a          Status state      Yes
                    validated and                       
                    posted result for                   
                    ordinary                            
                    processing and                      
                    downstream                          
                    transmission.                       
  -----------------------------------------------------------------------

**Interpretation of finalization.** Finalization is not the moment of
posting. It is a later closure event that marks a payroll result ready
for payment, remittance scheduling, statement release, and downstream
transmission.

# 2.1 Relationship to Payroll Execution Results

Posting operates on governed payroll execution outputs.

Relationship:

Payroll_Run
        ↓
Payroll_Run_Result_Set
        ↓
Employee_Payroll_Result
        ↓
Posting Rules and Mutation Semantics
        ↓
Accumulator Impact / Liability / Financial State

Posting shall not occur from informal or partial calculation artifacts.

Posting requires validated and governed result structures so that durable mutations remain traceable to:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID
- Run_Scope_ID where applicable

# 3. Posting trigger classes

**Design rule.** Posting triggers are extensible, but every trigger
shall belong to a defined trigger class.

> **EarningCalculated ---** Regular earnings, supplemental earnings, and
> externally imported earnings accepted for payroll.
>
> **DeductionApplied ---** Employee deductions including pretax,
> after-tax, elective, and required deductions.
>
> **TaxComputed ---** Employee withholding and employer tax obligations.
>
> **EmployerContributionGenerated ---** Employer-funded benefit or
> retirement contributions.
>
> **BenefitContributionGenerated ---** Shared contribution flows that
> produce employee, employer, and carrier/provider postings.
>
> **RetroAdjustmentDetected ---** Changes discovered after prior
> calculation context or effective dating changes.
>
> **ManualAdjustmentApproved ---** Authorized payroll office or
> operations adjustment.
>
> **LiabilityGenerated ---** Obligations owed to jurisdictions,
> carriers, trustees, or providers.
>
> **RemittanceRecorded ---** Payment or settlement recorded against an
> existing liability.

Posting triggers shall remain traceable to governed source artifacts, including:

- Earnings Result Lines
- Deduction Result Lines
- Tax Result Lines
- Employer Contribution Result Lines
- Accumulator Impact-eligible mutation events
- Governed correction records

Trigger classes define mutation intent, but the originating payroll result artifacts must remain referenceable.

# 4. Atomic transaction boundary

**Atomic unit.** The atomic posting boundary is Employee + Payroll Run
Context.

**Rule.** All postings associated with a single employee within a
payroll run shall succeed or fail as a unit. This permits one employee's
posting set to fail without necessarily invalidating the entire employer
payroll batch.

> • **Implication:** A partially-posted employee result is invalid and
> must not persist.
>
> • **Implication:** Employee-level failure handling requires clear
> exception state and operational review queues.
>
> • **Implication:** Employer-wide totals are emergent results of
> completed employee posting sets, not the primary atomic unit.

Employee-level posting failures shall generate governed exception records consistent with Payroll_Exception_Model.

Exception records shall preserve:

- employee posting context
- originating result references
- failed mutation targets
- failure phase
- retry or review state

# 5. Multi-posting transaction model

**Principle.** A single validated payroll result may create multiple
durable postings. Examples include employee deduction, employer
contribution, taxable wage mutation, and resulting third-party
liability.

  -----------------------------------------------------------------
  **Example: Shared      Employee portion \$65; employer portion
  health contribution**  \$100; carrier liability \$165; pretax
                         employee portion also reduces relevant
                         taxable wage bases before tax calculation.
  ---------------------- ------------------------------------------

  -----------------------------------------------------------------

> • **Required behavior:** A single source transaction may create
> multiple postings, but those postings remain linked by shared lineage.
>
> • **Required behavior:** The originating trigger, employee context,
> payroll run context, and effective period must remain traceable across
> all resulting postings.
>
> • **Required behavior:** Ledger separation is preserved even when the
> postings arise from one calculation event.

# 6. Accumulator and liability mutation order

**Default ordering.** The initial operating order for a validated
employee posting set shall be:

> **1.** Create posting context and lineage metadata.
>
> **2.** Apply employee and employer contribution postings.
>
> **3.** Mutate taxable wage accumulators where pretax or exclusion
> rules apply.
>
> **4.** Post employee and employer tax results derived from the
> validated result.
>
> **5.** Generate resulting liabilities to jurisdictions, carriers,
> trustees, or providers.
>
> **6.** Record remittance-intent or remittance-eligible state where
> appropriate.
>
> **7.** Commit the employee posting set atomically.

**Reason for ordering.** Pretax deductions and exclusions must affect
taxable wage bases before taxes are posted. Liabilities are downstream
consequences of posted wages, deductions, and tax results.

Accumulator mutation shall be represented through governed Accumulator Impact records rather than through opaque balance updates alone.

Relationship:

Employee Payroll Result
        ↓
Posting Rule
        ↓
Accumulator Impact
        ↓
Accumulator Value / Liability State

This preserves mutation lineage, replayability, and correction traceability.

# 7. Correction behavior relative to pay date

**Governing distinction.** The pay-date boundary changes correction
semantics.

  -----------------------------------------------------------------------
  **Condition**           **Correction mode**     **Required system
                                                  behavior**
  ----------------------- ----------------------- -----------------------
  Correction identified   Pre-pay reversal mode   Reverse the original
  before pay date and                             posting set and apply
  before pay release                              the corrected posting
                                                  set. Preserve audit
                                                  trail and linkage to
                                                  the superseded result.

  Correction identified   Post-pay adjustment     Preserve historical
  after pay date or after mode                    postings. Generate
  pay release                                     compensating corrective
                                                  transactions and any
                                                  resulting liabilities,
                                                  offsets, or recovery
                                                  flows.
  -----------------------------------------------------------------------

> • **Never overwrite:** Original durable postings remain part of
> history.
>
> • **Pre-pay use case:** The system is correcting provisional or
> not-yet-paid reality.
>
> • **Post-pay use case:** The system is correcting historical financial
> reality and must therefore preserve prior postings.

All corrective posting behavior shall remain traceable through Payroll_Adjustment_and_Correction_Model.

This includes linkage between:

- original posting set
- reversal or replacement posting set
- compensating corrective posting set
- resulting accumulator, liability, disbursement, or accounting consequences

# 8. Replay and review controls

**Replay rule.** Replay is driven by source events, posting rules,
mutation rules, and required review controls. Replay is not solely a
recalculation operation.

> • **Replay inputs:** Effective-dated source events, approved
> configuration, payroll calendar context, posting rules, and mutation
> semantics.
>
> • **Review inputs:** Exception state, policy-defined review
> thresholds, operator approval requirements, and correction context.
>
> • **Expected outcome:** A controlled regeneration of financial state
> that is explainable, auditable, and legally defensible.

Replay must preserve the ability to reconstruct:

- original Payroll_Run_ID
- original Payroll_Run_Result_Set_ID
- original Employee_Payroll_Result_ID
- original mutation order
- exception state
- review state
- correction lineage where applicable

Replay is valid only if both the mutation semantics and the execution lineage remain reconstructable.

# 9. Finalization semantics

**Definition.** Finalization is the event that transitions a payroll
result from validated and posted status into a closed operational state
suitable for payment, remittance, and downstream transmission.

> • **Finalization is not posting.** Posting mutates durable financial
> state; finalization closes the result to ordinary mutation.
>
> • **Likely downstream actions:** Payment file generation, ACH or check
> preparation, statement release, journal export, remittance scheduling,
> and transmission preparation.
>
> • **Control effect:** Ordinary changes after finalization should
> require correction handling, not silent mutation.

Finalization may authorize downstream creation or release of:

- Net pay disbursement outputs
- Payroll interface and export outputs
- Remittance-eligible state
- General ledger and accounting exports

These downstream artifacts must remain traceable to the validated and posted payroll result that was finalized.

# 9.1 Relationship to Other Models

This model integrates with:

- Policy_and_Rule_Execution_Model
- Rule_Resolution_Engine
- Employee_Payroll_Result_Model
- Payroll_Run_Result_Set_Model
- Accumulator_Impact_Model
- Payroll_Exception_Model
- Payroll_Adjustment_and_Correction_Model
- Net_Pay_and_Disbursement_Model
- Payroll_Interface_and_Export_Model
- General_Ledger_and_Accounting_Export_Model
- Payroll_Reconciliation_Model

# 10. Open questions and near-term follow-ons

> • **Additional trigger classes:** More trigger classes will likely
> emerge as garnishments, net-pay distributions, off-cycle payroll, and
> employer billing are modeled.
>
> • **Pay release timestamp:** The design likely needs both PayDate and
> PayReleaseDate because legal payment timing and operational payment
> release may diverge.
>
> • **Batch-level controls:** Employee-level atomicity is the primary
> boundary, but employer-level batch certification and settlement
> controls may still be needed.
>
> • **Review model:** The system will need explicit review states,
> reviewers, and review-required conditions for replay and correction
> handling.
>
> • **Next artifact:** Posting Rules and Mutation Semantics should be
> followed by a dedicated document on correction processing, reversal
> mechanics, and retroactive adjustment strategy.
