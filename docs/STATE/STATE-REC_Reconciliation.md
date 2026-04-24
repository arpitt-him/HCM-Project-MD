# STATE-REC — Reconciliation States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Compliance Domain |
| **Location** | `docs/STATE/STATE-REC_Reconciliation.md` |
| **Applies To** | Payroll reconciliation between exports and provider responses |
| **Related Documents** | docs/architecture/governance/Payroll_Reconciliation_Model.md, docs/architecture/interfaces/Payroll_Provider_Response_Model.md |

## Purpose

Defines the lifecycle states for payroll reconciliation. No payroll cycle shall be considered complete without reaching STATE-REC-007 (Closed).

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-REC-001 | Pending | Export transmitted; awaiting provider response | No |
| STATE-REC-002 | In Progress | Provider response received; reconciliation comparison under way | No |
| STATE-REC-003 | Matched | All totals and records reconcile; no variances | No |
| STATE-REC-004 | Variance Detected | Discrepancies found between exported and accepted data | No |
| STATE-REC-005 | Correction Required | Variance reviewed; correction action determined | No |
| STATE-REC-006 | Corrected | Correction applied; ready for re-reconciliation | No |
| STATE-REC-007 | Verified | Reconciliation confirmed complete; ready for closure | No |
| STATE-REC-008 | Closed | Payroll cycle reconciliation complete | Yes |

**Terminal states:** STATE-REC-008 (Closed).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-REC-001 | STATE-REC-002 | Provider response received | Response correlated to Export_ID |
| STATE-REC-002 | STATE-REC-003 | All matching criteria pass | Totals match; employee counts match; no variances |
| STATE-REC-002 | STATE-REC-004 | Variance detected | One or more matching criteria fail |
| STATE-REC-003 | STATE-REC-007 | Operator confirms match | User holds Reconciliation role |
| STATE-REC-004 | STATE-REC-005 | Operator reviews variance | Variance reviewed; correction path determined |
| STATE-REC-005 | STATE-REC-006 | Correction applied | Adjustment or correction run executed |
| STATE-REC-006 | STATE-REC-002 | Re-reconciliation triggered | New provider response or corrected data available |
| STATE-REC-007 | STATE-REC-008 | Operator closes reconciliation | All exceptions resolved; payroll cycle complete |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-REC-008 | Any | Closed is terminal |
| STATE-REC-001 | STATE-REC-003 | Cannot match without receiving and comparing response |
| STATE-REC-003 | STATE-REC-005 | Cannot require correction if matched |
| STATE-REC-007 | STATE-REC-004 | Cannot detect variance after verification |
