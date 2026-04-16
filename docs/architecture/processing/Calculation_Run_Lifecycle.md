# 1. Purpose

This document defines the lifecycle of a calculation run within the
payroll platform.

It describes how runs are initiated, how they bind to payroll calendar
context, how approved inputs become eligible for processing, how
participant-level failures are isolated, and how successful results may
move forward when policy permits partial completion.

The target outcome of every run is full completion for all in-scope
employees. Partial completion is an exception posture used to preserve
payroll time and allow successful work to progress while problem cases
are resolved.

# 2. Scope

This lifecycle applies to calculation runs that process approved inputs
for a defined payroll context and period.

It covers:

• Run creation\
• Calendar binding\
• Batch eligibility\
• Processing stages\
• Participant-level isolation\
• Batch-fatal failure handling\
• Rerun behavior\
• Approval and release

# 3. Governing Principles

The lifecycle is governed by the following principles:

• Every run shall bind to a valid Payroll_Context_ID and Period_ID.\
• The associated payroll calendar entry provides the authoritative
Pay_Date.\
• The objective is always to complete processing for all in-scope
employees.\
• Participant-specific failures should not stop unrelated employees from
being processed when safe to continue.\
• Shared, structural, or infrastructure failures shall stop the run
once.\
• Partial completion may move forward only when policy explicitly
permits it and payroll timing requires it.

# 4. Run Context Definition

Each run shall include at minimum:

• Run_ID\
• Run_Type\
• Payroll_Context_ID\
• Period_ID\
• Pay_Date\
• Execution_Timestamp\
• Initiating_User_or_Process\
• Run_Status\
• Included_Batch_Set\
• Rule_and_Config_Version_Reference

Run_Type values may include:

• Initial\
• Rerun\
• Adjustment\
• Supplemental\
• Simulation

# 5. Relationship to Payroll Calendar

A calculation run cannot exist independently of payroll calendar
context.

Each run shall reference a valid payroll calendar entry identified by
Payroll_Context_ID and Period_ID. The Pay_Date from that calendar entry
governs date-sensitive calculation behavior, regardless of the actual
execution timestamp.

If a run is repeated after a failure, the rerun shall continue to
reference the same payroll calendar entry unless a formal policy-based
reclassification occurs.

# 6. Batch Eligibility for Inclusion

Only approved input batches may be included in a run.

Each included batch must:

• Be structurally valid\
• Be approved for use\
• Be associated with the same Payroll_Context_ID and Period_ID as the
run\
• Pass any required batch-level integrity checks

A run may include one or more approved batches relevant to the payroll
context and period.

# 7. Processing Stages

The standard run lifecycle is:

Open → Ready → In Progress → Completed with Exceptions / Completed →
Approved → Released → Closed

State meanings:

Open\
Run record created but not yet eligible to start.

Ready\
Required run context and approved inputs are available.

In Progress\
Calculation processing is underway.

Completed with Exceptions\
Processing completed for successful employees, with one or more isolated
participant failures remaining unresolved.

Completed\
Processing completed successfully for all intended employees.

Approved\
Run results reviewed and approved for payroll movement.

Released\
Approved results made available to downstream payroll processing.

Closed\
Run is finalized and no longer open for ordinary modification.

# 8. Participant-Level Processing and Isolation

Within a run, employees may be processed in isolatable participant
record-sets.

Participant-specific validation or calculation failures should be logged
and isolated without unnecessarily stopping successful processing for
others, provided the error does not indicate a broader shared failure
condition.

Examples of participant-level issues include:

• Invalid participant reference\
• Missing participant-specific mapping\
• Invalid amount on participant record\
• Participant-specific setup defect

These issues should result in exception logging and failed-participant
tracking rather than automatic run termination when policy allows
continuation.

# 9. Batch-Fatal and Shared Failure Handling

Certain failures shall stop the run because they threaten overall result
integrity or platform stability.

Examples include:

• Database or datastore unavailable\
• Required rule set unavailable\
• Invalid batch structure\
• Duplicate or corrupt batch identity\
• Shared reference data failure\
• Payroll calendar context not resolvable

These conditions shall generate a single clear fatal outcome for the run
rather than repeated participant-level error multiplication.

# 10. Completion Policy

The intended goal of every run is complete processing for all in-scope
employees.

However, payroll time pressure can make repeated full rollback behavior
operationally harmful. When participant-specific issues prevent full
completion, and when policy allows, the run may progress in a partially
completed state so that successful employees are not delayed
unnecessarily.

This means:

• Full completion remains the default objective.\
• Partial completion is an exception-based operational allowance.\
• Unresolved participant failures remain visible and actionable.\
• Subsequent corrective processing should aim to complete the remaining
employees before payroll deadlines whenever feasible.

# 11. Approval and Release Rules

A run in Completed status may proceed to approval in the ordinary
manner.

A run in Completed with Exceptions status may proceed to approval and
release only when:

• Partial processing is allowed by policy\
• The unresolved employees are clearly identified\
• Exception handling ownership is assigned\
• Payroll timing requires forward motion\
• Audit visibility is preserved

Release of a partially completed run does not eliminate the obligation
to resolve failed employees. It only allows successful results to move
forward while corrective action continues.

# 12. Rerun Behavior

Reruns shall preserve the original payroll context and calendar
association unless formally re-scoped.

Reruns may be initiated to:

• Reattempt failed participants\
• Process corrected input\
• Recover from prior fatal failures\
• Complete employees omitted under partial-completion policy

A rerun should not unnecessarily recalculate successfully completed work
unless required for integrity, policy, or technical reasons.

# 13. Audit and Traceability

The platform shall retain traceability for:

• Run creation and initiation\
• Included batches\
• Status transitions\
• Successful participants\
• Failed participants\
• Fatal errors\
• Approval actions\
• Release actions\
• Rerun linkage

This ensures the system can explain both full and partial completion
outcomes.

# 14. Key Design Principle

Calculation runs are governed at batch and payroll-context level, but
participant-specific problems should be isolated wherever practical.

The objective is to complete payroll for all employees. When that is not
achievable within operational constraints, policy may allow partially
completed runs to move forward so that payroll time is preserved while
unresolved participant problems are corrected.
