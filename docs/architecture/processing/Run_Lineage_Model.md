# Run_Lineage_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/processing/Run_Lineage_Model.md` |
| **Last Updated** | April 2026 |

---

## Purpose

The Run Lineage Model defines how Payroll Runs are related across
standard execution, scoped catch-up processing, retroactive correction,
and recovery activity.

This model preserves immutable historical sequencing by establishing
explicit parent-child run relationships rather than permitting mutation
of finalized payroll results.

This model supports:

- Parent-child run traceability
- Deterministic replay sequencing
- Post-finalization correction lineage
- Scoped recovery processing
- Audit reconstruction
- Reconciliation continuity

---

## Scope

This model applies to:

- Payroll Run lineage relationships
- Catch-up run creation
- Retro run creation
- Recovery run creation
- Replay sequence reconstruction
- Audit and reconciliation traceability

This model governs:

- How child runs reference parent runs
- How lineage chains are traversed
- How replay order is determined
- How lineage is preserved without mutation
- How corrections are represented through additive runs

---

## Architectural Context

Run Lineage operates within the following architecture models:

- Payroll_Run_Model
- Run_Scope_Model
- Calculation_Run_Lifecycle_Model
- Payroll_Reconciliation_Model
- Correction_and_Immutability_Model
- Error_Handling_and_Isolation_Model

Run Lineage SHALL preserve immutable historical sequencing.

Run Lineage SHALL NOT permit finalized run replacement.

Run Lineage SHALL support deterministic replay reconstruction.

---

## Core Concepts

### Parent Run

A Parent Run is a finalized Payroll Run that serves as the lineage
anchor for one or more subsequent child runs.

A Parent Run SHALL remain immutable after finalization.

---

### Child Run

A Child Run is a new Payroll Run created to process a scoped correction,
recovery, retroactive adjustment, or other post-finalization activity.

A Child Run SHALL reference exactly one immediate Parent Run.

A Child Run MAY itself become the Parent Run of a subsequent Child Run.

---

### Lineage Chain

A Lineage Chain is the ordered sequence of related Payroll Runs beginning
with an original finalized run and continuing through all subsequent
child runs derived from it.

Example:

- Standard Payroll Run
- Catch-Up Run
- Retro Run
- Recovery Run

The complete sequence defines the auditable history of payroll change.

---

## Lineage Relationship Types

The following lineage relationship types are supported:

### CATCH_UP

Used when a child run processes delayed or missed payroll subjects
after finalization of the parent run.

---

### RETRO

Used when a child run processes adjustments caused by historical
effective-dated changes.

---

### RECOVERY

Used when a child run processes failed or incomplete prior activity.

---

### ADJUSTMENT

Used when a child run applies other additive corrective changes
without replacing original finalized results.

---

## Lineage Rules

RULE-RLN-001  
Every Child Run SHALL reference one finalized Parent Run.

RULE-RLN-002  
Parent Runs SHALL remain immutable after child run creation.

RULE-RLN-003  
Lineage relationships SHALL be explicit and persisted.

RULE-RLN-004  
Replay reconstruction SHALL process lineage chains in chronological order.

RULE-RLN-005  
Child Runs SHALL generate additive results only.

RULE-RLN-006  
Lineage chains SHALL preserve full audit traceability across all related runs.

RULE-RLN-007  
A Child Run SHALL NOT reference more than one immediate Parent Run.

RULE-RLN-008  
Lineage traversal SHALL support both forward and backward navigation.

---

## Lineage Structure

A lineage structure SHALL include at minimum:

- Run_ID
- Parent_Run_ID
- Root_Run_ID
- Relationship_Type
- Creation_Timestamp
- Trigger_Reason
- Scope_Reference
- Replay_Sequence_Number

---

## Root Run Concept

The Root Run is the first finalized Payroll Run in a lineage chain.

All descendant Child Runs SHALL preserve referenceability back to the Root Run.

This allows:

- Full replay reconstruction
- Chain-level audit review
- Consolidated reconciliation analysis

---

## Replay Sequencing

Replay order SHALL follow:

1. Root Run
2. First Child Run
3. Subsequent Child Runs in chronological order

Replay traversal SHALL use persisted lineage relationships and
Replay_Sequence_Number values where present.

Where chronological timestamps and explicit sequence values differ,
the persisted replay sequence SHALL govern.

---

## Lineage Traversal

The architecture SHALL support the following traversal methods:

### Parent Traversal

Navigate from a Child Run to its immediate Parent Run.

---

### Root Traversal

Navigate from any Child Run back to the Root Run.

---

### Descendant Traversal

Navigate from a Parent Run to all direct and indirect Child Runs.

---

### Replay Traversal

Navigate the lineage chain in deterministic replay order.

---

## Correction Behavior

All lineage-linked Child Runs SHALL preserve additive correction behavior.

This means:

- No finalized parent run mutation
- No replacement of parent results
- No destructive overwrite of parent postings

Corrections SHALL be represented through:

- Adjustment postings
- Reconciliation deltas
- Incremental funding impacts where applicable

---

## Relationship to Run Scope

Where a Child Run is created from a scoped population, the lineage record
SHALL preserve reference to the associated Run Scope.

This linkage supports:

- Scoped replay validation
- Exception traceability
- Population-level audit reconstruction

---

## Reconciliation Implications

Lineage chains SHALL support reconciliation continuity.

Reconciliation logic SHALL be capable of:

- Identifying affected prior runs
- Applying incremental correction balances
- Preserving finalized parent reconciliation states where possible
- Reconstructing the chain-level financial effect of all related runs

---

## Audit Requirements

Each lineage relationship SHALL record:

- Parent Run identifier
- Child Run identifier
- Root Run identifier
- Relationship type
- Trigger reason
- Creation metadata
- Scope reference where applicable
- Replay sequence metadata

Auditability SHALL support both run-level and chain-level review.

---

## Failure and Isolation Considerations

Failure of a Child Run SHALL NOT invalidate the existence of its Parent Run.

A failed Child Run MAY be followed by a new Child Run, creating a continued
lineage chain provided explicit lineage rules are preserved.

Failure handling SHALL remain additive and auditable.

---

## Dependencies

This model depends on:

- Payroll_Run_Model
- Run_Scope_Model
- Entity_Run_Scope
- Payroll_Reconciliation_Model
- Correction_and_Immutability_Model
- Exception_and_Work_Queue_Model

---

---

## Version 1 Execution Constraint

In Version 1 of the processing architecture, child runs within the same lineage SHALL execute serially.

This constraint ensures:

- Deterministic replay ordering
- Simplified lineage validation
- Predictable reconciliation behavior
- Reduced concurrency conflict risk

Participant-level execution within a single run MAY occur concurrently where isolation rules permit.

Parallel execution of sibling child runs within the same lineage is explicitly deferred to a future platform version.

---

## Deferred Capability: Parallel Sibling Lineage Execution

Future versions of the platform MAY allow concurrent execution of sibling child runs derived from the same parent run.

Such execution SHALL require:

- Population independence verification
- Protected write-target isolation
- Deterministic replay sequence assignment
- Conflict detection and prevention controls

This capability SHALL NOT be implemented until lineage replay integrity guarantees are formally extended to support concurrent sibling execution.

---

## Future Extensions

Future enhancements may include:

- Branch lineage handling for parallel corrective scenarios
- Automated lineage visualization
- Chain-level health scoring
- Predictive replay validation
- Lineage-aware scheduling optimization

---

## End of Document
