# Garnishment_and_Legal_Order_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Reviewed |
| **Owner** | Compliance Domain |
| **Location** | `docs/architecture/governance/Garnishment_and_Legal_Order_Model.md` |
| **Domain** | Governance |
| **Related Documents** | Earnings_and_Deductions_Computation_Model, Net_Pay_and_Disbursement_Model, Tax_Classification_and_Obligation_Model, Correction_and_Immutability_Model, Jurisdiction_and_Compliance_Rules_Model |

## Purpose

Defines structures and workflows governing garnishments, legal orders, and other externally mandated payroll withholdings. Ensures correct priority handling, statutory compliance, remittance, and auditability.

---

## 1. Scope of Legal Withholdings

Child Support, Tax Levies, Creditor Garnishments, Bankruptcy Orders, Student Loan Garnishments, Federal Administrative Garnishments, State-Mandated Withholdings, Voluntary Wage Assignments.

## 2. Core Legal_Order Entity

Legal_Order_ID, Employee_ID, Employment_ID, Order_Type, Issuing_Authority, Jurisdiction_ID, Order_Issue_Date, Order_Effective_Date, Order_Status, Order_Reference_Number.
Order_Type values: CHILD_SUPPORT, TAX_LEVY, CREDITOR_GARNISHMENT, BANKRUPTCY, STUDENT_LOAN, ADMINISTRATIVE_GARNISHMENT, VOLUNTARY_ASSIGNMENT.

## 3. Withholding Priority and Sequencing

Legal orders must follow defined priority rules considering: federal precedence, state-specific precedence, multiple concurrent orders, disposable earnings rules, maximum withholding limits. Priority logic must be explicit, configurable, and auditable.

## 4. Disposable Earnings Calculation

Disposable earnings may require: gross earnings basis, less required taxes, less mandatory deductions, jurisdiction-specific exclusions. The disposable earnings formula must be reproducible.

## 5. Withholding Rule Definition

Each order may define: Calculation_Method, Withholding_Percentage, Flat_Amount, Maximum_Amount, Minimum_Protected_Amount, Remittance_Frequency. Calculation methods vary by order type and jurisdiction.

## 6. Order Lifecycle and Status

Received, Validated, Active, Suspended, Modified, Satisfied, Terminated, Closed.

## 7. Remittance and External Payment Handling

Payee_Name, Payee_Address, Payment_Method, Remittance_Schedule, Remittance_Reference_Number. Remittance tracking must remain auditable.

## 8. Modification, Suspension, and Termination

Examples: court modification, temporary suspension, order satisfaction, administrative release. Historical order versions must be preserved.

## 9. Compliance, Notice, and Audit

Employee notice tracking, authority correspondence logging, compliance deadline monitoring, audit trail preservation. All changes and payments must be historically preserved.

## 10. Relationship to Other Models

This model integrates with: Earnings_and_Deductions_Computation_Model, Net_Pay_and_Disbursement_Model, Payroll_Funding_and_Cash_Management_Model, Tax_Classification_and_Obligation_Model, Multi_Context_Calendar_Model, Correction_and_Immutability_Model.
