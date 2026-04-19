# Plan_and_Rule_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Plan_and_Rule_Model.md` |
| **Domain** | Core |
| **Related Documents** | Employee_Assignment_Model, Rule_Resolution_Engine, Rule_Versioning_Model, Policy_and_Rule_Execution_Model, Reference_Data_Model |

## Purpose

Defines the structure and behaviour of Plans, Rules, and Rate Tables within the payroll calculation platform. Plans provide configuration context for payroll calculations; Rules define reusable executable logic. Plans reference rules through structured associations rather than embedding logic directly.

---

## 1. Core Design Principle

Plans define configuration context. Rules define executable logic. Plans shall reference rules through structured associations. Rules shall remain independently defined and reusable. Plan-specific behaviour shall be achieved through parameterisation rather than rule duplication.

## 2. Plan Definition

Plan_ID, Plan_Name, Plan_Type, Plan_Status, Payroll_Context_ID, Plan_Start_Date, Plan_End_Date (optional), Plan_Version_ID, Creation_Timestamp, Last_Update_Timestamp. Plans act as orchestration containers determining which rules and rate tables participate in calculations.

## 3. Rule Definition

Rule_ID, Rule_Name, Rule_Type, Rule_Version_ID, Rule_Status, Rule_Description, Default_Execution_Order, Creation_Timestamp, Last_Update_Timestamp.
Rule types: Eligibility Rule, Threshold Rule, Rate Selection Rule, Cap Rule, Floor Rule, Recovery Rule, Override Rule.

## 4. Plan-Rule Association Model

Plan_Rule_Assignment: Plan_Rule_Assignment_ID, Plan_ID, Rule_ID, Execution_Order, Rule_Parameter_Set_ID, Effective_Start_Date, Effective_End_Date, Assignment_Status. Enables rules to be reused across multiple plans with plan-specific parameterisation.

## 5. Rule Parameterisation

Rule_Parameter_Set_ID, Parameter_Name, Parameter_Value, Parameter_Data_Type, Effective_Start_Date, Effective_End_Date. Allows the same rule logic to operate differently across plans or periods.

## 6. Rule Sequencing

Typical execution sequence: (1) Eligibility validation, (2) Threshold determination, (3) Rate selection, (4) Cap or floor application, (5) Recovery or adjustment, (6) Final validation. Execution order configurable through Plan_Rule_Assignment records.

## 7. Rate Table Definition

Rate tables provide structured lookup values used by rules. Rate_Table_ID, Rate_Table_Name, Rate_Type, Effective_Start_Date, Effective_End_Date. Rate tables support: flat rate lookups, tiered rate structures, formula-based derivation.

## 8. Plan and Rule Versioning

All plans and rules shall be version-controlled. Version_ID, Effective_Date, Approved_By, Change_Description. Historical versions must remain available for replay and audit.

## 9. Relationship to Other Models

This model integrates with: Employee_Assignment_Model, Rule_Resolution_Engine, Rule_Versioning_Model, Policy_and_Rule_Execution_Model, Reference_Data_Model, Payroll_Context_Model.
