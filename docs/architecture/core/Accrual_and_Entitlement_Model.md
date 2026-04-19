# Accrual_and_Entitlement_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Accrual_and_Entitlement_Model.md` |
| **Domain** | Core |
| **Related Documents** | Leave_and_Absence_Management_Model, Accumulator_and_Balance_Model, Multi_Context_Calendar_Model, Correction_and_Immutability_Model, Employee_Event_and_Status_Change_Model |

## Purpose

Defines how leave, time-off, and related employee entitlements accrue, are consumed, carry over, expire, and remain auditable across payroll and employee lifecycle events.

---

## 1. Scope of Entitlements

Supported entitlement categories include: Paid Time Off (PTO), Vacation, Sick Leave, Personal Days, Floating Holidays, Compensatory Time, Service-based Leave, Special Company Leave Banks.

## 2. Core Entitlement_Plan Entity

Entitlement_Plan: Entitlement_Plan_ID, Plan_Name, Plan_Type, Organization_ID, Effective_Start_Date, Effective_End_Date, Status.
Plan_Type examples: PTO, VACATION, SICK, COMP_TIME, FLOATING_HOLIDAY, OTHER.

## 3. Accrual Rule Definition

Accrual_Rule: Accrual_Rule_ID, Entitlement_Plan_ID, Accrual_Method, Accrual_Frequency, Accrual_Rate, Maximum_Balance, Carryover_Rule, Expiration_Rule.
Accrual_Method examples: FIXED_PER_PERIOD, HOURS_WORKED_BASED, SERVICE_TIER_BASED, EVENT_DRIVEN.

## 4. Entitlement Balance Entity

Entitlement_Balance: Entitlement_Balance_ID, Employee_ID, Employment_ID, Entitlement_Plan_ID, Balance_Period_ID, Available_Balance, Pending_Balance, Used_Balance, Expired_Balance, Carried_Over_Balance.

## 5. Accrual Triggers

Balances may accrue based on: payroll completion, hours worked, service anniversaries, beginning of period, manual adjustment, or policy event. Accrual timing must align with payroll and calendar contexts.

## 6. Consumption and Deduction

Consumption_ID, Leave_Request_ID, Entitlement_Plan_ID, Consumed_Amount, Consumption_Date, Consumption_Status. Consumption must reduce balances in an auditable manner.

## 7. Carryover and Expiration

Plans may define: unlimited carryover, carryover up to capped hours, use-it-or-lose-it expiration, or jurisdiction-protected balances. Carryover and expiration must reference the correct calendar context.

## 8. Service-Tier and Eligibility Interaction

Accrual rates may vary by service or status. Examples: 0-1 years service: 3.08 hours per pay period; 1-5 years: 4.62 hours per pay period; part-time: prorated accrual. Rules must integrate with employee status and assignment data.

## 9. Manual Adjustments and Corrections

Adjustment_ID, Adjustment_Type, Adjustment_Amount, Effective_Date, Reason_Code, Approval_Status. Adjustments must preserve historical traceability.

## 10. Reporting and Audit Support

Entitlement reporting must support: current balances, projected balances, used balances, expired balances, carryover analysis, and audit history. Historical replay must reconstruct prior balances accurately.

## 11. Relationship to Other Models

This model integrates with: Leave_and_Absence_Management_Model, Accumulator_and_Balance_Model, Multi_Context_Calendar_Model, Employee_Event_and_Status_Change_Model, Correction_and_Immutability_Model, Payroll_Calendar_Model.
