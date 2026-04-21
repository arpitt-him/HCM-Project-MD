# Payroll_Run_Result_Set_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Processing Domain |
| **Location** | docs/architecture/processing/Payroll_Run_Result_Set_Model.md |
| **Domain** | Payroll Execution Results / Replay Integrity / Audit Container |
| **Related Documents** | Payroll_Run_Model.md, Payroll_Run_Funding_and_Remittance_Map.md, Net_Pay_Disbursement_Data_Model.md, Funding_Profile_Data_Model.md, Remittance_Profile_Data_Model.md, Payment_Instruction_Profile_Data_Model.md, Employment_Data_Model.md |

---

# Purpose

This document defines the **Payroll Run Result Set** as the governed container for all results generated during a Payroll Run.

The Payroll Run Result Set exists to preserve:

- calculation outputs
- employee-level results
- funding outcomes
- remittance outputs
- disbursement results
- audit and reconciliation artifacts

The Result Set is the authoritative record of what occurred during a Payroll Run.

This structure supports:

- deterministic payroll replay
- historical audit reconstruction
- payroll validation
- reconciliation workflows
- downstream reporting
- regulatory traceability

---

# Core Structural Role

```text
Payroll Run
    └── Payroll Run Result Set
            ├── Employee Payroll Result Set
            ├── Funding Result Set
            ├── Remittance Result Set
            ├── Disbursement Result Set
            ├── Accumulator Result Set
            └── Audit Snapshot
```

Payroll Run Result Set is the execution-output container, not the governing configuration.

---

# 1. Payroll Run Result Set Definition

A **Payroll Run Result Set** represents the full collection of structured outputs generated during a specific Payroll Run execution.

Each Payroll Run shall produce exactly one Result Set.

A Result Set may include:

- employee payroll calculations
- employer obligations
- funding usage outputs
- remittance instructions
- disbursement outputs
- audit summaries
- exception flags

The Result Set must be immutable after finalization.

Corrections must be recorded using adjustment or correction logic rather than overwriting results.

---

# 2. Payroll Run Result Set Primary Attributes

| Field Name | Description |
|---|---|
| Payroll_Run_Result_Set_ID | Unique identifier |
| Payroll_Run_ID | Parent payroll run reference |
| Run_Scope_ID | Run scope reference identifying the governed processed population segment where applicable |
| Source_Period_ID | Original payroll period to which the result set logically belongs |
| Execution_Period_ID | Period during which processing execution occurred |
| Result_Set_Status | Pending, Calculated, Approved, Released, Finalized, Archived |
| Result_Set_Type | Regular_Run, Off_Cycle, Adjustment_Run, Correction_Run |
| Execution_Start_Timestamp | Start time of result generation |
| Execution_End_Timestamp | Completion time of result generation |
| Approval_Required_Flag | Indicates approval workflow required |
| Approved_By_User_ID | Approval authority reference |
| Approval_Timestamp | Approval time |
| Finalization_Timestamp | Result lock timestamp |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Employee Payroll Result Set

Each Payroll Run Result Set shall contain one or more **Employee Payroll Results**.

```text
Payroll Run Result Set
    └── Employee Payroll Result (1..n)
```

Employee Payroll Results shall contain:

- earnings results
- deduction results
- tax results
- employer contribution results
- net pay result
- accumulator updates

Minimum fields:

| Field Name | Description |
|---|---|
| Employee_Payroll_Result_ID | Unique identifier |
| Payroll_Run_Result_Set_ID | Parent reference |
| Employment_ID | Employment reference |
| Person_ID | Person reference |
| Gross_Pay_Amount | Total gross earnings |
| Total_Deductions | Sum of deductions |
| Total_Taxes | Sum of tax obligations |
| Net_Pay_Amount | Final calculated net pay |

---

# 4. Funding Result Set

Funding Result Set records how payroll obligations were financially sourced.

```text
Payroll Run Result Set
    └── Funding Result Set (0..n)
```

Minimum fields:

| Field Name | Description |
|---|---|
| Funding_Result_Set_ID | Unique identifier |
| Payroll_Run_Result_Set_ID | Parent reference |
| Funding_Profile_ID | Funding source reference |
| Funding_Status | Funded, Partially_Funded, Failed |
| Funding_Amount | Total funded amount |
| Funding_Timestamp | Execution timestamp |

