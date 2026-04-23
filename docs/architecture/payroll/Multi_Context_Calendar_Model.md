# Multi_Context_Calendar_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
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

Additional governed attributes may include:

- Parent_Calendar_Context_ID
- Root_Calendar_Context_ID
- Calendar_Version_Number
- Calendar_Reset_Authority_Type
- Jurisdiction_Profile_ID where applicable
- Legal_Entity_ID where applicable
- Approval_Reference_ID

## 3. Calendar Context Lineage

Calendar contexts shall preserve lineage across effective-dated change over time.

Calendar lineage shall support:

- Parent_Calendar_Context_ID
- Root_Calendar_Context_ID
- Calendar_Lineage_Sequence
- Calendar_Change_Reason_Code

Calendar lineage is required when:

- a payroll calendar changes frequency
- a fiscal calendar changes boundary definition
- a billing calendar changes invoice cycle timing
- a reporting calendar definition is revised

Later calendar changes shall not reinterpret historical payroll, tax, billing, reporting, or accumulator outcomes.

## 4. Period Definition Model

Calendar_Period: Period_ID, Calendar_Context_ID, Period_Name, Period_Start_Date, Period_End_Date, Period_Type.
Period_Type examples: PAY_PERIOD, MONTH, QUARTER, YEAR, CUSTOM_PERIOD.

## 5. Calendar Relationships

Calendar contexts operate independently but may overlap in time.

Examples:

- Payroll Calendar → bi-weekly payroll periods
- Tax Calendar → calendar-year tax periods
- Fiscal Calendar → organization-specific accounting periods
- Billing Calendar → provider invoice periods
- Reporting Calendar → custom analytical or compliance windows

The same physical date may resolve differently across contexts.

Date interpretation must therefore always reference the applicable Calendar_Context_ID and Period_ID rather than relying on date alone.

## 6. Accumulator Alignment

Accumulators reference specific calendar contexts for reset boundaries. Taxable Wages → reset by TAX_CALENDAR. Employer Billing Totals → reset by BILLING_CALENDAR. Payroll Earnings → reset by PAYROLL_CALENDAR.

## 7. Relationship to Payroll Execution Artifacts

Calendar interpretation shall remain traceable to governed payroll execution artifacts.

Where applicable, payroll processing shall preserve linkage between:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID
- Calendar_Context_ID
- Period_ID
- Cycle_Date

This ensures that payroll replay, correction, tax interpretation, billing reconstruction, and reporting defensibility remain calendar-accurate.

## 8. Reporting Window Support

Reports may span single period, multiple periods, or custom date range. Reporting must reference Calendar_Context_ID, Start_Date, End_Date.

## 9. Cycle-Date Handling

Reprocessing and replay operations must preserve the original cycle date and applicable calendar context.

If payroll fails on December 31 and is rerun in January, the platform must continue to use the original December cycle date and governing period context unless a governed correction workflow explicitly changes the applicable period interpretation.

Cycle-date preservation is required to support:

- regulatory accuracy
- tax calendar correctness
- accumulator reset correctness
- billing and reporting reconstruction

## 10. Deterministic Calendar Interpretation

Calendar interpretation shall remain deterministic.

Given identical:

- Calendar_Context_ID
- Period_ID
- effective date state
- cycle date
- governing structural context

the platform shall resolve the same period boundaries, reset boundaries, and reporting interpretation.

Later calendar changes shall not silently reinterpret historical operational outcomes.

## 11. Dependencies

This model depends on:

- Payroll_Calendar_Model
- Holiday_and_Special_Calendar_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Accumulator_Definition_Model
- Provider_Billing_and_Charge_Model
- Regulatory_and_Compliance_Reporting_Model
- Correction_and_Immutability_Model

## 12. Relationship to Other Models

This model integrates with:

- Payroll_Calendar_Model
- Holiday_and_Special_Calendar_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Provider_Billing_and_Charge_Model
- Regulatory_and_Compliance_Reporting_Model
- Payroll_Reconciliation_Model
- Correction_and_Immutability_Model
