# Documentation Index

This index lists every document in the repository and its purpose. It is the starting point for navigating the HCM platform documentation.

**In-scope modules (v1):** HRIS, Payroll, Benefits Administration (minimum), Time & Attendance (minimum), Reporting (minimum)
**Platform status:** In Design

---

## PRD — Product Requirements

Product requirements documents define *what* the system must do and *why*. They are the authoritative source of functional scope for all modules.

### Platform PRDs

| Document | Purpose |
|---|---|
| [PRD-0000_Core_Vision.md](docs/PRD/PRD-0000_Core_Vision.md) | Platform vision, module roadmap, deployment model, and data entry channels |
| [PRD-0100_Architecture_Principles.md](docs/PRD/PRD-0100_Architecture_Principles.md) | Non-negotiable architectural principles governing all design decisions |
| [PRD-0200_Core_Entity_Model.md](docs/PRD/PRD-0200_Core_Entity_Model.md) | Conceptual entity model — primary objects, relationships, and identity anchoring |
| [PRD-0300_Payroll_Calendar.md](docs/PRD/PRD-0300_Payroll_Calendar.md) | Pay frequency support, period structure, and calendar governance |
| [PRD-0400_Earnings_Model.md](docs/PRD/PRD-0400_Earnings_Model.md) | Supported earning types, external earnings requirements, and import methods |
| [PRD-0500_Accumulator_Strategy.md](docs/PRD/PRD-0500_Accumulator_Strategy.md) | Accumulator scopes, period granularities, and integrity requirements |
| [PRD-0600_Jurisdiction_Model.md](docs/PRD/PRD-0600_Jurisdiction_Model.md) | Supported jurisdiction levels and multi-jurisdiction handling principles |
| [PRD-0700_Workflow_Framework.md](docs/PRD/PRD-0700_Workflow_Framework.md) | Approval workflow applicability, states, and configuration requirements |
| [PRD-0800_Validation_Framework.md](docs/PRD/PRD-0800_Validation_Framework.md) | Validation phases, exception categories, and configuration readiness checks |
| [PRD-0900_Integration_Model.md](docs/PRD/PRD-0900_Integration_Model.md) | Integration patterns, inbound/outbound requirements, formats, and security |
| [PRD-1000_Benefits_Boundary.md](docs/PRD/PRD-1000_Benefits_Boundary.md) | Defines deduction code structure and pre/post-tax classification used by payroll |
| [PRD-1100_Time_and_Attendance.md](docs/PRD/PRD-1100_Time_and_Attendance.md) | Capture and approval of worked time and correct delivery to payroll |

### Module PRDs

| Document | Purpose |
|---|---|
| [HRIS_Module_PRD.md](docs/PRD/HRIS_Module_PRD.md) | HRIS module scope, entity model, lifecycle events, self-service, and integration |

---

## NFR — Non-Functional Requirements

| Document | Purpose |
|---|---|
| [HCM_NFR_Specification.md](docs/NFR/HCM_NFR_Specification.md) | Platform-wide non-functional requirements: performance, availability, security, integrity, auditability |

---

## ADR — Architecture Decision Records

ADRs document significant architectural decisions — the context, the decision made, consequences, and alternatives considered. They are the historical record of *why* the architecture is the way it is.

| Document | Decision |
|---|---|
| [ADR-001_Event_Driven_Architecture.md](docs/ADR/ADR-001_Event_Driven_Architecture.md) | All inter-module integration uses an event-driven model; direct module-to-module calls are prohibited |
| [ADR-002_Deterministic_Replayability.md](docs/ADR/ADR-002_Deterministic_Replayability.md) | Historical payroll results must be exactly reproducible from historical inputs and rules |

---

## DATA — Entity Specifications

Entity specification documents define the canonical attributes, status values, relationships, and governance rules for every significant entity in the platform.

### HRIS Entities

