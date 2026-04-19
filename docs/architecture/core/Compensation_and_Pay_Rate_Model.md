# Compensation_and_Pay_Rate_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Reviewed |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Compensation_and_Pay_Rate_Model.md` |
| **Domain** | Core |
| **Related Documents** | DATA/Entity-Employee.md, Employee_Event_and_Status_Change_Model, Earnings_and_Deductions_Computation_Model, Overtime_and_Premium_Pay_Model, Correction_and_Immutability_Model |

## Purpose

Defines structures governing employee compensation, pay rate assignment, rate history management, and pay determination behaviour. HRIS owns compensation rate records; Payroll consumes them.

---

## 1. Scope of Compensation

Supported compensation types: Hourly Pay, Salary Pay, Commission Pay, Bonus Pay, Piece Rate Pay, Shift Differential Pay, Contract Pay, Allowance-Based Pay.

## 2. Core Pay_Rate Entity

Pay_Rate_ID, Employee_ID, Employment_ID, Rate_Type, Base_Rate, Rate_Currency, Effective_Start_Date, Effective_End_Date, Rate_Status.

## 3. Rate Type Classification

Rate types: HOURLY, SALARY, COMMISSION, BONUS, PIECE_RATE, DIFFERENTIAL, CONTRACT.

## 4. Rate Assignment Model

Employee_Pay_Rate_Assignment: Assignment_ID, Employee_ID, Employment_ID, Pay_Rate_ID, Assignment_Start_Date, Assignment_End_Date, Primary_Rate_Flag.

## 5. Multiple Rate Handling

Employees may have multiple rates: primary rate, overtime rate, shift differential rate, project-specific rate. Multiple rates must support hierarchical resolution rules.

## 6. Salary Compensation Handling

Salary structures: Annual_Salary, Salary_Pay_Frequency, Salary_Proration_Method. Supports annual, monthly, and per-pay-period salary structures.

## 7. Hourly Compensation Handling

Standard hourly rate, overtime multiplier rate, double-time rate. Hourly rates integrate directly with time-entry systems.

## 8. Rate Change and Versioning

Change_Date, Previous_Rate, New_Rate, Change_Reason, Approval_Status. Prior rates are preserved and accessible for retroactive payroll processing.

## 9. Retroactive Rate Changes

Retroactive_Start_Date, Affected_Pay_Periods, Adjustment_Required_Flag. Retroactive rate changes generate downstream recalculation events routed to Payroll. Recalculation must maintain audit history.

## 10. Reporting and Audit Support

Compensation reporting supports: rate history tracking, compensation summaries, differential reporting, audit verification.

## 11. Relationship to Other Models

This model integrates with: Time_Entry_and_Worked_Time_Model, Overtime_and_Premium_Pay_Model, Payroll_Check_Model, Employee_Event_and_Status_Change_Model, Operational_Reporting_and_Analytics_Model, Correction_and_Immutability_Model.
