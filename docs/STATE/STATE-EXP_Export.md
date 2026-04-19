# STATE-EXP — Export States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Architecture Team |
| **Location** | `docs/STATE/STATE-EXP_Export.md` |
| **Applies To** | Outbound payroll export units |
| **Related Documents** | docs/architecture/interfaces/Payroll_Interface_and_Export_Model.md, docs/architecture/governance/Correction_and_Immutability_Model.md |

## Purpose

Defines the lifecycle states for outbound payroll export units — from preparation through confirmed delivery.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-EXP-001 | Prepared | Export unit assembled from approved payroll results; not yet transmitted | No |
| STATE-EXP-002 | Ready | Export unit validated and cleared for transmission | No |
| STATE-EXP-003 | Sent | Transmission initiated; awaiting delivery confirmation | No |
| STATE-EXP-004 | Delivered | Export received by downstream system | No |
| STATE-EXP-005 | Failed | Transmission failed; retry eligible | No |
| STATE-EXP-006 | Retrying | Retry in progress after failure | No |
| STATE-EXP-007 | Confirmed | Downstream system confirmed successful processing | Yes |
| STATE-EXP-008 | Closed | Export lifecycle complete; no further action | Yes |

**Terminal states:** STATE-EXP-007 (Confirmed), STATE-EXP-008 (Closed).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-EXP-001 | STATE-EXP-002 | Export validation passes | All records valid; format confirmed; release approval complete |
| STATE-EXP-001 | STATE-EXP-005 | Export validation fails | Invalid records or format errors detected |
| STATE-EXP-002 | STATE-EXP-003 | Transmission initiated | Transmission window open; credentials valid |
| STATE-EXP-003 | STATE-EXP-004 | Delivery acknowledgment received | Downstream system acknowledges receipt |
| STATE-EXP-003 | STATE-EXP-005 | Transmission failure detected | Network error, timeout, or rejection |
| STATE-EXP-004 | STATE-EXP-007 | Downstream confirms successful processing | Provider response received; STATE-PRV-003 or equivalent |
| STATE-EXP-004 | STATE-EXP-005 | Downstream rejects after delivery | Provider response indicates rejection |
| STATE-EXP-005 | STATE-EXP-006 | Retry initiated | Retry count within max limit; root cause assessed |
| STATE-EXP-005 | STATE-EXP-008 | Max retries exceeded; manually closed | Operator closes after exhausting retries |
| STATE-EXP-006 | STATE-EXP-003 | Retry transmission sent | Idempotency key confirms no duplicate delivery risk |
| STATE-EXP-007 | STATE-EXP-008 | Export closed after confirmation | All downstream acknowledgments received |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-EXP-007 | Any | Confirmed is terminal |
| STATE-EXP-008 | Any | Closed is terminal |
| STATE-EXP-003 | STATE-EXP-001 | Cannot revert to prepared during transmission |
| STATE-EXP-007 | STATE-EXP-005 | Cannot fail after confirmation |
