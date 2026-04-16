Document Title: Payroll_Run_Model

Document Version: 0.1

Status: Draft

Last Updated: 2026-04-15

Description:

Defines the identity, lifecycle, types, execution scope, restart
behavior, and closure rules for Payroll Runs within a Payroll Context.

# 1. Purpose

This document defines the Payroll Run model.

A Payroll Run represents a discrete execution event within a Payroll
Context and Period. The model establishes how runs are identified,
classified, started, monitored, restarted, corrected, and closed.
Payroll Runs are the primary execution units through which payroll
calculation progresses from readiness to completion.

# 2. Core Design Principles

Payroll Run behavior shall follow these principles:

• Every Payroll Run shall belong to exactly one Payroll Context.\
• Every Payroll Run shall belong to exactly one Period_ID.\
• Payroll Runs shall be explicitly typed and lifecycle-controlled.\
• Payroll Runs shall support isolation, restart, and correction
behavior.\
• Run identity shall remain traceable across reruns and related
activity.\
• Payroll Runs shall not exist outside calendar and context boundaries.

# 3. Payroll Run Definition

A Payroll Run represents a bounded payroll processing event.

Recommended Payroll_Run fields:

• Run_ID\
• Payroll_Context_ID\
• Period_ID\
• Run_Type\
• Run_Status\
• Pay_Date\
• Run_Start_Timestamp\
• Run_End_Timestamp (optional)\
• Initiated_By\
• Parent_Run_ID (optional)\
• Related_Run_Group_ID (optional)\
• Run_Description (optional)

Payroll Runs serve as the execution anchor for payroll processing
activity.

# 4. Relationship to Payroll Context

Every Payroll Run shall be associated with one Payroll Context.

Relationship rules include:

• A Payroll Context may contain multiple Payroll Runs.\
• A Payroll Run may not span multiple Payroll Contexts.\
• Payroll Context authorization and visibility rules apply to associated
Payroll Runs.

This relationship ensures safe segmentation and operational clarity.

# 5. Relationship to Payroll Calendar

Every Payroll Run shall be associated with one Payroll calendar entry
through Payroll_Context_ID and Period_ID.

Calendar linkage establishes:

• Pay_Date\
• Processing deadlines\
• Approval deadlines\
• Release deadlines

Runs shall inherit their effective temporal context from the associated
calendar entry.

# 6. Run Type Classification

Payroll Runs shall be classified by run type.

Typical Run_Type values include:

• Regular Run\
• Adjustment Run\
• Correction Run\
• Reprocessing Run\
• Supplemental Run\
• Simulation Run

Run type classification supports operational routing and reporting
behavior.

# 7. Run Status Lifecycle

Payroll Runs shall maintain controlled lifecycle status.

Typical Run_Status values include:

• Defined\
• Ready\
• In Progress\
• Completed\
• Completed with Exceptions\
• Awaiting Approval\
• Approved\
• Released\
• Failed\
• Closed

Status transitions shall remain auditable and visible through
dashboards.

# 8. Run Readiness

A Payroll Run shall not begin until readiness conditions are satisfied.

Typical readiness checks include:

• Payroll Context is Active\
• Calendar entry is available\
• Required assignments are resolved\
• Required rules and reference data are available\
• Required import batches are approved\
• Critical dependencies are available

Readiness checks shall be explicit and auditable.

# 9. Execution Scope

A Payroll Run shall define its execution scope clearly.

Typical scope dimensions include:

• Payroll_Context_ID\
• Period_ID\
• Included employee population\
• Included batch set\
• Included correction items\
• Included exception retries

Execution scope determines what the run is intended to process.

# 10. Multi-Run and Related Run Handling

Multiple Payroll Runs may occur within the same Payroll Context and
Period.

Examples include:

• Regular Run followed by Correction Run\
• Regular Run followed by Supplemental Run\
• Failed Run followed by Reprocessing Run

Related runs shall remain linked through Parent_Run_ID or
Related_Run_Group_ID where appropriate.

# 11. Restart and Retry Behavior

Payroll Runs shall support controlled restart and retry behavior.

Supported behaviors include:

• Restart after shared fatal failure\
• Retry of failed employee subsets\
• Correction-driven rerun\
• Supplemental follow-up run

Restart behavior shall preserve auditability and shall not duplicate
successful outcomes.

# 12. Failure Handling

Payroll Runs shall distinguish between shared failures and isolated
failures.

Typical failure handling includes:

• Shared fatal errors stop the run once\
• Employee-specific failures enter exception handling workflows\
• Completed work remains preserved where policy allows\
• Partial completion may be permitted under controlled policy

Failure handling shall align with Error Handling and Work Queue models.

# 13. Approval and Release Integration

Payroll Runs shall integrate with approval and release workflows.

Typical progression includes:

• Completed or Completed with Exceptions\
• Awaiting Approval\
• Approved\
• Released

Release shall occur only after required approvals and policy checks are
satisfied.

# 14. Run Closure Rules

Payroll Runs shall close under controlled conditions.

Typical closure conditions include:

• Processing completed\
• Required approvals completed\
• Export activity complete\
• Reconciliation complete or appropriately delegated\
• Exceptions handled according to policy

Closed runs remain historically accessible and auditable.

# 15. Operational Visibility

Payroll Runs shall be visible in operational dashboards.

Typical run-level visibility includes:

• Run status\
• Percent complete\
• Failed employee count\
• Queue counts\
• Deadline proximity\
• Approval state\
• Release state\
• Reconciliation linkage

Run visibility supports timely operational control.

# 16. Audit and Traceability

Payroll Run activity shall be fully auditable.

Required audit elements include:

• Run creation\
• Status transitions\
• Readiness validation\
• Scope definition\
• Restart events\
• Related run linkage\
• Approval and release actions\
• Closure timestamp

Auditability supports payroll accountability and compliance.

# 17. Key Design Principle

A Payroll Run is the bounded execution event through which a Payroll
Context becomes operational payroll work.

Runs must be identifiable, governable, restartable, and auditable within
their payroll and calendar boundaries.
