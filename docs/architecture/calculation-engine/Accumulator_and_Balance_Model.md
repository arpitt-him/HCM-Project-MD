# Accumulator_and_Balance_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md` |
| **Domain** | Calculation Engine |
| **Related Documents** | PRD-500-Accumulator-Strategy.md, ADR-002-Deterministic-Replayability.md, Result_and_Payable_Model, Payroll_Calendar_Model, Correction_and_Immutability_Model |

## Purpose

## Purpose

Defines the structure, behaviour, and lifecycle rules governing persisted accumulator values and their historical mutation history within the payroll platform.

This model represents the runtime balance/value layer of accumulator behavior.

Accumulator meaning is governed by `Accumulator_Definition_Model`.
Accumulator mutation is governed by `Accumulator_Impact_Model`.
This model governs the persisted balance state and the historical records needed to reconstruct that state.

The model ensures accurate payroll outcomes, rerun safety, correction traceability, replay accuracy, and audit defensibility.

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

# 2. Relationship to Definition and Impact Models

Accumulator runtime behavior is governed through three distinct layers:

```text
Accumulator Definition
    ↓
Accumulator Impact
    ↓
Accumulator Balance / Value
```

# 3. Accumulator Balance Structure

Accumulator Balance records represent the current authoritative persisted value for a governed accumulator definition at a defined scope.

Recommended Balance Fields:

• Accumulator_Balance_ID\
• Accumulator_Definition_ID\
• Scope_Type\
• Scope_Keys\
• Current_Value\
• Source_Period_ID where applicable\
• Execution_Period_ID where applicable\
• Last_Updated_Run_ID\
• Last_Updated_Result_Set_ID\
• Last_Update_Timestamp\
• Balance_Status

Balance records are optimized for quick lookup and update operations.

Balance records do not define accumulator meaning independently; they persist the current state of a governed accumulator definition.

# 4. Accumulator Contribution History Structure

Contribution History records represent persisted historical balance-affecting entries derived from governed accumulator impacts.

Recommended Contribution Fields:

• Contribution_ID\
• Accumulator_Definition_ID\
• Accumulator_Impact_ID\
• Scope_Keys\
• Source_Run_ID\
• Source_Result_Set_ID\
• Source_Employee_Result_ID where applicable\
• Source_Batch_ID where applicable\
• Source_Period_ID\
• Execution_Period_ID\
• Contribution_Amount\
• Contribution_Type\
• Before_Value (optional)\
• After_Value (optional)\
• Reason_Code\
• Creation_Timestamp

Contribution records provide traceability and reconstruction capability.

Contribution history shall remain derived from governed accumulator impacts rather than acting as an independent mutation model.

# 5. Accumulator Scope Types

Accumulators may operate at multiple scopes.

Common Scope Types:

• Participant-Level\
• Participant + Employer\
• Employer-Level\
• Regulatory-Level\
• Plan-Specific\
• Organizational-Level

Scope determines storage keys, reset logic, update eligibility, and retrieval behavior.

# 6. Time Dimensions

Accumulators operate across defined time dimensions.

Supported Dimensions:

• Current Period\
• Quarter-To-Date\
• Year-To-Date\
• Plan-Year\
• Lifetime\
• Custom Period Windows

Time alignment shall reference governed calendar context, including Payroll_Context_ID, Period_ID, and the applicable calendar interpretation defined through Payroll_Calendar_Model and Multi_Context_Calendar_Model.

# 7. Reset Rules

Accumulator reset behavior shall be explicitly defined.

Supported Reset Types:

• Calendar-Year Reset\
• Plan-Year Reset\
• Quarter Reset\
• No Reset\
• Conditional Reset

Reset logic shall execute at defined calendar boundaries and shall
preserve historical traceability.

# 8. Update Timing Rules

Accumulator updates occur during controlled lifecycle stages.

Update timing rules:

