# EXC-DED — Benefits / Deductions Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v1.0 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/EXC/EXC-DED_Benefits_Deductions_Exceptions.md` |
| **Related Documents** | docs/architecture/core/Benefit_and_Deduction_Configuration_Model.md, docs/architecture/core/Eligibility_and_Enrollment_Lifecycle_Model.md, docs/STATE/STATE-DED_Benefits_Deductions.md |

## Purpose

Defines exceptions arising from benefit enrollments and deduction processing. These are distinct from configuration errors (EXC-CFG) and calculation errors (EXC-CAL).

---

### EXC-DED-001

| Field | Detail |
|---|---|
| **Code** | EXC-DED-001 |
| **Name** | Invalid Deduction Amount |
| **Severity** | Hard Stop |
| **Domain** | Deduction Validation |

**Condition:** A deduction amount is outside the permitted range for the deduction type. Examples: negative deduction where only positive is permitted; amount exceeds the maximum configured for the plan; amount is zero where zero is not permitted.

**System Behaviour:** Deduction rejected. Employee routed to exception queue. Run continues for unaffected employees.

**Operator Action Required:** Review the deduction configuration for the plan. Correct the amount or fix the plan configuration and reprocess the employee.

**Related Codes:** EXC-CAL-004, EXC-CFG-001

---

### EXC-DED-002

| Field | Detail |
|---|---|
| **Code** | EXC-DED-002 |
| **Name** | Missing Benefit Enrollment |
| **Severity** | Warning |
| **Domain** | Enrollment Completeness |

**Condition:** An employee who is benefit-eligible has no active enrollment record for a benefit plan that is configured as requiring enrollment for this employee population.

**System Behaviour:** Warning logged. No deduction generated for the missing enrollment. Flagged on HR operations dashboard.

**Operator Action Required:** Investigate whether the employee waived coverage (waiver should be on file), is in the enrollment window, or has a data entry gap. Resolve the enrollment status.

**Related Codes:** EXC-VAL-010

---

### EXC-DED-003

| Field | Detail |
|---|---|
| **Code** | EXC-DED-003 |
| **Name** | Pre-Tax / Post-Tax Classification Conflict |
| **Severity** | Hard Stop |
| **Domain** | Tax Treatment |

**Condition:** A deduction has been configured with conflicting pre-tax and post-tax flags, or a deduction's tax treatment conflicts with the plan's canonical tax classification in the Code_Classification_and_Mapping_Model.

**System Behaviour:** Deduction calculation halted for the affected employee. Routed to exception queue. Tax treatment cannot be determined.

**Operator Action Required:** Review the deduction configuration and the code mapping. Resolve the classification conflict before reprocessing.

**Related Codes:** EXC-CFG-002, EXC-TAX-004

---

### EXC-DED-004

| Field | Detail |
|---|---|
| **Code** | EXC-DED-004 |
| **Name** | Garnishment Priority Violation |
| **Severity** | Hard Stop |
| **Domain** | Garnishment Sequencing |

**Condition:** Multiple garnishments are active for the same employee and their combined withholding would exceed the maximum permissible withholding under applicable disposable earnings rules. The priority sequencing cannot be satisfied within legal limits.

**System Behaviour:** Garnishment calculation halted for the affected employee. Priority conflict details logged. Routed to exception queue.

**Operator Action Required:** Review all active garnishment orders for the employee. Apply the correct legal priority rules for the jurisdiction. Adjust withholding amounts in accordance with the priority sequence and applicable maximums.

**Related Codes:** EXC-VAL-002, EXC-CFG-001

---

### EXC-DED-005

| Field | Detail |
|---|---|
| **Code** | EXC-DED-005 |
| **Name** | Deduction Active for Terminated Employee |
| **Severity** | Warning |
| **Domain** | Enrollment Lifecycle |

**Condition:** A deduction remains in STATE-DED-003 (Active) for an employee whose Employment is in STATE-EMP-014 (Terminated) or STATE-EMP-015 (Closed).

**System Behaviour:** Warning logged. Deduction flagged on HR operations dashboard. Deduction not applied to final paycheck unless explicitly included in the termination calculation.

**Operator Action Required:** Confirm whether the deduction should be included in the final paycheck. Terminate the enrollment record if the deduction is no longer applicable.

**Related Codes:** EXC-VAL-012
