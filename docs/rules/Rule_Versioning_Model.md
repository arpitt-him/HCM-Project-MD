# Rule Versioning Model --- Draft v0.1

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
- VersionNotes

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

## 4. Evaluation Basis Model

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

## 5. Jurisdiction Independence Model

Rules must be independently defined per jurisdiction. Federal rules do
not implicitly govern state or local rules.\
\
Design Principle:\
Each jurisdiction may define:\
- What constitutes wages\
- When wages are considered paid\
- How withholding is calculated\
- How unemployment wages are allocated

## 6. Rule Validation Model

Automated validation ensures rule integrity and prevents structural
ambiguity.\
\
Validation Checks Include:\
- Ambiguity Detection\
- Coverage Gap Detection\
- Shadowed Rule Detection\
- Date Integrity Validation\
- Future Collision Forecasting

## 7. Severity Classification Model

Validation results are classified according to downstream operational
risk.\
\
Severity Levels:\
- CRITICAL: Blocks activation\
- HIGH: Requires review\
- MEDIUM: Advisory warning\
- LOW: Informational notice

## 8. Rule Impact Simulation (RIS) Model

Simulates payroll outcomes under different rule scenarios to detect
downstream impacts before activation.\
\
Simulation Characteristics:\
- Baseline Scenario vs Candidate Scenario\
- Hybrid Data Strategy (Sample + Full Population)\
- Intermediate Bucket Movement Comparison\
- Final Output Comparison\
- Cross-Jurisdiction Impact Analysis

## 9. Simulation Retention Model

Simulation results are retained according to policy and may be preserved
explicitly.\
\
Retention Logic:\
- Automatic retention assignment\
- User-adjustable retention period\
- Expiration-triggered deletion\
- Explicit preservation override\
- Logged deletion events

## 10. Scheduled Rule Health Monitoring

Recurring validation ensures rule stability over time.\
\
Recommended Schedule:\
- Nightly validation scans\
- Weekly forecast validation\
- Pre-payroll validation checks\
- Year-end expanded jurisdiction analysis
