# Calculation_Engine

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/calculation-engine/Calculation_Engine.md` |
| **Domain** | Calculation Engine |
| **Related Documents** | PRD-400-Earnings-Model.md, ADR-002-Deterministic-Replayability.md, Earnings_and_Deductions_Computation_Model, Result_and_Payable_Model, External_Result_Import_Specification, Accumulator_and_Balance_Model |

## Purpose

Defines the core calculation framework responsible for transforming approved source transactions, configuration rules, rates, and effective-dated reference data into calculated earnings, adjustments, balances, and explanatory outputs. Supports both internally calculated and externally imported earnings through a hybrid model.

---

# 1. Position in the Overall Model

The Calculation Engine sits between upstream transaction/event intake
and downstream payroll consumption.

Inputs include:\
• Source transactions\
• Participant assignment data\
• Plan/rule/rate configuration\
• Effective-dated reference data\
• Period context\
• Prior balances\
• External calculated results

Outputs include:\
• Payroll_Run_Result_Set records\
• Employee_Payroll_Result records\
• Calculated earning, deduction, tax, and contribution result lines\
• Adjustment and correction-linked outputs\
• Accumulator impacts\
• Explanation text\
• Audit records\
• Payroll-ready payables and downstream outputs\
• Exceptions

---

# 2. Relationship to Payroll Execution Artifacts

The Calculation Engine does not produce ungoverned outputs.

Its execution shall be bound to governed payroll execution artifacts, including:

• Payroll_Run_ID\
• Payroll_Run_Result_Set_ID\
• Employee_Payroll_Result_ID\
• Run_Scope_ID where applicable\
• Source_Period_ID\
• Execution_Period_ID

The Calculation Engine shall produce outputs in a form that is traceable to the run, result set, employee result, and correction lineage through which the calculation occurred.

This ensures that calculated results remain replay-safe, correction-safe, and auditable.

---

# 3. Core Design Principle

The Calculation Engine supports a hybrid calculation model.

Some earnings are calculated internally using rules. Others are
calculated externally and loaded into the platform as approved results.

In both cases, sufficient structure must be retained to support payroll
delivery, auditability, reporting, and user explanation.

Regardless of origin, all calculation outcomes shall converge into the same governed result architecture, including result sets, employee payroll results, accumulator impacts, and downstream payable / export handling.

---

# 4. Scope for v0.1

In Scope:\
• Core calculation framework\
• Rule-driven internal calculations\
• Support for externally calculated results\
• Effective-dated rule resolution\
• Period-based calculation runs\
• Retro and adjustment handling\
• Negative result handling\
• Explanation text generation\
• Payroll export readiness\
• Payroll_Run_Result_Set production\
• Employee_Payroll_Result production\
• Accumulator impact generation\
• Lineage-aware correction support\
• Deterministic replay-safe execution

Out of Scope:\
• Extreme-scale optimization\
• AI-assisted rule authoring\
• Full dispute workflow\
• Advanced territory conflict logic

---

# 5. Functional Highlights

Key capabilities include:

• Calculation Run Management\
• Input Resolution\
• Rule Execution\
• External Result Support\
• Negative Result Handling\
• Retroactive Recalculation\
• Structured Result Set Generation\
• Employee Payroll Result Generation\
• Accumulator Impact Generation\
• Full Audit Traceability\
• Lineage-aware correction support

---

# 6. Non-Functional Requirements

• Deterministic accuracy\
• Full traceability\
• Idempotent reruns\
• Extensible rule model\
• Role-based security access\
• Deterministic replayability\
• Correction-safe additive behavior\
• Lineage-preserving result generation

---

# 7. Data / Entity Concepts

Primary logical entities:

• Payroll Run\
• Payroll Run Result Set\
• Employee Payroll Result\
• Result Line\
• Source Transaction\
• Participant / Employment\
• Plan Assignment\
• Rule Definition / Rule Pack\
• Rate Table\
• Accumulator Definition\
• Accumulator Impact\
• External Result Import\
• Payroll Exception\
• Audit Record\
• Payable

---

# 8. Deterministic Replay Requirements

The Calculation Engine shall produce replay-safe outputs.

Replay operations shall:

• use the original effective-dated rules, rates, and reference data\
• preserve Payroll_Run_ID and Payroll_Run_Result_Set lineage\
• preserve Employee_Payroll_Result lineage\
• preserve accumulator mutation ordering\
• preserve correction-linked additive behavior

Later configuration or rule changes shall not reinterpret historical calculation outcomes silently.

---

# 9. Open Design Decisions

• Intermediate calculation persistence strategy\
• External result payload standards\
• Explanation text generation strategy\
• Negative payout handling policy\
• Calculation-engine-specific immutability enforcement boundaries relative to governed payroll result artifacts\
• Simulation vs production structure

---

# 10. Relationship to Other Models

This model integrates with:

• Earnings_and_Deductions_Computation_Model\
• Result_and_Payable_Model\
• External_Result_Import_Specification\
• Payroll_Run_Model\
• Payroll_Run_Result_Set_Model\
• Employee_Payroll_Result_Model\
• Run_Scope_Model\
• Run_Lineage_Model\
• Accumulator_Definition_Model\
• Accumulator_Impact_Model\
• Payroll_Adjustment_and_Correction_Model\
• Correction_and_Immutability_Model\
• Rule_Resolution_Engine\
• Rule_Pack_Model

---

# 11. Dependencies

This model depends on:

• Payroll_Run_Model\
• Payroll_Run_Result_Set_Model\
• Employee_Payroll_Result_Model\
• Run_Scope_Model\
• Run_Lineage_Model\
• Rule_Resolution_Engine\
• Rule_Pack_Model\
• Accumulator_Definition_Model\
• Accumulator_Impact_Model\
• Correction_and_Immutability_Model