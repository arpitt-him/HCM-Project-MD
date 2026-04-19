# STATE-GAR — Garnishment States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Compliance Domain |
| **Location** | `docs/STATE/STATE-GAR_Garnishment.md` |
| **Applies To** | Garnishment and legal order records |
| **Related Documents** | docs/architecture/governance/Garnishment_and_Legal_Order_Model.md |

## Purpose

Defines the lifecycle states for garnishments and legal orders. Garnishments are compliance-critical; state transitions must be auditable and legally defensible.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-GAR-001 | Received | Legal order received; not yet validated or set up | No |
| STATE-GAR-002 | Pending Setup | Order validated; payroll configuration in progress | No |
| STATE-GAR-003 | Active | Withholding active; deductions applied each payroll run | No |
| STATE-GAR-004 | Suspended | Withholding temporarily paused per court order or admin action | No |
| STATE-GAR-005 | Satisfied | Full obligation met; order fulfilled | Yes |
| STATE-GAR-006 | Terminated | Order terminated by issuing authority or court | Yes |

**Terminal states:** STATE-GAR-005 (Satisfied), STATE-GAR-006 (Terminated).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-GAR-001 | STATE-GAR-002 | Payroll admin validates and begins setup | Order verified as legally valid; employee matched |
| STATE-GAR-001 | STATE-GAR-006 | Order found invalid or rescinded on receipt | Legal validation fails; issuing authority confirms rescission |
| STATE-GAR-002 | STATE-GAR-003 | Setup complete; withholding activated | Withholding rule configured; priority established |
| STATE-GAR-003 | STATE-GAR-004 | Suspension order received | Court order or issuing authority instructs suspension |
| STATE-GAR-003 | STATE-GAR-005 | Cumulative withholding meets order total | System calculates satisfaction; final remittance confirmed |
| STATE-GAR-003 | STATE-GAR-006 | Termination notice received from issuing authority | Official termination document received |
| STATE-GAR-004 | STATE-GAR-003 | Suspension lifted | Court order or issuing authority reinstates withholding |
| STATE-GAR-004 | STATE-GAR-006 | Termination notice received while suspended | Official termination document received |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-GAR-005 | Any | Satisfied is terminal |
| STATE-GAR-006 | Any | Terminated is terminal |
| STATE-GAR-001 | STATE-GAR-003 | Cannot activate without completing setup |
| STATE-GAR-002 | STATE-GAR-005 | Cannot satisfy without having been active |
