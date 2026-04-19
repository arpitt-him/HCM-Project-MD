# Multi_Context_Calendar_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/payroll/Multi_Context_Calendar_Model.md` |
| **Domain** | Payroll |
| **Related Documents** | Payroll_Calendar_Model, Holiday_and_Special_Calendar_Model, Accumulator_and_Balance_Model, Provider_Billing_and_Charge_Model, Regulatory_and_Compliance_Reporting_Model |

## Purpose

Defines multiple independent calendar contexts used across payroll, billing, tax, and fiscal operations. Ensures that dates are interpreted correctly within their associated business context.

---

## 1. Calendar Context Types

PAYROLL_CALENDAR — defines pay periods and payroll cycle timing.
TAX_CALENDAR — defines tax-year boundaries and reporting cycles.
FISCAL_CALENDAR — defines accounting-year boundaries.
BILLING_CALENDAR — defines provider invoice periods.
REPORTING_CALENDAR — defines user-selected reporting windows.

## 2. Core Calendar_Context Entity

Calendar_Context_ID, Calendar_Name, Calendar_Type, Organization_ID, Effective_Start_Date, Effective_End_Date, Status.

## 3. Period Definition Model

Calendar_Period: Period_ID, Calendar_Context_ID, Period_Name, Period_Start_Date, Period_End_Date, Period_Type.
Period_Type examples: PAY_PERIOD, MONTH, QUARTER, YEAR, CUSTOM_PERIOD.

## 4. Calendar Relationships

Calendars operate independently but may overlap. Payroll Calendar → bi-weekly. Tax Calendar → calendar year. Fiscal Calendar → October–September. Billing Calendar → monthly. Each date must be interpreted within its assigned calendar context.

## 5. Accumulator Alignment

Accumulators reference specific calendar contexts for reset boundaries. Taxable Wages → reset by TAX_CALENDAR. Employer Billing Totals → reset by BILLING_CALENDAR. Payroll Earnings → reset by PAYROLL_CALENDAR.

## 6. Reporting Window Support

Reports may span single period, multiple periods, or custom date range. Reporting must reference Calendar_Context_ID, Start_Date, End_Date.

## 7. Cycle-Date Handling

Reprocessing operations must preserve the original cycle date. If payroll fails on Dec 31 and is rerun in January, the system must use the original December cycle date to ensure regulatory accuracy.

## 8. Relationship to Other Models

This model integrates with: Payroll_Calendar_Model, Payroll_Run_Model, Accumulator_and_Balance_Model, Provider_Billing_and_Charge_Model, Reporting and Reconciliation Models.
