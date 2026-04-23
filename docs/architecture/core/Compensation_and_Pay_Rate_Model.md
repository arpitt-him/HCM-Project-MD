# Compensation_and_Pay_Rate_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Compensation_and_Pay_Rate_Model.md` |
| **Domain** | Core |
| **Related Documents** | DATA/Entity-Employee.md, Employee_Event_and_Status_Change_Model, Earnings_and_Deductions_Computation_Model, Overtime_and_Premium_Pay_Model, Correction_and_Immutability_Model |

## Purpose

Defines structures governing employee compensation, pay rate assignment, rate history management, and pay determination behaviour.

HRIS owns compensation rate records; Payroll consumes them as governed inputs to earnings computation and payroll result generation.

Compensation and pay-rate records must remain:

- effective-dated
- assignment-aware
- replay-safe
- correction-capable
- auditable

This model governs how compensation context is supplied to payroll calculation without allowing historical pay-rate interpretation to drift.

---

## 1. Scope of Compensation

Supported compensation types: Hourly Pay, Salary Pay, Commission Pay, Bonus Pay, Piece Rate Pay, Shift Differential Pay, Contract Pay, Allowance-Based Pay.

## 2. Core Pay_Rate Entity

Pay_Rate_ID, Employee_ID, Employment_ID, Rate_Type, Base_Rate, Rate_Currency, Effective_Start_Date, Effective_End_Date, Rate_Status.

Additional pay-rate attributes may include:

Pay_Rate_Version_ID  
Source_Event_ID  
Source_Period_ID  
Execution_Period_ID  
Rule_Set_Reference  

These attributes support deterministic payroll consumption, replay, and retroactive correction processing.

## 3. Rate Type Classification

Rate types: HOURLY, SALARY, COMMISSION, BONUS, PIECE_RATE, DIFFERENTIAL, CONTRACT.

## 4. Rate Assignment Model

Employee_Pay_Rate_Assignment: Assignment_ID, Employee_ID, Employment_ID, Pay_Rate_ID, Assignment_Start_Date, Assignment_End_Date, Primary_Rate_Flag.

Rate assignments shall remain traceable to the governing assignment and payroll context in effect at the time of payroll calculation.

Additional assignment attributes may include:

Employee_Assignment_ID  
Payroll_Context_ID  
Run_Scope_Eligibility_Flag  

These attributes support deterministic rate resolution during payroll execution.

## 5. Multiple Rate Handling

Employees may have multiple rates, including:

- primary rate
- overtime rate
- shift differential rate
- project-specific rate
- supplemental or temporary rate

Multiple-rate resolution must be deterministic.

Rate precedence shall be governed by:

- assignment context
- rate type
- effective dating
- payroll context
- explicit priority rules where applicable

Resolved rates must remain traceable to the earnings result lines that consume them.

## 6. Salary Compensation Handling

Salary structures: Annual_Salary, Salary_Pay_Frequency, Salary_Proration_Method. Supports annual, monthly, and per-pay-period salary structures.

Salary interpretation must remain traceable to the payroll calendar and proration context used during computation.

Salary-derived earnings must remain reproducible for historical payroll periods.

## 7. Hourly Compensation Handling

Hourly compensation includes:

- standard hourly rate
- overtime multiplier rate
- double-time rate
- differential or premium-related rate context

Hourly rates integrate directly with time-entry systems and premium rule evaluation.

Hourly-rate usage must remain traceable to:

- Time_Entry_ID values where applicable
- premium eligibility logic where applicable
- resulting Employee Payroll Result lines

## 8. Rate Change and Versioning

Change_Date, Previous_Rate, New_Rate, Change_Reason, Approval_Status. Prior rates are preserved and accessible for retroactive payroll processing.

Historical rate versions shall remain accessible and must govern historical payroll replay for the periods in which they were effective.

Rate changes must never silently redefine prior payroll outcomes.

## 9. Retroactive Rate Changes

Retroactive_Start_Date, Affected_Pay_Periods, Adjustment_Required_Flag.

Retroactive rate changes generate downstream recalculation events routed to Payroll.

Retroactive handling must preserve:

- original pay-rate state
- corrected pay-rate state
- affected payroll periods
- affected payroll results where applicable
- governed correction lineage

Recalculation must maintain full audit history and integrate with Payroll_Adjustment_and_Correction_Model.

## 10. Reporting and Audit Support

Compensation reporting supports:

- rate history tracking
- compensation summaries
- differential reporting
- audit verification

Historical replay must reconstruct the pay-rate context that was effective when payroll computation occurred, including later retroactive correction lineage where applicable.

## 11. Relationship to Other Models

This model integrates with:

- Employee_Event_and_Status_Change_Model
- Employee_Assignment_Model
- Time_Entry_and_Worked_Time_Model
- Overtime_and_Premium_Pay_Model
- Rule_Resolution_Engine
- Earnings_and_Deductions_Computation_Model
- Employee_Payroll_Result_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Correction_and_Immutability_Model
- Operational_Reporting_and_Analytics_Model
