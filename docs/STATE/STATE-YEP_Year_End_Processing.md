# STATE-YEP — Year-End Processing States

| Field | Detail |
|---|---|
| **Document Type** | State Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Compliance Domain |
| **Location** | `docs/STATE/STATE-YEP_Year_End_Processing.md` |
| **Applies To** | Year-end tax forms (W-2, 1099, etc.) |
| **Related Documents** | docs/architecture/governance/Regulatory_and_Compliance_Reporting_Model.md, docs/architecture/governance/Data_Retention_and_Archival_Model.md |

## Purpose

Defines the lifecycle states for year-end tax forms. Filing deadlines make state transitions here compliance-critical — transitions must be auditable and timestamped.

---

## States

| ID | State | Description | Terminal? |
|---|---|---|---|
| STATE-YEP-001 | Draft | Form generated from payroll data; under review | No |
| STATE-YEP-002 | Corrected | Form revised after initial draft; correction in progress | No |
| STATE-YEP-003 | Final | Form reviewed, approved, and locked for filing | No |
| STATE-YEP-004 | Filed | Form submitted to the relevant authority | Yes |
| STATE-YEP-005 | Reissued | Corrected form issued after original filing (W-2c, etc.) | Yes |

**Terminal states:** STATE-YEP-004 (Filed), STATE-YEP-005 (Reissued).

---

## Transitions

| From | To | Trigger | Guard Condition |
|---|---|---|---|
| STATE-YEP-001 | STATE-YEP-002 | Reviewer identifies error | Error identified in draft form; correction workflow initiated |
| STATE-YEP-001 | STATE-YEP-003 | Reviewer approves draft | All data verified; approval workflow complete |
| STATE-YEP-002 | STATE-YEP-003 | Corrected form reviewed and approved | Correction verified; approval workflow complete |
| STATE-YEP-002 | STATE-YEP-002 | Further corrections required | Additional errors found; iterative correction |
| STATE-YEP-003 | STATE-YEP-004 | Form filed with authority | Electronic or paper submission confirmed; filing deadline met |
| STATE-YEP-003 | STATE-YEP-002 | Error found after finalisation but before filing | Correction required; form reverted for amendment |
| STATE-YEP-004 | STATE-YEP-005 | Error discovered after filing | Corrected form (e.g., W-2c) generated and filed |

---

## Invalid Transitions

| From | To | Reason |
|---|---|---|
| STATE-YEP-004 | STATE-YEP-001 | Filed forms cannot revert to draft; a reissue (W-2c) must be filed |
| STATE-YEP-004 | STATE-YEP-003 | Cannot revert a filed form to final |
| STATE-YEP-005 | Any | Reissued is terminal; further corrections require another reissue cycle |
| STATE-YEP-001 | STATE-YEP-004 | Cannot file without finalisation |
