# End_to_End_Run_Lineage_Map

| Field | Detail |
|---|---|
| **Document Type** | Architecture Orientation Map |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Processing Domain |
| **Location** | `docs/architecture/End_to_End_Run_Lineage_Map.md` |
| **Domain** | Payroll Execution / Lineage / Replay / Reconciliation |
| **Related Documents** | Payroll_Run_Model, Run_Lineage_Model, Payroll_Run_Result_Set_Model, Employee_Payroll_Result_Model, Accumulator_Definition_Model, Accumulator_Impact_Model, Accumulator_and_Balance_Model, Processing_Lineage_Validation_Model, Correction_and_Immutability_Model, Payroll_Reconciliation_Model |

---

## Purpose

This document is a cross-model orientation map. It shows how the major payroll execution lineage chains connect from run initiation through to reconciliation and audit, and it directs the reader to the authoritative model governing each segment.

It does not define entity structures, validation rules, or correction semantics — those are defined in the models referenced throughout. Its value is as a single navigable view of how everything fits together.

---

## 1. Core Lineage Principle

Every operationally significant payroll artifact must be traceable to:

- the Payroll Run that generated or governed it
- the Result Set that contained it where applicable
- the worker-level result lineage where applicable
- the correction lineage where applicable
- the calendar and period context in which it was interpreted

Corrections, reruns, retries, and reversals always create new lineage-linked artifacts. Historical lineage is never overwritten.

**Authoritative model:** `Correction_and_Immutability_Model`

---

## 2. Complete Execution Chain

```text
Payroll Context
        ↓
Payroll Calendar / Period Context
        ↓
Payroll Run
        ↓
Payroll Run Result Set
        ↓
Employee Payroll Result
        ↓
Result Lines  ──────────────────────────────────────────────┐
        ↓                                                   │
Accumulator Impact                                          │
        ↓                                                   │
Accumulator Contribution                                    │
        ↓                                                   ↓
Accumulator Balance / Value              Net Pay Result
                                                ↓
                                         Net Pay Disbursement
                                                ↓
                                         Payment Instruction
        ↓                                       ↓
Funding / Remittance              Release / Delivery / Return / Reissue
        ↓
Reconciliation / Reporting / Audit
```

---

## 3. Run and Result Set Lineage

The Payroll Run is the central execution anchor. Every downstream artifact traces back to a Run ID.

```text
Root Payroll Run
        ↓
Payroll Run Result Set
        ↓
[Correction Run → Corrected Result Set]
        ↓
[Supplemental Run → Supplemental Result Set]
```

Each Payroll Run preserves: `Payroll_Run_ID`, `Parent_Run_ID`, `Root_Run_ID`, `Run_Lineage_Sequence`, `Payroll_Context_ID`, `Source_Period_ID`, `Execution_Period_ID`.

Each Result Set preserves: `Payroll_Run_Result_Set_ID`, `Payroll_Run_ID`, `Parent_Payroll_Run_Result_Set_ID`, `Root_Payroll_Run_Result_Set_ID`.

**Authoritative models:** `Payroll_Run_Model`, `Run_Lineage_Model`, `Payroll_Run_Result_Set_Model`

---

## 4. Employee Payroll Result Lineage

The Employee Payroll Result is the worker-level truth record. All earnings, deductions, taxes, and accumulator impacts are anchored to it.

```text
Payroll Run Result Set
        └── Employee Payroll Result
                ├── Earnings result lines
                ├── Deduction result lines
                ├── Tax result lines
                ├── Employer contribution result lines
                ├── Net Pay Result
                └── Accumulator Impacts (0..n)
```

Each Employee Payroll Result preserves: `Employee_Payroll_Result_ID`, `Payroll_Run_Result_Set_ID`, `Payroll_Run_ID`, `Parent_Employee_Payroll_Result_ID`, `Root_Employee_Payroll_Result_ID`.

**Authoritative model:** `Employee_Payroll_Result_Model`

---

## 5. Accumulator Lineage

Accumulator mutation flows through four distinct layers. Each layer has a defined role and is governed by a separate model.

```text
Accumulator Definition          ← what the accumulator means, its scope and reset rules
        ↓
Accumulator Impact              ← the mutation event: which result changed which accumulator
        ↓
Accumulator Contribution        ← the persisted historical balance-affecting record
        ↓
Accumulator Balance / Value     ← the current authoritative persisted state
```

This four-layer separation supports deterministic replay, correction safety, and regulatory reconstruction. No layer may be bypassed.

**Authoritative models:** `Accumulator_Definition_Model`, `Accumulator_Impact_Model`, `Accumulator_and_Balance_Model`

---

## 6. Net Pay and Disbursement Lineage

