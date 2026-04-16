# Multi_Context_Calendar_Model

Version: v0.1

## 1. Purpose

Define multiple independent calendar contexts used across payroll,
billing, tax, and fiscal operations. This model ensures that dates are
interpreted correctly within their associated business context.

## 2. Calendar Context Types

Supported calendar contexts include:\
\
PAYROLL_CALENDAR\
Defines pay periods and payroll cycle timing.\
\
TAX_CALENDAR\
Defines tax-year boundaries and reporting cycles.\
\
FISCAL_CALENDAR\
Defines accounting-year boundaries.\
\
BILLING_CALENDAR\
Defines provider invoice periods.\
\
REPORTING_CALENDAR\
Defines user-selected reporting windows.

## 3. Core Calendar_Context Entity

Calendar_Context\
\
Calendar_Context_ID\
Calendar_Name\
Calendar_Type\
Organization_ID\
Effective_Start_Date\
Effective_End_Date\
Status

## 4. Period Definition Model

Each calendar contains defined periods:\
\
Calendar_Period\
\
Period_ID\
Calendar_Context_ID\
Period_Name\
Period_Start_Date\
Period_End_Date\
Period_Type\
\
Examples of Period_Type:\
\
PAY_PERIOD\
MONTH\
QUARTER\
YEAR\
CUSTOM_PERIOD

## 5. Calendar Relationships

Calendars operate independently but may overlap.\
\
Example:\
\
Payroll Calendar → Bi-weekly\
Tax Calendar → Calendar Year\
Fiscal Calendar → October--September\
Billing Calendar → Monthly\
\
Each date must be interpreted within its assigned calendar context.

## 6. Accumulator Alignment

Accumulators reference specific calendar contexts to determine reset
boundaries.\
\
Example:\
\
Taxable Wages → Reset by TAX_CALENDAR\
Employer Billing Totals → Reset by BILLING_CALENDAR\
Payroll Earnings → Reset by PAYROLL_CALENDAR

## 7. Reporting Window Support

Reports may span:\
\
Single Period\
Multiple Periods\
Custom Date Range\
\
Reporting must reference:\
\
Calendar_Context_ID\
Start_Date\
End_Date\
\
This supports flexible fiscal reporting such as October--September
cycles.

## 8. Cycle-Date Handling

Reprocessing operations must preserve the original cycle date.\
\
Example:\
\
If payroll fails on Dec-31 and is rerun in January,\
the system must use the original December cycle date.\
\
This ensures regulatory accuracy and audit continuity.

## 9. Example: October--September Fiscal Year

Example Fiscal Calendar:\
\
Calendar_Type: FISCAL\
Start_Date: 10/01\
End_Date: 09/30\
\
Used for:\
\
Annual financial reporting\
Employer reconciliation\
Provider invoice alignment

## 10. Relationship to Other Models

This model integrates with:\
\
Payroll_Calendar_Model\
Payroll_Run_Model\
Accumulator_and_Balance_Model\
Provider_Billing_and_Charge_Model\
Reporting and Reconciliation Models
