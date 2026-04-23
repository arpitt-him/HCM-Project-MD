# Benefit_and_Deduction_Configuration_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Benefit_and_Deduction_Configuration_Model.md` |
| **Domain** | Core |
| **Related Documents** | Eligibility_and_Enrollment_Lifecycle_Model, Earnings_and_Deductions_Computation_Model, Tax_Classification_and_Obligation_Model, Code_Classification_and_Mapping_Model, Provider_Billing_and_Charge_Model |

## Purpose

Defines configuration structures for employee benefits and deductions, including eligibility rules, employer and employee contributions, tax treatment behaviours, and deduction scheduling.

This model governs how benefit and deduction configuration supplies payroll computation with the information needed to generate:

- deduction result lines
- employer contribution result lines
- tax treatment effects
- accumulator impacts
- remittance and billing obligations

Configuration must remain effective-dated, replay-safe, correction-capable, and auditable.

---

## 1. Scope of Benefits and Deductions

Supported configurable programs include: Health Insurance, Dental Insurance, Vision Insurance, Life Insurance, Disability Insurance, Retirement Plans (401k/Roth), Flexible Spending Accounts, Health Savings Accounts, Voluntary Benefits, Employer-Paid Benefits.

## 2. Core Benefit_or_Deduction_Plan Entity

Plan_ID, Plan_Name, Plan_Type, Organization_ID, Effective_Start_Date, Effective_End_Date, Status.
Plan_Type examples: HEALTH, DENTAL, VISION, RETIREMENT, INSURANCE, VOLUNTARY, STATUTORY.

Additional plan attributes may include:

Plan_Version_ID  
Jurisdiction_ID  
Payroll_Context_ID  
Eligibility_Profile_ID  
Remittance_Profile_ID  

These attributes support deterministic payroll consumption and downstream remittance behaviour.

## 3. Plan Component Structure

Plan_Component: Component_ID, Plan_ID, Component_Name, Contribution_Type, Tax_Treatment, Calculation_Method.
Contribution_Type examples: EMPLOYEE_CONTRIBUTION, EMPLOYER_CONTRIBUTION, MATCHING_CONTRIBUTION.

Additional component attributes may include:

Accumulator_Target  
Liability_Target  
Remittance_Relevance_Flag  
Export_Relevance_Flag  

These attributes support deterministic routing of benefit and deduction outcomes into payroll, remittance, and export workflows.

## 4. Contribution Definitions

Contribution_ID, Rate_Type, Contribution_Rate, Contribution_Limit, Contribution_Frequency.
Rate_Type examples: FIXED_AMOUNT, PERCENTAGE_OF_WAGES, MATCHING_FORMULA.

Contribution definitions shall remain effective-dated and historically available.

Historical contribution rates and limits must govern replay for the payroll periods in which they were effective.

Contribution changes must never silently redefine historical payroll outcomes.

## 5. Eligibility Rules

Eligibility_ID, Plan_ID, Eligibility_Type, Eligibility_Criteria.

Examples: full-time status required, minimum service duration, department eligibility, location eligibility.

Eligibility determination shall be resolved through governed rule execution using employee, employment, assignment, and payroll context.

Eligibility outcomes must remain traceable and replay-safe.

## 6. Enrollment Handling

Employee_Plan_Enrollment: Enrollment_ID, Employee_ID, Plan_ID, Enrollment_Date, Termination_Date, Coverage_Level.
Coverage_Level examples: EMPLOYEE_ONLY, EMPLOYEE_SPOUSE, EMPLOYEE_CHILDREN, FAMILY.

Enrollments shall remain effective-dated and traceable to the payroll periods in which they were active.

Payroll consumption of enrollment state must preserve linkage to:

- Enrollment_ID
- Plan_ID
- Employee_ID
- affected payroll periods

## 7. Tax Treatment Integration

Each benefit or deduction must specify tax handling: PRE_TAX, POST_TAX, NON_TAXABLE, IMPUTED_INCOME.
Example: Life Insurance may generate Imputed Income. 401k is a Pre-Tax Contribution.

Tax treatment definitions shall govern:

- deduction result-line classification
- employer contribution treatment
- taxable wage formation
- accumulator mutation
- downstream tax reporting relevance

Tax handling must remain consistent with Tax_Classification_and_Obligation_Model.

## 8. Employer Contribution Handling

Employer-paid benefits generate employer financial obligations.

Examples: Employer Health Contributions, Employer Life Insurance, Employer Retirement Matching.

Employer contributions must route to:

- payroll result generation
- liability creation
- remittance or provider billing workflows
- accounting export where applicable

Employer contribution outcomes must remain traceable to the governing plan component and contribution definition.

## 9. Deduction Scheduling

Deduction_Frequency and Payroll_Period_Association define when deductions occur.
Examples: every payroll, monthly, first payroll of month, special cycle deductions.

Deduction scheduling must remain traceable to Payroll_Calendar_Model and the governing payroll period in which a deduction is eligible to occur.

Scheduling rules must remain deterministic during replay and correction workflows.

## 10. Plan Versioning and Governance

Plan_Version_Number, Effective_Date, Approval_Status, Change_Description.

Historical plan definitions must remain available for audit, replay, and correction processing.

Version changes must preserve:

- prior configuration state
- corrected or future configuration state
- affected payroll periods where applicable
- downstream payroll and remittance consequences

## 10.1 Relationship to Payroll Execution Results

Benefit and deduction configuration does not itself constitute payroll output.

It defines the governed context from which payroll result lines are produced.

Relationship:

Benefit / Deduction Configuration
        ↓
Eligibility / Enrollment
        ↓
Payroll Computation
        ↓
Employee Payroll Result
        ├── Deduction Result Line
        └── Employer Contribution Result Line

This ensures payroll outputs remain traceable to the exact plan, component, contribution, and enrollment context active at execution time.

## 11. Relationship to Other Models

This model integrates with:

- Eligibility_and_Enrollment_Lifecycle_Model
- Employee_Assignment_Model
- Payroll_Context_Model
- Earnings_and_Deductions_Computation_Model
- Employee_Payroll_Result_Model
- Accumulator_Impact_Model
- Tax_Classification_and_Obligation_Model
- Code_Classification_and_Mapping_Model
- Payroll_Run_Funding_and_Remittance_Map
- Provider_Billing_and_Charge_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
