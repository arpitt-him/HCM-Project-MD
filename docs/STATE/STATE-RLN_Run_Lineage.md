# STATE-RLN_Run_Lineage

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/STATE/STATE-RLN_Run_Lineage.md` |
| **Last Updated** | April 2026 |

---

## Purpose

The STATE-RLN_Run_Lineage model defines the lifecycle states and
permitted transitions governing Run Lineage relationships between
Payroll Runs.

This state model ensures that lineage relationships are created,
validated, and preserved in a controlled and auditable manner.

This model supports:

- Controlled lineage creation
- Deterministic replay sequencing
- Lineage verification
- Immutable parent-child relationship management
- Audit traceability of lineage transitions

---

## Scope

This state model applies to:

- Parent-child Payroll Run relationships
- Run lineage lifecycle management
- Replay sequencing validation
- Correction lineage tracking

This model governs:

- Valid lineage states
- Allowed lineage transitions
- Transition validation checkpoints
- Terminal lineage behavior

---

## State Definitions

The Run Lineage SHALL progress through the following lifecycle states:

| State | Description |
|---|---|
| **DRAFT** | Lineage relationship defined but not yet validated |
| **LINKED** | Parent-child linkage recorded |
| **VERIFIED** | Lineage integrity verified |
| **ACTIVE** | Lineage actively referenced by downstream runs |
| **CLOSED** | Lineage finalized and no further extension permitted |
| **INVALID** | Lineage determined to be invalid or inconsistent |

---

## State Transition Rules

Permitted transitions SHALL follow the table below:

| Current State | Allowed Next State | Condition |
|---|---|---|
| DRAFT | LINKED | Parent-child identifiers assigned |
| LINKED | VERIFIED | Lineage validation successful |
| VERIFIED | ACTIVE | Child run executed |
| ACTIVE | CLOSED | Lineage completed and finalized |
| LINKED | INVALID | Validation failure detected |
| VERIFIED | INVALID | Integrity violation detected |

---

## Transition Constraints

RULE-RLN-STATE-001  
A lineage SHALL NOT transition directly from DRAFT to ACTIVE.

RULE-RLN-STATE-002  
A lineage SHALL NOT enter VERIFIED state without successful integrity validation.

RULE-RLN-STATE-003  
INVALID state SHALL be terminal.

RULE-RLN-STATE-004  
CLOSED state SHALL be terminal.

RULE-RLN-STATE-005  
All lineage transitions SHALL be recorded in audit logs.

---

## Validation Requirements

Before transition to LINKED:

- Parent_Run_ID SHALL exist
- Child_Run_ID SHALL exist
- Parent_Run SHALL be finalized

Before transition to VERIFIED:

- Parent-child linkage SHALL be validated
- Root_Run_ID SHALL be confirmed
- Replay sequence SHALL be determined

Before transition to ACTIVE:

- Child run execution SHALL begin
- Replay sequence SHALL be registered

---

## Terminal State Behavior

### CLOSED

When CLOSED:

- Lineage SHALL be preserved as immutable
- Replay ordering SHALL be locked
- Audit state SHALL be finalized

---

### INVALID

When INVALID:

- Lineage SHALL NOT be used
- Exception workflows SHALL be triggered
- Correction lineage MAY be created

---

## Exception Handling Considerations

Exceptions affecting lineage SHALL:

- Trigger validation review
- Prevent activation of invalid lineage chains
- Allow replacement lineage creation when required

---

## Audit Requirements

Each lineage state transition SHALL record:

- Previous state
- New state
- Transition timestamp
- Initiating actor
- Validation result

Audit history SHALL remain immutable.

---

## Dependencies

This state model depends on:

- Run_Lineage_Model
- Entity_Run_Scope
- Payroll_Run_Model
- Calculation_Run_Lifecycle_Model
- Payroll_Reconciliation_Model

---

## Future Extensions

Future enhancements may include:

- BRANCHED state for parallel lineage structures
- MERGED state for lineage consolidation
- ARCHIVED state for historical lineage retention

---

## End of Document
