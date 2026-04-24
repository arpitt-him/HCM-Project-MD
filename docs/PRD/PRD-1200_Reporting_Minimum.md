# PRD-1200 — Reporting (Minimum Viable)

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Module Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-1200_Reporting_Minimum.md` |
| **Date** | April 2026 |
| **Related Documents** | PRD-0000_Core_Vision, PRD-0100_Architecture_Principles, PRD-0400_Earnings_Model, PRD-0500_Accumulator_Strategy, PRD-0700_Workflow_Framework, PRD-0800_Validation_Framework, HRIS_Module_PRD, PRD-1100_Time_and_Attendance, Operational_Reporting_and_Analytics_Model, Run_Visibility_and_Dashboard_Model, Monitoring_and_Alerting_Model, Security_and_Access_Control_Model |

---

## Purpose

Defines the minimum viable requirements for the Reporting module — the smallest set of pre-built, system-generated reports that allows operators, administrators, and managers to run the business, process payroll, and manage their workforce without requiring custom report development or data exports.

This PRD covers two report domains:

- **Payroll operational reports** — reports derived from payroll execution artifacts that support run management, post-run review, and financial oversight
- **HR operational reports** — reports derived from HRIS data that support workforce management, compliance tracking, and administrative oversight

Regulatory and statutory filing reports (Form 941, W-2, state quarterly reports) are governed by the Compliance domain and are explicitly out of scope for this PRD.

User-designed reports, ad-hoc query tools, analytical data feeds, and workforce analytics dashboards are out of scope for v1 and are addressed by the future Reporting (advanced) module.

This document is a self-contained module specification. It inherits and applies the platform-level principles defined in `PRD-0100_Architecture_Principles.md` without repeating or modifying them.

---

## Section Map

| § | Section | What it covers |
|---|---|---|
| 1 | Module Vision and Strategic Purpose | Why this module exists; its role in the platform |
| 2 | Module Scope | In scope, out of scope, and domain boundaries |
| 3 | Inherited Architectural Principles | Platform principles as applied to Reporting |
| 4 | Report Catalogue — Payroll Operational | Required payroll reports with definitions |
| 5 | Report Catalogue — HR Operational | Required HR reports with definitions |
| 6 | Report Delivery Model | How reports are accessed, exported, and scheduled |
| 7 | Report Governance | Effective dating, reproducibility, and correction awareness |
| 8 | Access Control | Role-scoped access model |
| 9 | Architecture Model Dependencies | Governing architecture models |
| 10 | Future Expansion Considerations | Out-of-scope capabilities planned for later phases |
| 11 | User Stories | Role-based user stories |
| 12 | Scope Boundaries | Explicit in-scope and out-of-scope requirement statements |
| 13 | Acceptance Criteria | Testable acceptance criteria per requirement |
| 14 | Non-Functional Requirements | Domain-specific SLA targets |

---

## 1. Module Vision and Strategic Purpose

**REQ-RPT-001**
The Reporting module shall provide pre-built, system-generated operational reports that support day-to-day management of payroll execution and HR administration without requiring custom development or raw data access.

**REQ-RPT-002**
Payroll operational reports shall be derived exclusively from governed payroll execution artifacts. Reports shall not introduce independent financial values or override governed payroll results.

**REQ-RPT-003**
HR operational reports shall be derived exclusively from governed HRIS records. Reports shall not introduce independent employment data or override HRIS-owned records.

**REQ-RPT-004**
All reports shall remain reproducible. A report generated for a historical period shall produce the same results when regenerated from archived data, subject only to governed corrections.

**REQ-RPT-005**
All reports shall resolve data as of an effective date, not a recorded date.

**REQ-RPT-006**
Report access shall be role-scoped. No report shall expose data beyond the viewer's authorised scope.

---

## 2. Module Scope

### In Scope (v1)

- Pre-built payroll operational reports derived from payroll execution artifacts
- Pre-built HR operational reports derived from HRIS records
- Report delivery via on-screen view and file export (CSV, PDF)
- Scheduled report delivery to configured recipients
- Role-scoped access enforcement on all reports
- Effective-date-based data resolution for all reports
- Correction-aware historical reporting

### Out of Scope (v1)

- Regulatory and statutory filing reports (Form 941, W-2, state quarterly — owned by Compliance domain)
- Time & Attendance reports (owned by T&A module — defined in PRD-1100 §15)
- User-designed or ad-hoc reports
- Configurable report templates and custom field selection
- Analytical data feeds and structured exports to external systems
- Workforce analytics and predictive modelling
- Embedded report builder or drag-and-drop report design

### Boundary with Payroll Module

**REQ-RPT-010**
The Reporting module shall consume payroll execution artifacts as read-only inputs. It shall not write to or modify any payroll record.

**REQ-RPT-011**
Payroll operational reports shall only reflect results from runs in STATE-RUN-008 (Calculated) or later, unless the report is explicitly a pre-calculation readiness or exception report.

### Boundary with HRIS Module

**REQ-RPT-012**
The Reporting module shall consume HRIS records as read-only inputs. It shall not write to or modify any HRIS record.

**REQ-RPT-013**
HR operational reports shall resolve employment state using effective-dated HRIS records. Point-in-time resolution shall be consistent with HRIS effective-dating rules.

---

## 3. Inherited Architectural Principles

The Reporting module inherits and applies all principles from PRD-0100_Architecture_Principles:

**REQ-RPT-015**
The Reporting module shall be independently deployable. Its absence shall not affect payroll calculation, HRIS record management, or any other module's core function.

**REQ-RPT-016**
All report output shall be derived from governed, versioned source records. Reports shall never introduce values that are not traceable to a governed source artifact.

**REQ-RPT-017**
Historical reports shall remain reproducible from archived data. Report reproducibility is a first-class requirement, not an aspirational goal.

**REQ-RPT-018**
Corrections to payroll or HR source data shall be reflected in reports as governed corrections, with prior and corrected values distinguishable where the report type supports it.

---

## 4. Report Catalogue — Payroll Operational

**REQ-RPT-020**
The platform shall deliver the following payroll operational reports in v1:

---

### PAY-RPT-001 — Payroll Register

| Field | Detail |
|---|---|
| **Purpose** | Complete record of all payroll results for a run — earnings, deductions, taxes, and net pay per employee |
| **Primary Users** | Payroll Administrator, Finance |
| **Source Artifacts** | Employee_Payroll_Result, Payroll_Check, Payroll_Item |
| **Filters** | Run_ID, Payroll_Context_ID, Legal_Entity, Department, Employment_Status |
| **Key Fields** | Employee name, Employment_ID, pay period, gross pay, pre-tax deductions, taxable wages, tax withholdings, post-tax deductions, net pay, payment method |
| **Subtotals** | By department, legal entity, payroll context |
| **Notes** | Available from STATE-RUN-008 (Calculated) onward |

---

### PAY-RPT-002 — Gross-to-Net Summary

| Field | Detail |
|---|---|
| **Purpose** | Aggregated summary of gross pay, deductions, taxes, and net pay for a run — used for financial reconciliation and funding confirmation |
| **Primary Users** | Payroll Administrator, Finance, Controller |
| **Source Artifacts** | Payroll_Run_Result_Set, Employee_Payroll_Result |
| **Filters** | Run_ID, Legal_Entity, Payroll_Context_ID |
| **Key Fields** | Total gross pay, total pre-tax deductions, total taxable wages, total employee taxes, total employer taxes, total post-tax deductions, total net pay, total employer cost |
| **Subtotals** | By legal entity, by payroll context |
| **Notes** | Supports funding confirmation prior to payment release |

---

### PAY-RPT-003 — Employer Cost Report

| Field | Detail |
|---|---|
| **Purpose** | Total employer cost per employee and in aggregate — gross pay plus employer tax obligations and employer benefit contributions |
| **Primary Users** | Finance, Controller, HR Administrator |
| **Source Artifacts** | Employee_Payroll_Result, Payroll_Item, Accumulator_Impact |
| **Filters** | Run_ID, Department, Legal_Entity, Cost_Center |
| **Key Fields** | Employee gross pay, employer FICA, employer SUI, employer FUTA, employer benefit contributions, total employer cost |
| **Subtotals** | By department, cost centre, legal entity |

---

### PAY-RPT-004 — Payroll Exception Report

| Field | Detail |
|---|---|
| **Purpose** | All exceptions raised during a payroll run — severity, status, and resolution state |
| **Primary Users** | Payroll Administrator, Payroll Operator |
| **Source Artifacts** | Payroll_Exception_Model, Exception_and_Work_Queue_Model |
| **Filters** | Run_ID, Exception_Severity, Exception_Status, Department |
| **Key Fields** | Exception code, name, severity, affected employee, description, current status, assigned operator, resolution timestamp |
| **Notes** | Includes Hard Stop, Hold, Warning, and Informational exceptions |

---

### PAY-RPT-005 — YTD Accumulator Balance Report

| Field | Detail |
|---|---|
| **Purpose** | Year-to-date, quarter-to-date, and period-to-date accumulator balances per employee |
| **Primary Users** | Payroll Administrator, Finance, Compliance |
| **Source Artifacts** | Accumulator_Balance, Accumulator_Impact, Accumulator_Contribution |
| **Filters** | Employment_ID, Accumulator_Family, Period_Context (PTD / QTD / YTD / LTD), Legal_Entity |
| **Key Fields** | Employee name, Employment_ID, accumulator name, period context, opening balance, period contribution, closing balance, last updated run |

---

### PAY-RPT-006 — Payroll Variance Report

| Field | Detail |
|---|---|
| **Purpose** | Period-over-period variance in gross pay, deductions, and net pay per employee — highlights unexpected changes for pre-approval review |
| **Primary Users** | Payroll Administrator, Finance |
| **Source Artifacts** | Employee_Payroll_Result (current and prior period) |
| **Filters** | Run_ID, Variance_Threshold (configurable %), Department, Legal_Entity |
| **Key Fields** | Employee name, prior gross, current gross, gross variance %, prior net, current net, net variance %, variance flag |
| **Notes** | Variance threshold is configurable. Employees exceeding threshold are flagged. |

---

### PAY-RPT-007 — Payment Disbursement Report

| Field | Detail |
|---|---|
| **Purpose** | Record of all payment disbursements for a run — method, amount, and status per employee |
| **Primary Users** | Payroll Administrator, Finance |
| **Source Artifacts** | Payroll_Check, Disbursement_Model |
| **Filters** | Run_ID, Payment_Method (ACH / Check / Wire), Legal_Entity |
| **Key Fields** | Employee name, Employment_ID, payment method, bank/account reference (masked), net pay amount, disbursement status, disbursement date |

---

### PAY-RPT-008 — Tax Liability Summary

| Field | Detail |
|---|---|
| **Purpose** | Aggregated employee and employer tax liabilities by jurisdiction for a run or period |
| **Primary Users** | Payroll Administrator, Tax, Finance |
| **Source Artifacts** | Employee_Payroll_Result, Tax_Classification_and_Obligation_Model, Accumulator_Impact |
| **Filters** | Run_ID, Jurisdiction_Level (Federal / State / Local), Legal_Entity |
| **Key Fields** | Jurisdiction name, tax type, employee liability, employer liability, total liability, YTD liability |
| **Notes** | Supports pre-remittance review; does not replace regulatory filing reports |

---

## 5. Report Catalogue — HR Operational

**REQ-RPT-030**
The platform shall deliver the following HR operational reports in v1:

---

### HR-RPT-001 — Active Headcount Report

| Field | Detail |
|---|---|
| **Purpose** | Current active employee count by department, location, legal entity, and employment type |
| **Primary Users** | HR Administrator, Manager, Finance |
| **Source Artifacts** | Employment, Assignment, Org_Unit |
| **Filters** | Effective_Date, Legal_Entity, Department, Location, Employment_Type, FLSA_Classification |
| **Key Fields** | Org unit, headcount, full-time count, part-time count, exempt count, non-exempt count |
| **Notes** | Point-in-time resolution — effective date must be specified |

---

### HR-RPT-002 — New Hire and Termination Report

| Field | Detail |
|---|---|
| **Purpose** | Employees hired and terminated within a specified period — supports turnover tracking and onboarding follow-up |
| **Primary Users** | HR Administrator, Finance |
| **Source Artifacts** | Employment, Employee_Event_and_Status_Change |
| **Filters** | Period_Start, Period_End, Event_Type (Hire / Termination / Rehire), Department, Legal_Entity |
| **Key Fields** | Employee name, Employment_ID, event type, effective date, department, location, employment type, termination reason (where applicable) |

---

### HR-RPT-003 — Turnover Report

| Field | Detail |
|---|---|
| **Purpose** | Employee turnover rate by department and legal entity for a specified period |
| **Primary Users** | HR Administrator, Finance, Executive |
| **Source Artifacts** | Employment, Employee_Event_and_Status_Change |
| **Filters** | Period_Start, Period_End, Department, Legal_Entity |
| **Key Fields** | Opening headcount, terminations, voluntary terminations, involuntary terminations, turnover rate %, average headcount |
| **Notes** | Voluntary / involuntary split requires Termination_Reason_Code classification |

---

### HR-RPT-004 — Leave Utilisation and Balance Report

| Field | Detail |
|---|---|
| **Purpose** | Leave balances and utilisation per employee and in aggregate — supports leave liability tracking and accrual review |
| **Primary Users** | HR Administrator, Finance, Manager |
| **Source Artifacts** | Leave_Request, Accrual_and_Entitlement_Model, Accumulator_Balance |
| **Filters** | Effective_Date, Leave_Type, Department, Legal_Entity, Employment_Status |
| **Key Fields** | Employee name, Employment_ID, leave type, accrued balance, used balance, remaining balance, pending requests |

---

### HR-RPT-005 — Open Position Report

| Field | Detail |
|---|---|
| **Purpose** | Positions currently unfilled relative to approved headcount — supports vacancy tracking and hiring prioritisation |
| **Primary Users** | HR Administrator, Manager, Finance |
| **Source Artifacts** | Position, Assignment, Org_Unit |
| **Filters** | Effective_Date, Department, Location, Legal_Entity, Position_Status |
| **Key Fields** | Position name, department, location, budgeted headcount, filled headcount, vacant count, position status, days vacant |
| **Notes** | Requires Position_Management_Model and headcount budget configuration |

---

### HR-RPT-006 — Compensation Summary Report

| Field | Detail |
|---|---|
| **Purpose** | Current compensation rates by employee, department, and legal entity — supports budgeting and equity review |
| **Primary Users** | HR Administrator, Finance, Manager (scoped) |
| **Source Artifacts** | Compensation_Record, Employment, Assignment |
| **Filters** | Effective_Date, Department, Legal_Entity, Employment_Type, Pay_Rate_Type |
| **Key Fields** | Employee name, Employment_ID, pay rate type, pay rate, annual equivalent, department, location, employment type |
| **Notes** | Manager access scoped to direct reports only per Security_and_Access_Control_Model |

---

### HR-RPT-007 — Onboarding Status Report

| Field | Detail |
|---|---|
| **Purpose** | Onboarding task completion status for new hires — identifies blocking tasks outstanding at or after start date |
| **Primary Users** | HR Administrator, Manager |
| **Source Artifacts** | Onboarding_Plan, Onboarding_Task, Employment |
| **Filters** | Period_Start, Period_End, Task_Status, Blocking_Flag, Department |
| **Key Fields** | Employee name, Employment_ID, start date, task name, task type, blocking flag, due date, completion date, current status |

---

### HR-RPT-008 — Document Expiration Report

| Field | Detail |
|---|---|
| **Purpose** | HR documents approaching or past their expiration date — supports I-9 re-verification and certification renewal tracking |
| **Primary Users** | HR Administrator, Compliance |
| **Source Artifacts** | Document, Person, Employment |
| **Filters** | Expiration_Window (days), Document_Type, Legal_Entity, Employment_Status |
| **Key Fields** | Employee name, Employment_ID, document type, expiration date, days until expiration, document status |

---

## 6. Report Delivery Model

**REQ-RPT-040**
All reports shall be available for on-screen viewing within the platform UI.

**REQ-RPT-041**
All reports shall support export in CSV format. Reports with structured layout (payroll register, pay statement) shall additionally support PDF export.

**REQ-RPT-042**
The platform shall support scheduled report delivery — a report may be configured to generate automatically at a defined frequency (daily, weekly, per payroll run) and delivered to configured recipients via secure in-platform notification or email.

**REQ-RPT-043**
Scheduled report delivery shall be role-scoped. A scheduled report shall only be deliverable to recipients whose role authorises access to the report's data scope.

**REQ-RPT-044**
All report exports shall be logged in the audit trail with the exporting user's identity, timestamp, report type, and scope parameters.

---

## 7. Report Governance

**REQ-RPT-050**
All reports shall resolve source data using effective-dated records. Reports shall not expose data based on insertion or update timestamps.

**REQ-RPT-051**
All reports shall be reproducible. Regenerating a report for a historical period from archived data shall produce results consistent with the original run, subject to governed corrections.

**REQ-RPT-052**
Where source data has been corrected since a report was first generated, the report shall reflect the corrected values when regenerated. The correction lineage shall remain traceable to the source correction record.

**REQ-RPT-053**
Reports derived from payroll execution artifacts shall identify the Payroll_Run_ID and Payroll_Run_Result_Set_ID that served as their data source.

**REQ-RPT-054**
Reports shall not be used as a mechanism to override or post-process governed payroll or HR results. Any discrepancy identified through a report shall be corrected through the governed correction workflow in the source module.

---

## 8. Access Control

**REQ-RPT-060**
All report access shall be governed by the Security_and_Access_Control_Model. No report shall be accessible without role-based authorisation.

**REQ-RPT-061**
Report scope enforcement shall apply to all dimensions — legal entity, client company, department, and employment scope. A user shall not be able to access report data outside their authorised scope by applying filters.

**REQ-RPT-062**
The following default access model shall apply:

| Role | Payroll Operational Reports | HR Operational Reports |
|---|---|---|
| Payroll Administrator | Full access within authorised payroll context | No access (HR-owned data) |
| HR Administrator | No access (payroll result detail) | Full access within authorised org scope |
| Finance / Controller | Gross-to-Net, Employer Cost, Tax Liability, YTD Accumulators | Headcount, Compensation Summary, Turnover |
| Manager | No access | Scoped to direct reports only — Headcount, Leave, Onboarding Status |
| Payroll Operator | Payroll Register, Exception Report, Disbursement | No access |
| Auditor | Read-only access to all reports within authorised scope | Read-only access to all reports within authorised scope |
| Employee | Pay statements only (governed by PRD-0400 and SPEC/Pay_Statement_Delivery.md) | Own record only |

**REQ-RPT-063**
The default access model shall be configurable by an administrator. Role-to-report mappings may be adjusted within the platform without a code change.

---

## 9. Architecture Model Dependencies

The Reporting module is built on the following existing platform architecture models:

| Architecture Model | Role in Reporting |
|---|---|
| Operational_Reporting_and_Analytics_Model | Governs report categories, metric definitions, data aggregation sources, and time-series behaviour |
| Run_Visibility_and_Dashboard_Model | Governs payroll run-level operational visibility and dashboard views |
| Monitoring_and_Alerting_Model | Governs operational alert state surfaced in exception and run reports |
| Employee_Payroll_Result_Model | Primary source for all payroll operational report data |
| Payroll_Run_Model | Governs run context, period, and status used as report filters |
| Accumulator_and_Balance_Model | Source for YTD and period accumulator balance reports |
| Payroll_Exception_Model | Source for exception report data |
| Employment_and_Person_Identity_Model | Source for all HR report identity resolution |
| Organizational_Structure_Model | Source for department, location, and legal entity dimensions in all reports |
| Leave_and_Absence_Management_Model | Source for leave utilisation and balance report data |
| Compensation_and_Pay_Rate_Model | Source for compensation summary report data |
| Data_Retention_and_Archival_Model | Governs availability of historical report data for reproduction |
| Security_and_Access_Control_Model | Governs role-based report access and scope enforcement |
| Correction_and_Immutability_Model | Governs how corrections are reflected in historical report reproduction |

---

## 10. Future Expansion Considerations

Planned capabilities not in Reporting (minimum) scope:

- User-designed reports and ad-hoc query tools
- Configurable report templates with custom field selection
- Structured data exports and analytical feeds to external systems (Workforce Analytics, BI tools)
- Embedded report builder or drag-and-drop design interface
- Workforce analytics — trend analysis, predictive attrition, compensation benchmarking
- Regulatory and statutory filing report generation (governed by Compliance domain)
- Real-time streaming report data

---

## 11. User Stories

**Payroll Administrator** needs to **review the complete payroll register and gross-to-net summary before approving a run** in order to **verify that all employees have been paid correctly and no unexpected amounts appear before payment is released.**

**Finance Controller** needs to **access the employer cost report and tax liability summary for each payroll run** in order to **confirm funding requirements, post accurate journal entries, and manage tax remittance obligations.**

**HR Administrator** needs to **view current headcount, new hire and termination activity, and leave balances** in order to **manage workforce planning, respond to management requests, and maintain compliance with leave obligations without extracting data from the system.**

**Manager** needs to **view the onboarding status of new hires in their team and leave balances for direct reports** in order to **track readiness for new starters and plan for upcoming absences without requiring HR to pull the data manually.**

**Payroll Operator** needs to **access the payroll exception report during a run** in order to **identify and resolve exceptions before the approval deadline without navigating individual employee records.**

**Compliance Auditor** needs to **reproduce any operational report for any historical period from archived data** in order to **respond to audit requests with accurate, point-in-time data without relying on screenshots or manual records.**

**Payroll Administrator** needs to **identify employees whose pay has changed significantly period-over-period** in order to **investigate unexpected variances before approving the run and avoid releasing incorrect payments.**

---

## 12. Scope Boundaries

### In Scope — v1

**REQ-RPT-070**
All eight payroll operational reports defined in §4 (PAY-RPT-001 through PAY-RPT-008) shall be delivered in v1.

**REQ-RPT-071**
All eight HR operational reports defined in §5 (HR-RPT-001 through HR-RPT-008) shall be delivered in v1.

**REQ-RPT-072**
On-screen viewing, CSV export, and PDF export shall be supported for all reports in v1.

**REQ-RPT-073**
Scheduled report delivery shall be supported in v1.

**REQ-RPT-074**
Role-scoped access enforcement as defined in §8 shall be implemented in v1.

**REQ-RPT-075**
Effective-date-based data resolution and historical reproducibility shall be implemented for all reports in v1.

### Out of Scope — v1

**REQ-RPT-076**
Regulatory and statutory filing reports are out of scope for this PRD. They are governed by the Compliance domain.

**REQ-RPT-077**
T&A operational reports (timecard status, hours summary, unapproved time, overtime alert, payroll handoff confirmation) are out of scope for this PRD. They are defined in PRD-1100 §15.

**REQ-RPT-078**
User-designed reports, ad-hoc query tools, configurable templates, and custom field selection are out of scope for v1.

**REQ-RPT-079**
Structured data exports to external analytics systems and workforce analytics capabilities are out of scope for v1.

---

## 13. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-RPT-002 | The payroll register for a completed run contains every employee in the run with correct gross pay, deductions, taxes, and net pay, traceable to the governing Payroll_Run_ID. |
| REQ-RPT-004 | A payroll register regenerated for a closed period from archived data produces results identical to the original, subject to any governed corrections applied since closing. |
| REQ-RPT-005 | A headcount report generated with an effective date of 90 days ago reflects the employment state on that date, not today's state. |
| REQ-RPT-011 | A payroll operational report cannot be generated for a run in STATE-RUN-007 (Calculating) or earlier. The system returns an appropriate error. |
| REQ-RPT-041 | Every report can be exported to CSV. The payroll register and gross-to-net summary can additionally be exported to PDF. |
| REQ-RPT-050 | The compensation summary report reflects compensation rates effective on the report date, not the most recently entered rate. |
| REQ-RPT-060 | A manager accessing the headcount report sees only employees within their reporting hierarchy. Applying a department filter outside their scope returns no results rather than exposing out-of-scope data. |
| REQ-RPT-061 | A payroll operator cannot access the compensation summary report. An HR administrator cannot access the payroll register. Access control is enforced at the report level, not only at the UI navigation level. |
| REQ-RPT-042 | A scheduled payroll register configured to run after each payroll run is delivered to the configured recipient within 15 minutes of run approval. |
| PAY-RPT-006 | The payroll variance report flags all employees whose gross pay has changed by more than the configured threshold percentage compared to the prior period. |
| HR-RPT-008 | The document expiration report correctly identifies all I-9 documents expiring within the configured window, including employees whose I-9 was re-verified. |

---

## 14. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.

**REQ-RPT-080**
The payroll register for a run of 25,000 employees shall be generated and available for on-screen viewing within 3 minutes of the report request.

**REQ-RPT-081**
All HR operational reports shall return results within 10 seconds for an organisation of up to 50,000 active employment records.

**REQ-RPT-082**
CSV export of any report shall complete within 2 minutes regardless of result set size.

**REQ-RPT-083**
PDF export of the payroll register for a run of up to 25,000 employees shall complete within 5 minutes.

**REQ-RPT-084**
Scheduled reports shall be delivered within 15 minutes of their configured trigger event.

**REQ-RPT-085**
All report data shall be accessible for reproduction for a minimum of seven years from the period end date, consistent with the Data_Retention_and_Archival_Model.

**REQ-RPT-086**
Report pages shall load within 3 seconds under normal load conditions. Parameterised filter changes (e.g., changing department filter) shall re-render within 2 seconds.
