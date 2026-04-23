# End_to_End_Run_Lineage_Map

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Processing Domain |
| **Location** | docs/architecture/processing/End_to_End_Run_Lineage_Map.md |
| **Domain** | Payroll Execution / Lineage / Replay / Reconciliation |

---

## Purpose

This document defines the end-to-end lineage chain for payroll execution.

It makes explicit how governed payroll artifacts connect from:

- run initiation  
- result generation  
- worker-level payroll output  
- accumulator mutation  
- payment execution  
- remittance execution  
- reconciliation and audit reconstruction  

This model preserves:

- deterministic replay  
- correction-safe lineage  
- funding and remittance traceability  
- employee-level and run-level financial reconstruction  
- audit defensibility  

---

## 1. Core Lineage Principle

Payroll execution shall preserve lineage across all major execution artifacts.

No artifact may become operationally significant without remaining traceable to:

- the Payroll Run that generated or governed it  
- the Result Set that contained it where applicable  
- the worker-level result lineage where applicable  
- the correction lineage where applicable  
- the calendar and period context in which it was interpreted  

Later corrections, reruns, retries, or reversals shall create new lineage-linked artifacts rather than overwrite historical lineage.

---

## 2. End-to-End Payroll Execution Chain

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
Result Lines / Net Pay Result / Accumulator Impacts
    ↓
Accumulator Balance / Value
    ↓
Net Pay Disbursement / Funding / Remittance
    ↓
Reconciliation / Reporting / Audit
```

---

## 3. Payroll Run Lineage

Payroll Run is the central execution anchor.

A Payroll Run shall preserve:

- Payroll_Run_ID  
- Parent_Run_ID  
- Root_Run_ID  
- Run_Lineage_Sequence  
- Payroll_Context_ID  
- Source_Period_ID  
- Execution_Period_ID  

Typical lineage:

```text
Root Payroll Run
    ↓
Correction Run
    ↓
Supplemental Run
```

---

## 4. Payroll Run Result Set Lineage

Each Payroll Run produces one governed Payroll Run Result Set.

Required identifiers:

- Payroll_Run_Result_Set_ID  
- Payroll_Run_ID  
- Parent_Payroll_Run_Result_Set_ID  
- Root_Payroll_Run_Result_Set_ID  
- Result_Set_Lineage_Sequence  

The Result Set contains:

- employee payroll results  
- funding outputs  
- remittance outputs  
- disbursement outputs  
- accumulator summaries  
- audit snapshot  
- exception references  

---

## 5. Employee Payroll Result Lineage

Employee Payroll Result represents worker-level payroll truth.

Required identifiers:

- Employee_Payroll_Result_ID  
- Payroll_Run_Result_Set_ID  
- Payroll_Run_ID  
- Parent_Employee_Payroll_Result_ID  
- Root_Employee_Payroll_Result_ID  
- Result_Lineage_Sequence  

Typical structure:

```text
Payroll Run Result Set
    └── Employee Payroll Result
            ├── Earnings
            ├── Deductions
            ├── Taxes
            ├── Employer Contributions
            ├── Net Pay
            └── Accumulator Impacts
```

---

## 6. Accumulator Lineage

Accumulator lineage consists of:

```text
Accumulator Definition
    ↓
Accumulator Impact
    ↓
Accumulator Balance / Value
```

This separation supports:

- deterministic replay  
- correction safety  
- regulatory reconstruction  

---

## 7. Net Pay and Disbursement Lineage

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

---

## 8. Funding and Remittance Lineage

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

---

## 9. Correction Lineage

Corrections never overwrite.

They create lineage-linked artifacts.

```text
Original Run
    ↓
Original Result Set
    ↓
Correction Run
    ↓
Corrected Result Set
```

---

## 10. Calendar and Period Propagation

Required preserved identifiers:

- Payroll_Context_ID  
- Source_Period_ID  
- Execution_Period_ID  
- Pay_Date  

Historical replay must use the original calendar context.

---

## 11. Exception Lineage

```text
Execution Artifact
    ↓
Payroll Exception
    ↓
Work Queue
    ↓
Resolution / Retry
```

---

## 12. Reconciliation Traversal

Examples:

```text
Payroll Run
    ↓
Result Set
    ↓
Employee Results
```

```text
Employee Result
    ↓
Accumulator Impact
    ↓
Accumulator Balance
```

```text
Employee Result
    ↓
Net Pay
    ↓
Disbursement
```

---

## 13. Deterministic Replay Boundary

Replay must reconstruct:

- runs  
- result sets  
- employee results  
- accumulator changes  
- payments  
- remittances  
- corrections  

Given identical:

- configuration  
- rules  
- source inputs  
- calendar context  

The platform shall reproduce identical governed outcomes.

---

## 14. Summary

This model defines the complete lineage path across payroll execution.

Key anchors:

- Payroll Run  
- Payroll Run Result Set  
- Employee Payroll Result  
- Accumulator Impacts  
- Disbursement  
- Funding  
- Remittance  

All correction-safe, replay-safe, and audit-safe payroll systems depend on this lineage chain.
