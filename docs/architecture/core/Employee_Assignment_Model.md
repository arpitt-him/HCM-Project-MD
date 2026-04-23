# Employee_Assignment_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Employee_Assignment_Model.md` |
| **Domain** | Core |
| **Related Documents** | DATA/Entity-Employee.md, Employment_and_Person_Identity_Model, Plan_and_Rule_Model, Compensation_and_Pay_Rate_Model, Correction_and_Immutability_Model |

## Purpose

Defines the model used to associate Employment_ID values with payroll plans, calculation rules, eligibility structures, and payroll execution context.

Assignments determine which plans, rates, and calculation logic apply to an employment relationship at any point in time.

This model governs the effective-dated assignment layer that influences:

- payroll context participation
- plan and rule resolution
- compensation application
- eligibility determination
- payroll result generation
- replay and correction workflows

---

## 1. Core Design Principles

Assignments attach to Employment_ID, not Person_ID. Assignments shall be effective-dated. Multiple assignments may exist across time. Assignment resolution shall be deterministic. Historical assignments shall remain preserved.

## 2. Assignment Definition

Assignment: Assignment_ID, Employment_ID, Plan_ID, Assignment_Type, Assignment_Start_Date, Assignment_End_Date (optional), Assignment_Status, Payroll_Context_ID, Assignment_Priority (optional), Creation_Timestamp, Last_Update_Timestamp.

Additional assignment attributes may include:

Assignment_Version_ID  
Source_Event_ID  
Run_Scope_Eligibility_Flag  
Source_Period_ID  
Execution_Period_ID  

These attributes support deterministic routing of assignments into payroll execution and replay.

## 3. Assignment Types

PRIMARY, SECONDARY, TEMPORARY, SUPPLEMENTAL, OVERRIDE. Assignment type helps determine resolution precedence and behaviour.

## 4. Effective Dating Rules

Every assignment must have an Assignment_Start_Date. Assignment_End_Date may be null for active assignments. Retroactive and future-dated assignments are supported. Gaps are not permitted unless explicitly allowed.

Effective dating must support reconstruction of the assignment state that was active at the time of payroll execution.

Historical assignment interpretation shall remain reproducible during replay and correction workflows.

## 5. Overlap Handling

Supported behaviours: single active assignment enforcement, multiple concurrent assignments with precedence rules, assignment stacking where applicable, conflict detection and exception generation. Resolution shall be deterministic and auditable.

## 6. Assignment Priority Rules

Priority may be defined by Assignment_Priority value, Assignment_Type hierarchy, plan precedence configuration, or business-defined ranking. Higher priority overrides lower priority when conflicts exist.

## 7. Assignment Resolution Logic

Resolution sequence:

1. Identify Employment_ID.
2. Identify Payroll_Context_ID.
3. Identify Period_ID.
4. Select assignments active during the period.
5. Apply priority and overlap rules.
6. Resolve applicable Plan_ID and related rule context.
7. Supply resolved assignment context to payroll calculation and result generation.

Assignment resolution must produce a single deterministic outcome per calculation event unless governed stacking rules apply.

Resolved assignment context shall remain traceable to:

- Payroll_Run_ID where applicable
- Payroll_Run_Result_Set_ID where applicable
- Employee_Payroll_Result_ID where applicable

## 8. Rehire Assignment Handling

Rehire creates a new Employment_ID. Historical assignments remain with the prior Employment_ID. New assignments attach to the new Employment_ID. No historical reassignment occurs automatically.

## 9. Retroactive Assignment Changes

Supported retro behaviours include:

- backdated assignment correction
- plan change retroactivity
- assignment termination adjustment
- assignment priority correction

All retroactive changes must preserve audit traceability.

Retroactive assignment changes shall remain linked to governed correction workflows and must preserve:

- original assignment state
- corrected assignment state
- affected payroll periods
- affected payroll results where applicable

## 10. Audit and Traceability

Track assignment creation, modification, and termination.

Preserve:

- historical assignment state
- source event linkage
- overlap and precedence resolution outcomes
- payroll run linkage where applicable
- correction lineage where applicable

This supports regulatory compliance, payroll verification, deterministic replay, and audit reconstruction.

## 10.1 Relationship to Other Models

This model integrates with:

- Employee_Event_and_Status_Change_Model
- Employment_and_Person_Identity_Model
- Payroll_Context_Model
- Run_Scope_Model
- Plan_and_Rule_Model
- Compensation_and_Pay_Rate_Model
- Rule_Resolution_Engine
- Employee_Payroll_Result_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Correction_and_Immutability_Model

## 11. Key Design Principle

Assignments define how an employment relationship participates in payroll calculation. Employment_ID determines who is paid. Assignment determines how they are paid.