| Document | Entity |
|---|---|
| [Entity_Person.md](docs/DATA/Entity_Person.md) | Person — enduring human identity record |
| [Entity_Employee.md](docs/DATA/Entity_Employee.md) | Employment — HR and payroll operational record |
| [Entity_Assignment.md](docs/DATA/Entity_Assignment.md) | Assignment — Employment linkage to Job, Position, Department, Location |
| [Entity_Compensation_Record.md](docs/DATA/Entity_Compensation_Record.md) | Compensation Record — pay rate and structure |
| [Entity_Leave_Request.md](docs/DATA/Entity_Leave_Request.md) | Leave Request — absence request lifecycle |
| [Entity_Document.md](docs/DATA/Entity_Document.md) | Document — HR documents associated with Person or Employment |
| [Entity_Onboarding_Plan.md](docs/DATA/Entity_Onboarding_Plan.md) | Onboarding Plan and Tasks — new hire readiness workflow |
| [Entity_Org_Unit.md](docs/DATA/Entity_Org_Unit.md) | Org Unit — organisational hierarchy nodes |
| [Entity_Job.md](docs/DATA/Entity_Job.md) | Job — role classification with FLSA and EEO attributes |
| [Entity_Position.md](docs/DATA/Entity_Position.md) | Position — headcount slot linked to Job and Org Unit |
| [Entity_Run_Scope.md](docs/DATA/Entity_Run_Scope.md) | Run Scope — structure used to delimit payroll processing populations |

### Payroll Entities

| Document | Entity |
|---|---|
| [Entity_Payroll_Item.md](docs/DATA/Entity_Payroll_Item.md) | Payroll Item — atomic earnings, deduction, or tax result line |
| [Entity_Payroll_Run.md](docs/DATA/Entity_Payroll_Run.md) | Payroll Run — discrete payroll execution event |
| [Entity_Payroll_Check.md](docs/DATA/Entity_Payroll_Check.md) | Payroll Check — atomic accounting unit per employee per run |
| [Entity_Accumulator.md](docs/DATA/Entity_Accumulator.md) | Accumulator — running balance and contribution history |

### Compliance Entities

| Document | Entity |
|---|---|
| [Entity_Legal_Order.md](docs/DATA/Entity_Legal_Order.md) | Legal Order — garnishments, levies, and court-ordered withholdings |
| [Entity_Jurisdiction.md](docs/DATA/Entity_Jurisdiction.md) | Jurisdiction — government authority with taxing or regulatory power |

---



## SPEC — Functional Specifications

SPEC documents define detailed behaviour for specific features or integration patterns, below the level of the PRD and above the level of architecture models.

| Document | Subject |
|---|---|
| [External_Earnings.md](docs/SPEC/External_Earnings.md) | Import format, validation, workflow, and audit for externally calculated earnings |
| [Residual_Commissions.md](docs/SPEC/Residual_Commissions.md) | Payroll treatment, tax handling, and reconciliation for residual commission earning types |
| [Self_Service_Model.md](docs/SPEC/Self_Service_Model.md) | ESS/MSS action specifications, role permission matrix, and event model |
| [Onboarding_Workflow.md](docs/SPEC/Onboarding_Workflow.md) | Onboarding plan creation, task lifecycle, rehire treatment, and integration touch points |
| [API_Contract_Standards.md](docs/SPEC/API_Contract_Standards.md) | Authentication, versioning, request/response format, error handling, idempotency, rate limiting |
| [Pay_Statement_Delivery.md](docs/SPEC/Pay_Statement_Delivery.md) | Pay statement content, format, delivery channels, retention, accessibility, and security |
| [API_Surface_Map.md](docs/SPEC/API_Surface_Map.md) | Domain-by-domain catalogue of all 21 integration points with direction, trigger, inputs, outputs, and SLAs |

---

## Architecture Models

Architecture models define *how* the system implements the requirements. They are organised by domain. Each model document covers entity definitions, design principles, and relationships to other models.

