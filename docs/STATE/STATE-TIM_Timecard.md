# STATE-TIM — Timecard / Timesheet States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Payroll Domain |
| **Location** | `docs/STATE/STATE-TIM_Timecard.md` |
| **Applies To** | Timecards and timesheets; upstream of payroll calculation |
| **Related Documents** | docs/architecture/core/Time_Entry_and_Worked_Time_Model.md, docs/architecture/core/Scheduling_and_Shift_Model.md |

## Purpose

Defines the lifecycle states for timecards and timesheets. Payroll shall only consume time entries in STATE-TIM-004 (Approved) or STATE-TIM-005 (Locked for Payroll).

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-TIM-001 | Draft | Timecard created; employee entering time | No |
| STATE-TIM-002 | Submitted | Employee submitted for manager review | No |
| STATE-TIM-003 | Rejected | Manager rejected; returned to employee for correction | No |
| STATE-TIM-004 | Approved | Manager approved; eligible for payroll consumption | No |
| STATE-TIM-005 | Locked for Payroll | Consumed by payroll run; no further edits permitted | No |
| STATE-TIM-006 | Corrected | Post-approval correction applied; creates audit trail | Yes |

**Terminal states:** STATE-TIM-006 (Corrected). A corrected timecard is replaced by a new version which begins at STATE-TIM-001.

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-TIM-001 | STATE-TIM-002 | Employee submits timecard | All required hours fields populated; within submission window |
| STATE-TIM-001 | STATE-TIM-001 | Employee saves draft | No constraint |
| STATE-TIM-002 | STATE-TIM-004 | Manager approves | User holds Time Approver role |
| STATE-TIM-002 | STATE-TIM-003 | Manager rejects | User holds Time Approver role; rejection reason recorded |
| STATE-TIM-003 | STATE-TIM-001 | Employee revises and saves | Employee acknowledges rejection |
| STATE-TIM-003 | STATE-TIM-002 | Employee resubmits | Corrections made |
| STATE-TIM-004 | STATE-TIM-005 | Payroll run locks timecard for calculation | Run in STATE-RUN-003 or later; payroll input cutoff passed |
| STATE-TIM-004 | STATE-TIM-001 | Manager or HR admin reverts for correction | Before payroll cutoff; reason recorded |
| STATE-TIM-005 | STATE-TIM-006 | Post-payroll correction applied | Requires payroll correction run; correction workflow approved |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-TIM-005 | STATE-TIM-001 | Locked timecards cannot be directly edited; a correction must be filed |
| STATE-TIM-006 | Any | Corrected is terminal; corrections create a new timecard version |
| STATE-TIM-002 | STATE-TIM-005 | Cannot lock for payroll without approval |
| STATE-TIM-001 | STATE-TIM-005 | Cannot lock a draft timecard |
