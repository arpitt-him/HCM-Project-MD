# Pay_Statement_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
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

Additional governed attributes may include:

- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID
- Statement_Template_ID
- Statement_Render_Version
- Statement_Status
- Parent_Pay_Statement_ID where corrected or reissued
- Root_Pay_Statement_ID

## 2. Relationship to Payroll Execution Artifacts

Pay statements shall be rendered from governed payroll execution artifacts rather than treated as primary financial records.

Pay statement generation shall remain traceable to:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID
- Payroll_Check_ID
- Run_Scope_ID where applicable

Pay statements do not define payroll truth.

They are employee-facing presentation artifacts derived from governed result, payable, payment, and accumulator state.

## 3. Earnings Section

Earnings_Line: Code, Description, Hours (optional), Rate (optional), Amount.
Examples: Regular Pay, Holiday Pay, Bonus Pay, Supplemental Earnings, Residual Commission.

Earnings lines shall be derived from governed payroll result lines and not independently keyed by free-form presentation logic.

## 4. Deductions Section

Deduction_Line: Code, Description, Amount, Deduction_Type.
Types: PRE_TAX, POST_TAX, VOLUNTARY, MANDATORY.

Deduction lines shall be derived from governed payroll result lines and related code classification semantics.

## 5. Tax Withholding Section

Tax_Line: Tax_Code, Tax_Description, Jurisdiction, Amount.
Examples: Federal Income Tax, State Income Tax, Medicare, Social Security.

Tax lines shall be derived from governed tax result lines and jurisdiction-aware tax classification definitions.

## 6. Employer Contributions Section (Optional Display)

Contribution_Line: Code, Description, Amount.
Examples: Employer Benefits, Employer Payroll Taxes, Worker Compensation. Display is configurable per template.

## 7. Check Summary Totals

Gross_Earnings, Total_Deductions, Total_Taxes, Net_Pay. Optional: Employer_Total_Cost.

## 8. Payment Information

Payment_Method, Payment_Context, Payment_Reference.
Examples: Direct Deposit, Printed Check, Paycard, Off-Cycle Payment.

## 9. Statement Correction and Reissue

Pay statements may require corrected or replacement rendering when underlying payroll artifacts are corrected.

Corrected or reissued statements shall:

- preserve linkage to the original Pay_Statement_ID
- preserve linkage to the corrected Payroll_Run_Result_Set_ID and Employee_Payroll_Result_ID
- remain historically distinguishable from prior rendered statements
- avoid destructive replacement of prior employee-visible statement history where governance requires preservation

Statement correction behavior shall align with Correction_and_Immutability_Model.

## 10. Year-to-Date (YTD) Values

YTD values shall be derived from governed accumulator state rather than independently maintained statement totals.

Examples include:

- YTD_Gross_Earnings
- YTD_Taxes_Withheld
- YTD_Deductions
- YTD_Net_Pay

YTD interpretation shall align to the appropriate governed calendar context and accumulator definitions.

Pay statement YTD values must remain traceable to:

- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Multi_Context_Calendar_Model

## 11. Compliance and Messaging

Supports regulatory disclosures and employer messaging: tax notices, legal disclaimers, employer messages.

## 12. Deterministic Statement Rendering

Pay statement rendering shall remain deterministic for a given governed payroll state.

Given identical:

- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID
- Payroll_Check_ID
- Statement template version
- accumulator state
- calendar context

the platform shall produce the same pay statement output.

Later template or configuration changes shall not silently reinterpret historical pay statements.

## 13. Dependencies

This model depends on:

- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Payroll_Check_Model
- Pay_Statement_Template_Model
- Code_Classification_and_Mapping_Model
- Tax_Classification_and_Obligation_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Multi_Context_Calendar_Model
- Correction_and_Immutability_Model

## 14. Relationship to Other Models

This model integrates with:

- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Payroll_Check_Model
- Pay_Statement_Template_Model
- Code_Classification_and_Mapping_Model
- Tax_Classification_and_Obligation_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Multi_Context_Calendar_Model
- Result_and_Payable_Model
- Correction_and_Immutability_Model
