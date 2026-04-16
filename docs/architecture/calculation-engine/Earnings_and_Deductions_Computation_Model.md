# Earnings_and_Deductions_Computation_Model

Version: v0.1

## 1. Purpose

Define how earnings and deductions are computed from worked time, pay
rates, benefit elections, premium rules, and payroll policy logic. This
model establishes the ordered transformation from payroll inputs into
financial result lines.

## 2. Computation Scope

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

## 3. Core Computation Context

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

## 4. Earnings Computation Inputs

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

## 5. Deduction Computation Inputs

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

## 6. Ordered Computation Flow

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

## 7. Result Line Generation

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

## 8. Taxable Wage Formation

Taxable wages are derived from ordered earnings and deduction outcomes.\
\
Examples:\
\
Pre-tax retirement deductions reduce certain wage bases\
Imputed income increases taxable wages\
Jurisdiction-specific tax rules alter taxable treatment\
\
Taxable wage formation must remain explicit and reproducible.

## 9. Arrears, Catch-Up, and Partial Processing

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

## 10. Retroactive Recalculation

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

## 11. Audit and Reproducibility

All computation steps must be reproducible.\
\
Audit support includes:\
\
Input snapshot reference\
Applied rule reference\
Generated result lines\
Calculation ordering trace\
Correction linkage

## 12. Relationship to Other Models

This model integrates with:\
\
Compensation_and_Pay_Rate_Model\
Time_Entry_and_Worked_Time_Model\
Overtime_and_Premium_Pay_Model\
Benefit_and_Deduction_Configuration_Model\
Tax_Classification_and_Obligation_Model\
Payroll_Check_Model\
Code_Classification_and_Mapping_Model\
Correction_and_Immutability_Model
