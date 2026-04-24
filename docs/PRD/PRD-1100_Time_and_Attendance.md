# PRD-1100 — Time & Attendance (Minimum Viable)

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Module Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Time & Attendance |
| **Location** | `docs/PRD/PRD-1100_Time_and_Attendance.md` |
| **Date** | April 2026 |
| **Related Documents** | PRD-0000_Core_Vision, PRD-0100_Architecture_Principles, PRD-0400_Earnings_Model, PRD-0600_Jurisdiction_Model, PRD-0700_Workflow_Framework, PRD-0800_Validation_Framework, HRIS_Module_PRD, Time_Entry_and_Worked_Time_Model, Scheduling_and_Shift_Model, Overtime_and_Premium_Pay_Model, Attendance_and_Exception_Tracking_Model, EXC-TIM_Time_Attendance_Exceptions |

---

## Purpose

Defines the minimum viable requirements for the Time & Attendance (T&A) module — the smallest set of capabilities that allows the platform to capture worked time, approve it, and deliver it correctly to payroll, while maintaining compliance with U.S. wage and hour law.

This module is explicitly scoped to MVHR viability. Advanced scheduling optimisation, workforce management analytics, biometric capture, and complex union-rule engines are not in scope for this version.

This document is a self-contained module specification. It inherits and applies the platform-level principles defined in `PRD-0100_Architecture_Principles.md` without repeating or modifying them. It does not cover payroll calculation, HRIS record management, or leave administration — those remain owned by their respective modules.

---

## Section Map

| § | Section | What it covers |
|---|---|---|
| 1 | Module Vision and Strategic Purpose | Why this module exists; its role in the platform |
| 2 | Module Scope | In scope, out of scope, and module boundaries |
| 3 | Inherited Architectural Principles | Platform principles as applied to T&A |
| 4 | Time Entry Model | Core time entry entity, capture methods, and attributes |
| 5 | Time Category Classification | Supported time categories and their payroll significance |
| 6 | Schedule and Shift Context | Minimum schedule model required to support time interpretation |
| 7 | Approval Lifecycle | Timecard approval states and payroll eligibility gate |
| 8 | Overtime and Premium Eligibility | FLSA and jurisdiction-driven overtime and premium detection |
| 9 | Payroll Handoff | How approved time is delivered to the Payroll module |
| 10 | Compliance and Wage-Hour Requirements | FLSA record-keeping and audit obligations |
| 11 | Correction and Retroactive Handling | Time entry correction rules and payroll recalculation triggers |
| 12 | Data Intake Model | Supported time entry intake methods |
| 13 | Employee and Manager Self-Service | Self-service capabilities for time entry and approval |
| 14 | Validation and Exception Framework | Exception categories and routing rules |
| 15 | Basic Reporting | Operational time reports required for MVHR viability |
| 16 | Integration with Other Modules | HRIS, Payroll, and leave integration patterns |
| 17 | Architecture Model Dependencies | Governing architecture models |
| 18 | Future Expansion Considerations | Out-of-scope capabilities planned for later phases |
| 19 | User Stories | Role-based user stories |
| 20 | Scope Boundaries | Explicit in-scope and out-of-scope requirement statements |
| 21 | Acceptance Criteria | Testable acceptance criteria per requirement |
| 22 | Non-Functional Requirements | Domain-specific SLA targets |

---

## 1. Module Vision and Strategic Purpose

**REQ-TIM-001**
The T&A module shall capture, approve, and deliver employee worked time as the authoritative input to payroll earnings calculation.

**REQ-TIM-002**
The T&A module shall serve as the governed source of worked time records consumed by the Payroll module. Payroll shall not accept unapproved time entries.

**REQ-TIM-003**
The T&A module shall support detection of overtime and premium pay eligibility based on approved worked time, jurisdiction rules, and employee classification.

**REQ-TIM-004**
The T&A module shall support manager approval of employee time records before payroll cutoff.

**REQ-TIM-005**
The T&A module shall maintain complete, auditable, effective-dated history of all time entry changes.

**REQ-TIM-006**
The T&A module shall support U.S.-based wage and hour compliance obligations, including FLSA record-keeping requirements.

