# PRD-500 — Accumulator Strategy

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Accumulator Strategy |
| **Version** | v1.0 |
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

| Scope | Description |
|---|---|
| Employee | Totals for an individual employee |
| Employer | Totals for the employing organization |
| Employer + Jurisdiction | Employer totals scoped to a specific jurisdiction |
| Client + Jurisdiction | PEO client totals scoped to a specific jurisdiction |

## 2. Accumulator Periods

Accumulators shall support the following period granularities:

| Period | Abbreviation |
|---|---|
| Period-to-date | PTD |
| Quarter-to-date | QTD |
| Year-to-date | YTD |
| Life-to-date | LTD |

Remittance-to-date totals shall also be maintained as a distinct accumulator type.

## 3. Accumulator Integrity Requirements

- Accumulators shall be updated atomically with the posting of payroll results.
- Accumulator state shall be reproducible from historical postings (replayability).
- Cross-scope reconciliation shall be supported to detect discrepancies between scope levels.
- Accumulator values shall never be overwritten — corrections generate compensating entries.

## 4. Architecture Model Reference

Detailed accumulator entity definitions, rollup behavior, reconciliation relationships, and consumer-group structures are specified in:

- `docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md`
- `docs/accumulators/Accumulator_Model_Detailed.md`
