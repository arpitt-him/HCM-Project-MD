# Holiday_and_Special_Calendar_Model

Version: v0.1

## 1. Purpose

Define structures governing holidays and special calendar dates that
affect payroll, premium pay, leave eligibility, and compliance rules.

## 2. Holiday Scope

Supported holiday categories include:\
\
Federal Holidays\
State Holidays\
Local Holidays\
Company Holidays\
Observed Holidays\
Floating Holidays\
Union Holidays\
Special Event Days

## 3. Core Holiday Entity

Holiday\
\
Holiday_ID\
Holiday_Name\
Holiday_Type\
Jurisdiction_ID\
Holiday_Date\
Observed_Date\
Calendar_Context_ID\
Status

## 4. Holiday Type Classification

Holiday types include:\
\
FEDERAL\
STATE\
LOCAL\
COMPANY\
UNION\
FLOATING\
SPECIAL_EVENT

## 5. Observed Date Rules

Observed date rules handle weekend alignment.\
\
Examples:\
\
Holiday on Saturday → Observed Friday\
Holiday on Sunday → Observed Monday\
Company-specific observed policies\
\
Observed dates must remain auditable.

## 6. Holiday Eligibility

Holiday eligibility determines which employees qualify.\
\
Eligibility factors:\
\
Employment status\
Department\
Location\
Union membership\
Service duration

## 7. Payroll Impact Handling

Holidays may trigger payroll behavior.\
\
Examples:\
\
Holiday pay generation\
Holiday premium rates\
Work-on-holiday premium\
Scheduled holiday earnings

## 8. Leave Interaction

Holiday logic interacts with leave management.\
\
Examples:\
\
Holiday during leave\
Holiday overlap with PTO\
Holiday exclusion from leave consumption

## 9. Jurisdiction Integration

Holiday rules vary by jurisdiction.\
\
Examples:\
\
Federal holiday rules\
State-specific observances\
Local municipality holidays\
\
Jurisdiction_ID determines applicability.

## 10. Special Calendar Events

Certain events may trigger special processing.\
\
Examples:\
\
Company shutdown days\
Emergency closures\
Election days\
Disaster recovery schedules

## 11. Reporting and Audit

Holiday reporting supports:\
\
Holiday usage tracking\
Holiday premium reporting\
Compliance audit verification\
\
All holiday definitions must remain historically preserved.

## 12. Relationship to Other Models

This model integrates with:\
\
Multi_Context_Calendar_Model\
Payroll_Calendar_Model\
Time_Entry_and_Worked_Time_Model\
Overtime_and_Premium_Pay_Model\
Leave_and_Absence_Management_Model\
Payroll_Check_Model
