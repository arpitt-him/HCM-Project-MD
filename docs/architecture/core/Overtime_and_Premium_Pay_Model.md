# Overtime_and_Premium_Pay_Model

Version: v0.1

## 1. Purpose

Define calculation structures and rule behaviors governing overtime,
premium pay, and special wage multipliers triggered by worked time
conditions.

## 2. Scope of Premium Pay

Supported premium categories include:\
\
Daily Overtime\
Weekly Overtime\
Double Time\
Holiday Premium\
Shift Differential\
Weekend Premium\
Callback Pay\
On-Call Premium\
Minimum Pay Guarantees

## 3. Core Premium_Rule Entity

Premium_Rule\
\
Premium_Rule_ID\
Rule_Name\
Premium_Type\
Jurisdiction_ID\
Effective_Start_Date\
Effective_End_Date\
Status

## 4. Threshold Definitions

Premium eligibility thresholds define when premium pay applies.\
\
Examples:\
\
Daily threshold → 8 hours\
Weekly threshold → 40 hours\
Holiday work → Entire shift premium\
Callback minimum → 2-hour minimum pay

## 5. Premium Rate Structure

Premium calculations may use:\
\
Multiplier-based rates\
Flat premium amounts\
Tiered multipliers\
\
Examples:\
\
1.5x rate for overtime\
2.0x rate for double time\
Shift differential → +\$1.25 per hour

## 6. Jurisdictional Rule Support

Premium rules must vary by jurisdiction.\
\
Examples:\
\
Federal overtime rules\
State-specific overtime thresholds\
Union-specific premium rules\
\
Jurisdiction_ID must determine applicable rules.

## 7. Premium Calculation Flow

Premium calculations follow ordered evaluation.\
\
Typical flow:\
\
Determine base hours\
Apply overtime thresholds\
Apply premium multipliers\
Apply minimum guarantees\
Generate premium earnings lines

## 8. Interaction with Time Entries

Premium rules depend on classified time entries.\
\
Examples:\
\
Overtime hours derived from weekly totals\
Holiday premium derived from holiday calendar\
Callback premium derived from call-back events

## 9. Retroactive Adjustments

Premium calculations must support retroactive changes.\
\
Examples:\
\
Corrected time entries\
Policy updates\
Jurisdiction rule changes\
\
Retroactive recalculation must preserve historical traceability.

## 10. Reporting and Audit Support

Premium pay reporting supports:\
\
Overtime summaries\
Premium pay totals\
Compliance audits\
Labor law reporting\
\
Audit trails must preserve premium calculation logic.

## 11. Relationship to Other Models

This model integrates with:\
\
Time_Entry_and_Worked_Time_Model\
Payroll_Check_Model\
Multi_Context_Calendar_Model\
Operational_Reporting_and_Analytics_Model\
Correction_and_Immutability_Model
