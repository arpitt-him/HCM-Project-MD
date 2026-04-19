# Benefit_and_Deduction_Configuration_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Reviewed |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Benefit_and_Deduction_Configuration_Model.md` |
| **Domain** | Core |
| **Related Documents** | Eligibility_and_Enrollment_Lifecycle_Model, Earnings_and_Deductions_Computation_Model, Tax_Classification_and_Obligation_Model, Code_Classification_and_Mapping_Model, Provider_Billing_and_Charge_Model |

## Purpose

Defines configuration structures for employee benefits and deductions, including eligibility rules, employer and employee contributions, and tax treatment behaviours.

---

## 1. Scope of Benefits and Deductions

Supported configurable programs include: Health Insurance, Dental Insurance, Vision Insurance, Life Insurance, Disability Insurance, Retirement Plans (401k/Roth), Flexible Spending Accounts, Health Savings Accounts, Voluntary Benefits, Employer-Paid Benefits.

## 2. Core Benefit_or_Deduction_Plan Entity

Plan_ID, Plan_Name, Plan_Type, Organization_ID, Effective_Start_Date, Effective_End_Date, Status.
Plan_Type examples: HEALTH, DENTAL, VISION, RETIREMENT, INSURANCE, VOLUNTARY, STATUTORY.

## 3. Plan Component Structure

Plan_Component: Component_ID, Plan_ID, Component_Name, Contribution_Type, Tax_Treatment, Calculation_Method.
Contribution_Type examples: EMPLOYEE_CONTRIBUTION, EMPLOYER_CONTRIBUTION, MATCHING_CONTRIBUTION.

## 4. Contribution Definitions

Contribution_ID, Rate_Type, Contribution_Rate, Contribution_Limit, Contribution_Frequency.
Rate_Type examples: FIXED_AMOUNT, PERCENTAGE_OF_WAGES, MATCHING_FORMULA.

## 5. Eligibility Rules

Eligibility_ID, Plan_ID, Eligibility_Type, Eligibility_Criteria.
Examples: full-time status required, minimum service duration, department eligibility, location eligibility.

## 6. Enrollment Handling

Employee_Plan_Enrollment: Enrollment_ID, Employee_ID, Plan_ID, Enrollment_Date, Termination_Date, Coverage_Level.
Coverage_Level examples: EMPLOYEE_ONLY, EMPLOYEE_SPOUSE, EMPLOYEE_CHILDREN, FAMILY.

## 7. Tax Treatment Integration

Each benefit or deduction must specify tax handling: PRE_TAX, POST_TAX, NON_TAXABLE, IMPUTED_INCOME.
Example: Life Insurance may generate Imputed Income. 401k is a Pre-Tax Contribution.

## 8. Employer Contribution Handling

Employer-paid benefits generate employer financial obligations. Examples: Employer Health Contributions, Employer Life Insurance, Employer Retirement Matching. Employer contributions must route to billing and accounting models.

## 9. Deduction Scheduling

Deduction_Frequency and Payroll_Period_Association define when deductions occur.
Examples: every payroll, monthly, first payroll of month, special cycle deductions.

## 10. Plan Versioning and Governance

Plan_Version_Number, Effective_Date, Approval_Status, Change_Description. Historical plan definitions must remain available for audit and replay.

## 11. Relationship to Other Models

This model integrates with: Eligibility_and_Enrollment_Lifecycle_Model, Earnings_and_Deductions_Computation_Model, Tax_Classification_and_Obligation_Model, Code_Classification_and_Mapping_Model, Provider_Billing_and_Charge_Model, Payroll_Check_Model.
