# Payroll_Calendar_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/payroll/Payroll_Calendar_Model.md` |
| **Domain** | Payroll |
| **Related Documents** | PRD-300-Payroll-Calendar.md, Multi_Context_Calendar_Model, Holiday_and_Special_Calendar_Model, Payroll_Context_Model, Payroll_Run_Model |

## Purpose

Defines the period structure, date controls, and calendar governance that govern when payroll inputs, calculations, corrections, and transmissions are permitted.

---

## 1. Core Design Principle

All payroll processing shall occur within a defined payroll context and calendar period. No payroll calculation shall execute without a valid Payroll_Context_ID and Period_ID reference.

## 2. Supported Pay Frequencies

Weekly (52 periods), Biweekly (26 periods), Semi-Monthly (24 periods), Monthly (12 periods), Custom.

## 3. Period Date Controls

Period_Start, Period_End, Pay_Date, Input_Cutoff, Calculation_Date, Validation_Window, Correction_Window, Finalization_Date, Transmission_Date.

## 4. Calendar Entry Entity

Calendar_Entry_ID, Payroll_Context_ID, Period_ID, all date control fields above, Calendar_Status.

## 5. Calendar Lifecycle States

Open → In Progress → Calculated → Approved → Released → Closed. State transitions shall be controlled by authorised users or approved system processes.

## 6. Pay_Date Preservation on Rerun

If a run fails and is rerun after the original pay date, the system must continue referencing the original Pay_Date from the calendar entry. This ensures correct date-sensitive calculation behaviour.

## 7. Calendar Governance

Calendars must be established before payroll runs can be initiated. Future periods shall be pre-generated. Calendar changes require approval workflow completion. Historical calendar definitions must be preserved for replayability.

## 8. Relationship to Other Models

This model integrates with: Multi_Context_Calendar_Model, Holiday_and_Special_Calendar_Model, Payroll_Context_Model, Payroll_Run_Model, Accumulator_and_Balance_Model.
