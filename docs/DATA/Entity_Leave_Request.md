# Entity — Leave Request

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Leave_Request.md` |
| **Related Documents** | DATA/Entity_Employee.md, HRIS_Module_PRD.md §11, docs/STATE/STATE-LEV_Leave_Request.md, docs/architecture/core/Leave_and_Absence_Management_Model.md |

## Purpose

Defines the Leave Request entity — a formal request for employee absence with type, duration, approval state, and payroll impact signals. HRIS owns leave requests and communicates leave state to the Payroll module.

---

## 1. Design Principles

- Leave requests are owned by HRIS. Payroll consumes leave signals but does not own leave state.
- Each leave request has a defined type, status lifecycle, and payroll impact classification.
- Leave balances are tracked separately via accrual records and updated in alignment with payroll cycles.
- Leave state drives payroll earnings treatment — paid leave generates earnings substitution; unpaid leave generates earnings suppression.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Leave_Request_ID | UUID | Yes | System-generated. Immutable. |
| Employment_ID | UUID | Yes | Payroll anchor |
| Leave_Type | Enum | Yes | See values below |
| Request_Date | Date | Yes | Date employee submitted the request |
| Leave_Start_Date | Date | Yes | First day of leave |
| Leave_End_Date | Date | Yes | Last day of leave (estimated if open-ended) |
| Actual_Return_Date | Date | No | Populated on Return to Work event |
| Leave_Status | Enum | Yes | References STATE-LEV; see values below |
| Leave_Reason_Code | String | Yes | Must reference a valid reason code |
| Payroll_Impact_Type | Enum | Yes | See values below |
| Leave_Balance_Impact | Decimal | No | Hours or days deducted from balance |
| Approved_By | UUID | No | User who approved the request |
| Approval_Timestamp | Datetime | No | |
| HR_Contact_ID | UUID | No | Assigned HR contact for compliance tracking |
| FMLA_Eligible_Flag | Boolean | No | True if leave qualifies under FMLA |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | System-generated |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Leave_Type Values

| Value | Description |
|---|---|
| PTO | Paid Time Off |
| VACATION | Vacation leave |
| SICK | Sick leave |
| PERSONAL | Personal leave |
| LOA | General Leave of Absence |
| FMLA | Family and Medical Leave Act |
| STD | Short-Term Disability |
| LTD | Long-Term Disability |
| MILITARY | Military leave |
| JURY_DUTY | Jury duty |
| HOLIDAY | Holiday leave |

---

## 4. Leave_Status Values (references STATE-LEV)

| Value | STATE-LEV Reference | Description |
|---|---|---|
| REQUESTED | STATE-LEV-001 | Submitted; awaiting decision |
| APPROVED | STATE-LEV-002 | Approved; not yet started |
| DENIED | STATE-LEV-003 | Rejected |
| SCHEDULED | STATE-LEV-004 | Confirmed for future date |
| ACTIVE | STATE-LEV-005 | Employee currently on leave |
| COMPLETED | STATE-LEV-006 | Leave ended; employee returned |
| CANCELLED | STATE-LEV-007 | Withdrawn before activation |

---

## 5. Payroll_Impact_Type Values

| Value | Payroll Treatment |
|---|---|
| PAID_SUBSTITUTION | Generates earnings substitution signal to Payroll |
| UNPAID_SUPPRESSION | Generates earnings suppression signal to Payroll |
| DISABILITY_PAY | Generates special pay code signal to Payroll |
| NO_IMPACT | No payroll earnings impact |

---

## 6. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Leave Request → Employment | Many-to-one | |
| Leave Request → Leave Type | Many-to-one | Governs accrual and payroll treatment |
| Leave Request → Approver | Many-to-one | |

---

## 7. Governance

- Leave requests are created through the leave request workflow; direct creation outside workflow is not permitted.
- Leave Status may only advance through valid STATE-LEV transitions.
- Payroll impact signals are generated automatically when leave enters ACTIVE status.
- All leave record changes are audit-logged with timestamp and actor.

---

## 8. Related Architecture Models

| Model | Relevance |
|---|---|
| Leave_and_Absence_Management_Model | Full leave lifecycle and payroll impact rules |
| Accrual_and_Entitlement_Model | Balance tracking and carryover rules |
| Employee_Event_and_Status_Change_Model | Return to Work event handling |
