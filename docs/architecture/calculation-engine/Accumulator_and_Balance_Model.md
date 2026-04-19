# Accumulator_and_Balance_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md` |
| **Domain** | Calculation Engine |
| **Related Documents** | PRD-500-Accumulator-Strategy.md, ADR-002-Deterministic-Replayability.md, Result_and_Payable_Model, Payroll_Calendar_Model, Correction_and_Immutability_Model |

## Purpose

Defines the structure, behaviour, and lifecycle rules governing accumulators and balances within the payroll platform. Accumulators represent persisted payroll balances and their supporting contribution history, ensuring accurate payroll outcomes, rerun safety, and audit traceability.

---

# 1. Core Design Principles

The accumulator model shall follow these principles:

• Current balances and contribution history shall be stored separately.\
• Balances shall provide fast access to current values.\
• Contribution history shall preserve audit traceability.\
• Recalculation shall not cause participant values to be counted more
than once.\
• Reset and accumulation logic shall align with payroll calendar
periods.\
• Historical traceability shall remain intact after release.

# 2. Accumulator Balance Structure

Accumulator Balance records represent the current authoritative value
for a defined scope.

Recommended Balance Fields:

• Accumulator_ID\
• Scope_Type\
• Participant_ID (if applicable)\
• Employer_ID (if applicable)\
• Plan_ID (if applicable)\
• Period_Context\
• Current_Value\
• Last_Updated_Run_ID\
• Last_Update_Timestamp\
• Balance_Status

Balance records are optimized for quick lookup and update operations.

# 3. Accumulator Contribution History Structure

Contribution History records represent the individual calculation
effects that produced the current balance.

Recommended Contribution Fields:

• Contribution_ID\
• Accumulator_ID\
• Scope_Keys (Participant_ID, Employer_ID, etc.)\
• Source_Run_ID\
• Source_Batch_ID\
• Period_ID\
• Contribution_Amount\
• Contribution_Type\
• Before_Value (optional)\
• After_Value (optional)\
• Reason_Code\
• Creation_Timestamp

Contribution records provide traceability and reconstruction capability.

# 4. Accumulator Scope Types

Accumulators may operate at multiple scopes.

Common Scope Types:

• Participant-Level\
• Participant + Employer\
• Employer-Level\
• Regulatory-Level\
• Plan-Specific\
• Organizational-Level

Scope determines storage keys, reset logic, update eligibility, and retrieval behavior.

# 5. Time Dimensions

Accumulators operate across defined time dimensions.

Supported Dimensions:

• Current Period\
• Quarter-To-Date\
• Year-To-Date\
• Plan-Year\
• Lifetime\
• Custom Period Windows

Time alignment shall reference Payroll_Context_ID and Period_ID from the
Payroll Calendar Model.

# 6. Reset Rules

Accumulator reset behavior shall be explicitly defined.

Supported Reset Types:

• Calendar-Year Reset\
• Plan-Year Reset\
• Quarter Reset\
• No Reset\
• Conditional Reset

Reset logic shall execute at defined calendar boundaries and shall
preserve historical traceability.

# 7. Update Timing Rules

Accumulator updates occur during controlled lifecycle stages.

Update timing rules:

• Updates shall occur only after validation is complete.\
• Updates shall be atomic with the associated payroll result posting.\
• Partial updates shall not be permitted.\
• Updates shall reference the triggering run and period.

# 8. Rerun and Recalculation Safety

Accumulator design shall support safe recalculation.

Rerun safety requirements:

• Prior contribution history shall be retained.\
• Rerun contributions shall be clearly identified.\
• Net effect of rerun contributions shall be deterministic.\
• Double-counting shall be prevented through contribution tracking.

# 9. Correction Handling

Corrections may affect accumulator balances.

Correction behavior:

• Corrections shall generate reversal contribution records.\
• Reversal records shall clearly link to original contributions.\
• Net accumulator values shall reflect all corrections.\
• Correction history shall remain permanently auditable.

# 10. Accumulator Family Classification

Accumulators are organized into functional families.

Example families:

• Gross Wages\
• Pre-Tax Deductions\
• Post-Tax Deductions\
• Federal Tax Withheld\
• State Tax Withheld\
• Employer Tax Contributions\
• Benefit Contributions\
• Retirement Contributions\
• Garnishment Totals

Family classification supports reporting, compliance thresholds, and cross-scope validation.

# 11. Cross-Scope Validation

Accumulator integrity may be validated across scopes.

Validation examples:

• Employee YTD gross wages should reconcile to employer-level totals.\
• Jurisdiction-level tax accumulators should reconcile to employee tax contributions.\
• Plan-year benefit accumulators should reconcile to deduction history.

Cross-scope validation supports compliance and audit readiness.

# 12. Audit and Traceability

Accumulator systems shall support complete audit reconstruction.

Required audit capabilities:

• Track all balance changes\
• Track all contribution entries\
• Link contributions to runs and batches\
• Record timestamps and origin sources\
• Maintain historical continuity across recalculations

# 13. Performance Considerations

Balance and contribution separation supports performance optimization.

Balance records shall support fast lookup, minimal contention, and efficient update behavior. Contribution history shall support indexed retrieval, efficient filtering, and historical reconstruction. Performance tuning shall not compromise data integrity.

# 14. Key Design Principle

Accumulator balances represent current payroll state, while contribution
history represents how that state was produced.

Both shall be preserved independently to support correctness,
auditability, rerun safety, and long-term operational reliability.
