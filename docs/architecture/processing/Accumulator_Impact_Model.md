# Accumulator_Impact_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Calculation & Reporting Domain |
| **Location** | docs/architecture/processing/Accumulator_Impact_Model.md |
| **Domain** | Accumulator Impacts / Result-to-Accumulator Mutation / Replay Traceability |
| **Related Documents** | Employee_Payroll_Result_Model.md, Payroll_Run_Result_Set_Model.md, Payroll_Adjustment_and_Correction_Model.md, Accumulator_Definition_Model.md, Accumulator_Model_Detailed.md, Rule_Pack_Model.md, Tax_Classification_and_Obligation_Model.md |

---

# Purpose

This document defines the core data structure for **Accumulator Impact** as the governed mutation record that connects payroll results to accumulator value changes.

Accumulator Impact exists to preserve:

- which payroll result affected which accumulator
- what change was applied
- at what scope the change was applied
- under which rule and effective context the change occurred
- whether the impact came from an original result, retro result, reversal, or correction

This model exists to support:

- deterministic replay
- accumulator traceability
- tax and reporting reconstruction
- retroactive recalculation
- reversal and correction integrity
- cross-scope rollup validation
- auditability of accumulator mutation

without embedding accumulator mutation semantics directly inside result lines or stored accumulator balances.

---

# Core Structural Role

```text
Employee Payroll Result / Payroll Adjustment and Correction
    ↓
Accumulator Impact
    ↓
Accumulator Definition
    ↓
Accumulator Value / Balance
    ↓
Rollup / Reporting / Remittance / Replay
```

Accumulator Impact is the mutation layer between payroll outcomes and stored accumulator state.

---

# 1. Accumulator Impact Definition

An **Accumulator Impact** represents a governed record of how a payroll outcome changes an accumulator value.

An Accumulator Impact may represent:

- addition to YTD gross wages
- reduction of a deduction balance
- increase to taxable wage base
- employer contribution liability update
- retroactive correction to prior-period totals
- reversal of a prior accumulator effect
- jurisdiction-specific allocation impact
- reporting-only total update

Accumulator Impact shall be modeled as distinct from:

- Accumulator Definition
- Accumulator value/balance record
- Employee Payroll Result
- Payroll Run Result Set
- Rule Pack
- report output

Accumulator Impact is the mutation event record, not the definition and not the stored total.

---

# 2. Accumulator Impact Primary Attributes

| Field Name | Description |
|---|---|
| Accumulator_Impact_ID | Unique identifier |
| Accumulator_Definition_ID | Referenced accumulator definition |
| Payroll_Run_Result_Set_ID | Parent payroll run result set reference |
| Employee_Payroll_Result_ID | Parent employee payroll result reference where applicable |
| Payroll_Run_ID | Parent payroll run reference |
| Employment_ID | Employment reference where applicable |
| Person_ID | Person reference where applicable |
| Impact_Status | Calculated, Posted, Reversed, Corrected, Superseded |
| Impact_Source_Type | Earnings_Line, Deduction_Line, Tax_Line, Employer_Contribution_Line, Correction_Line, Manual_Adjustment, Other |
| Source_Object_ID | Source line or object reference |
| Impact_Timestamp | Time impact was generated/applied |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Accumulator Impact Functional Attributes

| Field Name | Description |
|---|---|
| Prior_Value | Accumulator value before this impact |
| Delta_Value | Amount of change applied |
| New_Value | Accumulator value after this impact |
| Posting_Direction | Increase, Decrease, Neutral, Derived |
| Scope_Type | Person, Employment, Legal_Entity, Jurisdiction, Payroll_Context, Other |
| Scope_Object_ID | Object at which value is applied |
| Jurisdiction_ID | Jurisdiction reference where relevant |
| Rule_Pack_ID | Governing rule pack reference where relevant |
| Rule_Version_ID | Governing rule version reference where relevant |
| Retroactive_Flag | Indicates retroactive impact |
| Reversal_Flag | Indicates reversal impact |
| Correction_Flag | Indicates correction-driven impact |
| Notes | Administrative notes |

---

# 4. Relationship to Employee Payroll Result

Accumulator Impact is primarily produced by Employee Payroll Result.

Typical path:

```text
Employee Payroll Result
    └── Accumulator Impact (0..n)
```

A single Employee Payroll Result may produce multiple impacts across:

- earnings accumulators
- tax accumulators
- deduction accumulators
- employer contribution accumulators
- reporting totals
- jurisdiction-specific balances

Accumulator Impact preserves the exact mutation outcome that results from worker-level payroll processing.

---

# 5. Relationship to Payroll Run Result Set

Some accumulator impacts may be generated or summarized at the broader run level.

Typical path:

```text
Payroll Run Result Set
    └── Accumulator Impact (0..n)
```

Examples may include:

- legal-entity liability totals
- run-level remittance accumulators
- aggregate reporting counters
- cross-employee control totals

This allows accumulator mutation to exist both at worker-detail level and at broader payroll execution levels where needed.

---

# 6. Relationship to Accumulator Definition

Every Accumulator Impact must reference exactly one governed Accumulator Definition.

Typical path:

```text
Accumulator Definition
    └── Accumulator Impact (0..n)
```

Accumulator Definition explains:

- what the accumulator means
- what scope it applies to
- how it resets
- whether it carries forward
- how it participates in reporting/remittance

Accumulator Impact records the actual change against that meaning.

No impact may exist without a governed definition.

---

