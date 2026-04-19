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

Module Vision:

Deliver a foundational Human Resources Information System (HRIS) module
that serves as the authoritative system of record for people, employment
relationships, organizational structure, and HR lifecycle events across
the HCM platform.

The HRIS module shall:

- Establish and own the canonical Person and Employment identity record
- Serve as the upstream source of truth for Payroll, Benefits, Time & Attendance, and all downstream modules
- Support the full employee lifecycle from onboarding through termination and rehire
- Enable manager and HR administrator self-service for record management and lifecycle events
- Maintain complete, auditable, effective-dated history of all HR data changes
- Support multi-employer, multi-legal-entity, and PEO-style operating environments

Relationship to Platform PRD:

The HCM Platform PRD establishes the platform vision, architectural principles, and core entity
model. This document specifies the HRIS module in detail within that framework. The HRIS module
does not introduce new architectural principles; it applies platform principles to the HR domain
and delegates payroll-financial behavior to the Payroll module.

Initial Scope:

U.S.-based employment structures. Multi-country extensibility is a design constraint, not an
initial deliverable.

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

HRIS is the system of record for identity, employment, compensation rates, and lifecycle events.
Payroll consumes HRIS data but does not own it. Changes in HRIS trigger downstream effects in
Payroll through the event model. HRIS does not calculate pay, generate checks, or manage
accumulators.

---

## 3. Inherited Architectural Principles

The HRIS module inherits and applies all principles from the HCM Platform PRD:

Modular Architecture:
HRIS is independently deployable. Downstream modules shall not require HRIS to be co-deployed,
but shall degrade gracefully when HRIS data is absent.

Event-Driven Processing:
All meaningful HR changes shall be represented as events. Events are the integration contract
between HRIS and downstream modules.

Effective-Dated Data:
All HR records shall support effective start and end dates. Point-in-time resolution shall be
deterministic.

Approval Workflow Governance:
HR changes shall follow configurable approval workflows before becoming effective.

Audit and Historical Preservation:
All record changes shall be preserved historically. No silent overwrites.

---

## 4. Core Entity Model

Primary HRIS Entities:

- Person: The human being. Owns legal identity, contact, and biographical attributes.
- Employment: The employment relationship between a Person and an Employer. Owns payroll-relevant
  status and context.
- Employment Record: Historical record of an employment period.
- Job: A defined role classification within the organization.
- Position: A specific organizational slot that may be filled by an employee.
- Assignment: The association of an Employment to a Job, Position, Department, and Location.
- Compensation Record: The pay rate and structure associated with an Employment.
- Org Unit: A node in the organizational hierarchy (Legal Entity, Division, Department, Location,
  Cost Center).
- Leave Request: A formal request for absence, with type, duration, and approval state.
- Document: An HR document associated with a Person or Employment (I-9, W-4, offer letter, etc.).
- Onboarding Task: A unit of work in a new hire onboarding workflow.

Identity Anchoring:

Person_ID is the enduring human identity key. Employment_ID is the payroll and HR operational
anchor. All downstream module records key to Employment_ID, not Person_ID, consistent with the
Employment_and_Person_Identity_Model.

---

## 5. Person Record Model

Person records represent enduring human identity.

Core Person attributes:

- Person_ID
- Legal_First_Name
- Legal_Last_Name
- Preferred_Name (optional)
- Date_of_Birth
- National_Identifier / SSN (secured)
- Gender (optional, self-identified)
- Pronouns (optional)
- Contact_Attributes (address, phone, email)
- Emergency_Contact_Attributes
- Person_Status

Person_Status values:

- Active
- Inactive
- Deceased
- Restricted

Person records persist across employment episodes. A terminated employee
retains their Person record.

---

## 6. Employment Record Model

Employment records represent the operational HR and payroll relationship.

Core Employment attributes:

- Employment_ID
- Person_ID
- Employer_ID
- Legal_Entity_ID
- Employee_Number
- Employment_Type
- Employment_Start_Date
- Employment_End_Date (optional)
- Employment_Status
- Full_or_Part_Time_Status
- Regular_or_Temporary_Status
- Payroll_Context_ID
- Primary_Work_Location_ID
- Primary_Department_ID
- FLSA_Status

