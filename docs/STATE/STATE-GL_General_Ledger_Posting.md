# STATE-GL — General Ledger Posting States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Payroll Domain |
| **Location** | `docs/STATE/STATE-GL_General_Ledger_Posting.md` |
| **Applies To** | Journal entries generated from payroll results |
| **Related Documents** | docs/architecture/interfaces/General_Ledger_and_Accounting_Export_Model.md, docs/architecture/governance/Correction_and_Immutability_Model.md |

## Purpose

Defines the lifecycle states for GL journal entries generated from payroll. GL states are separate from payroll run states because GL has its own accounting lifecycle and may be managed by a different team.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-GL-001 | Generated | Journal entry created from payroll results; not yet validated | No |
| STATE-GL-002 | Validated | Debits equal credits; all account codes mapped; ready for posting | No |
| STATE-GL-003 | Posted | Journal entry accepted by the accounting system | Yes |
| STATE-GL-004 | Failed | Journal entry rejected by validation or accounting system | No |
| STATE-GL-005 | Reposted | Corrected journal entry posted after a prior failure | Yes |

**Terminal states:** STATE-GL-003 (Posted), STATE-GL-005 (Reposted).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-GL-001 | STATE-GL-002 | Validation passes | Total debits = total credits; all account codes valid |
| STATE-GL-001 | STATE-GL-004 | Validation fails | Imbalance detected or unmapped account code |
| STATE-GL-002 | STATE-GL-003 | Accounting system accepts posting | Accounting system confirms receipt |
| STATE-GL-002 | STATE-GL-004 | Accounting system rejects | System-side rejection; error code returned |
| STATE-GL-004 | STATE-GL-001 | Correction applied and resubmitted for validation | Root cause resolved; corrected journal entry generated |
| STATE-GL-003 | STATE-GL-005 | Correcting entry posted (rare) | Accounting error identified post-posting; correcting entry approved |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-GL-003 | STATE-GL-001 | Posted entries are immutable; corrections generate new journal entries |
| STATE-GL-003 | STATE-GL-004 | Cannot fail after successful posting |
| STATE-GL-005 | Any | Reposted is terminal |
| STATE-GL-001 | STATE-GL-003 | Cannot post without validation |
