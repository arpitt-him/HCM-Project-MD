# Accumulator_Definition_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Calculation & Reporting Domain |
| **Location** | docs/architecture/processing/Accumulator_Definition_Model.md |
| **Domain** | Accumulators / Totals / Reset Logic / Reporting Foundations |
| **Related Documents** | Employee_Payroll_Result_Model.md, Payroll_Run_Result_Set_Model.md, Payroll_Adjustment_and_Correction_Model.md, Tax_Classification_and_Obligation_Model.md, Rule_Pack_Model.md, Regulatory_and_Compliance_Reporting_Model.md |

---

# Purpose

This document defines the core data structure for **Accumulator Definition** as the governed specification of payroll totals, balances, and reporting counters used across calculation, remittance, reporting, and audit processes.

Accumulator Definition exists to define:

- what an accumulator represents
- what kinds of results feed it
- how it resets
- how it is scoped
- how it participates in payroll calculation and reporting
- how correction and replay logic affect it

This model exists to support:

- year-to-date payroll totals
- quarter-to-date and month-to-date totals
- tax wage bases
- deduction balances
- employer contribution balances
- jurisdiction-specific totals
- remittance support
- statutory reporting support
- retroactive correction handling

without embedding accumulator semantics directly inside payroll result lines or reporting logic.

---

# Core Structural Role

```text
Accumulator Definition
    ↓
Accumulator Impact Rules
    ↓
Employee Payroll Result / Payroll Run Result Set
    ↓
Updated Accumulator Values
    ↓
Reporting / Remittance / Replay / Correction
```

Accumulator Definition is the governed semantic meaning of payroll totals.

It is distinct from the actual stored accumulator value.

---

# 1. Accumulator Definition

An **Accumulator Definition** represents the governed definition of a payroll total, balance, or reporting counter.

An Accumulator Definition may represent:

- year-to-date gross wages
- year-to-date taxable wages
- quarter-to-date unemployment wages
- month-to-date deduction totals
- benefit plan balances
- garnishment arrears
- employer contribution totals
- jurisdiction-specific tax bases
- remittance liability totals
- custom reporting totals

Accumulator Definition shall be modeled as distinct from:

- Employee Payroll Result
- Payroll Run Result Set
- Accumulator value record
- Rule Pack
- tax classification
- report definition

Accumulator Definition is the meaning and structure of the accumulator, not the actual current balance.

---

# 2. Accumulator Definition Primary Attributes

| Field Name | Description |
|---|---|
| Accumulator_Definition_ID | Unique identifier |
| Accumulator_Code | Unique business/system code |
| Accumulator_Name | Human-readable name |
| Accumulator_Category | Earnings, Tax, Deduction, Employer_Contribution, Balance, Liability, Reporting, Other |
| Accumulator_Status | Draft, Active, Inactive, Retired |
| Scope_Type | Person, Employment, Legal_Entity, Jurisdiction, Payroll_Context, Other |
| Reset_Frequency | Never, Per_Pay_Period, Monthly, Quarterly, Annual, Custom |
| Effective_Start_Date | Date definition becomes effective |
| Effective_End_Date | Date definition ceases use |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Accumulator Functional Attributes

| Field Name | Description |
|---|---|
| Accumulator_Description | Narrative explanation |
| Positive_Negative_Allowed_Flag | Indicates whether negative values are valid |
| Retroactive_Adjustment_Allowed_Flag | Indicates retro corrections may update prior values |
| Jurisdiction_Relevance_Flag | Indicates jurisdiction-specific usage |
| Tax_Base_Relevance_Flag | Indicates tax base handling relevance |
| Reporting_Relevance_Flag | Indicates statutory or management reporting use |
| Remittance_Relevance_Flag | Indicates liability/remittance use |
| Balance_Carry_Forward_Flag | Indicates values roll forward across reset boundary |
| Rounding_Rule_Type | Standard, Currency, Tax, Custom, Other |
| Notes | Administrative notes |

---

# 4. Scope Model

Accumulator Definitions must be explicitly scoped.

Supported scope patterns include:

