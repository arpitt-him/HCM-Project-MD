# Time_Entry_and_Worked_Time_Model

Version: v0.1

## 1. Purpose

Define how employee worked time is captured, classified, approved,
corrected, and supplied to payroll, accrual, analytics, and compliance
processes.

## 2. Scope of Time Capture

Supported time categories include:\
\
Regular worked time\
Overtime\
Double time\
Holiday worked\
Paid leave time\
Unpaid leave time\
On-call time\
Call-back time\
Travel time\
Training time

## 3. Core Time_Entry Entity

Time_Entry\
\
Time_Entry_ID\
Employee_ID\
Employment_ID\
Work_Date\
Start_Time\
End_Time\
Duration\
Time_Category\
Time_Status\
Source_System_ID\
Entry_Method

## 4. Time Category Classification

Time entries must be classified for downstream use.\
\
Examples:\
\
REGULAR\
OVERTIME\
DOUBLE_TIME\
HOLIDAY_WORKED\
PTO_USED\
SICK_USED\
UNPAID_LEAVE\
ON_CALL\
TRAVEL\
TRAINING

## 5. Approval Lifecycle

Time entries progress through approval states.\
\
Status examples:\
\
Draft\
Submitted\
Approved\
Rejected\
Corrected\
Locked\
\
Payroll processing should only consume approved or otherwise authorized
time.

## 6. Worked Time Aggregation

Time entries may aggregate into period totals.\
\
Examples:\
\
Daily totals\
Weekly totals\
Pay period totals\
Department totals\
\
Aggregation supports overtime calculation, payroll earnings generation,
and analytics.

## 7. Payroll Integration

Worked time drives payroll earnings and premium calculations.\
\
Examples:\
\
Regular hours → Standard earnings\
Overtime hours → Overtime earnings\
Holiday worked → Special earnings code\
Leave time → Leave earnings substitution or suppression\
\
Payroll must consume classified and approved time data.

## 8. Overtime and Premium Rules

Time entries may trigger premium pay calculations.\
\
Rule considerations include:\
\
Daily overtime thresholds\
Weekly overtime thresholds\
Holiday premium rules\
Callback minimums\
Jurisdiction-specific overtime laws

## 9. Correction and Retroactive Handling

Time entries may be corrected after submission.\
\
Correction attributes:\
\
Original_Time_Entry_ID\
Correction_Type\
Corrected_Duration\
Retroactive_Flag\
Affected_Payroll_Period\
\
Corrections must preserve historical traceability and trigger payroll
review when needed.

## 10. Accrual and Entitlement Interaction

Worked time may affect accrual behavior.\
\
Examples:\
\
Hours worked-based PTO accrual\
Leave consumption from approved leave-related time entries\
Service-based entitlement eligibility\
\
Time data must integrate with accrual models where required.

## 11. Compliance and Audit

Time capture must support compliance and audit controls.\
\
Examples:\
\
Timesheet audit trail\
Manager approval history\
Worked time retention\
Jurisdiction-specific labor law evidence

## 12. Relationship to Other Models

This model integrates with:\
\
Payroll_Check_Model\
Accrual_and_Entitlement_Model\
Leave_and_Absence_Management_Model\
Employee_Event_and_Status_Change_Model\
Operational_Reporting_and_Analytics_Model\
Correction_and_Immutability_Model
