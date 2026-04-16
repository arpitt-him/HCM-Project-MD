# 1. Purpose

This document defines the framework for detecting, classifying,
isolating, and handling errors during payroll calculation processing.

The objective is to preserve payroll time, isolate failures where
possible, prevent unnecessary rollback of successful work, and ensure
that shared failures are handled consistently and visibly.

# 2. Governing Principles

Error handling shall follow these core principles:

• Errors shall be handled at the lowest practical scope.\
• Shared failures shall terminate processing once.\
• Participant-specific failures shall be isolated where safe.\
• Full completion is always the objective.\
• Partial completion is permitted when policy allows.\
• Retry eligibility shall be determined by error classification, not by
default behavior.

# 3. Error Scope Levels

Errors shall be categorized by scope.

System-Level\
Affects platform infrastructure or shared services.

Batch-Level\
Affects the integrity or structure of the input batch.

Participant-Level\
Affects a single participant record-set.

Record-Level\
Affects an individual record within a participant set.

External-Dependency-Level\
Affects communications with external systems or delivery endpoints.

# 4. Error Severity Classes

Errors shall be assigned a severity level.

Fatal\
Processing cannot safely continue.

Recoverable\
Processing may continue with isolation.

Warning\
Processing continues; attention may be required.

Informational\
No operational impact.

# 5. Error Classification Categories

Errors shall also be classified by root cause.

Business/Data Errors\
Examples:\
• Invalid participant data\
• Missing mapping\
• Invalid earning type\
• Configuration defects

Internal Technical Errors\
Examples:\
• Database timeout\
• Lock contention\
• Temporary internal service interruption

External Dependency Errors\
Examples:\
• FTP/SFTP unavailable\
• External API timeout\
• Partner system failure

Structural Errors\
Examples:\
• Invalid batch structure\
• Missing required columns\
• Corrupt batch identifiers

Shared Infrastructure Errors\
Examples:\
• Datastore unavailable\
• Required rules unavailable\
• Calendar context unresolved

# 6. Default Handling Behavior Matrix

Handling behavior shall follow classification rules.

System Fatal:\
Stop run once and log.

Batch Fatal:\
Reject batch or stop run.

Participant Recoverable:\
Log participant failure and continue processing others.

Record Recoverable:\
Skip record and continue.

External Dependency Recoverable:\
Retry based on retry policy.

Warning:\
Log and continue.

Informational:\
Log only.

# 7. Retry Eligibility Model

Retry behavior shall be determined by classification.

Manual Correction Required:\
Business/Data Errors requiring data or configuration fixes.

Automatic Retry Eligible:\
Internal technical errors that may resolve automatically.

Conditional Retry Eligible:\
External dependency failures subject to retry limits and escalation
thresholds.

Retry behavior shall include:

• Maximum retry count\
• Retry delay intervals\
• Escalation thresholds\
• Failure notification rules

# 8. Participant Isolation Policy

Participant-level failures shall not terminate processing for unrelated
participants when safe to continue.

Failed participants shall:

• Be logged\
• Be tracked\
• Remain visible for correction\
• Be eligible for targeted rerun processing

Successful participants shall not be unnecessarily recalculated.

# 9. Shared Failure Handling

Failures affecting shared infrastructure or system-wide dependencies
shall terminate the run once.

Examples include:

• Database unavailable\
• Required rules missing\
• Shared reference data unavailable

These failures shall produce a single consolidated failure event.

# 10. Partial Completion Policy

Full completion remains the standard objective.

However, partial completion may be allowed when:

• Participant-level failures remain unresolved\
• Payroll time constraints exist\
• Policy permits continuation\
• Successful work should not be delayed

All unresolved failures must remain visible until resolved.

# 11. Logging and Traceability

All errors shall be logged with structured metadata.

Required logging attributes include:

• Error_ID\
• Timestamp\
• Error_Scope\
• Error_Severity\
• Error_Category\
• Participant_ID (if applicable)\
• Batch_ID (if applicable)\
• Run_ID\
• Retry_Eligibility\
• Resolution_Status

# 12. Recovery and Rerun Strategy

Rerun behavior shall preserve successful work where possible.

Recovery may include:

• Targeted participant rerun\
• Batch-level rerun\
• Full run restart (fatal conditions only)

Idempotent processing practices shall be supported to prevent
duplication of results.

# 13. External Dependency Failure Handling

Failures occurring during external transmission or receipt shall be
handled separately from calculation failures.

Examples:

• Failed outbound payroll delivery\
• External partner unavailability

Processing may complete internally while transmission is retried
separately.

# 14. Key Design Principle

Error handling shall preserve payroll continuity while ensuring
correctness.

Failures shall be isolated where safe, stopped where necessary, retried
where appropriate, and always recorded for audit visibility.
