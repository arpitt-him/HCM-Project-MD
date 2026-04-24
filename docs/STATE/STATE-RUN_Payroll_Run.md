# STATE-RUN — Payroll Run Lifecycle States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Payroll Domain |
| **Location** | `docs/STATE/STATE-RUN_Payroll_Run.md` |
| **Applies To** | All payroll runs within a payroll context |
| **Related Documents** | docs/architecture/processing/Payroll_Run_Model.md, docs/architecture/processing/Calculation_Run_Lifecycle.md, docs/architecture/governance/Release_and_Approval_Model.md |

## Purpose

Defines the complete lifecycle of a payroll run from creation through closure, including failure states, reversal, and the rare reopen path. This is the primary operational state machine for payroll execution.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-RUN-001 | Created | Run shell exists; no data attached | No |
| STATE-RUN-002 | Open | Run is open for data intake: time, earnings, deductions, adjustments, retro, overrides | No |
| STATE-RUN-003 | Validating | System is performing pre-calculation validations: missing time, invalid tax setup, config gaps, garnishment conflicts, benefit eligibility issues | No |
| STATE-RUN-004 | Validation Failed | Blocking exceptions exist; run cannot proceed until resolved | No |
| STATE-RUN-005 | Ready for Calculation | All validations passed or acknowledged; run eligible for calculation | No |
| STATE-RUN-006 | Calculating | Engine computing gross, taxes, deductions, net, accumulators, retro adjustments | No |
| STATE-RUN-007 | Calculation Failed | Calculation aborted due to config errors, tax engine failures, missing data, or corrupted inputs | No |
| STATE-RUN-008 | Calculated | Gross-to-net complete; results available for review | No |
| STATE-RUN-009 | In Review | Payroll team reviewing pay registers, variance reports, retro deltas, garnishment orders, tax summaries | No |
| STATE-RUN-010 | Ready for Approval | All review steps complete; awaiting approval workflow | No |
| STATE-RUN-011 | Approval Pending | Approval workflow in progress | No |
| STATE-RUN-012 | Approved | Run approved and locked for execution | No |
| STATE-RUN-013 | Executing | System performing final net calc, payment file generation, GL mapping, tax file prep, vendor outputs | No |
| STATE-RUN-014 | Execution Failed | Payment file, GL, or tax output failed; requires correction and re-execution | No |
| STATE-RUN-015 | Completed | Execution succeeded; payments generated; outputs produced | No |
| STATE-RUN-016 | Post Processing | Downstream processes: GL posting, tax filing, vendor remittance, retro triggers, accumulator updates | No |
| STATE-RUN-017 | Closed | Run finalised; no further edits allowed | Yes |
| STATE-RUN-018 | Reopened | Run reopened for corrections; triggers mini-lifecycle | No |
| STATE-RUN-019 | Reversed | Run reversed due to incorrect payments, regulatory issues, or payroll cycle rollback | Yes |

**Terminal states:** STATE-RUN-017 (Closed), STATE-RUN-019 (Reversed). No further transitions are permitted from these states without explicit platform admin intervention.

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-RUN-001 | STATE-RUN-002 | Run opened for intake | Valid Payroll_Context_ID and Period_ID assigned |
| STATE-RUN-002 | STATE-RUN-003 | Operator initiates validation | Input cutoff reached or operator triggers manually |
| STATE-RUN-003 | STATE-RUN-004 | Validation produces blocking exceptions | One or more Hard Stop exceptions present |
| STATE-RUN-003 | STATE-RUN-005 | Validation passes | No blocking exceptions; all Holds resolved or acknowledged |
| STATE-RUN-004 | STATE-RUN-003 | Operator resolves exceptions and retriggers validation | All prior Hard Stops addressed |
| STATE-RUN-004 | STATE-RUN-002 | Operator returns run to intake for data correction | User holds Payroll Operator role |
| STATE-RUN-005 | STATE-RUN-006 | Operator initiates calculation | Run in Ready for Calculation state |
| STATE-RUN-006 | STATE-RUN-007 | Calculation engine encounters fatal error | Unrecoverable error detected during calculation |
| STATE-RUN-006 | STATE-RUN-008 | Calculation completes successfully | All employees processed; no fatal errors |
| STATE-RUN-007 | STATE-RUN-005 | Operator corrects root cause and resets | Root cause of failure resolved |
| STATE-RUN-008 | STATE-RUN-009 | Operator begins review | User holds Payroll Reviewer role |
| STATE-RUN-009 | STATE-RUN-006 | Reviewer identifies issues requiring recalculation | User holds Payroll Reviewer role; recalc reason recorded |
| STATE-RUN-009 | STATE-RUN-010 | Reviewer completes review | All review checklist items completed |
| STATE-RUN-010 | STATE-RUN-011 | Operator submits for approval | Approval workflow initiated |
| STATE-RUN-011 | STATE-RUN-012 | Approver approves | User holds Approver role; STATE-WFL-006 reached |
| STATE-RUN-011 | STATE-RUN-009 | Approver rejects and returns | User holds Approver role; rejection reason recorded |
| STATE-RUN-012 | STATE-RUN-013 | System initiates execution | Run approved; execution window open |
| STATE-RUN-013 | STATE-RUN-014 | Execution encounters fatal error | Payment file, GL, or tax output failure |
| STATE-RUN-013 | STATE-RUN-015 | Execution completes successfully | All outputs generated |
| STATE-RUN-014 | STATE-RUN-012 | Operator corrects and resubmits for execution | Root cause resolved; re-approval may be required per policy |
| STATE-RUN-015 | STATE-RUN-016 | Downstream processing begins | Post-processing tasks initiated |
| STATE-RUN-015 | STATE-RUN-017 | No post-processing required; run closed directly | Policy allows direct closure |
| STATE-RUN-016 | STATE-RUN-017 | All post-processing complete | GL posted, tax filed, remittances sent |
| STATE-RUN-017 | STATE-RUN-018 | Admin reopens for correction | Requires elevated admin role; audit record created; rare |
| STATE-RUN-018 | STATE-RUN-009 | Correction reviewed; re-enters review cycle | Corrections applied; review reinitiated |
| STATE-RUN-017 | STATE-RUN-019 | Run reversed | Requires elevated admin role; regulatory or payment error confirmed |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-RUN-017 | Any (except STATE-RUN-018, STATE-RUN-019) | Closed is terminal; reopen or reversal requires explicit admin action |
| STATE-RUN-019 | Any | Reversed is terminal; a new corrective run must be created |
| STATE-RUN-012 | STATE-RUN-002 | Cannot return to open intake after approval without reverting through review |
| STATE-RUN-006 | STATE-RUN-002 | Cannot return to intake during calculation |
| STATE-RUN-001 | STATE-RUN-005 | Cannot skip validation |
| STATE-RUN-001 | STATE-RUN-012 | Cannot approve a run that has not been calculated and reviewed |
