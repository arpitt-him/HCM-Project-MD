# Calculation_Run_Lifecycle

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/processing/Calculation_Run_Lifecycle.md` |
| **Domain** | Processing |
| **Related Documents** | ADR-002-Deterministic-Replayability.md, Payroll_Run_Model, Payroll_Calendar_Model, Error_Handling_and_Isolation_Model, Release_and_Approval_Model |

## Purpose

Defines the lifecycle of a calculation run within the payroll platform — how runs are initiated, bound to calendar context, how participant-level failures are isolated, and how successful results advance while problem cases are resolved.

---

## 1. Core Governing Principles

Every run shall bind to a valid Payroll_Context_ID and Period_ID. The associated payroll calendar entry provides the authoritative Pay_Date. Participant-specific failures should not stop unrelated employees from being processed when safe to continue. Shared or infrastructure failures shall stop the run. Partial completion may move forward only when policy explicitly permits it.

## 2. Run Context Definition

Run_ID, Run_Type, Payroll_Context_ID, Period_ID, Pay_Date, Execution_Timestamp, Initiating_User_or_Process, Run_Status, Included_Batch_Set, Rule_and_Config_Version_Reference.
Run_Type values: Initial, Rerun, Adjustment, Supplemental, Simulation.

## 3. Relationship to Payroll Calendar

A calculation run cannot exist independently of payroll calendar context. The Pay_Date from the calendar entry governs date-sensitive calculation behaviour, regardless of actual execution timestamp. Reruns continue to reference the same calendar entry.

## 4. Batch Eligibility for Inclusion

Only approved input batches may be included. Each included batch must be structurally valid, approved, associated with the same Payroll_Context_ID and Period_ID, and pass batch-level integrity checks.

## 5. Processing Stages

Open → Ready → In Progress → Completed with Exceptions / Completed → Approved → Released → Closed.

## 6. Participant-Level Failure Isolation

A participant-level failure shall not halt other participants' processing. Each failed participant is routed to the exception queue. The run may reach Completed with Exceptions while most participants succeed.

## 7. Shared Failure Handling

Structural, infrastructure, or data-integrity failures that affect all participants shall stop the run. Examples: missing calendar reference, security context failure, rule engine unavailable.

## 8. Rerun Behaviour

Reruns must reference the same calendar entry. Prior results must be superseded, not duplicated. Rerun must produce auditable trace linking to original run.

## 9. Relationship to Other Models

This model integrates with: Payroll_Run_Model, Payroll_Calendar_Model, Error_Handling_and_Isolation_Model, Release_and_Approval_Model, Accumulator_and_Balance_Model, Rule_Resolution_Engine.
