# Entity — Position

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Position.md` |
| **Related Documents** | DATA/Entity_Job.md, DATA/Entity_Assignment.md, DATA/Entity_Org_Unit.md, HRIS_Module_PRD.md §8, docs/STATE/STATE-EMP_Employment_Lifecycle.md |

## Purpose

Defines the Position entity — a specific organisational headcount slot linked to a Job and an Org Unit. Positions represent approved roles within the organisational structure. Position management is optional — deployments may operate in Job-only mode.

---

## 1. Design Principles

- A position is a headcount slot, not a person. It may be open, filled, or frozen.
- Each position references exactly one Job.
- **A position's legal entity is determined by its Org_Unit_ID.** The org unit belongs to a legal entity; that entity ownership flows through to the position. Legal_Entity_ID is not stored directly on the position — it is derived via the org unit.
- **A position's Job_ID must reference a job belonging to the same legal entity as its Org_Unit.** Cross-entity position-to-job references are not permitted.
- Positions are effective-dated. History is preserved.
- Position management is optional. When not used, assignments reference Job directly.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Position_ID | UUID | Yes | System-generated. Immutable. |
| Job_ID | UUID | Yes | The job classification for this position |
| Org_Unit_ID | UUID | Yes | Department or location this position belongs to |
| Position_Title | String | No | Override title; if null, inherits from Job_Title |
| Headcount_Budget | Integer | No | Number of approved headcount for this position |
| Position_Status | Enum | Yes | References STATE-EMP-020 to 023; see values below |
| Effective_Start_Date | Date | Yes | |
| Effective_End_Date | Date | No | |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Position_Status Values (references STATE-EMP)

| Value | STATE-EMP Reference | Description |
|---|---|---|
| OPEN | STATE-EMP-020 | Available for filling |
| FILLED | STATE-EMP-021 | Currently occupied |
| FROZEN | STATE-EMP-022 | Exists but hiring suspended |
| CLOSED | STATE-EMP-023 | Eliminated |

---

## 4. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Position → Job | Many-to-one | |
| Position → Org Unit | Many-to-one | |
| Position → Assignments | One-to-many | Active assignments fill the position |

---

## 5. Governance

- Positions may only be closed if no active assignment occupies them (EXC-EMP rule).
- Position_Status transitions must follow STATE-EMP-020 to 023 valid paths.
- A position's Job_ID must belong to the same legal entity as the position's Org_Unit. Violations are rejected at the service layer.
- When the Jobs & Positions UI is filtered by legal entity, only jobs belonging to that entity are presented in the job picker for new positions.
- All position changes are audit-logged.

---

## 6. Related Architecture Models

| Model | Relevance |
|---|---|
| Organizational_Structure_Model | Position within org hierarchy |
| Employee_Assignment_Model | Assignment-to-position linkage |