• Updates shall occur only after validation is complete.\
• Updates shall be atomic with the associated payroll result posting.\
• Partial updates shall not be permitted.\
• Updates shall reference the triggering run and period.

Accumulator updates shall remain traceable to:

• Payroll_Run_ID\
• Payroll_Run_Result_Set_ID\
• Employee_Payroll_Result_ID where applicable\
• Accumulator_Impact_ID

# 9. Rerun and Recalculation Safety

Accumulator design shall support safe recalculation.

Rerun safety requirements:

• Prior contribution history shall be retained.\
• Rerun contributions shall be clearly identified.\
• Net effect of rerun contributions shall be deterministic.\
• Double-counting shall be prevented through contribution tracking.

Rerun and recalculation behavior shall preserve source lineage between original and rerun-derived accumulator effects.

Historical rerun behavior shall remain reconstructable through run, result-set, and accumulator-impact lineage.

# 10. Correction Handling

Corrections may affect accumulator balances.

Correction behavior:

• Corrections shall generate reversal contribution records.\
• Reversal records shall clearly link to original contributions.\
• Net accumulator values shall reflect all corrections.\
• Correction history shall remain permanently auditable.

Correction-linked accumulator behavior shall preserve linkage to:

• original accumulator impact\
• original payroll result lineage\
• correction-generated payroll result lineage\
• resulting balance state

# 11. Accumulator Family Classification

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

# 12. Cross-Scope Validation

Accumulator integrity may be validated across scopes.

Validation examples:

• Employee YTD gross wages should reconcile to employer-level totals.\
• Jurisdiction-level tax accumulators should reconcile to employee tax contributions.\
• Plan-year benefit accumulators should reconcile to deduction history.

Cross-scope validation supports compliance and audit readiness.

# 13. Deterministic Replay Requirements

Accumulator balance reconstruction shall remain deterministic.

Given identical:

• Accumulator_Definition_ID\
• scope context\
• accumulator impacts\
• source payroll execution lineage\
• applicable calendar state

the platform shall reconstruct the same balance state and contribution history.

Later rule, configuration, or calendar changes shall not silently reinterpret historical accumulator state.

# 14. Audit and Traceability

Accumulator systems shall support complete audit reconstruction.

Required audit capabilities:

• Track all balance changes\
• Track all contribution entries\
• Link contributions to runs and batches\
• Record timestamps and origin sources\
• Maintain historical continuity across recalculations

# 15. Performance Considerations

Balance and contribution separation supports performance optimization.

Balance records shall support fast lookup, minimal contention, and efficient update behavior. Contribution history shall support indexed retrieval, efficient filtering, and historical reconstruction. Performance tuning shall not compromise data integrity.

# 16. Relationship to Other Models

This model integrates with:

• Accumulator_Definition_Model\
• Accumulator_Impact_Model\
• Payroll_Run_Model\
• Payroll_Run_Result_Set_Model\
• Employee_Payroll_Result_Model\
• Result_and_Payable_Model\
• Payroll_Calendar_Model\
• Multi_Context_Calendar_Model\
• Payroll_Adjustment_and_Correction_Model\
• Correction_and_Immutability_Model\
• Regulatory_and_Compliance_Reporting_Model

# 17. Dependencies

This model depends on:

• Accumulator_Definition_Model\
• Accumulator_Impact_Model\
• Payroll_Run_Model\
• Payroll_Run_Result_Set_Model\
• Employee_Payroll_Result_Model\
• Payroll_Calendar_Model\
• Multi_Context_Calendar_Model\
• Payroll_Adjustment_and_Correction_Model\
• Correction_and_Immutability_Model

# 18. Key Design Principle

Accumulator balances represent current persisted accumulator state, while contribution history represents how that state was produced.

Accumulator meaning is governed separately through `Accumulator_Definition_Model`.
Accumulator mutation is governed separately through `Accumulator_Impact_Model`.

All three layers shall remain distinct and independently preservable to support correctness, auditability, rerun safety, correction traceability, and long-term operational reliability.
