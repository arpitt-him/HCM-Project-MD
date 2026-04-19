# Entity — Payroll Check

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/DATA/Entity_Payroll_Check.md` |
| **Related Documents** | DATA/Entity_Payroll_Run.md, DATA/Entity_Payroll_Item.md, DATA/Entity_Employee.md, docs/architecture/processing/Payroll_Check_Model.md, docs/architecture/interfaces/Pay_Statement_Model.md |

## Purpose

Defines the Payroll Check entity — the atomic accounting unit of payroll execution. All payroll financial results originate from a Payroll Check. Every check belongs to a run, belongs to one employee, and owns a set of result lines that drive accumulators, liabilities, pay statements, and reporting.

---

## 1. Design Principles

- One Payroll Check is produced per Employment_ID per Payroll Run.
- Checks are immutable once posted. Corrections use Void, Replacement, or Adjustment patterns — not direct edits.
- Idempotency is enforced: reprocessing replaces prior results rather than duplicating them.
- All financial outputs — pay statements, accumulators, liabilities — are traceable to a Check_ID.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Check_ID | UUID | Yes | System-generated. Immutable. |
| Check_Number | String | Yes | Human-readable identifier; unique within context |
| Payroll_Run_ID | UUID | Yes | The run that produced this check |
| Employment_ID | UUID | Yes | Payroll anchor — never Person_ID |
| Pay_Period_Start_Date | Date | Yes | |
| Pay_Period_End_Date | Date | Yes | |
| Check_Date | Date | Yes | Date the check was generated |
| Payment_Date | Date | Yes | Date the employee receives payment |
| Calendar_Context_ID | UUID | Yes | Tax calendar context for YTD alignment |
| Payment_Method | Enum | Yes | See values below |
| Payment_Context | Enum | Yes | See values below |
| Check_Status | Enum | Yes | See values below |
| Gross_Earnings | Decimal | Yes | Derived from result lines |
| Total_Deductions | Decimal | Yes | Derived from result lines |
| Total_Taxes | Decimal | Yes | Derived from result lines |
| Net_Pay | Decimal | Yes | Derived from result lines |
| Employer_Total_Cost | Decimal | No | Derived; includes employer contributions |
| Void_Reason | String | No | Required if Check_Status = VOIDED |
| Corrects_Check_ID | UUID | No | Reference to original if this is a correction |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | System-generated |

---

## 3. Payment_Method Values

| Value | Description |
|---|---|
| DIRECT_DEPOSIT | ACH transfer to employee bank account |
| PRINTED_CHECK | Physical paper check |
| PAYCARD | Payroll debit card |
| CASH | Cash payment |
| MANUAL_CHECK | Manually issued check outside normal processing |
| OTHER | Other payment method |

---

## 4. Payment_Context Values

| Value | Description |
|---|---|
| REGULAR | Standard scheduled payroll |
| OFF_CYCLE | Off-schedule payment |
| ADJUSTMENT | Correction to a prior check |
| VOID_REPLACEMENT | Replacement issued after void |
| TERMINATION | Final pay on termination |
| BONUS | Bonus or incentive payment |
| MANUAL | Manual payment outside system |

---

## 5. Check_Status Values

| Value | Description |
|---|---|
| INITIALIZED | Check record created; calculation not yet complete |
| CALCULATED | Gross-to-net computed; not yet released |
| VALIDATED | Passed validation; ready for release |
| RELEASED | Released; payment initiated |
| VOIDED | Voided; payment cancelled |
| CORRECTED | Superseded by a correction check |

---

## 6. Idempotency Key

Employment_ID + Check_Number + Payroll_Context_ID. Reprocessing a run replaces prior check records for the same idempotency key rather than creating duplicates.

---

## 7. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Payroll Check → Payroll Run | Many-to-one | |
| Payroll Check → Employment | Many-to-one | |
| Payroll Check → Payroll Items | One-to-many | Each result line is a Payroll Item |
| Payroll Check → Accumulators | One-to-many (indirect) | Via Payroll Items |
| Payroll Check → Pay Statement | One-to-one | |
| Payroll Check → Correcting Check | One-to-one | Optional |

---

## 8. Governance

- Checks are created exclusively by the payroll calculation engine.
- Check_Status transitions must follow the defined lifecycle.
- Released checks are immutable. Corrections generate new check records.
- All check status changes are audit-logged with timestamp and actor.

---

## 9. Related Architecture Models

| Model | Relevance |
|---|---|
| Payroll_Check_Model | Full check structure and correction lifecycle |
| Pay_Statement_Model | Pay statement generation from check |
| Accumulator_and_Balance_Model | How check result lines post to accumulators |
| Correction_and_Immutability_Model | Void, replacement, and adjustment patterns |