### Calculation Engine

| Document | Purpose |
|---|---|
| [Accumulator_and_Balance_Model.md](docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md) | Accumulator entity structure, rollup behaviour, and balance management |
| [Calculation_Engine.md](docs/architecture/calculation-engine/Calculation_Engine.md) | Core calculation framework, hybrid model (internal + external), and audit traceability |
| [Earnings_and_Deductions_Computation_Model.md](docs/architecture/calculation-engine/Earnings_and_Deductions_Computation_Model.md) | Ordered computation of earnings and deductions from inputs to result lines |
| [External_Result_Import_Specification.md](docs/architecture/calculation-engine/External_Result_Import_Specification.md) | Structure and processing rules for externally calculated earnings imports |
| [Net_Pay_and_Disbursement_Model.md](docs/architecture/calculation-engine/Net_Pay_and_Disbursement_Model.md) | Net pay finalisation, payment methods, split deposits, and disbursement lifecycle |
| [Result_and_Payable_Model.md](docs/architecture/calculation-engine/Result_and_Payable_Model.md) | Result record structure, payable promotion, status lifecycle, and accumulator feeding |l compliance and rule resolution |

### Core

| Document | Purpose |
|---|---|
| [Accrual_and_Entitlement_Model.md](docs/architecture/core/Accrual_and_Entitlement_Model.md) | Leave accrual rules, entitlement calculation, and balance management |
| [Benefit_and_Deduction_Configuration_Model.md](docs/architecture/core/Benefit_and_Deduction_Configuration_Model.md) | Benefit plan configuration and deduction setup |
| [Compensation_and_Pay_Rate_Model.md](docs/architecture/core/Compensation_and_Pay_Rate_Model.md) | Compensation record structure, rate history, and change handling |
| [Eligibility_and_Enrollment_Lifecycle_Model.md](docs/architecture/core/Eligibility_and_Enrollment_Lifecycle_Model.md) | Benefit eligibility determination and enrollment state management |
| [Employee_Assignment_Model.md](docs/architecture/core/Employee_Assignment_Model.md) | Job, position, department, and location assignment linkages |
| [Employee_Event_and_Status_Change_Model.md](docs/architecture/core/Employee_Event_and_Status_Change_Model.md) | Lifecycle event structure, status transitions, and downstream routing |
| [Employment_and_Person_Identity_Model.md](docs/architecture/core/Employment_and_Person_Identity_Model.md) | Person/Employment identity separation and payroll anchor rules |
| [Leave_and_Absence_Management_Model.md](docs/architecture/core/Leave_and_Absence_Management_Model.md) | Leave request lifecycle and payroll impact signals |
| [Organizational_Structure_Model.md](docs/architecture/core/Organizational_Structure_Model.md) | Org hierarchy, legal entity, department, and location structures |
| [Overtime_and_Premium_Pay_Model.md](docs/architecture/core/Overtime_and_Premium_Pay_Model.md) | Overtime eligibility, premium pay rules, and FLSA compliance |
| [Plan_and_Rule_Model.md](docs/architecture/core/Plan_and_Rule_Model.md) | Plan definitions and rule structures governing payroll behaviour |
| [Platform_Composition_and_Extensibility_Model.md](docs/architecture/core/Platform_Composition_and_Extensibility_Model.md) | Defines how the platform is structurally composed and how extensibility is achieved across the system |
| [Position_Management_Model.md](docs/architecture/core/Position_Management_Model.md) | Headcount budgeting, vacancy tracking, and position control rules |
| [Reference_Data_Model.md](docs/architecture/core/Reference_Data_Model.md) | Standardised code sets, versioning, and reference data governance |
| [Reporting_Hierarchy_Model.md](docs/architecture/core/Reporting_Hierarchy_Model.md) | Manager-employee reporting relationships, org chart structure, and hierarchy traversal |
| [Scheduling_and_Shift_Model.md](docs/architecture/core/Scheduling_and_Shift_Model.md) | Work schedule and shift definitions consumed by time and payroll |
| [Tenant_Client_Company_Legal_Entity_and_Jurisdiction_Structural_Relationship_Map.md](docs/architecture/core/Tenant_Client_Company_Legal_Entity_and_Jurisdiction_Structural_Relationship_Map.md) | Ties together four core models that define the administrative, statutory, and compliance backbone of the platform |
| [Time_Entry_and_Worked_Time_Model.md](docs/architecture/core/Time_Entry_and_Worked_Time_Model.md) | Time entry structure and worked time records for payroll consumption |

