# Eligibility_and_Enrollment_Lifecycle_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Eligibility_and_Enrollment_Lifecycle_Model.md` |
| **Domain** | Core |
| **Related Documents** | Benefit_and_Deduction_Configuration_Model, Employee_Assignment_Model, Multi_Context_Calendar_Model, Code_Classification_and_Mapping_Model, Correction_and_Immutability_Model |

## Purpose

Defines the lifecycle governing employee eligibility, enrollment, change events, and termination of benefit and deduction participation.

Ensures consistent timing, retroactivity control, payroll-impact alignment, and auditability.

This model governs how eligibility and enrollment state becomes a governed payroll input for deduction and contribution processing, while remaining replay-safe and correction-capable.

---

## 1. Lifecycle Overview

The enrollment lifecycle includes: Eligibility Determination, Enrollment Initiation, Coverage Activation, Change Events, Coverage Termination, Historical Preservation.

## 2. Eligibility Determination

Eligibility_Check: Eligibility_Check_ID, Employee_ID, Plan_ID, Eligibility_Status, Eligibility_Date, Eligibility_Reason.
Common eligibility triggers: hire date, employment status change, service duration thresholds, location or department assignment.

Eligibility determination shall be resolved through governed rule execution using:

- Employee event state
- Employment context
- Assignment context
- Payroll context
- Plan configuration

Eligibility outcomes must remain traceable and historically reconstructable.

## 3. Enrollment Event Entity

Enrollment_Event: Enrollment_Event_ID, Employee_ID, Plan_ID, Event_Type, Event_Date, Effective_Date, Coverage_Level, Event_Status.
Event_Type examples: INITIAL_ENROLLMENT, OPEN_ENROLLMENT, LIFE_EVENT_CHANGE, RETROACTIVE_ENROLLMENT, TERMINATION_EVENT.

Additional enrollment event attributes may include:

Enrollment_Event_Version_ID  
Source_Event_ID  
Source_Period_ID  
Execution_Period_ID  
Approval_Reference_ID  

These attributes support deterministic payroll timing and correction handling.

## 4. Coverage Activation Rules

Coverage_Start_Date, Payroll_Effective_Date, Waiting_Period, Eligibility_Window.
Examples: immediate coverage, first payroll after eligibility, first day of following month.

Coverage activation timing must remain reproducible during historical payroll replay.

Activation logic shall preserve the exact effective rule and timing basis used when deductions or contributions first became payroll-active.

## 5. Change Event Handling

Change_Event examples: Marriage, Birth or adoption, Divorce, Loss of other coverage, Employment status change. Each event must specify Change_Event_Type, Supporting_Documentation, and Effective_Date_Rules.

Change events shall remain traceable to their originating employee lifecycle events where applicable.

Enrollment change handling must preserve:

- triggering event
- effective date basis
- resulting coverage state
- payroll impact timing

## 6. Retroactive Adjustment Handling

Retroactive_Start_Date, Retroactive_End_Date, Adjustment_Method.

Adjustment_Method examples: Back-deduction, Refund processing, Imputed adjustment.

Retroactive enrollment changes shall remain linked to governed correction workflows and must preserve:

- original enrollment state
- corrected enrollment state
- affected payroll periods
- resulting deduction or contribution impacts
- resulting refund, arrears, or imputed-income consequences where applicable

## 7. Termination of Coverage

Coverage termination triggers: employee termination, voluntary plan cancellation, eligibility loss, end of coverage period.
Termination_Date, Final_Deduction_Date, Continuation_Eligibility_Flag.

Coverage termination must remain traceable to the final payroll periods in which deductions or contributions were permitted.

Termination timing must support deterministic final-deduction behaviour and continuation-processing decisions.

## 8. Continuation Coverage Support

Examples: COBRA continuation, extended benefit eligibility.
Continuation_Start_Date, Continuation_End_Date, Premium_Adjustment_Rules.

## 9. Historical Preservation

All enrollment states must remain historically preserved.

Historical tracking includes:

- enrollment history
- coverage level changes
- contribution changes
- termination records
- payroll-impact timing
- correction lineage

Data must support payroll replay, audit review, and reconstruction of the exact enrollment state effective during payroll execution.

## 10. Integration with Payroll Timing

Enrollment changes must align with payroll cycles via Payroll_Period_ID and Payroll_Calendar_Context to ensure deduction and contribution timing consistency.

Payroll consumption of eligibility and enrollment state must remain traceable to:

- Payroll_Run_ID where applicable
- Payroll_Run_Result_Set_ID where applicable
- Employee_Payroll_Result_ID where applicable

This ensures deduction and contribution outcomes remain explainable and replay-safe.

## 11. Relationship to Other Models

This model integrates with:

- Benefit_and_Deduction_Configuration_Model
- Employee_Event_and_Status_Change_Model
- Employee_Assignment_Model
- Payroll_Context_Model
- Payroll_Calendar_Model
- Employee_Payroll_Result_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Code_Classification_and_Mapping_Model
- Multi_Context_Calendar_Model
- Correction_and_Immutability_Model
