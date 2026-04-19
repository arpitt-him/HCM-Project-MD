# SPEC — Onboarding Workflow

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/SPEC/Onboarding_Workflow.md` |
| **Related Documents** | HRIS_Module_PRD.md §13, DATA/Entity_Onboarding_Plan.md, docs/STATE/STATE-ONB_Onboarding_Task.md, docs/architecture/core/Reporting_Hierarchy_Model.md, docs/architecture/governance/Release_and_Approval_Model.md |

## Purpose

Defines the implementation-ready specification for the onboarding workflow — plan creation, task assignment, blocking vs non-blocking task behaviour, integration touch points with downstream systems, rehire treatment, and exception handling. Extends the entity definition in `DATA/Entity_Onboarding_Plan.md` with operational logic.

---

## 1. Onboarding Plan Creation

An onboarding plan is created automatically when a HIRE or REHIRE lifecycle event reaches STATE-WFL-006 (Effective). Plan creation is system-triggered, not manually initiated.

### 1.1 Inputs

| Field | Source | Notes |
|---|---|---|
| Employment_ID | Hire/Rehire event | The new hire's Employment_ID |
| Target_Start_Date | Hire event Effective_Date | Drives task due dates |
| Hire_Type | HIRE or REHIRE | Determines task set — see §4 |
| Manager_Employment_ID | Employment record | Manager is assigned MANAGER_INTRODUCTION task ownership |
| Assigned_HR_Contact_ID | HR assignment rules | Configurable per org unit |
| Plan_Template_ID | Configuration | Based on Employment_Type and org unit |

### 1.2 Outputs

| Output | Description |
|---|---|
| Onboarding_Plan record | Created in CREATED status |
| Task records | Generated from template; due dates calculated from Target_Start_Date |
| Audit record | Plan creation logged with timestamp and source event |

### 1.3 Events Published

| Event | Trigger | Consumers |
|---|---|---|
| OnboardingPlanCreated | Plan creation | HR operations dashboard; task owner notification |
| OnboardingTaskAssigned | Each task created | Task owner notification |

---

## 2. Task Due Date Calculation

Task due dates are calculated relative to Target_Start_Date:

| Task_Type | Default Due Date | Notes |
|---|---|---|
| DOCUMENT_COMPLETION (I-9) | Target_Start_Date + 3 business days | Legal requirement |
| DOCUMENT_COMPLETION (W-4) | Target_Start_Date | Required before first payroll |
| PAYROLL_PROFILE_SETUP | Target_Start_Date − 5 business days | Must be complete before payroll run |
| BENEFITS_ENROLLMENT | Target_Start_Date + 30 days | Enrollment window |
| IT_PROVISIONING | Target_Start_Date − 2 business days | Ready before first day |
| EQUIPMENT_REQUEST | Target_Start_Date − 2 business days | |
| MANAGER_INTRODUCTION | Target_Start_Date | First day |
| TRAINING_ASSIGNMENT | Target_Start_Date + 14 days | |

All due dates are configurable per template.

---

## 3. Payroll Activation Gate

Payroll activation is gated on blocking task completion. The following task types are blocking by default:

- DOCUMENT_COMPLETION (I-9, W-4)
- PAYROLL_PROFILE_SETUP

Payroll activation is permitted when all blocking tasks reach STATE-ONB-003 (Completed) or STATE-ONB-004 (Waived).

**System behaviour:**
- When the last blocking task completes or is waived, the system publishes OnboardingBlockingTasksComplete.
- The Payroll module receives this event and activates the Employment_ID for inclusion in the next eligible payroll run.
- If a new hire's Target_Start_Date falls within an open payroll period and blocking tasks are not complete by the input cutoff, EXC-ONB-001 is raised.

---

## 4. Rehire Onboarding Treatment

Rehires receive a modified onboarding plan. Because the person has a prior employment history, certain tasks are abbreviated or omitted.

| Task_Type | New Hire | Rehire | Notes |
|---|---|---|---|
| DOCUMENT_COMPLETION (I-9) | Required — Blocking | Required if prior I-9 expired — Blocking | I-9 must be re-verified if > 3 years since last employment |
| DOCUMENT_COMPLETION (W-4) | Required — Blocking | Required — Blocking | New elections required regardless |
| PAYROLL_PROFILE_SETUP | Required — Blocking | Required — Blocking | New Employment_ID requires fresh setup |
| BENEFITS_ENROLLMENT | Required — Non-blocking | Required — Non-blocking | New enrollment period triggered |
| IT_PROVISIONING | Required — Non-blocking | Conditional | Omitted if systems access was not revoked |
| EQUIPMENT_REQUEST | Required — Non-blocking | Conditional | Omitted if equipment was retained |
| MANAGER_INTRODUCTION | Required — Non-blocking | Optional | Configurable |
| TRAINING_ASSIGNMENT | Required — Non-blocking | Conditional | Only mandatory training since last employment |

Rehire plan template is selected when Hire_Type = REHIRE on the triggering event.

---

## 5. Integration Touch Points

### 5.1 IT Provisioning

The IT_PROVISIONING task generates an external notification to the IT service management system (configurable endpoint). The notification carries:

| Field | Notes |
|---|---|
| Employment_ID | New hire identifier |
| Person_Name | For account creation |
| Target_Start_Date | System access required by |
| Manager_Employment_ID | For approval routing in IT system |
| Location | For system access scope |

The platform does not own IT provisioning outcomes. The IT_PROVISIONING task is marked complete by the task owner (IT team) in the platform, not automatically via IT system response. Future integration may support automated completion via callback.

### 5.2 Benefits Enrollment

The BENEFITS_ENROLLMENT task signals the Benefits module (future) to open an enrollment window for the new hire. The signal carries:

| Field | Notes |
|---|---|
| Employment_ID | |
| Enrollment_Window_Start | Target_Start_Date |
| Enrollment_Window_End | Target_Start_Date + 30 days (configurable) |
| Eligibility_Effective_Date | Target_Start_Date |

Benefits enrollment is not owned by the onboarding workflow. The task is marked complete when the employee submits elections or waives coverage.

### 5.3 Payroll Profile Setup

The PAYROLL_PROFILE_SETUP task requires an HR administrator to confirm:
- Payroll_Context_ID is assigned to the Employment record
- Tax withholding elections (W-4 and state) are on file
- Direct deposit or payment method is configured

This is a human-in-the-loop task. Completion is manual. It is blocking because missing payroll profile data generates EXC-CFG-005 (Calendar Not Defined) or EXC-TAX-002 (Missing Jurisdiction) on the first payroll run.

---

## 6. Exception Handling

### EXC-ONB-001

| Field | Detail |
|---|---|
| **Code** | EXC-ONB-001 |
| **Name** | Blocking Onboarding Tasks Incomplete at Payroll Cutoff |
| **Severity** | Hold |

**Condition:** A new hire's Employment_ID is within an open payroll period but one or more blocking onboarding tasks have not reached STATE-ONB-003 or STATE-ONB-004 by the payroll input cutoff.

**System Behaviour:** Employee excluded from the current payroll run. Hold raised in the exception queue. HR operations dashboard flags the incomplete tasks.

**Operator Action Required:** Complete or waive the blocking tasks before the next payroll run, or initiate an off-cycle run after tasks are complete.

---

### EXC-ONB-002

| Field | Detail |
|---|---|
| **Code** | EXC-ONB-002 |
| **Name** | Onboarding Plan Not Created for Active Employment |
| **Severity** | Warning |

**Condition:** An Employment record in ACTIVE status has no associated Onboarding_Plan record. This may occur if the hire event was processed outside the normal workflow or the plan creation step failed.

**System Behaviour:** Warning logged. Surfaced on HR operations dashboard.

**Operator Action Required:** Manually create an onboarding plan for the affected employment, or investigate whether the hire was processed correctly.

---

### EXC-ONB-003

| Field | Detail |
|---|---|
| **Code** | EXC-ONB-003 |
| **Name** | I-9 Re-Verification Required for Rehire |
| **Severity** | Hold |

**Condition:** A rehire's most recent I-9 document is either expired, missing, or more than 3 years old, requiring re-verification before employment can be activated.

**System Behaviour:** PAYROLL_PROFILE_SETUP task remains blocked. Payroll activation withheld. HR operations dashboard flags the I-9 status.

**Operator Action Required:** Collect and upload a new I-9 from the employee before activating payroll.

---

### EXC-ONB-004

| Field | Detail |
|---|---|
| **Code** | EXC-ONB-004 |
| **Name** | Onboarding Task Overdue — Manager Not Assigned |
| **Severity** | Warning |

**Condition:** The MANAGER_INTRODUCTION task is overdue and no Manager_Employment_ID is set on the new hire's employment record.

**System Behaviour:** Warning logged. Escalation alert generated to HR contact.

**Operator Action Required:** Assign a manager to the employment record via a MANAGER_CHANGE event, then reschedule the introduction task.

---

## 7. Onboarding Success Outputs

When all blocking tasks are complete:

| Output | Description |
|---|---|
| OnboardingBlockingTasksComplete event | Published to Payroll module to enable payroll activation |
| Plan_Status update | Set to BLOCKING_COMPLETE |
| HR dashboard update | New hire moved from "Pending Activation" to "Active" view |
| Audit record | Completion timestamp and final task completion details logged |

When all tasks are complete (blocking and non-blocking):

| Output | Description |
|---|---|
| Plan_Status update | Set to COMPLETE |
| Completion_Date | Set on Onboarding_Plan record |
| Onboarding completion included in reporting | Available in onboarding completion rate reports |
