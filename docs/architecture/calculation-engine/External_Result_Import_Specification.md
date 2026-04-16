# 1. Purpose

This document defines the structure, validation, and processing rules
for importing externally calculated earnings into the platform.

The intent is to support summarized externally calculated results that
are suitable for payroll processing while maintaining appropriate
auditability and reconciliation controls.

# 2. Supported Import Method (v0.1)

Primary Method:\
Manual CSV File Upload

Files will be uploaded by authorized administrative users through a
controlled interface. Each upload must pass validation and approval
before records become available for calculation or payroll output.

Future methods (planned but not required for v0.1):\
• Scheduled file-drop ingestion\
• API-based ingestion

# 3. Record Granularity Standard

External earnings shall be provided at summarized level.

One record is expected per:

Participant_ID + Earning_Type + Period_ID

Multiple earning types per participant are supported and expected.

Transaction-level commission detail is not required and should remain in
the originating commission system.

# 4. CSV File Structure

Required Fields:

• Participant_ID\
• Earning_Type\
• Period_ID\
• Amount\
• Source_System\
• Source_Batch_ID

Recommended Fields:

• Source_Record_Count\
• Description\
• Source_Total_Basis_Amount (optional)\
• Currency_Code (optional if single-currency environment)

Example Structure:

Participant_ID,Earning_Type,Period_ID,Amount,Source_System,Source_Batch_ID,Source_Record_Count,Description\
10025,RESIDUAL,2026-01,3104.22,COMM_SYS,BATCH-2026-01-RES,417,January
residual commissions\
10025,COMMISSION,2026-01,9842.55,COMM_SYS,BATCH-2026-01-COM,126,January
direct commissions\
10025,RECOVERY,2026-01,-420.00,COMM_SYS,BATCH-2026-01-ADJ,3,Chargeback
adjustments

# 5. Adjustment Model Standard

Multiple submissions for the same Participant_ID, Earning_Type, and
Period_ID are allowed.

Subsequent records shall be treated as adjustments rather than
replacements.

Original records shall not be overwritten.

Adjustment records may contain positive or negative amounts and must
reference the appropriate Source_Batch_ID.

This preserves audit history and prevents silent data replacement.

# 6. File Processing Workflow

The following staged workflow shall be used:

Upload → Validate → Stage → Approve → Commit

Stage:\
Records are stored in temporary holding state.

Approve:\
Authorized user reviews validation results and confirms processing.

Commit:\
Records become available for calculation and payroll processing.

# 7. Validation Rules

The system shall validate:

• Required fields present\
• Valid numeric formats\
• Period_ID format correctness\
• Earning_Type validity\
• Duplicate detection within batch\
• Participant_ID existence validation\
• Batch-level totals integrity when provided

Files failing validation shall be rejected or partially accepted
according to configured policy.

# 8. Error Handling

Errors shall be reported at both:

File Level:\
Entire file rejected due to structural failure.

Row Level:\
Individual records rejected with error logging.

Rejected records shall not be committed until corrected and resubmitted.

# 9. Reconciliation Controls

Each batch should support reconciliation using:

• Source_Batch_ID\
• Source_Record_Count\
• Expected total amount per batch (optional but recommended)

These controls allow confirmation that imported totals match source
system expectations.

# 10. Audit Requirements

The system shall record:

• Uploaded file name\
• Upload timestamp\
• Uploading user\
• Approval timestamp\
• Approving user\
• Record counts\
• Batch identifiers\
• Validation results

Audit records must be retained according to retention policy.

# 11. Security Controls

Access to upload and approval functions shall be restricted to
authorized roles.

Files shall be protected against unauthorized viewing or modification.

Sensitive financial data shall be handled according to platform security
standards.

# 12. Future Expansion Considerations

Future enhancements may include:

• Automated scheduled ingestion\
• API-based import services\
• Real-time validation services\
• Enhanced reconciliation dashboards

These enhancements shall not change the core summarized-record ingestion
model.

# 13. Key Design Principle

This platform accepts summarized externally calculated earnings suitable
for payroll processing.

Transaction-level detail remains the responsibility of the originating
commission or incentive system unless explicitly required in future
system capabilities.
