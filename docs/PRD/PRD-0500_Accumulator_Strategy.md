# PRD-500 — Accumulator Strategy

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Accumulator Strategy |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0500_Accumulator_Strategy.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §7 |
| **Related Documents** | PRD-0200_Core_Entity_Model, docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md, docs/accumulators/Accumulator_Model_Detailed.md |

## Purpose

Defines the requirements for accumulator structures that track running totals required for tax compliance, benefit thresholds, and operational reporting.

---

## 1. Accumulator Scopes

Accumulators shall be maintained at the following scopes:

**REQ-BAL-001**
The platform shall maintain accumulators at the employee scope.

**REQ-BAL-002**
The platform shall maintain accumulators at the employer scope.

**REQ-BAL-003**
The platform shall maintain accumulators at the employer + jurisdiction scope.

**REQ-BAL-004**
The platform shall maintain accumulators at the client + jurisdiction scope to support PEO operating environments.

| Scope | Description |
|---|---|
| Employee | Totals for an individual employee |
| Employer | Totals for the employing organisation |
| Employer + Jurisdiction | Employer totals scoped to a specific jurisdiction |
| Client + Jurisdiction | PEO client totals scoped to a specific jurisdiction |

## 2. Accumulator Periods

**REQ-BAL-010**
Accumulators shall support period-to-date (PTD) granularity.

**REQ-BAL-011**
Accumulators shall support quarter-to-date (QTD) granularity.

**REQ-BAL-012**
Accumulators shall support year-to-date (YTD) granularity.

**REQ-BAL-013**
Accumulators shall support life-to-date (LTD) granularity.

**REQ-BAL-014**
Remittance-to-date totals shall be maintained as a distinct accumulator type.

## 3. Accumulator Integrity Requirements

**REQ-BAL-020**
Accumulator updates shall be atomic with the posting of payroll results. Partial accumulator updates are not permitted.

**REQ-BAL-021**
Accumulator state shall be fully reproducible from historical postings in support of deterministic replayability.

**REQ-BAL-022**
Cross-scope reconciliation shall be supported to detect discrepancies between accumulator scope levels.

**REQ-BAL-023**
Accumulator values shall never be overwritten. Corrections shall generate compensating contribution entries.

## 4. Architecture Model Reference

Detailed accumulator entity definitions, rollup behaviour, reconciliation relationships, and consumer-group structures are specified in:

- `docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md`
- `docs/accumulators/Accumulator_Model_Detailed.md`

---

## 5. User Stories

**Payroll Engineer** needs to **rely on accumulators as the authoritative source of YTD totals** in order to **correctly apply wage base limits, generate pay statement YTD values, and produce compliant year-end tax forms.**

**Compliance Auditor** needs to **reconstruct accumulator balances as of any historical date** in order to **verify that wage base limits were correctly applied and that tax obligations were correctly calculated.**

**Payroll Administrator** needs to **cross-validate accumulator totals across employee and employer scopes** in order to **detect discrepancies before they reach year-end reporting.**

---

## 6. Scope Boundaries

### In Scope — v1

**REQ-BAL-030**
All four accumulator scopes (employee, employer, employer+jurisdiction, client+jurisdiction) shall be supported in v1.

**REQ-BAL-031**
All four period granularities (PTD, QTD, YTD, LTD) shall be supported in v1. Plan-year and custom period windows are optional in v1.

**REQ-BAL-032**
Accumulator reset logic aligned to the tax calendar year shall be implemented in v1.

### Out of Scope — v1

**REQ-BAL-033**
Custom accumulator families beyond those defined in Entity_Accumulator.md are out of scope for v1 configuration UI. Custom families may be added via platform engineering.

**REQ-BAL-034**
Multi-country accumulator structures (non-U.S. wage bases, non-Gregorian tax years) are out of scope for v1.

---

## 7. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-BAL-001 | An employee's YTD gross wages accumulator equals the sum of all gross earnings posted across all payroll runs in the tax year. |
| REQ-BAL-002 | An employer's YTD FICA employer contribution accumulator equals the sum of all employer FICA contributions posted across all runs in the tax year. |
| REQ-BAL-003 | An employer+jurisdiction accumulator correctly isolates totals by state — Georgia employer SUI is separate from Florida employer SUI for the same employer. |
| REQ-BAL-010 | A PTD accumulator resets to zero at the start of each new payroll period. The prior period's value remains in contribution history. |
| REQ-BAL-011 | A QTD accumulator resets to zero at the start of each new calendar quarter. |
| REQ-BAL-012 | A YTD accumulator resets to zero at the start of each new tax year. |
| REQ-BAL-013 | An LTD accumulator never resets and correctly reflects the sum of all contributions since the employee's first payroll run. |
| REQ-BAL-020 | A payroll run that fails mid-calculation leaves no partial accumulator updates. The accumulator state is identical before and after the failed run. |
| REQ-BAL-021 | The accumulator state for any employee can be fully reconstructed from contribution history alone, producing values identical to the stored balance. |
| REQ-BAL-022 | A cross-scope validation detects a $0.01 discrepancy between employee-level and employer-level gross wage totals and generates the appropriate exception. |
| REQ-BAL-023 | A correction to a prior payroll period generates reversal contribution records. The net accumulator value reflects the correction. The original contributions remain in history. |

---

## 8. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.


**REQ-BAL-040**
An accumulator balance lookup for a single employee (current YTD values across all families) shall return within 500 milliseconds.

**REQ-BAL-041**
Accumulator updates for a payroll run of 25,000 employees shall complete within the payroll calculation SLA defined in `docs/NFR/HCM_NFR_Specification.md`.

**REQ-BAL-042**
A full accumulator reconstruction from contribution history for a single employee across a full tax year shall complete within 10 seconds.
