# Earnings_and_Deductions_Computation_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/calculation-engine/Earnings_and_Deductions_Computation_Model.md` |
| **Domain** | Calculation Engine |
| **Related Documents** | PRD-400-Earnings-Model.md, DATA/Entity-Payroll-Item.md, Calculation_Engine, Result_and_Payable_Model, Accumulator_and_Balance_Model, Tax_Classification_and_Obligation_Model, Correction_and_Immutability_Model |

## Purpose

Defines how earnings and deductions are computed from worked time, pay rates, benefit elections, premium rules, and payroll policy logic. Establishes the ordered transformation from payroll inputs into financial result lines.

---

## 1. Computation Scope

Computation includes:\
\
Regular earnings\
Premium earnings\
Salary earnings\
Bonus and supplemental earnings\
Employee deductions\
Employer contributions\
Taxable wage formation\
Net pay preparation

## 2. Core Computation Context

Computation_Context\
\
Computation_Context_ID\
Payroll_Run_ID\
Payroll_Check_ID\
Employee_ID\
Employment_ID\
Pay_Period_ID\
Calendar_Context_ID\
Computation_Status

## 3. Earnings Computation Inputs

Earnings computation consumes:\
\
Approved time entries\
Scheduled work context\
Assigned pay rates\
Overtime and premium rules\
Holiday rules\
Compensation overrides\
\
These inputs generate earnings result lines.

## 4. Deduction Computation Inputs

Deduction computation consumes:\
\
Benefit enrollments\
Deduction plans\
Contribution definitions\
Deduction schedules\
Tax treatment definitions\
Arrear or catch-up rules\
\
These inputs generate deduction and contribution result lines.

## 5. Ordered Computation Flow

Typical ordered computation:\
\
1. Determine eligible earnings inputs\
2. Generate base earnings\
3. Apply premium earnings\
4. Apply pre-tax deductions\
5. Determine taxable wages\
6. Apply taxes\
7. Apply post-tax deductions\
8. Apply employer contributions\
9. Derive net pay outputs\
\
Computation order must be explicit and auditable.

## 6. Result Line Generation

Each computation step produces structured result lines.\
\
Result attributes include:\
\
Result_Line_ID\
Result_Class\
Code_Type\
Code\
Description\
Hours (optional)\
Rate (optional)\
Amount\
Taxable_Flag\
Cash_Impact_Flag

## 7. Taxable Wage Formation

Taxable wages are derived from ordered earnings and deduction outcomes.\
\
Examples:\
\
Pre-tax retirement deductions reduce certain wage bases\
Imputed income increases taxable wages\
Jurisdiction-specific tax rules alter taxable treatment\
\
Taxable wage formation must remain explicit and reproducible.

## 8. Arrears, Catch-Up, and Partial Processing

The model must support partial and deferred deductions.\
\
Examples:\
\
Insufficient net pay\
Benefit arrears\
Deferred collection\
Catch-up deduction logic\
\
Arrears handling must be traceable and policy-driven.

## 9. Retroactive Recalculation

Retroactive changes may affect earnings or deductions.\
\
Examples:\
\
Corrected time entry\
Retroactive rate change\
Late benefit enrollment\
Tax rule correction\
\
Recalculation must preserve prior history and generate correction-aware
outputs.

## 10. Relationship to Other Models

This model integrates with:\
\
Calculation_Engine\
Result_and_Payable_Model\
Accumulator_and_Balance_Model\
Tax_Classification_and_Obligation_Model\
Overtime_and_Premium_Pay_Model\
Correction_and_Immutability_Model\
Payroll_Check_Model
