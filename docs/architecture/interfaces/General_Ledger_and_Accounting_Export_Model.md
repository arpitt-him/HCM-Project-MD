# General_Ledger_and_Accounting_Export_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/interfaces/General_Ledger_and_Accounting_Export_Model.md` |
| **Domain** | Interfaces |
| **Related Documents** | Payroll_Check_Model, Result_and_Payable_Model, Tax_Classification_and_Obligation_Model, Multi_Context_Calendar_Model, Integration_and_Data_Exchange_Model, Correction_and_Immutability_Model |

## Purpose

Defines the structure and lifecycle of payroll-to-accounting exports.

Ensures that governed payroll execution outputs are transformed into balanced journal entries suitable for downstream accounting and financial reporting systems.

This model governs how accounting exports derive from:

- Payroll_Run
- Payroll_Run_Result_Set
- Employee_Payroll_Result
- payroll liabilities
- cash disbursement outcomes
- correction and adjustment processing

The model ensures that payroll-to-GL export remains traceable, balanced, idempotent, auditable, and reconcilable across original runs, reruns, and correction activity.

---

## 1. Scope of Accounting Exports

Payroll expense postings, employer tax liabilities, benefit expenses, cash disbursement postings, accrual postings, adjustment entries, departmental cost allocations.

## 2. Core Journal_Entry Entity

Journal_Entry_ID, 
Journal_Date, 
Accounting_Period_ID, 
Organization_ID, 
Source_System, 
Source_Run_ID, 
Payroll_Run_Result_Set_ID,
Run_Scope_ID (optional),
Source_Period_ID,
Execution_Period_ID,
Source_Check_ID (optional), 
Journal_Status

Status examples: Initialized, Balanced, Approved, Exported, Posted.

## 3. Journal_Line Entity

Journal_Line_ID, Journal_Entry_ID, Account_Code, Account_Description, Debit_Amount, Credit_Amount, Department_ID, Cost_Center_ID, Location_ID, Reference_Code, Memo_Text.

Additional lineage attributes may include:

Employee_Payroll_Result_ID (optional),
Employment_ID (optional),
Person_ID (optional).

These fields support worker-level financial drilldown, allocation traceability, and correction auditing where journal lines are derived from employee-specific results.

## 4. Chart of Accounts Integration

Account_Code, Account_Type, Account_Description, Posting_Category.
Examples: Wage Expense, Employer Tax Expense, Cash, Benefits Expense, Accrued Liabilities.

## 5. Mapping from Payroll to Accounting

Gross Earnings → Wage Expense Account. Employee Taxes → Tax Liability Account. Employer Taxes → Employer Tax Expense. Net Pay → Cash Disbursement. Benefits → Benefits Expense. Mappings shall be configurable and version-controlled.

## 5.1 Accounting Export Source Lineage

Every journal entry and journal line shall preserve linkage to the governed payroll artifacts from which it was derived.

At minimum, accounting export lineage may include:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID where worker-level lineage is required
- Source_Period_ID
- Execution_Period_ID
- correction or adjustment reference where applicable

This ensures that:

- payroll-to-GL reconciliation can trace accounting postings back to authoritative payroll results
- reruns and correction runs do not create ambiguous accounting lineage
- audit review can explain both aggregate journal totals and underlying payroll result origins

## 6. Cost Allocation Support

Supported allocation dimensions: Department, Location, Cost Center, Project, Business Unit. Allocations may be single-dimension, multi-dimensional, or percentage-based.

## 7. Balancing Requirements

Total Debits = Total Credits. Validation prior to export. Automatic rejection of unbalanced journals. Balance verification is mandatory before posting to accounting systems.

Correction, adjustment, and supplemental exports shall also satisfy balancing requirements.

Additive correction journals must remain independently balanced even when they represent only the delta from a prior payroll result or prior accounting export.

## 8. Accounting Period Alignment

Accounting_Period_ID, Fiscal_Year, Fiscal_Period. Supports calendar fiscal years and non-calendar fiscal years (e.g., October–September).

## 9. Export Formats

CSV, Fixed-width files, XML, JSON, API submission, accounting system native formats. Each export definition must specify file format, field mapping, and export frequency.

## 10. Idempotency and Replay Protection

Export_Batch_ID, Source_Run_Reference, Journal_Fingerprint. Duplicate exports must not create duplicate postings.

Idempotency and replay protection shall distinguish between:

- retransmission of the same accounting export
- corrected replacement accounting export
- additive correction export generated from a later Payroll Run or correction run

Replacement or additive exports must remain explicitly identifiable so that duplicate prevention does not block governed correction activity.

## 11. Reconciliation and Validation

Post-export validation includes:

- payroll-to-GL reconciliation
- control total matching
- expense validation
- cash validation
- liability validation
- correction and adjustment alignment

Reconciliation shall remain traceable to:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- accounting export batch or journal entry
- correction or adjustment lineage where applicable

Reconciliation must detect discrepancies before closing accounting periods and must support governed correction workflows where mismatches are identified.

## 12. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Reconciliation_Model
- Net_Pay_and_Disbursement_Model
- Provider_Billing_and_Charge_Model
- Tax_Classification_and_Obligation_Model
- Multi_Context_Calendar_Model
- Operational_Reporting_and_Analytics_Model
- Integration_and_Data_Exchange_Model
- Correction_and_Immutability_Model
