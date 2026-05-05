# Entity — Job

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Job.md` |
| **Related Documents** | DATA/Entity_Position.md, DATA/Entity_Assignment.md, HRIS_Module_PRD.md §8, docs/architecture/core/Organizational_Structure_Model.md |

## Purpose

Defines the Job entity — a role classification representing a type of work within the organisation. Jobs provide the FLSA classification, EEO category, and pay grade framework that govern compensation ranges and regulatory reporting.

---

## 1. Design Principles

- Jobs are classification objects, not headcount slots. A job may be filled by many employees.
- **Jobs are scoped to a Legal Entity.** Legal entities are distinct operating companies and frequently organise themselves differently — different titles, levels, grade structures, and FLSA designations for comparable work. Job definitions belong to the entity that owns them.
- Job_Code uniqueness is enforced within a Legal Entity, not globally. Two entities may carry the same code with different definitions.
- Jobs are effective-dated. Changes create new versions; history is preserved.
- FLSA_Classification on the job drives overtime eligibility for employees in that job.
- EEO_Category supports regulatory reporting.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Job_ID | UUID | Yes | System-generated. Immutable. |
| Legal_Entity_ID | UUID | Yes | The legal entity that owns this job definition. Jobs are not shared across entities. |
| Job_Code | String | Yes | Unique within the Legal Entity; not globally unique |
| Job_Title | String | Yes | Display title |
| Job_Family | String | No | Grouping for reporting and compensation bands |
| Job_Level | String | No | Level within the family (e.g., L1, Senior, Principal) |
| FLSA_Classification | Enum | Yes | See values below |
| EEO_Category | Enum | Yes | See values below |
| Job_Status | Enum | Yes | ACTIVE, INACTIVE |
| Effective_Start_Date | Date | Yes | |
| Effective_End_Date | Date | No | |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. FLSA_Classification Values

| Value | Description |
|---|---|
| EXEMPT | Exempt from FLSA overtime requirements |
| NON_EXEMPT | Subject to FLSA overtime requirements |
| INDEPENDENT_CONTRACTOR | Not an employee for FLSA purposes |

---

## 4. EEO_Category Values

| Value | Description |
|---|---|
| EXEC_SENIOR_OFFICIALS | Executive and Senior Level Officials and Managers |
| FIRST_MID_OFFICIALS | First / Mid-Level Officials and Managers |
| PROFESSIONALS | Professionals |
| TECHNICIANS | Technicians |
| SALES | Sales Workers |
| ADMIN_SUPPORT | Administrative Support Workers |
| CRAFT_WORKERS | Craft Workers |
| OPERATIVES | Operatives |
| LABORERS | Laborers and Helpers |
| SERVICE_WORKERS | Service Workers |

---

## 5. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Job → Legal Entity | Many-to-one | A job belongs to exactly one legal entity |
| Job → Positions | One-to-many | A job may have multiple position slots within the same entity |
| Job → Assignments | One-to-many | Employees are assigned to jobs scoped to their employing entity |

---

## 6. Governance

- Job changes require approval workflow completion.
- FLSA_Classification changes affect overtime eligibility for all employees currently in the job and must trigger a review of active assignments.
- Job_Code must be unique within its Legal Entity. Duplicate codes across entities are permitted and carry no system-level relationship.
- A job cannot be assigned to an employee whose Legal_Entity_ID differs from the job's Legal_Entity_ID.
- All job changes are audit-logged.

---

## 7. Related Architecture Models

| Model | Relevance |
|---|---|
| Organizational_Structure_Model | Job within org hierarchy |
| Overtime_and_Premium_Pay_Model | FLSA classification drives overtime rules |
