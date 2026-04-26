# Architecture_Model_Inventory

| Field | Detail |
|---|---|
| **Document Type** | Control Artifact |
| **Version** | v1.9 |
| **Status** | Active |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/Architecture_Model_Inventory.md` |
| **Last Updated** | April 2026 |

## Purpose

Complete inventory of all documentation artifacts in the HCM platform repository. Tracks artifact type, domain, location, lifecycle status, and confidence level. Used for completeness checking, review tracking, and onboarding orientation.

---

## Inventory

### PRD — Product Requirements

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| PRD | Platform | PRD-0000_Core_Vision | docs/PRD | Complete | Locked | Core Platform | Replaces HCM_Platform_PRD §1, §3. User stories, scope, AC, NFRs added. |
| PRD | Platform | PRD-0100_Architecture_Principles | docs/PRD | Complete | Locked | Core Platform | Replaces HCM_Platform_PRD §2. Scope, AC, NFRs added. |
| PRD | Platform | PRD-0200_Core_Entity_Model | docs/PRD | Complete | Locked | Core Platform | User stories, scope, AC, NFRs added. |
| PRD | Payroll | PRD-0300_Payroll_Calendar | docs/PRD | Complete | Locked | Payroll Domain | User stories, scope, AC, NFRs added. |
| PRD | Payroll | PRD-0400_Earnings_Model | docs/PRD | Complete | Locked | Payroll Domain | User stories, scope, AC, NFRs added. |
| PRD | Payroll | PRD-0500_Accumulator_Strategy | docs/PRD | Complete | Locked | Core Platform | User stories, scope, AC, NFRs added. |
| PRD | Compliance | PRD-0600_Jurisdiction_Model | docs/PRD | Complete | Locked | Compliance Domain | User stories, scope, AC, NFRs added. |
| PRD | Platform | PRD-0700_Workflow_Framework | docs/PRD | Complete | Locked | Core Platform | User stories, scope, AC, NFRs added. |
| PRD | Platform | PRD-0800_Validation_Framework | docs/PRD | Complete | Locked | Core Platform | User stories, scope, AC, NFRs added. |
| PRD | Platform | PRD-0900_Integration_Model | docs/PRD | Complete | Locked | Core Platform | User stories, scope, AC, NFRs added. |
| PRD | Platform / Payroll | PRD-1000_Benefits_Boundary | docs/PRD | Complete | Locked | Core Platform | Resolves v1 benefits scope ambiguity; deduction processing in scope, plan admin out of scope |
| PRD | Platform / Payroll | PRD-1100_Time_and_Attendance | docs/PRD | Complete | Locked | Core Platform | Capture/approval of worked time, delivery to payroll |
| PRD | Platform | PRD-1200_Reporting_Minimum | docs/PRD | Complete | Draft | Core Platform | Pre-built payroll operational and HR operational reports; 8 payroll reports, 8 HR reports, access control model, delivery and governance requirements |
| PRD | HRIS | HRIS_Module_PRD | docs/PRD | Complete | Draft | Core Platform | User stories, scope boundaries, 21 AC, 14 NFRs added. |

### NFR — Non-Functional Requirements

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| NFR | Platform | HCM_NFR_Specification | docs/NFR | Complete | Draft | Core Platform | Platform-wide NFRs v0.1 |

### ADR — Architecture Decision Records

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| ADR | Platform | ADR-001_Event_Driven_Architecture | docs/ADR | Complete | Accepted | Core Platform | |
| ADR | Platform | ADR-002_Deterministic_Replayability | docs/ADR | Complete | Accepted | Core Platform | |
| ADR | Platform | ADR-003_UI_Technology_Stack | docs/ADR | Complete | Accepted | Core Platform | Blazor Server on .NET Core; C# end-to-end; SignalR scale profile match for target deployment size |
| ADR | Platform | ADR-004_Data_Access_Strategy | docs/ADR | Complete | Accepted | Core Platform | Dapper micro-ORM; manual SQL; no stored procedures; DBMS portability via ADO.NET provider abstraction |
| ADR | Platform | ADR-005_Background_Job_Execution | docs/ADR | Complete | Accepted | Core Platform | IHostedService + platform_job table + Blazor SignalR; Hangfire and Quartz.NET rejected on operator visibility grounds |
| ADR | Platform | ADR-006_UI_Component_Library | docs/ADR | Complete | Accepted | Core Platform | Platform UI requires a comprehensive set of data-entry and data-display components - Syncfusion UI license exists |
| ADR | Platform | ADR-007_Module_Composition_DI_Lifetime | docs/ADR | Complete | Accepted | Core Platform | MEF for assembly discovery only; Autofac owns all lifetimes; IPlatformModule contract; menu contribution model; UI components in host assembly only |
| ADR | Platform | ADR-008_API_Surface_Architecture | docs/ADR | Complete | Accepted | Core Platform | Minimal API for HTTP endpoints; MVC explicitly excluded; Blazor Server + Minimal API coexistence pattern; no routing conflicts |
| ADR | Platform | ADR-009_Authentication_Identity_Strategy | docs/ADR | Complete | Accepted | Core Platform | OIDC provider-agnostic authentication; Keycloak as on-premises default; role mapping from JWT claims; tenant_id claim as trust anchor for ADR-010 |
| ADR | Platform | ADR-010_Tenant_Isolation_Strategy | docs/ADR | Complete | Accepted | Core Platform | Three isolation models as client deployment options (dedicated DB, shared DB, separate schema); Autofac per-request IConnectionFactory resolution; repositories unaware of isolation model |
| ADR | Platform | ADR-011_Module_Independence_Principle | docs/ADR | Complete | Accepted | Core Platform | Six rules governing module independence; event payloads in AllWorkHRIS.Core; InProcessEventBus zero-subscriber no-op; PayrollContextId nullable; schemas applied per module; subscribers register own handlers |

### DATA — Entity Specifications

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Data Entity | Core | Entity_Person | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Core | Entity_Employee | docs/DATA | Complete | Draft | Core Platform | Employment entity |
| Data Entity | Core | Entity_Assignment | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Core | Entity_Compensation_Record | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Core | Entity_Leave_Request | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Core | Entity_Document | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Core | Entity_Onboarding_Plan | docs/DATA | Complete | Draft | Core Platform | Includes Onboarding Task |
| Data Entity | Core | Entity_Org_Unit | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Core | Entity_Job | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Core | Entity_Position | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Core | Entity_Run_Scope | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Payroll | Entity_Payroll_Item | docs/DATA | Complete | Draft | Payroll Domain | |
| Data Entity | Payroll | Entity_Payroll_Run | docs/DATA | Complete | Draft | Payroll Domain | |
| Data Entity | Payroll | Entity_Payroll_Check | docs/DATA | Complete | Draft | Payroll Domain | |
| Data Entity | Payroll | Entity_Accumulator | docs/DATA | Complete | Draft | Payroll Domain | Includes Contribution history |
| Data Entity | Compliance | Entity_Legal_Order | docs/DATA | Complete | Draft | Compliance Domain | Garnishments and levies |
| Data Entity | Compliance | Entity_Jurisdiction | docs/DATA | Complete | Draft | Compliance Domain | |
| Functional Specification | Reporting | Reporting_Minimum_Module | docs/SPEC | Complete | Draft | Core Platform | 16 pre-built reports (8 payroll, 8 HR), CSV/XLSX/PDF export (ClosedXML + QuestPDF), async threshold, scheduled delivery, role-scoped access, ReportRunner shared component, 18 test cases |

### SPEC — Functional Specifications

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Spec | Payroll | External_Earnings | docs/SPEC | Complete | Draft | Payroll Domain | Inputs, outputs, error catalogue added |
| Spec | Payroll | Residual_Commissions | docs/SPEC | Complete | Draft | Payroll Domain | Extends External_Earnings; inputs, outputs, error catalogue added |
| Spec | HRIS | Self_Service_Model | docs/SPEC | Complete | Draft | Core Platform / HRIS | ESS/MSS actions, role permission matrix, event model |
| Spec | HRIS | Onboarding_Workflow | docs/SPEC | Complete | Draft | Core Platform / HRIS | Plan creation, rehire treatment, integration touch points, EXC-ONB |
| Spec | Platform | API_Contract_Standards | docs/SPEC | Complete | Draft | Core Platform | Authentication, versioning, request/response format, error handling, idempotency, rate limiting |
| Spec | Payroll | Pay_Statement_Delivery | docs/SPEC | Complete | Draft | Core Platform / Payroll | Content, format, delivery channels, retention, accessibility, security |
| Functional Specification | Platform | Temporal_Override | docs/SPEC | Complete | Draft | Core Platform | Tenant-scoped operative date displacement for non-production testing; environment-gated; governed operative date principle |
| Functional Specification | Platform | Host_Application_Shell | docs/SPEC | Complete | Draft | Core Platform | Solution structure, startup sequence, IPlatformModule contract, MenuContribution, IConnectionFactory, IUnitOfWork, shell layout, NavMenu, CSS design tokens, auth scaffold, 18 test cases |
| Spec | Platform | API_Surface_Map | docs/SPEC | Complete | Draft | Core Platform | 21 integration points across HRIS, Payroll, Benefits, Compliance, T&A (future) |
| Functional Specification | HRIS | HRIS_Core_Module | docs/SPEC | Complete | Draft | Core Platform / HRIS | Module assembly structure, repository and service interfaces, domain commands, lifecycle event pattern, event publisher, Blazor component specs for Employee List/Detail/Org pages, DateRangeFilter component, 26 test cases (v0.2 — PayrollContextId nullable, InProcessEventBus pattern, 3 independence test cases added) |
| Functional Specification | HRIS | HRIS_Leave_and_Absence | docs/SPEC | Complete | Draft | Core Platform / HRIS | Leave request lifecycle, manager approval, balance tracking, payroll impact signals, return from leave, leave_balance schema addition, 20 test cases |
| Functional Specification | HRIS | HRIS_Document_Management | docs/SPEC | Complete | Draft | Core Platform / HRIS | Document upload, versioning, supersession, I-9 and W-4 specific handling, expiration tracking, compliance alerts, access control, storage abstraction, retention rules, 20 test cases |
| Functional Specification | Payroll | Payroll_Core_Module | docs/SPEC | Complete | Draft | Core Platform / Payroll | Module assembly, HRIS event subscriptions, run initiation async pattern, ordered computation flow, accumulator 4-layer mutation chain, PayrollRunJob background service, pay register and run progress UI components, 23 test cases |
| Functional Specification | Benefits | Benefits_Minimum_Module | docs/SPEC | Complete | Draft | Core Platform | Module assembly, deduction code management, election lifecycle, versioning pattern, HRIS event integration, batch import async pattern, payroll boundary, Blazor component specs, 20 test cases |
| Functional Specification | T&A | Time_Attendance_Minimum_Module | docs/SPEC | Complete | Draft | Core Platform | Module assembly, time entry lifecycle, overtime detection and FLSA reclassification, payroll handoff, correction of locked entries, batch import, HRIS event integration, Blazor component specs, 20 test cases |
| ADR | Platform | ADR-009_Authentication_Identity_Strategy | docs/ADR | Complete | Accepted | Core Platform | OIDC provider-agnostic authentication; Keycloak as on-premises default; role mapping from JWT claims; tenant_id claim as trust anchor for ADR-010 |
| ADR | Platform | ADR-010_Tenant_Isolation_Strategy | docs/ADR | Complete | Accepted | Core Platform | Three isolation models as client deployment options (dedicated DB, shared DB, separate schema); Autofac per-request IConnectionFactory resolution; repositories unaware of isolation model |

### Conventions

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Convention | Platform | Requirement_ID_Convention | docs/conventions | Complete | Locked | Core Platform | REQ, STATE, EXC, ENT prefix taxonomy |

### STATE — State Models

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| State Model | Payroll | STATE-RLN_Run_Lineage | docs/STATE | Complete | Locked | Payroll Domain | 19 states; full run lifecycle |
| State Model | Payroll | STATE-RSC_Run_Scope | docs/STATE | Complete | Locked | Payroll Domain | 19 states; full run lifecycle |
| State Model | Platform | STATE-WFL_Workflow_Approval | docs/STATE | Complete | Locked | Core Platform | 7 states; applies to all approval workflows |
| State Model | Payroll | STATE-RUN_Payroll_Run | docs/STATE | Complete | Locked | Payroll Domain | 19 states; full run lifecycle |
| State Model | HRIS | STATE-EMP_Employment_Lifecycle | docs/STATE | Complete | Locked | Core Platform / HRIS | 14 states across Person, Employment, Position |
| State Model | HRIS | STATE-LEV_Leave_Request | docs/STATE | Complete | Locked | Core Platform / HRIS | 7 states |
| State Model | HRIS | STATE-DOC_Document | docs/STATE | Complete | Locked | Core Platform / HRIS | 4 states |
| State Model | HRIS | STATE-ONB_Onboarding_Task | docs/STATE | Complete | Locked | Core Platform / HRIS | 5 states |
| State Model | T&A | STATE-TIM_Time_Entry | docs/STATE | Complete | Draft | Core Platform / T&A | 7 states; time entry lifecycle from draft through payroll consumption; governs payroll eligibility gate |
| State Model | Payroll | STATE-DED_Benefits_Deductions | docs/STATE | Complete | Locked | Core Platform | 5 states |
| State Model | Compliance | STATE-GAR_Garnishment | docs/STATE | Complete | Locked | Compliance Domain | 6 states |
| State Model | Compliance | STATE-TAX_Tax_Elections | docs/STATE | Complete | Locked | Compliance Domain | 4 states |
| State Model | Payroll | STATE-RET_Retro_Adjustments | docs/STATE | Complete | Locked | Payroll Domain | 5 states |
| State Model | Payroll | STATE-GL_General_Ledger_Posting | docs/STATE | Complete | Locked | Payroll Domain | 5 states |
| State Model | Compliance | STATE-YEP_Year_End_Processing | docs/STATE | Complete | Locked | Compliance Domain | 5 states |
| State Model | Payroll | STATE-EXP_Export | docs/STATE | Complete | Locked | Architecture Team | 8 states |
| State Model | Compliance | STATE-REC_Reconciliation | docs/STATE | Complete | Locked | Compliance Domain | 8 states |
| State Model | Payroll | STATE-PRV_Provider_Response | docs/STATE | Complete | Locked | Architecture Team | 7 states |

### EXC — Exception Catalogues

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Exception Catalogue | Platform | EXC-VAL_Validation_Exceptions | docs/EXC | Complete | Draft | Core Platform | 10 rules; EXC-VAL-001 to 024 |
| Exception Catalogue | Payroll | EXC-CAL_Calculation_Exceptions | docs/EXC | Complete | Draft | Payroll Domain | 7 rules; EXC-CAL-001 to 007 |
| Exception Catalogue | Platform | EXC-CFG_Configuration_Exceptions | docs/EXC | Complete | Draft | Core Platform | 6 rules; EXC-CFG-001 to 006 |
| Exception Catalogue | Payroll | EXC-RUN_Payroll_Run_Exceptions | docs/EXC | Complete | Draft | Payroll Domain | 6 rules; EXC-RUN-001 to 006 |
| Exception Catalogue | Platform | EXC-INT_Integration_Exceptions | docs/EXC | Complete | Draft | Core Platform | 7 rules; EXC-INT-001 to 007 |
| Exception Catalogue | Compliance | EXC-TAX_Taxation_Exceptions | docs/EXC | Complete | Draft | Compliance Domain | 6 rules; EXC-TAX-001 to 006 |
| Exception Catalogue | Payroll | EXC-TIM_Time_Attendance_Exceptions | docs/EXC | Complete | Draft | Payroll Domain | 5 rules; EXC-TIM-001 to 005 |
| Exception Catalogue | Platform | EXC-DED_Benefits_Deductions_Exceptions | docs/EXC | Complete | Draft | Core Platform | 5 rules; EXC-DED-001 to 005 |
| Exception Catalogue | Payroll | EXC-COR_Correction_Exceptions | docs/EXC | Complete | Draft | Payroll Domain | 5 rules; EXC-COR-001 to 005 |
| Exception Catalogue | Compliance | EXC-AUD_Audit_Retention_Exceptions | docs/EXC | Complete | Draft | Compliance Domain | 4 rules; EXC-AUD-001 to 004 |
| Exception Catalogue | Compliance | EXC-SEC_Security_Access_Exceptions | docs/EXC | Complete | Draft | Compliance Domain | 4 rules; EXC-SEC-001 to 004 |

### Architecture Models — Accumulators

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Accumulators | Accumulator_Model_Detailed | docs/accumulators | Complete | Approved | Core Platform | Yes | High |

### Architecture Models — Calculation Engine

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Calculation Engine | Accumulator_and_Balance_Model | docs/architecture/calculation-engine | Complete | Approved | Architecture Team | Yes | High |
| Model | Calculation Engine | Calculation_Engine | docs/architecture/calculation-engine | Complete | Approved | Architecture Team | Yes | High |
| Model | Calculation Engine | Earnings_and_Deductions_Computation_Model | docs/architecture/calculation-engine | Complete | Approved | Architecture Team | Yes | High |
| Model | Calculation Engine | External_Result_Import_Specification | docs/architecture/calculation-engine | Complete | Approved | Architecture Team | Yes | High |
| Model | Calculation Engine | Net_Pay_and_Disbursement_Model | docs/architecture/calculation-engine | Complete | Approved | Architecture Team | Yes | High |
| Model | Calculation Engine | Result_and_Payable_Model | docs/architecture/calculation-engine | Complete | Approved | Architecture Team | Yes | High |

### Architecture Models — Core

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Core | Accrual_and_Entitlement_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Benefit_and_Deduction_Configuration_Model | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |
| Model | Core | Benefit_Deduction_Election_Model | docs/architecture/core | Complete | Draft | Core Platform | Yes | High |
| Model | Core | Compensation_and_Pay_Rate_Model | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |
| Model | Core | Eligibility_and_Enrollment_Lifecycle_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Employee_Assignment_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Employee_Event_and_Status_Change_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Employment_and_Person_Identity_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Leave_and_Absence_Management_Model | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |
| Model | Core | Organizational_Structure_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Overtime_and_Premium_Pay_Model | docs/architecture/core | Complete | Draft | Core Platform | Yes | High |
| Model | Core | Plan_and_Rule_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Platform_Composition_and_Extensibility_Model | docs/architecture/core | Complete | Draft | Core Platform | Yes | High |
| Model | Core | Position_Management_Model | docs/architecture/core | Complete | Draft | Core Platform / HRIS | Yes | High | Advisory position control; headcount at position and dept level |
| Model | Core | Reference_Data_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Reporting_Hierarchy_Model | docs/architecture/core | Complete | Draft | Core Platform / HRIS | Yes | High | E-to-E manager relationship; org chart; v1 primary only |
| Model | Core | Scheduling_and_Shift_Model | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |
| Model | Core | Tenant_Client_Company_Legal_Entity_and_Jurisdiction_Structural_Relationship_Map | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |
| Model | Core | Time_Entry_and_Worked_Time_Model | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |

### Architecture Models — Data

| Model | Core | Address_Association_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Address_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Client_Company_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Document_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Employment_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Funding_Profile_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Jurisdiction_Registration_and_Profile_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Legal_Entity_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Net_Pay_Disbursement_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Payment_Instruction_Profile_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Person_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Remittance_Profile_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Role_and_Permission_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Tenant_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | User_Account_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |
| Model | Core | Work_Location_Data_Model | docs/architecture/data | Complete | Draft | Core Platform / HRIS | Yes | High |

### Architecture Models — Governance

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Governance | Configuration_and_Metadata_Management_Model | docs/architecture/governance | Complete | Approved | Compliance Domain | Yes | High |
| Model | Governance | Correction_and_Immutability_Model | docs/architecture/governance | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Governance | Data_Retention_and_Archival_Model | docs/architecture/governance | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Governance | Garnishment_and_Legal_Order_Model | docs/architecture/governance | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Governance | Jurisdiction_and_Compliance_Rules_Model | docs/architecture/governance | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Governance | Payroll_Reconciliation_Model | docs/architecture/governance | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Governance | Regulatory_and_Compliance_Reporting_Model | docs/architecture/governance | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Governance | Release_and_Approval_Model | docs/architecture/governance | Complete | Approved | Compliance Domain | Yes | High |
| Model | Governance | Security_and_Access_Control_Model | docs/architecture/governance | Complete | Approved | Compliance Domain | Yes | High |

### Architecture Models — Interfaces

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Interfaces | General_Ledger_and_Accounting_Export_Model | docs/architecture/interfaces | Complete | Reviewed | Core Platform | Yes | High |
| Model | Interfaces | Integration_and_Data_Exchange_Model | docs/architecture/interfaces | Complete | Reviewed | Core Platform | Yes | High |
| Model | Interfaces | Pay_Statement_Model | docs/architecture/interfaces | Complete | Reviewed | Core Platform | Yes | High |
| Model | Interfaces | Pay_Statement_Template_Model | docs/architecture/interfaces | Complete | Draft | Core Platform | Yes | High |
| Model | Interfaces | Payroll_Funding_and_Cash_Management_Model | docs/architecture/interfaces | Complete | Reviewed | Core Platform | Yes | High |
| Model | Interfaces | Payroll_Interface_and_Export_Model | docs/architecture/interfaces | Complete | Reviewed | Core Platform | Yes | High |
| Model | Interfaces | Payroll_Provider_Response_Model | docs/architecture/interfaces | Complete | Draft | Core Platform | Yes | High |
| Model | Interfaces | Provider_Billing_and_Charge_Model | docs/architecture/interfaces | Complete | Reviewed | Core Platform | Yes | High |

### Architecture Models — Operations

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Operations | Attendance_and_Exception_Tracking_Model | docs/architecture/operations | Complete | Draft | Payroll Domain | Yes | High |
| Model | Operations | Exception_and_Work_Queue_Model | docs/architecture/operations | Complete | Draft | Payroll Domain | Yes | High |
| Model | Operations | Monitoring_and_Alerting_Model | docs/architecture/operations | Complete | Draft | Payroll Domain | Yes | High |
| Model | Operations | Operational_Reporting_and_Analytics_Model | docs/architecture/operations | Complete | Reviewed | Payroll Domain | Yes | High |
| Model | Operations | Run_Visibility_and_Dashboard_Model | docs/architecture/operations | Complete | Draft | Payroll Domain | Yes | High |
| Model | Operations | System_Initialization_and_Bootstrap_Model | docs/architecture/operations | Complete | Draft | Payroll Domain | Yes | High |
| Model | Operations | System_Maintenance_and_Upgrade_Model | docs/architecture/operations | Complete | Draft | Payroll Domain | Yes | High |

### Architecture Models — Payroll

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Payroll | Holiday_and_Special_Calendar_Model | docs/architecture/payroll | Complete | Draft | Payroll Domain | Yes | High |
| Model | Payroll | Multi_Context_Calendar_Model | docs/architecture/payroll | Complete | Draft | Payroll Domain | Yes | High |
| Model | Payroll | Payroll_Calendar_Model | docs/architecture/payroll | Complete | Draft | Payroll Domain | Yes | High |
| Model | Payroll | Payroll_Context_Model | docs/architecture/payroll | Complete | Approved | Payroll Domain | Yes | High |

### Architecture Models — Processing

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Processing | Accumulator_Definition_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Accumulator_Impact_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Async_Job_Execution_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Calculation_Run_Lifecycle | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Employee_Payroll_Result_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Error_Handling_and_Isolation_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Payroll_Adjustment_and_Correction_Model.md | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Payroll_Check_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Payroll_Exception_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | processing | Payroll_Run_Funding_and_Remittance_Map | docs/architecture/processing | Complete | Draft | Payroll Domain  | Yes | High |
| Model | Processing | Payroll_Run_Model | docs/architecture/processing | Complete | Approved | Payroll Domain | Yes | High |
| Model | Processing | Payroll_Run_Result_Set_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Processing_Lineage_Validation_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Run_Linkage_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Run_Scope_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Async_Job_Execution_Model | docs/architecture/processing | Complete | Draft | Core Platform | Governs background job execution tier; job entity, job types, status lifecycle, progress reporting, retry, priority, dashboard integration |

### Architecture Models — Rules

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Rules | Code_Classification_and_Mapping_Model | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Policy_and_Rule_Execution_Model | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Posting_Rules_and_Mutation_Semantics | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Rule_Pack_Model | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Rule_Resolution_Engine | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Rule_Versioning_Model | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Tax_Classification_and_Obligation_Model | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |

---

## Control Artifacts

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Control Artifact | Architecture Control | Architecture_Model_Inventory | docs/architecture | Active | Draft | Core Platform | This document — v3.0 |
| Control Artifact | Architecture Control | PRD_to_Architecture_Coverage_Map | docs/architecture | Active | Draft | Core Platform | Traceability artifact |

---

### Build — Build Planning Artifacts

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Build Plan | Platform | Build_Sequence_Plan | docs/build | Complete | Active | Core Platform | 9-phase build sequence; Phase 0 HRIS schema only; Phase 2 includes HRIS Standalone Test (8 steps); Payroll schema added at Phase 4; dependency map; NuGet package reference (v0.2) |
---

## Legend

| Field | Values |
|---|---|
| Status | Complete / In Progress / Stub |
| Lifecycle Status | Draft / Reviewed / Approved / Locked / Accepted / Retired |
| Confidence Level | High / Medium / Low / Unknown |
| Implementation Status | Not Started / In Design / In Build / Verified / Operational |
