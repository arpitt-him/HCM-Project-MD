# PRD-300 — Payroll Calendar Model

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Payroll Calendar |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Payroll Domain |
| **Location** | `docs/PRD/PRD-0300_Payroll_Calendar.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §5 |
| **Related Documents** | PRD-0200_Core_Entity_Model, docs/architecture/payroll/Payroll_Calendar_Model.md, docs/architecture/payroll/Multi_Context_Calendar_Model.md, docs/architecture/payroll/Holiday_and_Special_Calendar_Model.md |

## Purpose

Defines the requirements for payroll calendar structures, period definitions, and the date-based controls that govern when payroll inputs, calculations, corrections, and transmissions are permitted.

---

## 1. Supported Pay Frequencies

**REQ-CAL-001**
The platform shall support weekly pay periods (52 periods per year).

**REQ-CAL-002**
The platform shall support biweekly pay periods (26 periods per year).

**REQ-CAL-003**
The platform shall support semi-monthly pay periods (24 periods per year).

**REQ-CAL-004**
The platform shall support monthly pay periods (12 periods per year).

**REQ-CAL-005**
The platform shall support custom pay periods with configurable period boundaries.

**REQ-CAL-006**
Multiple payroll calendars per employer shall be supported. An employer may run different pay groups on different frequencies simultaneously.

## 2. Period Definition

Each payroll period shall include the following date controls:

| Field | Purpose |
|---|---|
| Period Start | First day of the earning period |
| Period End | Last day of the earning period |
| Pay Date | Date employees receive payment |
| Input Cutoff | Deadline for submitting payroll inputs |
| Calculation Date | Date payroll calculation is executed |
| Validation Window | Period during which results may be reviewed |
| Correction Window | Period during which corrections are permitted |
| Finalization Date | Date the period is closed for ordinary processing |
| Transmission Date | Date results are transmitted to downstream systems |

**REQ-CAL-007**
Every payroll period shall define all date controls listed above.

**REQ-CAL-008**
The system shall enforce input cutoff dates — payroll inputs submitted after the cutoff shall not be included in the current period's run without explicit override authorisation.

**REQ-CAL-009**
The Pay Date associated with a payroll calendar entry shall remain unchanged even if a run fails and is reprocessed after the original Pay Date.

## 3. Calendar Governance

**REQ-CAL-010**
Payroll calendars shall be established before payroll runs can be initiated for the relevant period.

**REQ-CAL-011**
Future periods shall be pre-generated to support advance planning and input submission.

**REQ-CAL-012**
Calendar changes shall require approval workflow completion before taking effect.

**REQ-CAL-013**
Historical calendar definitions shall be preserved permanently to support deterministic replayability.

## 4. Architecture Model Reference

Detailed calendar structure, multi-context support, and holiday handling are specified in:

- `docs/architecture/payroll/Payroll_Calendar_Model.md`
- `docs/architecture/payroll/Multi_Context_Calendar_Model.md`
- `docs/architecture/payroll/Holiday_and_Special_Calendar_Model.md`

---

## 5. User Stories

**Payroll Administrator** needs to **configure and generate payroll calendars in advance** in order to **ensure that all processing deadlines, cutoff dates, and pay dates are defined before a run is initiated.**

**Payroll Administrator** needs to **enforce input cutoff dates** in order to **prevent late submissions from entering a run that is already in progress.**

**Payroll Engineer** needs to **rely on the calendar entry's Pay_Date as the authoritative date for tax calculations** in order to **ensure that a reprocessed run after the original pay date still applies the correct tax rules.**

**Compliance Auditor** needs to **reconstruct the payroll calendar as it existed for any historical period** in order to **verify that processing deadlines were met and that the correct Pay_Date governed each run.**

---

## 6. Scope Boundaries

### In Scope — v1

**REQ-CAL-014**
All five pay frequencies (weekly, biweekly, semi-monthly, monthly, custom) shall be supported in v1.

**REQ-CAL-015**
All nine period date controls defined in §2 shall be enforced in v1.

**REQ-CAL-016**
Multiple concurrent payroll calendars per employer (different pay groups on different frequencies) shall be supported in v1.

### Out of Scope — v1

**REQ-CAL-017**
Automated calendar generation based on business rules or holiday calendars is out of scope for v1. Calendar periods shall be created manually or via batch import.

**REQ-CAL-018**
Non-U.S. payroll calendar structures (e.g., 13-period fiscal calendars, non-Gregorian calendar systems) are out of scope for v1.

---

## 7. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-CAL-001 | A payroll run can be created and completed for a weekly period (52 periods per year) with correct Pay_Date and period boundaries. |
| REQ-CAL-002 | A payroll run can be created and completed for a biweekly period (26 periods per year). |
| REQ-CAL-003 | A payroll run can be created and completed for a semi-monthly period (24 periods per year). |
| REQ-CAL-004 | A payroll run can be created and completed for a monthly period (12 periods per year). |
| REQ-CAL-005 | A custom period with administrator-defined boundaries can be created and a payroll run completed within it. |
| REQ-CAL-006 | Two payroll groups with different frequencies (e.g., weekly and biweekly) can run simultaneously on the same employer without interference. |
| REQ-CAL-007 | A payroll run cannot be initiated for a period that has no calendar entry. The system returns EXC-CFG-005. |
| REQ-CAL-008 | A payroll input submitted after the Input_Cutoff date is rejected from the current run and generates the appropriate warning. |
| REQ-CAL-009 | A payroll run that fails on Pay_Date and is reprocessed on a subsequent date continues to use the original Pay_Date for all tax calculations. |
| REQ-CAL-010 | A calendar entry cannot be created for a period that already has a closed (STATE-RUN-017) run without admin-level override. |
| REQ-CAL-011 | A calendar change (e.g., revised cutoff date) requires workflow approval before taking effect. |
| REQ-CAL-012 | Historical calendar entries remain queryable and unchanged after the period is closed. |
| REQ-CAL-013 | Future periods can be pre-generated up to 12 months in advance for any pay frequency. |

---

## 8. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.


**REQ-CAL-020**
Calendar period generation for 12 months of weekly periods (52 entries) shall complete within 5 seconds.

**REQ-CAL-021**
A calendar lookup (resolving Pay_Date and deadlines for a given Payroll_Context_ID and Period_ID) shall return within 500 milliseconds.
