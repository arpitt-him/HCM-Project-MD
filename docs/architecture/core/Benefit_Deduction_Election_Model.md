# Benefit_Deduction_Election_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Benefit_Deduction_Election_Model.md` |
| **Domain** | Core |
| **Related Documents** | PRD-1000_Benefits_Boundary, Benefit_and_Deduction_Configuration_Model, Eligibility_and_Enrollment_Lifecycle_Model, Earnings_and_Deductions_Computation_Model, Accumulator_and_Balance_Model, Code_Classification_and_Mapping_Model, Correction_and_Immutability_Model, Integration_and_Data_Exchange_Model, STATE-DED_Benefits_Deductions, EXC-DED_Benefits_Deductions_Exceptions |

---

## Purpose

Defines the structure, lifecycle, intake, validation, and correction behaviour of the Benefit Deduction Election record — the per-employee instance that specifies what deduction amounts are active for a given employee and how they are consumed by payroll.

This model occupies the layer between plan configuration and payroll computation:

```text
Benefit_and_Deduction_Configuration_Model    ← what plans and codes exist
        ↓
Benefit_Deduction_Election_Model             ← what this employee has elected (this model)
        ↓
Eligibility_and_Enrollment_Lifecycle_Model   ← lifecycle state of the election
        ↓
Earnings_and_Deductions_Computation_Model    ← how the deduction is calculated and posted
        ↓
Employee_Payroll_Result                      ← the result lines generated
```

The election record does not define plan semantics — those are owned by `Benefit_and_Deduction_Configuration_Model`. It does not calculate deduction amounts — that is owned by `Earnings_and_Deductions_Computation_Model`. Its sole responsibility is to be the governed, effective-dated, per-employee record that tells payroll what to deduct and in what amount.

In v1 this model is explicitly scoped to support **manual or externally sourced deduction elections only**. Plan-level enrollment workflow, EOI, open enrollment, and carrier integration are out of scope per PRD-1000.

---

## 1. Core Benefit_Deduction_Election Entity

A Benefit Deduction Election represents a single active or historical deduction instruction for one employee against one deduction code.

### Required Fields

| Field | Type | Description |
|---|---|---|
| Election_ID | UUID | Unique identifier. System-generated. Immutable once created. |
| Employment_ID | UUID | The employment record this election applies to. Payroll anchor. |
| Deduction_Code | String | The governed deduction code per Code_Classification_and_Mapping_Model |
| Tax_Treatment | Enum | PRE_TAX, POST_TAX — inherited from deduction code classification at time of election |
| Employee_Amount | Decimal | Employee deduction amount per pay period. Must be ≥ 0. |
| Employer_Contribution_Amount | Decimal | Employer contribution amount per pay period. Optional. Must be ≥ 0 where provided. |
| Effective_Start_Date | Date | First date from which this election is payroll-active |
| Effective_End_Date | Date | Last date through which this election is payroll-active. Null = open-ended |
| Election_Status | Enum | STATE-DED lifecycle state (see §2) |
| Source | Enum | MANUAL, IMPORT, API — how the election was created |
| Created_By | String | Identity of the operator or system that created the record |
| Created_Timestamp | Datetime | Record creation timestamp |
| Last_Updated_Timestamp | Datetime | Last modification timestamp |

### Lineage Fields

| Field | Type | Description |
|---|---|---|
| Election_Version_ID | UUID | Version identifier for this state of the record |
| Original_Election_ID | UUID | References the first version of this election chain. Populated on corrections. |
| Parent_Election_ID | UUID | References the immediately prior version. Populated on corrections. |
| Correction_Type | Enum | AMOUNT_CHANGE, DATE_CHANGE, TERMINATION, REINSTATEMENT. Populated on corrections. |
| Source_Event_ID | UUID | References the HRIS lifecycle event (e.g. termination, leave) that triggered a status change, where applicable |

---

## 2. Election Lifecycle

Election lifecycle states are governed by `STATE-DED_Benefits_Deductions`. The states relevant to the election record are:

| State | Payroll Active? | Description |
|---|---|---|
| STATE-DED-001 | No | Pending — election created but not yet effective |
| STATE-DED-003 | Yes | Active — election is within its effective date range and deduction is applied |
| STATE-DED-004 | No | Suspended — deduction temporarily paused (e.g. unpaid leave of absence) |
| STATE-DED-005 | No | Terminated — election ended; no further deductions |

Payroll computation shall only consume elections in STATE-DED-003 (Active) whose effective date range encompasses the payroll period being calculated.

STATE-DED-002 (Awaiting Evidence of Insurability) is an enrollment-path state reserved for the future Benefits Administration module. It shall not be used in v1.

---

## 3. Effective Date Enforcement

**REQ-BEN-009 (from PRD-1000):** An election shall not apply to any payroll period whose end date falls before the `Effective_Start_Date` or after the `Effective_End_Date`.

Effective date enforcement shall be evaluated at payroll scope resolution — before calculation begins — not at posting time.

Where an election's effective dates partially overlap a payroll period (e.g. the election starts mid-period), the platform shall apply the deduction for the full period unless partial-period proration is explicitly configured for the deduction code.

Historical elections must remain queryable at any effective date for audit and replay purposes.

---

## 4. Intake Methods

Elections may be created through the following governed channels:

**Manual entry (MANUAL):** HR administrator enters election amounts directly via platform UI. Subject to field-level validation before saving. Requires HR Admin role.

