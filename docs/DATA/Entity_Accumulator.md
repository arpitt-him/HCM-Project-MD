# Entity — Accumulator

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/DATA/Entity_Accumulator.md` |
| **Related Documents** | DATA/Entity_Payroll_Item.md, DATA/Entity_Payroll_Check.md, PRD-0500_Accumulator_Strategy.md, docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md, docs/accumulators/Accumulator_Model_Detailed.md |

## Purpose

Defines the Accumulator entity — the persisted running balance structure that tracks cumulative payroll totals across periods. Accumulators are the authoritative source for YTD, QTD, and LTD figures used in tax compliance, benefit thresholds, pay statement display, and reporting. The entity is split into two sub-entities: Accumulator_Balance (current value) and Accumulator_Contribution (history).

---

## 1. Design Principles

- Current balances and contribution history are stored separately for performance and auditability.
- Accumulator updates are atomic with the posting of payroll results. Partial updates are not permitted.
- Accumulator values are never overwritten. Corrections generate reversal contribution records.
- Accumulator state must be fully reproducible from contribution history.
- Reset logic is explicit and tied to calendar boundaries.

---

## 2. Accumulator_Balance Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Accumulator_ID | UUID | Yes | System-generated. Immutable. |
| Accumulator_Family | Enum | Yes | See values below |
| Scope_Type | Enum | Yes | See values below |
| Participant_ID | UUID | Conditional | Required if scope includes employee |
| Employer_ID | UUID | Conditional | Required if scope includes employer |
| Jurisdiction_ID | UUID | No | For jurisdiction-scoped accumulators |
| Plan_ID | UUID | No | For plan-year accumulators |
| Period_Context | Enum | Yes | PTD, QTD, YTD, PLAN_YEAR, LTD |
| Calendar_Context_ID | UUID | Yes | Defines reset boundaries |
| Current_Value | Decimal | Yes | Current balance |
| Balance_Status | Enum | Yes | ACTIVE, RESET, ARCHIVED |
| Last_Updated_Run_ID | UUID | Yes | Run that last updated this balance |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Accumulator_Contribution Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Contribution_ID | UUID | Yes | System-generated. Immutable. |
| Accumulator_ID | UUID | Yes | Links to Accumulator_Balance |
| Source_Run_ID | UUID | Yes | Run that generated this contribution |
| Source_Check_ID | UUID | Yes | Check that generated this contribution |
| Period_ID | UUID | Yes | The payroll period |
| Contribution_Amount | Decimal | Yes | Positive or negative |
| Contribution_Type | Enum | Yes | STANDARD, REVERSAL, CORRECTION, RESET |
| Before_Value | Decimal | No | Balance before this contribution |
| After_Value | Decimal | No | Balance after this contribution |
| Reason_Code | String | No | |
| Creation_Timestamp | Datetime | Yes | |

---

## 4. Accumulator_Family Values

| Value | Description |
|---|---|
| GROSS_WAGES | Total gross earnings |
| PRE_TAX_DEDUCTIONS | Pre-tax benefit and retirement deductions |
| POST_TAX_DEDUCTIONS | Post-tax deductions |
| FEDERAL_TAX_WITHHELD | Federal income tax withheld |
| STATE_TAX_WITHHELD | State income tax withheld |
| LOCAL_TAX_WITHHELD | Local income tax withheld |
| SOCIAL_SECURITY | Social Security tax |
| MEDICARE | Medicare tax |
| EMPLOYER_FICA | Employer FICA contributions |
| FUTA | Federal unemployment tax |
| SUI | State unemployment insurance |
| EMPLOYER_BENEFIT | Employer benefit contributions |
| RETIREMENT | Retirement contributions (employee + employer) |
| GARNISHMENT_TOTALS | Garnishment withholdings |

---

## 5. Scope_Type Values

| Value | Description |
|---|---|
| EMPLOYEE | Per-employee totals |
| EMPLOYER | Per-employer totals |
| EMPLOYEE_JURISDICTION | Employee totals scoped to a jurisdiction |
| EMPLOYER_JURISDICTION | Employer totals scoped to a jurisdiction |
| CLIENT_JURISDICTION | PEO client totals scoped to a jurisdiction |

---

## 6. Period_Context and Reset Rules

| Period_Context | Reset Trigger |
|---|---|
| PTD | Each new payroll period |
| QTD | Each new calendar quarter |
| YTD | Each new tax year |
| PLAN_YEAR | Each new plan year |
| LTD | Never reset |

---

## 7. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Accumulator Balance → Contributions | One-to-many | Full history retained |
| Accumulator Balance → Employment | Many-to-one | For employee-scoped accumulators |
| Accumulator Balance → Calendar Context | Many-to-one | Defines reset boundary |

---

## 8. Governance

- Accumulator balances may only be updated through the payroll posting workflow.
- Direct balance edits outside the calculation engine are not permitted.
- Correction contributions must reference the original contribution being corrected.
- All accumulator updates are audit-logged.

---

## 9. Related Architecture Models

| Model | Relevance |
|---|---|
| Accumulator_and_Balance_Model | Full accumulator design and validation |
| Accumulator_Model_Detailed | Rollup behaviour and consumer-group definitions |
| Posting_Rules_and_Mutation_Semantics | How result lines post to accumulators |
| Correction_and_Immutability_Model | Reversal and correction contribution rules |
