# Pay_Statement_Model

Version: v0.1

## 1. Purpose

Define the structure and content of employee pay statements generated
from payroll checks. This model ensures that payroll results are clearly
presented to employees and aligned with financial, tax, and regulatory
reporting requirements.

## 2. Core Pay_Statement Entity

Pay_Statement\
\
Pay_Statement_ID\
Payroll_Check_ID\
Employee_ID\
Employment_ID\
\
Statement_Date\
Pay_Date\
Pay_Period_Start_Date\
Pay_Period_End_Date\
\
Calendar_Context_ID

## 3. Earnings Section

Displays all earnings components.\
\
Earnings_Line fields:\
\
Code\
Description\
Hours (optional)\
Rate (optional)\
Amount\
\
Examples:\
\
Regular Pay\
Holiday Pay\
Bonus Pay\
Supplemental Earnings

## 4. Deductions Section

Displays employee deductions.\
\
Deduction_Line fields:\
\
Code\
Description\
Amount\
Deduction_Type\
\
Types include:\
\
PRE_TAX\
POST_TAX\
VOLUNTARY\
MANDATORY

## 5. Tax Withholding Section

Displays employee tax withholdings.\
\
Tax_Line fields:\
\
Tax_Code\
Tax_Description\
Jurisdiction\
Amount\
\
Examples:\
\
Federal Income Tax\
State Income Tax\
Medicare\
Social Security

## 6. Employer Contributions Section (Optional Display)

Some pay statements optionally display employer-paid contributions.\
\
Contribution_Line fields:\
\
Code\
Description\
Amount\
\
Examples:\
\
Employer Benefits\
Employer Payroll Taxes\
Worker Compensation

## 7. Check Summary Totals

Summary values displayed prominently:\
\
Gross_Earnings\
Total_Deductions\
Total_Taxes\
Net_Pay\
\
Optional:\
\
Employer_Total_Cost

## 8. Payment Information

Displays payment delivery details.\
\
Fields include:\
\
Payment_Method\
Payment_Context\
Payment_Reference\
\
Examples:\
\
Direct Deposit\
Printed Check\
Paycard\
Off-Cycle Payment

## 9. Year-to-Date (YTD) Values

Displays cumulative totals aligned to the appropriate tax calendar.\
\
Examples:\
\
YTD_Gross_Earnings\
YTD_Taxes_Withheld\
YTD_Deductions\
YTD_Net_Pay

## 10. Compliance and Messaging

Supports regulatory disclosures and employer messaging.\
\
Examples:\
\
Tax notices\
Legal disclaimers\
Employer messages

## 11. Relationship to Other Models

This model integrates with:\
\
Payroll_Check_Model\
Code_Classification_and_Mapping_Model\
Tax_Classification_and_Obligation_Model\
Accumulator_and_Balance_Model\
Multi_Context_Calendar_Model
