# Pay_Statement_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Reviewed |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/interfaces/Pay_Statement_Model.md` |
| **Domain** | Interfaces |
| **Related Documents** | DATA/Entity-Payroll-Item.md, Pay_Statement_Template_Model, Payroll_Check_Model, Accumulator_and_Balance_Model, Code_Classification_and_Mapping_Model, Multi_Context_Calendar_Model |

## Purpose

Defines the structure and content of employee pay statements generated from payroll checks. Ensures that payroll results are clearly presented to employees and aligned with financial, tax, and regulatory reporting requirements.

---

## 1. Core Pay_Statement Entity

Pay_Statement_ID, Payroll_Check_ID, Employee_ID, Employment_ID, Statement_Date, Pay_Date, Pay_Period_Start_Date, Pay_Period_End_Date, Calendar_Context_ID.

## 2. Earnings Section

Earnings_Line: Code, Description, Hours (optional), Rate (optional), Amount.
Examples: Regular Pay, Holiday Pay, Bonus Pay, Supplemental Earnings, Residual Commission.

## 3. Deductions Section

Deduction_Line: Code, Description, Amount, Deduction_Type.
Types: PRE_TAX, POST_TAX, VOLUNTARY, MANDATORY.

## 4. Tax Withholding Section

Tax_Line: Tax_Code, Tax_Description, Jurisdiction, Amount.
Examples: Federal Income Tax, State Income Tax, Medicare, Social Security.

## 5. Employer Contributions Section (Optional Display)

Contribution_Line: Code, Description, Amount.
Examples: Employer Benefits, Employer Payroll Taxes, Worker Compensation. Display is configurable per template.

## 6. Check Summary Totals

Gross_Earnings, Total_Deductions, Total_Taxes, Net_Pay. Optional: Employer_Total_Cost.

## 7. Payment Information

Payment_Method, Payment_Context, Payment_Reference.
Examples: Direct Deposit, Printed Check, Paycard, Off-Cycle Payment.

## 8. Year-to-Date (YTD) Values

YTD_Gross_Earnings, YTD_Taxes_Withheld, YTD_Deductions, YTD_Net_Pay. Aligned to appropriate tax calendar via Calendar_Context_ID.

## 9. Compliance and Messaging

Supports regulatory disclosures and employer messaging: tax notices, legal disclaimers, employer messages.

## 10. Relationship to Other Models

This model integrates with: Payroll_Check_Model, Pay_Statement_Template_Model, Code_Classification_and_Mapping_Model, Tax_Classification_and_Obligation_Model, Accumulator_and_Balance_Model, Multi_Context_Calendar_Model.