---

# 5. Remittance Result Set

Remittance Result Set captures obligations destined for external recipients.

```text
Payroll Run Result Set
    └── Remittance Result Set (0..n)
```

Minimum fields:

| Field Name | Description |
|---|---|
| Remittance_Result_Set_ID | Unique identifier |
| Payroll_Run_Result_Set_ID | Parent reference |
| Remittance_Profile_ID | Remittance configuration reference |
| Total_Remittance_Amount | Sum of remittance obligations |
| Remittance_Status | Prepared, Released, Transmitted, Accepted, Rejected |
| Transmission_Timestamp | Send time |

---

# 6. Disbursement Result Set

Disbursement Result Set records employee payment execution outputs.

```text
Payroll Run Result Set
    └── Disbursement Result Set (0..n)
```

Minimum fields:

| Field Name | Description |
|---|---|
| Disbursement_Result_Set_ID | Unique identifier |
| Payroll_Run_Result_Set_ID | Parent reference |
| Net_Pay_Disbursement_ID | Linked payment record |
| Disbursement_Status | Prepared, Released, Settled, Returned |
| Disbursement_Amount | Payment value |

---

# 7. Accumulator Result Set

Accumulator updates must be preserved as part of payroll outcome.

```text
Payroll Run Result Set
    └── Accumulator Result Set (0..n)
```

Accumulator updates may include:

- year-to-date values
- quarter-to-date values
- month-to-date values
- jurisdiction totals
- employee-level totals

Minimum fields:

| Field Name | Description |
|---|---|
| Accumulator_Result_ID | Unique identifier |
| Payroll_Run_Result_Set_ID | Parent reference |
| Accumulator_Type | YTD, QTD, MTD |
| Accumulator_Code | Specific accumulator reference |
| Updated_Value | New total |

Accumulator Result Set may summarize or consolidate one or more underlying Accumulator Impact records generated from Employee Payroll Results.

Relationship:

Employee Payroll Result
        ↓
Accumulator Impact
        ↓
Accumulator Result Set

This preserves separation between:

- detailed mutation lineage
- stored accumulator updates
- run-level accumulator summaries

---

# 8. Audit Snapshot

Audit Snapshot preserves metadata about the environment and rule logic used.

```text
Payroll Run Result Set
    └── Audit Snapshot (1)
```

Audit Snapshot may include:

- rule pack version
- tax table version
- jurisdiction rule versions
- configuration hash
- execution environment ID

This snapshot allows deterministic replay.

---

# 8.1 Exception Association

Payroll Run Result Set may be associated with one or more Payroll Exception records.

```text
Payroll Run Result Set
    └── Payroll Exception (0..n)
```

---

# 9. Result Set Lifecycle

Typical lifecycle:

```text
Pending
    ↓
Calculated
    ↓
Approved
    ↓
Released
    ↓
Finalized
    ↓
Archived
```

No Result Set shall be modified after Finalized status.

Corrections must generate separate adjustment runs.

---

# 10. Validation Rules

Examples:

- Payroll_Run_ID must exist
- Result_Set_Status must be valid
- Employee result totals must reconcile to run totals
- Funding and remittance totals must balance against calculated obligations
- Net pay totals must reconcile with disbursement totals

Validation must occur prior to Finalization.

---

# 11. Replay and Deterministic Execution Support

Payroll Run Result Set must preserve sufficient state to allow:

- replay validation
- forensic analysis
- payroll recomputation verification

Replay operations must produce identical output when supplied with identical inputs and rule context.

---

# 12. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Run_Scope_Model
- Employee_Payroll_Result_Model
- Payroll_Exception_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Run_Funding_and_Remittance_Map
- Net_Pay_Disbursement_Data_Model
- Funding_Profile_Data_Model
- Remittance_Profile_Data_Model
- Payment_Instruction_Profile_Data_Model
- Accumulator_Impact_Model
- Employment_Data_Model

---

# 13. Summary

This model establishes Payroll Run Result Set as the structured container for all outputs produced during payroll execution.

Key principles:

- One Payroll Run produces one Result Set
- Result Sets contain employee, funding, remittance, and disbursement outputs
- Result Sets preserve accumulator and audit lineage
- Result Sets become immutable after finalization
- Replay accuracy depends on Result Set completeness
