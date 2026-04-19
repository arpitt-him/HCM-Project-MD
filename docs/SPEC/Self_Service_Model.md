# SPEC — Self-Service Model

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/SPEC/Self_Service_Model.md` |
| **Related Documents** | HRIS_Module_PRD.md §14, docs/architecture/core/Reporting_Hierarchy_Model.md, docs/architecture/governance/Security_and_Access_Control_Model.md, docs/architecture/governance/Release_and_Approval_Model.md, docs/STATE/STATE-WFL_Workflow_Approval.md |

## Purpose

Defines the implementation-ready specification for employee, manager, and HR administrator self-service capabilities. Covers the permitted actions per role, the inputs and outputs for each action, the workflow events each action generates, and the access scoping rules that govern visibility.

---

## 1. Self-Service Principles

Self-service actions initiate workflow events. They never write directly to canonical records. Every self-service action that modifies data must pass through the approval workflow (STATE-WFL) before taking effect. Read-only actions (view, download) do not require workflow. Access is scoped by role and reporting hierarchy — a manager may only act on their direct reports (or full team tree if configured).

---

## 2. Role Summary

| Role | Scope | Key Capabilities |
|---|---|---|
| Employee (ESS) | Own record only | View, update contact info, submit leave, complete onboarding tasks, view pay statements |
| Manager (MSS) | Direct reports (+ team tree if configured) | View team, initiate lifecycle events, approve leave, track onboarding |
| HR Administrator | All employees within assigned org scope | Full record management, all lifecycle events, configuration |

---

## 3. Employee Self-Service (ESS) Actions

---

### ESS-001 — View Personal Record

**Description:** Employee views their own employment, personal, and assignment details.

**Inputs:** None beyond authentication.

**Outputs:**
| Field | Source |
|---|---|
| Legal name, preferred name | Entity_Person |
| Employment status, type, start date | Entity_Employee |
| Job title, department, location | Entity_Assignment → Entity_Job, Entity_Org_Unit |
| Manager name | Manager_Employment_ID → Entity_Person |
| Compensation rate (current only) | Entity_Compensation_Record |

**Events Published:** None — read-only.

**Access Scope:** Own Employment_ID only.

---

### ESS-002 — Update Contact Information

**Description:** Employee updates their own address, phone, or email. Does not require manager approval but is audit-logged.

**Inputs:**
| Field | Required | Notes |
|---|---|---|
| Address_Line_1, City, State, Postal_Code | No | Only fields being changed need be provided |
| Phone | No | |
| Personal Email | No | |

**Outputs:**
| Output | Description |
|---|---|
| Updated Person record | Contact fields updated after approval |
| Audit record | Field-level change log with before/after values |

**Events Published:** PersonContactUpdated

**Workflow:** Informational only — no approval required for contact updates. Change takes effect immediately with audit log.

**Access Scope:** Own Person_ID only.

---

### ESS-003 — Submit Leave Request

**Description:** Employee submits a leave request for manager approval.

**Inputs:**
| Field | Required | Notes |
|---|---|---|
| Leave_Type | Yes | Must be a configured leave type |
| Leave_Start_Date | Yes | Must be a future date |
| Leave_End_Date | Yes | Must be >= Leave_Start_Date |
| Leave_Reason_Code | Yes | Must reference a valid reason code |
| Supporting_Notes | No | Optional free-text |

**Outputs:**
| Output | Description |
|---|---|
| Leave Request record | Created in STATE-LEV-001 (Requested) |
| Approval workflow | STATE-WFL-001 created; routed to manager |
| Audit record | Creation logged with timestamp and employee |

**Events Published:** LeaveRequestSubmitted → routed to manager's approval queue.

**Access Scope:** Own Employment_ID only.

**Related Exceptions:** EXC-VAL-013 (missing I-9 if leave type triggers compliance check)

---

### ESS-004 — View Pay Statements

**Description:** Employee views their historical pay statements. Pay statement data is owned by Payroll; HRIS provides the access control layer.

**Inputs:** Optional date range filter.

**Outputs:**
| Output | Description |
|---|---|
| Pay statement list | All statements for own Employment_ID within requested range |
| Pay statement detail | Full check detail including earnings, deductions, taxes, YTD |

**Events Published:** None — read-only.

**Access Scope:** Own Employment_ID only. Requires integration with Payroll module (Pay_Statement_Model).

---

### ESS-005 — Complete Onboarding Task

**Description:** Employee marks an assigned onboarding task as complete and optionally uploads supporting documentation.

**Inputs:**
| Field | Required | Notes |
|---|---|---|
| Task_ID | Yes | Must be assigned to the employee |
| Completion_Notes | No | |
| Document_Upload | Conditional | Required for DOCUMENT_COMPLETION task types |

**Outputs:**
| Output | Description |
|---|---|
| Task status update | Task moves to STATE-ONB-003 (Completed) |
| Document record | Created if document uploaded |
| Plan status update | If all blocking tasks now complete, Plan_Status updated to BLOCKING_COMPLETE |

**Events Published:** OnboardingTaskCompleted; OnboardingBlockingTasksComplete (if applicable)

**Access Scope:** Own Onboarding_Plan_ID only.

---

## 4. Manager Self-Service (MSS) Actions

---

### MSS-001 — View Direct Reports

**Description:** Manager views the employment, assignment, and status details of their direct reports.

**Inputs:** Optional: full team tree toggle (shows all recursive reports, not just direct).

**Outputs:**
| Field | Source |
|---|---|
| Name, employment status, job title | Entity_Person, Entity_Employee, Entity_Assignment |
| Department, location | Entity_Assignment → Entity_Org_Unit |
| Leave status | Entity_Leave_Request (active only) |
| Onboarding completion status | Entity_Onboarding_Plan |

**Events Published:** None — read-only.

**Access Scope:** Employment records where Manager_Employment_ID = manager's Employment_ID (or full tree if configured).

---

### MSS-002 — Approve Leave Request

**Description:** Manager reviews and approves or denies a pending leave request from a direct report.

**Inputs:**
| Field | Required | Notes |
|---|---|---|
| Leave_Request_ID | Yes | Must belong to a direct report |
| Decision | Yes | APPROVE or DENY |
| Denial_Reason | Conditional | Required if Decision = DENY |

**Outputs:**
| Output | Description |
|---|---|
| Leave Request status update | Moves to STATE-LEV-002 (Approved) or STATE-LEV-003 (Denied) |
| Workflow closure | STATE-WFL-006 (Effective) reached |
| Payroll signal | If approved: payroll impact type signal queued |
| Audit record | Decision logged with timestamp and manager |

**Events Published:** LeaveRequestApproved or LeaveRequestDenied

**Access Scope:** Leave requests belonging to direct reports only.

---

### MSS-003 — Initiate Lifecycle Event

**Description:** Manager initiates a lifecycle event for a direct report. The event enters the approval workflow; it does not take effect immediately.

**Supported Event Types for MSS:**
- COMPENSATION_CHANGE
- DEPARTMENT_TRANSFER
- LOCATION_TRANSFER
- MANAGER_CHANGE
- JOB_CHANGE

**Inputs:**
| Field | Required | Notes |
|---|---|---|
| Employment_ID | Yes | Must be a direct report |
| Event_Type | Yes | See supported types above |
| Effective_Date | Yes | Must be a future or current date |
| Event_Reason_Code | Yes | |
| New values (varies by event type) | Yes | e.g., New_Compensation_Rate, New_Department_ID |

**Outputs:**
| Output | Description |
|---|---|
| Employee Event record | Created in STATE-WFL-001 (Draft) |
| Approval workflow | Routed to HR administrator or next approver |
| Audit record | Creation logged |

**Events Published:** LifecycleEventInitiated → routed to approval queue.

**Access Scope:** Direct reports only.

---

### MSS-004 — View Team Org Chart

**Description:** Manager views the org chart for their team, showing reporting relationships, job titles, and direct report counts.

**Inputs:** Optional: depth level (default = all levels).

**Outputs:** Derived org chart tree from Manager_Employment_ID relationships. Includes node attributes as defined in Reporting_Hierarchy_Model §6.

**Events Published:** None — read-only.

**Access Scope:** Manager's team tree only.

---

### MSS-005 — Track Direct Report Onboarding

**Description:** Manager views onboarding plan progress for a new direct report.

**Inputs:** Employment_ID of the new hire (must be a direct report).

**Outputs:**
| Output | Description |
|---|---|
| Plan status | Overall onboarding plan status |
| Task list | All tasks with status, owner role, due date |
| Blocking task summary | Which blocking tasks remain incomplete |

**Events Published:** None — read-only.

**Access Scope:** Direct reports' onboarding plans only.

---

## 5. Role Permission Matrix

| Action | ESS | MSS | HR Admin |
|---|---|---|---|
| View own record | ✓ | ✓ | ✓ |
| Update own contact info | ✓ | ✓ | ✓ |
| Submit leave request | ✓ | ✓ | ✓ |
| View pay statements (own) | ✓ | ✓ | ✓ |
| Complete onboarding tasks | ✓ | ✓ | ✓ |
| View direct reports | — | ✓ | ✓ |
| Approve leave requests | — | ✓ (direct reports) | ✓ |
| Initiate lifecycle events | — | ✓ (limited types) | ✓ (all types) |
| View team org chart | — | ✓ | ✓ |
| Track direct report onboarding | — | ✓ (direct reports) | ✓ |
| Create/manage employment records | — | — | ✓ |
| Manage org structure | — | — | ✓ |
| Configure leave types | — | — | ✓ |
| Generate HR reports | — | — | ✓ |
| Access sensitive fields (SSN, bank) | — | — | ✓ (with sensitive-data role) |

---

## 6. Event Model Summary

| Event | Trigger | Consumers |
|---|---|---|
| PersonContactUpdated | ESS-002 contact update | Audit log; downstream address update |
| LeaveRequestSubmitted | ESS-003 submission | Manager approval queue |
| LeaveRequestApproved | MSS-002 approval | Payroll signal; leave balance update |
| LeaveRequestDenied | MSS-002 denial | Employee notification |
| OnboardingTaskCompleted | ESS-005 task completion | Onboarding plan status evaluation |
| OnboardingBlockingTasksComplete | ESS-005 when last blocking task complete | Payroll activation signal |
| LifecycleEventInitiated | MSS-003 event initiation | HR approval queue |

---

## 7. Access Scoping Rules

All MSS actions are constrained to Employment records where Manager_Employment_ID = the acting manager's Employment_ID. Managers cannot view or act on employees outside their reporting hierarchy without explicit role elevation. HR Administrator scope is defined by org unit assignment — an HR admin assigned to Department A cannot manage Department B employees unless their scope includes both. Sensitive fields (SSN, bank account) require the Sensitive_Data_Access role in addition to the base HR Admin role. All access attempts are audit-logged per EXC-SEC-004.

---

## 8. Error Outputs

| Error Code | Condition | Severity | Behaviour |
|---|---|---|---|
| EXC-SEC-001 | Action attempted outside role scope | Hard Stop | Blocked; security alert generated |
| EXC-VAL-011 | Lifecycle event missing required reason code | Hold | Event held; operator prompted |
| EXC-VAL-014 | Lifecycle event with retroactive effective date | Hold | HR confirmation required |
| EXC-HRS-001 | Manager termination with unassigned direct reports | Hold | Termination blocked until resolved |
