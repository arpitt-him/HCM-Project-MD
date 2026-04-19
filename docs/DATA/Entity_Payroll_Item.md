# Entity — Payroll Item

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/DATA/Entity_Payroll_Item.md` |
| **Related Documents** | DATA/Entity_Employee.md, PRD-0200_Core_Entity_Model.md, PRD-0400_Earnings_Model.md, PRD-0500_Accumulator_Strategy.md, docs/architecture/calculation-engine/Earnings_and_Deductions_Computation_Model.md, docs/architecture/calculation-engine/Result_and_Payable_Model.md, docs/rules/Code_Classification_and_Mapping_Model.md |

## Purpose

Defines the canonical Payroll Item entity — a single computed line within a payroll result representing an earnings amount, deduction, tax withholding, or employer contribution for one employee in one payroll period.

Payroll Items are the atomic unit of payroll financial output. They feed accumulators, drive liabilities, appear on pay statements, and form the basis of all downstream reporting and reconciliation.

---

## 1. Design Principles

- One Payroll Item represents one result class (earning, deduction, tax, employer contribution) for one employee in one period.
- Payroll Items are produced by the calculation engine after all input validation is complete.
- Payroll Items are immutable once posted. Corrections generate new compensating items; they do not overwrite existing ones.
- Every Payroll Item must be traceable to its source run, input context, and the rule version that governed it.
- All Payroll Items are classified using the canonical code classification model before posting.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Payroll_Item_ID | UUID | Yes | System-generated. Immutable. |
| Payroll_Run_ID | UUID | Yes | The run that produced this item |
| Payroll_Check_ID | UUID | Yes | The check this item belongs to |
| Employment_ID | UUID | Yes | Payroll anchor — never Person_ID |
| Period_ID | UUID | Yes | The payroll period |
| Result_Class | Enum | Yes | See values below |
| Code_Type | String | Yes | External or canonical code type |
| Code | String | Yes | Earning/deduction/tax code |
| Description | String | Yes | Human-readable; appears on pay statement |
| Hours | Decimal | No | Applicable for hourly earnings |
| Rate | Decimal | No | Applicable for hourly earnings |
| Amount | Decimal | Yes | Calculated amount; positive or negative |
| Taxable_Flag | Boolean | Yes | Whether this item affects taxable wages |
| Cash_Impact_Flag | Boolean | Yes | Whether this item affects net pay |
| Accumulator_Target | String | No | Which accumulator family this item feeds |
| Source_Rule_Version_ID | UUID | No | Rule version that governed calculation |
| Item_Status | Enum | Yes | See values below |
| Correction_Flag | Boolean | Yes | True if this item is a correction |
| Corrects_Item_ID | UUID | No | Reference to the item being corrected |
| Creation_Timestamp | Datetime | Yes | System-generated |

---

## 3. Result_Class Values

| Value | Description |
|---|---|
| EARNING | Wages, salary, bonus, commission, overtime |
| DEDUCTION_PRE_TAX | Employee deduction reducing taxable wages |
| DEDUCTION_POST_TAX | Employee deduction from after-tax net pay |
| TAX_WITHHOLDING | Employee tax withheld (federal, state, local) |
| EMPLOYER_CONTRIBUTION | Employer-paid benefit or tax obligation |
| IMPUTED_INCOME | Non-cash benefit increasing taxable wages |
| ADJUSTMENT | Correction or manual override entry |
| REIMBURSEMENT | Non-taxable expense reimbursement |

---

## 4. Item_Status Values

| Value | Description |
|---|---|
| CALCULATED | Produced by engine; awaiting validation |
| VALIDATED | Passed all validation checks |
| POSTED | Committed to durable financial state |
| SUPERSEDED | Replaced by a correction item |
| VOIDED | Voided before posting; not effective |

---

## 5. Earnings Sub-types

When Result_Class is EARNING, the Code further classifies the earning type:

| Code Family | Examples |
|---|---|
| Regular wages | REG, SAL |
| Overtime | OT1, OT15 |
| Supplemental | BONUS, COMMISSION |
| Residual | RESIDUAL |
| Leave | PTO, SICK, HOL |
| Adjustments | ADJ, REVERSAL |

---

## 6. Computation Order

Within a payroll check, items are computed and posted in a defined order to ensure taxable wage bases are correct before tax items are produced:

1. Base earnings (regular, salary, hourly)
2. Premium earnings (overtime, holiday, supplemental)
3. Pre-tax deductions (reduce taxable wage bases)
4. Imputed income (increase taxable wage bases)
5. Tax withholdings (computed from adjusted taxable wages)
6. Post-tax deductions
7. Employer contributions
8. Net pay derivation

This order is governed by the `Earnings_and_Deductions_Computation_Model`.

---

## 7. Accumulator Impact

Each posted Payroll Item updates one or more accumulators:

| Result_Class | Accumulator Targets |
|---|---|
| EARNING | Gross Wages (PTD, QTD, YTD, LTD) |
| DEDUCTION_PRE_TAX | Pre-Tax Deduction Totals |
| TAX_WITHHOLDING | Federal / State / Local Tax Totals |
| EMPLOYER_CONTRIBUTION | Employer Liability Totals |
| IMPUTED_INCOME | Taxable Wage Accumulators |

Accumulator updates are atomic with the posting of the Payroll Item. They are governed by the `Accumulator_and_Balance_Model`.

---

## 8. Pay Statement Display

Payroll Items with a Description are eligible for display on the employee pay statement. Description values must:

- Be human-readable
- Fit within the character limit defined by the pay statement template
- Be set at the time of calculation (not derived at display time)

Governed by `docs/architecture/interfaces/Pay_Statement_Model.md`.

---

## 9. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Payroll Item → Payroll Check | Many-to-one | |
| Payroll Item → Payroll Run | Many-to-one | |
| Payroll Item → Employment | Many-to-one | |
| Payroll Item → Accumulator | Many-to-many | Via accumulator routing rules |
| Payroll Item → Liability | One-to-many | Tax and benefit liabilities |
| Payroll Item → Corrects Item | Many-to-one (optional) | Correction linkage |

---

## 10. Related Architecture Models

| Model | Relevance |
|---|---|
| Earnings_and_Deductions_Computation_Model | Governs how items are computed |
| Result_and_Payable_Model | Governs result lifecycle and payable promotion |
| Code_Classification_and_Mapping_Model | Governs code-to-canonical-class mapping |
| Accumulator_and_Balance_Model | Governs accumulator updates from items |
| Correction_and_Immutability_Model | Governs correction item handling |
| Posting_Rules_and_Mutation_Semantics | Governs when and how items become durable state |
