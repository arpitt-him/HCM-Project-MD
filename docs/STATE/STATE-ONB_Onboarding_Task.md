# STATE-ONB — Onboarding Task States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/STATE/STATE-ONB_Onboarding_Task.md` |
| **Applies To** | Individual tasks within an onboarding plan |
| **Related Documents** | HRIS_Module_PRD.md §13 |

## Purpose

Defines the lifecycle states for individual onboarding tasks. Note that blocking tasks in states other than STATE-ONB-003 (Completed) or STATE-ONB-004 (Waived) prevent payroll activation.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-ONB-001 | Not Started | Task created and assigned; work not yet begun | No |
| STATE-ONB-002 | In Progress | Task actively being worked on | No |
| STATE-ONB-003 | Completed | Task finished and confirmed | Yes |
| STATE-ONB-004 | Waived | Task formally waived with documented reason | Yes |
| STATE-ONB-005 | Overdue | Past due date; not completed | No |

**Terminal states:** STATE-ONB-003 (Completed), STATE-ONB-004 (Waived).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-ONB-001 | STATE-ONB-002 | Task owner begins work | Task is assigned to a role or user |
| STATE-ONB-001 | STATE-ONB-005 | Due date passes without progress | System-triggered; alert generated to HR contact |
| STATE-ONB-001 | STATE-ONB-004 | HR admin waives task | User holds HR Admin role; waiver reason recorded |
| STATE-ONB-002 | STATE-ONB-003 | Task owner marks complete | Completion evidence provided where required |
| STATE-ONB-002 | STATE-ONB-005 | Due date passes while in progress | System-triggered; escalation alert generated |
| STATE-ONB-002 | STATE-ONB-004 | HR admin waives task | User holds HR Admin role; waiver reason recorded |
| STATE-ONB-005 | STATE-ONB-002 | Task owner resumes work | HR contact acknowledges overdue status |
| STATE-ONB-005 | STATE-ONB-003 | Task completed after due date | Completion evidence provided; late completion recorded |
| STATE-ONB-005 | STATE-ONB-004 | HR admin waives overdue task | User holds HR Admin role; waiver reason recorded |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-ONB-003 | Any | Completed is terminal |
| STATE-ONB-004 | Any | Waived is terminal |
| STATE-ONB-001 | STATE-ONB-003 | Cannot complete without beginning work (except via waiver) |
