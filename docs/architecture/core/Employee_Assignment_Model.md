# Employee_Assignment_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Employee_Assignment_Model.md` |
| **Domain** | Core |
| **Related Documents** | DATA/Entity-Employee.md, Employment_and_Person_Identity_Model, Plan_and_Rule_Model, Compensation_and_Pay_Rate_Model, Correction_and_Immutability_Model |

## Purpose

Defines the model used to associate Employment_ID values with payroll plans, calculation rules, and eligibility structures. Assignments determine which plans, rates, and calculation logic apply to an employment relationship at any point in time.

---

## 1. Core Design Principles

Assignments attach to Employment_ID, not Person_ID. Assignments shall be effective-dated. Multiple assignments may exist across time. Assignment resolution shall be deterministic. Historical assignments shall remain preserved.

## 2. Assignment Definition

Assignment: Assignment_ID, Employment_ID, Plan_ID, Assignment_Type, Assignment_Start_Date, Assignment_End_Date (optional), Assignment_Status, Payroll_Context_ID, Assignment_Priority (optional), Creation_Timestamp, Last_Update_Timestamp.

## 3. Assignment Types

PRIMARY, SECONDARY, TEMPORARY, SUPPLEMENTAL, OVERRIDE. Assignment type helps determine resolution precedence and behaviour.

## 4. Effective Dating Rules

Every assignment must have an Assignment_Start_Date. Assignment_End_Date may be null for active assignments. Retroactive and future-dated assignments are supported. Gaps are not permitted unless explicitly allowed.

## 5. Overlap Handling

Supported behaviours: single active assignment enforcement, multiple concurrent assignments with precedence rules, assignment stacking where applicable, conflict detection and exception generation. Resolution shall be deterministic and auditable.

## 6. Assignment Priority Rules

Priority may be defined by Assignment_Priority value, Assignment_Type hierarchy, plan precedence configuration, or business-defined ranking. Higher priority overrides lower priority when conflicts exist.

## 7. Assignment Resolution Logic

Resolution sequence: (1) Identify Employment_ID, (2) Identify Payroll_Context_ID, (3) Identify Period_ID, (4) Select assignments active during the period, (5) Apply priority rules, (6) Resolve applicable Plan_ID, (7) Execute calculation logic. Must produce a single deterministic outcome per calculation event unless stacking rules apply.

## 8. Rehire Assignment Handling

Rehire creates a new Employment_ID. Historical assignments remain with the prior Employment_ID. New assignments attach to the new Employment_ID. No historical reassignment occurs automatically.

## 9. Retroactive Assignment Changes

Supported retro behaviours: backdated assignment correction, plan change retroactivity, assignment termination adjustment, assignment priority correction. All retroactive changes must preserve audit traceability.

## 10. Audit and Traceability

Track assignment creation, modification, and termination. Link assignments to calculation runs. Preserve historical assignment state. Supports regulatory compliance and payroll verification.

## 11. Key Design Principle

Assignments define how an employment relationship participates in payroll calculation. Employment_ID determines who is paid. Assignment determines how they are paid.
