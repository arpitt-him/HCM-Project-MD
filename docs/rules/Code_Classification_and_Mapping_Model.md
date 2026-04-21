# Code_Classification_and_Mapping_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Rules Domain |
| **Location** | `docs/rules/Code_Classification_and_Mapping_Model.md` |
| **Domain** | Rules |
| **Related Documents** |

## 1. Purpose

Define how external payroll, provider, billing, and related source codes are classified into canonical internal result types.

This model ensures consistent interpretation of earnings, deductions, taxes, contributions, imputed income, adjustments, and invoice-related charges across all integrations.

This model governs how source codes are translated into:

- canonical payroll result classes
- tax and cash treatment
- accumulator routing
- calculation behavior
- downstream reporting, remittance, export, and accounting consequences

The model exists to ensure that source-system variation does not compromise payroll correctness, replayability, reconciliation, or auditability.

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

## 4.1 Relationship to Employee Payroll Result

Code classification and mapping governs how externally sourced or internally referenced payroll inputs are expressed as result lines within Employee Payroll Results.

Relationship:

External Code
        ↓
Code Classification and Mapping
        ↓
Employee Payroll Result Line
        ↓
Accumulator Impact / Tax / Liability / Export Consequence

Mapped classifications may drive creation of:

- Earnings Result Lines
- Deduction Result Lines
- Tax Result Lines
- Employer Contribution Result Lines
- Imputed Income effects
- Adjustment lines where governed

This ensures that result lines are governed by canonical semantics rather than by provider-specific or source-specific code meaning.

Additional classification attributes may include:

Rule_Version_ID
Effective_Start_Date
Effective_End_Date
Reporting_Relevance_Flag
Remittance_Relevance_Flag
GL_Posting_Category
Correction_Eligible_Flag

These attributes support replay, downstream export behavior, reconciliation, and governed correction handling.

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

Each canonical result class routes to governed accumulator structures.

Examples:

EARNING → Gross Wages
DEDUCTION_PRE_TAX → Pre-Tax Deduction Totals
TAX_WITHHOLDING → Federal or State Tax Totals
IMPUTED_INCOME → Taxable Wage Accumulators
EMPLOYER_CONTRIBUTION → Employer Liability Totals
INVOICE_CHARGE → Employer Invoice Totals

Accumulator routing shall remain traceable through:

- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Accumulator_Model_Detailed

This ensures that result-class mapping determines not only classification meaning, but also how downstream accumulator mutation occurs.

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

## 9.1 Replay and Correction Handling

Code mappings must support deterministic replay.

Historical payroll results shall continue to interpret source codes according to the mapping version and effective dates that were active at the time of original processing.

Mapping changes shall not silently redefine historical results.

Where a mapping error is corrected after payroll execution, corrective handling must preserve linkage between:

- original source code
- original canonical classification
- corrected canonical classification
- affected payroll results
- resulting adjustment or correction activity

This supports replay integrity, auditability, and controlled correction workflows.

## 10. Error Handling and Unknown Codes

If an incoming code is not recognized:\
\
Flag as UNMAPPED\
Route to Exception Queue\
Block posting or require manual classification\
\
No financial results should be processed without valid classification.

Unknown or unmapped codes shall block or hold downstream processing where classification is required for:

- payroll result generation
- tax treatment
- accumulator posting
- remittance determination
- export generation
- accounting export

No unmapped code shall be allowed to produce silent financial impact.

## 11. Relationship to Other Models

This model integrates with:

- Employee_Payroll_Result_Model
- Tax_Classification_and_Obligation_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Accumulator_Model_Detailed
- Result_and_Payable_Model
- Provider_Billing_and_Charge_Model
- Payroll_Interface_and_Export_Model
- General_Ledger_and_Accounting_Export_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Rule_Resolution_Engine
