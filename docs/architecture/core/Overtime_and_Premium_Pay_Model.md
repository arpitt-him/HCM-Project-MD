# Overtime_and_Premium_Pay_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Overtime_and_Premium_Pay_Model.md` |
| **Domain** | Core |
| **Related Documents** | Time_Entry_and_Worked_Time_Model, Scheduling_and_Shift_Model, Earnings_and_Deductions_Computation_Model, Jurisdiction_and_Compliance_Rules_Model, Correction_and_Immutability_Model |

## Purpose

Defines calculation structures and rule behaviours governing overtime, premium pay, and special wage multipliers triggered by worked time conditions.

This model governs how worked time conditions produce structured premium earnings result lines associated with Employee Payroll Results.

Premium calculations must remain:

- jurisdiction-aware
- rule-driven
- deterministic
- traceable
- correction-capable

Premium outputs shall integrate with taxable wage formation, accumulator mutation, and downstream posting workflows.

---

## 1. Scope of Premium Pay

Supported premium categories: Daily Overtime, Weekly Overtime, Double Time, Holiday Premium, Shift Differential, Weekend Premium, Callback Pay, On-Call Premium, Minimum Pay Guarantees.

## 2. Core Premium_Rule Entity

Premium_Rule_ID, Rule_Name, Premium_Type, Jurisdiction_ID, Effective_Start_Date, Effective_End_Date, Status.

Additional rule attributes may include:

Rule_Family  
Rule_Version_ID  
Applicability_Context  
Priority  
Specificity_Score  
Rule_Set_Reference  

These attributes support deterministic rule selection through Rule_Resolution_Engine.

## 3. Threshold Definitions

Premium eligibility thresholds define when premium pay applies. Examples: daily threshold: 8 hours; weekly threshold: 40 hours; holiday work: entire shift premium; callback minimum: 2-hour minimum pay.

Threshold evaluation shall remain traceable to:

- Work_Date
- Pay_Period_ID
- Employee_ID
- Jurisdiction_ID
- Time_Entry_ID

This ensures that premium eligibility decisions remain reconstructable during replay and correction workflows.

## 4. Premium Rate Structure

Premium calculations may use: multiplier-based rates (1.5x, 2.0x), flat premium amounts, or tiered multipliers. Example: shift differential at +$1.25 per hour.

## 5. Jurisdictional Rule Support

Premium rules must vary by jurisdiction. Examples: federal overtime rules, state-specific overtime thresholds, union-specific premium rules. Jurisdiction_ID must determine applicable rules.

## 6. Premium Calculation Flow

Typical governed premium flow:

1. Determine base hours from approved time entries.
2. Resolve applicable premium rule through Rule_Resolution_Engine.
3. Apply overtime or premium thresholds.
4. Apply premium multipliers or premium amounts.
5. Apply minimum guarantees where applicable.
6. Generate premium earnings result lines.
7. Associate result lines with Employee Payroll Result.
8. Forward result lines for taxable wage formation and accumulator impact processing.

All premium computation steps must remain ordered, explicit, and auditable.

## 6.1 Interaction with Taxable Wage Formation

Premium earnings contribute to taxable wage formation.

Premium result lines shall:

- participate in jurisdiction-specific taxable wage calculations
- influence wage-base thresholds where applicable
- remain identifiable as premium-origin earnings

Tax treatment shall remain governed by Tax_Classification_and_Obligation_Model.

## 7. Interaction with Time Entries

Overtime hours derived from weekly totals. Holiday premium derived from holiday calendar. Callback premium derived from call-back events.

Premium derivation shall remain traceable to:

Time_Entry_ID  
Scheduling_Context_ID  
Shift_ID  
Holiday_Calendar_ID  

This ensures that premium calculations can be reconstructed during audit and replay.

## 8. Retroactive Adjustments

Premium calculations must support retroactive changes, including:

- corrected time entries
- policy updates
- jurisdiction rule changes
- scheduling corrections

Retroactive recalculation shall:

- preserve original premium result lineage
- generate correction-aware premium outputs
- maintain linkage between original and corrected premium calculations
- integrate with Payroll_Adjustment_and_Correction_Model

Historical premium results shall never be silently overwritten.

## 9. Relationship to Other Models

This model integrates with:

- Time_Entry_and_Worked_Time_Model
- Scheduling_and_Shift_Model
- Rule_Resolution_Engine
- Policy_and_Rule_Execution_Model
- Earnings_and_Deductions_Computation_Model
- Employee_Payroll_Result_Model
- Accumulator_Impact_Model
- Tax_Classification_and_Obligation_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Multi_Context_Calendar_Model
- Correction_and_Immutability_Model
