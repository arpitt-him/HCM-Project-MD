# Leave_and_Absence_Management_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Reviewed |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Leave_and_Absence_Management_Model.md` |
| **Domain** | Core |
| **Related Documents** | Accrual_and_Entitlement_Model, Employee_Event_and_Status_Change_Model, Accumulator_and_Balance_Model, Multi_Context_Calendar_Model, Correction_and_Immutability_Model |

## Purpose

Defines structures and lifecycle management for employee leaves and absences, including paid and unpaid leave types, eligibility, duration tracking, and payroll impact behaviour.

---

## 1. Leave Scope

Supported leave types: PTO, Vacation, Sick Leave, Holiday Leave, Personal Leave, LOA, FMLA, Short-Term Disability, Long-Term Disability, Military Leave, Jury Duty Leave.

## 2. Core Leave_Request Entity

Leave_Request_ID, Employee_ID, Employment_ID, Leave_Type, Request_Date, Leave_Start_Date, Leave_End_Date, Leave_Status, Leave_Reason_Code.

## 3. Leave_Type Definition

Leave_Type_ID, Leave_Type_Name, Paid_or_Unpaid_Flag, Accrual_Eligible_Flag, Maximum_Duration, Carryover_Allowed_Flag.

## 4. Leave Status Lifecycle

Requested, Approved, Denied, Scheduled, Active, Completed, Cancelled.

## 5. Leave Duration Tracking

Total_Requested_Days, Total_Approved_Days, Leave_Balance_Impact, Remaining_Balance. Leave balances must update in alignment with accrual models.

## 6. Payroll Impact Handling

Paid leave generates earnings substitution signals. Unpaid leave generates earnings suppression signals. Disability leave generates special pay code signals. Payroll must reference leave data when calculating earnings.

## 7. Leave Accrual Integration

Accrual_Rate, Accrual_Frequency, Maximum_Accrual_Limit, Carryover_Rules. Accrual behaviour integrates with accumulator models.

## 8. Compliance Leave Handling

FMLA leave tracking, military leave protections, state-specific leave requirements. Compliance rules must be configurable by jurisdiction.

## 9. Return to Work Handling

Return_Date, Work_Status_Restored, Benefit_Reactivation_Flag, Payroll_Reactivation_Flag.

## 10. Historical Tracking and Audit

All leave activity must be historically preserved: leave approvals, changes, duration adjustments, balance changes. Historical data supports compliance and payroll replay.

## 11. Relationship to Other Models

This model integrates with: Employee_Event_and_Status_Change_Model, Eligibility_and_Enrollment_Lifecycle_Model, Payroll_Check_Model, Accumulator_and_Balance_Model, Multi_Context_Calendar_Model, Correction_and_Immutability_Model.
