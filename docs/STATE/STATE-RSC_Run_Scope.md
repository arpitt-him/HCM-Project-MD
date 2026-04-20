# STATE-RSC_Run_Scope

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/STATE/STATE-RSC_Run_Scope.md` |
| **Last Updated** | April 2026 |

---

## Purpose

The STATE-RSC_Run_Scope model defines the lifecycle states and
permitted transitions governing the Run Scope entity.

This state model ensures that scoped payroll processing follows
controlled progression rules, supports validation checkpoints,
and prevents unauthorized execution behaviors.

This model supports:

- Controlled Run Scope lifecycle progression
- Validation enforcement prior to execution
- Exception containment
- Deterministic execution readiness
- Audit traceability of state transitions

---

## Scope

This state model applies to:

- Run Scope lifecycle management
- Scoped payroll execution preparation
- Catch-up and recovery processing
- Retroactive execution workflows

This model governs:

- Valid lifecycle states
- Allowed state transitions
- Transition validation requirements
- Terminal state behavior

---

## State Definitions

The Run Scope SHALL progress through the following lifecycle states:

| State | Description |
|---|---|
| **DRAFT** | Run Scope is created but not yet validated |
| **VALIDATED** | Population and dependencies validated |
| **READY** | Scope prepared and queued for execution |
| **RUNNING** | Execution in progress |
| **COMPLETED** | Execution completed successfully |
| **FAILED** | Execution terminated due to unrecoverable error |
| **CANCELLED** | Execution cancelled prior to completion |

---

## State Transition Rules

Permitted transitions SHALL follow the table below:

| Current State | Allowed Next State | Condition |
|---|---|---|
| DRAFT | VALIDATED | Population defined and resolved |
| VALIDATED | READY | Dependencies verified |
| READY | RUNNING | Execution initiated |
| RUNNING | COMPLETED | Execution successful |
| RUNNING | FAILED | Execution error encountered |
| VALIDATED | CANCELLED | Operator cancellation |
| READY | CANCELLED | Operator cancellation |

---

## Transition Constraints

RULE-RSC-STATE-001  
A Run Scope SHALL NOT transition directly from DRAFT to RUNNING.

RULE-RSC-STATE-002  
A Run Scope SHALL NOT enter READY state without successful validation.

RULE-RSC-STATE-003  
FAILED and CANCELLED states SHALL be terminal states.

RULE-RSC-STATE-004  
COMPLETED state SHALL be terminal.

RULE-RSC-STATE-005  
All transitions SHALL be recorded in audit logs.

---

## Validation Requirements

Before transition to VALIDATED:

- Population SHALL be defined
- Parent Run SHALL be finalized
- Population SHALL be resolved

Before transition to READY:

- Dependencies SHALL be verified
- Resource availability SHALL be confirmed

Before transition to RUNNING:

- Execution authorization SHALL be confirmed
- Scheduling priority SHALL be assigned

---

## Terminal State Behavior

### COMPLETED

When COMPLETED:

- Execution results SHALL be finalized
- Adjustment postings SHALL be committed
- Audit logs SHALL be finalized

---

### FAILED

When FAILED:

- Error state SHALL be recorded
- Recovery workflows MAY be initiated
- Parent lineage SHALL remain intact

---

### CANCELLED

When CANCELLED:

- Execution SHALL NOT proceed
- Resources SHALL be released
- Audit state SHALL be recorded

---

## Exception Handling Considerations

Exceptions occurring during RUNNING SHALL:

- Be isolated to affected population members
- Trigger transition to FAILED when unrecoverable
- Allow new scoped execution to be created where necessary

---

## Audit Requirements

Each state transition SHALL record:

- Previous state
- New state
- Transition timestamp
- Initiating actor
- Trigger reason

Audit history SHALL remain immutable.

---

## Dependencies

This state model depends on:

- Run_Scope_Model
- Entity_Run_Scope
- Run_Lineage_Model
- Payroll_Run_Model
- Calculation_Run_Lifecycle_Model

---

## Future Extensions

Future enhancements may include:

- PAUSED state for temporary suspension
- RETRY_PENDING state for automated recovery
- PARTIAL_SUCCESS state for segmented execution

---

## End of Document
