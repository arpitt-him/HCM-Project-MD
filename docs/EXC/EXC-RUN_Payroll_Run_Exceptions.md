# EXC-RUN — Payroll Run Lifecycle Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/EXC/EXC-RUN_Payroll_Run_Exceptions.md` |
| **Related Documents** | docs/STATE/STATE-RUN_Payroll_Run.md, docs/architecture/processing/Payroll_Run_Model.md, docs/architecture/processing/Calculation_Run_Lifecycle.md, docs/architecture/operations/Exception_and_Work_Queue_Model.md |

## Purpose

Defines exceptions arising from the payroll run lifecycle itself — run initiation failures, stuck states, aborts, and conditions requiring manual intervention. These are distinct from calculation logic failures (EXC-CAL) and validation failures (EXC-VAL).

---

### EXC-RUN-001

| Field | Detail |
|---|---|
| **Code** | EXC-RUN-001 |
| **Name** | Run Failed to Start |
| **Severity** | Hard Stop |
| **Domain** | Run Initiation |

**Condition:** A payroll run was initiated but failed to transition from STATE-RUN-001 (Created) to STATE-RUN-002 (Open). Causes include: missing calendar entry, invalid Payroll_Context_ID, insufficient system resources, or permission failure.

**System Behaviour:** Run remains in Created state. Error logged with failure reason. Alert generated to payroll operations team.

**Operator Action Required:** Identify the root cause from the error log. Resolve the blocking condition (calendar, context, permission, or infrastructure) and retry run creation.

**Related Codes:** EXC-CFG-005, EXC-VAL-024, EXC-SEC-001

---

### EXC-RUN-002

| Field | Detail |
|---|---|
| **Code** | EXC-RUN-002 |
| **Name** | Run Stuck in Processing State |
| **Severity** | Hard Stop |
| **Domain** | Run Execution |

**Condition:** A payroll run has been in STATE-RUN-006 (Calculating) or STATE-RUN-013 (Executing) beyond the configured timeout threshold without completing or failing. No progress has been detected.

**System Behaviour:** Monitoring alert triggered. Run flagged as stuck. No automatic state transition occurs.

**Operator Action Required:** Investigate the run for hung threads, infrastructure failures, or deadlocked processes. Escalate to platform engineering if infrastructure-level intervention is required. Do not manually advance the run state without confirming process completion.

**Related Codes:** EXC-RUN-003

---

### EXC-RUN-003

| Field | Detail |
|---|---|
| **Code** | EXC-RUN-003 |
| **Name** | Run Aborted Due to Infrastructure Failure |
| **Severity** | Hard Stop |
| **Domain** | Run Execution |

**Condition:** A run was forcibly aborted because of a platform infrastructure failure — database unavailability, out-of-memory condition, network partition, or unhandled system exception — that prevented safe continuation.

**System Behaviour:** Run transitions to STATE-RUN-007 (Calculation Failed) or STATE-RUN-014 (Execution Failed) depending on phase. Partial results are rolled back. Full error context captured.

**Operator Action Required:** Verify infrastructure health. Confirm rollback completed cleanly. Once infrastructure is stable, reset and rerun from the appropriate restart point. Do not proceed with partial results.

**Related Codes:** EXC-RUN-002, EXC-VAL-003

---

### EXC-RUN-004

| Field | Detail |
|---|---|
| **Code** | EXC-RUN-004 |
| **Name** | Run Requires Manual Intervention |
| **Severity** | Hold |
| **Domain** | Run Lifecycle |

**Condition:** The run has surfaced one or more conditions that require a human decision before it can proceed. Examples: unresolved exception queue items at or above Hold severity; approval workflow pending beyond the deadline; compliance-sensitive validation exception requiring senior sign-off.

**System Behaviour:** Run held at current state. Deadline risk alert generated if payroll pay date is within configured proximity threshold.

**Operator Action Required:** Review and resolve the specific conditions blocking the run. Each blocking item must be individually acknowledged or resolved before the run can advance.

**Related Codes:** EXC-VAL-002, EXC-VAL-014, EXC-CAL-006

---

### EXC-RUN-005

| Field | Detail |
|---|---|
| **Code** | EXC-RUN-005 |
| **Name** | Run Initiated After Input Cutoff |
| **Severity** | Warning |
| **Domain** | Run Timing |

**Condition:** A payroll run was initiated after the configured Input_Cutoff date for the period. Some inputs submitted before the cutoff may not have been included.

**System Behaviour:** Warning logged. Run proceeds. Operator dashboard highlights the late initiation. Cutoff override recorded for audit.

**Operator Action Required:** Confirm that all expected inputs were received before the cutoff. Identify any late inputs and decide whether to include them via an off-cycle run or accept their omission.

**Related Codes:** EXC-RUN-004

---

### EXC-RUN-006

| Field | Detail |
|---|---|
| **Code** | EXC-RUN-006 |
| **Name** | Payroll Run Deadline at Risk |
| **Severity** | Warning |
| **Domain** | Run Timing |

**Condition:** The payroll run is in an unresolved state (e.g., exceptions outstanding, approval pending) and the Pay_Date is within the configured deadline-risk proximity threshold.

**System Behaviour:** Escalation alert generated to Payroll Supervisor and Finance. Warning surfaced on the operational dashboard.

**Operator Action Required:** Treat as urgent. Escalate unresolved items. Initiate emergency approval procedures if applicable. Document any decisions made under deadline pressure.

**Related Codes:** EXC-RUN-004
