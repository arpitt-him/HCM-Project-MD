# STATE-PRV — Provider Response States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Architecture Team |
| **Location** | `docs/STATE/STATE-PRV_Provider_Response.md` |
| **Applies To** | Inbound responses from downstream payroll providers |
| **Related Documents** | docs/architecture/interfaces/Payroll_Provider_Response_Model.md, docs/architecture/governance/Payroll_Reconciliation_Model.md |

## Purpose

Defines the lifecycle states for inbound provider responses from the moment of receipt through reconciliation closure.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-PRV-001 | Received | Response file or message received; not yet parsed | No |
| STATE-PRV-002 | Parsed | Response content extracted and structured | No |
| STATE-PRV-003 | Validated | Response format and correlation confirmed | No |
| STATE-PRV-004 | Matched | Response correlated to outbound export | No |
| STATE-PRV-005 | Variance Detected | Response content does not match export | No |
| STATE-PRV-006 | Exception Raised | Variance routed to exception queue for investigation | No |
| STATE-PRV-007 | Closed | Response fully processed; reconciliation complete | Yes |

**Terminal states:** STATE-PRV-007 (Closed).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-PRV-001 | STATE-PRV-002 | Parser processes response | File structurally valid; encoding confirmed |
| STATE-PRV-001 | STATE-PRV-006 | Parsing fails | Malformed file or unrecognised format |
| STATE-PRV-002 | STATE-PRV-003 | Validation passes | Provider identity confirmed; response format valid |
| STATE-PRV-002 | STATE-PRV-006 | Validation fails | Provider identity mismatch or format error |
| STATE-PRV-003 | STATE-PRV-004 | Correlation to export confirmed | Export_ID or Provider_Reference_ID matched |
| STATE-PRV-003 | STATE-PRV-006 | Correlation fails | No matching export found within timestamp range |
| STATE-PRV-004 | STATE-PRV-005 | Totals or record-level comparison finds discrepancy | Variance detected against export data |
| STATE-PRV-004 | STATE-PRV-007 | All comparisons pass | Full acceptance; no variances; reconciliation closed |
| STATE-PRV-005 | STATE-PRV-006 | Variance requires investigation | Exception queue entry created |
| STATE-PRV-006 | STATE-PRV-004 | Exception resolved; comparison re-run | Root cause corrected; re-matching attempted |
| STATE-PRV-006 | STATE-PRV-007 | Exception resolved and closed without re-match | Exception disposition documented |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-PRV-007 | Any | Closed is terminal |
| STATE-PRV-001 | STATE-PRV-004 | Cannot match without parsing and validation |
| STATE-PRV-004 | STATE-PRV-001 | Cannot revert to received after matching |
