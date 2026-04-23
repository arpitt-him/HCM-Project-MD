# Rule_Versioning_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Rules Domain |
| **Location** | docs/rules/Rule_Versioning_Model.md |
| **Domain** | Rules |
| **Related Documents** | Rule_Resolution_Engine.md, Rule_Pack_Model.md, Policy_and_Rule_Execution_Model.md, Jurisdiction_and_Compliance_Rules_Model.md, Jurisdiction_Registration_and_Profile_Data_Model.md |

## Purpose

The Rule Versioning Model defines the lifecycle structure governing
the creation, evolution, activation, and retirement of rule versions.

This model ensures:

- Deterministic payroll calculation behavior
- Historical replay accuracy
- Correction-safe rule transitions
- Full audit traceability across rule evolution
- Controlled activation through governed Rule Packs

Rule versioning is mandatory to preserve legal compliance,
jurisdictional correctness, and computational reproducibility.

## 1. Rule Identity Model

Defines the foundational identity attributes for each rule, ensuring
uniqueness, traceability, and governance alignment.\
\
Key Elements:\
- RuleID\
- RuleFamily\
- Jurisdiction\
- TaxType\
- RuleName\
- Description\
- CreatedDate\
- CreatedBy\
- RuleStatus

## 2. Rule Version Model

Each rule exists as one or more versions. Versions allow evolution over
time without destroying historical traceability.\
\
Key Elements:\
- RuleVersionID\
- RuleID\
- VersionNumber\
- EffectiveStartDate\
- EffectiveEndDate\
- IntroducedDate\
- SupersededByVersionID\
- ParentRuleVersionID\
- RootRuleVersionID\
- ReplacementReasonCode\
- LineageSequenceNumber\
- CorrectionEligibilityFlag\
- RuleVersionStatus\
- ActivationApprovalID\
- VersionNotes\
- RulePackID (or ContainingRulePackID)\
- ActivationContext\
- RuleSetReference\
- SourcePeriodID\
- ExecutionPeriodID\

## 3. Applicability Domain Model

Defines the context in which a rule applies. Overlapping effective dates
are permitted provided applicability domains do not conflict.\
\
Possible Applicability Dimensions:\
- Jurisdiction\
- EmployeeType\
- PaymentType\
- EarningType\
- WorkLocation\
- ResidencyStatus\
- SpecialConditions

## 4. Rule Pack Association Model

Rule versions are not independently executable.

A rule version becomes operational only when included
within an activated Rule Pack.

Each Rule Version shall support:

- ContainingRulePackID (optional)
- RuleActivationPriority
- RuleOverrideEligibilityFlag
- ConflictResolutionPolicy

Rule Pack association provides:

- Execution grouping
- Activation governance
- Override resolution
- Jurisdiction-specific packaging

Rule Version activation shall occur exclusively through
Rule Pack execution contexts.

## 5. Evaluation Basis Model

Specifies the basis used to determine when wages or transactions are
evaluated.\
\
Typical Evaluation Bases:\
- PAY_DATE\
- WORK_DATE\
- PAYMENT_AVAILABLE_DATE\
- ALLOCATION_DATE\
\
Each jurisdictional rule version must explicitly define its evaluation
basis.

## 6. Jurisdiction Independence Model

Rules must be independently defined per jurisdiction. Federal rules do
not implicitly govern state or local rules.\
\
Design Principle:\
Each jurisdiction may define:\
- What constitutes wages\
- When wages are considered paid\
- How withholding is calculated\
- How unemployment wages are allocated

## 7. Rule Validation Model

Automated validation ensures rule integrity and prevents structural
ambiguity.\
\
Validation Checks Include:\
- Ambiguity Detection\
- Coverage Gap Detection\
- Shadowed Rule Detection\
- Date Integrity Validation\
- Future Collision Forecasting

## 8. Severity Classification Model

Validation results are classified according to downstream operational
risk.\
\
Severity Levels:\
- CRITICAL: Blocks activation\
- HIGH: Requires review\
- MEDIUM: Advisory warning\
- LOW: Informational notice

## 9. Rule Impact Simulation (RIS) Model

Simulates payroll outcomes under different rule scenarios to detect
downstream impacts before activation.\
\
Simulation Characteristics:\
- Baseline Scenario vs Candidate Scenario\
- Hybrid Data Strategy (Sample + Full Population)\
- Intermediate Bucket Movement Comparison\
- Final Output Comparison\
- Cross-Jurisdiction Impact Analysis

## 10. Deterministic Replay Binding

All payroll executions shall bind to the exact
RuleVersionID active at the time of execution.

Replay operations shall:

- Use identical RuleVersionID values
- Use identical Evaluation Basis definitions
- Respect original Applicability Domains
- Ignore later superseding versions
  unless explicitly authorized

Rule version transitions shall never invalidate
previously executed payroll outcomes.

Replay determinism is a mandatory system guarantee.

## 11. Simulation Retention Model

Simulation results are retained according to policy and may be preserved
explicitly.\
\
Retention Logic:\
- Automatic retention assignment\
- User-adjustable retention period\
- Expiration-triggered deletion\
- Explicit preservation override\
- Logged deletion events

## 12. Scheduled Rule Health Monitoring

Recurring validation ensures rule stability over time.\
\
Recommended Schedule:\
- Nightly validation scans\
- Weekly forecast validation\
- Pre-payroll validation checks\
- Year-end expanded jurisdiction analysis

## 13. Relationship to Rule Packs

Rule versions may be grouped into Rule Packs for governed activation.

A rule version does not become executable merely by existing.
It becomes operational when activated through the appropriate Rule Pack and context.

## 14. Deterministic Replay Requirements

Historical payroll replay shall use the exact rule version active for the original execution context.
Later rule versions must not silently reinterpret historical payroll outcomes.

## 15. Relationship to Other Models

This model integrates with:

- Rule_Pack_Model
- Rule_Resolution_Engine
- Policy_and_Rule_Execution_Model
- Tax_Classification_and_Obligation_Model
- Posting_Rules_and_Mutation_Semantics
- Payroll_Run_Model
- Run_Lineage_Model
- Payroll_Adjustment_and_Correction_Model
- Configuration_and_Metadata_Management_Model