# Payroll_Calendar_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.3 |
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

Additional governed attributes may include:

- Parent_Calendar_Entry_ID
- Root_Calendar_Entry_ID
- Calendar_Version_Number
- Approval_Reference_ID
- Source_Period_ID where applicable
- Execution_Period_ID where applicable

## 5. Payroll Calendar Lineage

Payroll calendar entries shall preserve lineage across effective-dated calendar change over time.

Calendar lineage shall support:

- Parent_Calendar_Entry_ID
- Root_Calendar_Entry_ID
- Calendar_Lineage_Sequence
- Calendar_Change_Reason_Code

Calendar lineage is required when:

- pay dates are revised before release
- cutoff dates are adjusted
- correction windows are changed
- transmission timing is updated

Later calendar changes shall not reinterpret historical payroll execution, reporting, accumulator, or transmission outcomes.

## 6. Calendar Lifecycle States

Open → In Progress → Calculated → Approved → Released → Closed. State transitions shall be controlled by authorised users or approved system processes.

## 7. Pay_Date Preservation on Rerun

If a run fails and is rerun after the original pay date, the system must continue referencing the original Pay_Date from the calendar entry. This ensures correct date-sensitive calculation behaviour.

## 7.1 Source Period vs Execution Period

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

## 8. Calendar Governance

Calendars must be established before payroll runs can be initiated. Future periods shall be pre-generated. Calendar changes require approval workflow completion. Historical calendar definitions must be preserved for replayability.

## 8.1 Multiple Payroll Runs Per Period

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

## 9. Deterministic Payroll Calendar Interpretation

Payroll calendar interpretation shall remain deterministic.

Given identical:

- Payroll_Context_ID
- Period_ID
- Pay_Date
- effective calendar state
- source period and execution period context where applicable

the platform shall resolve the same payroll timing, cutoff, correction-window, finalization, and transmission behavior.

Later calendar changes shall not silently reinterpret historical payroll operations.

## 10. Dependencies

This model depends on:

- Payroll_Context_Model
- Multi_Context_Calendar_Model
- Holiday_and_Special_Calendar_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Payroll_Adjustment_and_Correction_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Correction_and_Immutability_Model

## 11. Relationship to Other Models

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
- Correction_and_Immutability_Model
- Regulatory_and_Compliance_Reporting_Model