Employment_Type values:

- Employee
- Contractor
- Intern
- Seasonal

Employment_Status values:

- Pending
- Active
- On Leave
- Suspended
- Terminated
- Closed

Employment records are created at hire and closed at termination. Rehire
creates a new Employment_ID under the same Person_ID, consistent with
the Employment_and_Person_Identity_Model.

---

## 7. Organizational Structure Model

Organizational structures define where employees belong and how the enterprise is structured.

Org Unit types supported:

- Legal Entity
- Division
- Business Unit
- Department
- Cost Center
- Location
- Region

Org Unit attributes:

- Org_Unit_ID
- Org_Unit_Type
- Org_Unit_Code
- Org_Unit_Name
- Parent_Org_Unit_ID
- Effective_Start_Date
- Effective_End_Date
- Org_Status

Hierarchy rules:

- Hierarchies are parent-child and must be acyclic.
- Each unit may have one parent and multiple children.
- Changes are effective-dated and historically preserved.
- Rollup relationships shall be deterministic for reporting and payroll aggregation.

Legal Entity attributes additionally include:

- Tax_Registration_Number
- Country_Code
- State_of_Incorporation

Locations additionally include:

- Full address attributes
- State_Code and Locality_Code (for tax jurisdiction resolution)
- Work_Location_Type (Office / Remote / Hybrid)

---

## 8. Job and Position Model

Jobs define role classifications. Positions define organizational slots.

Job attributes:

- Job_ID
- Job_Code
- Job_Title
- Job_Family
- Job_Level
- FLSA_Classification
- EEO_Category
- Effective_Start_Date
- Effective_End_Date

Position attributes:

- Position_ID
- Job_ID
- Org_Unit_ID
- Position_Title (optional override)
- Headcount_Budget
- Position_Status
- Effective_Start_Date
- Effective_End_Date

Position_Status values:

- Open
- Filled
- Frozen
- Closed

Positions are optional. Deployments may operate with Job-only structures
where position management is not required.

---

## 9. Employee Lifecycle Event Model

Employee lifecycle events drive state changes across HRIS and downstream modules.

Supported event types:

- HIRE
- REHIRE
- TERMINATION
- VOLUNTARY_RESIGNATION
- LEAVE_OF_ABSENCE
- RETURN_TO_WORK
- STATUS_CHANGE
- COMPENSATION_CHANGE
- JOB_CHANGE
- POSITION_CHANGE
- LOCATION_TRANSFER
- DEPARTMENT_TRANSFER
- WORK_STATE_CHANGE
- LEGAL_ENTITY_TRANSFER
- MANAGER_CHANGE

Core event attributes:

- Employee_Event_ID
- Person_ID
- Employment_ID
- Event_Type
- Event_Date
- Effective_Date
- Recorded_Date
- Event_Status
- Event_Reason_Code
- Initiated_By
- Approved_By
- Source_Context_ID

Event workflow states:

- Draft
- Submitted
- Pending Approval
- Approved
- Effective
- Rejected
- Cancelled

Effective dating rules:

Each event carries separate effective dates for Payroll, Benefits, and Tax domains, allowing
downstream modules to apply the change on their own schedules consistent with the
Employee_Event_and_Status_Change_Model.

Retroactive events:

Events entered after their effective date must carry a Retroactive_Flag. Retroactive events
must not silently alter historical records. Affected downstream periods must be identified
and routed for correction processing.

Event sequencing:

Sequencing rules prevent invalid state transitions. Examples:

- Return to Work requires a prior active Leave of Absence
- Rehire requires a prior Termination on the same Person_ID
- Legal Entity Transfer requires a simultaneous or sequential Employment record transition

---

## 10. Compensation Record Model

HRIS owns compensation rate records. Payroll consumes them.

Core Compensation attributes:

- Compensation_ID
- Employment_ID
- Rate_Type
- Base_Rate
- Rate_Currency
- Annual_Equivalent (calculated)
- Pay_Frequency
- Effective_Start_Date
- Effective_End_Date
- Compensation_Status
- Change_Reason_Code
- Approval_Status

Rate_Type values:

- HOURLY
- SALARY
- COMMISSION
- CONTRACT

