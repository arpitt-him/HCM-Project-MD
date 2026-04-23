# Provider_Billing_and_Charge_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/interfaces/Provider_Billing_and_Charge_Model.md` |
| **Domain** | Interfaces |
| **Related Documents** | Result_and_Payable_Model, Code_Classification_and_Mapping_Model, Multi_Context_Calendar_Model, General_Ledger_and_Accounting_Export_Model, Payroll_Funding_and_Cash_Management_Model |

## Purpose

Defines the canonical model for employer-facing provider billing, employee-level invoice allocations, and charge classification in PEO-style operating environments. Separates payroll execution facts from provider billing artifacts while ensuring full reconcilability.

---

## 1. Core Design Principles

Payroll remains authoritative; billing is derived. Employee-facing payroll semantics and client-facing provider billing semantics are distinct canonical classes. Code meaning is context-sensitive. Totals should be reproducible from atomic values rather than trusted only as imported summaries.

---

## 2. Canonical Domain Boundary

Payroll execution: employee + check + result line (earnings, deductions, taxes, imputed income, net-pay impacts). Employer obligation: employee + period + obligation class (employer taxes, employer-paid benefits, worker comp). Provider billing: employee + invoice period + charge allocation (fees, adjustments, billed contributions, invoice totals).

---

## 3. Relationship to Payroll Execution Artifacts

Provider billing artifacts shall remain traceable to the payroll execution artifacts that generated billable employer obligations.

Billing lineage shall support reference to:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID where applicable
- Result_Line_ID where applicable
- Payable lineage where applicable

Billing artifacts shall not redefine payroll execution truth.

They represent derived employer-facing financial representation of payroll-derived obligations.

---

## 4. Provider_Invoice Entity

Invoice_ID, Provider_ID, Client_Entity_ID, Invoice_Date, Billing_Period_Start, Billing_Period_End, Calendar_Context_ID, Currency_Code, Invoice_Status, Imported_Source_Artifact_ID.

Additional governed attributes may include:

- Payroll_Run_Result_Set_ID
- Invoice_Lineage_ID
- Parent_Invoice_ID
- Root_Invoice_ID
- Reconciliation_Status
- Settlement_Status
- Invoice_Source_Type
- Invoice_Version_Number

---

## 5. Employee_Invoice_Allocation Entity

Employee_Invoice_Allocation_ID, Invoice_ID, Employee_ID, Employment_ID, Allocation_Period_Start, Allocation_Period_End, Total_Wages_Basis, Total_Employer_Charges, Total_Adjustments, Total_Billed_Amount.

---

## 6. Provider_Charge_Line Entity

Provider_Charge_Line_ID, Employee_Invoice_Allocation_ID, Charge_Family, Charge_Class, External_Code_Type, External_Code, External_Code_Description, Amount, Calculation_Mode, Derived_From_Result_Line_ID (optional), Jurisdiction_ID (optional), Plan_ID (optional), Is_Adjustment, Is_Summary_Line.

Charge lines shall remain traceable to originating obligation sources where derivation applies.

Where payroll-derived:

- Derived_From_Result_Line_ID shall reference the originating payroll result line.

Where provider-imported:

- External_Source_Reference_ID shall preserve the originating provider artifact reference.

Charge lineage shall remain reconstructable across adjustment and reconciliation workflows.

---

## 7. Charge Family Examples

Employer Benefits (health, life, disability), Employer Payroll Taxes (FICA-M, FUTA, SUI), Worker Compensation, Administrative Fees, Credit Billing Adjustments, Return Deductions.

---

## 8. Calculation Modes

FIXED (direct fee amount), DERIVED (calculated from payroll results), PERCENTAGE (rate applied to wages basis), HOURLY (rate × hours), IMPORTED (sourced directly from external system).

---

## 9. Reconciliation Design Principles

Imported provider summary columns are informative but not canonical. System-computed totals shall be reproducible from detailed values. Negative charges, credits, and return deductions must be modelled explicitly. Multi-period reports must preserve the requested date range and calendar context.

Provider billing reconciliation shall support traceability between:

- Provider_Invoice_ID
- Payroll_Run_Result_Set_ID
- payable obligations derived from payroll
- funding settlement references
- general ledger export records

Reconciliation discrepancies shall generate governed reconciliation exceptions rather than silent correction.

---

## 10. Non-Goals

This model does not redefine payroll result semantics already covered by Result_and_Payable_Model. It does not specify provider-specific import file parsing rules in full detail. It does not replace the need for Code_Classification_and_Mapping_Model.

---

## 11. Deterministic Billing Reconstruction

Provider billing behavior shall remain reconstructable for any requested effective period.

Reconstruction shall preserve:

- invoice composition
- employee allocation totals
- charge lineage
- calendar context interpretation
- payroll linkage state

Later configuration, mapping, or provider corrections shall not reinterpret previously issued billing silently.

Corrections shall produce additive adjustment artifacts rather than destructive replacement.

---

## 12. Dependencies

This model depends on:

- Result_and_Payable_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Code_Classification_and_Mapping_Model
- Payroll_Funding_and_Cash_Management_Model
- General_Ledger_and_Accounting_Export_Model
- Multi_Context_Calendar_Model
- Integration_and_Data_Exchange_Model
- Exception_and_Work_Queue_Model

---

## 13. Relationship to Other Models

This model integrates with: Code_Classification_and_Mapping_Model, Result_and_Payable_Model, General_Ledger_and_Accounting_Export_Model, Multi_Context_Calendar_Model, Payroll_Funding_and_Cash_Management_Model, Integration_and_Data_Exchange_Model.

---