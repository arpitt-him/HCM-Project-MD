# STATE-EMP — Employment Lifecycle States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/STATE/STATE-EMP_Employment_Lifecycle.md` |
| **Applies To** | Person records, Employment records, Job Position records |
| **Related Documents** | HRIS_Module_PRD.md §5, §6, §8, docs/architecture/core/Employment_and_Person_Identity_Model.md, docs/architecture/core/Employee_Event_and_Status_Change_Model.md |

## Purpose

Defines the lifecycle states for Person records, Employment records, and Position records within the HRIS module.

---

## Person States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-EMP-001 | Active | Has at least one active Employment record | No |
| STATE-EMP-002 | Inactive | No active Employment; record retained for history | No |
| STATE-EMP-003 | Deceased | Deceased; record preserved permanently for legal purposes | Yes |
| STATE-EMP-004 | Restricted | Access-restricted; reason managed by HR admin | No |

**Terminal states:** STATE-EMP-003 (Deceased).

### Person Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-EMP-001 | STATE-EMP-002 | All Employment records closed or terminated | System-triggered when last active Employment closes |
| STATE-EMP-002 | STATE-EMP-001 | New Employment record created (rehire) | Valid Employment record activated |
| STATE-EMP-001 | STATE-EMP-003 | Deceased event recorded | HR admin records death; supporting documentation required |
| STATE-EMP-002 | STATE-EMP-003 | Deceased event recorded | HR admin records death |
| STATE-EMP-001 | STATE-EMP-004 | Restriction applied by admin | User holds HR Admin role; reason code required |
| STATE-EMP-004 | STATE-EMP-001 | Restriction lifted | User holds HR Admin role |

### Invalid Person Transitions

| From | To | Reason |
|---|---|---|
| STATE-EMP-003 | Any | Deceased is terminal |
| STATE-EMP-002 | STATE-EMP-004 | Restriction applies to active persons only |

---

## Employment States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-EMP-010 | Pending | Hire initiated; not yet at employment start date | No |
| STATE-EMP-011 | Active | Currently employed and payroll-eligible | No |
| STATE-EMP-012 | On Leave | Active employment; employee currently on approved leave | No |
| STATE-EMP-013 | Suspended | Employment suspended pending investigation or administrative action | No |
| STATE-EMP-014 | Terminated | Employment ended; record preserved | Yes |
| STATE-EMP-015 | Closed | All obligations settled; record fully archived | Yes |

**Terminal states:** STATE-EMP-014 (Terminated), STATE-EMP-015 (Closed).

### Employment Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-EMP-010 | STATE-EMP-011 | Employment start date reached | Hire workflow approved; onboarding blocking tasks complete |
| STATE-EMP-010 | STATE-EMP-014 | Hire rescinded before start date | HR admin action; workflow approved |
| STATE-EMP-011 | STATE-EMP-012 | Leave of Absence approved | Leave request in STATE-LEV-002 |
| STATE-EMP-011 | STATE-EMP-013 | Suspension applied | HR admin action; workflow approved |
| STATE-EMP-011 | STATE-EMP-014 | Termination event | Termination workflow approved; final pay calculated |
| STATE-EMP-012 | STATE-EMP-011 | Return to Work event | Return to Work workflow approved |
| STATE-EMP-012 | STATE-EMP-014 | Termination while on leave | Termination workflow approved |
| STATE-EMP-013 | STATE-EMP-011 | Suspension lifted | HR admin action; workflow approved |
| STATE-EMP-013 | STATE-EMP-014 | Termination during suspension | Termination workflow approved |
| STATE-EMP-014 | STATE-EMP-015 | All termination obligations settled | Final pay issued; benefits terminated; documents archived |

### Invalid Employment Transitions

| From | To | Reason |
|---|---|---|
| STATE-EMP-014 | Any | Terminated is terminal; rehire creates a new Employment_ID |
| STATE-EMP-015 | Any | Closed is terminal |
| STATE-EMP-010 | STATE-EMP-012 | Cannot go on leave before employment starts |
| STATE-EMP-010 | STATE-EMP-013 | Cannot be suspended before employment starts |
| STATE-EMP-011 | STATE-EMP-010 | Cannot revert to Pending once Active |

---

## Position States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-EMP-020 | Open | Position exists and is available for filling | No |
| STATE-EMP-021 | Filled | Position currently occupied by an active employee | No |
| STATE-EMP-022 | Frozen | Position exists but hiring is suspended | No |
| STATE-EMP-023 | Closed | Position eliminated | Yes |

**Terminal states:** STATE-EMP-023 (Closed).

### Position Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-EMP-020 | STATE-EMP-021 | Employee assigned to position | Assignment workflow approved |
| STATE-EMP-021 | STATE-EMP-020 | Employee vacates position | Termination, transfer, or resignation event |
| STATE-EMP-020 | STATE-EMP-022 | Hiring freeze applied | HR admin action |
| STATE-EMP-022 | STATE-EMP-020 | Hiring freeze lifted | HR admin action |
| STATE-EMP-021 | STATE-EMP-022 | Freeze applied while filled | HR admin action; existing occupant unaffected |
| STATE-EMP-020 | STATE-EMP-023 | Position eliminated | Workflow approved; no active occupant |
| STATE-EMP-022 | STATE-EMP-023 | Position eliminated while frozen | Workflow approved |

### Invalid Position Transitions

| From | To | Reason |
|---|---|---|
| STATE-EMP-023 | Any | Closed is terminal |
| STATE-EMP-021 | STATE-EMP-023 | Cannot eliminate a filled position; occupant must vacate first |
