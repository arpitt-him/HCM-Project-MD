# Time_Entry_and_Worked_Time_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Reviewed |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Time_Entry_and_Worked_Time_Model.md` |
| **Domain** | Core |
| **Related Documents** | Scheduling_and_Shift_Model, Overtime_and_Premium_Pay_Model, Accrual_and_Entitlement_Model, Earnings_and_Deductions_Computation_Model, Correction_and_Immutability_Model |

## Purpose

Defines how employee worked time is captured, classified, approved, corrected, and supplied to payroll, accrual, analytics, and compliance processes.

---

## 1. Scope of Time Capture

Supported time categories: Regular worked time, Overtime, Double time, Holiday worked, Paid leave time, Unpaid leave time, On-call time, Call-back time, Travel time, Training time.

## 2. Core Time_Entry Entity

Time_Entry_ID, Employee_ID, Employment_ID, Work_Date, Start_Time, End_Time, Duration, Time_Category, Time_Status, Source_System_ID, Entry_Method.

## 3. Time Category Classification

REGULAR, OVERTIME, DOUBLE_TIME, HOLIDAY_WORKED, PTO_USED, SICK_USED, UNPAID_LEAVE, ON_CALL, TRAVEL, TRAINING.

## 4. Approval Lifecycle

Draft, Submitted, Approved, Rejected, Corrected, Locked. Payroll processing should only consume approved or otherwise authorised time.

## 5. Worked Time Aggregation

Time entries may aggregate into daily, weekly, pay period, and department totals. Aggregation supports overtime calculation, payroll earnings generation, and analytics.

## 6. Payroll Integration

Regular hours generate standard earnings. Overtime hours generate overtime earnings. Holiday worked generates special earnings code. Leave time generates leave earnings substitution or suppression.

## 7. Overtime and Premium Rules

Time entries may trigger premium pay: daily overtime thresholds, weekly overtime thresholds, holiday premium rules, callback minimums, jurisdiction-specific overtime laws.

## 8. Correction and Retroactive Handling

Original_Time_Entry_ID, Correction_Type, Corrected_Duration, Retroactive_Flag, Affected_Payroll_Period. Corrections must preserve historical traceability and trigger payroll review when needed.

## 9. Accrual and Entitlement Interaction

Hours worked-based PTO accrual, leave consumption from approved leave-related time entries, service-based entitlement eligibility. Time data must integrate with accrual models where required.

## 10. Compliance and Audit

Timesheet audit trail, manager approval history, worked time retention, jurisdiction-specific labour law evidence.

## 11. Relationship to Other Models

This model integrates with: Overtime_and_Premium_Pay_Model, Scheduling_and_Shift_Model, Payroll_Check_Model, Accrual_and_Entitlement_Model, Correction_and_Immutability_Model, Operational_Reporting_and_Analytics_Model.