### Data Model

| Document | Purpose |
|---|---|
| [Address_Association_Model.md](docs/architecture/data/Address_Association_Model.md) | Defines the core data structure for **Address Association** as the effective-dated linkage between a governed owning object and an Address record |
| [Address_Data_Model.md](docs/architecture/data/Address_Data_Model.md) | Defines the core data structure for **Address** as a reusable, governed postal and location reference object within the platform |
| [Client_Company_Data_Model.md](docs/architecture/data/Client_Company_Data_Model.md) | Defines the core data structure for **Client Company** as a first-class grouping and administrative construct |
| [Document_Data_Model.md](docs/architecture/data/Document_Data_Model.md) | Defines the core data structure for **Document** as a governed record object within the platform |
| [Funding_Profile_Data_Model.md](docs/architecture/data/Funding_Profile_Data_Model.md) | Defines the core data structure for **Funding Profile** as the payroll funding configuration for determining how payroll obligations are financially sourced and prepared for disbursement |
| [Employment_Data_Model.md](docs/architecture/data/Employment_Data_Model.md) | Defines the core data structure for **Employment** as the operational relationship between a Person and an employer-of-record Legal Entity |
| [Jurisdiction_Registration_and_Profile_Data_Model.md](docs/architecture/data/Jurisdiction_Registration_and_Profile_Data_Model.md) | Defines core data structures for jurisdictional compliance and rule resolution |
| [Legal_Entity_Data_Model.md](docs/architecture/data/Legal_Entity_Data_Model.md) | Defines the core data structure for **Legal Entity** as a first-class organizational and compliance construct within the platform |
| [Net_Pay_Disbursement_Data_Model.md](docs/architecture/data/Net_Pay_Disbursement_Data_Model.md) | Defines the core data structure for **Net Pay Disbursement** as the governed and execution-linked structure used to deliver employee net pay |
| [Payment_Instruction_Profile_Data_Model.md](docs/architecture/data/Payment_Instruction_Profile_Data_Model.md) | Defines the core data structure for **Payment Instruction Profile** as the configuration used to describe how a payment or remittance is routed, formatted, and released to an external financial or settlement destination |
| [Person_Data_Model.md](docs/architecture/data/Person_Data_Model.md) | Defines the core data structure for **Person** as the durable human identity record within the platform |
| [Remittance_Profile_Data_Model.md](docs/architecture/data/Remittance_Profile_Data_Model.md) | Defines the core data structure for **Remittance Profile** as the configuration used to determine how payroll-related obligations are delivered to authorities, providers, garnishment recipients, and other external parties |
| [Role_and_Permission_Model.md](docs/architecture/data/Role_and_Permission_Model.md) | Defines the core data structures for **Role**, **Permission**, and **Role Assignment** as the authorization framework of the platform |
| [Tenant_Data_Model.md](docs/architecture/data/Tenant_Data_Model.md) | Defines the core data structure for **Tenant** as the primary security, configuration, and operational isolation boundary within the platform |
| [User_Account_Data_Model.md](docs/architecture/data/User_Account_Data_Model.md) | Defines the core data structure for **User Account** as the governed authentication and platform-access identity associated with a Person |
| [Work_Location_Data_Model.md](docs/architecture/data/Work_Location_Data_Model.md) | Defines the core data structure for **Work Location** as the operational workplace reference used by the platform |

