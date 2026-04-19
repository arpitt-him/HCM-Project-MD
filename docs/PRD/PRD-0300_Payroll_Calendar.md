# PRD-300 — Payroll Calendar Model

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Payroll Calendar |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Payroll Domain |
| **Location** | `docs/PRD/PRD-0300_Payroll_Calendar.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §5 |
| **Related Documents** | PRD-0200_Core_Entity_Model, docs/architecture/payroll/Payroll_Calendar_Model.md, docs/architecture/payroll/Multi_Context_Calendar_Model.md, docs/architecture/payroll/Holiday_and_Special_Calendar_Model.md |

## Purpose

Defines the requirements for payroll calendar structures, period definitions, and the date-based controls that govern when payroll inputs, calculations, corrections, and transmissions are permitted.

---

## 1. Supported Pay Frequencies

| Frequency | Description |
|---|---|
| Weekly | 52 periods per year |
| Biweekly | 26 periods per year |
| Semi-monthly | 24 periods per year |
| Monthly | 12 periods per year |
| Custom | Configurable period boundaries |

Multiple calendars per employer are supported. An employer may run different pay groups on different frequencies simultaneously.

## 2. Period Definition

Each payroll period includes the following date controls:

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

## 3. Calendar Governance

- Calendars must be established before payroll runs can be initiated.
- Future periods shall be pre-generated to support advance planning.
- Calendar changes require approval workflow completion.
- Historical calendar definitions must be preserved for replayability.

## 4. Architecture Model Reference

Detailed calendar structure, multi-context support, and holiday handling are specified in:

- `docs/architecture/payroll/Payroll_Calendar_Model.md`
- `docs/architecture/payroll/Multi_Context_Calendar_Model.md`
- `docs/architecture/payroll/Holiday_and_Special_Calendar_Model.md`
