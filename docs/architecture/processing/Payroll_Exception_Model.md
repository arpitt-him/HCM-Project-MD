# Payroll_Exception_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Processing & Operations Domain |
| **Location** | docs/architecture/processing/Payroll_Exception_Model.md |
| **Domain** | Payroll Exceptions / Validation Failure / Operational Intervention |
| **Related Documents** | Payroll_Run_Model.md, Payroll_Run_Result_Set_Model.md, Employee_Payroll_Result_Model.md, Payroll_Run_Funding_and_Remittance_Map.md, Validation_Framework_Model.md, Exception_and_Work_Queue_Model.md, Release_and_Approval_Model.md |

---

# Purpose

This document defines the core data structure for **Payroll Exception** as the governed record used to capture, classify, route, and resolve payroll-related failures, warnings, holds, and operational review conditions.

Payroll Exception exists to preserve:

- validation failures
- calculation anomalies
- funding issues
- remittance issues
- disbursement issues
- configuration issues
- approval holds
- manual review requirements

This model exists to support:

- controlled payroll interruption
- exception-based work queues
- traceable review and resolution
- audit reconstruction
- payroll survivability under imperfect conditions
- deterministic rerun and replay after correction

without mixing exception handling into payroll result data itself.

---

# Core Structural Role

```text
Payroll Run / Payroll Run Result Set / Employee Payroll Result / Funding Use / Remittance Use / Disbursement Use
    ↓
Payroll Exception
    ↓
Classification / Severity / Routing / Resolution / Reprocessing
```

Payroll Exception is the governed operational problem record associated with payroll execution.

---

# 1. Payroll Exception Definition

A **Payroll Exception** represents a governed record of an issue, anomaly, warning, hold, or failure detected during payroll processing or its downstream operational steps.

A Payroll Exception may represent:

- missing required data
- invalid configuration
- tax calculation failure
- deduction sequencing issue
- accumulator inconsistency
- negative net pay review requirement
- funding shortfall
- remittance transmission failure
- invalid payment instruction
- approval hold
- jurisdiction mismatch
- reconciliation discrepancy

Payroll Exception shall be modeled as distinct from:

- Payroll Run
- Payroll Run Result Set
- Employee Payroll Result
- work queue item
- approval record
- correction record

Payroll Exception is the problem record, not the run, not the fix, and not the queue artifact itself.

---

# 2. Payroll Exception Primary Attributes

| Field Name | Description |
|---|---|
| Payroll_Exception_ID | Unique identifier |
| Payroll_Exception_Code | Business/system exception code |
| Payroll_Exception_Type | Validation, Calculation, Funding, Remittance, Disbursement, Approval, Reconciliation, Other |
| Payroll_Exception_Category | Hard_Stop, Hold, Warning, Informational |
| Exception_Severity | Critical, High, Medium, Low |
| Exception_Status | Open, Assigned, In_Review, Resolved, Waived, Closed, Reopened |
| Detected_Timestamp | Detection timestamp |
| Detected_By_Source | Rule engine, validation engine, user, integration, external provider, other |
| Exception_Title | Short human-readable title |
| Exception_Description | Detailed description |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Exception Context Attributes

| Field Name | Description |
|---|---|
| Payroll_Run_ID | Related payroll run where applicable |
| Payroll_Run_Result_Set_ID | Related result set where applicable |
| Employee_Payroll_Result_ID | Related employee result where applicable |
| Employment_ID | Related employment where applicable |
| Person_ID | Related person where applicable |
| Payroll_Context_ID | Related payroll context where applicable |
| Funding_Profile_ID | Related funding profile where applicable |
| Remittance_Profile_ID | Related remittance profile where applicable |
| Payment_Instruction_Profile_ID | Related payment instruction profile where applicable |
| Jurisdiction_Profile_ID | Related jurisdiction profile where applicable |
| Rule_Pack_ID | Related rule pack where applicable |
| Source_Object_Type | Generic source object type |
| Source_Object_ID | Generic source object reference |
| Run_Lineage_ID | (optional) | 
| Parent_Run_ID | (optional) |
| Root_Run_ID | (optional) |
| Replay_Sequence_Number | (optional) |
| Run_Scope_ID | (optional) |