**REQ-TIM-007**
Initial scope is U.S.-based employment structures. Multi-country extensibility is a design constraint, not an initial deliverable.

---

## 2. Module Scope

### In Scope (v1)

- Manual time entry by employee via self-service
- Batch time entry import via file
- API-based time entry submission from external time capture systems
- Time category classification (regular, overtime, PTO used, sick, holiday worked, etc.)
- Basic schedule context — work schedule assignment per employee to support overtime threshold evaluation
- Manager approval of employee timecards
- HR administrator override and correction of time entries
- Overtime threshold detection (daily and weekly) and premium pay eligibility flagging
- Approved time delivery to Payroll as a governed payroll input
- FLSA-compliant worked time record retention
- Attendance exception detection and routing to work queues
- Basic operational reports (timecard status, hours by period, unapproved time)

### Out of Scope (v1)

- Biometric or geofenced time capture hardware integration
- Advanced scheduling optimisation and shift-swap workflows
- Union rule engines and collective bargaining agreement (CBA) rule processing
- Complex premium rule stacking beyond FLSA-governed overtime
- Workforce management analytics and demand forecasting
- Multi-country time and attendance structures
- Automatic break deduction rules (configurable break deduction is future)
- Project-based or cost-centre time tracking (timesheet allocation)

### Boundary with HRIS Module

**REQ-TIM-010**
HRIS shall remain the system of record for employment type, FLSA classification, work location, and pay rate. T&A shall consume these attributes from HRIS but shall not own them.

**REQ-TIM-011**
Leave requests and approved leave records are owned by HRIS. T&A shall consume approved leave state to suppress or substitute earnings input to Payroll but shall not manage the leave request lifecycle.

**REQ-TIM-012**
T&A shall not write back to HRIS employment or compensation records.

### Boundary with Payroll Module

**REQ-TIM-013**
T&A shall deliver approved time entries to Payroll as governed payroll inputs via the integration model defined in INT-TIM-001. Payroll shall not independently source worked time from any other system.

**REQ-TIM-014**
T&A shall not calculate earnings, generate result lines, or manage accumulators. Those responsibilities remain with the Payroll module.

**REQ-TIM-015**
Unapproved time entries at payroll cutoff shall generate EXC-TIM-002 and be excluded from the payroll run.

---

## 3. Inherited Architectural Principles

The T&A module inherits and applies all principles from PRD-0100_Architecture_Principles:

**REQ-TIM-016**
T&A shall be independently deployable. Payroll shall degrade gracefully when T&A is absent, but shall not accept worked time from ungoverned sources when T&A is deployed.

**REQ-TIM-017**
All time entry changes shall be represented as versioned records. Silent overwrites of approved time entries are not permitted.

**REQ-TIM-018**
All time records shall support effective-dated context. Point-in-time resolution of worked time shall be deterministic.

**REQ-TIM-019**
Time entry changes shall follow configurable approval workflows before becoming payroll-eligible.

**REQ-TIM-020**
Approved and payroll-consumed time entries shall be immutable except through governed correction workflows.

---

## 4. Time Entry Model

**REQ-TIM-030**
The platform shall support a governed Time Entry record as the authoritative unit of worked time capture.

Core Time Entry attributes:

| Field | Description |
|---|---|
| Time_Entry_ID | Unique identifier |
| Employment_ID | Employment reference — payroll anchor |
| Person_ID | Person reference |
| Work_Date | Date on which work occurred |
| Start_Time | Shift or period start time (optional for duration-only entry) |
| End_Time | Shift or period end time (optional for duration-only entry) |
| Duration | Total hours/minutes worked for the entry |
| Time_Category | Classification of time worked (see §5) |
| Time_Status | Entry lifecycle state (see §7) |
| Source_System_ID | Originating capture system reference where applicable |
| Entry_Method | MANUAL, IMPORT, API, SELF_SERVICE |
| Schedule_ID | Referenced work schedule where applicable |
| Shift_ID | Referenced shift definition where applicable |
| Payroll_Period_ID | Payroll period to which the entry belongs |
| Payroll_Consumption_Status | PENDING, CONSUMED, EXCLUDED |
| Notes | Optional administrative notes |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