### Governance

| Document | Purpose |
|---|---|
| [Configuration_and_Metadata_Management_Model.md](docs/architecture/governance/Configuration_and_Metadata_Management_Model.md) | Configuration validation, readiness assessment, and dependency diagnostics |
| [Correction_and_Immutability_Model.md](docs/architecture/governance/Correction_and_Immutability_Model.md) | Correction handling, immutability rules, and compensating transaction model |
| [Data_Retention_and_Archival_Model.md](docs/architecture/governance/Data_Retention_and_Archival_Model.md) | Retention periods, archival lifecycle, and purge governance |
| [Garnishment_and_Legal_Order_Model.md](docs/architecture/governance/Garnishment_and_Legal_Order_Model.md) | Legal order processing, garnishment calculation, and remittance |
| [Jurisdiction_and_Compliance_Rules_Model.md](docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md) | Jurisdiction hierarchy, compliance rule structure, and applicability |
| [Payroll_Reconciliation_Model.md](docs/architecture/governance/Payroll_Reconciliation_Model.md) | Reconciliation controls between payroll results and financial records |
| [Regulatory_and_Compliance_Reporting_Model.md](docs/architecture/governance/Regulatory_and_Compliance_Reporting_Model.md) | Tax and regulatory filing structures (W-2, 941, etc.) |
| [Release_and_Approval_Model.md](docs/architecture/governance/Release_and_Approval_Model.md) | Approval workflow structure and release governance |
| [Security_and_Access_Control_Model.md](docs/architecture/governance/Security_and_Access_Control_Model.md) | Role-based access, segregation of duties, and data access scoping |

### Interfaces

| Document | Purpose |
|---|---|
| [General_Ledger_and_Accounting_Export_Model.md](docs/architecture/interfaces/General_Ledger_and_Accounting_Export_Model.md) | Journal entry structure and payroll-to-GL export lifecycle |
| [Integration_and_Data_Exchange_Model.md](docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md) | Integration boundaries, exchange patterns, and canonical translation layer |
| [Pay_Statement_Model.md](docs/architecture/interfaces/Pay_Statement_Model.md) | Pay statement structure and content fields |
| [Pay_Statement_Template_Model.md](docs/architecture/interfaces/Pay_Statement_Template_Model.md) | Reusable pay statement templates, branding, and conditional display rules |
| [Payroll_Interface_and_Export_Model.md](docs/architecture/interfaces/Payroll_Interface_and_Export_Model.md) | Outbound payroll export structure, transmission, and retry handling |
| [Provider_Billing_and_Charge_Model.md](docs/architecture/interfaces/Provider_Billing_and_Charge_Model.md) | Employer-facing provider billing and charge classification (PEO contexts) |

### Operations

| Document | Purpose |
|---|---|
| [Monitoring_and_Alerting_Model.md](docs/architecture/operations/Monitoring_and_Alerting_Model.md) | Operational monitoring, alerting thresholds, and incident routing |
| [Operational_Reporting_and_Analytics_Model.md](docs/architecture/operations/Operational_Reporting_and_Analytics_Model.md) | Payroll cost, labour, tax, and exception reporting |
| [Run_Visibility_and_Dashboard_Model.md](docs/architecture/operations/Run_Visibility_and_Dashboard_Model.md) | Payroll run status dashboards and operator visibility |
| [System_Initialization_and_Bootstrap_Model.md](docs/architecture/operations/System_Initialization_and_Bootstrap_Model.md) | System startup, environment bootstrap, and initialisation controls |
| [System_Maintenance_and_Upgrade_Model.md](docs/architecture/operations/System_Maintenance_and_Upgrade_Model.md) | Maintenance windows, upgrade lifecycle, and environment promotion |
| [Exception_and_Work_Queue_Model.md](docs/architecture/operations/Exception_and_Work_Queue_Model.md) | Exception routing, work queue structure, and resolution workflows |

