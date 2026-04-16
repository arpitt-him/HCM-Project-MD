# Garnishment_and_Legal_Order_Model

Version: v0.1

## 1. Purpose

Define structures and workflows governing garnishments, legal orders,
and other externally mandated payroll withholdings. This model ensures
correct priority handling, statutory compliance, remittance, and
auditability.

## 2. Scope of Legal Withholdings

Supported legal withholding categories include:\
\
Child Support\
Tax Levies\
Creditor Garnishments\
Bankruptcy Orders\
Student Loan Garnishments\
Federal Administrative Garnishments\
State-Mandated Withholdings\
Voluntary Wage Assignments

## 3. Core Legal_Order Entity

Legal_Order\
\
Legal_Order_ID\
Employee_ID\
Employment_ID\
Order_Type\
Issuing_Authority\
Jurisdiction_ID\
Order_Issue_Date\
Order_Effective_Date\
Order_Status\
Order_Reference_Number

## 4. Order Type Classification

Supported order types include:\
\
CHILD_SUPPORT\
TAX_LEVY\
CREDITOR_GARNISHMENT\
BANKRUPTCY\
STUDENT_LOAN\
ADMINISTRATIVE_GARNISHMENT\
VOLUNTARY_ASSIGNMENT

## 5. Withholding Priority and Sequencing

Legal orders must follow defined priority rules.\
\
Priority considerations include:\
\
Federal precedence\
State-specific precedence\
Multiple concurrent orders\
Disposable earnings rules\
Maximum withholding limits\
\
Priority logic must be explicit, configurable, and auditable.

## 6. Disposable Earnings Calculation

Certain orders calculate withholding from disposable earnings.\
\
Disposable earnings may require:\
\
Gross earnings basis\
Less required taxes\
Less mandatory deductions\
Jurisdiction-specific exclusions\
\
The disposable earnings formula must be reproducible.

## 7. Withholding Rule Definition

Each order may define:\
\
Calculation_Method\
Withholding_Percentage\
Flat_Amount\
Maximum_Amount\
Minimum_Protected_Amount\
Remittance_Frequency\
\
Calculation methods vary by order type and jurisdiction.

## 8. Order Lifecycle and Status

Legal orders progress through lifecycle states.\
\
Status examples:\
\
Received\
Validated\
Active\
Suspended\
Modified\
Satisfied\
Terminated\
Closed

## 9. Remittance and External Payment Handling

Withheld amounts must be remitted to the proper authority.\
\
Remittance attributes include:\
\
Payee_Name\
Payee_Address\
Payment_Method\
Remittance_Schedule\
Remittance_Reference_Number\
\
Remittance tracking must remain auditable.

## 10. Modification, Suspension, and Termination

Orders may change over time.\
\
Examples:\
\
Court modification\
Temporary suspension\
Order satisfaction\
Administrative release\
\
Historical order versions must be preserved.

## 11. Compliance, Notice, and Audit

Legal withholding must support:\
\
Employee notice tracking\
Authority correspondence logging\
Compliance deadline monitoring\
Audit trail preservation\
\
All changes and payments must be historically preserved.

## 12. Relationship to Other Models

This model integrates with:\
\
Earnings_and_Deductions_Computation_Model\
Net_Pay_and_Disbursement_Model\
Payroll_Funding_and_Cash_Management_Model\
Tax_Classification_and_Obligation_Model\
Multi_Context_Calendar_Model\
Correction_and_Immutability_Model\
Operational_Reporting_and_Analytics_Model