**REQ-TIM-031**
Time entries shall support both punch-based capture (start time / end time) and duration-based capture (hours entered directly) to accommodate different time capture methods.

**REQ-TIM-032**
Every time entry shall reference an Employment_ID. Time entries without a valid Employment_ID shall be rejected with EXC-TIM-001.

**REQ-TIM-033**
All time entries shall preserve a complete version history. Prior versions shall be retained and queryable. Corrections shall create new versioned entries linked to their predecessors via Original_Time_Entry_ID.

---

## 5. Time Category Classification

**REQ-TIM-040**
The platform shall support the following time categories as the minimum set required for payroll accuracy and FLSA compliance:

| Category Code | Description | Payroll Significance |
|---|---|---|
| REGULAR | Standard worked hours within threshold | Standard earnings |
| OVERTIME | Hours exceeding FLSA or jurisdiction threshold | Premium earnings — governed by Overtime_and_Premium_Pay_Model |
| DOUBLE_TIME | Hours triggering double-time threshold where applicable | Premium earnings |
| HOLIDAY_WORKED | Hours worked on a designated company or statutory holiday | Premium earnings |
| PTO_USED | Paid time off taken — sourced from approved leave | Earnings substitution — sourced from HRIS leave state |
| SICK_USED | Sick leave taken — sourced from approved leave | Earnings substitution — sourced from HRIS leave state |
| UNPAID_LEAVE | Unpaid absence — sourced from approved leave | Earnings suppression |
| ON_CALL | Compensable on-call time where policy requires | Standard or premium earnings per jurisdiction rule |
| CALLBACK | Called back to work outside scheduled hours | Premium earnings per jurisdiction rule |

**REQ-TIM-041**
Time category classification shall govern the earnings result line type generated by Payroll. Payroll shall not reclassify time independently of the governed Time_Category value.

**REQ-TIM-042**
Leave-sourced categories (PTO_USED, SICK_USED, UNPAID_LEAVE) shall be populated from approved leave state owned by HRIS. T&A shall not independently determine leave balances or entitlements.

---

## 6. Schedule and Shift Context

**REQ-TIM-050**
The platform shall support a minimum schedule model sufficient to enable overtime threshold evaluation and planned-vs-actual comparison.

**REQ-TIM-051**
Each Employment record shall support assignment to a work schedule defining expected work days and hours per week. Schedule assignment shall be effective-dated.

**REQ-TIM-052**
Schedule context shall be consumed from the Scheduling_and_Shift_Model. T&A shall not maintain an independent scheduling system for MVHR scope.

**REQ-TIM-053**
Shift definitions shall provide start time, end time, expected duration, and shift type (DAY, EVENING, NIGHT, WEEKEND) sufficient to evaluate shift premium eligibility.

**REQ-TIM-054**
Schedule assignments shall be historical and queryable by effective date to support replay and retroactive correction.

---

## 7. Approval Lifecycle

**REQ-TIM-060**
Time entries shall follow a governed approval lifecycle. Only time entries in Approved or Locked status shall be eligible for payroll consumption.

Time Entry status values:

| Status Code | Status Name | Description |
|---|---|---|
| STATE-TIM-001 | Draft | Entry created but not submitted for approval |
| STATE-TIM-002 | Submitted | Submitted to manager for approval |
| STATE-TIM-003 | Approved | Approved by manager or HR administrator; payroll-eligible |
| STATE-TIM-004 | Rejected | Returned to employee for correction |
| STATE-TIM-005 | Corrected | Corrected version submitted following rejection |
| STATE-TIM-006 | Locked | Consumed by a payroll run; immutable except via correction |
| STATE-TIM-007 | Voided | Withdrawn before payroll consumption |

**REQ-TIM-061**
A timecard shall transition to Locked status upon payroll consumption. Locked entries may not be directly edited. Corrections shall proceed through the correction workflow defined in §11.

**REQ-TIM-062**
Approval authority shall be role-scoped. Employees may approve only their own submissions where self-approval is permitted by policy. Managers may approve only direct reports within their reporting scope. HR administrators may approve for any employee within their access scope.

**REQ-TIM-063**
The platform shall support configurable approval deadlines per payroll period. Unapproved time entries at the payroll input cutoff shall generate EXC-TIM-002.

