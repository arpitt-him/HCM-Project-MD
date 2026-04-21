# Earnings_and_Deductions_Computation_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/calculation-engine/Earnings_and_Deductions_Computation_Model.md` |
| **Domain** | Calculation Engine |
| **Related Documents** | PRD-400-Earnings-Model.md, DATA/Entity-Payroll-Item.md, Calculation_Engine, Result_and_Payable_Model, Accumulator_and_Balance_Model, Tax_Classification_and_Obligation_Model, Correction_and_Immutability_Model |

## Purpose

Defines how earnings and deductions are computed from worked time, pay rates, benefit elections, premium rules, and payroll policy logic.

Establishes the ordered transformation from governed payroll inputs into structured payroll result lines associated with Employee Payroll Results.

This model governs how computation outputs become:

- earnings result lines
- deduction result lines
- tax-triggering wage values
- employer contribution results
- net-pay preparation inputs

All computation outputs must remain deterministic, traceable, and replayable across original processing, simulation, and correction workflows.

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

Additional lineage fields may include:

Payroll_Run_Result_Set_ID  
Employee_Payroll_Result_ID  
Run_Scope_ID  
Source_Period_ID  
Execution_Period_ID  

These identifiers ensure that computation outputs remain traceable to governed payroll execution artifacts.

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

Result lines shall be governed by canonical classification semantics defined in Code_Classification_and_Mapping_Model.

Additional lineage attributes may include:

Canonical_Result_Class  
Employee_Payroll_Result_ID  
Rule_Version_ID  
Computation_Phase  
Source_Input_Reference  

These fields ensure that result lines remain explainable and reproducible across replay and audit scenarios.

## 6.1 Relationship to Accumulator Impact

Result lines generated during computation do not directly mutate accumulators.

Instead, validated result lines become inputs to governed accumulator mutation.

Relationship:

Result Line
        ↓
Posting Rule
        ↓
Accumulator Impact
        ↓
Accumulator Value / Liability State

This separation preserves replayability, auditability, and correction safety.

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

Taxable wage formation shall reference governed tax classification logic defined in Tax_Classification_and_Obligation_Model.

Jurisdiction-specific wage-base adjustments must remain:

- explicit
- versioned
- traceable
- reproducible across replay cycles

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

Arrears processing may generate deferred liabilities that are later converted into payable obligations during posting.

Deferred deduction state must remain traceable to:

- original computation cycle
- affected result lines
- subsequent recovery events

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

Retroactive recalculation must generate correction-aware result outputs consistent with Payroll_Adjustment_and_Correction_Model.

Corrective outputs must preserve:

- original result lineage
- recalculated result lineage
- delta differences
- affected accumulator impacts

## 10. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Code_Classification_and_Mapping_Model
- Tax_Classification_and_Obligation_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Posting_Rules_and_Mutation_Semantics
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Overtime_and_Premium_Pay_Model
- Correction_and_Immutability_Model
- Payroll_Interface_and_Export_Model
