# External_Result_Import_Specification

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/calculation-engine/External_Result_Import_Specification.md` |
| **Domain** | Calculation Engine |
| **Related Documents** | PRD-400-Earnings-Model.md, PRD-900-Integration-Model.md, SPEC/External-Earnings.md, SPEC/Residual-Commissions.md, Calculation_Engine, Result_and_Payable_Model, Integration_and_Data_Exchange_Model |

## Purpose

Defines the structure, validation rules, and processing workflow for importing externally calculated earnings into the platform. Supports summarised external results suitable for payroll processing while maintaining auditability and reconciliation controls.

---

# 1. Supported Import Method (v0.1)

Primary Method:\
Manual CSV File Upload

Files will be uploaded by authorized administrative users through a
controlled interface. Each upload must pass validation and approval
before records become available for calculation or payroll output.

Future methods (planned but not required for v0.1):\
• Scheduled file-drop ingestion\
• API-based ingestion

# 2. Record Granularity Standard

External earnings shall be provided at summarized level.

One record is expected per:

Participant_ID + Earning_Type + Period_ID

Multiple earning types per participant are supported and expected.

Transaction-level commission detail is not required and should remain in
the originating commission system.

# 3. CSV File Structure

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
• Currency_Code (optional if single-currency environment)\
• Source_Period_ID (optional)\
• External_Result_Line_ID (optional but strongly recommended)\
• External_Adjustment_Reference_ID (optional)\
• Jurisdiction_Code (optional where jurisdiction-sensitive earnings apply)\
• Legal_Entity_Code (optional where multi-entity imports apply)

Example Structure:

```
Participant_ID,Earning_Type,Period_ID,Amount,Source_System,Source_Batch_ID,Source_Record_Count,Description
10025,RESIDUAL,2026-01,3104.22,COMM_SYS,BATCH-2026-01-RES,417,January residual commissions
10025,COMMISSION,2026-01,9842.55,COMM_SYS,BATCH-2026-01-COM,126,January direct commissions
10025,RECOVERY,2026-01,-420.00,COMM_SYS,BATCH-2026-01-ADJ,3,Chargeback adjustments
```

# 4. Adjustment Model Standard

Multiple submissions for the same Participant_ID, Earning_Type, and
Period_ID are allowed.

Subsequent records shall be treated as adjustments rather than
replacements.

Original records shall not be overwritten.

Adjustment records may contain positive or negative amounts and must
reference the appropriate Source_Batch_ID.

This preserves audit history and prevents silent data replacement.

Each adjustment submission shall preserve lineage to the previously committed imported result context where such context exists.

Adjustment handling shall support:

• Parent_Import_Record_ID  
• Root_Import_Record_ID  
• Adjustment_Sequence_Number  

This ensures imported-result history remains reconstructable across replay, correction, and audit workflows.

# 5. File Processing Workflow

The following staged workflow shall be used:

Upload → Validate → Stage → Approve → Commit

Stage:\
Records are stored in temporary holding state.

Approve:\
Authorized user reviews validation results and confirms processing.

Commit:\
Records become available for calculation and payroll processing.

# 6. Relationship to Payroll Execution Artifacts

Committed external result imports shall remain traceable to governed payroll execution artifacts.

Where imported results are consumed by payroll processing, the platform shall preserve linkage to:

• Payroll_Run_ID  
• Payroll_Run_Result_Set_ID  
• Employee_Payroll_Result_ID where applicable  
• Run_Scope_ID where applicable  

Imported results do not replace governed payroll execution artifacts.

They become governed payroll inputs that may later be expressed through result sets, employee payroll results, payables, accumulator impacts, and downstream exports.

# 7. Validation Rules

The system shall validate:

• Required fields present\
• Valid numeric formats\
• Period_ID format correctness\
• Earning_Type validity\
• Duplicate detection within batch\
• Participant_ID existence validation\
• Batch-level totals integrity when provided\
• Legal_Entity compatibility validation where provided\
• Jurisdiction compatibility validation where provided\
• Duplicate detection against previously committed external result lineage where applicable\
• Import compatibility with the target Payroll_Context_ID and Period_ID\
• That negative adjustments are permitted for the supplied Earning_Type where policy requires

Files failing validation shall be rejected or partially accepted
according to configured policy.

# 8. Error Handling

Errors shall be reported at both:

File Level:\
Entire file rejected due to structural failure.

Row Level:\
Individual records rejected with error logging.

Rejected records shall not be committed until corrected and resubmitted.

Rejected and corrected import records shall remain historically visible where governance policy requires.

External result import error handling shall not permit silent replacement of previously committed imported results.

# 9. Reconciliation Controls

Each batch should support reconciliation using:

• Source_Batch_ID\
• Source_Record_Count\
• Expected total amount per batch (optional but recommended)

These controls allow confirmation that imported totals match source
system expectations.

Where imported results are later consumed by payroll execution, reconciliation shall support traceability between:

• Source_Batch_ID  
• committed import records  
• Payroll_Run_Result_Set_ID  
• downstream Employee_Payroll_Result records where applicable

# 10. Audit Requirements

The system shall record:

• Uploaded file name\
• Upload timestamp\
• Uploading user\
• Approval timestamp\
• Approving user\
• Record counts\
• Batch identifiers\
• Validation results\
• Import lineage references\
• Adjustment sequence history\
• commit actor\
• target payroll context\
• target period\
• downstream execution linkage where applicable

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

# 13. Deterministic Replay Requirements

Committed external result imports shall remain replay-safe.

Replay operations shall preserve:

• original imported values
• original adjustment sequence
• original source batch lineage
• original approval and commit history

Later resubmissions or corrections shall not silently reinterpret historical imported-result state.

# 14. Relationship to Other Models

This model integrates with:

- Result_and_Payable_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Interface_and_Export_Model
- Integration_and_Data_Exchange_Model
- Exception_and_Work_Queue_Model
- Security_and_Access_Control_Model
- Data_Retention_and_Archival_Model

# 15. Key Design Principle

This platform accepts summarized externally calculated earnings suitable
for payroll processing.

Transaction-level detail remains the responsibility of the originating
commission or incentive system unless explicitly required in future
system capabilities.
