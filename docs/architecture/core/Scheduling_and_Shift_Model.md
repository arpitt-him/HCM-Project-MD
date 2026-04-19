# Scheduling_and_Shift_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Reviewed |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Scheduling_and_Shift_Model.md` |
| **Domain** | Core |
| **Related Documents** | Time_Entry_and_Worked_Time_Model, Overtime_and_Premium_Pay_Model, Holiday_and_Special_Calendar_Model, Employee_Event_and_Status_Change_Model, Operational_Reporting_and_Analytics_Model |

## Purpose

Defines structures governing employee work schedules, shift definitions, planned working time, and shift-based premium eligibility.

---

## 1. Scope of Scheduling

Supported scheduling constructs: Fixed, Rotating, Shift-based, Flexible, Part-time, Seasonal, On-call schedules.

## 2. Core Schedule Entity

Schedule_ID, Schedule_Name, Schedule_Type, Organization_ID, Effective_Start_Date, Effective_End_Date, Status.
Schedule_Type examples: FIXED, ROTATING, FLEXIBLE, SHIFT_BASED.

## 3. Shift Definition

Shift_ID, Shift_Name, Shift_Start_Time, Shift_End_Time, Shift_Duration, Shift_Type, Shift_Premium_Eligible_Flag.
Shift_Type examples: DAY, EVENING, NIGHT, WEEKEND, ON_CALL.

## 4. Schedule Pattern Structure

Pattern_ID, Schedule_ID, Pattern_Type, Cycle_Length, Pattern_Description.
Examples: 5 days on / 2 days off; 4-day compressed schedule; rotating 12-hour shifts.

## 5. Employee Schedule Assignment

Assignment_ID, Employee_ID, Employment_ID, Schedule_ID, Shift_ID, Assignment_Start_Date, Assignment_End_Date. Assignments determine planned working expectations.

## 6. Planned vs Actual Time

Schedules represent planned time. Time entries represent actual time. Differences may trigger: overtime eligibility, exception reporting, attendance review.

## 7. Shift Premium Interaction

Shift assignments may trigger premium pay: night shift differential, weekend premium, holiday shift premium. Shift premium eligibility integrates with premium rules.

## 8. Schedule Changes

Change_Date, New_Shift_Assignment, Reason_Code, Approval_Status. Changes must preserve historical schedule records.

## 9. Compliance and Labour Rules

Scheduling must respect: minimum rest periods, maximum shift duration, required meal breaks, union scheduling agreements.

## 10. Relationship to Other Models

This model integrates with: Time_Entry_and_Worked_Time_Model, Overtime_and_Premium_Pay_Model, Holiday_and_Special_Calendar_Model, Employee_Event_and_Status_Change_Model, Operational_Reporting_and_Analytics_Model.