### Payroll

| Document | Purpose |
|---|---|
| [Holiday_and_Special_Calendar_Model.md](docs/architecture/payroll/Holiday_and_Special_Calendar_Model.md) | Holiday definitions and special calendar rules |
| [Multi_Context_Calendar_Model.md](docs/architecture/payroll/Multi_Context_Calendar_Model.md) | Multi-context calendar support for complex PEO environments |
| [Payroll_Calendar_Model.md](docs/architecture/payroll/Payroll_Calendar_Model.md) | Payroll period structure, date controls, and calendar governance |
| [Payroll_Context_Model.md](docs/architecture/payroll/Payroll_Context_Model.md) | Payroll group and context definitions governing run scope |

### Processing

| Document | Purpose |
|---|---|
| [Accumulator_Definition_Model.md](docs/architecture/processing/Accumulator_Definition_Model.md) | Defines the core data structure for **Accumulator Definition** as the specification of payroll totals, balances, and reporting counters used across calculation, remittance, reporting, and audit processes |
| [Accumulator_Impact_Model.md](docs/architecture/processing/Accumulator_Impact_Model.md) | Defines the core data structure for **Accumulator Impact** as the mutation record that connects payroll results to accumulator value changes |
| [Calculation_Run_Lifecycle.md](docs/architecture/processing/Calculation_Run_Lifecycle.md) | Payroll run states, transitions, and lifecycle management |
| [Employee_Payroll_Result_Model.md](docs/architecture/processing/Employee_Payroll_Result_Model.md) | Defines the core data structure for **Employee Payroll Result** as the detailed payroll outcome for an individual Employment within a Payroll Run Result Set |
| [Error_Handling_and_Isolation_Model.md](docs/architecture/processing/Error_Handling_and_Isolation_Model.md) | Error isolation, failure containment, and recovery patterns |
| [Payroll_Adjustment_and_Correction_Model.md](docs/architecture/processing/Payroll_Adjustment_and_Correction_Model.md) | Defines the core data structure for **Payroll Adjustment and Correction** as the mechanism used to repair, reverse, replace, or supplement payroll outcomes without overwriting finalized results |
| [Payroll_Check_Model.md](docs/architecture/processing/Payroll_Check_Model.md) | Payroll check structure and its relationship to results and disbursement |
| [Payroll_Exception_Model.md](docs/architecture/processing/Payroll_Exception_Model.md) | Defines the core data structure for **Payroll Exception** as the record used to capture, classify, route, and resolve payroll-related failures, warnings, holds, and operational review conditions |
| [Payroll_Run_Funding_and_Remittance_Map.md](docs/architecture/processing/Payroll_Run_Funding_and_Remittance_Map.md) | Defines how **Payroll Run** relates to the funding and remittance configuration models at execution time |
| [Payroll_Run_Model.md](docs/architecture/processing/Payroll_Run_Model.md) | Payroll run entity, execution model, and approval governance |
| [Payroll_Run_Result_Set_Model.md](docs/architecture/processing/Payroll_Run_Result_Set_Model.md) | Defines the **Payroll Run Result Set** as the governed container for all results generated during a Payroll Run |
| [Processing_Lineage_Validation_Model.md] (docs/architecture/processing/Processing_Lineage_Validation_Model.md) | Defines controls used to verify integrity of the payroll run lineage chains |
| [Run_Lineage_Model.md] (docs/architecture/processing/Run_Lineage_Model.md) | Defines how payroll runs are related across standard execution, scoped catch-up processing, retroactive correction and recovery activity |
| [Run_Scope_Model.md] (docs/architecture/processing/Run_Scope_Model.md) | Defines scoped execution boundaries enabling catch-up, retro, and recovery payroll runs without requiring full population reprocessing |

