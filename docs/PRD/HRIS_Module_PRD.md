# HRIS Module PRD

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Module Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/PRD/HRIS_Module_PRD.md` |
| **Date** | April 2026 |
| **Related Documents** | PRD-0000_Core_Vision, PRD-0100_Architecture_Principles, PRD-0200_Core_Entity_Model, PRD-0700_Workflow_Framework, PRD-0800_Validation_Framework, ADR-001_Event_Driven_Architecture, DATA/Entity_Person.md, DATA/Entity_Employee.md |

## Purpose

Defines the requirements for the HRIS module — the authoritative system of record for people, employment relationships, organisational structure, and HR lifecycle events across the HCM platform. HRIS is the upstream source of truth for Payroll and all future downstream modules.

This document is a self-contained module specification. It inherits and applies the platform-level principles defined in `PRD-0100_Architecture_Principles.md` without repeating or modifying them. It does not cover payroll calculation, benefits administration, or any other module's internal behaviour.

---

## Section Map

| § | Section | What it covers |
|---|---|---|
| 1 | Module Vision and Strategic Purpose | Why this module exists; its role in the platform |
| 2 | Module Scope | In scope, out of scope, and boundary with Payroll |
| 3 | Inherited Architectural Principles | Platform principles as applied to HRIS |
| 4 | Core Entity Model | Primary HRIS entities and identity anchoring |
| 5 | Person Record Model | Person attributes, status values, persistence rules |
| 6 | Employment Record Model | Employment attributes, types, status values |
| 7 | Organisational Structure Model | Org unit types, hierarchy rules, legal entity and location attributes |
| 8 | Job and Position Model | Job classification and position slot definitions |
| 9 | Employee Lifecycle Event Model | Event types, attributes, workflow states, retroactive handling |
| 10 | Compensation Record Model | Rate types, change rules, multiple rate support |
| 11 | Leave and Absence Management Model | Leave types, request lifecycle, payroll impact signals |
| 12 | Document Storage Model | Supported document types, attributes, governance |
| 13 | Onboarding Workflow Model | Task types, blocking vs non-blocking tasks |
| 14 | Self-Service Model | Manager, HR administrator, and employee self-service capabilities |
| 15 | Data Intake Model | Supported intake methods, validation requirements, batch rules |
| 16 | Approval Workflow Model | Workflow states, applicability, configuration |
| 17 | Validation and Exception Framework | Exception categories, examples, routing rules |
| 18 | Reporting and Analytics Support | Operational reports, workforce analytics feeds, constraints |
| 19 | Integration with Downstream Modules | Payroll, Benefits, T&A, Recruiting integration patterns |
| 20 | Architecture Model Dependencies | Which platform architecture models govern HRIS behaviour |
| 21 | Future Expansion Considerations | Out-of-scope capabilities planned for later phases |

---

## 1. Module Vision and Strategic Purpose

**REQ-HRS-001**
The HRIS module shall establish and own the canonical Person and Employment identity record for the platform.

**REQ-HRS-002**
The HRIS module shall serve as the upstream source of truth for Payroll, Benefits, Time & Attendance, and all downstream modules.

**REQ-HRS-003**
The HRIS module shall support the full employee lifecycle from onboarding through termination and rehire.

**REQ-HRS-004**
The HRIS module shall enable manager and HR administrator self-service for record management and lifecycle events.

**REQ-HRS-005**
The HRIS module shall maintain complete, auditable, effective-dated history of all HR data changes.

**REQ-HRS-006**
The HRIS module shall support multi-employer, multi-legal-entity, and PEO-style operating environments.

**REQ-HRS-007**
Initial scope is U.S.-based employment structures. Multi-country extensibility is a design constraint, not an initial deliverable.

---

## 2. Module Scope

### In Scope (v1)

- Person and employment record management
- Organizational structure management (legal entities, departments, locations, cost centers)
- Job and position management
- Employee lifecycle event processing (hire, rehire, transfer, status change, termination)
- Compensation record management (rate establishment and history)
- Leave and absence request management
- Document storage and management
- Onboarding workflow support
- Manager and HR administrator self-service
- Employee data intake (manual entry, batch import, API)
- Reporting and workforce analytics feeds

### Out of Scope (v1)

- Payroll calculation and processing (owned by Payroll module)
- Benefits plan configuration and enrollment processing (owned by Benefits module)
- Recruiting and applicant tracking
- Performance management
- Learning and development
- Time entry and scheduling (owned by Time & Attendance module)
- Multi-country payroll structures

### Boundary with Payroll Module

**REQ-HRS-010**
HRIS shall be the system of record for identity, employment, compensation rates, and lifecycle events. Payroll shall consume HRIS data but shall not own it.

**REQ-HRS-011**
Changes in HRIS shall trigger downstream effects in Payroll through the event model. HRIS shall not calculate pay, generate checks, or manage accumulators.

**REQ-HRS-012**
The Payroll module shall not write back to HRIS person or employment records.

---

## 3. Inherited Architectural Principles

The HRIS module inherits and applies all principles from PRD-0100_Architecture_Principles:

**REQ-HRS-015**
HRIS shall be independently deployable. Downstream modules shall not require HRIS to be co-deployed, but shall degrade gracefully when HRIS data is absent.

**REQ-HRS-016**
All meaningful HR changes shall be represented as events. Events are the integration contract between HRIS and downstream modules.

**REQ-HRS-017**
All HR records shall support effective start and end dates. Point-in-time resolution shall be deterministic.

**REQ-HRS-018**
HR changes shall follow configurable approval workflows before becoming effective.

**REQ-HRS-019**
All record changes shall be preserved historically. Silent overwrites are not permitted.

---

## 4. Core Entity Model

Primary HRIS Entities:

- Person: The human being. Owns legal identity, contact, and biographical attributes.
- Employment: The employment relationship between a Person and an Employer.
- Employment Record: Historical record of an employment period.
- Job: A defined role classification within the organization.
- Position: A specific organizational slot that may be filled by an employee.
- Assignment: The association of an Employment to a Job, Position, Department, and Location.
- Compensation Record: The pay rate and structure associated with an Employment.
- Org Unit: A node in the organizational hierarchy (Legal Entity, Division, Department, Location, Cost Center).
- Leave Request: A formal request for absence, with type, duration, and approval state.
- Document: An HR document associated with a Person or Employment (I-9, W-4, offer letter, etc.).
- Onboarding Task: A unit of work in a new hire onboarding workflow.

**REQ-HRS-020**
Person_ID shall be the enduring human identity key. Employment_ID shall be the payroll and HR operational anchor. All downstream module records shall key to Employment_ID, not Person_ID.

---

## 5. Person Record Model

**REQ-HRS-030**
Person records shall persist across all employment episodes. A terminated employee shall retain their Person record.

**REQ-HRS-031**
The National Identifier / SSN field shall be stored encrypted and access-controlled per the Security_and_Access_Control_Model.

**REQ-HRS-032**
Changes to legal name, national identifier, or date of birth shall require HR administrator authorisation.

Core Person attributes: Person_ID, Legal_First_Name, Legal_Last_Name, Preferred_Name (optional), Date_of_Birth, National_Identifier / SSN (secured), Gender (optional, self-identified), Pronouns (optional), Contact_Attributes, Emergency_Contact_Attributes, Person_Status.

Person_Status values:

| STATE-EMP-001 | Active | Has at least one active Employment record |
|---|---|---|
| STATE-EMP-002 | Inactive | No active Employment; record retained |
| STATE-EMP-003 | Deceased | Record preserved for legal purposes |
| STATE-EMP-004 | Restricted | Access-restricted; reason managed by HR |

---

## 6. Employment Record Model

**REQ-HRS-040**
Employment records shall be created at hire and closed at termination.

**REQ-HRS-041**
Rehire shall create a new Employment_ID under the same Person_ID. Historical employment records shall remain associated with their original Employment_ID.

**REQ-HRS-042**
Concurrent employments for the same Person shall be supported, each with a distinct Employment_ID.

Core Employment attributes: Employment_ID, Person_ID, Employer_ID, Legal_Entity_ID, Employee_Number, Employment_Type, Employment_Start_Date, Employment_End_Date (optional), Employment_Status, Full_or_Part_Time_Status, Regular_or_Temporary_Status, Payroll_Context_ID, Primary_Work_Location_ID, Primary_Department_ID, FLSA_Status.

Employment_Type values: Employee, Contractor, Intern, Seasonal.

Employment_Status values:

| STATE-EMP-010 | Pending | Hire initiated, not yet effective |
|---|---|---|
| STATE-EMP-011 | Active | Currently employed and payroll-eligible |
| STATE-EMP-012 | On Leave | Active employment, currently on leave |
| STATE-EMP-013 | Suspended | Employment suspended pending action |
| STATE-EMP-014 | Terminated | Employment ended; record preserved |
| STATE-EMP-015 | Closed | Employment fully closed; all obligations settled |

---

## 7. Organizational Structure Model

**REQ-HRS-050**
The platform shall support the following Org Unit types: Legal Entity, Division, Business Unit, Department, Cost Center, Location, Region.

**REQ-HRS-051**
Org unit hierarchies shall be parent-child and must be acyclic. Each unit may have one parent and multiple children.

**REQ-HRS-052**
All org unit changes shall be effective-dated and historically preserved.

**REQ-HRS-053**
Rollup relationships shall be deterministic for reporting and payroll aggregation.

**REQ-HRS-054**
Location records shall include State_Code and Locality_Code to support tax jurisdiction resolution.

Org Unit attributes: Org_Unit_ID, Org_Unit_Type, Org_Unit_Code, Org_Unit_Name, Parent_Org_Unit_ID, Effective_Start_Date, Effective_End_Date, Org_Status.

Legal Entity additional attributes: Tax_Registration_Number, Country_Code, State_of_Incorporation.

Location additional attributes: Full address, State_Code, Locality_Code, Work_Location_Type (Office / Remote / Hybrid).

---

## 8. Job and Position Model

**REQ-HRS-060**
The platform shall support Job definitions representing role classifications with FLSA and EEO attributes.

**REQ-HRS-061**
The platform shall support Position definitions representing specific organisational slots linked to a Job and Org Unit.

**REQ-HRS-062**
Position management shall be optional. Deployments may operate with Job-only structures where position management is not required.

Job attributes: Job_ID, Job_Code, Job_Title, Job_Family, Job_Level, FLSA_Classification, EEO_Category, Effective_Start_Date, Effective_End_Date.

Position attributes: Position_ID, Job_ID, Org_Unit_ID, Position_Title (optional), Headcount_Budget, Position_Status, Effective_Start_Date, Effective_End_Date.

Position_Status values:

| STATE-EMP-020 | Open | Position unfilled and available |
|---|---|---|
| STATE-EMP-021 | Filled | Position occupied |
| STATE-EMP-022 | Frozen | Position exists but hiring suspended |
| STATE-EMP-023 | Closed | Position eliminated |

---

## 9. Employee Lifecycle Event Model

**REQ-HRS-070**
The platform shall support the following lifecycle event types: HIRE, REHIRE, TERMINATION, VOLUNTARY_RESIGNATION, LEAVE_OF_ABSENCE, RETURN_TO_WORK, STATUS_CHANGE, COMPENSATION_CHANGE, JOB_CHANGE, POSITION_CHANGE, LOCATION_TRANSFER, DEPARTMENT_TRANSFER, WORK_STATE_CHANGE, LEGAL_ENTITY_TRANSFER, MANAGER_CHANGE.

**REQ-HRS-071**
Each event shall carry separate effective dates for Payroll, Benefits, and Tax domains, allowing downstream modules to apply changes on their own schedules.

**REQ-HRS-072**
Events entered after their effective date shall carry a Retroactive_Flag. Retroactive events shall not silently alter historical records. Affected downstream periods shall be identified and routed for correction processing.

**REQ-HRS-073**
Event sequencing rules shall prevent invalid state transitions. Examples: Return to Work requires a prior active Leave of Absence; Rehire requires a prior Termination on the same Person_ID.

Core event attributes: Employee_Event_ID, Person_ID, Employment_ID, Event_Type, Event_Date, Effective_Date, Recorded_Date, Event_Status, Event_Reason_Code, Initiated_By, Approved_By, Source_Context_ID.

Event workflow states:

| STATE-WFL-001 | Draft | Initiated but not submitted |
|---|---|---|
| STATE-WFL-002 | Submitted | Submitted for review |
| STATE-WFL-003 | Pending Approval | Under active review |
| STATE-WFL-004 | Approved | Approved, awaiting effective date |
| STATE-WFL-005 | Effective | Applied to records |
| STATE-WFL-006 | Rejected | Returned without approval |
| STATE-WFL-007 | Cancelled | Withdrawn before completion |

---

## 10. Compensation Record Model

**REQ-HRS-080**
HRIS shall own compensation rate records. Payroll shall consume them but shall not own or modify them.

**REQ-HRS-081**
Compensation changes shall be effective-dated and versioned. Prior rates shall be preserved and accessible for retroactive payroll processing.

**REQ-HRS-082**
Rate changes shall require approval workflow completion before becoming effective.

**REQ-HRS-083**
Retroactive rate changes shall generate downstream recalculation events routed to Payroll.

**REQ-HRS-084**
Employees may carry multiple active rates simultaneously (e.g., base salary plus shift differential). Rate resolution precedence is governed by the Compensation_and_Pay_Rate_Model.

Core Compensation attributes: Compensation_ID, Employment_ID, Rate_Type, Base_Rate, Rate_Currency, Annual_Equivalent (calculated), Pay_Frequency, Effective_Start_Date, Effective_End_Date, Compensation_Status, Change_Reason_Code, Approval_Status.

Rate_Type values: HOURLY, SALARY, COMMISSION, CONTRACT.

---

## 11. Leave and Absence Management Model

**REQ-HRS-090**
The platform shall support the following leave types: Paid Time Off (PTO), Vacation, Sick Leave, Personal Leave, Leave of Absence (LOA), Family and Medical Leave (FMLA), Short-Term Disability, Long-Term Disability, Military Leave, Jury Duty, Holiday Leave.

**REQ-HRS-091**
Accrual rates and frequencies shall be configurable per leave type.

**REQ-HRS-092**
Carryover rules shall be configurable per leave type and jurisdiction.

**REQ-HRS-093**
Paid leave shall generate earnings substitution signals to Payroll.

**REQ-HRS-094**
Unpaid leave shall generate earnings suppression signals to Payroll.

**REQ-HRS-095**
Disability leave shall generate special pay code signals to Payroll.

**REQ-HRS-096**
Payroll shall not calculate leave earnings independently of HRIS leave state.

Leave Request attributes: Leave_Request_ID, Employment_ID, Leave_Type, Request_Date, Leave_Start_Date, Leave_End_Date, Leave_Status, Leave_Reason_Code, Approved_By, Leave_Balance_Impact.

Leave status lifecycle:

| STATE-LEV-001 | Requested | Leave submitted, awaiting decision |
|---|---|---|
| STATE-LEV-002 | Approved | Leave approved |
| STATE-LEV-003 | Denied | Leave request rejected |
| STATE-LEV-004 | Scheduled | Approved and scheduled for future date |
| STATE-LEV-005 | Active | Employee currently on leave |
| STATE-LEV-006 | Completed | Leave ended, employee returned |
| STATE-LEV-007 | Cancelled | Leave withdrawn before activation |

---

## 12. Document Storage Model

**REQ-HRS-100**
The platform shall support storage and management of the following document types: I-9, W-4, State tax withholding forms, Offer Letter, Employment Agreement, Non-Disclosure Agreement, Power of Attorney, Licenses and Certifications, Performance Documentation, Disciplinary Records.

**REQ-HRS-101**
All documents shall be versioned and date-stamped. Prior versions shall be retained and accessible.

**REQ-HRS-102**
Expiration tracking shall support compliance alerting (e.g., I-9 re-verification deadlines).

**REQ-HRS-103**
Document access shall be governed by role and employment scope consistent with the Security_and_Access_Control_Model.

Document attributes: Document_ID, Person_ID, Employment_ID (optional), Document_Type, Document_Name, Effective_Date, Expiration_Date (optional), Storage_Reference, Upload_Date, Uploaded_By, Document_Status.

Document_Status values:

| STATE-DOC-001 | Active | Current version in use |
|---|---|---|
| STATE-DOC-002 | Superseded | Replaced by a newer version |
| STATE-DOC-003 | Expired | Past expiration date |
| STATE-DOC-004 | Archived | Retained for compliance, no longer active |

---

## 13. Onboarding Workflow Model

**REQ-ONB-001**
The platform shall support onboarding plans that coordinate the tasks required to make a new hire operationally ready.

**REQ-ONB-002**
Blocking onboarding tasks shall be completed before payroll activation is permitted.

**REQ-ONB-003**
Non-blocking tasks may remain open past the start date without preventing payroll processing.

**REQ-ONB-004**
The platform shall support the following onboarding task types: document completion (I-9, W-4, agreements), IT provisioning, equipment requests, system access setup, benefits enrollment initiation, payroll profile setup, training assignment, manager introduction, first day scheduling.

Onboarding attributes: Onboarding_Plan_ID, Employment_ID, Plan_Status, Target_Start_Date, Completion_Date, Assigned_HR_Contact.

Task attributes: Task_ID, Onboarding_Plan_ID, Task_Type, Task_Owner_Role, Due_Date, Completion_Date, Task_Status, Blocking_Flag.

Task_Status values:

| STATE-ONB-001 | Not Started | Task created but not begun |
|---|---|---|
| STATE-ONB-002 | In Progress | Task underway |
| STATE-ONB-003 | Completed | Task finished |
| STATE-ONB-004 | Waived | Task formally waived |
| STATE-ONB-005 | Overdue | Past due date, incomplete |

---

## 14. Self-Service Model

**REQ-ESS-001**
Managers shall be able to view direct report records, initiate lifecycle events, approve leave requests, view team organisational structure, and track onboarding task completion for direct reports.

**REQ-ESS-002**
HR administrators shall be able to create and manage person and employment records, manage organisational structure, process all lifecycle event types, manage job and position definitions, configure leave types and accrual rules, manage document workflows, and generate HR reports.

**REQ-ESS-003**
Employees shall be able to view their personal record, view pay statements (via Payroll module integration), submit leave requests, complete onboarding tasks, and update contact information.

**REQ-ESS-004**
All self-service actions shall be role-scoped and approval-governed. Self-service actions shall initiate workflow events rather than writing directly to canonical records.

---

## 15. Data Intake Model

**REQ-HRS-110**
Employee data shall be enterable through the following channels: manual entry via HR administrator UI, batch file import (CSV, XLSX, XML), API intake (synchronous, per-record), onboarding self-service completion.

**REQ-HRS-111**
All intake methods shall validate against schema and referential integrity rules before posting.

**REQ-HRS-112**
Invalid records shall route to exception queues rather than partial posting.

**REQ-HRS-113**
All intake methods shall generate Employee_Events for downstream consumption.

**REQ-HRS-114**
All intake methods shall produce audit records identifying source, timestamp, and operator.

**REQ-HRS-115**
Batch imports shall support incremental and full-replacement import modes.

**REQ-HRS-116**
Batch imports shall support dry-run mode for pre-import validation without posting.

**REQ-HRS-117**
Control totals shall be validated before a batch is considered accepted.

---

## 16. Approval Workflow Model

**REQ-HRS-120**
HR changes shall follow configurable approval workflows before becoming effective. Workflow states follow STATE-WFL as defined in §9.

**REQ-HRS-121**
Approval workflows shall apply to: lifecycle events (hire, termination, compensation change, transfer), leave requests, organisational structure changes, job and position changes, document sensitive field updates.

**REQ-HRS-122**
Workflows shall be configurable by event type, org unit, and employment level.

**REQ-HRS-123**
Multi-level approval chains shall be supported.

**REQ-HRS-124**
Delegation of approval authority shall be supported.

**REQ-HRS-125**
Approval deadlines and escalation rules shall be configurable.

---

## 17. Validation and Exception Framework

**REQ-HRS-130**
Validation shall occur before records are posted. Partial record posting shall not be permitted when Hard Stop exceptions are present.

**REQ-HRS-131**
All exceptions shall be routed to work queues for investigation and resolution.

Exception categories: Informational, Warning, Hold, Hard Stop.

**EXC-VAL-020**
Missing required field on hire record → Hard Stop

**EXC-VAL-021**
Compensation change without an approved reason code → Hold

**EXC-VAL-022**
Termination date before hire date → Hard Stop

**EXC-VAL-023**
Missing I-9 documentation past legally required window → Warning

**EXC-VAL-024**
Retroactive event affecting a closed payroll period → Hold (requires Payroll confirmation)

---

## 18. Reporting and Analytics Support

**REQ-HRS-140**
HRIS shall produce the following operational HR reports: active headcount by department/location/legal entity, new hires and terminations by period, turnover rate, leave utilisation and balances, open positions vs. headcount budget, onboarding completion status, document expiration tracking.

**REQ-HRS-141**
HRIS shall produce structured data exports to the Workforce Analytics module (future) as consistent effective-dated snapshots for historical trend analysis.

**REQ-HRS-142**
All reports shall resolve data as of an effective date, not a recorded date.

**REQ-HRS-143**
Historical reports shall be reproducible from archived data.

**REQ-HRS-144**
Report access shall be role-scoped consistent with the Security_and_Access_Control_Model.

---

## 19. Integration with Downstream Modules

**REQ-HRS-150**
HRIS shall be the upstream source of record for all HR data consumed by other modules. Downstream modules shall subscribe to HRIS events; HRIS shall not orchestrate downstream module behaviour.

**REQ-HRS-151**
The Payroll module shall consume Employment records, compensation rates, lifecycle events, and leave state via the Employee_Event_and_Status_Change_Model.

**REQ-HRS-152**
The Benefits module (future) shall receive hire, status change, and termination events to trigger enrollment and termination.

**REQ-HRS-153**
The Time & Attendance module (future) shall consume employment type, schedule, and leave balances, and shall return worked time records for payroll consumption.

**REQ-HRS-154**
The Recruiting module (future) shall produce candidate-to-hire transitions that initiate HRIS person and employment records.

---

## 20. Architecture Model Dependencies

The HRIS module is built on the following existing platform architecture models:

| Architecture Model | Role in HRIS |
|---|---|
| Employment_and_Person_Identity_Model | Defines the Person / Employment identity separation that governs all HRIS records |
| Employee_Event_and_Status_Change_Model | Governs lifecycle event structure, effective dating, and downstream routing |
| Employee_Assignment_Model | Governs how employment relationships are linked to plans, jobs, and org units |
| Organizational_Structure_Model | Defines org hierarchy, legal entity, department, and location structures |
| Compensation_and_Pay_Rate_Model | Governs compensation record structure, rate history, and change handling |
| Leave_and_Absence_Management_Model | Governs leave request lifecycle and payroll impact signals |
| Correction_and_Immutability_Model | Governs retroactive changes and prohibits silent record overwrites |
| Security_and_Access_Control_Model | Governs role-based access, self-service scoping, and document access |
| Release_and_Approval_Model | Governs approval workflow structure for HR events |
| Data_Retention_and_Archival_Model | Governs retention of person, employment, and document records |
| Integration_and_Data_Exchange_Model | Governs data intake, event publication, and downstream module feeds |

HRIS does not introduce new canonical models for domains already covered above.
New architecture models required by HRIS will be defined in a companion HRIS Architecture Model Inventory.

---

## 21. Future Expansion Considerations

Planned future areas not in v1 scope:

- Recruiting and applicant tracking integration (candidate-to-hire flow)
- Performance management linkage (goal setting, review cycles)
- Learning and development linkage (training completion, certification tracking)
- Multi-country employment structures and localisation
- Enhanced employee self-service portal
- Workforce planning and position budgeting
- Skills and competency tracking
- Succession planning support

---

## 22. User Stories

**HR Administrator** needs to **create and maintain person and employment records as the authoritative source of truth** in order to **ensure that Payroll, Benefits, and all downstream modules operate on correct, consistent employee data.**

**HR Administrator** needs to **process all employee lifecycle events through a governed workflow** in order to **ensure that changes are reviewed, approved, and applied consistently without silent record overwrites.**

**Manager** needs to **initiate compensation changes and transfers for direct reports from a self-service interface** in order to **act on HR decisions without requiring full HR system access or IT involvement.**

**Manager** needs to **view the reporting hierarchy and org chart for their team** in order to **understand their team structure, identify open positions, and track onboarding progress.**

**Employee** needs to **submit leave requests and complete onboarding tasks without contacting HR directly** in order to **manage their own HR actions through a self-service interface.**

**Payroll Administrator** needs to **receive accurate employment, compensation, and leave state from HRIS** in order to **calculate correct payroll results without manually re-entering HR data into the payroll system.**

**Compliance Auditor** needs to **reconstruct the complete HR state of any employee as of any historical date** in order to **respond to regulatory enquiries, legal discovery, and internal audits without data gaps.**

**New Employee** needs to **complete all required onboarding tasks before their first payroll run** in order to **ensure that their payroll profile, tax elections, and documentation are in place before payment is generated.**

---

## 23. Scope Boundaries

### In Scope — v1

**REQ-HRS-160**
All ten HRIS capabilities defined in HRIS_Module_PRD §2 (person records, employment records, org structure, job and position, lifecycle events, compensation records, leave management, document storage, onboarding, self-service, data intake, reporting) shall be delivered in v1.

**REQ-HRS-161**
U.S.-based employment structures only in v1. All employment types, FLSA classifications, and EEO categories are defined for U.S. compliance.

**REQ-HRS-162**
Primary reporting hierarchy (one manager per employee) shall be implemented in v1 via the Reporting_Hierarchy_Model.

**REQ-HRS-163**
Position management in advisory mode (headcount tracked at position and department level; warnings generated but no hard blocks) shall be implemented in v1.

**REQ-HRS-164**
All four self-service roles (Employee, Manager, HR Administrator) shall be supported in v1 with capabilities as defined in SPEC/Self_Service_Model.md.

### Out of Scope — v1

**REQ-HRS-165**
Dotted-line and matrix reporting relationships are out of scope for v1.

**REQ-HRS-166**
Position control in hard-enforcement mode (blocking hires without an open approved position) is out of scope for v1.

**REQ-HRS-167**
Recruiting, applicant tracking, and candidate-to-hire workflow are out of scope for v1. HRIS will receive hire events but will not generate them from a recruiting pipeline.

**REQ-HRS-168**
Performance management, goal setting, and review cycles are out of scope for v1.

**REQ-HRS-169**
Learning management and training completion tracking are out of scope for v1, except as onboarding task types.

**REQ-HRS-170**
Multi-country employment structures and non-U.S. payroll-relevant HR data fields are out of scope for v1.

---

## 24. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-HRS-001 | The HRIS module is the only module that can create or modify Person and Employment records. Payroll cannot write to either. |
| REQ-HRS-002 | A Payroll run correctly uses the Employment record, compensation rate, and leave state published by HRIS without requiring manual data re-entry. |
| REQ-HRS-003 | A hire, rehire, termination, compensation change, and transfer each generate the correct downstream events consumed by the Payroll module. |
| REQ-HRS-005 | Every HR record change produces an audit log entry with field-level before/after values, actor identity, and timestamp. |
| REQ-HRS-006 | A multi-employer deployment contains no cross-employer data visibility between HR administrators scoped to different employers. |
| REQ-HRS-020 | A rehired employee's new Employment_ID is distinct from the prior one. The prior employment record and its payroll history remain unmodified. |
| REQ-HRS-040 | A termination event cannot be processed with an Employment_End_Date earlier than the Employment_Start_Date. EXC-VAL-012 is generated. |
| REQ-HRS-060 | A position can be flagged as Frozen. Attempting to assign an employee to a Frozen position generates EXC-HRS-004 (warning). The assignment can proceed with documented acknowledgement. |
| REQ-HRS-080 | A compensation change submitted through MSS enters the approval workflow. The Employment record compensation rate is not updated until STATE-WFL-006 (Effective). |
| REQ-HRS-083 | A retroactive compensation change generates a downstream recalculation event to the Payroll module and is not silently applied. |
| REQ-HRS-090 | An approved leave request generates the correct payroll impact signal (paid substitution, unpaid suppression, or disability pay code) to the Payroll module. |
| REQ-HRS-100 | An I-9 document uploaded for an employee is versioned. The prior version remains accessible and is marked Superseded. |
| REQ-HRS-102 | An I-9 approaching its re-verification deadline generates a compliance alert at the configured threshold. |
| REQ-HRS-110 | A batch import of 1,000 employee records via CSV produces correct Employment records for all valid rows and routes all invalid rows to the exception queue. |
| REQ-HRS-116 | A dry-run batch import reports all validation errors without creating any records. |
| REQ-HRS-130 | A hire record missing a required field (e.g., Employment_Start_Date) is rejected with EXC-VAL-010. No partial hire record is created. |
| REQ-HRS-150 | A Payroll module deployment without HRIS co-deployed degrades gracefully — it processes payroll for employees already in the system but does not fail to start. |
| REQ-ESS-001 | A manager cannot view or act on employees outside their reporting hierarchy without explicit role elevation. |
| REQ-ESS-004 | An employee self-service address update creates a workflow event. The address on the Person record is not changed until the event workflow completes. |
| REQ-ONB-001 | An onboarding plan is automatically created when a hire event reaches STATE-WFL-006 (Effective). No manual plan creation is required. |
| REQ-ONB-002 | A new hire whose blocking onboarding tasks are incomplete at payroll cutoff is excluded from the payroll run and generates EXC-ONB-001. |

---

## 25. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.


### User-Facing Performance

**REQ-HRS-180**
Employee profile, job data, and employment status pages shall load within 2 seconds under normal load conditions.

**REQ-HRS-181**
Benefits, compensation history, and time entry pages shall load within 3 seconds under normal load conditions.

**REQ-HRS-182**
Complex dashboards and workforce analytics pages shall load within 5 seconds under normal load conditions.

**REQ-HRS-183**
Employee lookup by name or employee number shall return results within 1 second.

**REQ-HRS-184**
Org structure search and directory search shall return results within 2 seconds.

**REQ-HRS-185**
Self-service actions (address update, leave request submission, onboarding task completion) shall receive a confirmation response within 2 seconds.

**REQ-HRS-186**
Pay statement and W-2 loading in employee self-service shall return within 3 seconds.

### Batch Processing

**REQ-HRS-187**
Full nightly HRIS batch processing shall complete within 2 hours.

**REQ-HRS-188**
Payroll-related HRIS batch jobs shall complete within 1 hour.

### Open Enrollment Load

**REQ-HRS-189**
The system shall support 5–10× normal concurrent user load during open enrollment without page load times exceeding 4 seconds.

**REQ-HRS-190**
Enrollment submissions during open enrollment shall receive a confirmation response within 3 seconds regardless of concurrent load.

### Availability

**REQ-HRS-191**
The HRIS module shall achieve 99.9% uptime measured monthly, excluding approved maintenance windows.

### Scalability

**REQ-HRS-192**
The HRIS module shall support at least 500,000 active Employment records in a single deployment.

**REQ-HRS-193**
The HRIS module shall support 10–20% of the total workforce accessing the system concurrently during peak events without performance degradation below the defined SLAs.