**REQ-TIM-064**
All approval decisions shall be audit-logged with approver identity, timestamp, and status transition.

---

## 8. Overtime and Premium Eligibility

**REQ-TIM-070**
The platform shall evaluate overtime eligibility for all approved time entries based on:

- FLSA weekly overtime threshold (40 hours per workweek) for non-exempt employees
- Applicable state daily overtime thresholds where jurisdiction rules require
- Employee FLSA classification (EXEMPT / NON_EXEMPT) sourced from HRIS Employment record

**REQ-TIM-071**
Overtime threshold evaluation shall use the workweek definition associated with the employee's Payroll Context. Workweek definition shall be configurable per employer and shall not be assumed to align with the payroll period.

**REQ-TIM-072**
Where approved time in a workweek exceeds the applicable overtime threshold, the platform shall reclassify hours above the threshold from REGULAR to OVERTIME and flag them for premium earnings generation by Payroll.

**REQ-TIM-073**
Overtime detection shall generate EXC-TIM-003 (Overtime Threshold Exceeded) as a warning for operator review on the pay register.

**REQ-TIM-074**
Shift premium eligibility (night, weekend, holiday) shall be determined by the Overtime_and_Premium_Pay_Model using the time entry's Time_Category, Shift_ID, Work_Date, and applicable Jurisdiction_ID. T&A shall supply the input context; premium rate calculation remains with Payroll.

**REQ-TIM-075**
FLSA-exempt employees shall not have overtime thresholds applied. Exempt status shall be sourced from the FLSA_Classification field on the HRIS Employment record.

---

## 9. Payroll Handoff

**REQ-TIM-080**
The platform shall deliver all Approved and Locked time entries for a payroll period to the Payroll module as governed inputs prior to the payroll calculation phase.

**REQ-TIM-081**
The payroll handoff shall include for each time entry: Employment_ID, Work_Date, Time_Category, Duration, Overtime_Flag, Shift_ID, Jurisdiction_ID, and Payroll_Period_ID.

**REQ-TIM-082**
Only time entries with Payroll_Consumption_Status = PENDING at handoff shall be included. Entries previously consumed or explicitly excluded shall not be resubmitted.

**REQ-TIM-083**
The handoff shall conform to the integration contract defined in INT-TIM-001 (API_Surface_Map). Batch file and API delivery patterns shall both be supported.

**REQ-TIM-084**
The Payroll module shall confirm receipt of each handoff batch. Unacknowledged handoffs shall generate EXC-TIM-002 and route to the operator work queue.

**REQ-TIM-085**
Upon payroll consumption, the platform shall transition the Time_Entry status to Locked and set Payroll_Consumption_Status = CONSUMED, preserving the Payroll_Run_ID reference.

---

## 10. Compliance and Wage-Hour Requirements

**REQ-TIM-090**
The platform shall retain worked time records for a minimum of three years per FLSA record-keeping requirements. Retention shall be governed by the Data_Retention_and_Archival_Model.

**REQ-TIM-091**
Retained records shall include, at minimum: employee identity, workweek, hours worked per day, hours worked per week, straight-time and overtime earnings, and total wages paid per period.

**REQ-TIM-092**
The platform shall enforce the non-exempt / exempt distinction sourced from HRIS for all overtime and minimum wage compliance evaluations. T&A shall not independently classify employees.

**REQ-TIM-093**
The platform shall support reconstruction of the complete time record for any employee for any historical period from archived data, to support regulatory audit and legal discovery.

**REQ-TIM-094**
All time entry approval actions, corrections, and payroll handoff events shall be preserved in the audit log with actor identity and timestamp, consistent with the platform audit model.

---

## 11. Correction and Retroactive Handling

**REQ-TIM-100**
Time entry corrections shall preserve the original entry. Corrections shall create new versioned time entries linked to the original via Original_Time_Entry_ID, with a Correction_Type and Retroactive_Flag.

**REQ-TIM-101**
A correction to a Locked time entry shall trigger a payroll recalculation review event to the Payroll module, consistent with the Payroll_Adjustment_and_Correction_Model.

