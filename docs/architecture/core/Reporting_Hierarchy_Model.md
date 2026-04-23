# Reporting_Hierarchy_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/architecture/core/Reporting_Hierarchy_Model.md` |
| **Domain** | Core |
| **Related Documents** | DATA/Entity_Employee.md, docs/architecture/core/Organizational_Structure_Model.md, docs/architecture/core/Employee_Event_and_Status_Change_Model.md, docs/architecture/governance/Security_and_Access_Control_Model.md |

## Purpose

Defines the people-reporting hierarchy — the Employment-to-Employment manager relationship that governs who reports to whom.  This model is distinct from the organisational structure model, which defines the administrative hierarchy of org units. An employee's manager and their department's org unit parent are related but independent concepts.

---

## 1. Core Design Principles

The reporting hierarchy is Employment-to-Employment. Manager_Employment_ID on the Employment record points to the manager's Employment_ID, not their Person_ID. This ensures that when a manager changes roles or departs, the relationship can be cleanly managed through lifecycle events. Only the primary reporting relationship is supported in v1. Dotted-line and matrix reporting are deferred to a future release. The reporting hierarchy is effective-dated. Manager changes are lifecycle events, not direct field edits.

---

### 1.1 Reporting Lineage Principle

Reporting relationships shall remain historically reconstructable.

Manager changes shall preserve:

- prior Manager_Employment_ID
- new Manager_Employment_ID
- effective date of change
- originating lifecycle event reference

The reporting hierarchy must support point-in-time reconstruction for:

- audit review
- workflow reconstruction
- access-control evaluation
- historical org chart rendering

Silent overwrite of historical reporting relationships is not permitted.

---

## 2. Reporting Relationship Definition

The reporting relationship is expressed as a single field on the Employment record:

| Field | Type | Notes |
|---|---|---|
| Manager_Employment_ID | UUID | References the Employment_ID of the direct manager. Null for top-of-hierarchy roles. |

Reporting relationship state shall also preserve supporting lineage attributes, including:

- Effective_Start_Date
- Effective_End_Date
- Source_Event_ID
- Relationship_Status

These attributes support effective-dated hierarchy reconstruction without changing the v1 primary relationship model.

This field is populated at hire and updated via MANAGER_CHANGE lifecycle events.

---

## 3. Hierarchy Traversal

The reporting hierarchy is a tree structure:

- Each Employment node has at most one Manager_Employment_ID (one parent).
- A manager may have many direct reports (one-to-many children).
- The hierarchy must be acyclic — an employee cannot be their own ancestor.
- Top-of-hierarchy roles (e.g., CEO) have Manager_Employment_ID = null.

Traversal supports:
- Direct reports list (one level down)
- Full team tree (recursive, all levels down)
- Management chain (path from employee to root)
- Span of control (count of direct and indirect reports)

All hierarchy traversal shall be resolved as of an effective date.

Traversal logic shall not assume current-state hierarchy when historical rendering, replay, audit, or workflow review requires point-in-time hierarchy interpretation.

---

## 4. Lifecycle Event Integration

Reporting hierarchy changes are managed exclusively through lifecycle events:

| Event Type | Effect on Hierarchy |
|---|---|
| HIRE | Manager_Employment_ID set at time of hire via onboarding workflow |
| MANAGER_CHANGE | Manager_Employment_ID updated; prior manager relationship preserved in event history |
| DEPARTMENT_TRANSFER | May trigger a MANAGER_CHANGE if the new department has a different manager |
| TERMINATION (manager) | All direct reports of the departing manager must be reassigned; generates EXC-HRS-001 if not resolved before termination becomes effective |
| REHIRE | New Employment_ID created; Manager_Employment_ID must be set as part of the rehire workflow |

All hierarchy-changing lifecycle events shall remain traceable to governed approval and workflow history where applicable.

Hierarchy changes must preserve both the prior and resulting reporting chain state.

---

