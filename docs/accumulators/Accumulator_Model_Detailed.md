# Accumulator Model --- Detailed Draft v0.3

This document represents the consolidated Accumulator Model --- Detailed
Draft v0.3. It integrates prior structures with reconciliation, rollup,
consumer-group, and cross-scope validation enhancements.

## 1. Accumulator Core Definition

- AccumulatorID

- AccumulatorFamily

- Scope

- PostingDirection

- EffectiveStartDate

- EffectiveEndDate

- Status

## 2. Rollup Behavior Model

- DERIVED --- Calculated dynamically from lower-scope accumulators.

- INDEPENDENT --- Posted directly at each scope level.

- HYBRID --- Combination of derived rollups and independent postings.

## 3. Reconciliation Relationship Types

- EXACT_SUM --- Higher totals equal sum of lower totals.

- SUM_PLUS_ADJUSTMENTS --- Includes authorized adjustments.

- INFORMATIONAL_ROLLUP --- Reporting rollups without strict
  reconciliation.

- NO_DIRECT_RELATIONSHIP --- Independent totals.

## 4. Consumer-Oriented Rollups

- Payroll Operations

- Management Accounting

- Corporate Accounting

- External Reporting

- Carrier Reconciliation

## 5. Cross-Scope Validation

- CrossScopeValidationEnabled (Boolean)

- ValidationFrequency

- ExceptionHandlingRule

## 6. Rule Versioning Integration

- RuleVersionID

- EffectiveDateRange

- EvaluationBasis

- ReplayCompatibilityRequirement
