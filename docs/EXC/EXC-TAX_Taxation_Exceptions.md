# EXC-TAX — Taxation Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v1.0 |
| **Status** | Draft |
| **Owner** | Compliance Domain |
| **Location** | `docs/EXC/EXC-TAX_Taxation_Exceptions.md` |
| **Related Documents** | docs/rules/Tax_Classification_and_Obligation_Model.md, docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md, docs/STATE/STATE-TAX_Tax_Elections.md |

## Purpose

Defines exceptions arising from taxation — invalid withholding elections, missing jurisdiction assignments, reciprocity conflicts, and tax engine failures. Tax exceptions are treated as their own class due to their regulatory and financial significance.

---

### EXC-TAX-001

| Field | Detail |
|---|---|
| **Code** | EXC-TAX-001 |
| **Name** | Invalid Withholding Election |
| **Severity** | Hold |
| **Domain** | Tax Elections |

**Condition:** An employee's tax withholding election (W-4 or state equivalent) contains invalid or inconsistent values. Examples: Filing status not valid for the jurisdiction; additional withholding amount is negative; exempt claim on a form that prohibits it for this employee's situation.

**System Behaviour:** Tax election held in STATE-TAX-001 (Pending Verification). Payroll run proceeds using the prior valid election if one exists; if no prior election exists, default withholding rules apply and a warning is generated.

**Operator Action Required:** Notify the employee to resubmit a corrected withholding form. Document the interim treatment applied.

**Related Codes:** EXC-TAX-002, EXC-VAL-010

---

### EXC-TAX-002

| Field | Detail |
|---|---|
| **Code** | EXC-TAX-002 |
| **Name** | Missing Jurisdiction Assignment |
| **Severity** | Hard Stop |
| **Domain** | Jurisdiction Resolution |

**Condition:** The system cannot determine the applicable tax jurisdiction(s) for an employee because no work location or residency jurisdiction is assigned to the employment record.

**System Behaviour:** Tax calculation halted for the affected employee. Routed to exception queue. Run continues for unaffected employees.

**Operator Action Required:** Assign a valid primary work location with a State_Code and Locality_Code to the employment record. Verify residency jurisdiction if the employee works in a different state from their residence.

**Related Codes:** EXC-CFG-001, EXC-VAL-010

---

### EXC-TAX-003

| Field | Detail |
|---|---|
| **Code** | EXC-TAX-003 |
| **Name** | Reciprocity Conflict Detected |
| **Severity** | Hold |
| **Domain** | Multi-State Taxation |

**Condition:** An employee's work location and residence are in states that have a reciprocity agreement, but the employee's withholding election does not reflect the correct reciprocity treatment, or the agreement configuration is incomplete in the system.

**System Behaviour:** Tax calculation held for the affected employee. Conflict details logged identifying the work state, residence state, and applicable reciprocity rule. Routed to exception queue.

**Operator Action Required:** Review the reciprocity configuration for the involved states. Ensure the correct exemption form has been submitted by the employee and that the system reciprocity rules are properly configured.

**Related Codes:** EXC-TAX-001, EXC-CFG-003

---

### EXC-TAX-004

| Field | Detail |
|---|---|
| **Code** | EXC-TAX-004 |
| **Name** | Tax Engine Calculation Failure |
| **Severity** | Hard Stop |
| **Domain** | Tax Computation |

**Condition:** The tax calculation engine returned an error or produced no output for a required tax component. Causes include: missing rate tables, corrupted rule data, unsupported jurisdiction configuration, or engine runtime error.

**System Behaviour:** Tax calculation halted for the affected employee. Error details and context snapshot logged. Routed to exception queue. Run continues for unaffected employees.

**Operator Action Required:** Identify the root cause from the error log. If a rate table or rule is missing, create and approve it. If the failure is a runtime error, escalate to platform engineering.

**Related Codes:** EXC-CAL-001, EXC-CFG-001

---

### EXC-TAX-005

| Field | Detail |
|---|---|
| **Code** | EXC-TAX-005 |
| **Name** | Wage Base Limit Exceeded Without Stop |
| **Severity** | Warning |
| **Domain** | Wage Base Management |

**Condition:** The system has calculated tax on wages that appear to exceed the annual wage base limit for a wage-base-limited tax (e.g., Social Security, FUTA, SUI). This may indicate an accumulator tracking error.

**System Behaviour:** Warning logged. Calculation result flagged for review. Processing continues. Accumulator state cross-check triggered.

**Operator Action Required:** Verify the YTD accumulator for the affected tax against the employee's actual year-to-date wages. If a tracking error is confirmed, initiate a correction run.

**Related Codes:** EXC-CAL-005, EXC-VAL-004

---

### EXC-TAX-006

| Field | Detail |
|---|---|
| **Code** | EXC-TAX-006 |
| **Name** | Lock-In Letter Applied — Employee Override Blocked |
| **Severity** | Informational |
| **Domain** | Tax Elections |

**Condition:** An employee has submitted a new withholding election but a lock-in letter from the IRS or a state authority is on file, preventing the employee from reducing their withholding below the locked amount.

**System Behaviour:** New election is not applied. Employee's withholding remains at the locked rate. Informational record created. Employee notified.

**Operator Action Required:** No payroll action required. Inform the employee that their withholding is locked per the authority's instruction. Changes can only be made upon receipt of a formal release from the issuing authority.

**Related Codes:** EXC-TAX-001
