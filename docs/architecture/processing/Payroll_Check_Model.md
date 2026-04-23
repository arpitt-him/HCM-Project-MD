# Payroll_Check_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/processing/Payroll_Check_Model.md` |
| **Domain** | Processing |
| **Related Documents** | DATA/Entity-Payroll-Item.md, Payroll_Run_Model, Result_and_Payable_Model, Accumulator_and_Balance_Model, Pay_Statement_Model, Correction_and_Immutability_Model |

## Purpose

Defines the Payroll Check as the governed payment and presentation artifact representing employee-facing payroll settlement for a given payroll outcome.

Payroll financial truth originates in governed payroll execution artifacts, including Payroll_Run, Payroll_Run_Result_Set, and Employee_Payroll_Result.

Payroll_Check represents the check-level or payment-level realization of those governed results for payment delivery, pay statement production, reconciliation, and downstream audit use.

---

## 1. Core Payroll_Check Entity

Check_ID, Check_Number, Payroll_Run_ID, Employee_ID, Employment_ID, Pay_Period_Start_Date, Pay_Period_End_Date, Check_Date, Payment_Date, Calendar_Context_ID, Check_Status.
Check_Status: Initialized, Calculated, Validated, Released, Voided, Corrected.

Additional governed attributes may include:

- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID
- Parent_Check_ID
- Root_Check_ID
- Check_Lineage_Sequence
- Check_Type
- Source_Period_ID
- Execution_Period_ID

## 2. Relationship to Payroll Execution Artifacts

Payroll_Check shall remain traceable to governed payroll execution artifacts.

A Payroll_Check may be derived from:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID

Payroll_Check does not define payroll truth.

It represents the payment-facing and employee-facing realization of already governed payroll results.

This ensures:

- deterministic replay
- correction-safe check reconstruction
- pay statement traceability
- settlement reconciliation integrity

## 3. Payment Handling

Payment_Method: DIRECT_DEPOSIT, PRINTED_CHECK, PAYCARD, CASH, MANUAL_CHECK, OTHER.
Payment_Context: REGULAR, OFF_CYCLE, ADJUSTMENT, VOID_REPLACEMENT, TERMINATION, BONUS, MANUAL.

## 4. Check Line Derivation

Payroll_Check may include check-facing line items derived from governed payroll result lines.

Check-facing lines may include:

- earnings lines
- deduction lines
- tax lines
- employer contribution lines where display is permitted

Check-facing line attributes may include:

- Code_Type
- Code
- Description
- Calculation_Mode
- Hours (optional)
- Rate (optional)
- Amount
- Source_Result_Line_ID

Canonical payroll result ownership remains with governed payroll execution artifacts, not with Payroll_Check itself.

## 5. Check-Level Totals

Gross_Earnings, Total_Deductions, Total_Taxes, Net_Pay, Employer_Total_Cost. Derived from result lines.

## 6. Relationship to Accumulator Posting

Accumulator posting shall remain governed by payroll result and accumulator impact architecture.

Payroll_Check may reflect the employee-facing presentation of values that also produced accumulator impacts, but Payroll_Check is not the authoritative posting boundary.

Accumulator mutation shall remain traceable through:

- Employee_Payroll_Result
- Accumulator_Impact
- Accumulator_Definition
- Accumulator value state

## 7. Idempotency Boundary

Payroll_Check generation shall be idempotent with respect to governed payroll execution state.

Idempotency shall prevent duplicate check artifacts for the same governed payment outcome.

Reprocessing shall not destructively replace historical checks once released or otherwise made immutable.

Where correction is required, the system shall generate governed void, replacement, or adjustment check artifacts with preserved lineage.

## 8. Correction Lifecycle

Void Check, Replacement Check, Adjustment Check. All correction actions integrate with the Correction_and_Immutability_Model.

Correction lifecycle shall preserve:

- Parent_Check_ID
- Root_Check_ID
- Check_Lineage_Sequence
- relationship to originating correction record
- relationship to original payroll result lineage

Voided, replacement, and adjustment checks must remain historically visible and queryable.

## 9. Reporting Integration

Payroll_Check records support: Pay Statements, Tax Reporting, Invoice Reporting, Reconciliation, Audit Logs.

Payroll_Check records also support:

- payroll funding and settlement traceability
- pay statement rendering
- corrected or replacement statement reconstruction
- provider billing derivation where applicable

## 10. Deterministic Replay Requirements

Payroll_Check reconstruction shall remain deterministic.

Given identical governed payroll execution artifacts, payment context, and template/rendering configuration, the platform shall reconstruct the same payroll check artifact.

Later configuration or correction activity shall not silently reinterpret historical check state.

Where corrected checks exist, replay shall preserve original and corrected check lineage distinctly.

## 11. Dependencies

This model depends on:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Result_and_Payable_Model
- Net_Pay_and_Disbursement_Model
- Pay_Statement_Model
- Accumulator_Impact_Model
- Accumulator_Definition_Model
- Correction_and_Immutability_Model
- Payroll_Adjustment_and_Correction_Model

## 12. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Result_and_Payable_Model
- Net_Pay_and_Disbursement_Model
- Pay_Statement_Model
- Pay_Statement_Template_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Provider_Billing_and_Charge_Model
- Payroll_Adjustment_and_Correction_Model
- Correction_and_Immutability_Model
