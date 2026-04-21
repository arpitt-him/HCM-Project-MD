# Rule_Resolution_Engine

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Reviewed |
| **Owner** | Rules Domain |
| **Location** | `docs/rules/Rule_Resolution_Engine.md` |
| **Domain** | Rules |
| **Related Documents** | Rule_Versioning_Model, Policy_and_Rule_Execution_Model, Code_Classification_and_Mapping_Model, Tax_Classification_and_Obligation_Model, Employee_Payroll_Result_Model, Accumulator_Impact_Model, Payroll_Adjustment_and_Correction_Model |

## Purpose

Define the deterministic runtime mechanism that selects exactly one applicable rule version for a payroll event, explains why it was selected, and supports auditability, replayability, and simulation.

The Rule Resolution Engine governs how effective-dated rules become operational decisions that drive:

- payroll calculation outcomes
- tax treatment
- accumulator impacts
- remittance obligations
- export behavior
- correction and replay results

Without rule resolution, rule models remain stored definitions only. With rule resolution, governed rules become deterministic payroll outcomes.

# 1. Resolution Context Model

The resolution engine does not reason from rule tables alone. It
resolves against a fully specified resolution context.

A resolution context should include, at minimum:

- Rule family

- Jurisdiction

- Tax type

- Employee identifier

- Employee type or classification

- Payment type

- Earning type

- Work location

- Residency status

- Payroll period start and end dates

- Pay date

- Work date or allocation date where applicable

- Evaluation date derived from the governing evaluation basis

The resolution engine should treat the context snapshot as immutable for
the duration of a single resolution decision.

Where applicable, the resolution context should also preserve lineage to the governed payroll execution artifacts within which resolution occurs, including:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID
- Run_Scope_ID
- Source_Period_ID
- Execution_Period_ID

These references ensure that rule resolution can be reconstructed not only from business attributes, but also from the exact execution context in which the decision was made.

# 2. Candidate Rule Selection Pipeline

Resolution should occur through a narrowing pipeline rather than an
undifferentiated search.

Recommended pipeline:

1.  1\. Identify the target rule family.

2.  2\. Filter by jurisdiction and tax type.

3.  3\. Filter by effective date range using the rule's evaluation
    basis.

4.  4\. Filter by applicability domain attributes.

5.  5\. Score remaining candidates for specificity.

6.  6\. Break any remaining ties by explicit priority.

7.  7\. Select exactly one winner or raise a controlled failure.

This pipeline should be implemented identically in both production
payroll processing and Rule Impact Simulation so that the same logic
governs both real and simulated outcomes.

# 2.1 Relationship to Payroll Result Generation

Rule resolution decisions are consumed by payroll execution to generate governed result lines and downstream effects.

Relationship:

Resolution Context
        ↓
Rule Resolution
        ↓
Selected Rule Version
        ↓
Employee Payroll Result Line
        ↓
Accumulator Impact / Tax / Liability / Export Consequence

Selected rule versions may influence:

- earnings calculation
- deduction treatment
- tax classification and obligation handling
- employer contribution treatment
- accumulator routing
- remittance relevance
- export and accounting consequences

This ensures that rule resolution is understood as an execution input, not merely a rules-domain utility.

# 3. Applicability Matching Logic

Applicability matching determines whether a rule version is eligible for
consideration. A rule may constrain one or many dimensions of the
resolution context.

Typical applicability dimensions include:

- Jurisdiction

- Tax type

- Employee population

- Payment type

- Earning type

- Work location

- Residency pattern

- Special statutory or contractual condition

Overlapping rule versions are permitted only when the applicability
domains do not collide operationally. The engine must evaluate
applicability using exact, explainable matching logic rather than
informal pattern interpretation.

# 4. Hybrid Precedence Model

When multiple candidate rules survive date and applicability filtering,
the engine shall apply the hybrid precedence model.

Specificity first:\
A rule that constrains more context dimensions is considered more
specific and should outrank a broader rule.

Priority second:\
If specificity does not produce a single winner, the engine shall use
explicit priority values to break the tie.

This model provides natural behavior for exception handling while
preserving a deliberate override mechanism for edge cases and
administratively required precedence.

# 5. Resolution Trace Model

