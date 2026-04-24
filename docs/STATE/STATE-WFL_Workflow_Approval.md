# STATE-WFL — Workflow / Approval States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/STATE/STATE-WFL_Workflow_Approval.md` |
| **Applies To** | All approval workflows across the platform |
| **Related Documents** | docs/architecture/governance/Release_and_Approval_Model.md, PRD-0700_Workflow_Framework.md, HRIS_Module_PRD.md §16 |

## Purpose

Defines the canonical state lifecycle for all approval workflows in the platform. This model applies to payroll run approval, HR lifecycle events, configuration changes, leave requests, and any other domain using the platform approval framework.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-WFL-001 | Draft | Change initiated but not yet submitted for review | No |
| STATE-WFL-002 | Submitted | Submitted and awaiting assignment to a reviewer | No |
| STATE-WFL-003 | Under Review | Actively being evaluated by an assigned approver | No |
| STATE-WFL-004 | Approved | Approved and staged to become effective | No |
| STATE-WFL-005 | Rejected | Returned to initiator without approval | Yes |
| STATE-WFL-006 | Effective | Applied to the system of record | Yes |
| STATE-WFL-007 | Cancelled | Withdrawn by initiator before completion | Yes |

**Terminal states:** STATE-WFL-005 (Rejected), STATE-WFL-006 (Effective), STATE-WFL-007 (Cancelled). No further transitions are permitted from these states.

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-WFL-001 | STATE-WFL-002 | Initiator submits | User holds Initiator role; all required fields populated |
| STATE-WFL-001 | STATE-WFL-007 | Initiator cancels | User is the original initiator |
| STATE-WFL-002 | STATE-WFL-003 | Approver claims or is assigned | User holds Approver role for the event type and org scope |
| STATE-WFL-002 | STATE-WFL-007 | Initiator withdraws before assignment | User is the original initiator |
| STATE-WFL-003 | STATE-WFL-004 | Approver approves | User holds Approver role; all approval conditions met |
| STATE-WFL-003 | STATE-WFL-005 | Approver rejects | User holds Approver role; rejection reason recorded |
| STATE-WFL-003 | STATE-WFL-002 | Approver returns for revision | User holds Approver role; revision reason recorded |
| STATE-WFL-004 | STATE-WFL-006 | Effective date reached or system applies | Approval status = Approved; no blocking holds |
| STATE-WFL-004 | STATE-WFL-007 | Initiator or admin cancels before effective | User holds Initiator or Admin role; change not yet effective |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-WFL-005 | Any | Rejected is terminal. A new workflow instance must be created to retry. |
| STATE-WFL-006 | Any | Effective is terminal. Changes to effective records require a new workflow or correction. |
| STATE-WFL-007 | Any | Cancelled is terminal. |
| STATE-WFL-001 | STATE-WFL-004 | Cannot approve without submission and review. |
| STATE-WFL-004 | STATE-WFL-003 | Cannot return to review after approval without cancelling and resubmitting. |