**REQ-TIM-102**
Retroactive corrections affecting a closed payroll period shall generate EXC-TIM-004 (Unapproved Time Submitted After Payroll Cutoff) and require operator determination of whether to apply the correction in the current or next run, or to initiate an off-cycle correction run.

**REQ-TIM-103**
Correction lineage shall be preserved and queryable. The full chain from original entry to final corrected state shall be reconstructable for any time record.

**REQ-TIM-104**
Historical time entries shall never be silently overwritten. Destructive edits of approved or locked entries are not permitted.

---

## 12. Data Intake Model

**REQ-TIM-110**
Time entries shall be enterable through the following channels: manual entry via employee self-service, manual entry by HR administrator or manager, batch file import (CSV, XLSX), API intake (synchronous, per-record or batch).

**REQ-TIM-111**
All intake methods shall validate against schema and referential integrity rules (valid Employment_ID, valid Time_Category, valid Payroll_Period_ID) before staging.

**REQ-TIM-112**
Invalid records shall route to exception queues rather than partially post.

**REQ-TIM-113**
All intake methods shall produce audit records identifying source, timestamp, and operator or system identity.

**REQ-TIM-114**
Batch imports shall support dry-run mode for pre-import validation without posting.

**REQ-TIM-115**
API-submitted time entries shall return a validation response within the SLA defined in §22.

---

## 13. Employee and Manager Self-Service

**REQ-TIM-120**
Employees shall be able to submit time entries for their own Employment_ID via self-service. Employees shall not be able to submit or modify time for other employees.

**REQ-TIM-121**
Managers shall be able to review, approve, and reject time entries for direct reports within their reporting scope. Managers shall not access time records outside their scope without explicit role elevation.

**REQ-TIM-122**
Employees shall be able to view their own timecard status, approval history, and current-period hours via self-service.

**REQ-TIM-123**
Managers shall be able to view a summary of their team's timecard status — including unapproved entries and hours approaching overtime — via self-service.

**REQ-TIM-124**
All self-service time entry actions shall initiate governed workflow events rather than writing directly to canonical records.

---

## 14. Validation and Exception Framework

**REQ-TIM-130**
Validation shall occur before time entries are staged. Entries with Hard Stop exceptions shall not be staged.

**REQ-TIM-131**
All exceptions shall be routed to work queues for investigation and resolution, consistent with the Exception_and_Work_Queue_Model.

Exception categories and governing codes:

| Exception Code | Name | Severity | Condition |
|---|---|---|---|
| EXC-TIM-001 | Missing Employment Reference | Hard Stop | Time entry submitted without valid Employment_ID |
| EXC-TIM-002 | Unapproved Time at Payroll Cutoff | Warning | Time entries unapproved at input cutoff for the period |
| EXC-TIM-003 | Overtime Threshold Exceeded | Warning | Approved hours exceed applicable weekly or daily overtime threshold |
| EXC-TIM-004 | Late Entry After Payroll Cutoff | Warning | Time entry submitted after payroll input cutoff; excluded from current run |
| EXC-TIM-005 | Shift Duration Anomaly | Warning | Recorded shift duration exceeds configured reasonableness threshold |

---

## 15. Basic Reporting

**REQ-TIM-140**
The T&A module shall produce the following operational reports as minimum viable output:

- **Timecard Status Report** — current-period approval status per employee, including Approved, Submitted, and Draft counts, filterable by department and manager
- **Hours Summary Report** — total regular and overtime hours per employee per payroll period
- **Unapproved Time Report** — all time entries not yet approved as of a given date, with days outstanding
- **Overtime Alert Report** — employees whose approved hours have reached or exceeded the overtime threshold for the current workweek
- **Payroll Handoff Confirmation** — record of time entries delivered to Payroll for a given period, with entry counts and total hours

**REQ-TIM-141**
All reports shall resolve data as of an effective date, not a recorded date.

**REQ-TIM-142**
Report access shall be role-scoped consistent with the Security_and_Access_Control_Model.

---

## 16. Integration with Other Modules

**REQ-TIM-150**
T&A shall consume employment type, FLSA classification, work schedule, and work location from HRIS via the Employee_Event_and_Status_Change_Model. T&A shall not maintain independent copies of these attributes.

