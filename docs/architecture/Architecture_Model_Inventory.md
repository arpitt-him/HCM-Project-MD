# Architecture_Model_Inventory

| Field | Detail |
|---|---|
| **Document Type** | Control Artifact |
| **Version** | v2.0 |
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
| PRD | Platform | PRD-0000_Core_Vision | docs/PRD | Complete | Locked | Core Platform | Replaces HCM_Platform_PRD §1, §3 |
| PRD | Platform | PRD-0100_Architecture_Principles | docs/PRD | Complete | Locked | Core Platform | Replaces HCM_Platform_PRD §2 |
| PRD | Platform | PRD-0200_Core_Entity_Model | docs/PRD | Complete | Locked | Core Platform | Replaces HCM_Platform_PRD §4 |
| PRD | Payroll | PRD-0300_Payroll_Calendar | docs/PRD | Complete | Locked | Payroll Domain | Replaces HCM_Platform_PRD §5 |
| PRD | Payroll | PRD-0400_Earnings_Model | docs/PRD | Complete | Locked | Payroll Domain | Replaces HCM_Platform_PRD §6, §9 |
| PRD | Payroll | PRD-0500_Accumulator_Strategy | docs/PRD | Complete | Locked | Core Platform | Replaces HCM_Platform_PRD §7 |
| PRD | Compliance | PRD-0600_Jurisdiction_Model | docs/PRD | Complete | Locked | Compliance Domain | Replaces HCM_Platform_PRD §8 |
| PRD | Platform | PRD-0700_Workflow_Framework | docs/PRD | Complete | Locked | Core Platform | Replaces HCM_Platform_PRD §10 |
| PRD | Platform | PRD-0800_Validation_Framework | docs/PRD | Complete | Locked | Core Platform | Replaces HCM_Platform_PRD §11 |
| PRD | Platform | PRD-0900_Integration_Model | docs/PRD | Complete | Locked | Core Platform | Replaces HCM_Platform_PRD §14 |
| PRD | HRIS | HRIS_Module_PRD | docs/PRD | Complete | Draft | Core Platform | HRIS module specification v0.1 |

### NFR — Non-Functional Requirements

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| NFR | Platform | HCM_NFR_Specification | docs/NFR | Complete | Draft | Core Platform | Platform-wide NFRs v0.1 |

### ADR — Architecture Decision Records

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| ADR | Platform | ADR-001_Event_Driven_Architecture | docs/ADR | Complete | Accepted | Core Platform | |
| ADR | Platform | ADR-002_Deterministic_Replayability | docs/ADR | Complete | Accepted | Core Platform | |

### DATA — Entity Specifications

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Data Entity | Core | Entity_Person | docs/DATA | Complete | Draft | Core Platform | |
| Data Entity | Core | Entity_Employee | docs/DATA | Complete | Draft | Core Platform | Employment entity |
| Data Entity | Payroll | Entity_Payroll_Item | docs/DATA | Complete | Draft | Payroll Domain | |

### SPEC — Functional Specifications

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Spec | Payroll | External_Earnings | docs/SPEC | Complete | Draft | Payroll Domain | |
| Spec | Payroll | Residual_Commissions | docs/SPEC | Complete | Draft | Payroll Domain | Extends External_Earnings |

### Conventions

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Convention | Platform | Requirement_ID_Convention | docs/conventions | Complete | Locked | Core Platform | REQ, STATE, EXC, ENT prefix taxonomy |

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
| Model | Core | Compensation_and_Pay_Rate_Model | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |
| Model | Core | Eligibility_and_Enrollment_Lifecycle_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Employee_Assignment_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Employee_Event_and_Status_Change_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Employment_and_Person_Identity_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Leave_and_Absence_Management_Model | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |
| Model | Core | Organizational_Structure_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Overtime_and_Premium_Pay_Model | docs/architecture/core | Complete | Draft | Core Platform | Yes | High |
| Model | Core | Plan_and_Rule_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Reference_Data_Model | docs/architecture/core | Complete | Approved | Core Platform | Yes | High |
| Model | Core | Scheduling_and_Shift_Model | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |
| Model | Core | Time_Entry_and_Worked_Time_Model | docs/architecture/core | Complete | Reviewed | Core Platform | Yes | High |

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
| Model | Processing | Calculation_Run_Lifecycle | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Error_Handling_and_Isolation_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Payroll_Check_Model | docs/architecture/processing | Complete | Draft | Payroll Domain | Yes | High |
| Model | Processing | Payroll_Run_Model | docs/architecture/processing | Complete | Approved | Payroll Domain | Yes | High |

### Architecture Models — Rules

| Artifact Type | Domain | Model Name | Folder Location | Status | Lifecycle Status | Owner | PRD Coverage | Confidence |
|---|---|---|---|---|---|---|---|---|
| Model | Rules | Code_Classification_and_Mapping_Model | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Policy_and_Rule_Execution_Model | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Posting_Rules_and_Mutation_Semantics | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Rule_Resolution_Engine | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Rule_Versioning_Model | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |
| Model | Rules | Tax_Classification_and_Obligation_Model | docs/rules | Complete | Reviewed | Compliance Domain | Yes | High |

---

## Control Artifacts

| Artifact Type | Domain | Document Name | Folder Location | Status | Lifecycle Status | Owner | Notes |
|---|---|---|---|---|---|---|---|
| Control Artifact | Architecture Control | Architecture_Model_Inventory | docs/architecture | Active | Draft | Core Platform | This document |
| Control Artifact | Architecture Control | PRD_to_Architecture_Coverage_Map | docs/architecture | Active | Draft | Core Platform | Traceability artifact |

---

## Legend

| Field | Values |
|---|---|
| Status | Complete / In Progress / Stub |
| Lifecycle Status | Draft / Reviewed / Approved / Locked / Accepted / Retired |
| Confidence Level | High / Medium / Low / Unknown |
| Implementation Status | Not Started / In Design / In Build / Verified / Operational |
