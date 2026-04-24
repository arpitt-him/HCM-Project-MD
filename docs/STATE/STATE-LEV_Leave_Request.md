# STATE-LEV — Leave Request States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/STATE/STATE-LEV_Leave_Request.md` |
| **Applies To** | All leave requests across all leave types |
| **Related Documents** | HRIS_Module_PRD.md §11, docs/architecture/core/Leave_and_Absence_Management_Model.md |

## Purpose

Defines the lifecycle states for leave requests from initial submission through completion or cancellation.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-LEV-001 | Requested | Leave submitted by employee; awaiting manager or HR decision | No |
| STATE-LEV-002 | Approved | Leave approved; not yet started | No |
| STATE-LEV-003 | Denied | Leave request rejected | Yes |
| STATE-LEV-004 | Scheduled | Approved and confirmed for a future date | No |
| STATE-LEV-005 | Active | Employee currently on leave | No |
| STATE-LEV-006 | Completed | Leave period ended; employee returned to work | Yes |
| STATE-LEV-007 | Cancelled | Leave withdrawn before activation | Yes |

**Terminal states:** STATE-LEV-003 (Denied), STATE-LEV-006 (Completed), STATE-LEV-007 (Cancelled).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-LEV-001 | STATE-LEV-002 | Manager or HR approves | User holds Leave Approver role |
| STATE-LEV-001 | STATE-LEV-003 | Manager or HR denies | User holds Leave Approver role; denial reason recorded |
| STATE-LEV-001 | STATE-LEV-007 | Employee withdraws request | Employee or HR admin action before approval decision |
| STATE-LEV-002 | STATE-LEV-004 | Leave confirmed for specific dates | Leave dates confirmed; payroll signals generated |
| STATE-LEV-002 | STATE-LEV-007 | Employee cancels approved leave | Employee or HR admin action; before leave start date |
| STATE-LEV-004 | STATE-LEV-005 | Leave start date reached | System-triggered; payroll earnings impact activated |
| STATE-LEV-004 | STATE-LEV-007 | Employee cancels before leave begins | Employee or HR admin action; before leave start date |
| STATE-LEV-005 | STATE-LEV-006 | Leave end date reached or Return to Work event | System-triggered or HR admin records return |
| STATE-LEV-005 | STATE-LEV-007 | Leave cancelled while active (exceptional) | HR admin action; requires payroll correction if earnings impacted |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-LEV-003 | Any | Denied is terminal; a new leave request must be submitted |
| STATE-LEV-006 | Any | Completed is terminal |
| STATE-LEV-007 | Any | Cancelled is terminal |
| STATE-LEV-001 | STATE-LEV-005 | Cannot go Active without Approved and Scheduled states |
| STATE-LEV-002 | STATE-LEV-006 | Cannot complete without going Active |