**REQ-TIM-151**
T&A shall consume approved leave state from HRIS to correctly classify leave-sourced time categories and suppress or substitute earnings inputs to Payroll.

**REQ-TIM-152**
T&A shall publish approved worked time to the Payroll module via INT-TIM-001 prior to the payroll calculation phase for each run.

**REQ-TIM-153**
T&A shall receive payroll period context (period start, period end, input cutoff date, pay date) from the Payroll Calendar model to enforce submission deadlines and classify entries by period.

**REQ-TIM-154**
HRIS lifecycle events (termination, leave of absence, transfer) shall trigger T&A to close or suspend open timecards for the affected Employment_ID and generate appropriate exception handling.

---

## 17. Architecture Model Dependencies

The T&A module is built on the following existing platform architecture models:

| Architecture Model | Role in T&A |
|---|---|
| Time_Entry_and_Worked_Time_Model | Governs the core time entry entity, approval lifecycle, aggregation, and payroll integration |
| Scheduling_and_Shift_Model | Governs schedule context, shift definitions, and planned-vs-actual comparison |
| Overtime_and_Premium_Pay_Model | Governs overtime threshold detection and premium eligibility determination |
| Attendance_and_Exception_Tracking_Model | Governs attendance exception detection, classification, and work queue routing |
| Employee_Event_and_Status_Change_Model | Governs HRIS lifecycle events that affect T&A state |
| Payroll_Run_Model | Governs payroll period context and cutoff enforcement |
| Payroll_Adjustment_and_Correction_Model | Governs retroactive correction handling when approved time changes affect closed payroll periods |
| Correction_and_Immutability_Model | Governs immutability of approved and locked time entries |
| Exception_and_Work_Queue_Model | Governs exception routing and operator work queue management |
| Security_and_Access_Control_Model | Governs role-scoped access to time records and approval actions |
| Integration_and_Data_Exchange_Model | Governs data intake and payroll handoff patterns |
| Data_Retention_and_Archival_Model | Governs FLSA-compliant worked time record retention |

T&A does not introduce new canonical models for domains already governed above. New architecture models required specifically by T&A will be defined in a companion T&A Architecture Model Inventory entry.

---

## 18. Future Expansion Considerations

Planned capabilities not in MVHR scope:

- Biometric and geofenced time capture hardware integration
- Advanced schedule optimisation, shift-swap, and open-shift bidding workflows
- Union rule engine and CBA-governed premium rule stacking
- Project-based and cost-centre timesheet allocation
- Automated configurable break deduction rules
- Mobile-native time capture application
- Multi-country time and attendance structures and localisation
- Demand forecasting and workforce capacity planning
- Advanced absence analytics and pattern detection

---

## 19. User Stories

**Employee** needs to **enter and submit worked hours for manager approval through a self-service interface** in order to **ensure their time is captured accurately and submitted before the payroll cutoff without requiring HR involvement.**

**Manager** needs to **review and approve direct reports' timecards before payroll cutoff** in order to **ensure that only accurate, authorised time is delivered to payroll and that overtime is identified before it affects the pay run.**

**HR Administrator** needs to **correct time entry errors and override timecard status for any employee** in order to **resolve exceptions and ensure that the payroll run is not delayed by individual time entry problems.**

**Payroll Administrator** needs to **receive a complete, approved set of worked time records from T&A before initiating the payroll run** in order to **calculate correct earnings, overtime, and premiums without manually re-entering time data.**

**Compliance Auditor** needs to **reconstruct the complete worked time record for any employee for any historical period** in order to **respond to FLSA-related regulatory enquiries and demonstrate compliance with wage and hour obligations.**

**Payroll Engineer** needs to **consume time entries with governed Time_Category values and payroll-period context** in order to **generate correct earnings result lines and apply the appropriate premium rules without ambiguity about how hours should be classified.**

---

## 20. Scope Boundaries

### In Scope — v1

**REQ-TIM-160**
All T&A capabilities defined in §2 (time entry capture, time category classification, schedule context, manager approval lifecycle, overtime detection, payroll handoff, FLSA compliance, correction handling, data intake, self-service, exception handling, and basic reporting) shall be delivered in v1.

