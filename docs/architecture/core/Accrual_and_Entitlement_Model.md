# Accrual_and_Entitlement_Model

Version: v0.1

## 1. Purpose

Define how leave, time-off, and related employee entitlements accrue,
are consumed, carry over, expire, and remain auditable across payroll
and employee lifecycle events.

## 2. Scope of Entitlements

Supported entitlement categories include:\
\
Paid Time Off (PTO)\
Vacation\
Sick Leave\
Personal Days\
Floating Holidays\
Compensatory Time\
Service-based Leave\
Special Company Leave Banks

## 3. Core Entitlement_Plan Entity

Entitlement_Plan\
\
Entitlement_Plan_ID\
Plan_Name\
Plan_Type\
Organization_ID\
Effective_Start_Date\
Effective_End_Date\
Status\
\
Plan_Type examples:\
\
PTO\
VACATION\
SICK\
COMP_TIME\
FLOATING_HOLIDAY\
OTHER

## 4. Accrual Rule Definition

Accrual_Rule\
\
Accrual_Rule_ID\
Entitlement_Plan_ID\
Accrual_Method\
Accrual_Frequency\
Accrual_Rate\
Maximum_Balance\
Carryover_Rule\
Expiration_Rule\
\
Accrual_Method examples:\
\
FIXED_PER_PERIOD\
HOURS_WORKED_BASED\
SERVICE_TIER_BASED\
EVENT_DRIVEN

## 5. Entitlement Balance Entity

Entitlement_Balance\
\
Entitlement_Balance_ID\
Employee_ID\
Employment_ID\
Entitlement_Plan_ID\
Balance_Period_ID\
Available_Balance\
Pending_Balance\
Used_Balance\
Expired_Balance\
Carried_Over_Balance

## 6. Accrual Triggers

Balances may accrue based on:\
\
Payroll completion\
Hours worked\
Service anniversaries\
Beginning of period\
Manual adjustment\
Policy event\
\
Accrual timing must align with payroll and calendar contexts.

## 7. Consumption and Deduction

Entitlements are consumed by approved leave events.\
\
Consumption attributes include:\
\
Consumption_ID\
Leave_Request_ID\
Entitlement_Plan_ID\
Consumed_Amount\
Consumption_Date\
Consumption_Status\
\
Consumption must reduce balances in an auditable manner.

## 8. Carryover and Expiration

Plans may define year-end or period-end behavior.\
\
Examples:\
\
Unlimited carryover\
Carryover up to capped hours\
Use-it-or-lose-it expiration\
Jurisdiction-protected balances\
\
Carryover and expiration must reference the correct calendar context.

## 9. Service-Tier and Eligibility Interaction

Accrual rates may vary by service or status.\
\
Examples:\
\
0--1 years service → 3.08 hours per pay period\
1--5 years service → 4.62 hours per pay period\
Part-time employees → prorated accrual\
\
Accrual rules must integrate with employee status and assignment data.

## 10. Manual Adjustments and Corrections

Balances may change due to corrections or discretionary adjustments.\
\
Adjustment attributes:\
\
Adjustment_ID\
Adjustment_Type\
Adjustment_Amount\
Effective_Date\
Reason_Code\
Approval_Status\
\
Adjustments must preserve historical traceability.

## 11. Reporting and Audit Support

Entitlement reporting must support:\
\
Current balances\
Projected balances\
Used balances\
Expired balances\
Carryover analysis\
Audit history\
\
Historical replay must reconstruct prior balances accurately.

## 12. Relationship to Other Models

This model integrates with:\
\
Leave_and_Absence_Management_Model\
Accumulator_and_Balance_Model\
Employee_Event_and_Status_Change_Model\
Multi_Context_Calendar_Model\
Correction_and_Immutability_Model\
Operational_Reporting_and_Analytics_Model
