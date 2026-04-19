# Entity — Employee (Employment)

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Employee.md` |
| **Related Documents** | DATA/Entity_Person.md, DATA/Entity_Payroll_Item.md, PRD-0200_Core_Entity_Model.md, docs/architecture/core/Employment_and_Person_Identity_Model.md, docs/architecture/core/Employee_Assignment_Model.md |

## Purpose

Defines the canonical Employment entity — the operational record representing the payroll-recognized employment relationship between a Person and an Employer. This is the primary anchor for payroll calculation, accumulation, and downstream processing.

> **Note on naming:** The platform uses "Employment" as the canonical entity name to distinguish it from the abstract Person. The terms "Employee" and "Employment" are used interchangeably in operational contexts but refer to the same entity.

---

## 1. Design Principles

- Employment_ID is the payroll and HR operational anchor. All downstream records (payroll results, accumulators, benefit enrollments) key to Employment_ID.
- A new Employment_ID is created at each hire, including rehires. Person_ID remains constant across rehires.
- Employment records are never deleted. Termination sets Employment_Status to Terminated/Closed.
- Concurrent employments (same Person, multiple employers or engagements) are supported, each with a distinct Employment_ID.
- All changes are effective-dated and historically preserved.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Employment_ID | UUID | Yes | System-generated. Immutable. Payroll anchor. |
| Person_ID | UUID | Yes | Foreign key to Person entity |
| Employer_ID | UUID | Yes | Foreign key to Legal Entity |
| Legal_Entity_ID | UUID | Yes | Payroll legal entity |
| Employee_Number | String | Yes | Operational/external-facing identifier |
| Employment_Type | Enum | Yes | See values below |
| Employment_Start_Date | Date | Yes | |
| Employment_End_Date | Date | No | Set at termination |
| Employment_Status | Enum | Yes | See values below |
| Full_or_Part_Time_Status | Enum | Yes | FULL_TIME / PART_TIME |
| Regular_or_Temporary_Status | Enum | Yes | REGULAR / TEMPORARY / SEASONAL |
| FLSA_Status | Enum | Yes | EXEMPT / NON_EXEMPT |
| Payroll_Context_ID | UUID | Yes | Links to payroll group and frequency |
| Primary_Work_Location_ID | UUID | Yes | Drives tax jurisdiction resolution |
| Primary_Department_ID | UUID | Yes | |
| Manager_Employment_ID | UUID | No | Direct manager reference |
| Creation_Timestamp | Datetime | Yes | System-generated |
| Last_Update_Timestamp | Datetime | Yes | System-generated |
| Last_Updated_By | String | Yes | Actor reference |

---

## 3. Employment_Type Values

| Value | Description |
|---|---|
| EMPLOYEE | Standard W-2 employee |
| CONTRACTOR | 1099 contractor (limited payroll scope) |
| INTERN | Internship engagement |
| SEASONAL | Seasonal engagement |

---

## 4. Employment_Status Values

| Value | Description |
|---|---|
| PENDING | Hire initiated, not yet effective |
| ACTIVE | Currently employed and payroll-eligible |
| ON_LEAVE | Active employment, currently on leave |
| SUSPENDED | Employment suspended pending investigation or action |
| TERMINATED | Employment ended; record preserved |
| CLOSED | Employment fully closed; all obligations settled |

Employment_Status governs payroll eligibility. Only ACTIVE and ON_LEAVE statuses generate payroll results in a standard run.

---

## 5. Rehire Handling

When a terminated employee is rehired:

- Person_ID remains unchanged
- A new Employment_ID is created
- The prior Employment record is preserved with its Terminated status
- Historical payroll results remain associated with the prior Employment_ID

This preserves historical payroll integrity while establishing a clean operational record for the new engagement.

---

## 6. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Employment → Person | Many-to-one | Each employment links to one Person |
| Employment → Legal Entity | Many-to-one | |
| Employment → Assignment | One-to-many | Job, position, department, location linkages |
| Employment → Compensation Record | One-to-many | Rate history |
| Employment → Payroll Result | One-to-many | All payroll outputs |
| Employment → Accumulator | One-to-many | Running totals |
| Employment → Document | One-to-many | Employment-scoped documents |
| Employment → Leave Request | One-to-many | |
| Employment → Employee Event | One-to-many | Lifecycle event history |

---

## 7. Governance

- Employment records may only be created through an approved Hire or Rehire workflow.
- Employment_Status changes require approved lifecycle events (not direct field edits).
- Compensation records are managed separately and referenced via the Compensation_and_Pay_Rate_Model.
- All Employment changes are audit-logged with timestamp and actor.

---

## 8. Related Architecture Models

| Model | Relevance |
|---|---|
| Employment_and_Person_Identity_Model | Defines the identity separation and anchoring rules |
| Employee_Event_and_Status_Change_Model | Governs lifecycle events and status transitions |
| Employee_Assignment_Model | Governs job, position, department, location linkages |
| Compensation_and_Pay_Rate_Model | Governs rate records and history |
| Payroll_Context_Model | Defines payroll group and processing context |
| Security_and_Access_Control_Model | Role-based access to employment records |
