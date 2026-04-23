# Calculation_Run_Lifecycle

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.3 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/processing/Calculation_Run_Lifecycle.md` |
| **Domain** | Processing |
| **Related Documents** | ADR-002-Deterministic-Replayability.md, Payroll_Run_Model, Payroll_Calendar_Model, Error_Handling_and_Isolation_Model, Release_and_Approval_Model, Run_Scope_Model, Run_Lineage_Model, Correction_and_Immutability_Model |

## Purpose

Defines the lifecycle of a calculation run within the payroll platform — how runs are initiated, bound to calendar context, how participant-level and scope-level failures are isolated, and how successful results advance while problem cases are resolved.

This model also distinguishes between pre-finalization rerun behavior and post-finalization additive correction behavior so that deterministic replay, auditability, and immutable historical preservation remain intact.

---

## 1. Core Governing Principles

Every run shall bind to a valid Payroll_Context_ID and Period_ID. The associated payroll calendar entry provides the authoritative Pay_Date. Participant-specific failures should not stop unrelated employees from being processed when safe to continue. Scope-level failures shall stop only the affected scope when isolation is possible. Shared or infrastructure failures shall stop the run. Partial completion may move forward only when policy explicitly permits it.

Post-finalization corrections shall be represented through additive runs and adjustment results rather than mutation of finalized historical results.

---

## 2. Run Context Definition

Run_ID
Run_Type
Payroll_Context_ID
Period_ID
Pay_Date
Execution_Timestamp
Initiating_User_or_Process
Run_Status
Included_Batch_Set
Rule_and_Config_Version_Reference
Run_Scope_ID (optional)
Parent_Run_ID (optional)
Replay_Sequence_Reference (optional)
Payroll_Run_Result_Set_ID (optional)
Source_Period_ID (optional)
Execution_Period_ID (optional)

Run_Type values: Initial, Rerun, Adjustment, Supplemental, Simulation, Catch_Up, Retro, Recovery.

When Run_Scope_ID is populated, the calculation run SHALL be treated as scoped execution and SHALL be governed by Run_Scope_Model and related lineage controls.

---

## 3. Relationship to Payroll Calendar

A calculation run cannot exist independently of payroll calendar context. The Pay_Date from the calendar entry governs date-sensitive calculation behaviour, regardless of actual execution timestamp. Reruns continue to reference the same calendar entry.

Post-finalization catch-up, retro, and recovery runs SHALL also reference the same payroll calendar context as the finalized parent run unless an explicit policy-approved exception exists.

---

## 4. Batch Eligibility for Inclusion

Only approved input batches may be included. Each included batch must be structurally valid, approved, associated with the same Payroll_Context_ID and Period_ID, and pass batch-level integrity checks.

For scoped runs, included batches must also be consistent with the resolved scope population and SHALL NOT introduce subjects outside the approved scope boundary.

---

## 5. Scope Resolution and Validation

When a calculation run is scope-driven, the scope SHALL be resolved and validated before the run enters Ready state.

Scope validation SHALL confirm at minimum:

- The parent run is finalized
- Population membership is resolved
- Population membership is valid for the Payroll_Context_ID and Period_ID
- Scope dependencies are satisfied
- Required inputs for all in-scope participants are available
- Scope lineage references are established where applicable

A calculation run SHALL NOT proceed to Ready when its associated Run Scope remains in Draft or unresolved state.

---

## 6. Processing Stages

Open → Ready → In Progress → Completed with Exceptions / Completed → Approved → Released → Closed.

Scoped runs follow the same core lifecycle, but entry to Ready requires successful scope validation, and Completed with Exceptions may apply at participant or scope level depending on the error class encountered.

Ready status SHALL imply successful validation of calendar, batch, configuration, and scope prerequisites applicable to the run.

---

## 7. Participant-Level Failure Isolation

A participant-level failure shall not halt other participants' processing. Each failed participant is routed to the exception queue. The run may reach Completed with Exceptions while most participants succeed.

Participant-level failures include, but are not limited to:

- Missing individual data
- Invalid participant election
- Participant-specific rule resolution failure
- Participant-level accumulator constraint violation

---

## 8. Scope-Level Failure Isolation

A scope-level failure affects the bounded scoped population but does not necessarily require termination of unrelated runs or contexts.

Scope-level failures include, but are not limited to:

- Invalid scope population resolution
- Scope dependency violations
- Scope-parent lineage inconsistency
- Scoped funding or reconciliation constraint failures

Where safe isolation is possible, a scope-level failure SHALL terminate or suspend only the affected scope and SHALL NOT invalidate finalized parent runs or unrelated processing populations.

---

## 9. Shared Failure Handling

Structural, infrastructure, or data-integrity failures that affect all participants shall stop the run. Examples: missing calendar reference, security context failure, rule engine unavailable, corrupted configuration version set, systemic database failure.

Shared failures SHALL prevent progression beyond In Progress and SHALL produce auditable failure records.

---

## 10. Pre-Finalization Rerun Behaviour

A pre-finalization rerun is a rerun performed before the original run has been finalized and released.

Pre-finalization reruns:

- Must reference the same calendar entry
- May supersede prior in-flight calculation results
- Must preserve auditable trace linkage to the earlier run attempt
- Shall not create conflicting released financial results

This behaviour is permitted because the parent run has not yet reached final immutable release status.

---

## 11. Post-Finalization Correction Behaviour

A post-finalization correction run is any run executed after a parent run has been finalized.

Post-finalization correction runs include:

- Catch-up runs
- Retro runs
- Recovery runs
- Additive adjustment runs

Post-finalization correction runs:

- SHALL reference the finalized parent run
- SHALL preserve immutable parent results
- SHALL generate additive adjustment results only
- SHALL NOT replace or destructively supersede finalized historical postings
- SHALL participate in explicit run lineage sequencing

---

## 12. Relationship to Lineage and Replay

When a calculation run references a parent run or a scope, it SHALL participate in explicit lineage management.

Replay reconstruction SHALL process:

1. The root finalized run
2. Any subsequent child runs in persisted replay order

Where explicit replay sequencing exists, replay order SHALL be governed by persisted lineage sequence rather than raw timestamp alone.

---

## 13. Approval and Release Controls

A run may progress from Completed or Completed with Exceptions to Approved only when policy-defined approval conditions are met.

Scoped correction runs may require separate approval from the parent run, depending on governance rules and financial impact.

Released status SHALL indicate that calculation results are authorized for downstream operational consumption.

Approval and release decisions shall remain traceable to the exact run state and validation state active at the time of approval.

Released status authorizes downstream consumption by result, export, remittance, and reconciliation processes.

---

## 14. Relationship to Error Handling

This model relies on Error_Handling_and_Isolation_Model for error classification and recovery mechanics.

At minimum, the following error classes SHALL be supported:

- Participant-level errors
- Scope-level errors
- Batch-level errors
- Infrastructure errors
- Configuration errors

The calculation lifecycle SHALL respond differently based on error class and containment boundary.

---

## 15. Audit and Traceability Requirements

All calculation runs shall record:

- Run identity and type
- Payroll context and period
- Scope reference where applicable
- Parent run reference where applicable
- Rule and configuration version reference
- Lifecycle transitions with timestamp and actor
- Replay and lineage references where applicable

Audit records shall support deterministic replay validation and correction-chain reconstruction.

---

## 16. Relationship to Other Models

This model integrates with: 

Payroll_Run_Model
Payroll_Calendar_Model
Payroll_Run_Result_Set_Model
Employee_Payroll_Result_Model
Accumulator_Impact_Model
Configuration_and_Metadata_Management_Model
Exception_and_Work_Queue_Model
Error_Handling_and_Isolation_Model
Release_and_Approval_Model
Accumulator_and_Balance_Model
Rule_Resolution_Engine
Run_Scope_Model
Run_Lineage_Model
Payroll_Reconciliation_Model
Correction_and_Immutability_Model

---

## 17. Cross-Validation Notes

This model establishes the following semantic distinctions:

- Pre-finalization reruns may supersede in-flight results
- Post-finalization correction runs must be additive
- Scoped runs require explicit Run_Scope_ID linkage
- Replay reconstruction depends on lineage-aware sequencing
- Scope-level failure isolation is distinct from participant-level isolation

These distinctions SHALL govern all downstream implementation and testing.

---

## End of Document