- **Person** — durable totals across employments where policy permits
- **Employment** — totals specific to one employment relationship
- **Legal Entity** — totals at employer-of-record level
- **Jurisdiction** — totals specific to tax or reporting authority context
- **Payroll Context** — totals specific to a payroll grouping or cycle context
- **Other** — governed custom scope

Scope must remain explicit because the same conceptual total may need different accumulator definitions at different levels.

Examples:

- Employee YTD Gross Wages → Employment scope
- Employer State Unemployment Wages → Legal Entity + Jurisdiction scope
- Quarterly withholding liability → Legal Entity + Jurisdiction scope

---

# 5. Reset Logic Model

Reset logic defines when an accumulator returns to a new reporting or calculation base.

Supported patterns include:

- never resets
- per pay period reset
- monthly reset
- quarterly reset
- annual reset
- custom reset based on calendar or statutory schedule

Examples:

- YTD federal taxable wages → annual reset
- QTD unemployment wages → quarterly reset
- current pay-period gross wages → per pay period reset
- garnishment arrears → no automatic reset

Reset logic must align with the governing calendar and statutory rules.

Reset behavior shall not be inferred only from accumulator name.

---

# 6. Relationship to Accumulator_Model_Detailed.md

Accumulator Definition provides the semantic and governance layer that defines the meaning, scope, reset behavior, and reporting relevance of accumulators.

Accumulator_Model_Detailed.md represents the operational storage and lifecycle of accumulator values that are created, updated, and maintained during payroll execution.

Relationship:

Accumulator_Definition
        ↓
Accumulator_Impact
        ↓
Accumulator_Value (Accumulator_Model_Detailed)

Accumulator_Definition defines meaning.
Accumulator_Model_Detailed stores values.


# 7. Relationship to Payroll Result Lines

Accumulator Definitions do not store results directly.

Instead, they define which payroll result lines may affect stored accumulator values.

Typical path:

```text
Accumulator Definition
    ↓
Impact Rule / Qualification Logic
    ↓
Employee Payroll Result Line
    ↓
Accumulator Impact
```

Relevant line types may include:

- earnings result lines
- deduction result lines
- tax result lines
- employer contribution result lines
- correction lines
- reversal lines

This structure allows accumulator semantics to remain governed and traceable.

---

# 8. Relationship to Employee Payroll Result

Employee Payroll Result may generate one or more Accumulator Impacts referencing Accumulator Definitions.

Typical path:

```text
Employee Payroll Result
    └── Accumulator Impact
            └── Accumulator Definition
```

Accumulator Definition explains what the accumulator means.

Accumulator Impact records what changed during a given payroll result.

Stored balance/value records may be modeled separately.

This distinction is essential for replay and audit.

---

# 9. Relationship to Payroll Adjustment and Correction

Corrections may affect accumulator values.

Accumulator Definitions must therefore support:

- additive adjustments
- partial reversals
- full reversals
- replacement results
- retroactive recalculation impacts

Corrections shall not redefine the accumulator itself.

They change the values recorded against the governed definition.

The definition must remain stable enough to support:

- before/after reconstruction
- corrected-value replay
- reporting reconciliation

---

# 10. Jurisdiction and Tax Relevance

Some accumulators are jurisdiction-sensitive.

Examples:

- federal taxable wage base
- state unemployment wage base
- city withholding wages
- authority-specific taxable benefits
- local leave accrual balances

Accumulator Definition may therefore include jurisdiction relevance and may be referenced by jurisdiction-aware rule packs.

Where jurisdiction matters, the applicable Jurisdiction or Jurisdiction Profile must remain traceable from downstream accumulator values or impacts.

---

# 11. Remittance and Reporting Relevance

Some accumulators feed remittance or reporting directly.

Examples:

- employer tax liability totals
- withheld tax totals
- benefit remittance balances
- statutory reporting wage totals
- year-end taxable compensation totals

These accumulators may be required for:

- authority filings
- provider settlements
- liability reconciliation
- period-end payroll close

Accumulator Definition should therefore explicitly support remittance and reporting relevance flags.

---

# 12. Balance Carry-Forward and Threshold Considerations

Some accumulators reset cleanly.

Others require carry-forward or threshold handling.

Examples:

