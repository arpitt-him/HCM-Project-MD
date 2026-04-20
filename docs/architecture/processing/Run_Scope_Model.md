# Run_Scope_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/processing/Run_Scope_Model.md` |
| **Last Updated** | April 2026 |

---

## Purpose

The Run Scope Model defines the mechanism by which a subset of payroll subjects
may be selected and processed within a Payroll Run.

This model enables targeted processing of specific employees or assignments
after a Payroll Run has been finalized, allowing recovery, correction, and
catch-up processing without reprocessing the full population.

---

## Scope

This model applies to:

- Payroll processing workflows
- Catch-up execution processing
- Retroactive recalculation handling
- Exception-driven recovery
- Scoped recalculation operations

This model governs:

- Population scoping
- Parent-child run relationships
- Scoped execution behavior
- Adjustment-only correction handling
- Run lineage preservation

---

## Architectural Context

Run Scope operates within the following architecture models:

- Payroll_Run_Model
- Calculation_Run_Lifecycle_Model
- Error_Handling_and_Isolation_Model
- Payroll_Reconciliation_Model
- Correction_and_Immutability_Model

Run Scope SHALL NOT modify finalized payroll results.

Run Scope SHALL produce additive adjustment results only.

---

## Core Concepts

### Run Scope

A Run Scope defines a bounded population of payroll subjects selected
for execution within a specific Payroll Run.

Subjects may include:

- Employees
- Assignments
- Payroll contexts
- Jurisdictional entities

A Run Scope SHALL always reference a finalized parent Payroll Run.

---

## Run Scope Types

### FULL

Processes the complete eligible population.

Used for:

- Standard payroll execution

---

### CATCH_UP

Processes a defined subset of employees requiring correction or delayed processing.

Used for:

- Late timecards
- Missed processing
- Post-finalization correction
- Operational recovery

---

### RETRO

Processes employees impacted by historical changes.

Used for:

- Retroactive compensation changes
- Backdated employment changes

---

### RECOVERY

Processes employees affected by execution or integration failures.

Used for:

- Disbursement failures
- External processing interruptions

---

## Population Definition Methods

Run Scope populations may be defined using:

### Explicit Population

Population defined directly by employee identifiers.

Used for:

- Targeted operational corrections
- Manual remediation runs

---

### Query-Based Population

Population defined using rule-based selection logic.

Used for:

- Exception-driven execution
- Bulk correction scenarios

---

### Exception-Derived Population

Population generated from exception records.

Used for:

- Automated recovery processing

---

## Execution Rules

RULE-RSC-001  
All catch-up processing SHALL occur in a new Payroll Run.

RULE-RSC-002  
Scoped runs SHALL reference a finalized parent Payroll Run.

RULE-RSC-003  
Finalized parent runs SHALL remain immutable.

RULE-RSC-004  
Scoped runs SHALL generate adjustment postings only.

RULE-RSC-005  
Catch-up runs SHALL generate incremental funding obligations
for net-positive differences.

RULE-RSC-006  
Exceptions affecting one employee SHALL NOT terminate unrelated employees.

---

## Lifecycle States

Run Scope SHALL progress through the following states:

- DRAFT
- VALIDATED
- READY
- RUNNING
- COMPLETED
- FAILED
- CANCELLED

---

## Dependencies

This model depends on:

- Payroll_Run_Model
- Payroll_Check_Model
- Calculation_Run_Lifecycle_Model
- Exception_and_Work_Queue_Model
- Payroll_Reconciliation_Model
- Correction_and_Immutability_Model

---

## Future Extensions

Future enhancements may include:

- Automated scope generation
- Dynamic dependency resolution
- Predictive exception recovery batching
- Intelligent scope clustering

---

## End of Document
