# Entity — Assignment

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Assignment.md` |
| **Related Documents** | DATA/Entity_Employee.md, HRIS_Module_PRD.md §4, docs/architecture/core/Employee_Assignment_Model.md, docs/architecture/core/Plan_and_Rule_Model.md |

## Purpose

Defines the Assignment entity — the association of an Employment record to a Job, Position, Department, Location, and payroll plan at a point in time. Assignments are the bridge between HR identity and executable payroll logic. Assignments attach to Employment_ID, never to Person_ID.

---

## 1. Design Principles

- Assignments are effective-dated. Multiple assignments may exist across time for the same Employment_ID.
- Assignment resolution must be deterministic — given a Payroll_Context_ID and Period_ID, exactly one assignment (or a defined stack) must be resolvable.
- Historical assignments are preserved permanently. They are never deleted, only closed with an end date.
- Retroactive and future-dated assignments are supported.
- Rehire creates a new Employment_ID; historical assignments remain with the prior Employment_ID.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Assignment_ID | UUID | Yes | System-generated. Immutable. |
| Employment_ID | UUID | Yes | Payroll anchor |
| Job_ID | UUID | Yes | The job classification for this assignment |
| Position_ID | UUID | No | Optional; may be null if position management not in use |
| Department_ID | UUID | Yes | Primary department for cost allocation |
| Location_ID | UUID | Yes | Primary work location; drives tax jurisdiction |
| Payroll_Context_ID | UUID | Yes | Payroll group and processing context |
| Plan_ID | UUID | No | Payroll plan governing calculation logic |
| Assignment_Type | Enum | Yes | See values below |
| Assignment_Status | Enum | Yes | See values below |
| Assignment_Priority | Integer | No | Used for precedence when multiple assignments are active |
| Assignment_Start_Date | Date | Yes | Effective start date |
| Assignment_End_Date | Date | No | Null for currently active assignments |
| Created_By | UUID | Yes | User or system that created the record |
| Creation_Timestamp | Datetime | Yes | System-generated |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Assignment_Type Values

| Value | Description |
|---|---|
| PRIMARY | Primary assignment; used for standard payroll calculation |
| SECONDARY | Secondary concurrent assignment |
| TEMPORARY | Temporary assignment covering an absence or project |
| SUPPLEMENTAL | Supplemental assignment for additional earnings |
| OVERRIDE | Overrides a specific calculation attribute of the primary assignment |

---

## 4. Assignment_Status Values

| Value | Description |
|---|---|
| ACTIVE | Currently effective and in use |
| PENDING | Future-dated; not yet effective |
| CLOSED | End date has passed; retained for history |
| CANCELLED | Cancelled before becoming effective |

---

## 5. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Assignment → Employment | Many-to-one | All assignments key to Employment_ID |
| Assignment → Job | Many-to-one | |
| Assignment → Position | Many-to-one | Optional |
| Assignment → Org Unit (Department) | Many-to-one | |
| Assignment → Location | Many-to-one | Location drives jurisdiction resolution |
| Assignment → Payroll Context | Many-to-one | |
| Assignment → Plan | Many-to-one | Optional; governs calculation logic |

---

## 6. Effective Dating Rules

An assignment must have an Assignment_Start_Date. Assignment_End_Date may be null for the currently active assignment. Gaps between consecutive assignments are not permitted unless explicitly configured. Overlapping assignments of the same type and priority generate EXC-VAL-005.

---

## 7. Governance

- Assignments may only be created or modified through approved HR lifecycle events.
- Location_ID changes require a Work_State_Change event to trigger downstream tax jurisdiction updates.
- All assignment changes are audit-logged with timestamp and actor.

---

## 8. Related Architecture Models

| Model | Relevance |
|---|---|
| Employee_Assignment_Model | Full assignment resolution logic and priority rules |
| Employment_and_Person_Identity_Model | Identity anchoring — why assignments key to Employment_ID |
| Plan_and_Rule_Model | Plan resolution from assignment |
| Jurisdiction_and_Compliance_Rules_Model | Location drives jurisdiction |
