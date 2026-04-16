# Net_Pay_and_Disbursement_Model

Version: v0.1

## 1. Purpose

Define structures governing the finalization of payroll results into net
pay, payment distribution methods, and disbursement processing
workflows.

## 2. Disbursement Scope

Supported payment methods include:\
\
Direct Deposit\
Paper Check\
Paycard\
Off-cycle Check\
Manual Adjustment Payment\
Split Deposit\
International Wire (future extension)

## 3. Core Net_Pay Entity

Net_Pay\
\
Net_Pay_ID\
Payroll_Check_ID\
Employee_ID\
Employment_ID\
\
Gross_Pay\
Total_Deductions\
Total_Taxes\
Net_Pay_Amount\
\
Net_Pay_Status

## 4. Payment Method Definition

Payment_Method\
\
Payment_Method_ID\
Employee_ID\
Employment_ID\
Payment_Type\
Priority_Order\
Allocation_Type\
Allocation_Value\
\
Payment_Type examples:\
\
DIRECT_DEPOSIT\
CHECK\
PAYCARD\
WIRE

## 5. Split Payment Handling

Employees may distribute pay across multiple destinations.\
\
Examples:\
\
Primary account → Remaining balance\
Secondary account → Fixed amount\
Savings account → Percentage-based allocation\
\
Split distribution must follow priority order rules.

## 6. Bank and Financial Routing

Payment routing requires financial institution details.\
\
Routing attributes:\
\
Bank_Name\
Routing_Number\
Account_Number\
Account_Type\
Country_Code\
\
Sensitive data must be securely stored and encrypted.

## 7. Check Generation Handling

Paper check payments include:\
\
Check_Number\
Check_Date\
Check_Status\
Void_Flag\
Reissue_Flag\
\
Check printing must remain auditable and reproducible.

## 8. Paycard Handling

Paycard processing includes:\
\
Card_Provider_ID\
Card_Account_Number\
Activation_Status\
Funding_Status\
\
Paycards must integrate with secure payment providers.

## 9. Off-Cycle Payment Handling

Off-cycle payments support:\
\
Corrections\
Final pay\
Manual payroll events\
Emergency payments\
\
Off-cycle runs must remain fully traceable.

## 10. Payment Status Lifecycle

Payments progress through defined states.\
\
Status examples:\
\
Pending\
Authorized\
Released\
Funded\
Completed\
Failed\
Voided

## 11. Reconciliation and Settlement

Payment reconciliation ensures financial accuracy.\
\
Examples:\
\
Bank settlement reconciliation\
Payment confirmation tracking\
Failed payment resolution\
\
Reconciliation must detect mismatches before final closure.

## 12. Security and Compliance

Payment processing must enforce:\
\
Encryption standards\
Fraud prevention controls\
Access authorization\
Audit tracking\
\
Sensitive financial operations require strict controls.

## 13. Relationship to Other Models

This model integrates with:\
\
Payroll_Check_Model\
Earnings_and_Deductions_Computation_Model\
Payroll_Interface_and_Export_Model\
General_Ledger_and_Accounting_Export_Model\
Security_and_Access_Control_Model\
Correction_and_Immutability_Model
