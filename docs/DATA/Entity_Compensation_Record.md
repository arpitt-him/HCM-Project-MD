# Entity — Compensation Record

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Compensation_Record.md` |
| **Related Documents** | DATA/Entity_Employee.md, HRIS_Module_PRD.md §10, docs/architecture/core/Compensation_and_Pay_Rate_Model.md |

## Purpose

Defines the Compensation Record entity — the pay rate and structure associated with an Employment record at a point in time. HRIS owns compensation records. Payroll consumes them. Changes are effective-dated and versioned; prior rates are never overwritten.

---

## 1. Design Principles

- Compensation records are effective-dated and versioned. A change creates a new record; the prior record is closed.
- All compensation records attach to Employment_ID, not Person_ID.
- An employee may carry multiple simultaneous active rates (e.g., base salary plus shift differential).
- Rate changes require approval workflow completion before becoming effective.
- Retroactive rate changes must generate downstream recalculation signals to the Payroll module.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Compensation_ID | UUID | Yes | System-generated. Immutable. |
| Employment_ID | UUID | Yes | Payroll anchor |
| Rate_Type | Enum | Yes | See values below |
| Base_Rate | Decimal | Yes | The rate amount |
| Rate_Currency | String | Yes | ISO 4217; defaults to USD |
| Annual_Equivalent | Decimal | No | System-calculated from Base_Rate and Pay_Frequency |
| Pay_Frequency | Enum | Yes | WEEKLY, BIWEEKLY, SEMI_MONTHLY, MONTHLY |
| Effective_Start_Date | Date | Yes | |
| Effective_End_Date | Date | No | Null for currently active rate |
| Compensation_Status | Enum | Yes | See values below |
| Change_Reason_Code | String | Yes | Must reference a valid reason code |
| Approval_Status | Enum | Yes | PENDING, APPROVED, REJECTED |
| Approved_By | UUID | No | User who approved the change |
| Approval_Timestamp | Datetime | No | |
| Primary_Rate_Flag | Boolean | Yes | True if this is the primary rate for the employment |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | System-generated |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Rate_Type Values

| Value | Description |
|---|---|
| HOURLY | Per-hour rate; multiplied by worked hours |
| SALARY | Fixed annual or periodic salary |
| COMMISSION | Commission-based; typically externally calculated |
| CONTRACT | Fixed contract rate |
| DIFFERENTIAL | Supplemental rate applied on top of base (e.g., shift differential) |

---

## 4. Compensation_Status Values

| Value | Description |
|---|---|
| PENDING | Awaiting approval |
| ACTIVE | Currently effective and in use by payroll |
| CLOSED | End date passed; retained for history |
| CANCELLED | Cancelled before becoming effective |
| SUPERSEDED | Replaced by a newer compensation record |

---

## 5. Annual Equivalent Calculation

| Rate_Type | Calculation |
|---|---|
| SALARY (annual) | Base_Rate directly |
| SALARY (per period) | Base_Rate × periods per year |
| HOURLY | Base_Rate × standard hours per year (configurable) |
| DIFFERENTIAL | Not applicable — supplemental only |

---

## 6. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Compensation Record → Employment | Many-to-one | |
| Compensation Record → Change Reason | Many-to-one | Must reference valid reason code |
| Compensation Record → Approver | Many-to-one | Optional if auto-approved |

---

## 7. Governance

- Compensation records may only be created or modified through approved Compensation Change workflow events.
- Direct field edits outside the workflow are not permitted.
- Retroactive compensation changes generate EXC-VAL-014 and must be confirmed by the Payroll module before taking effect.
- All compensation record changes are audit-logged with timestamp and actor.

---

## 8. Related Architecture Models

| Model | Relevance |
|---|---|
| Compensation_and_Pay_Rate_Model | Full rate resolution logic and multiple rate handling |
| Employee_Event_and_Status_Change_Model | Compensation change event structure |
| Correction_and_Immutability_Model | Rate history preservation rules |
