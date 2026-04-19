# STATE-TAX — Tax Elections / Jurisdiction Assignment States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Compliance Domain |
| **Location** | `docs/STATE/STATE-TAX_Tax_Elections.md` |
| **Applies To** | Employee tax withholding elections and jurisdiction assignments |
| **Related Documents** | docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md, docs/rules/Tax_Classification_and_Obligation_Model.md |

## Purpose

Defines the lifecycle states for tax withholding elections and jurisdiction assignments. Critical for multi-state payroll where state transitions directly affect tax calculation.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-TAX-001 | Pending Verification | Election submitted; awaiting validation (e.g., reciprocity check, SSN verification) | No |
| STATE-TAX-002 | Active | Election verified and applied to payroll calculations | No |
| STATE-TAX-003 | Locked | Election locked due to regulatory constraint (e.g., reciprocity agreement, lock-in letter) | No |
| STATE-TAX-004 | Expired | Election has passed its effective end date | Yes |

**Terminal states:** STATE-TAX-004 (Expired).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-TAX-001 | STATE-TAX-002 | Verification passes | SSN verified; jurisdiction valid; no conflicts detected |
| STATE-TAX-001 | STATE-TAX-001 | Verification fails; resubmission required | Conflict detected; employee notified for correction |
| STATE-TAX-002 | STATE-TAX-001 | Employee submits new election | New W-4 or state equivalent received |
| STATE-TAX-002 | STATE-TAX-003 | Lock-in letter received from IRS or state authority | Official lock-in order received; employee notified |
| STATE-TAX-002 | STATE-TAX-004 | Effective end date reached | System-triggered; new election required |
| STATE-TAX-003 | STATE-TAX-002 | Lock-in period expires or authority releases | Official release received from IRS or state |
| STATE-TAX-003 | STATE-TAX-004 | Locked election expires | Effective end date reached while locked |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-TAX-004 | Any | Expired is terminal; employee must submit a new election |
| STATE-TAX-003 | STATE-TAX-001 | Locked elections cannot be overridden by employee submission |
| STATE-TAX-001 | STATE-TAX-003 | Cannot lock an unverified election |
