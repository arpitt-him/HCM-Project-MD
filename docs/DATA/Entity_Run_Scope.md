# Entity_Run_Scope

| Field | Detail |
|---|---|
| **Document Type** | Data Entity |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/DATA/Entity_Run_Scope.md` |
| **Last Updated** | April 2026 |

---

## Purpose

The Run Scope entity defines the persisted structure used to identify,
control, and execute scoped payroll processing populations. It provides
the durable linkage between scoped execution requests and their parent
Payroll Run lineage.

This entity supports:

- Catch-up payroll execution
- Retroactive correction processing
- Exception-driven recovery
- Targeted recalculation workflows
- Deterministic replay lineage preservation

---

## Scope

The Entity_Run_Scope applies to:

- Payroll processing lifecycle management
- Scoped execution workflows
- Post-finalization correction processing
- Recovery and remediation operations

This entity SHALL be created whenever a scoped population
is defined for execution within a Payroll Run.

---

## Entity Definition

**Entity Name:** Run_Scope  
**Entity Type:** Operational Control Entity  
**Primary Key:** Run_Scope_ID  

---

## Primary Attributes

| Attribute Name | Description | Required | Notes |
|---|---|---|---|
| Run_Scope_ID | Unique identifier for the Run Scope | Yes | System-generated UUID |
| Parent_Run_ID | Identifier of the finalized parent Payroll Run | Yes | References Payroll_Run |
| Scope_Type | Type of scope execution | Yes | FULL, CATCH_UP, RETRO, RECOVERY |
| Scope_Status | Current lifecycle status | Yes | See Lifecycle States |
| Creation_Timestamp | Timestamp when scope was created | Yes | System-generated |
| Created_By | User or process creating the scope | Yes | User_ID or System |
| Trigger_Reason | Business reason for scope creation | Yes | Free-text or coded |
| Population_Method | Method used to define population | Yes | Explicit, Query, Exception |
| Population_Count | Number of subjects included | Yes | Integer |
| Priority_Level | Execution priority | Yes | STANDARD, CATCH_UP, RECOVERY, EMERGENCY |

---

## Population Definition Attributes

| Attribute Name | Description | Required | Notes |
|---|---|---|---|
| Population_Definition | Serialized population definition | Yes | Query or explicit list reference |
| Population_Resolved_Flag | Indicates population resolution completed | Yes | Boolean |
| Resolution_Timestamp | Timestamp population was resolved | No | Set after validation |
| Exception_Derived_Flag | Indicates exception-based population | No | Boolean |

---

## Execution Control Attributes

| Attribute Name | Description | Required | Notes |
|---|---|---|---|
| Execution_Start_Timestamp | Timestamp execution begins | No | Set at RUNNING |
| Execution_End_Timestamp | Timestamp execution completes | No | Set at completion |
| Execution_Result | Final execution outcome | No | SUCCESS, FAILED |
| Adjustment_Flag | Indicates adjustment postings generated | Yes | Boolean |

---

## Lifecycle States

The Run Scope SHALL transition through the following states:

- DRAFT
- VALIDATED
- READY
- RUNNING
- COMPLETED
- FAILED
- CANCELLED

Lifecycle transitions SHALL follow defined processing rules
within the Calculation_Run_Lifecycle_Model.

---

## Relationships

| Related Entity | Relationship Type | Description |
|---|---|---|
| Payroll_Run | Parent | Parent finalized Payroll Run |
| Payroll_Run | Child | New scoped Payroll Run |
| Payroll_Check | Derived | Generated adjustment checks |
| Exception_Record | Dependency | Source of exception-driven scope |
| Payroll_Context | Context | Payroll environment reference |

---

## Constraints

CON-RSC-001  
A Run Scope SHALL reference a finalized Payroll Run.

CON-RSC-002  
A Run Scope SHALL NOT modify finalized parent run data.

CON-RSC-003  
A Run Scope SHALL generate adjustment-only results.

CON-RSC-004  
A Run Scope SHALL maintain immutable lineage linkage.

---

## Indexing Strategy

Recommended indexing fields:

- Run_Scope_ID
- Parent_Run_ID
- Scope_Status
- Scope_Type
- Creation_Timestamp

These indexes support:

- Rapid scope retrieval
- Execution monitoring
- Replay reconstruction
- Audit validation

---

## Audit Requirements

Each Run Scope SHALL record:

- Creation metadata
- Execution metadata
- Population lineage
- Adjustment linkage
- Final outcome status

Audit records SHALL be retained according to
Data_Retention_and_Archival_Model policies.

---

## Dependencies

This entity depends on:

- Payroll_Run_Model
- Calculation_Run_Lifecycle_Model
- Exception_and_Work_Queue_Model
- Payroll_Reconciliation_Model
- Correction_and_Immutability_Model

---

## Future Extensions

Future enhancements may include:

- Dynamic scope resizing
- Intelligent population grouping
- Predictive remediation scheduling
- Parallel execution orchestration

---

## End of Document
