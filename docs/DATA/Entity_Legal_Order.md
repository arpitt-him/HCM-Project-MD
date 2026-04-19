# Entity — Legal Order

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Compliance Domain |
| **Location** | `docs/DATA/Entity_Legal_Order.md` |
| **Related Documents** | DATA/Entity_Employee.md, docs/STATE/STATE-GAR_Garnishment.md, docs/architecture/governance/Garnishment_and_Legal_Order_Model.md, docs/EXC/EXC-DED_Benefits_Deductions_Exceptions.md |

## Purpose

Defines the Legal Order entity — an externally mandated withholding obligation attached to an employment record. Legal orders include child support, tax levies, creditor garnishments, bankruptcy orders, student loan garnishments, and other statutory or court-ordered withholdings. Legal orders are compliance-critical; all state transitions must be auditable and legally defensible.

---

## 1. Design Principles

- Legal orders are received from external authorities and must be validated before setup.
- Priority sequencing among concurrent orders must follow applicable federal and state rules.
- All order modifications, suspensions, and terminations must preserve historical versions.
- Remittance tracking must remain auditable and linkable to each payroll period.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Legal_Order_ID | UUID | Yes | System-generated. Immutable. |
| Employment_ID | UUID | Yes | Payroll anchor |
| Order_Type | Enum | Yes | See values below |
| Order_Status | Enum | Yes | References STATE-GAR; see values below |
| Issuing_Authority | String | Yes | Name of issuing court or agency |
| Jurisdiction_ID | UUID | Yes | Jurisdiction governing this order |
| Order_Reference_Number | String | Yes | Official case or order number |
| Order_Issue_Date | Date | Yes | Date issued by authority |
| Order_Effective_Date | Date | Yes | Date withholding must begin |
| Order_End_Date | Date | No | Null for open-ended orders |
| Calculation_Method | Enum | Yes | See values below |
| Withholding_Percentage | Decimal | No | For percentage-based orders |
| Flat_Amount | Decimal | No | For fixed-amount orders |
| Maximum_Amount | Decimal | No | Per-period or total cap |
| Minimum_Protected_Amount | Decimal | No | Minimum take-home pay to protect |
| Remittance_Frequency | Enum | Yes | EACH_PAYROLL, WEEKLY, MONTHLY |
| Payee_Name | String | Yes | Remittance recipient |
| Payee_Address | String | Yes | |
| Payment_Method | Enum | Yes | CHECK, ACH, EFT |
| Remittance_Reference_Number | String | No | Case reference for remittance |
| Priority_Sequence | Integer | No | Used when multiple orders are active |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Order_Type Values

| Value | Description |
|---|---|
| CHILD_SUPPORT | Court-ordered child support |
| TAX_LEVY | IRS or state tax levy |
| CREDITOR_GARNISHMENT | Creditor judgment |
| BANKRUPTCY | Bankruptcy court order |
| STUDENT_LOAN | Federal student loan garnishment |
| ADMINISTRATIVE_GARNISHMENT | Federal administrative garnishment |
| VOLUNTARY_ASSIGNMENT | Employee-authorised voluntary wage assignment |

---

## 4. Order_Status Values (references STATE-GAR)

| Value | STATE-GAR Reference | Description |
|---|---|---|
| RECEIVED | STATE-GAR-001 | Order received; not yet validated |
| PENDING_SETUP | STATE-GAR-002 | Validated; being configured |
| ACTIVE | STATE-GAR-003 | Withholding active |
| SUSPENDED | STATE-GAR-004 | Temporarily paused |
| SATISFIED | STATE-GAR-005 | Obligation fully met |
| TERMINATED | STATE-GAR-006 | Terminated by issuing authority |

---

## 5. Calculation_Method Values

| Value | Description |
|---|---|
| PERCENTAGE | Percentage of disposable earnings |
| FLAT_AMOUNT | Fixed dollar amount per period |
| LESSER_OF | Lesser of percentage or flat amount |
| TIERED | Tiered schedule based on income level |

---

## 6. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Legal Order → Employment | Many-to-one | |
| Legal Order → Jurisdiction | Many-to-one | Governs priority and calculation rules |
| Legal Order → Remittance Records | One-to-many | Each period's remittance is tracked |

---

## 7. Governance

- Legal orders must be validated before transitioning to PENDING_SETUP.
- Multiple concurrent orders must be prioritised per federal and state rules.
- Order modifications must preserve the prior version; historical records are never overwritten.
- All state transitions are audit-logged with timestamp and actor.

---

## 8. Related Architecture Models

| Model | Relevance |
|---|---|
| Garnishment_and_Legal_Order_Model | Full priority logic and remittance handling |
| Earnings_and_Deductions_Computation_Model | Disposable earnings calculation |
| Jurisdiction_and_Compliance_Rules_Model | Jurisdiction-specific priority rules |