## 5. Manager Termination Handling

When an employee with direct reports is terminated, the system must resolve the orphaned reporting relationships before the termination becomes effective.

**Behaviour:**
- System detects that the departing Employment_ID is referenced as Manager_Employment_ID by one or more active employments.
- EXC-HRS-001 (Direct Reports Without Manager) is raised as a Hold.
- HR admin must reassign all direct reports to a new manager before the termination event reaches Effective state.
- The termination workflow is blocked at STATE-WFL-004 (Approved) until all direct report reassignments are confirmed.

Manager reassignment actions shall record:

- prior Manager_Employment_ID
- replacement Manager_Employment_ID
- reassignment effective date
- approving actor where required

Reassignment history must remain queryable after termination is completed.

---

## 6. Org Chart Data Structure

The org chart is a derived view of the reporting hierarchy, not a stored entity. It is computed on demand from Manager_Employment_ID values across all active Employment records.

Org chart node attributes (derived):

| Attribute | Source |
|---|---|
| Employment_ID | Employment record |
| Display_Name | Person.Legal_First_Name + Legal_Last_Name |
| Job_Title | Assignment.Job_ID → Job.Job_Title |
| Department | Assignment.Department_ID → Org_Unit.Org_Unit_Name |
| Location | Assignment.Location_ID → Org_Unit.Org_Unit_Name |
| Direct_Report_Count | Count of Employment records where Manager_Employment_ID = this node |
| Manager_Employment_ID | Employment record |

Org chart resolution must respect effective dates — a point-in-time org chart must use the manager relationships effective on the requested date.

Org chart rendering shall remain deterministic for a requested effective date.

Later manager changes shall not reinterpret previously rendered historical org chart states.

---

## 7. Manager Self-Service Scoping

The reporting hierarchy governs manager self-service access. A manager may view and initiate actions only for:
- Their direct reports (Manager_Employment_ID = their Employment_ID)
- Or, if configured, their full team tree (all recursive direct reports)

Cross-hierarchy access requires explicit role elevation per the Security_and_Access_Control_Model.

Manager self-service scoping shall evaluate hierarchy state using the effective relationship state applicable to the requested operation.

Where historical workflow review is performed, access evaluation may require point-in-time hierarchy resolution.

---

## 8. Constraints and Rules

- An employee may not be assigned as their own manager.
- A circular hierarchy (A reports to B, B reports to A) is not permitted and must be rejected at the point of change.
- Manager_Employment_ID must reference an active Employment record (Employment_Status = ACTIVE or ON_LEAVE).
- An employee may not be assigned a manager in a different Legal Entity unless explicitly permitted by configuration.
- Manager_Employment_ID changes must be effective-dated and lifecycle-driven rather than direct ad hoc mutation.
- Hierarchy validation must preserve acyclic structure across both current-state and effective-dated future-state changes.

---

### 8.1 Deterministic Hierarchy Reconstruction

The reporting hierarchy shall support deterministic reconstruction for any requested effective date.

Deterministic reconstruction shall preserve:

- manager chain
- direct report relationships
- top-of-hierarchy identification
- legal-entity boundary interpretation
- access-scoping implications where applicable

Historical hierarchy reconstruction shall use effective-dated relationship state rather than current-state values.

---

## 9. Dependencies

This model depends on:

- Employment_and_Person_Identity_Model
- Employee_Event_and_Status_Change_Model
- Employee_Assignment_Model
- Organizational_Structure_Model
- Security_and_Access_Control_Model
- Release_and_Approval_Model

---

## 10. Relationship to Other Models

This model integrates with:

- Employment_and_Person_Identity_Model
- Employee_Event_and_Status_Change_Model
- Employee_Assignment_Model
- Organizational_Structure_Model
- Security_and_Access_Control_Model
- Release_and_Approval_Model
- Operational_Reporting_and_Analytics_Model
- Run_Visibility_and_Dashboard_Model
