# Accumulator_Model_Detailed

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.3 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/accumulators/Accumulator_Model_Detailed.md` |
| **Domain** | Accumulators |
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

## 7. Relationship to Other Models

This model integrates with: Accumulator_and_Balance_Model, Result_and_Payable_Model, Posting_Rules_and_Mutation_Semantics, Multi_Context_Calendar_Model, Correction_and_Immutability_Model, Rule_Versioning_Model.
