# Overtime_and_Premium_Pay_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Overtime_and_Premium_Pay_Model.md` |
| **Domain** | Core |
| **Related Documents** | Time_Entry_and_Worked_Time_Model, Scheduling_and_Shift_Model, Earnings_and_Deductions_Computation_Model, Jurisdiction_and_Compliance_Rules_Model, Correction_and_Immutability_Model |

## Purpose

Defines calculation structures and rule behaviours governing overtime, premium pay, and special wage multipliers triggered by worked time conditions.

---

## 1. Scope of Premium Pay

Supported premium categories: Daily Overtime, Weekly Overtime, Double Time, Holiday Premium, Shift Differential, Weekend Premium, Callback Pay, On-Call Premium, Minimum Pay Guarantees.

## 2. Core Premium_Rule Entity

Premium_Rule_ID, Rule_Name, Premium_Type, Jurisdiction_ID, Effective_Start_Date, Effective_End_Date, Status.

## 3. Threshold Definitions

Premium eligibility thresholds define when premium pay applies. Examples: daily threshold: 8 hours; weekly threshold: 40 hours; holiday work: entire shift premium; callback minimum: 2-hour minimum pay.

## 4. Premium Rate Structure

Premium calculations may use: multiplier-based rates (1.5x, 2.0x), flat premium amounts, or tiered multipliers. Example: shift differential at +$1.25 per hour.

## 5. Jurisdictional Rule Support

Premium rules must vary by jurisdiction. Examples: federal overtime rules, state-specific overtime thresholds, union-specific premium rules. Jurisdiction_ID must determine applicable rules.

## 6. Premium Calculation Flow

Determine base hours, apply overtime thresholds, apply premium multipliers, apply minimum guarantees, generate premium earnings lines.

## 7. Interaction with Time Entries

Overtime hours derived from weekly totals. Holiday premium derived from holiday calendar. Callback premium derived from call-back events.

## 8. Retroactive Adjustments

Premium calculations must support retroactive changes: corrected time entries, policy updates, jurisdiction rule changes. Retroactive recalculation must preserve historical traceability.

## 9. Relationship to Other Models

This model integrates with: Time_Entry_and_Worked_Time_Model, Payroll_Check_Model, Multi_Context_Calendar_Model, Operational_Reporting_and_Analytics_Model, Correction_and_Immutability_Model.
