# Reporting_Hierarchy_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/architecture/core/Reporting_Hierarchy_Model.md` |
| **Domain** | Core |
| **Related Documents** | DATA/Entity_Employee.md, docs/architecture/core/Organizational_Structure_Model.md, docs/architecture/core/Employee_Event_and_Status_Change_Model.md, docs/architecture/governance/Security_and_Access_Control_Model.md |

## Purpose

Defines the people-reporting hierarchy — the Employment-to-Employment manager relationship that governs who reports to whom. This model is distinct from the organisational structure model, which defines the administrative hierarchy of org units. An employee's manager and their department's org unit parent are related but independent concepts.

---

## 1. Core Design Principles

The reporting hierarchy is Employment-to-Employment. Manager_Employment_ID on the Employment record points to the manager's Employment_ID, not their Person_ID. This ensures that when a manager changes roles or departs, the relationship can be cleanly managed through lifecycle events. Only the primary reporting relationship is supported in v1. Dotted-line and matrix reporting are deferred to a future release. The reporting hierarchy is effective-dated. Manager changes are lifecycle events, not direct field edits.

---

## 2. Reporting Relationship Definition

The reporting relationship is expressed as a single field on the Employment record:

| Field | Type | Notes |
|---|---|---|
| Manager_Employment_ID | UUID | References the Employment_ID of the direct manager. Null for top-of-hierarchy roles. |

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

---

## 5. Manager Termination Handling

When an employee with direct reports is terminated, the system must resolve the orphaned reporting relationships before the termination becomes effective.

**Behaviour:**
- System detects that the departing Employment_ID is referenced as Manager_Employment_ID by one or more active employments.
- EXC-HRS-001 (Direct Reports Without Manager) is raised as a Hold.
- HR admin must reassign all direct reports to a new manager before the termination event reaches Effective state.
- The termination workflow is blocked at STATE-WFL-004 (Approved) until all direct report reassignments are confirmed.

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

---

## 7. Manager Self-Service Scoping

The reporting hierarchy governs manager self-service access. A manager may view and initiate actions only for:
- Their direct reports (Manager_Employment_ID = their Employment_ID)
- Or, if configured, their full team tree (all recursive direct reports)

Cross-hierarchy access requires explicit role elevation per the Security_and_Access_Control_Model.

---

## 8. Constraints and Rules

- An employee may not be assigned as their own manager.
- A circular hierarchy (A reports to B, B reports to A) is not permitted and must be rejected at the point of change.
- Manager_Employment_ID must reference an active Employment record (Employment_Status = ACTIVE or ON_LEAVE).
- An employee may not be assigned a manager in a different Legal Entity unless explicitly permitted by configuration.

---

## 9. Relationship to Other Models

This model integrates with: Organizational_Structure_Model, Employee_Event_and_Status_Change_Model, Security_and_Access_Control_Model, Employee_Assignment_Model, Release_and_Approval_Model.