### Rules

| Document | Purpose |
|---|---|
| [Code_Classification_and_Mapping_Model.md](docs/rules/Code_Classification_and_Mapping_Model.md) | External code classification into canonical result classes |
| [Policy_and_Rule_Execution_Model.md](docs/rules/Policy_and_Rule_Execution_Model.md) | Policy evaluation and rule execution framework |
| [Posting_Rules_and_Mutation_Semantics.md](docs/rules/Posting_Rules_and_Mutation_Semantics.md) | How validated results become durable postings; correction behaviour |
| [Rule_Pack_Model.md](docs/rules/Rule_Pack_Model.md) | How executable rule logic is packaged, versioned, activated, and resolved within the platform |
| [Rule_Resolution_Engine.md](docs/rules/Rule_Resolution_Engine.md) | Rule candidate selection, precedence model, and resolution tracing |
| [Rule_Versioning_Model.md](docs/rules/Rule_Versioning_Model.md) | Rule version lifecycle, effective dating, and historical preservation |
| [Tax_Classification_and_Obligation_Model.md](docs/rules/Tax_Classification_and_Obligation_Model.md) | Tax type classification, obligation structure, and jurisdiction linkage |

### Accumulators

| Document | Purpose |
|---|---|
| [Accumulator_Model_Detailed.md](docs/accumulators/Accumulator_Model_Detailed.md) | Detailed accumulator entity structure, rollup behaviour, and reconciliation |

---

## Conventions

Convention documents define the naming, numbering, and structural standards that apply across all documentation. All contributors must consult these before adding new requirements, state models, or exception rules.

| Document | Purpose |
|---|---|
| [Requirement_ID_Convention.md](docs/conventions/Requirement_ID_Convention.md) | Defines REQ, STATE, EXC, and ENT prefix taxonomies, numbering rules, severity levels, and known state/exception values |

---

## STATE — State Models

State model documents define the named states, valid transitions, guard conditions, and invalid transitions for every significant lifecycle in the platform. Each document is referenced by the PRD or architecture model that owns the domain.

| Document | Lifecycle |
|---|---|
| [STATE-RSC_Run_Lineage.md](docs/STATE/STATE-RSC_Run_Lineage.md) | Payroll run — draft, linked, verified, active, closed and invalid |
| [STATE-RSC_Run_Scope.md](docs/STATE/STATE-RSC_Run_Scope.md) | Payroll run — draft, validated, ready, running, completed, failed and cancelled |
| [STATE-WFL_Workflow_Approval.md](docs/STATE/STATE-WFL_Workflow_Approval.md) | All platform approval workflows |
| [STATE-RUN_Payroll_Run.md](docs/STATE/STATE-RUN_Payroll_Run.md) | Payroll run — creation through closure, failure, reversal |
| [STATE-EMP_Employment_Lifecycle.md](docs/STATE/STATE-EMP_Employment_Lifecycle.md) | Person, Employment, and Position records |
| [STATE-LEV_Leave_Request.md](docs/STATE/STATE-LEV_Leave_Request.md) | Leave requests — all leave types |
| [STATE-DOC_Document.md](docs/STATE/STATE-DOC_Document.md) | HR documents associated with Person or Employment |
| [STATE-ONB_Onboarding_Task.md](docs/STATE/STATE-ONB_Onboarding_Task.md) | Individual onboarding plan tasks |
| [STATE-TIM_Timecard.md](docs/STATE/STATE-TIM_Timecard.md) | Timecards and timesheets |
| [STATE-DED_Benefits_Deductions.md](docs/STATE/STATE-DED_Benefits_Deductions.md) | Benefit plan enrollments and deduction elections |
| [STATE-GAR_Garnishment.md](docs/STATE/STATE-GAR_Garnishment.md) | Garnishments and legal orders |
| [STATE-TAX_Tax_Elections.md](docs/STATE/STATE-TAX_Tax_Elections.md) | Tax withholding elections and jurisdiction assignments |
| [STATE-RET_Retro_Adjustments.md](docs/STATE/STATE-RET_Retro_Adjustments.md) | Retroactive pay adjustments |
| [STATE-GL_General_Ledger_Posting.md](docs/STATE/STATE-GL_General_Ledger_Posting.md) | GL journal entries from payroll |
| [STATE-YEP_Year_End_Processing.md](docs/STATE/STATE-YEP_Year_End_Processing.md) | Year-end tax forms (W-2, 1099, etc.) |
| [STATE-EXP_Export.md](docs/STATE/STATE-EXP_Export.md) | Outbound payroll export units |
| [STATE-REC_Reconciliation.md](docs/STATE/STATE-REC_Reconciliation.md) | Payroll reconciliation lifecycle |
| [STATE-PRV_Provider_Response.md](docs/STATE/STATE-PRV_Provider_Response.md) | Inbound provider response processing |

