# Payroll_Check_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/processing/Payroll_Check_Model.md` |
| **Domain** | Processing |
| **Related Documents** | DATA/Entity-Payroll-Item.md, Payroll_Run_Model, Result_and_Payable_Model, Accumulator_and_Balance_Model, Pay_Statement_Model, Correction_and_Immutability_Model |

## Purpose

Defines the Payroll Check as the atomic accounting unit of payroll execution. All payroll financial results originate from a Payroll Check and flow into accumulators, billing processes, and reporting outputs.

---

## 1. Core Payroll_Check Entity

Check_ID, Check_Number, Payroll_Run_ID, Employee_ID, Employment_ID, Pay_Period_Start_Date, Pay_Period_End_Date, Check_Date, Payment_Date, Calendar_Context_ID, Check_Status.
Check_Status: Initialized, Calculated, Validated, Released, Voided, Corrected.

## 2. Payment Handling

Payment_Method: DIRECT_DEPOSIT, PRINTED_CHECK, PAYCARD, CASH, MANUAL_CHECK, OTHER.
Payment_Context: REGULAR, OFF_CYCLE, ADJUSTMENT, VOID_REPLACEMENT, TERMINATION, BONUS, MANUAL.

## 3. Result Line Ownership

Each Payroll_Check owns Result_Lines[]. Result_Line fields: Code_Type, Code, Description, Calculation_Mode, Hours (optional), Rate (optional), Amount.

## 4. Check-Level Totals

Gross_Earnings, Total_Deductions, Total_Taxes, Net_Pay, Employer_Total_Cost. Derived from result lines.

## 5. Accumulator Posting Boundary

Payroll_Check → Result_Line → Accumulator_Contribution → Accumulator_Balance. Posting is atomic at the check level.

## 6. Idempotency Boundary

Idempotency key: Employment_ID + Check_Number + Payroll_Context. Reprocessing replaces prior results rather than duplicating them.

## 7. Correction Lifecycle

Void Check, Replacement Check, Adjustment Check. All correction actions integrate with the Correction_and_Immutability_Model.

## 8. Reporting Integration

Payroll_Check records support: Pay Statements, Tax Reporting, Invoice Reporting, Reconciliation, Audit Logs.

## 9. Relationship to Other Models

This model integrates with: Payroll_Run_Model, Result_and_Payable_Model, Accumulator_and_Balance_Model, Net_Pay_and_Disbursement_Model, Pay_Statement_Model, Provider_Billing_and_Charge_Model, Correction_and_Immutability_Model.