# 7. Relationship to Accumulator Value / Detailed Model

Accumulator Impact is the mutation input to stored accumulator balances.

Typical path:

```text
Accumulator Impact
    ↓
Accumulator Value / Balance
```

`Accumulator_Model_Detailed.md` represents the runtime storage and behavior of accumulator values and rollups.

Accumulator Impact provides the explicit mutation lineage by which those stored values change.

Relationship:

```text
Accumulator_Definition
        ↓
Accumulator_Impact
        ↓
Accumulator_Value (Accumulator_Model_Detailed)
```

Definition provides meaning.  
Impact provides mutation.  
Detailed model stores values and rollup behavior.

---

# 8. Impact Source Model

Accumulator impacts should preserve the source payroll artifact that caused the change.

Supported sources may include:

- earnings result line
- deduction result line
- tax result line
- employer contribution result line
- correction line
- reversal line
- manual governed adjustment
- imported correction input

This is essential for:

- traceability
- audit explanation
- accumulator dispute handling
- retro and reversal replay

Source lineage must remain explicit.

---

# 9. Scope and Posting Model

Accumulator Impact must respect the scope defined by the Accumulator Definition.

Examples:

- Employment-scoped YTD gross wages
- Jurisdiction-scoped taxable wages
- Legal Entity liability balances
- Person-scoped service-related balances where policy permits

Posting direction shall also remain explicit.

Examples:

- positive earning adds to gross wage accumulator
- garnishment repayment reduces outstanding balance
- reversal negates prior delta
- derived rollup may be marked as Derived or informational posting

This prevents ambiguity during replay and reconciliation.

---

# 10. Retroactive, Reversal, and Correction Handling

Accumulator Impact must support non-standard mutation patterns.

### 10.1 Retroactive Impact

Applies to a prior effective period but is generated in a later run.

### 10.2 Reversal Impact

Negates a previously posted impact.

### 10.3 Correction Impact

Adjusts prior values through governed correction processing.

These patterns must remain explicitly flagged and linked to their lineage.

Examples of useful lineage fields or relationships:

- Prior_Accumulator_Impact_ID
- Correction_Reference_ID
- Source_Period_ID
- Corrected_Period_ID

The model must support before/after reconstruction.

---

# 11. Jurisdiction and Reporting Relevance

Some impacts are jurisdiction-sensitive or reporting-sensitive.

Examples:

- federal taxable wage impact
- state unemployment wage impact
- local withholding wage impact
- authority-specific benefit or liability impact

Where jurisdiction matters, the impact should preserve:

- Jurisdiction_ID
- applicable scope
- rule/version context

This allows reporting and remittance reconciliation to explain not only totals, but how those totals were built.

---

# 12. Impact Status Model

Suggested Impact_Status values:

| Status | Meaning |
|---|---|
| Calculated | Impact determined but not yet formally posted |
| Posted | Impact applied to accumulator values |
| Reversed | Impact negated by a later reversal |
| Corrected | Impact superseded or adjusted by correction logic |
| Superseded | Historical impact retained but replaced in operational lineage |

Status transitions shall be governed and auditable.

Historical impacts must remain preserved even when later reversed or corrected.

---

# 13. Effective Dating and Historical Preservation

Accumulator Impact is an execution artifact and is therefore naturally historical.

The model shall preserve:

- original mutation values
- source lineage
- scope context
- rule/version context
- status history
- reversal/correction lineage
- period relevance

Historical impacts must never be overwritten in place.

This is mandatory for:

- replay
- correction traceability
- remittance reconstruction
- reporting defensibility
- audit inquiry response

---

# 14. Validation Rules

Examples of validation rules:

- Accumulator_Definition_ID is required
- Impact_Source_Type is required
- Impact_Status is required
- Delta_Value must be present unless derived posting rules explicitly permit otherwise
- New_Value should reconcile to Prior_Value plus Delta_Value where arithmetic posting applies
- Scope_Type and Scope_Object_ID must align with definition scope semantics
- Reversal impacts must reference prior lineage where policy requires
- Corrected impacts must preserve correction linkage where policy requires
- Posted impacts may not be edited directly outside governed correction handling

These validations shall be enforced through payroll processing controls and accumulator governance rules.

---

# 15. Audit and Traceability Requirements

The system shall preserve:

- impact creation history
- source lineage history
- status transition history
- rule/version linkage history
- jurisdiction linkage history
- reversal lineage
- correction lineage
- posting and supersession history

This supports:

- payroll replay
- accumulator audit
- reporting reconciliation
- remittance explanation
- tax review
- correction defensibility

---

# 16. Relationship to Other Models

This model integrates with:

- Employee_Payroll_Result_Model
- Payroll_Run_Result_Set_Model
- Payroll_Adjustment_and_Correction_Model
- Accumulator_Definition_Model
- Accumulator_Model_Detailed.md
- Rule_Pack_Model
- Tax_Classification_and_Obligation_Model
- Regulatory_and_Compliance_Reporting_Model

---

# 17. Summary

This model establishes Accumulator Impact as the governed mutation record connecting payroll results to accumulator values.

Key principles:

- Accumulator Impact is distinct from accumulator definitions and stored balances
- Every impact must reference a governed accumulator definition
- Impacts preserve source lineage, scope, rule context, and arithmetic effect
- Retroactive, reversal, and correction impacts must remain explicit
- Impacts are the traceable bridge between payroll results and accumulator storage
- Historical integrity and replayability are mandatory
