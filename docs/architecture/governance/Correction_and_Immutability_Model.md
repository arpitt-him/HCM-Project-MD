# Correction_and_Immutability_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Compliance Domain |
| **Location** | `docs/architecture/governance/Correction_and_Immutability_Model.md` |
| **Domain** | Governance |
| **Related Documents** | ADR-002-Deterministic-Replayability.md, Posting_Rules_and_Mutation_Semantics, Release_and_Approval_Model, Accumulator_and_Balance_Model, Result_and_Payable_Model |

## Purpose

Defines the rules governing correction behaviour, data immutability, and lifecycle locking across payroll calculation, accumulator, result, and export processes. Ensures that once payroll data reaches certain lifecycle states it cannot be silently altered, and that all corrections remain auditable.

---

## 1. Core Design Principles

Data shall remain editable only while in pre-release states. Released payroll data shall never be silently overwritten. Corrections shall create traceable adjustment activity. Historical states shall remain reconstructable. All corrections shall preserve audit lineage.

## 2. Immutability Lifecycle States

Draft → fully editable. Calculated → editable through recalculation. Approved → limited correction permitted. Released → locked against direct modification. Exported → fully immutable except through controlled adjustment. Closed → permanently locked.

Immutability applies to: Results, Payables, Accumulators, Export Units, Assignment Resolution Outputs.

Immutability states apply at the following object levels:

- Payroll_Run
- Payroll_Run_Result_Set
- Employee_Payroll_Result
- Accumulator_Impact
- Payable
- Export_Unit

## 3. Pre-Release Correction Behaviour

Allowed: replace calculated results, refresh accumulator balances, rebuild contribution history records, re-evaluate rule execution. Pre-release correction ensures flexibility while maintaining clean result state.

## 4. Post-Release Correction Behaviour

Direct replacement of data shall not be permitted after release. Correction methods: reversal of prior result, posting of corrective adjustment, delta-based recalculation, supplemental payable generation. All post-release corrections must remain traceable and historically visible.

## 5. Accumulator Correction Handling

Supported: reverse prior contributions, apply new corrective contribution entries, preserve balance continuity, maintain before-and-after visibility. Accumulator integrity must remain consistent across all recalculation scenarios.

Accumulator corrections shall be executed through governed Accumulator Impact records.

Accumulator balances shall not be overwritten directly. All changes shall be recorded as lineage-linked accumulator mutations.

## 6. Export Immutability Rules

Export units become immutable once transmission readiness is confirmed. Allowed: cancel export prior to transmission, regenerate with new Export_ID, maintain historical export records. After successful delivery confirmation, corrections shall generate new export activity rather than modifying prior exports.

## 7. Correction Audit Requirements

All corrections must record: original record reference, correction type and method, correction initiator and approver, before and after values, correction timestamp, affected payroll period. Corrections must be permanently visible alongside the original records they correct.

## 8. Relationship to Other Models

This model integrates with: Posting_Rules_and_Mutation_Semantics, Accumulator_and_Balance_Model, Result_and_Payable_Model, Release_and_Approval_Model, Payroll_Run_Model, Data_Retention_and_Archival_Model.

## 9. Lineage and Correction Chain Enforcement

All post-release corrections shall generate new lineage-linked execution artifacts.

Each correction shall reference:

- Parent_Run_ID
- Root_Run_ID
- Correction_Run_ID
- Original_Result_Set_ID
- Corrected_Result_Set_ID

Correction chains shall remain reconstructable across multiple generations of correction activity.

Lineage records shall preserve full ancestry between original calculation and final corrected state.

## 10. Deterministic Replayability Requirements

All correction activity shall preserve deterministic replay capability.

System replay of historical payroll execution shall produce identical results when executed using the same effective data and rule sets.