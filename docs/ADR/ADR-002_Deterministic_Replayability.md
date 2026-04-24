# ADR-002 — Deterministic Replayability

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.2 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-002_Deterministic_Replayability.md` |
| **Date** | April 2026 |
| **Related Documents** | PRD-0100_Architecture_Principles, docs/rules/Rule_Resolution_Engine.md, docs/rules/Posting_Rules_and_Mutation_Semantics.md, docs/architecture/governance/Correction_and_Immutability_Model.md, docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md |

---

## Context

Payroll is a high-stakes financial and legal process. Employers, employees, regulators, and auditors all have legitimate needs to understand *why* a particular payroll result was produced, and to verify that historical results can be reproduced exactly.

Specific scenarios that require reliable reproduction of historical results include:

- **Audits and regulatory inquiries:** A tax authority may ask why a specific withholding amount was produced for a specific employee in a specific period, months or years after the fact.
- **Employee disputes:** An employee may contest a paycheck. The system must be able to reproduce the exact calculation that produced it.
- **Corrections:** When a correction is needed, the system must understand the original state before it can produce a correct replacement.
- **System migrations and upgrades:** After a system change, the platform must be able to verify that historical results are unchanged.
- **Rule Impact Simulation (RIS):** Before deploying a new tax rule or configuration change, the platform should be able to simulate its effect on historical payroll data and compare the outcome to what was actually produced.

Without a formal commitment to replayability, these scenarios either become operationally painful or impossible to satisfy reliably.

---

## Decision

**Historical payroll results shall be deterministically reproducible using historical inputs and rules.**

Given the same inputs, the same rule versions, and the same effective dates that were in effect at the time of original calculation, the system must produce the same result — identically and without exception.

### What Replayability Requires

**Immutable historical records.** Payroll postings, accumulator mutations, and result lines shall never be overwritten. Corrections generate compensating records; they do not modify originals. This is governed by the `Correction_and_Immutability_Model`.

**Effective-dated rules and configuration.** Every rule, tax rate, plan definition, and configuration object must carry an effective date range. The system must be able to reconstruct which version of every rule was active at any historical point in time. This is governed by the `Rule_Versioning_Model` and `Rule_Resolution_Engine`.

**Stable context snapshots.** Payroll runs must capture a snapshot of the context inputs used: employee state, assignment, compensation, jurisdiction, calendar period, and configuration references. These snapshots must be retained indefinitely and must not be retroactively modified.

**Deterministic rule resolution.** The rule resolution engine must produce the same winner given the same resolution context. Precedence logic (specificity-first, then priority) must be deterministic and traceable. See `Rule_Resolution_Engine`.

**Replay as controlled regeneration.** Replay is not merely re-running a calculation. It is a controlled regeneration of financial state driven by source events, posting rules, and mutation semantics. Replay must produce an auditable trace explaining every result. See `Posting_Rules_and_Mutation_Semantics`.

**Resolution traces.** Every rule resolution decision must be retained. The system must be able to explain: which rules were candidates, why each non-winner was eliminated, which rule won, and on what basis.

### What Replayability Does Not Require

Replayability does not require the system to reproduce *incorrect* results from historical bugs. When a defect in calculation logic is corrected, retroactive corrections are the appropriate response — not preserving the wrong answer.

---

## Consequences

### Positive

- Audit and regulatory inquiries can be answered with precision.
- Employee disputes can be resolved by reproducing the exact calculation in question.
- Corrections can be made with confidence because the original state is always known.
- Rule Impact Simulation becomes feasible — candidate rules can be evaluated against historical data.
- System upgrades can be validated by comparing replay results to original production results.

### Negative / Tradeoffs

- Effective-dated data adds complexity to every data model and query. All lookups that could be affected by time must resolve as of a specific date.
- Immutability means storage grows without bound for active tenants. Archival and retention policies are required (see `Data_Retention_and_Archival_Model`).
- Caching strategies must be proven not to compromise determinism. A cache that serves a stale rule version will silently corrupt replayability.
- Performance optimizations (parallelism, batching) must be designed and verified to preserve result correctness — determinism wins over performance when they conflict.

---

## Alternatives Considered

**Mutable records with change logging.** Rejected. Logging changes is insufficient — the system must be able to reconstruct exact historical state, not just know that it changed. Change logs lose the ability to distinguish what the state *was* from what it *became*.

**Best-effort reproduction ("close enough").** Rejected. Payroll results are financial and legal records. Approximate reproduction creates legal and audit exposure. Determinism is a correctness requirement, not a quality target.

**Replay only within a limited window.** Rejected. Regulatory retention requirements extend to 7–10 years. Replayability must match retention scope.

---

## Compliance

All architecture models that involve calculation, rule evaluation, posting, accumulator mutation, or configuration management must document how they support deterministic replayability. Any design decision that trades off replayability for performance or simplicity requires explicit documentation and sign-off.
