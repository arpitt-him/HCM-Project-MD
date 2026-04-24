# Time_Entry_and_Worked_Time_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.3 |
| **Status** | Reviewed |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Time_Entry_and_Worked_Time_Model.md` |
| **Domain** | Core |
| **Related Documents** | PRD-1100_Time_and_Attendance, Scheduling_and_Shift_Model, Overtime_and_Premium_Pay_Model, Accrual_and_Entitlement_Model, Earnings_and_Deductions_Computation_Model, Correction_and_Immutability_Model, STATE-TIM_Time_Entry, EXC-TIM_Time_Attendance_Exceptions |

## Purpose

Defines how employee worked time is captured, classified, approved, corrected, and supplied to payroll, accrual, analytics, and compliance processes.

This model governs the authoritative lifecycle of worked time records that serve as primary computation inputs to payroll and accrual processing.

Worked time must remain:

- versioned
- auditable
- correction-aware
- jurisdiction-sensitive
- replay-safe

Approved time entries form governed inputs to Employee Payroll Result generation and premium eligibility determination.

---

## 1. Scope of Time Capture

Supported time categories: Regular worked time, Overtime, Double time, Holiday worked, Paid leave time, Unpaid leave time, On-call time, Call-back time, Travel time, Training time.

## 2. Core Time_Entry Entity

Time_Entry_ID, Employee_ID, Employment_ID, Work_Date, Start_Time, End_Time, Duration, Time_Category, Time_Status, Source_System_ID, Entry_Method.

Additional lineage attributes may include:

Time_Entry_Version_ID  
Original_Time_Entry_ID  
Parent_Correction_ID  
Run_Scope_Eligibility_Flag  
Payroll_Consumption_Status  

These attributes support replay-safe recalculation and correction tracking.

## 3. Time Category Classification

REGULAR, OVERTIME, DOUBLE_TIME, HOLIDAY_WORKED, PTO_USED, SICK_USED, UNPAID_LEAVE, ON_CALL, TRAVEL, TRAINING.

## 4. Approval Lifecycle

Time entry approval is governed by `STATE-TIM_Time_Entry`. The full state model, transition rules, guard conditions, and invalid transitions are defined there. The summary relevant to this model is:

| State | Code | Payroll Eligible? |
|---|---|---|
| Draft | STATE-TIM-001 | No |
| Submitted | STATE-TIM-002 | No |
| Approved | STATE-TIM-003 | Yes |
| Rejected | STATE-TIM-004 | No |
| Corrected | STATE-TIM-005 | No |
| Locked | STATE-TIM-006 | Yes — consumed by payroll run; immutable |
| Voided | STATE-TIM-007 | No — terminal |

Only time entries in STATE-TIM-003 (Approved) or STATE-TIM-006 (Locked) may be consumed by payroll execution.

Time entries in Draft or Submitted status shall remain excluded from payroll scope resolution. Unapproved entries at payroll cutoff generate EXC-TIM-002.

Locked entries represent payroll-consumed state and must remain immutable except through governed correction workflows. Corrections to Locked entries create new versioned entries linked via Original_Time_Entry_ID; the original entry remains permanently Locked.

All approval state transitions shall be audit-logged with actor identity, timestamp, and reason code where applicable.

Approval authority is role-scoped per the Security_and_Access_Control_Model:
- Employees may submit their own entries
- Managers may approve entries for direct reports within their reporting scope
- HR administrators may approve entries for any employee within their access scope

## 5. Worked Time Aggregation

Time entries may aggregate into daily, weekly, pay period, and department totals. Aggregation supports overtime calculation, payroll earnings generation, and analytics.

Aggregated time values shall remain derivable from individual time entry records.

No aggregation shall exist without traceable linkage to contributing Time_Entry_ID values.

Aggregation outputs shall support replay during:

- overtime recalculation
- retroactive correction
- jurisdictional policy updates

## 6. Payroll Integration

Regular hours generate standard earnings. Overtime hours generate overtime earnings. Holiday worked generates special earnings code. Leave time generates leave earnings substitution or suppression.

## 7. Overtime and Premium Rules

Time entries may trigger premium pay: daily overtime thresholds, weekly overtime thresholds, holiday premium rules, callback minimums, jurisdiction-specific overtime laws.

Premium eligibility shall be resolved through Rule_Resolution_Engine using:

- Jurisdiction_ID
- Employee classification
- Work schedule context
- Applicable policy rules

Premium determination decisions must remain reproducible during replay workflows.

## 8. Correction and Retroactive Handling

Time corrections shall preserve original lineage using:

Original_Time_Entry_ID  
Correction_Type  
Corrected_Duration  
Retroactive_Flag  
Affected_Payroll_Period  

Corrections must:

- preserve original time history
- generate new versioned entries
- trigger payroll recalculation review
- maintain correction lineage across affected payroll runs

Historical entries shall never be silently overwritten.

## 9. Accrual and Entitlement Interaction

Hours worked-based PTO accrual, leave consumption from approved leave-related time entries, service-based entitlement eligibility. Time data must integrate with accrual models where required.

## 10. Compliance and Audit

Timesheet audit trail, manager approval history, worked time retention, jurisdiction-specific labour law evidence.

## 11. Relationship to Other Models

This model integrates with:

- Scheduling_and_Shift_Model
- Overtime_and_Premium_Pay_Model
- Rule_Resolution_Engine
- Earnings_and_Deductions_Computation_Model
- Employee_Payroll_Result_Model
- Payroll_Run_Model
- Run_Scope_Model
- Accumulator_Impact_Model
- Payroll_Adjustment_and_Correction_Model
- Accrual_and_Entitlement_Model
- Multi_Context_Calendar_Model
- Correction_and_Immutability_Model
- Operational_Reporting_and_Analytics_Model
- Security_and_Access_Control_Model
- Data_Retention_and_Archival_Model
- Exception_and_Work_Queue_Model
- STATE-TIM_Time_Entry
- PRD-1100_Time_and_Attendance