# Accumulator_Model_Detailed

| Field                 | Detail                                                                                                                                                                                          |
| --------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Document Type**     | Architecture Model                                                                                                                                                                              |
| **Version**           | v0.3                                                                                                                                                                                            |
| **Status**            | Approved                                                                                                                                                                                        |
| **Owner**             | Core Platform                                                                                                                                                                                   |
| **Location**          | `docs/accumulators/Accumulator_Model_Detailed.md`                                                                                                                                               |
| **Domain**            | Accumulators                                                                                                                                                                                    |
| **Related Documents** | PRD-500-Accumulator-Strategy.md, Accumulator_and_Balance_Model, Result_and_Payable_Model, Posting_Rules_and_Mutation_Semantics, Multi_Context_Calendar_Model, Correction_and_Immutability_Model |

## Purpose

Provides the detailed accumulator entity structure, rollup behaviour, reconciliation relationships, consumer-group definitions, and rule versioning integration that extend the high-level model in `Accumulator_and_Balance_Model`. Represents the consolidated detailed design as of v0.3.

---

## 1. Accumulator Core Definition

AccumulatorID, AccumulatorFamily, Scope, PostingDirection, EffectiveStartDate, EffectiveEndDate, Status.

## 2. Rollup Behaviour Model

DERIVED — calculated dynamically from lower-scope accumulators.
INDEPENDENT — posted directly at each scope level.
HYBRID — combination of derived rollups and independent postings.

## 3. Reconciliation Relationship Types

EXACT_SUM — higher totals equal sum of lower totals.
SUM_PLUS_ADJUSTMENTS — includes authorised adjustments.
INFORMATIONAL_ROLLUP — reporting rollups without strict reconciliation.
NO_DIRECT_RELATIONSHIP — independent totals.

## 4. Consumer-Oriented Rollups

Payroll Operations, Management Accounting, Corporate Accounting, External Reporting, Carrier Reconciliation. Each consumer group may require distinct rollup views of the same underlying accumulator data.

## 5. Cross-Scope Validation

CrossScopeValidationEnabled (Boolean), ValidationFrequency, ExceptionHandlingRule. Cross-scope validation detects discrepancies between scope levels and routes exceptions for investigation.

## 6. Rule Versioning Integration

RuleVersionID, EffectiveDateRange, EvaluationBasis, ReplayCompatibilityRequirement. Accumulator behaviour may vary by rule version — versioning integration ensures replay reproduces the same accumulator state.

## 7. Relationship to Accumulator_Definition_Model.md

Accumulator_Model_Detailed stores the runtime values of accumulators defined by Accumulator_Definition_Model.md.

Each stored accumulator value must reference a governed Accumulator_Definition to ensure semantic consistency, replay capability, and reporting traceability.

Relationship:

Accumulator_Definition
        ↓
Accumulator_Value (this model)

This model represents operational balances.
The Definition model represents meaning.

## 7.1 Relationship to Accumulator_Impact_Model.md

Accumulator_Impact_Model.md defines the governed mutation layer between payroll results and stored accumulator values.

Relationship:

Accumulator_Definition
        ↓
Accumulator_Impact
        ↓
Accumulator_Value (this model)

In this structure:

- `Accumulator_Definition_Model.md` defines accumulator meaning, scope, reset behavior, and reporting semantics.
- `Accumulator_Impact_Model.md` records how payroll results mutate accumulator values, including source lineage, scope context, retroactivity, reversal, and correction handling.
- `Accumulator_Model_Detailed.md` stores operational accumulator values and governs rollup, reconciliation, and value-level runtime behavior.

This model therefore consumes governed accumulator impacts rather than embedding mutation semantics directly inside stored accumulator balances.

Accumulator impacts should remain traceable to:

- the originating payroll result
- the applicable accumulator definition
- the applicable rule/version context
- any retroactive, reversal, or correction lineage

This separation supports:

- deterministic replay
- accumulator auditability
- correction traceability
- cross-scope reconciliation
- reporting defensibility

## 8. Relationship to Other Models

This model integrates with: Accumulator_and_Balance_Model, Accumulator_Impact_Model, Result_and_Payable_Model, Posting_Rules_and_Mutation_Semantics, Multi_Context_Calendar_Model, Correction_and_Immutability_Model, Rule_Versioning_Model.
