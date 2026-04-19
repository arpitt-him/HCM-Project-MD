# EXC-TIM — Time & Attendance Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v1.0 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/EXC/EXC-TIM_Time_Attendance_Exceptions.md` |
| **Related Documents** | docs/architecture/core/Time_Entry_and_Worked_Time_Model.md, docs/architecture/operations/Attendance_and_Exception_Tracking_Model.md, docs/STATE/STATE-TIM_Timecard.md |

## Purpose

Defines exceptions arising from time and attendance data. Time is upstream of payroll — unresolved time exceptions are among the most common sources of payroll holds in production environments.

---

### EXC-TIM-001

| Field | Detail |
|---|---|
| **Code** | EXC-TIM-001 |
| **Name** | Missing Punch — Open Time Entry |
| **Severity** | Hold |
| **Domain** | Time Entry Completeness |

**Condition:** A time entry record has an In punch with no corresponding Out punch, or an Out punch with no corresponding In punch, resulting in an open interval at payroll cutoff.

**System Behaviour:** Affected timecard held. Payroll run cannot consume an incomplete time entry. Employee routed to exception queue.

**Operator Action Required:** Obtain the correct punch time from the employee or manager. Manually complete the punch record. Reapprove the timecard before the payroll run.

**Related Codes:** EXC-TIM-002

---

### EXC-TIM-002

| Field | Detail |
|---|---|
| **Code** | EXC-TIM-002 |
| **Name** | Invalid Timecard State at Payroll Cutoff |
| **Severity** | Hard Stop |
| **Domain** | Timecard Lifecycle |

**Condition:** At payroll input cutoff, one or more timecards for active employees are in STATE-TIM-001 (Draft) or STATE-TIM-002 (Submitted) — i.e., not yet approved (STATE-TIM-004).

**System Behaviour:** Unapproved timecards cannot be locked for payroll. Affected employees excluded from run. Routed to exception queue.

**Operator Action Required:** Obtain manager approval for all outstanding timecards before the run proceeds. If the cutoff has passed, determine whether to include the employees in the current run (via emergency approval) or the next run.

**Related Codes:** EXC-TIM-001

---

### EXC-TIM-003

| Field | Detail |
|---|---|
| **Code** | EXC-TIM-003 |
| **Name** | Overtime Rule Violation |
| **Severity** | Warning |
| **Domain** | Overtime Compliance |

**Condition:** An employee's time entries would generate overtime that has not been pre-approved, or the overtime calculation appears inconsistent with the employee's FLSA classification or jurisdiction rules.

**System Behaviour:** Warning logged. Overtime calculated and included in results. Flagged on the pay register review dashboard for operator confirmation.

**Operator Action Required:** Review the overtime entries. Confirm that overtime was authorised. If the overtime is incorrect (scheduling error, timecard error), correct the source time entries and recalculate.

**Related Codes:** EXC-CAL-007

---

### EXC-TIM-004

| Field | Detail |
|---|---|
| **Code** | EXC-TIM-004 |
| **Name** | Unapproved Time Submitted After Payroll Cutoff |
| **Severity** | Warning |
| **Domain** | Cutoff Compliance |

**Condition:** Time entries were submitted for approval after the payroll input cutoff for the period. They cannot be included in the current payroll run.

**System Behaviour:** Time entries staged but not included in current run. Warning logged. Operator notified.

**Operator Action Required:** Determine whether to include the late entries in the next regular run or initiate an off-cycle correction run for the affected employees.

**Related Codes:** EXC-RUN-005

---

### EXC-TIM-005

| Field | Detail |
|---|---|
| **Code** | EXC-TIM-005 |
| **Name** | Shift Duration Anomaly |
| **Severity** | Warning |
| **Domain** | Time Reasonableness |

**Condition:** A time entry records a shift duration that exceeds a configured reasonableness threshold (e.g., shift longer than 16 hours, or negative duration due to timezone or punch entry error).

**System Behaviour:** Warning logged. Entry flagged on the timecard review dashboard. Processing continues.

**Operator Action Required:** Verify the shift duration with the employee and manager. Correct any punch entry errors before the timecard is approved.

**Related Codes:** EXC-TIM-001
