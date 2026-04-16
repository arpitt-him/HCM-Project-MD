# Code_Classification_and_Mapping_Model

Version: v0.1

## 1. Purpose

Define how external payroll and billing codes are classified into
canonical internal result types. This model ensures consistent
interpretation of earnings, deductions, taxes, contributions, imputed
income, and invoice-related charges across all integrations.

## 2. External Code Sources

External payroll and billing providers supply coded result lines such
as:\
\
Code_Type\
Code\
Code_Description\
\
Examples observed:\
\
Earn\
DED-P\
DED-N\
Dedu\
ConB\
TaxU\
ImpI\
Invoice_Level_Charges

## 3. Canonical Result Classes

All external codes are mapped into canonical internal classes:\
\
EARNING\
DEDUCTION_PRE_TAX\
DEDUCTION_POST_TAX\
EMPLOYER_CONTRIBUTION\
TAX_WITHHOLDING\
IMPUTED_INCOME\
INVOICE_CHARGE\
ADJUSTMENT

## 4. Canonical Classification Attributes

Each mapped code must define:\
\
Canonical_Result_Class\
Tax_Treatment\
Actor (Employee / Employer)\
Cash_Impact (Yes / No)\
Taxable_Impact (Yes / No)\
Accumulator_Target\
Calculation_Mode

## 5. Calculation Modes

Supported calculation behaviors include:\
\
HOURLY\
Amount = Hours × Rate\
\
FIXED\
Amount is provided directly\
\
PERCENTAGE\
Amount derived from base value\
\
DERIVED\
Amount determined via rule or table\
\
REFERENCE\
Informational only

## 6. Tax Treatment Types

Tax treatment must be explicitly defined:\
\
PRE_TAX\
POST_TAX\
NON_TAXABLE\
TAXABLE_NON_CASH\
STATUTORY_EMPLOYER

## 7. Accumulator Routing

Each canonical result class routes to specific accumulators.\
\
Examples:\
\
EARNING → Gross Wages\
DEDUCTION_PRE_TAX → Pre-Tax Deduction Totals\
TAX_WITHHOLDING → Federal or State Tax Totals\
IMPUTED_INCOME → Taxable Wage Accumulators\
EMPLOYER_CONTRIBUTION → Employer Liability Totals\
INVOICE_CHARGE → Employer Invoice Totals

## 8. External-to-Canonical Mapping Examples

Sample mappings based on observed datasets:\
\
Earn / REG → EARNING\
DED-P / 4KROTH → DEDUCTION_PRE_TAX\
DED-N / AET005 → DEDUCTION_POST_TAX\
ConB / FICA-M → EMPLOYER_CONTRIBUTION\
TaxU / FWT → TAX_WITHHOLDING\
ImpI / LIFEX → IMPUTED_INCOME\
Invoice_Level_Charges / Service Fee → INVOICE_CHARGE

## 9. Mapping Governance

Mappings must be versioned and auditable.\
\
Each mapping record should include:\
\
Source_System\
Code_Type\
Code\
Canonical_Result_Class\
Effective_Date\
Expiration_Date\
Version_Number\
Approval_Status

## 10. Error Handling and Unknown Codes

If an incoming code is not recognized:\
\
Flag as UNMAPPED\
Route to Exception Queue\
Block posting or require manual classification\
\
No financial results should be processed without valid classification.

## 11. Relationship to Other Models

This model integrates with:\
\
Payroll_Check_Model\
Accumulator_and_Balance_Model\
Result_and_Payable_Model\
Provider_Billing_and_Charge_Model\
Rule_Resolution_Engine
