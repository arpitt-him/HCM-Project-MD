# Payroll_Adjustment_and_Correction_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Processing & Governance Domain |
| **Location** | docs/architecture/processing/Payroll_Adjustment_and_Correction_Model.md |
| **Domain** | Payroll Adjustment / Correction / Reversal / Replacement Processing |
| **Related Documents** | Payroll_Run_Model.md, Payroll_Run_Result_Set_Model.md, Employee_Payroll_Result_Model.md, Payroll_Exception_Model.md, Net_Pay_Disbursement_Data_Model.md, Accumulator_Model_Detailed.md, Correction_and_Immutability_Model.md, Release_and_Approval_Model.md |

---

# Purpose

This document defines the core data structure for **Payroll Adjustment and Correction** as the governed mechanism used to repair, reverse, replace, or supplement payroll outcomes without overwriting finalized results.

Payroll Adjustment and Correction exists to preserve:

- correction lineage
- reversal logic
- replacement logic
- supplementary payroll outcomes
- audit and replay integrity
- accumulator correction traceability
- payment and remittance correction handling

This model exists to support:

- retroactive pay corrections
- missed earnings additions
- deduction reversals
- tax recalculation corrections
- payment reversals and reissues
- off-cycle correction runs
- accumulator corrections
- employer liability correction

without allowing finalized payroll results to be edited in place.

---

# Core Structural Role

```text
Payroll Exception / Payroll Run Result Set / Employee Payroll Result
    ↓
Payroll Adjustment and Correction
    ↓
Correction Run / Reversal / Replacement / Supplemental Result / Audit Lineage
```

Payroll Adjustment and Correction is the governed corrective-processing layer of the payroll architecture.

---

# 1. Payroll Adjustment and Correction Definition

A **Payroll Adjustment and Correction** represents a governed record describing how one or more prior payroll outcomes are corrected, reversed, replaced, or supplemented.

A Payroll Adjustment and Correction may represent:

- retroactive earnings addition
- retroactive deduction correction
- tax adjustment
- accumulator correction
- payment reversal
- payment reissue
- supplemental payroll correction
- partial correction of one employee result
- broad correction affecting multiple workers or a full run

Payroll Adjustment and Correction shall be modeled as distinct from:

- Payroll Exception
- Payroll Run
- Payroll Run Result Set
- Employee Payroll Result
- Net Pay Disbursement
- Work queue item

It is the governed correction record, not the original error and not the original result itself.

---

# 2. Correction Primary Attributes

| Field Name | Description |
|---|---|
| Payroll_Correction_ID | Unique identifier |
| Payroll_Correction_Code | Business/system code |
| Correction_Type | Adjustment, Reversal, Replacement, Supplemental, Retroactive, Reissue, Other |
| Correction_Status | Draft, Pending_Approval, Approved, Executed, Partially_Executed, Cancelled, Closed |
| Correction_Reason_Code | Governed reason code |
| Correction_Description | Narrative explanation |
| Requested_By_User_ID | Requesting actor |
| Approved_By_User_ID | Approving actor where applicable |
| Requested_Timestamp | Request time |
| Approval_Timestamp | Approval time |
| Execution_Timestamp | Execution time |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Correction Context Attributes

| Field Name | Description |
|---|---|
| Source_Payroll_Run_ID | Original payroll run reference |
| Source_Result_Set_ID | Original payroll run result set reference |
| Source_Employee_Payroll_Result_ID | Original employee result reference where applicable |
| Source_Net_Pay_Disbursement_ID | Original disbursement reference where applicable |
| Source_Remittance_Result_Set_ID | Original remittance result reference where applicable |
| Source_Funding_Result_Set_ID | Original funding result reference where applicable |
| Employment_ID | Related employment where applicable |
| Person_ID | Related person where applicable |
| Payroll_Context_ID | Payroll context reference |
| Triggering_Exception_ID | Related payroll exception where applicable |
| Correction_Run_ID | Generated correction payroll run reference where applicable |
| Correction_Result_Set_ID | Generated correction result set reference where applicable |
| Parent_Run_ID | Immediate parent run reference where applicable |
| Root_Run_ID | Root run lineage reference where applicable |
| Run_Scope_ID | Scope reference where applicable |

These references preserve correction lineage to the original source outcome.

---

# 4. Correction Scope Model

A correction may apply at different levels.

### 4.1 Employee-Level Correction

Examples:

- missed overtime
- incorrect deduction
- wrong tax treatment
- returned payment reissue

### 4.2 Run-Level Correction

Examples:

- rule pack error affecting entire run
- funding-profile issue requiring rerun
- remittance profile misconfiguration

### 4.3 Component-Level Correction

Examples:

- deduction-only correction
- employer contribution-only correction
- accumulator-only correction
- disbursement-only correction

Correction scope shall be explicit and queryable.

---

# 5. Relationship to Payroll Exception

Payroll Exceptions often trigger correction activity.

Typical path:

```text
Payroll Exception
    └── Payroll Adjustment and Correction
```

However, not every correction requires a prior exception.

Examples of correction without prior exception:

- approved retro pay award
- negotiated supplement
- late bonus entry
- post-close manual correction request

The model must therefore support both:

- exception-triggered correction
- direct governed correction initiation

---

# 6. Relationship to Payroll Run and Result Set

Corrections may produce one or more new Payroll Runs or Result Sets.

Typical patterns include:

