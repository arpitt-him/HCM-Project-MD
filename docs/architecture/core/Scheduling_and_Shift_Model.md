# Scheduling_and_Shift_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Scheduling_and_Shift_Model.md` |
| **Domain** | Core |
| **Related Documents** | Time_Entry_and_Worked_Time_Model, Overtime_and_Premium_Pay_Model, Holiday_and_Special_Calendar_Model, Employee_Event_and_Status_Change_Model, Operational_Reporting_and_Analytics_Model |

## Purpose

Defines structures governing employee work schedules, shift definitions, planned working time, and shift-based premium eligibility.

This model governs the planned-time structures that inform:

- time-entry interpretation
- overtime and premium eligibility
- worked-time exception analysis
- payroll computation context
- compliance validation

Schedules and shifts do not represent payroll results directly, but they provide governed context that influences payroll computation and premium result generation.

---

## 1. Scope of Scheduling

Supported scheduling constructs: Fixed, Rotating, Shift-based, Flexible, Part-time, Seasonal, On-call schedules.

## 2. Core Schedule Entity

Schedule_ID, Schedule_Name, Schedule_Type, Organization_ID, Effective_Start_Date, Effective_End_Date, Status.
Schedule_Type examples: FIXED, ROTATING, FLEXIBLE, SHIFT_BASED.

Additional schedule attributes may include:

Schedule_Version_ID  
Rule_Set_Reference  
Jurisdiction_ID  
Premium_Policy_Reference  
Calendar_Context_ID  

These attributes support deterministic interpretation of planned work context during replay and retroactive correction workflows.

## 3. Shift Definition

Shift_ID, Shift_Name, Shift_Start_Time, Shift_End_Time, Shift_Duration, Shift_Type, Shift_Premium_Eligible_Flag.
Shift_Type examples: DAY, EVENING, NIGHT, WEEKEND, ON_CALL.

Additional shift attributes may include:

Minimum_Rest_Requirement  
Meal_Break_Requirement  
Premium_Rule_Reference  
Callback_Eligible_Flag  
On_Call_Eligible_Flag  

These attributes support jurisdiction-aware premium resolution and labour-rule compliance validation.

## 4. Schedule Pattern Structure

Pattern_ID, Schedule_ID, Pattern_Type, Cycle_Length, Pattern_Description.
Examples: 5 days on / 2 days off; 4-day compressed schedule; rotating 12-hour shifts.

## 5. Employee Schedule Assignment

Assignment_ID, Employee_ID, Employment_ID, Schedule_ID, Shift_ID, Assignment_Start_Date, Assignment_End_Date. Assignments determine planned working expectations.

Schedule assignments shall remain effective-dated and historically queryable.

Additional assignment attributes may include:

Assignment_Version_ID  
Original_Assignment_ID  
Source_Event_ID  
Approval_Reference_ID  

These attributes support reconstruction of the planned schedule context that was in force when worked time was recorded and later consumed by payroll.

## 6. Planned vs Actual Time

Schedules represent planned time.

Time entries represent actual time worked or reported.

Differences between planned and actual time may drive:

- overtime eligibility
- premium eligibility
- attendance exceptions
- payroll result differences
- compliance review

Planned-vs-actual evaluation shall remain traceable to:

- Schedule_ID
- Shift_ID
- Assignment_ID
- Time_Entry_ID

## 7. Shift Premium Interaction

Shift assignments may trigger premium pay, including:

- night shift differential
- weekend premium
- holiday shift premium
- callback premium
- on-call premium

Shift premium eligibility shall integrate with Overtime_and_Premium_Pay_Model and be resolved through Rule_Resolution_Engine using governed schedule, shift, jurisdiction, and employee context.

Premium-triggering schedule attributes must remain traceable during replay and correction workflows.

## 8. Schedule Changes

Change_Date, New_Shift_Assignment, Reason_Code, Approval_Status.

Schedule changes must preserve historical schedule records.

Schedule corrections shall:

- preserve prior assignment history
- create new effective-dated assignment states
- remain traceable to source events and approvals
- support replay of time interpretation and premium eligibility

Historical schedule assignments shall never be silently overwritten.

## 9. Compliance and Labour Rules

Scheduling must respect: minimum rest periods, maximum shift duration, required meal breaks, union scheduling agreements.

Scheduling compliance rules may participate in:

- time-entry validation
- premium eligibility validation
- payroll exception generation
- labour-law evidence retention

Compliance-sensitive schedule violations shall remain traceable to governed exception handling workflows where policy requires.

## 10. Relationship to Other Models

This model integrates with:

- Time_Entry_and_Worked_Time_Model
- Overtime_and_Premium_Pay_Model
- Rule_Resolution_Engine
- Earnings_and_Deductions_Computation_Model
- Employee_Payroll_Result_Model
- Payroll_Exception_Model
- Payroll_Adjustment_and_Correction_Model
- Holiday_and_Special_Calendar_Model
- Employee_Event_and_Status_Change_Model
- Operational_Reporting_and_Analytics_Model
