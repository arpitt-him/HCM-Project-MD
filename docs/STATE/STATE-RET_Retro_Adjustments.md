# STATE-RET — Retro / Adjustment States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Payroll Domain |
| **Location** | `docs/STATE/STATE-RET_Retro_Adjustments.md` |
| **Applies To** | Retroactive pay adjustments and correction transactions |
| **Related Documents** | docs/architecture/governance/Correction_and_Immutability_Model.md, docs/rules/Posting_Rules_and_Mutation_Semantics.md |

## Purpose

Defines the lifecycle states for retroactive pay adjustments. Retro states are critical for auditability — each state must be traceable to the correction that created it.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-RET-001 | Identified | Retro need identified; not yet calculated | No |
| STATE-RET-002 | Calculated | Retro amounts computed; awaiting review | No |
| STATE-RET-003 | Applied | Retro adjustment included in a payroll run and posted | Yes |
| STATE-RET-004 | Reversed | Previously applied retro has been reversed | Yes |
| STATE-RET-005 | Finalized | Retro fully resolved; no further action required | Yes |

**Terminal states:** STATE-RET-003 (Applied), STATE-RET-004 (Reversed), STATE-RET-005 (Finalized).

Note: STATE-RET-003 (Applied) becomes terminal once posted. If a correction is needed to an applied retro, a new retro record is created; the original is not modified.

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-RET-001 | STATE-RET-002 | Retro calculation triggered | Source event identified; affected periods determined |
| STATE-RET-002 | STATE-RET-001 | Calculation result rejected; recalculation required | Reviewer identifies error; recalculation initiated |
| STATE-RET-002 | STATE-RET-003 | Retro approved and included in payroll run | Approval workflow complete; payroll run committed |
| STATE-RET-002 | STATE-RET-005 | Retro determined to be zero-impact after calculation | Net delta is zero; no payment required; documented |
| STATE-RET-003 | STATE-RET-004 | Applied retro reversed due to error | Post-pay correction workflow approved; reversing entry generated |
| STATE-RET-004 | STATE-RET-005 | Reversal confirmed and closed | Reversing entry posted; no further action required |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-RET-003 | STATE-RET-002 | Applied retros cannot be recalled; a new correction record must be created |
| STATE-RET-003 | STATE-RET-001 | Applied retros cannot revert to identified |
| STATE-RET-004 | STATE-RET-003 | A reversed retro cannot be re-applied; a new retro record is required |
| STATE-RET-005 | Any | Finalized is terminal |
| STATE-RET-001 | STATE-RET-003 | Cannot apply without calculation and approval |