**REQ-TIM-161**
U.S.-based employment structures and U.S. wage and hour compliance only in v1.

**REQ-TIM-162**
FLSA weekly overtime threshold (40 hours per workweek) shall be enforced for all non-exempt employees in v1.

**REQ-TIM-163**
State daily overtime thresholds (e.g., California) shall be supported via the Jurisdiction_and_Compliance_Rules_Model in v1 where jurisdiction rules are available.

**REQ-TIM-164**
The INT-TIM-001 integration point (Time Entry Import) defined in the API_Surface_Map shall be implemented and promoted to In Scope status as part of this PRD.

### Out of Scope — v1

**REQ-TIM-165**
Biometric, geofenced, or hardware-integrated time capture is out of scope for v1.

**REQ-TIM-166**
Union rule engines and CBA-governed premium stacking are out of scope for v1.

**REQ-TIM-167**
Project-based and cost-centre timesheet allocation is out of scope for v1.

**REQ-TIM-168**
Multi-country time and attendance structures are out of scope for v1.

---

## 21. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-TIM-001 | A payroll run cannot consume time entries that have not reached Approved or Locked status. A run initiated with unapproved time entries generates EXC-TIM-002 for affected employees and excludes them from the run. |
| REQ-TIM-030 | A time entry submitted without a valid Employment_ID is rejected at intake with EXC-TIM-001. No partial record is staged. |
| REQ-TIM-031 | A time entry submitted as duration-only (no start/end time) is accepted and processed identically to a punch-based entry of the same duration and category. |
| REQ-TIM-033 | A correction to a time entry preserves the original entry as a historical record. The original entry remains queryable after correction. |
| REQ-TIM-060 | An employee cannot submit a time entry for another employee's Employment_ID via self-service. The system returns an authorisation error. |
| REQ-TIM-061 | A time entry consumed by a payroll run transitions to Locked. A direct edit attempt on a Locked entry is rejected. A correction creates a new versioned entry. |
| REQ-TIM-070 | A non-exempt employee with 45 approved hours in a workweek has 40 hours classified as REGULAR and 5 hours classified as OVERTIME, generating EXC-TIM-003. |
| REQ-TIM-075 | An FLSA-exempt employee with 50 approved hours in a workweek has all 50 hours classified as REGULAR with no OVERTIME reclassification. |
| REQ-TIM-080 | All approved time entries for a payroll period are delivered to Payroll before the calculation phase. Payroll confirms receipt. Entries transition to Locked upon consumption. |
| REQ-TIM-090 | Worked time records for a closed payroll period remain queryable three years after the period end date. |
| REQ-TIM-100 | A correction to a Locked time entry generates a payroll recalculation review event to the Payroll module and is traceable via Original_Time_Entry_ID lineage. |
| REQ-TIM-110 | A batch import of 5,000 time entries via CSV produces correct Time Entry records for all valid rows and routes all invalid rows to the exception queue without posting partial records. |
| REQ-TIM-114 | A dry-run batch import reports all validation errors without staging any records. |
| REQ-TIM-121 | A manager cannot view or approve time records for employees outside their reporting hierarchy without explicit role elevation. |
| REQ-TIM-164 | INT-TIM-001 accepts time entries via both API and batch file and delivers them to Payroll within the defined SLA. |

---

## 22. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.

**REQ-TIM-180**
Employee timecard and approval status pages shall load within 2 seconds under normal load conditions.

**REQ-TIM-181**
Manager team timecard summary pages shall load within 3 seconds under normal load conditions.

**REQ-TIM-182**
Overtime threshold evaluation for a single payroll period across all employees in a run shall complete within 5 minutes for a run of 25,000 employees.

**REQ-TIM-183**
Batch time entry import of 50,000 records shall complete validation and staging within 10 minutes of file arrival.

**REQ-TIM-184**
API-submitted time entries shall receive a validation response within 2 seconds per record under normal load conditions.

**REQ-TIM-185**
The payroll handoff (time entry delivery to Payroll) for a period containing 500,000 time entries shall complete within 15 minutes of initiation.

**REQ-TIM-186**
Time entry records shall remain available for point-in-time query for a minimum of seven years from the period end date to support extended audit and legal discovery requirements.
