# EXC-CAL — Calculation Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/EXC/EXC-CAL_Calculation_Exceptions.md` |
| **Related Documents** | docs/architecture/calculation-engine/Calculation_Engine.md, docs/architecture/calculation-engine/Earnings_and_Deductions_Computation_Model.md, docs/architecture/processing/Calculation_Run_Lifecycle.md |

## Purpose

Defines exceptions arising from the payroll calculation engine — failures during gross-to-net computation, rule application, accumulator updates, and result generation. EXC-CAL is distinct from EXC-VAL (pre-calculation validation failures) and EXC-RUN (run lifecycle failures).

---

### EXC-CAL-001

| Field | Detail |
|---|---|
| **Code** | EXC-CAL-001 |
| **Name** | Calculation Rule Not Found |
| **Severity** | Hard Stop |
| **Domain** | Rule Resolution |

**Condition:** The rule resolution engine cannot find an applicable rule version for a required calculation step given the employee's context, jurisdiction, and effective date.

**System Behaviour:** Calculation halted for the affected employee. Routed to exception queue with resolution context snapshot. Run continues for unaffected employees.

**Operator Action Required:** Verify that the required rule exists, is active, and covers the effective date and jurisdiction. If missing, create and approve the rule before reprocessing.

**Related Codes:** EXC-CFG-001, EXC-VAL-020

---

### EXC-CAL-002

| Field | Detail |
|---|---|
| **Code** | EXC-CAL-002 |
| **Name** | Ambiguous Rule Resolution |
| **Severity** | Hard Stop |
| **Domain** | Rule Resolution |

**Condition:** Two or more rule versions remain as candidates after specificity and priority evaluation for the same employee context and calculation step. The resolution engine cannot determine a single winner.

**System Behaviour:** Calculation halted for the affected employee. Ambiguity details logged with all candidate rule versions. Routed to exception queue.

**Operator Action Required:** Review the competing rule versions. Resolve the ambiguity by adjusting priority values, narrowing applicability domains, or retiring the conflicting version.

**Related Codes:** EXC-CAL-001

---

### EXC-CAL-003

| Field | Detail |
|---|---|
| **Code** | EXC-CAL-003 |
| **Name** | Earnings Computation Produced Unexpected Result |
| **Severity** | Warning |
| **Domain** | Earnings Computation |

**Condition:** An earnings computation produced a result outside a configured reasonableness threshold. Examples: hourly calculation yielding an implausibly large amount; salary proration producing zero where non-zero is expected.

**System Behaviour:** Warning logged. Result retained for review. Processing continues. Flagged on the pay register review dashboard.

**Operator Action Required:** Review the flagged computation. Confirm the result is correct given the inputs (hours, rate, proration rules) or identify and correct the source of the anomaly.

**Related Codes:** EXC-VAL-004

---

### EXC-CAL-004

| Field | Detail |
|---|---|
| **Code** | EXC-CAL-004 |
| **Name** | Deduction Exceeds Available Net Pay |
| **Severity** | Warning |
| **Domain** | Deductions Computation |

**Condition:** A mandatory or voluntary deduction amount exceeds the employee's available net pay after prior deductions and taxes. The system cannot fully apply the deduction without producing negative net pay.

**System Behaviour:** Warning logged. Partial deduction applied up to available net pay. Arrears balance created for the unrecovered amount. Operator notified.

**Operator Action Required:** Review the arrears balance. Determine whether to carry the arrears to the next period, waive it, or take corrective action on the deduction configuration.

**Related Codes:** EXC-VAL-002, EXC-DED-001

---

### EXC-CAL-005

| Field | Detail |
|---|---|
| **Code** | EXC-CAL-005 |
| **Name** | Accumulator Update Failed |
| **Severity** | Hard Stop |
| **Domain** | Accumulator Processing |

**Condition:** The accumulator engine failed to post a contribution for a payroll result line. This may be caused by a missing accumulator definition, a broken accumulator-to-code mapping, or a database integrity failure.

**System Behaviour:** Calculation halted for the affected employee. Partial accumulator state is rolled back. Employee routed to exception queue.

**Operator Action Required:** Identify the root cause — missing accumulator definition, broken code mapping, or infrastructure failure. Resolve and reprocess. Do not allow partial accumulator state to persist.

**Related Codes:** EXC-CFG-002, EXC-VAL-021

---

### EXC-CAL-006

| Field | Detail |
|---|---|
| **Code** | EXC-CAL-006 |
| **Name** | Retro Calculation Produced Irreconcilable Delta |
| **Severity** | Hold |
| **Domain** | Retroactive Recalculation |

**Condition:** A retroactive recalculation produced a delta that cannot be automatically reconciled with the prior posted result. Examples: conflicting accumulator states; correction affecting a wage-base-limited tax that has already been fully collected.

**System Behaviour:** Retro delta held. Not posted. Routed to exception queue with before-and-after comparison.

**Operator Action Required:** Review the retro delta report. Determine the correct corrective treatment and either approve the delta for posting or initiate a manual correction workflow.

**Related Codes:** EXC-COR-001, EXC-VAL-014

---

### EXC-CAL-007

| Field | Detail |
|---|---|
| **Code** | EXC-CAL-007 |
| **Name** | Overtime Rule Conflict |
| **Severity** | Hold |
| **Domain** | Overtime Computation |

**Condition:** Two or more overtime rules are applicable to the same employee for the same period and their combined application produces conflicting results. Examples: FLSA daily overtime conflicts with a state weekly overtime rule.

**System Behaviour:** Overtime calculation held for the affected employee. Conflict details logged with both rule versions. Routed to exception queue.

**Operator Action Required:** Review the conflicting rules. Configure the rule priority or applicability to resolve the conflict, then reprocess.

**Related Codes:** EXC-CAL-002
