# PRD-700 — Workflow Framework

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Workflow Framework |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0700_Workflow_Framework.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §10 |
| **Related Documents** | PRD-0100_Architecture_Principles, docs/architecture/governance/Release_and_Approval_Model.md |

## Purpose

Defines the requirements for approval workflow governance across all platform modules. Workflows are the mechanism by which changes move from intent to effect without bypassing controls.

---

## 1. Workflow Applicability

Approval workflows shall apply to all of the following:

**REQ-WFL-001**
Payroll run submission, approval, and release shall require approval workflow completion.

**REQ-WFL-002**
Configuration changes — pay rules, tax setup, calendar definitions — shall require approval workflow completion before becoming effective.

**REQ-WFL-003**
HR lifecycle events — hire, transfer, compensation change, termination — shall require approval workflow completion.

**REQ-WFL-004**
Leave requests shall require approval workflow completion.

**REQ-WFL-005**
Organisational structure changes shall require approval workflow completion.

**REQ-WFL-006**
External earnings import approval shall require approval workflow completion before records are committed to a payroll run.

**REQ-WFL-007**
Document-sensitive field updates shall require approval workflow completion.

## 2. Workflow States

**REQ-WFL-010**
All approval workflows shall support the following standard state lifecycle:

| STATE-WFL-001 | Draft | Change initiated but not submitted |
|---|---|---|
| STATE-WFL-002 | Submitted | Submitted for review |
| STATE-WFL-003 | Under Review | Actively being evaluated |
| STATE-WFL-004 | Approved | Approved and staged for effect |
| STATE-WFL-005 | Rejected | Returned without approval |
| STATE-WFL-006 | Effective | Applied to the system of record |
| STATE-WFL-007 | Cancelled | Withdrawn before completion |

## 3. Workflow Configuration Requirements

**REQ-WFL-020**
Workflows shall be configurable by event type, organisational unit, and employment level.

**REQ-WFL-021**
Multi-level approval chains shall be supported.

**REQ-WFL-022**
Delegation of approval authority shall be supported.

**REQ-WFL-023**
Approval deadlines and escalation rules shall be configurable.

**REQ-WFL-024**
Self-service actions shall initiate workflow events — they shall not write directly to canonical records.

## 4. Workflow Integrity

**REQ-WFL-030**
A change that is Approved but not yet Effective shall not affect payroll calculation.

**REQ-WFL-031**
Rejection of a workflow shall not leave partial state mutations.

**REQ-WFL-032**
All workflow state transitions shall be auditable with timestamp and actor.

## 5. Architecture Model Reference

- `docs/architecture/governance/Release_and_Approval_Model.md`

---

## 6. User Stories

**Payroll Administrator** needs to **submit a payroll run for approval and track its progress through the approval chain** in order to **ensure the run is authorised before payment files are generated.**

**HR Administrator** needs to **configure approval workflows by event type and organisational unit** in order to **ensure that the right approvers are notified for the right types of changes without platform engineering involvement.**

**Manager** needs to **approve or reject a subordinate's compensation change from a self-service interface** in order to **fulfil their approval role without requiring access to the full HR administrative system.**

**Compliance Auditor** needs to **retrieve the complete approval history for any payroll run or HR event** in order to **demonstrate that all required approvals were obtained before changes took effect.**

---

## 7. Scope Boundaries

### In Scope — v1

**REQ-WFL-040**
All seven workflow applicability domains defined in §1 shall require approval workflow in v1.

**REQ-WFL-041**
Multi-level approval chains shall be configurable in v1.

**REQ-WFL-042**
Delegation of approval authority shall be supported in v1.

**REQ-WFL-043**
All STATE-WFL-001 to 007 transitions shall be implemented in v1.

### Out of Scope — v1

**REQ-WFL-044**
Automated workflow routing based on machine learning or predictive approval models is out of scope for v1.

**REQ-WFL-045**
External approval integrations (e.g., approvals via email reply or third-party task management tools) are out of scope for v1. All approvals occur within the platform UI.

---

## 8. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-WFL-001 | A payroll run cannot be released without at least one approval workflow completion. Attempting to release without approval returns EXC-SEC-003. |
| REQ-WFL-002 | A configuration change to a pay rule does not take effect until the associated approval workflow reaches STATE-WFL-006 (Effective). |
| REQ-WFL-003 | A compensation change submitted by a manager enters STATE-WFL-002 (Submitted) and is routed to the configured approver. The employment record is not updated until STATE-WFL-006. |
| REQ-WFL-004 | A leave request submitted by an employee enters STATE-WFL-002 and is routed to the employee's manager. |
| REQ-WFL-020 | An administrator can configure a two-level approval chain (manager → HR director) for compensation changes without code changes. |
| REQ-WFL-021 | An approval delegated to a substitute approver is accepted and logged with both the original approver identity and the delegate identity. |
| REQ-WFL-022 | An approval deadline that passes without action generates an escalation alert to the next level in the chain. |
| REQ-WFL-024 | A self-service address update creates a workflow event. The address on the Person record is not changed until the workflow completes. |
| REQ-WFL-030 | An approved change that has not yet reached its effective date does not affect payroll calculation. |
| REQ-WFL-031 | A rejected workflow leaves the target record in its prior state with no partial modifications. |
| REQ-WFL-032 | Every workflow state transition is recorded in the audit log with actor identity and timestamp. |

---

## 9. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.


**REQ-WFL-050**
A workflow event shall be routed to the first approver's queue within 1 minute of submission.

**REQ-WFL-051**
An approver's pending approval queue shall load within 2 seconds for queues containing up to 500 items.

**REQ-WFL-052**
The workflow engine shall support at least 10,000 concurrent in-flight workflow instances without performance degradation.