```text
Source Payroll Run Result Set
    ↓
Payroll Adjustment and Correction
    ↓
Correction Payroll Run
    ↓
Correction Result Set
```

The original result remains preserved.

The correction creates new governed outputs that reference the original.

This preserves:

- replay integrity
- audit history
- before/after visibility
- legal defensibility

Where correction runs are created, they shall participate in explicit run-lineage sequencing and remain traceable to the originating correction record.

---

# 7. Relationship to Employee Payroll Result

Corrections frequently target Employee Payroll Result.

Typical path:

```text
Source Employee Payroll Result
    ↓
Payroll Adjustment and Correction
    ↓
Correction Employee Payroll Result
```

The correction may:

- add missing earning lines
- reverse deduction lines
- recalculate taxes
- update accumulators
- produce replacement net pay

The original employee result must remain queryable and immutable after finalization.

---

# 8. Relationship to Net Pay Disbursement

Corrections may affect employee payment delivery.

Examples:

- payment reversal
- payment reissue
- supplemental payment
- stop-payment and replacement check
- ACH return handling

Typical path:

```text
Source Net Pay Disbursement
    ↓
Payroll Adjustment and Correction
    ↓
Replacement or Reversal Disbursement
```

The model shall preserve payment lineage between original, reversal, and replacement disbursements.

---

# 9. Relationship to Accumulators

Corrections may modify accumulator balances.

Examples:

- YTD wage increase
- YTD tax correction
- employer contribution adjustment
- leave balance or benefit deduction adjustment

The model shall preserve:

- prior accumulator state
- delta applied by correction
- corrected new value
- linkage to original result

Accumulator corrections must never silently overwrite prior execution history.

Accumulator corrections shall be represented through governed Accumulator Impact records where applicable, rather than by opaque balance replacement alone.

---

# 10. Correction Action Types

Typical correction action patterns include:

### 10.1 Additive Adjustment
Adds missing amounts without reversing the original result.

### 10.2 Partial Reversal
Reverses only a component of the original result.

### 10.3 Full Reversal
Reverses the entire original result or run outcome.

### 10.4 Replacement
Produces a corrected replacement for a prior result.

### 10.5 Supplemental
Adds a new governed payment/result outside the original run while preserving linkage.

### 10.6 Reissue
Creates replacement payment delivery without changing underlying calculation where appropriate.

Action type must be explicit because correction handling differs materially by type.

---

# 11. Correction Status Model

Suggested Correction_Status values:

| Status | Meaning |
|---|---|
| Draft | Created but not yet submitted |
| Pending_Approval | Awaiting approval |
| Approved | Approved for execution |
| Executed | Correction successfully processed |
| Partially_Executed | Some correction outputs completed; others pending or failed |
| Cancelled | Withdrawn before completion |
| Closed | Fully completed and no longer operationally open |

Status transitions shall be governed and auditable.

No correction may move to Executed without preserving the outputs it generated.

---

# 12. Effective Dating and Retroactivity

Corrections often involve retroactive impact.

The model shall support:

- original effective period
- correction execution date
- retroactive impact period
- original pay date reference
- corrected pay date reference where applicable

This is necessary for:

- tax recalculation
- accumulator repair
- period-based reporting
- employee communication
- legal audit

Retroactive handling must remain explicit, not inferred only from timestamps.

---

# 13. Approval and Governance Controls

Corrections frequently require governance.

Examples:

- negative net pay offset approval
- tax override approval
- off-cycle supplemental payment approval
- payment reversal approval
- broad run-level rerun approval

The model shall support linkage to:

- approval workflow
- release controls
- override authorization
- segregation-of-duties review

Correction execution must be governed proportionally to risk and impact.

---

# 14. Validation Rules

Examples of validation rules:

- Correction_Type is required
- Correction_Status is required
- Correction_Reason_Code is required
- Executed corrections must reference generated outputs
- Replacement corrections must preserve source-to-replacement lineage
- Full reversals must define scope of reversal explicitly
- Reissue corrections must reference prior disbursement where applicable
- Approved_By_User_ID is required when approval is mandated
- Cancelled corrections may not produce new execution outputs

These validations shall be enforced through correction workflows and payroll governance controls.

---

# 15. Audit and Traceability Requirements

The system shall preserve:

- correction request history
- approval history
- status transition history
- source-result linkage history
- generated-output linkage history
- disbursement reversal/reissue lineage
- accumulator correction lineage
- retroactivity context
- waiver/override history where applicable

This supports:

- audit
- payroll control review
- employee inquiry resolution
- legal defensibility
- deterministic replay with correction visibility

---

# 16. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Payroll_Exception_Model
- Net_Pay_Disbursement_Data_Model
- Accumulator_Model_Detailed.md
- Correction_and_Immutability_Model.md
- Release_and_Approval_Model.md
- Accumulator_Impact_Model
- Run_Lineage_Model
- Calculation_Run_Lifecycle
- Payroll_Reconciliation_Model
- Payroll_Run_Funding_and_Remittance_Map

---

# 17. Summary

This model establishes Payroll Adjustment and Correction as the governed mechanism for repairing payroll outcomes without overwriting finalized results.

Key principles:

- Corrections are separate governed records, not edits to prior results
- Corrections preserve source-to-correction lineage
- Corrections may affect runs, employee results, disbursements, remittances, and accumulators
- Corrections support additive, reversal, replacement, supplemental, and reissue patterns
- Retroactivity, approval, and auditability must remain explicit
- Historical integrity is mandatory