Compensation change rules:

- Changes are effective-dated and versioned.
- Prior rates are preserved and accessible for retroactive payroll processing.
- Rate changes require approval workflow completion before becoming effective.
- Retroactive rate changes generate downstream recalculation events routed to Payroll.

Multiple rate support:

Employees may carry multiple active rates (e.g., base salary plus shift differential).
Rate resolution precedence is governed by the Compensation_and_Pay_Rate_Model.

---

## 11. Leave and Absence Management Model

HRIS manages leave requests and balances. Payroll consumes leave data to determine
earnings behavior.

Leave types supported:

- Paid Time Off (PTO)
- Vacation
- Sick Leave
- Personal Leave
- Leave of Absence (LOA)
- Family and Medical Leave (FMLA)
- Short-Term Disability
- Long-Term Disability
- Military Leave
- Jury Duty
- Holiday Leave

Leave Request attributes:

- Leave_Request_ID
- Employment_ID
- Leave_Type
- Request_Date
- Leave_Start_Date
- Leave_End_Date
- Leave_Status
- Leave_Reason_Code
- Approved_By
- Leave_Balance_Impact

Leave status lifecycle:

- Requested
- Approved
- Denied
- Scheduled
- Active
- Completed
- Cancelled

Leave balance tracking:

- Accrual rates and frequencies are configurable per leave type.
- Balances update in alignment with accrual and payroll cycles.
- Carryover rules are configurable per leave type and jurisdiction.

Payroll impact:

- Paid leave generates earnings substitution signals to Payroll.
- Unpaid leave generates earnings suppression signals.
- Disability leave generates special pay code signals.
- Payroll shall not calculate leave earnings independently of HRIS leave state.

---

## 12. Document Storage Model

HRIS manages HR documents associated with persons and employment relationships.

Supported document types:

- I-9 (Employment Eligibility Verification)
- W-4 (Federal Withholding)
- State tax withholding forms
- Offer Letter
- Employment Agreement
- Non-Disclosure Agreement
- Power of Attorney
- Licenses and Certifications
- Performance Documentation
- Disciplinary Records

Document attributes:

- Document_ID
- Person_ID
- Employment_ID (optional)
- Document_Type
- Document_Name
- Effective_Date
- Expiration_Date (optional)
- Storage_Reference
- Upload_Date
- Uploaded_By
- Document_Status

Document governance:

- All documents are versioned and date-stamped.
- Prior versions are retained and accessible.
- Expiration tracking supports compliance alerting (e.g., I-9 re-verification).
- Access is governed by role and employment scope consistent with the
  Security_and_Access_Control_Model.

---

## 13. Onboarding Workflow Model

Onboarding workflows coordinate the tasks required to make a new hire operationally ready.

Onboarding Task types:

- Document completion (I-9, W-4, agreements)
- IT provisioning requests
- Equipment requests
- System access setup
- Benefits enrollment initiation
- Payroll profile setup
- Training assignment
- Manager introduction task
- First day scheduling

Onboarding attributes:

- Onboarding_Plan_ID
- Employment_ID
- Plan_Status
- Target_Start_Date
- Completion_Date
- Assigned_HR_Contact

Task attributes:

- Task_ID
- Onboarding_Plan_ID
- Task_Type
- Task_Owner_Role
- Due_Date
- Completion_Date
- Task_Status
- Blocking_Flag

Task_Status values:

- Not Started
- In Progress
- Completed
- Waived
- Overdue

Blocking tasks must be completed before payroll activation is permitted.
Non-blocking tasks may remain open past the start date without preventing
payroll processing.

---

## 14. Self-Service Model

HRIS shall support manager and HR administrator self-service for record management.

Manager self-service capabilities:

- View direct report records
- Initiate lifecycle events (transfers, compensation changes, terminations)
- Approve leave requests
- View team organizational structure
- Track onboarding task completion for direct reports

HR administrator capabilities:

- Create and manage person and employment records
- Manage organizational structure
- Process all lifecycle event types
- Manage job and position definitions
- Configure leave types and accrual rules
- Manage document workflows
- Generate HR reports

Employee self-service (limited v1 scope):

- View personal record
- View pay statements (via Payroll module integration)
- Submit leave requests
- Complete onboarding tasks
- Update contact information

