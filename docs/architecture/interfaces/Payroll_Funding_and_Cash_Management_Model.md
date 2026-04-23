# Payroll_Funding_and_Cash_Management_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/interfaces/Payroll_Funding_and_Cash_Management_Model.md` |
| **Domain** | Interfaces |
| **Related Documents** | Net_Pay_and_Disbursement_Model, General_Ledger_and_Accounting_Export_Model, Tax_Classification_and_Obligation_Model, Provider_Billing_and_Charge_Model, Multi_Context_Calendar_Model, Correction_and_Immutability_Model |

## Purpose

Defines the structures and workflows governing payroll funding, cash movement, bank coordination, and financial settlement responsibilities required to execute payroll obligations.

---

## 1. Funding Scope

Net pay funding, tax liability funding, benefit provider funding, third-party garnishment funding, off-cycle payroll funding, settlement reconciliation.

## 2. Core Payroll_Funding_Batch Entity

Funding_Batch_ID, Payroll_Run_ID, Funding_Date, Funding_Status, Funding_Amount_Total, Funding_Source_Account_ID, Funding_Destination_Type.
Status examples: Initialized, Calculated, Authorized, Funded, Settled, Closed.

Additional governed attributes may include:

- Payroll_Run_Result_Set_ID
- Funding_Lineage_ID
- Parent_Funding_Batch_ID
- Root_Funding_Batch_ID
- Authorization_Reference_ID
- Settlement_Reference_ID
- Funding_Currency_Code

## 3. Relationship to Payroll Execution Artifacts

Payroll funding shall remain traceable to governed payroll execution artifacts.

Funding batches and funding components shall support linkage to:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID where applicable
- Run_Scope_ID where applicable
- Payable lineage where applicable

Funding does not create payroll truth.

It executes cash obligations derived from governed payroll result, payable, liability, and remittance artifacts.

This distinction is required for replay safety, correction handling, reconciliation integrity, and audit defensibility.

## 4. Funding Components

Net Pay Funding, Tax Funding, Benefit Funding, Vendor Funding, Adjustment Funding. Each component tracks: Component_ID, Component_Type, Component_Amount, Component_Status.

Funding components shall remain traceable to the obligations they satisfy, including:

- net pay payable obligations
- tax liability obligations
- benefit or provider payable obligations
- garnishment or legal-order obligations
- correction-generated funding obligations

Funding component lineage shall remain reconstructable across adjustment, retry, and settlement workflows.

## 5. Funding Source Definition

Funding_Source_Account_ID, Bank_Name, Routing_Number, Account_Number, Account_Type, Currency_Code, Account_Status. All source accounts must be securely stored and auditable.

## 6. Funding Timing and Lead Rules

Funding timing must align with: ACH lead times, bank holidays, weekend processing rules, provider funding windows. Funding schedules must reference calendar contexts.

Funding timing interpretation shall remain traceable to the governing calendar context effective at the time of funding authorization.

Later calendar changes shall not reinterpret historical funding timing decisions.

## 7. Tax Liability Funding

Federal tax deposits, state tax deposits, local tax deposits. Funding must align with deposit schedules, jurisdiction requirements, and tax reporting cycles.

Tax funding shall remain traceable to:

- Tax_Classification_and_Obligation_Model
- remittance schedule context
- jurisdiction-specific deposit requirements
- Payroll_Run lineage where liability originated

Tax funding corrections shall generate additive funding adjustments rather than silently replacing prior funding history.

## 8. Benefit and Vendor Funding

Insurance premiums, retirement contributions, garnishment payments, provider service fees. Funding must track payable obligations to third parties.

Benefit and vendor funding shall remain traceable to:

- Provider_Billing_and_Charge_Model
- payable obligations
- provider or authority settlement context
- correction-generated deltas where applicable

## 9. Cash Reconciliation

Funding amount verification, settlement confirmation, bank response tracking, exception detection. All mismatches must generate reconciliation alerts.

Cash reconciliation shall support traceability between:

- Funding_Batch_ID
- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- settlement confirmation records
- provider or bank response references
- downstream general-ledger export where applicable

## 10. Failed Funding Handling

Insufficient funds, bank rejection, network failure. Recovery attributes: Retry_Count, Failure_Reason_Code, Resolution_Status.

Failed funding recovery shall distinguish between:

- retry of the same funding instruction
- replacement funding batch creation
- correction-driven funding delta generation
- settlement exception handling

These outcomes must remain operationally distinct and auditable.

## 11. Audit and Compliance

Authorization tracking, funding approvals, cash movement logging, settlement confirmation records.

Audit records shall preserve:

- funding authorization lineage
- funding batch lifecycle history
- component-level obligation linkage
- settlement and bank response history
- retry or correction lineage where applicable

## 12. Deterministic Replay Requirements

Payroll funding behavior shall remain replay-safe.

Replay and reconstruction operations shall preserve:

- original funding batch composition
- original component amounts
- original authorization state
- original calendar timing interpretation
- original settlement and failure lineage
- additive correction behavior where later funding changes occurred

Later configuration, calendar, or banking changes shall not reinterpret historical funding decisions silently.

## 13. Dependencies

This model depends on:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Result_and_Payable_Model
- Net_Pay_and_Disbursement_Model
- Tax_Classification_and_Obligation_Model
- Provider_Billing_and_Charge_Model
- Payroll_Reconciliation_Model
- Payroll_Provider_Response_Model
- General_Ledger_and_Accounting_Export_Model
- Multi_Context_Calendar_Model
- Correction_and_Immutability_Model

## 14. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Result_and_Payable_Model
- Net_Pay_and_Disbursement_Model
- Tax_Classification_and_Obligation_Model
- Provider_Billing_and_Charge_Model
- Payroll_Reconciliation_Model
- Payroll_Provider_Response_Model
- General_Ledger_and_Accounting_Export_Model
- Multi_Context_Calendar_Model
- Payroll_Adjustment_and_Correction_Model
- Correction_and_Immutability_Model
- Exception_and_Work_Queue_Model
