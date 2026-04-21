# Payroll_Calendar_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
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

## 6.1 Source Period vs Execution Period

Payroll activity may reference both:

- **Source Period** — the original payroll period to which results logically belong
- **Execution Period** — the period in which processing occurs

These values may differ in the following cases:

- Retroactive corrections
- Off-cycle adjustments
- Supplemental payroll runs
- Post-finalization correction processing

Where both values exist, the system shall preserve:

- Source_Period_ID  
- Execution_Period_ID  

Source_Period_ID governs:

- tax period attribution
- reporting lineage
- accumulator period alignment

Execution_Period_ID governs:

- operational processing time
- workflow routing
- release and transmission scheduling

This distinction supports:

- replay accuracy
- retroactive correction handling
- jurisdictional reporting alignment
- financial reconciliation integrity

## 7. Calendar Governance

Calendars must be established before payroll runs can be initiated. Future periods shall be pre-generated. Calendar changes require approval workflow completion. Historical calendar definitions must be preserved for replayability.

## 7.1 Multiple Payroll Runs Per Period

A single Payroll Calendar Entry may be associated with multiple Payroll Runs.

These runs may include:

- Initial payroll execution
- Pre-finalization reruns
- Post-finalization child runs
- Supplemental runs
- Correction runs
- Simulation runs

All such runs must reference the same governing Period_ID unless policy explicitly permits otherwise.

This ensures:

- correct accumulator alignment
- consistent reporting attribution
- replay traceability
- operational lineage clarity

## 8. Relationship to Other Models

This model integrates with:

- Multi_Context_Calendar_Model
- Holiday_and_Special_Calendar_Model
- Payroll_Context_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Payroll_Adjustment_and_Correction_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Accumulator_Model_Detailed
