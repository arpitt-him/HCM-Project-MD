# STATE-DED — Benefits / Deductions / Enrollment States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/STATE/STATE-DED_Benefits_Deductions.md` |
| **Applies To** | Benefit plan enrollments and deduction elections |
| **Related Documents** | docs/architecture/core/Eligibility_and_Enrollment_Lifecycle_Model.md, docs/architecture/core/Benefit_and_Deduction_Configuration_Model.md |

## Purpose

Defines the lifecycle states for benefit plan enrollments and deduction elections, from initial enrollment eligibility through termination.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-DED-001 | Pending Enrollment | Employee is eligible; enrollment not yet completed | No |
| STATE-DED-002 | Awaiting Evidence of Insurability | Enrollment initiated; pending medical underwriting approval | No |
| STATE-DED-003 | Active | Enrollment complete; deductions active in payroll | No |
| STATE-DED-004 | Suspended | Deductions temporarily paused (e.g., unpaid leave) | No |
| STATE-DED-005 | Terminated | Enrollment ended; deductions stopped | Yes |

**Terminal states:** STATE-DED-005 (Terminated).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-DED-001 | STATE-DED-002 | Employee selects coverage requiring EOI | Plan requires Evidence of Insurability; election submitted |
| STATE-DED-001 | STATE-DED-003 | Employee completes enrollment | Enrollment window open; election submitted and approved |
| STATE-DED-001 | STATE-DED-005 | Enrollment window closes without election | Waiver recorded or auto-waived per plan rules |
| STATE-DED-002 | STATE-DED-003 | EOI approved by carrier | Carrier approval received; coverage effective date set |
| STATE-DED-002 | STATE-DED-005 | EOI denied by carrier | Carrier denial received |
| STATE-DED-003 | STATE-DED-004 | Leave of absence begins (unpaid) | Employment moves to STATE-EMP-012; plan suspends deductions |
| STATE-DED-003 | STATE-DED-005 | Qualifying termination event | Employment terminated, coverage period ends, or voluntary cancellation |
| STATE-DED-004 | STATE-DED-003 | Return from leave | Employment moves to STATE-EMP-011; deductions resume |
| STATE-DED-004 | STATE-DED-005 | Employment terminated while on leave | Termination event processed |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-DED-005 | Any | Terminated is terminal; re-enrollment creates a new enrollment record |
| STATE-DED-003 | STATE-DED-001 | Cannot revert to pending once active |
| STATE-DED-003 | STATE-DED-002 | EOI is an entry-path state only |
