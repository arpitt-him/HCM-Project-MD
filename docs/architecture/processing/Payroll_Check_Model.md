# Payroll_Check_Model

Version: v0.1

## 1. Purpose

Define the Payroll Check as the atomic accounting unit of payroll
execution. All payroll financial results originate from a Payroll_Check
and flow into accumulators, billing processes, and reporting outputs.

## 2. Core Payroll_Check Entity

Payroll_Check\
Check_ID\
Check_Number\
Payroll_Run_ID\
Employee_ID\
Employment_ID\
Pay_Period_Start_Date\
Pay_Period_End_Date\
Check_Date\
Payment_Date\
Calendar_Context_ID\
Check_Status (Initialized, Calculated, Validated, Released, Voided,
Corrected)

## 3. Payment Handling

Payment_Method\
DIRECT_DEPOSIT\
PRINTED_CHECK\
PAYCARD\
CASH\
MANUAL_CHECK\
OTHER\
\
Payment_Context\
REGULAR\
OFF_CYCLE\
ADJUSTMENT\
VOID_REPLACEMENT\
TERMINATION\
BONUS\
MANUAL

## 4. Result Line Ownership

Each Payroll_Check owns Result_Lines\[\].\
\
Result_Line fields include:\
Code_Type\
Code\
Description\
Calculation_Mode\
Hours (optional)\
Rate (optional)\
Amount

## 5. Check-Level Totals

Derived totals maintained per check:\
\
Gross_Earnings\
Total_Deductions\
Total_Taxes\
Net_Pay\
Employer_Total_Cost

## 6. Accumulator Posting Boundary

Posting Flow:\
\
Payroll_Check\
→ Result_Line\
→ Accumulator_Contribution\
→ Accumulator_Balance

## 7. Idempotency Boundary

Idempotency Key:\
\
Employment_ID\
Check_Number\
Payroll_Context\
\
Reprocessing replaces prior results rather than duplicating them.

## 8. Correction Lifecycle

Supported correction actions:\
\
Void Check\
Replacement Check\
Adjustment Check\
\
These actions integrate with the Correction_and_Immutability_Model.

## 9. Provider Billing Relationship

Payroll_Check records generate employer financial obligations which feed
invoice allocation processes.

## 10. Reporting Integration

Payroll_Check records support downstream reporting including:\
\
Pay Statements\
Tax Reporting\
Invoice Reporting\
Reconciliation\
Audit Logs
