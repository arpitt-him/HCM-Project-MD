# Plan_and_Rule_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Plan_and_Rule_Model.md` |
| **Domain** | Core |
| **Related Documents** | Employee_Assignment_Model, Rule_Resolution_Engine, Rule_Versioning_Model, Policy_and_Rule_Execution_Model, Reference_Data_Model |

## Purpose

Defines the structure and behaviour of Plans, Rules, and Rate Tables within the payroll calculation platform.

Plans provide governed configuration context for payroll calculations. Rules define reusable executable logic. Plans reference rules through structured associations rather than embedding logic directly.

This model governs how assignment- and context-driven plan selection supplies executable rule context to payroll computation, result generation, replay, and correction workflows.

---

## 1. Core Design Principle

Plans define configuration context. Rules define executable logic. Plans shall reference rules through structured associations. Rules shall remain independently defined and reusable. Plan-specific behaviour shall be achieved through parameterisation rather than rule duplication.

## 2. Plan Definition

Plan_ID, Plan_Name, Plan_Type, Plan_Status, Payroll_Context_ID, Plan_Start_Date, Plan_End_Date (optional), Plan_Version_ID, Creation_Timestamp, Last_Update_Timestamp. Plans act as orchestration containers determining which rules and rate tables participate in calculations.

Additional plan attributes may include:

Assignment_Context_ID  
Rule_Set_Reference  
Jurisdiction_ID  
Source_Period_ID  
Execution_Period_ID  

These attributes support deterministic plan selection and replay-safe payroll execution.

## 3. Rule Definition

Rule_ID, Rule_Name, Rule_Type, Rule_Version_ID, Rule_Status, Rule_Description, Default_Execution_Order, Creation_Timestamp, Last_Update_Timestamp.
Rule types: Eligibility Rule, Threshold Rule, Rate Selection Rule, Cap Rule, Floor Rule, Recovery Rule, Override Rule.

Additional rule attributes may include:

Applicability_Context  
Mutation_Target  
Output_Type  
Exception_Behavior  
Replay_Relevance_Flag  

These attributes support deterministic execution, failure handling, and downstream result-line generation.

## 4. Plan-Rule Association Model

Plan_Rule_Assignment: Plan_Rule_Assignment_ID, Plan_ID, Rule_ID, Execution_Order, Rule_Parameter_Set_ID, Effective_Start_Date, Effective_End_Date, Assignment_Status. Enables rules to be reused across multiple plans with plan-specific parameterisation.

Plan-rule assignments shall remain traceable to the payroll context and assignment state in force at execution time.

Additional attributes may include:

Assignment_Context_ID  
Priority_Value  
Source_Event_ID  

These attributes support deterministic resolution where multiple plan-rule combinations may be eligible.

## 5. Rule Parameterisation

Rule_Parameter_Set_ID, Parameter_Name, Parameter_Value, Parameter_Data_Type, Effective_Start_Date, Effective_End_Date. Allows the same rule logic to operate differently across plans or periods.

Historical parameter values shall remain available and must govern replay for the periods in which they were effective.

Parameter changes must never silently redefine historical payroll outcomes.

## 6. Rule Sequencing

Typical execution sequence:

1. Eligibility validation
2. Threshold determination
3. Rate selection
4. Cap or floor application
5. Recovery or adjustment
6. Final validation

Execution order shall be configurable through Plan_Rule_Assignment records.

Sequencing must remain deterministic and produce traceable outputs suitable for payroll result generation, accumulator mutation, and downstream posting workflows.

## 7. Rate Table Definition

Rate tables provide structured lookup values used by rules. Rate_Table_ID, Rate_Table_Name, Rate_Type, Effective_Start_Date, Effective_End_Date. Rate tables support: flat rate lookups, tiered rate structures, formula-based derivation.

Rate tables shall remain effective-dated and historically queryable.

Additional rate-table attributes may include:

Rate_Table_Version_ID  
Source_Context_ID  
Jurisdiction_ID  
Calculation_Basis  

Rate-table resolution must remain deterministic during replay and correction workflows.

## 8. Plan and Rule Versioning

All plans and rules shall be version-controlled.

Version_ID, Effective_Date, Approved_By, Change_Description.

Historical versions must remain available for replay, audit, and correction processing.

Version changes must preserve:

- prior executable state
- corrected or future executable state
- affected payroll periods where applicable
- linkage to governed adjustment or correction workflows

## 8.1 Relationship to Payroll Execution Results

Plans and rules do not directly constitute payroll results.

They define the governed configuration and execution context from which payroll results are produced.

Relationship:

Employee Assignment
        ↓
Plan
        ↓
Plan-Rule Assignment
        ↓
Rule Resolution / Execution
        ↓
Employee Payroll Result

This ensures that payroll outputs remain traceable to the exact plan, rule, parameter, and rate-table context that was active at execution time.

## 9. Relationship to Other Models

This model integrates with:

- Employee_Assignment_Model
- Payroll_Context_Model
- Rule_Resolution_Engine
- Policy_and_Rule_Execution_Model
- Rule_Versioning_Model
- Compensation_and_Pay_Rate_Model
- Earnings_and_Deductions_Computation_Model
- Employee_Payroll_Result_Model
- Accumulator_Impact_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Reference_Data_Model
