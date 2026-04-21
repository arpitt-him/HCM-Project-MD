# Accrual_and_Entitlement_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Accrual_and_Entitlement_Model.md` |
| **Domain** | Core |
| **Related Documents** | Leave_and_Absence_Management_Model, Accumulator_and_Balance_Model, Multi_Context_Calendar_Model, Correction_and_Immutability_Model, Employee_Event_and_Status_Change_Model |

## Purpose

Defines how leave, time-off, and related employee entitlements accrue, are consumed, carry over, expire, and remain auditable across payroll and employee lifecycle events.

This model governs entitlement state mutation for leave-related balances and other time-off rights.

Entitlement behaviour must remain:

- rule-driven
- effective-dated
- replay-safe
- correction-capable
- auditable

Accrual and entitlement outcomes may be triggered by payroll completion, worked time, employee lifecycle events, leave consumption, or governed adjustments.

---

## 1. Scope of Entitlements

Supported entitlement categories include: Paid Time Off (PTO), Vacation, Sick Leave, Personal Days, Floating Holidays, Compensatory Time, Service-based Leave, Special Company Leave Banks.

## 2. Core Entitlement_Plan Entity

Entitlement_Plan: Entitlement_Plan_ID, Plan_Name, Plan_Type, Organization_ID, Effective_Start_Date, Effective_End_Date, Status.
Plan_Type examples: PTO, VACATION, SICK, COMP_TIME, FLOATING_HOLIDAY, OTHER.

Additional plan attributes may include:

Plan_Version_ID  
Eligibility_Profile_ID  
Jurisdiction_ID  
Rule_Set_Reference  

These attributes support deterministic entitlement evaluation across replay and correction workflows.

## 3. Accrual Rule Definition

Accrual_Rule: Accrual_Rule_ID, Entitlement_Plan_ID, Accrual_Method, Accrual_Frequency, Accrual_Rate, Maximum_Balance, Carryover_Rule, Expiration_Rule.
Accrual_Method examples: FIXED_PER_PERIOD, HOURS_WORKED_BASED, SERVICE_TIER_BASED, EVENT_DRIVEN.

Additional rule attributes may include:

Rule_Version_ID  
Trigger_Class  
Evaluation_Basis  
Mutation_Target  
Effective_Calendar_Context  

These attributes support deterministic accrual triggering, entitlement mutation, and replay reconstruction.

## 4. Entitlement Balance Entity

Entitlement_Balance: Entitlement_Balance_ID, Employee_ID, Employment_ID, Entitlement_Plan_ID, Balance_Period_ID, Available_Balance, Pending_Balance, Used_Balance, Expired_Balance, Carried_Over_Balance.

Additional balance attributes may include:

Balance_Version_ID  
Source_Trigger_ID  
Source_Event_Type  
Source_Period_ID  
Execution_Period_ID  

These attributes support reconstruction of how balances changed across payroll, leave, and correction events.

## 5. Accrual Triggers

Balances may accrue based on governed source events, including:

- payroll completion
- hours worked
- service anniversaries
- beginning of period
- manual adjustment
- policy event

Accrual timing must align with payroll and calendar contexts.

Each accrual trigger shall remain traceable to its originating event so that entitlement balance changes can be reconstructed during replay and correction workflows.

## 6. Consumption and Deduction

Consumption_ID, Leave_Request_ID, Entitlement_Plan_ID, Consumed_Amount, Consumption_Date, Consumption_Status.

Consumption must reduce balances in an auditable manner.

Entitlement consumption shall remain traceable to:

- Leave_Request_ID
- affected Time_Entry_ID values where applicable
- resulting payroll suppression or substitution behavior where applicable

Consumption events must remain deterministic and historically reconstructable.

## 7. Carryover and Expiration

Plans may define: unlimited carryover, carryover up to capped hours, use-it-or-lose-it expiration, or jurisdiction-protected balances. Carryover and expiration must reference the correct calendar context.

Carryover and expiration decisions shall remain traceable to:

- governing calendar context
- effective rule version
- jurisdiction-specific protections
- source entitlement balance state

These decisions must be reproducible during historical replay.

## 8. Service-Tier and Eligibility Interaction

Accrual rates may vary by service or status. Examples: 0-1 years service: 3.08 hours per pay period; 1-5 years: 4.62 hours per pay period; part-time: prorated accrual. Rules must integrate with employee status and assignment data.

Service-tier and eligibility determination shall be resolved through governed policy execution using employee status, assignment, and employment context.

Eligibility changes must remain historically reconstructable for replay and audit.

## 9. Manual Adjustments and Corrections

Adjustment_ID, Adjustment_Type, Adjustment_Amount, Effective_Date, Reason_Code, Approval_Status.

Adjustments must preserve historical traceability.

Manual and corrective changes shall remain linked to governed correction workflows and must not silently overwrite prior entitlement state.

Correction handling must preserve:

- original balance state
- adjustment lineage
- corrected balance outcome
- approval and effective-date context

## 10. Reporting and Audit Support

Entitlement reporting must support:

- current balances
- projected balances
- used balances
- expired balances
- carryover analysis
- audit history

Historical replay must reconstruct prior balances accurately, including:

- accrual events
- consumption events
- carryover and expiration outcomes
- manual adjustments
- correction lineage

## 11. Relationship to Other Models

This model integrates with:

- Leave_and_Absence_Management_Model
- Time_Entry_and_Worked_Time_Model
- Employee_Event_and_Status_Change_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Accumulator_Model_Detailed
- Rule_Resolution_Engine
- Policy_and_Rule_Execution_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Multi_Context_Calendar_Model
- Payroll_Calendar_Model
- Correction_and_Immutability_Model