Every resolution decision must be traceable. The system must retain
enough structured information to explain why a particular rule won and
why other candidates were excluded.

A resolution trace should capture:

- Resolution trace identifier

- Context snapshot

- Candidate rules considered

- Elimination reasons for non-selected candidates

- Selected rule version

- Specificity score

- Priority value used, if any

- Resolution timestamp

The trace is not a debugging luxury. It is an operational and audit
requirement.

# 6. Failure Handling Model

The engine must fail in controlled ways.

Primary failure modes:

- Coverage gap: no eligible rule exists where one is required.

- Ambiguity: more than one eligible rule remains after precedence
  evaluation.

- Invalid rule data: malformed effective dates, missing jurisdiction, or
  incomplete applicability definitions.

- Optional rule not present: acceptable only when the consuming process
  explicitly allows absence.

Coverage gaps and ambiguities should be treated as critical unless the
rule family is explicitly modeled as optional.

Coverage gaps, ambiguities, and invalid rule data shall generate governed exception records consistent with Payroll_Exception_Model where payroll execution depends on successful resolution.

Exception handling shall preserve:

- rule family
- context snapshot
- candidate set
- failure type
- consuming process
- downstream impact scope

# 7. Performance and Caching Strategy

Rule resolution will be called repeatedly during payroll calculation,
tax determination, allocation processing, and simulation. Performance
therefore matters.

Recommended strategy:

- Pre-index rules by family, jurisdiction, and tax type.

- Cache common resolution contexts within a payroll run.

- Reuse resolution results across equivalent employee contexts where
  allowed.

- Isolate simulation caches from production caches.

- Expire caches when rule collections change.

Caching must improve speed without compromising determinism or
traceability.

Caching shall not change the logical basis of rule selection.

Replay operations must resolve using the same effective context, rule-set reference, and rule-version eligibility rules that were applicable at the original execution moment.

Cached results may improve performance, but they must never replace traceable historical resolution semantics.

# 8. Alternate Rule Set Support for RIS

The resolution engine must support alternate rule collections for Rule
Impact Simulation.

This allows the system to compare:\
versus

- Baseline rule set

- Candidate or future-dated rule set

Both scenarios must use the same input context and starting state so
that differences can be attributed to rule changes rather than data
drift. The engine should therefore accept a rule-set reference as an
explicit input rather than assuming a single production collection.

# 9. Determinism Guarantees

The rule resolution engine is part of the replayability foundation of
the platform.

Determinism requires:

- Stable context definition

- Stable rule collection reference

- Effective-dated rule evaluation

- Explicit applicability logic

- Hybrid precedence applied consistently

- Trace retention for later reconstruction

The platform should be able to answer: given this exact context at that
historical moment, which rule version applied and why?

Determinism must also hold across:

- retroactive recalculation
- correction runs
- additive adjustment runs
- simulation against alternate rule sets

The platform should be able to answer not only which rule applied originally, but also which rule applied during a later correction or simulation, and why that outcome differed or remained the same.

# 10. Illustrative Precedence Example

The following example shows how hybrid precedence works when several
Pennsylvania state income tax rules are simultaneously eligible for
consideration.

  --------------------------------------------------------------------------------------
  **Rule Version**   **Applicability**   **Specificity**   **Priority**   **Outcome**
  ------------------ ------------------- ----------------- -------------- --------------
  PA_SIT_GEN         PA jurisdiction     1                 10             Loses
                     only                                                 

  PA_SIT_BONUS       PA + bonus payment  2                 10             Loses

  PA_SIT_BONUS_PGH   PA + bonus +        3                 10             Wins
                     Pittsburgh                                           
  --------------------------------------------------------------------------------------

# 10.1 Relationship to Other Models

This model integrates with:

- Rule_Versioning_Model
- Policy_and_Rule_Execution_Model
- Code_Classification_and_Mapping_Model
- Tax_Classification_and_Obligation_Model
- Employee_Payroll_Result_Model
- Accumulator_Impact_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model

# 11. Concluding Principle

The rule resolution engine is the runtime discipline that turns a large
collection of effective-dated, jurisdiction-sensitive rules into a
single explainable decision. Without it, the rule model is only storage.
With it, the system becomes deterministic, auditable, and fit for
payroll operations.
