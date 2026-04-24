# STATE-TIM — Time Entry States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Time & Attendance |
| **Location** | `docs/STATE/STATE-TIM_Time_Entry.md` |
| **Applies To** | All time entry records regardless of capture method (self-service, import, API) |
| **Related Documents** | PRD-1100_Time_and_Attendance.md §7, docs/architecture/core/Time_Entry_and_Worked_Time_Model.md, docs/EXC/EXC-TIM_Time_Attendance_Exceptions.md |

## Purpose

Defines the lifecycle states for Time Entry records from initial capture through payroll consumption or voiding. These states govern payroll eligibility — only entries in Approved or Locked status may be consumed by payroll.

---

## States

| ID | State | Description | Payroll Eligible? | Terminal? |
|---|---|---|---|---|
| STATE-TIM-001 | Draft | Entry created but not yet submitted for approval | No | No |
| STATE-TIM-002 | Submitted | Submitted to manager or HR administrator for approval | No | No |
| STATE-TIM-003 | Approved | Approved by authorised approver; eligible for payroll consumption | Yes | No |
| STATE-TIM-004 | Rejected | Returned to employee for correction | No | No |
| STATE-TIM-005 | Corrected | Corrected version resubmitted following a Rejected state | No | No |
| STATE-TIM-006 | Locked | Consumed by a payroll run; immutable except via governed correction workflow | Yes | No |
| STATE-TIM-007 | Voided | Withdrawn before payroll consumption; not included in any run | No | Yes |

**Terminal states:** STATE-TIM-007 (Voided).

**Payroll-eligible states:** STATE-TIM-003 (Approved), STATE-TIM-006 (Locked).

**Immutable states:** STATE-TIM-006 (Locked). Entries in this state may not be directly edited. All changes must proceed through the correction workflow, which creates a new versioned entry linked via `Original_Time_Entry_ID`.

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-TIM-001 | STATE-TIM-002 | Employee submits timecard | Entry has valid Employment_ID, Work_Date, Duration, and Time_Category |
| STATE-TIM-001 | STATE-TIM-007 | Employee or HR admin voids entry before submission | Actor is entry owner or holds HR Admin role |
| STATE-TIM-002 | STATE-TIM-003 | Manager or HR admin approves | Actor holds Leave Approver or HR Admin role; within authorised reporting scope |
| STATE-TIM-002 | STATE-TIM-004 | Manager or HR admin rejects | Actor holds Leave Approver or HR Admin role; rejection reason recorded |
| STATE-TIM-002 | STATE-TIM-007 | Employee withdraws before decision | Employee or HR admin action before approval decision |
| STATE-TIM-003 | STATE-TIM-006 | Payroll run consumes the entry | Run has reached calculation phase; entry period matches run period |
| STATE-TIM-003 | STATE-TIM-007 | HR admin voids after approval but before payroll consumption | HR Admin role required; void reason recorded; audit log entry created |
| STATE-TIM-004 | STATE-TIM-005 | Employee submits corrected entry | Correction references original entry via Original_Time_Entry_ID |
| STATE-TIM-005 | STATE-TIM-003 | Manager or HR admin approves corrected entry | Same guard conditions as STATE-TIM-002 → STATE-TIM-003 |
| STATE-TIM-005 | STATE-TIM-004 | Manager or HR admin rejects corrected entry | Same guard conditions as STATE-TIM-002 → STATE-TIM-004 |
| STATE-TIM-006 | STATE-TIM-006 | Correction workflow creates new Locked entry | New versioned entry created; original entry remains Locked and immutable |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-TIM-007 | Any | Voided is terminal; a new entry must be created if time needs to be captured |
| STATE-TIM-006 | STATE-TIM-007 | Locked entries cannot be voided; corrections must proceed via correction workflow |
| STATE-TIM-006 | STATE-TIM-001 | Locked entries cannot revert to Draft |
| STATE-TIM-006 | STATE-TIM-004 | Locked entries cannot be rejected; correction workflow governs changes |
| STATE-TIM-003 | STATE-TIM-001 | Approved entries cannot revert to Draft |
| STATE-TIM-003 | STATE-TIM-002 | Approved entries cannot revert to Submitted |
| STATE-TIM-001 | STATE-TIM-003 | Draft entries cannot be directly approved; must be submitted first |

---

## Payroll Consumption Rules

**REQ-TIM-060 (from PRD-1100):** Only time entries in STATE-TIM-003 (Approved) or STATE-TIM-006 (Locked) may be included in a payroll run scope.

**REQ-TIM-061 (from PRD-1100):** Upon payroll consumption, the entry transitions from STATE-TIM-003 (Approved) to STATE-TIM-006 (Locked). The consuming Payroll_Run_ID is recorded on the entry.

**REQ-TIM-015 (from PRD-1100):** Time entries in Draft or Submitted status at payroll cutoff generate EXC-TIM-002 and are excluded from the run.

---

## Correction Behaviour

Corrections to Locked entries do not change the state of the original entry. The original entry remains permanently in STATE-TIM-006 as an immutable historical record.

The correction workflow creates a new time entry record with:
- A new `Time_Entry_ID`
- `Original_Time_Entry_ID` referencing the entry being corrected
- `Correction_Type` indicating the nature of the change
- `Retroactive_Flag` set where the correction affects a closed payroll period
- Initial state of STATE-TIM-001 (Draft), proceeding through the standard approval lifecycle

If the corrected entry is consumed by a subsequent payroll run, it transitions to STATE-TIM-006 independently, creating a correction lineage chain.

**Authoritative model:** `Correction_and_Immutability_Model`, `Time_Entry_and_Worked_Time_Model`

---

## Audit Requirements

All state transitions shall be recorded in the audit log with:
- Time_Entry_ID
- From state
- To state
- Actor identity
- Timestamp
- Reason code where applicable (Rejection, Void)

Audit records for Locked entries shall be retained for a minimum of seven years consistent with `Data_Retention_and_Archival_Model` and FLSA record-keeping requirements.

---

## Relationship to Exception Codes

| Condition | Exception Code | Severity |
|---|---|---|
| Entry missing valid Employment_ID | EXC-TIM-001 | Hard Stop |
| Unapproved entry at payroll input cutoff | EXC-TIM-002 | Warning |
| Approved hours exceed overtime threshold | EXC-TIM-003 | Warning |
| Entry submitted after payroll cutoff | EXC-TIM-004 | Warning |
| Shift duration exceeds reasonableness threshold | EXC-TIM-005 | Warning |