**Batch file import (IMPORT):** File delivered via SFTP or managed portal containing one record per employee-deduction combination. Governed by INT-BEN-001 (API_Surface_Map). Dry-run mode supported for pre-import validation without posting.

**API submission (API):** Per-record or batch API call per `SPEC/API_Contract_Standards.md`. Governed by INT-BEN-001.

All three channels produce the same canonical Election record. Source is recorded in the `Source` field for audit traceability. All channels route invalid records to the exception queue rather than partially posting.

---

## 5. Validation Rules

The following validations apply at intake regardless of channel:

| Rule | Failure Behaviour | Exception Code |
|---|---|---|
| Employment_ID must reference a valid, active Employment record | Hard Stop — record rejected | EXC-DED-001 |
| Deduction_Code must reference a valid, active code in Code_Classification_and_Mapping_Model | Hard Stop — record rejected | EXC-DED-001 |
| Employee_Amount must be ≥ 0 | Hard Stop — record rejected | EXC-DED-001 |
| Effective_Start_Date must be a valid calendar date | Hard Stop — record rejected | EXC-DED-001 |
| Effective_End_Date, if provided, must be ≥ Effective_Start_Date | Hard Stop — record rejected | EXC-DED-001 |
| Tax_Treatment must match the canonical classification of the Deduction_Code | Hard Stop — record rejected | EXC-DED-003 |
| Duplicate active election for the same Employment_ID + Deduction_Code + overlapping effective dates | Warning — flagged for operator review; not automatically rejected | EXC-DED-002 |

---

## 6. Payroll Consumption

At payroll scope resolution, the platform identifies all elections in STATE-DED-003 (Active) whose effective date range encompasses the payroll period for each in-scope employee.

Each qualifying election produces:
- One **employee deduction result line** on the Employee Payroll Result, using the `Deduction_Code` and `Employee_Amount`
- One **employer contribution result line** where `Employer_Contribution_Amount` is present and > 0

Both result lines reference the `Election_ID` that generated them, preserving traceability from payroll result back to election record.

Payroll computation shall not modify the election record. The election record is a read-only input to computation.

---

## 7. Suspension and Termination

**Suspension (STATE-DED-004):** Triggered by HRIS lifecycle events (leave of absence begins). The election record is not deleted or end-dated. Its status transitions to STATE-DED-004. No deduction is generated while suspended. When the triggering condition resolves (return from leave), the status returns to STATE-DED-003.

**Termination (STATE-DED-005):** Triggered by employment termination, voluntary cancellation, or end-date reached. The election record transitions to STATE-DED-005 and is permanently closed. If a future deduction is needed, a new election record must be created.

Suspension and termination transitions shall preserve the `Source_Event_ID` referencing the HRIS event that triggered the change, where applicable.

---

## 8. Correction and Historical Preservation

Elections shall never be silently overwritten. All changes create a new versioned election record linked to its predecessor via `Parent_Election_ID` and `Original_Election_ID`.

**Amount change:** A new election record is created with the revised `Employee_Amount` or `Employer_Contribution_Amount`. The prior record is end-dated. The correction chain is preserved via lineage fields.

**Date change:** A new election record is created with revised effective dates. The prior record is end-dated or voided. Lineage is preserved.

**Retroactive correction:** Where an amount change affects a payroll period that has already been processed, the correction shall generate a payroll recalculation review event to the Payroll module consistent with `Payroll_Adjustment_and_Correction_Model`. The prior deduction result lines are not silently modified.

Historical election records must remain queryable at any effective date to support replay, audit, and retroactive correction.

---

## 9. Employer Contribution Handling

Employer contributions are tracked separately from employee deductions per REQ-BEN-005.

They do not affect employee net pay. They generate:
- A separate employer contribution result line on the Employee Payroll Result
- Accumulator impacts against the employer contribution YTD accumulator
- Liability entries routed to remittance or billing workflows per `Benefit_and_Deduction_Configuration_Model`

The employer contribution amount on the election record represents the per-period flat amount. Where employer contributions are formula-based (e.g. matching), the formula is defined in `Benefit_and_Deduction_Configuration_Model` and the election record carries only the resolved per-period amount.

---

## 10. Accumulator Integration

Each payroll posting from a benefit deduction election generates accumulator impacts per `Accumulator_Impact_Model`:

- Employee deduction YTD accumulator (PTD, QTD, YTD)
- Employer contribution YTD accumulator where applicable

Accumulator impacts reference the `Election_ID` and `Deduction_Code` of the source election for traceability and reconstruction.

---

## 11. Relationship to Other Models

| Model | Relationship |
|---|---|
| Benefit_and_Deduction_Configuration_Model | Provides the deduction code definitions and tax treatment classifications that elections reference |
| Eligibility_and_Enrollment_Lifecycle_Model | Governs the lifecycle state of each election via STATE-DED |
| Earnings_and_Deductions_Computation_Model | Consumes active elections as inputs to deduction result line generation |
| Employee_Payroll_Result_Model | Receives the deduction and employer contribution result lines produced from elections |
| Accumulator_and_Balance_Model | Receives accumulator impacts generated from each election posting |
| Code_Classification_and_Mapping_Model | Provides canonical deduction code definitions validated against at intake |
| Correction_and_Immutability_Model | Governs versioning and immutability of election records |
| Integration_and_Data_Exchange_Model | Governs batch file and API intake of elections via INT-BEN-001 |
| Security_and_Access_Control_Model | Governs HR Admin role requirement for manual entry and access scope |
| Data_Retention_and_Archival_Model | Governs retention of historical election records |
