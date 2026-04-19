# Entity — Onboarding Plan

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Onboarding_Plan.md` |
| **Related Documents** | DATA/Entity_Employee.md, HRIS_Module_PRD.md §13, docs/STATE/STATE-ONB_Onboarding_Task.md |

## Purpose

Defines the Onboarding Plan and Onboarding Task entities. An Onboarding Plan coordinates the tasks required to make a new hire operationally ready. Blocking tasks must be completed before payroll activation is permitted.

---

## 1. Design Principles

- An Onboarding Plan is created for each new hire or rehire.
- Plans contain one or more tasks. Tasks are independently tracked.
- Blocking tasks prevent payroll activation when incomplete.
- Non-blocking tasks may remain open past the employment start date without preventing payroll.
- All task completions and waivers are audit-logged.

---

## 2. Onboarding Plan Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Onboarding_Plan_ID | UUID | Yes | System-generated. Immutable. |
| Employment_ID | UUID | Yes | The hire or rehire this plan supports |
| Plan_Template_ID | UUID | No | Template used to generate the plan |
| Plan_Status | Enum | Yes | See values below |
| Target_Start_Date | Date | Yes | Employee's planned first day |
| Completion_Date | Date | No | Date all blocking tasks were completed |
| Assigned_HR_Contact_ID | UUID | No | HR contact responsible for onboarding |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | System-generated |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Plan_Status Values

| Value | Description |
|---|---|
| CREATED | Plan initialised; tasks not yet started |
| IN_PROGRESS | At least one task is in progress or completed |
| BLOCKING_COMPLETE | All blocking tasks complete; payroll activation permitted |
| COMPLETE | All tasks complete or waived |
| CANCELLED | Plan cancelled (e.g., hire rescinded) |

---

## 4. Onboarding Task Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Task_ID | UUID | Yes | System-generated. Immutable. |
| Onboarding_Plan_ID | UUID | Yes | Parent plan |
| Task_Type | Enum | Yes | See values below |
| Task_Name | String | Yes | Display name |
| Task_Owner_Role | String | Yes | Role responsible for completing the task |
| Task_Owner_User_ID | UUID | No | Specific user assigned if known |
| Due_Date | Date | Yes | Target completion date |
| Completion_Date | Date | No | Actual completion date |
| Task_Status | Enum | Yes | References STATE-ONB; see values below |
| Blocking_Flag | Boolean | Yes | True if task blocks payroll activation |
| Waiver_Reason | String | No | Required if task is waived |
| Waived_By | UUID | No | User who approved the waiver |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | |

---

## 5. Task_Type Values

| Value | Description | Blocking Default |
|---|---|---|
| DOCUMENT_COMPLETION | I-9, W-4, employment agreement | Yes |
| IT_PROVISIONING | System access setup | No |
| EQUIPMENT_REQUEST | Hardware assignment | No |
| BENEFITS_ENROLLMENT | Initiate benefits enrollment | No |
| PAYROLL_PROFILE_SETUP | Configure payroll context and tax setup | Yes |
| TRAINING_ASSIGNMENT | Required compliance training | No |
| MANAGER_INTRODUCTION | First meeting with manager | No |
| FIRST_DAY_SCHEDULING | Schedule first day agenda | No |
| OTHER | Custom task | Configurable |

---

## 6. Task_Status Values (references STATE-ONB)

| Value | STATE-ONB Reference | Description |
|---|---|---|
| NOT_STARTED | STATE-ONB-001 | Created and assigned; not begun |
| IN_PROGRESS | STATE-ONB-002 | Actively being worked on |
| COMPLETED | STATE-ONB-003 | Finished |
| WAIVED | STATE-ONB-004 | Formally waived |
| OVERDUE | STATE-ONB-005 | Past due date; incomplete |

---

## 7. Payroll Activation Rule

Payroll activation is blocked while any task with Blocking_Flag = True is in status NOT_STARTED, IN_PROGRESS, or OVERDUE. Payroll activation is permitted when all blocking tasks are in COMPLETED or WAIVED status.

---

## 8. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Onboarding Plan → Employment | One-to-one | |
| Onboarding Plan → Tasks | One-to-many | |
| Task → Onboarding Plan | Many-to-one | |

---

## 9. Related Architecture Models

| Model | Relevance |
|---|---|
| Release_and_Approval_Model | Waiver approval workflow |
| Security_and_Access_Control_Model | Task owner role scoping |