---

## EXC — Exception Catalogues

Exception catalogue documents define production-grade validation and exception rules with addressable EXC codes, severity levels, system behaviour, and operator actions. Each document covers one exception domain.

| Document | Domain |
|---|---|
| [EXC-VAL_Validation_Exceptions.md](docs/EXC/EXC-VAL_Validation_Exceptions.md) | Payroll result validation, HR record validation, configuration readiness |
| [EXC-CAL_Calculation_Exceptions.md](docs/EXC/EXC-CAL_Calculation_Exceptions.md) | Calculation engine failures, rule resolution, accumulator errors |
| [EXC-CFG_Configuration_Exceptions.md](docs/EXC/EXC-CFG_Configuration_Exceptions.md) | Missing objects, broken references, effective date gaps, code mapping |
| [EXC-RUN_Payroll_Run_Exceptions.md](docs/EXC/EXC-RUN_Payroll_Run_Exceptions.md) | Run initiation failures, stuck states, aborts, deadline risk |
| [EXC-INT_Integration_Exceptions.md](docs/EXC/EXC-INT_Integration_Exceptions.md) | Inbound file failures, outbound transmission failures, provider response anomalies |
| [EXC-TAX_Taxation_Exceptions.md](docs/EXC/EXC-TAX_Taxation_Exceptions.md) | Invalid elections, missing jurisdictions, reciprocity conflicts, engine failures |
| [EXC-TIM_Time_Attendance_Exceptions.md](docs/EXC/EXC-TIM_Time_Attendance_Exceptions.md) | Missing punches, invalid timecard states, overtime violations, cutoff issues |
| [EXC-DED_Benefits_Deductions_Exceptions.md](docs/EXC/EXC-DED_Benefits_Deductions_Exceptions.md) | Invalid deductions, missing enrollments, tax treatment conflicts, garnishment priority |
| [EXC-COR_Correction_Exceptions.md](docs/EXC/EXC-COR_Correction_Exceptions.md) | Immutability violations, correction sequencing, retro scope, year-end corrections |
| [EXC-AUD_Audit_Retention_Exceptions.md](docs/EXC/EXC-AUD_Audit_Retention_Exceptions.md) | Audit trail gaps, retention expiry, legal hold violations, archival failures |
| [EXC-SEC_Security_Access_Exceptions.md](docs/EXC/EXC-SEC_Security_Access_Exceptions.md) | Unauthorised actions, cross-tenant violations, separation of duties, sensitive field access |

---

## Control Artifacts

| Document | Purpose |
|---|---|
| [Architecture_Model_Inventory.md](docs/architecture/Architecture_Model_Inventory.md) | Complete inventory of all architecture models with status and lifecycle tracking |
| [PRD_to_Architecture_Coverage_Map.md](docs/architecture/PRD_to_Architecture_Coverage_Map.md) | Traceability map from PRD capabilities to primary and supporting architecture models |

---

*Last updated: April 2026*