Access governance:

All self-service actions are role-scoped and approval-governed. Self-service actions
initiate workflow events rather than writing directly to canonical records. Consistent
with the Release_and_Approval_Model.

---

## 15. Data Intake Model

Employee data may be entered through multiple channels.

Supported intake methods:

- Manual entry via HR administrator UI
- Batch file import (CSV, XLSX, XML)
- API intake (synchronous, per-record)
- Onboarding self-service completion (document upload, form submission)
- Integration from Recruiting module (future)

All intake methods must:

- Validate against schema and referential integrity rules before posting
- Route invalid records to exception queues rather than partial posting
- Generate Employee_Events for downstream consumption
- Produce audit records identifying source, timestamp, and operator

Batch import requirements:

- Support incremental and full-replacement import modes
- Provide per-record validation results
- Support dry-run mode for pre-import validation without posting
- Control totals must be validated before batch is considered accepted

---

## 16. Approval Workflow Model

HR changes follow configurable approval workflows before becoming effective.

Workflow states:

- Draft
- Submitted
- Under Review
- Approved
- Rejected
- Effective
- Cancelled

Approval workflow applies to:

- Lifecycle events (hire, termination, compensation change, transfer)
- Leave requests
- Organizational structure changes
- Job and position changes
- Document sensitive field updates

Workflow configuration:

- Workflows are configurable by event type, org unit, and employment level.
- Multi-level approval chains are supported.
- Delegation of approval authority is supported.
- Approval deadlines and escalation rules are configurable.

---

## 17. Validation and Exception Framework

Validation occurs before records are posted.

Exception categories:

- Informational
- Warning
- Hold
- Hard Stop

Examples:

- Missing required field on hire record (Hard Stop)
- Compensation change without an approved reason code (Hold)
- Termination date before hire date (Hard Stop)
- Missing I-9 documentation past legally required window (Warning)
- Retroactive event affecting a closed payroll period (Hold, requires Payroll confirmation)

All exceptions are routed to work queues for investigation and resolution.
Partial record posting is not permitted when Hard Stop exceptions are present.

---

## 18. Reporting and Analytics Support

HRIS shall produce data feeds and reports supporting HR operations and workforce analytics.

Operational HR reports:

- Active headcount by department, location, legal entity
- New hires and terminations by period
- Turnover rate
- Leave utilization and balances
- Open positions and headcount vs. budget
- Onboarding completion status
- Document expiration tracking

Workforce analytics feeds:

- Structured data exports to Workforce Analytics module (future)
- Consistent effective-dated snapshots for historical trend analysis

Reporting constraints:

- All reports resolve data as of an effective date, not a recorded date.
- Historical reports must be reproducible from archived data.
- Report access is role-scoped consistent with the Security_and_Access_Control_Model.

---

## 19. Integration with Downstream Modules

HRIS is the upstream source of record for all HR data consumed by other modules.

Payroll module:

- Consumes Employment records, compensation rates, lifecycle events, and leave state.
- Receives events via the Employee_Event_and_Status_Change_Model.
- Does not write back to HRIS person or employment records.

Benefits module (future):

- Consumes eligibility-relevant employment attributes.
- Receives hire, status change, and termination events to trigger enrollment and termination.

Time & Attendance module (future):

- Consumes employment type, schedule, and leave balances.
- Returns worked time records for payroll consumption.

Recruiting module (future):

- Produces candidate-to-hire transitions that initiate HRIS person and employment records.

Integration pattern:

HRIS publishes events. Downstream modules subscribe and act. HRIS does not orchestrate
downstream module behavior. Consistent with the Integration_and_Data_Exchange_Model.

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
New architecture models required by HRIS will be defined in a companion
HRIS Architecture Model Inventory.

---

## 21. Future Expansion Considerations

Planned future areas not in v1 scope:

- Recruiting and applicant tracking integration (candidate-to-hire flow)
- Performance management linkage (goal setting, review cycles)
- Learning and development linkage (training completion, certification tracking)
- Multi-country employment structures and localization
- Enhanced employee self-service portal
- Workforce planning and position budgeting
- Skills and competency tracking
- Succession planning support
