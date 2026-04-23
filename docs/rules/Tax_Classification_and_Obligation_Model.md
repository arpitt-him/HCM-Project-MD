# Tax_Classification_and_Obligation_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.3 |
| **Status** | Reviewed |
| **Owner** | Rules Domain |
| **Location** | `docs/rules/Tax_Classification_and_Obligation_Model.md` |
| **Domain** | Rules |
| **Related Documents** | 

## Purpose

Define classification and handling of employee tax withholdings and employer statutory tax obligations.

This model governs how taxes are:

- classified
- associated with jurisdictions
- calculated against taxable wages and wage bases
- recorded in payroll results
- posted to accumulators
- expressed as liabilities
- reported, remitted, exported, and reconciled

This model ensures correct treatment of jurisdictional taxes, wage bases, liabilities, correction activity, and downstream financial and reporting consequences.

## 1. Tax Actors

Two primary actors exist:\
\
Employee Tax Withholding\
Taxes withheld from employee wages.\
\
Employer Statutory Obligation\
Taxes paid by employer based on payroll activity.

## 2. Tax Classification Types

Canonical tax classifications:\
\
FEDERAL_INCOME_TAX\
STATE_INCOME_TAX\
SOCIAL_SECURITY\
MEDICARE\
FUTA\
STATE_UNEMPLOYMENT\
LOCAL_TAX\
OTHER_STATUTORY_TAX

## 3. Jurisdiction Model

Each tax is associated with a jurisdiction:\
\
Jurisdiction_ID\
Jurisdiction_Type (Federal, State, Local)\
Jurisdiction_Code\
\
Examples:\
\
Federal\
Georgia\
Local Municipality

## 4. Tax Component Attributes

Each tax definition includes:\
\
Tax_Code\
Tax_Name\
Tax_Classification\
Jurisdiction_ID\
Actor_Type (Employee / Employer)\
Calculation_Method\
Wage_Base_Type\
Rate_Structure

Additional attributes may include:

Obligation_Type  
Remittance_Frequency  
Reporting_Relevance_Flag  
Accumulator_Definition_ID  
Rule_Version_ID  
Effective_Start_Date  
Effective_End_Date  

These attributes support downstream remittance, reporting, replay, and correction handling.

### 4.1 Relationship to Employee Payroll Result

Tax classifications are expressed operationally through Tax Result Lines produced within Employee Payroll Results.

Relationship:

Tax Classification / Obligation
        ↓
Employee Payroll Result
        └── Tax Result Line
                ↓
Accumulator Impact
                ↓
Liability / Reporting / Remittance

This ensures that tax definitions remain governed rules, while payroll execution produces explicit result-line instances of those rules.

### 4.2 Rule Pack Association

Each tax definition shall be associated with one or more Rule Packs.

Rule Pack binding shall define:

- jurisdiction-specific tax behavior
- calculation logic
- exemption handling
- reporting configuration
- remittance handling

Rule Pack selection shall be governed through:

Legal Entity → Jurisdiction Profile → Rule Pack → Tax Classification

## 5. Wage Base Handling

Certain taxes include annual wage limits.\
\
Examples:\
\
Social Security Wage Base\
FUTA Wage Base\
State Unemployment Wage Base\
\
System must track cumulative wages and stop calculation once limits are
reached.

## 6. Tax Accumulator Alignment

Tax accumulators may track:

- Taxable_Wages
- Tax_Withheld
- Employer_Tax_Liability
- Wage_Base_Consumed
- Jurisdiction_Specific_Totals

Each accumulator must be governed through:

- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Accumulator_Model_Detailed

Tax-related accumulator values reset according to the appropriate governed tax or reporting calendar and must remain traceable to the payroll results and tax result lines that produced them.

## 7. Imputed Income Interaction

Certain employer-paid benefits generate taxable wages.\
\
Example:\
\
Group-Term Life Insurance (IRC §79)\
\
Imputed income increases taxable wages for applicable tax calculations.

## 8. External Code Mapping Examples

Based on observed datasets:\
\
TaxU / FWT → FEDERAL_INCOME_TAX\
TaxU / GASWT → STATE_INCOME_TAX\
TaxU / MEDI → MEDICARE\
TaxU / OASDI → SOCIAL_SECURITY\
\
ConB / FUTA → FUTA\
ConB / State Unemployment → STATE_UNEMPLOYMENT

## 9. Tax Lifecycle

Tax processing lifecycle:\
\
Determine Taxable Wages\
Apply Wage Base Limits\
Calculate Tax Amount\
Post Tax Results\
Update Accumulators\
Report Liabilities

## 9.1 Correction and Reversal Handling

Tax obligations may require adjustment through:

- retroactive recalculation
- reversal of prior tax results
- correction of taxable wage classifications
- wage base correction
- liability adjustment after provider or authority variance

Tax corrections shall not overwrite historical tax results silently.

Corrective handling must preserve lineage to:

- original payroll result
- original tax result line
- accumulator impacts
- corrected liability outcome

This supports replay, audit, reporting defensibility, and remittance correction workflows.

## 9.2 Downstream Obligation Alignment

Tax classifications and obligations may drive downstream outputs including:

- statutory remittance
- provider export
- payroll-to-GL accounting export
- regulatory reporting
- reconciliation workflows

A governed tax obligation may therefore produce consequences in:

- Remittance Profile and remittance use
- Payroll Interface and Export processing
- General Ledger and Accounting Export
- Payroll Reconciliation
- Payroll Provider Response handling

This model defines the governed tax semantics that those downstream models consume.

## 10. Relationship to Other Models

This model integrates with:

- Code_Classification_and_Mapping_Model
- Employee_Payroll_Result_Model
- Payroll_Run_Result_Set_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Accumulator_Model_Detailed
- Remittance_Profile_Data_Model
- Payroll_Interface_and_Export_Model
- General_Ledger_and_Accounting_Export_Model
- Payroll_Reconciliation_Model
- Payroll_Adjustment_and_Correction_Model
- Multi_Context_Calendar_Model
- Provider_Billing_and_Charge_Model

## 11. Multi-Jurisdiction Tax Applicability

Employees may be subject to multiple simultaneous tax jurisdictions.

Applicable tax determination shall consider:

- work location jurisdiction
- residency jurisdiction
- legal entity jurisdiction
- special authority jurisdictions

Resolution shall remain:

- deterministic
- traceable
- reproducible

Each applied tax obligation shall reference the originating jurisdiction context.

## 12. Tax Liability Lifecycle

Tax liabilities shall progress through the following lifecycle:

Calculated  
Approved  
Accrued  
Remitted  
Reported  
Reconciled  
Closed

Each lifecycle stage shall remain traceable through lineage records.

Liabilities shall not be overwritten once remitted.

## 13. Deterministic Replay Requirements

Tax calculation shall produce identical outputs when replayed using:

- identical taxable wage inputs
- identical jurisdiction rule sets
- identical rule pack versions
- identical accumulator states

Replay capability shall support:

- audit reconstruction
- jurisdictional review
- reconciliation validation