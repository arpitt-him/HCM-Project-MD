# Compensation_and_Pay_Rate_Model

Version: v0.1

## 1. Purpose

Define structures governing employee compensation, pay rate assignment,
rate history management, and pay determination behavior.

## 2. Scope of Compensation

Supported compensation types include:\
\
Hourly Pay\
Salary Pay\
Commission Pay\
Bonus Pay\
Piece Rate Pay\
Shift Differential Pay\
Contract Pay\
Allowance-Based Pay

## 3. Core Pay_Rate Entity

Pay_Rate\
\
Pay_Rate_ID\
Employee_ID\
Employment_ID\
Rate_Type\
Base_Rate\
Rate_Currency\
Effective_Start_Date\
Effective_End_Date\
Rate_Status

## 4. Rate Type Classification

Rate types include:\
\
HOURLY\
SALARY\
COMMISSION\
BONUS\
PIECE_RATE\
DIFFERENTIAL\
CONTRACT

## 5. Rate Assignment Model

Employee_Pay_Rate_Assignment\
\
Assignment_ID\
Employee_ID\
Employment_ID\
Pay_Rate_ID\
Assignment_Start_Date\
Assignment_End_Date\
Primary_Rate_Flag

## 6. Multiple Rate Handling

Employees may have multiple rates.\
\
Examples:\
\
Primary rate\
Overtime rate\
Shift differential rate\
Project-specific rate\
\
Multiple rates must support hierarchical resolution rules.

## 7. Salary Compensation Handling

Salary pay structures include:\
\
Annual salary\
Monthly salary\
Per-pay-period salary\
\
Salary attributes:\
\
Annual_Salary\
Salary_Pay_Frequency\
Salary_Proration_Method

## 8. Hourly Compensation Handling

Hourly pay structures include:\
\
Standard hourly rate\
Overtime multiplier rate\
Double-time rate\
\
Hourly rates integrate directly with time-entry systems.

## 9. Rate Change and Versioning

Rate changes must preserve historical continuity.\
\
Rate change attributes:\
\
Change_Date\
Previous_Rate\
New_Rate\
Change_Reason\
Approval_Status

## 10. Retroactive Rate Changes

Retroactive changes may require recalculation.\
\
Retroactive attributes:\
\
Retroactive_Start_Date\
Affected_Pay_Periods\
Adjustment_Required_Flag\
\
Recalculation must maintain audit history.

## 11. Reporting and Audit Support

Compensation reporting supports:\
\
Rate history tracking\
Compensation summaries\
Differential reporting\
Audit verification

## 12. Relationship to Other Models

This model integrates with:\
\
Time_Entry_and_Worked_Time_Model\
Overtime_and_Premium_Pay_Model\
Payroll_Check_Model\
Employee_Event_and_Status_Change_Model\
Operational_Reporting_and_Analytics_Model\
Correction_and_Immutability_Model
