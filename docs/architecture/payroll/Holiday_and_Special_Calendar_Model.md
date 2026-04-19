# Holiday_and_Special_Calendar_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/payroll/Holiday_and_Special_Calendar_Model.md` |
| **Domain** | Payroll |
| **Related Documents** | Multi_Context_Calendar_Model, Payroll_Calendar_Model, Time_Entry_and_Worked_Time_Model, Overtime_and_Premium_Pay_Model, Leave_and_Absence_Management_Model |

## Purpose

Defines structures governing holidays and special calendar dates that affect payroll, premium pay, leave eligibility, and compliance rules.

---

## 1. Holiday Scope

Federal Holidays, State Holidays, Local Holidays, Company Holidays, Observed Holidays, Floating Holidays, Union Holidays, Special Event Days.

## 2. Core Holiday Entity

Holiday_ID, Holiday_Name, Holiday_Type, Jurisdiction_ID, Holiday_Date, Observed_Date, Calendar_Context_ID, Status.
Holiday_Type: FEDERAL, STATE, LOCAL, COMPANY, UNION, FLOATING, SPECIAL_EVENT.

## 3. Observed Date Rules

Holiday on Saturday → Observed Friday. Holiday on Sunday → Observed Monday. Company-specific observed policies. Observed dates must remain auditable.

## 4. Holiday Eligibility

Eligibility factors: employment status, department, location, union membership, service duration.

## 5. Payroll Impact Handling

Holiday pay generation, holiday premium rates, work-on-holiday premium, scheduled holiday earnings.

## 6. Leave Interaction

Holiday during leave, holiday overlap with PTO, holiday exclusion from leave consumption.

## 7. Jurisdiction Integration

Federal holiday rules, state-specific observances, local municipality holidays. Jurisdiction_ID determines applicability.

## 8. Special Calendar Events

Company shutdown days, emergency closures, election days, disaster recovery schedules. Special events may trigger non-standard payroll processing.

## 9. Relationship to Other Models

This model integrates with: Multi_Context_Calendar_Model, Payroll_Calendar_Model, Time_Entry_and_Worked_Time_Model, Overtime_and_Premium_Pay_Model, Leave_and_Absence_Management_Model, Payroll_Check_Model.