```text
Employee Payroll Result
        ↓
Net Pay Result
        ↓
Net Pay Disbursement
        ↓
Payment Instruction
        ↓
Release / Delivery / Return / Reissue
```

**Authoritative models:** `Employee_Payroll_Result_Model`, `Payroll_Funding_and_Cash_Management_Model`, `Net_Pay_Disbursement_Data_Model`

---

## 7. Funding and Remittance Lineage

Funding:

```text
Payroll Run Result Set
        ↓
Funding Use
        ↓
Funding Batch
        ↓
Settlement
```

Remittance:

```text
Payroll Run Result Set
        ↓
Remittance Use
        ↓
Remittance Output
        ↓
Transmission / Acceptance / Retry
```

**Authoritative models:** `Payroll_Run_Funding_and_Remittance_Map`, `Payroll_Interface_and_Export_Model`, `Payroll_Provider_Response_Model`

---

## 8. Correction Lineage

Corrections never overwrite. They produce new lineage-linked artifacts that carry delta impact forward.

```text
Original Run
        ↓
Original Result Set
        ↓
Original Employee Payroll Result
        ↓
Correction Run (child)
        ↓
Corrected Result Set
        ↓
Corrected Employee Payroll Result
```

Corrections at the accumulator level follow the same four-layer chain defined in §5, with Accumulator Impact `Impact_Type` set to CORRECTION or REVERSAL and `Prior_Accumulator_Impact_ID` preserving the link to the original.

**Authoritative models:** `Correction_and_Immutability_Model`, `Run_Lineage_Model`, `Payroll_Adjustment_and_Correction_Model`

---

## 9. Exception Lineage

```text
Execution Artifact
        ↓
Payroll Exception
        ↓
Work Queue Item
        ↓
Resolution / Retry / Escalation
```

Exceptions are traceable to the artifact that generated them. Resolution actions are audit-logged.

**Authoritative models:** `Payroll_Exception_Model`, `Exception_and_Work_Queue_Model`

---

## 10. Calendar and Period Context Propagation

All execution artifacts preserve the calendar context in which they were interpreted. Historical replay must use the original calendar context — not the current one.

Required identifiers preserved across the chain: `Payroll_Context_ID`, `Source_Period_ID`, `Execution_Period_ID`, `Pay_Date`.

**Authoritative models:** `Payroll_Calendar_Model`, `Multi_Context_Calendar_Model`

---

## 11. Reconciliation Traversal

The lineage chain supports three primary reconciliation traversal paths:

**Run-level:**
```text
Payroll Run → Result Set → Employee Results → totals
```

**Accumulator-level:**
```text
Employee Result → Accumulator Impact → Accumulator Contribution → Accumulator Balance
```

**Payment-level:**
```text
Employee Result → Net Pay → Disbursement → Settlement
```

All three paths must be reconstructable from archived artifacts for any historical period.

**Authoritative model:** `Payroll_Reconciliation_Model`, `Processing_Lineage_Validation_Model`

---

## 12. Deterministic Replay Guarantee

Given identical configuration, rules, source inputs, and calendar context, the platform must reproduce identical governed outcomes across all layers of this chain.

This guarantee applies to: runs, result sets, employee results, accumulator mutations, payments, remittances, and corrections.

Lineage chain integrity is the prerequisite for replay validity. The `Processing_Lineage_Validation_Model` governs the validation logic that confirms chain integrity before replay is permitted.

**Authoritative models:** `ADR-002_Deterministic_Replayability`, `Processing_Lineage_Validation_Model`, `Run_Lineage_Model`

---

## 13. Where to Go for Detail

| Topic | Authoritative Document |
|---|---|
| Run structure, states, parent-child relationships | `Payroll_Run_Model`, `Run_Lineage_Model` |
| Result set structure and lifecycle | `Payroll_Run_Result_Set_Model` |
| Worker-level result structure | `Employee_Payroll_Result_Model` |
| Accumulator meaning and scope | `Accumulator_Definition_Model` |
| Accumulator mutation events | `Accumulator_Impact_Model` |
| Accumulator balance and contribution history | `Accumulator_and_Balance_Model` |
| Net pay and disbursement | `Payroll_Funding_and_Cash_Management_Model` |
| Funding and remittance | `Payroll_Run_Funding_and_Remittance_Map` |
| Correction and immutability rules | `Correction_and_Immutability_Model` |
| Exception routing and resolution | `Exception_and_Work_Queue_Model` |
| Calendar and period context | `Multi_Context_Calendar_Model` |
| Reconciliation logic | `Payroll_Reconciliation_Model` |
| Lineage chain validation | `Processing_Lineage_Validation_Model` |
| Replay guarantee and ADR | `ADR-002_Deterministic_Replayability` |