- garnishment arrears may carry forward indefinitely
- deduction balances may carry to future periods
- tax wage bases may stop accumulating once threshold is reached
- leave accrual balances may cap and carry according to policy

Accumulator Definition may therefore need to support:

- carry-forward rules
- cap or threshold references
- stop-at-limit behavior
- continuation after reset boundary where applicable

The definition should preserve the governing semantics even if the actual calculation logic is implemented via Rule Packs.

---

# 13. Status Model

Suggested Accumulator_Status values:

| Status | Meaning |
|---|---|
| Draft | Defined but not yet active |
| Active | Available for operational use |
| Inactive | Retained historically but not currently used |
| Retired | Permanently retired and no longer assignable |

Status transitions shall be governed and auditable.

Retired definitions may not be newly assigned to active result-impact logic without formal reactivation.

Historical values tied to retired definitions must remain queryable.

---

# 14. Effective Dating and Historical Preservation

Accumulator Definitions shall support effective dating.

Changes that may require historical preservation include:

- description changes
- reset rule changes
- scope changes
- reporting relevance changes
- threshold or carry-forward semantics
- rounding rule changes

Historical definitions must be preserved.

Silent overwrite is not permitted where definition changes affect replay, statutory reporting, remittance logic, or audit interpretation.

If a meaning changes materially, a new effective-dated definition should generally be created rather than redefining history.

---

# 14. Validation Rules

Examples of validation rules:

- Accumulator_Code is required
- Accumulator_Name is required
- Accumulator_Category is required
- Scope_Type is required
- Reset_Frequency is required
- Effective_End_Date may not precede Effective_Start_Date
- Retired definitions may not be newly used in active impact rules
- Positive_Negative_Allowed_Flag must align with governed balance semantics where policy requires
- Balance_Carry_Forward_Flag must be compatible with Reset_Frequency where policy requires

These validations shall be enforced through payroll configuration governance and accumulator management controls.

---

# 15. Audit and Traceability Requirements

The system shall preserve:

- accumulator definition creation history
- status transition history
- reset-rule history
- scope history
- remittance/reporting relevance history
- threshold/carry-forward semantics history
- downstream impact-rule linkage history

This supports:

- payroll replay
- reporting reconciliation
- audit review
- statutory interpretation review
- correction traceability

---

## 15.1 Relationship to Accumulator_Impact_Model.md

Accumulator_Impact_Model.md defines the governed mutation layer between payroll results and stored accumulator values.

Relationship:

Accumulator_Definition
        ↓
Accumulator_Impact
        ↓
Accumulator_Value (Accumulator_Model_Detailed)

In this structure:

- `Accumulator_Definition_Model.md` defines accumulator meaning, scope, reset behavior, carry-forward semantics, and reporting/remittance relevance.
- `Accumulator_Impact_Model.md` records the actual mutation applied to an accumulator, including source lineage, scope context, jurisdiction context, retroactivity, reversal handling, and correction handling.
- `Accumulator_Model_Detailed.md` stores runtime accumulator values and governs rollup, reconciliation, and value-level operational behavior.

Accumulator Definition therefore governs the semantic meaning of impacts and stored values, while remaining distinct from both mutation records and runtime balances.

This separation supports:

- deterministic replay
- correction traceability
- reporting defensibility
- remittance explanation
- cross-scope reconciliation
- audit integrity

---

# 16. Relationship to Other Models

This model integrates with:

- Accumulator_Impact_Model
- Accumulator_Model_Detailed
- Employee_Payroll_Result_Model
- Payroll_Run_Result_Set_Model
- Payroll_Adjustment_and_Correction_Model
- Tax_Classification_and_Obligation_Model
- Rule_Pack_Model
- Regulatory_and_Compliance_Reporting_Model

---

# 17. Summary

This model establishes Accumulator Definition as the governed semantic definition of payroll totals, balances, and reporting counters.

Key principles:

- Accumulator Definition is distinct from accumulator values and impacts
- Scope, reset logic, and reporting meaning must be explicit
- Definitions must support payroll, remittance, reporting, and correction use cases
- Jurisdiction relevance and threshold behavior must remain governable
- Historical integrity and effective dating are mandatory
