# Leave_and_Absence_Management_Model

Version: v0.1

## 1. Purpose

Define structures and lifecycle management for employee leaves and
absences, including paid and unpaid leave types, eligibility, duration
tracking, and payroll impact behavior.

## 2. Leave Scope

Supported leave types include:\
\
Paid Time Off (PTO)\
Vacation\
Sick Leave\
Holiday Leave\
Personal Leave\
Leave of Absence (LOA)\
Family and Medical Leave (FMLA)\
Short-Term Disability\
Long-Term Disability\
Military Leave\
Jury Duty Leave

## 3. Core Leave_Request Entity

Leave_Request\
\
Leave_Request_ID\
Employee_ID\
Employment_ID\
Leave_Type\
Request_Date\
Leave_Start_Date\
Leave_End_Date\
Leave_Status\
Leave_Reason_Code

## 4. Leave_Type Definition

Leave types must be configurable.\
\
Leave_Type attributes:\
\
Leave_Type_ID\
Leave_Type_Name\
Paid_or_Unpaid_Flag\
Accrual_Eligible_Flag\
Maximum_Duration\
Carryover_Allowed_Flag

## 5. Leave Status Lifecycle

Leave requests progress through states.\
\
Status examples:\
\
Requested\
Approved\
Denied\
Scheduled\
Active\
Completed\
Cancelled

## 6. Leave Duration Tracking

Leave duration tracking includes:\
\
Total_Requested_Days\
Total_Approved_Days\
Leave_Balance_Impact\
Remaining_Balance\
\
Leave balances must update in alignment with accrual models.

## 7. Payroll Impact Handling

Leaves affect payroll behavior.\
\
Examples:\
\
Paid leave → Earnings substitution\
Unpaid leave → Earnings suppression\
Disability leave → Special pay codes\
Holiday leave → Scheduled earnings\
\
Payroll must reference leave data when calculating earnings.

## 8. Leave Accrual Integration

Leave balances may accumulate over time.\
\
Accrual attributes:\
\
Accrual_Rate\
Accrual_Frequency\
Maximum_Accrual_Limit\
Carryover_Rules\
\
Accrual behavior integrates with accumulator models.

## 9. Compliance Leave Handling

Certain leave types require regulatory compliance.\
\
Examples:\
\
FMLA leave tracking\
Military leave protections\
State-specific leave requirements\
\
Compliance rules must be configurable by jurisdiction.

## 10. Return to Work Handling

Return-to-work events restore employee status.\
\
Return attributes:\
\
Return_Date\
Work_Status_Restored\
Benefit_Reactivation_Flag\
Payroll_Reactivation_Flag

## 11. Historical Tracking and Audit

All leave activity must be historically preserved.\
\
Audit requirements include:\
\
Leave approvals\
Leave changes\
Duration adjustments\
Balance changes\
\
Historical data supports compliance and payroll replay.

## 12. Relationship to Other Models

This model integrates with:\
\
Employee_Event_and_Status_Change_Model\
Eligibility_and_Enrollment_Lifecycle_Model\
Payroll_Check_Model\
Accumulator_and_Balance_Model\
Multi_Context_Calendar_Model\
Correction_and_Immutability_Model