---

# 4. Exception Classification Model

Payroll Exceptions shall be classified by operational impact.

### 4.1 Hard Stop

A Hard Stop prevents progression of payroll processing or release until resolved.

Examples:

- invalid tax configuration
- missing required legal entity funding configuration
- failed gross-to-net reconciliation
- unresolved critical validation error

Hard_Stop exceptions SHALL prevent progression of payroll lifecycle stages that depend on successful completion of the affected processing unit.

Hard_Stop conditions SHALL be evaluated during Release readiness determination.

### 4.2 Hold

A Hold pauses a downstream action pending review or approval.

Examples:

- negative net pay requiring review
- remittance release held until filing completion
- funding shortfall awaiting treasury action

### 4.3 Warning

A Warning allows processing to continue but records a significant issue requiring attention.

Examples:

- unusual deduction increase
- inactive but historically permitted address for correspondence
- calculation anomaly below block threshold

### 4.4 Informational

An Informational exception records a non-blocking event or advisory condition.

Examples:

- payroll context override used
- fallback payment channel selected
- optional review note created

---

# 5. Relationship to Payroll Run

```text
Payroll Run
    └── Payroll Exception (0..n)
```

Exceptions may attach at the run level when they affect:

- the entire run
- run release
- run approval
- reconciliation
- run-level funding or remittance behavior

Examples:

- calendar mismatch
- funding profile unavailable
- run not approved for release
- aggregate funding shortfall

---

# 6. Relationship to Employee Payroll Result

```text
Employee Payroll Result
    └── Payroll Exception (0..n)
```

Exceptions may attach at the employee-result level when they affect:

- one employee’s calculation
- one employee’s deductions
- one employee’s tax treatment
- one employee’s disbursement outcome

Examples:

- negative net pay
- garnishment priority conflict
- invalid tax treatment
- failed direct deposit

This supports targeted intervention without invalidating the entire run unnecessarily.

---

# 7. Relationship to Funding, Remittance, and Disbursement

Payroll Exception may also attach to downstream operational use records.

Funding, remittance, and disbursement exceptions SHALL remain traceable to their originating payroll run and associated financial execution artifacts.

Where external provider responses are involved, linkage SHALL include Provider_Response identifiers where available.

### 7.1 Funding Exceptions

Examples:

- funding shortfall
- invalid funding source
- profile suspended
- release approval failure

### 7.2 Remittance Exceptions

Examples:

- rejected remittance file
- filing dependency not satisfied
- invalid authority instruction
- due-date rule conflict

### 7.3 Disbursement Exceptions

Examples:

- invalid employee payment instruction
- returned ACH
- check print failure
- payment release blocked

These exceptions preserve operational failure context without rewriting result data.

---

# 8. Exception Status Model

Suggested Exception_Status values:

| Status | Meaning |
|---|---|
| Open | Newly detected and not yet worked |
| Assigned | Routed to an owner or queue |
| In_Review | Actively under investigation |
| Awaiting_Approval | Awaiting approval |
| Resolved | Corrective action completed |
| Waived | Accepted without corrective action under governance |
| Closed | Finalized and no longer active |
| Reopened | Reactivated after prior closure |

Status transitions shall be governed and auditable.

No exception may move to Resolved, Waived, or Closed without preserving the action taken and actor identity.

---

# 9. Severity and Escalation Model

Severity determines urgency and escalation behavior.

Typical handling patterns:

- **Critical** → immediate block and escalation
- **High** → same-cycle review required
- **Medium** → operational review and tracked resolution
- **Low** → advisory follow-up where permitted

Escalation behavior may depend on:

- payroll stage
- amount at risk
- number of employees affected
- regulatory sensitivity
- funding or payment exposure
- filing deadline proximity

