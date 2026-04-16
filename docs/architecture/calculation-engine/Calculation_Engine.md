# 1. Purpose

The Calculation Engine is responsible for transforming approved source
transactions, configuration rules, rates, and effective-dated reference
data into calculated earnings, adjustments, balances, and explanatory
outputs.

Its purpose is not simply to produce a number. It must also produce
enough supporting detail to explain how the number was derived, why it
changed, and what inputs contributed to the result.

This is especially important for complex earnings such as commissions,
draws, recoveries, retroactive adjustments, and externally calculated
residual commissions.

# 2. Position in the Overall Model

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
• Calculated earning lines\
• Adjustments\
• Balance movements\
• Explanation text\
• Audit records\
• Payroll-ready outputs\
• Exceptions

# 3. Core Design Principle

The Calculation Engine supports a hybrid calculation model.

Some earnings are calculated internally using rules. Others are
calculated externally and loaded into the platform as approved results.

In both cases, sufficient structure must be retained to support payroll
delivery, auditability, reporting, and user explanation.

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
• Payroll export readiness

Out of Scope:\
• Extreme-scale optimization\
• AI-assisted rule authoring\
• Full dispute workflow\
• Advanced territory conflict logic

# 5. Functional Highlights

Key capabilities include:

• Calculation Run Management\
• Input Resolution\
• Rule Execution\
• External Result Support\
• Negative Result Handling\
• Retroactive Recalculation\
• Structured Output Generation\
• Full Audit Traceability

# 6. Non-Functional Requirements

• Deterministic accuracy\
• Full traceability\
• Idempotent reruns\
• Extensible rule model\
• Role-based security access

# 7. Data / Entity Concepts

Primary logical entities:

• Calculation Run\
• Calculation Result\
• Calculation Result Detail\
• Source Transaction\
• Participant\
• Plan Assignment\
• Rule Definition\
• Rate Table\
• Balance\
• External Calculation Import\
• Exception Record\
• Audit Record

# 8. Open Design Decisions

• Intermediate calculation persistence strategy\
• External result payload standards\
• Explanation text generation strategy\
• Negative payout handling policy\
• Result immutability definition\
• Simulation vs production structure