Severity must remain explicit and queryable.

---

# 10. Exception Routing and Work Queues

Payroll Exception may be routed to work queues or operational owners.

Typical routing dimensions include:

- payroll operations
- HR operations
- compliance
- treasury/funding
- tax team
- system administration
- client administrator
- provider/integration support

Routing may be driven by:

- exception type
- severity
- legal entity
- payroll context
- jurisdiction
- amount threshold
- module or subsystem involved

Work queue linkage may be stored separately, but exception-to-queue relationship must remain traceable.

---

# 11. Resolution Model

Resolution must preserve what was done and why.

Typical resolution fields may include:

| Field Name | Description |
|---|---|
| Resolution_Type | Corrected, Approved_Override, Waived, Retried, Reissued, Other |
| Resolution_Description | Narrative explanation |
| Resolved_By_User_ID | Actor resolving the issue |
| Resolution_Timestamp | Time of resolution |
| Approval_Reference_ID | Approval record where required |
| Follow_Up_Action_Required_Flag | Indicates downstream action still required |

Exceptions may be resolved by:

- correcting source data
- changing configuration
- approving an override
- retrying an operation
- reissuing payment
- waiving the exception under controlled policy

Resolution must not erase original exception conditions.

---

# 12. Relationship to Corrections and Reruns

Exceptions often trigger corrective processing.

Examples:

- source data corrected, then run rerun
- payment returned, then disbursement reissued
- tax configuration corrected, then recalculated
- funding issue fixed, then release resumed

Payroll Exception should therefore preserve linkage to:

- correction reference
- rerun reference
- replacement run reference
- reversal/reissue reference

This allows the platform to trace issue-to-correction lineage.

Where corrective reruns are initiated due to an exception, the originating Payroll_Exception_ID SHALL be preserved as the trigger reference within the resulting child run lineage.

---

# 13. Effective Dating and Historical Preservation

Payroll Exception is an execution artifact and is therefore naturally historical.

The model must preserve:

- original detection context
- original severity and category
- status history
- routing history
- resolution history
- linkage to corrected or replacement outcomes

Historical exceptions must never be overwritten in place.

This is mandatory for:

- audit
- postmortem review
- payroll governance
- control effectiveness analysis

---

# 14. Validation Rules

Examples of validation rules:

- Payroll_Exception_Code is required
- Payroll_Exception_Type is required
- Payroll_Exception_Category is required
- Exception_Severity is required
- Exception_Status is required
- Hard_Stop exceptions may not be waived without governed approval where policy requires
- Resolved exceptions must include resolution metadata
- Closed exceptions must not remain in active work queues
- Reopened exceptions must preserve prior resolution history

These validations shall be enforced through workflow, queue, and operational governance controls.

---

# 15. Audit and Traceability Requirements

The system shall preserve:

- exception creation history
- severity history
- status transition history
- routing history
- resolution history
- source object linkage history
- approval and override history
- rerun/correction linkage history

This supports:

- payroll audit
- operational review
- control testing
- incident investigation
- regulatory inquiry response
- exception trend analysis

---

# 16. Relationship to Other Models

This model integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Payroll_Run_Funding_and_Remittance_Map
- Validation_Framework_Model
- Exception_and_Work_Queue_Model
- Release_and_Approval_Model
- Run_Lineage_Model  
- Calculation_Run_Lifecycle  
- Error_Handling_and_Isolation_Model  
- Payroll_Reconciliation_Model  
- Configuration_and_Metadata_Management_Model

---

# 17. Summary

This model establishes Payroll Exception as the governed record of payroll problems, warnings, holds, and operational failures.

Key principles:

- Payroll Exception is distinct from payroll results, work queues, and corrections
- Exceptions may attach at run, employee, funding, remittance, or disbursement levels
- Severity, category, routing, and resolution must remain explicit
- Exceptions must preserve full historical and operational lineage
- Exceptions support controlled payroll survivability rather than silent failure
