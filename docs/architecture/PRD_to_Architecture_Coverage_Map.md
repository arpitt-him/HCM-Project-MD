# PRD_to_Architecture_Coverage_Map

| Field | Detail |
|---|---|
| **Document Type** | Control Artifact |
| **Version** | v2.0 |
| **Status** | Active |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/PRD_to_Architecture_Coverage_Map.md` |
| **Last Updated** | April 2026 |

## Purpose

Traceability map from PRD capabilities to the primary and supporting architecture models that implement them. Used to verify coverage, identify gaps, and track implementation confidence and status.

---

## Coverage Map

### Platform Capabilities (PRD-0000 through PRD-0100)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Modular Architecture | PRD-0100 | System supports modular components and deployable units | System_Initialization_and_Bootstrap_Model | Configuration_and_Metadata_Management_Model; Integration_and_Data_Exchange_Model | Strong | Low | High | High | In Design | No |
| Deterministic Replayability | PRD-0100 | Ability to reproduce historical payroll results | Payroll_Run_Model | Accumulator_and_Balance_Model; Configuration_and_Metadata_Management_Model; Correction_and_Immutability_Model | Strong | Medium | High | Medium | In Design | No |
| Effective-Dated Data | PRD-0100 | All payroll data supports time-bound validity | Reference_Data_Model | Payroll_Calendar_Model; Plan_and_Rule_Model; Compensation_and_Pay_Rate_Model | Strong | Low | High | High | In Design | No |
| Approval Workflow Governance | PRD-0100 | Changes require approval workflows | Release_and_Approval_Model | Security_and_Access_Control_Model; Payroll_Run_Model; Configuration_and_Metadata_Management_Model | Strong | Low | High | High | In Design | No |
| Multi-Tenant Support | PRD-0000 | Support multiple clients and companies | Payroll_Context_Model | Security_and_Access_Control_Model; Organizational_Structure_Model | Strong | Medium | High | Medium | In Design | No |
| Event-Driven Architecture | PRD-0100 | All meaningful state changes represented as events | Employee_Event_and_Status_Change_Model | Integration_and_Data_Exchange_Model; ADR-001_Event_Driven_Architecture | Strong | Low | High | High | In Design | No |
| Audit and Historical Preservation | PRD-0100 | All record changes preserved historically | Correction_and_Immutability_Model | Data_Retention_and_Archival_Model; Security_and_Access_Control_Model | Strong | Low | High | High | In Design | No |

### Core Entity Model (PRD-0200)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Person / Employment Identity Separation | PRD-0200 | Person_ID vs Employment_ID anchoring | Employment_and_Person_Identity_Model | Employee_Assignment_Model; Employee_Event_and_Status_Change_Model | Strong | Low | High | High | In Design | No |
| Organisational Structure | PRD-0200 | Hierarchical org units with effective dating | Organizational_Structure_Model | Reference_Data_Model; Jurisdiction_and_Compliance_Rules_Model | Strong | Low | High | High | In Design | No |
| Document Storage | PRD-0200 | Support regulatory and employment documents | Data_Retention_and_Archival_Model | Security_and_Access_Control_Model; HRIS_Module_PRD | Strong | Medium | Medium | High | In Design | No |

### Payroll Calendar (PRD-0300)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Payroll Calendar Model | PRD-0300 | Period structure and date controls | Payroll_Calendar_Model | Multi_Context_Calendar_Model; Holiday_and_Special_Calendar_Model; Payroll_Context_Model | Strong | Low | High | High | In Design | No |
| Multiple Pay Frequencies | PRD-0300 | Weekly, biweekly, semi-monthly, monthly, custom | Payroll_Calendar_Model | Payroll_Context_Model | Strong | Low | High | High | In Design | No |

### Earnings Model (PRD-0400)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Earnings Types | PRD-0400 | Salary, hourly, overtime, bonus, commission, residual | Earnings_and_Deductions_Computation_Model | Result_and_Payable_Model; Code_Classification_and_Mapping_Model | Strong | Low | High | High | In Design | No |
| External Earnings Integration | PRD-0400 | Batch, API, and XML import of external earnings | External_Result_Import_Specification | Integration_and_Data_Exchange_Model; SPEC/External_Earnings; SPEC/Residual_Commissions | Strong | Medium | High | High | In Design | No |

### Accumulator Strategy (PRD-0500)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Accumulator Strategy | PRD-0500 | Running totals and reporting structures | Accumulator_and_Balance_Model | Result_and_Payable_Model; Earnings_and_Deductions_Computation_Model; Accumulator_Model_Detailed | Strong | Medium | High | Medium | In Design | No |

### Jurisdiction Model (PRD-0600)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Jurisdiction Support | PRD-0600 | Multiple jurisdiction layers supported | Jurisdiction_and_Compliance_Rules_Model | Tax_Classification_and_Obligation_Model; Garnishment_and_Legal_Order_Model | Strong | Medium | High | Medium | In Design | No |

### Workflow Framework (PRD-0700)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Approval Workflow | PRD-0700 | Configurable approval workflows across all domains | Release_and_Approval_Model | Security_and_Access_Control_Model; Payroll_Run_Model; Configuration_and_Metadata_Management_Model | Strong | Low | High | High | In Design | No |

### Validation Framework (PRD-0800)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Validation Framework | PRD-0800 | Post-calculation and pre-posting validation | Configuration_and_Metadata_Management_Model | Exception_and_Work_Queue_Model; Error_Handling_and_Isolation_Model; Policy_and_Rule_Execution_Model | Strong | Medium | High | Medium | In Design | No |

### Integration Model (PRD-0900)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| External Integration | PRD-0900 | Support batch, API, and external ingestion | Integration_and_Data_Exchange_Model | Payroll_Interface_and_Export_Model; Provider_Billing_and_Charge_Model; General_Ledger_and_Accounting_Export_Model | Strong | Medium | High | Medium | In Design | No |

### HRIS Module Capabilities (HRIS_Module_PRD)

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Person and Employment Records | HRIS_Module_PRD | Authoritative record for people and employment | Employment_and_Person_Identity_Model | Employee_Event_and_Status_Change_Model; Employee_Assignment_Model | Strong | Low | High | High | In Design | No |
| Employee Lifecycle Events | HRIS_Module_PRD | Hire, rehire, transfer, termination, status change | Employee_Event_and_Status_Change_Model | Correction_and_Immutability_Model; Release_and_Approval_Model | Strong | Low | High | High | In Design | No |
| Compensation Record Management | HRIS_Module_PRD | Rate establishment, history, and change handling | Compensation_and_Pay_Rate_Model | Correction_and_Immutability_Model; Release_and_Approval_Model | Strong | Low | High | High | In Design | No |
| Leave and Absence Management | HRIS_Module_PRD | Leave types, request lifecycle, payroll impact | Leave_and_Absence_Management_Model | Accrual_and_Entitlement_Model; Accumulator_and_Balance_Model | Strong | Low | High | High | In Design | No |
| Document Storage | HRIS_Module_PRD | I-9, W-4, employment documents with versioning | Data_Retention_and_Archival_Model | Security_and_Access_Control_Model | Strong | Medium | Medium | High | In Design | No |
| Onboarding Workflow | HRIS_Module_PRD | Task-based onboarding with blocking/non-blocking | Release_and_Approval_Model | Employee_Event_and_Status_Change_Model; Exception_and_Work_Queue_Model | Strong | Low | Medium | Medium | In Design | No |
| Manager and HR Self-Service | HRIS_Module_PRD | Role-scoped self-service with workflow governance | Security_and_Access_Control_Model | Release_and_Approval_Model; Employee_Event_and_Status_Change_Model | Strong | Low | Medium | Medium | In Design | No |
| Employee Data Intake | HRIS_Module_PRD | Manual, batch, API, and self-service intake | Integration_and_Data_Exchange_Model | Exception_and_Work_Queue_Model; Employee_Event_and_Status_Change_Model | Strong | Medium | High | Medium | In Design | No |
| HRIS Reporting and Analytics | HRIS_Module_PRD | Headcount, turnover, leave utilisation, onboarding | Operational_Reporting_and_Analytics_Model | Accumulator_and_Balance_Model; Organizational_Structure_Model | Moderate | Low | Medium | Medium | In Design | No |

### Operational Capabilities

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Operational Visibility | PRD-0000 | Dashboards and monitoring | Run_Visibility_and_Dashboard_Model | Monitoring_and_Alerting_Model; Operational_Reporting_and_Analytics_Model | Strong | Low | Medium | High | In Design | No |
| System Lifecycle Management | PRD-0000 | Support bootstrap, upgrade, maintenance | System_Maintenance_and_Upgrade_Model | System_Initialization_and_Bootstrap_Model; Configuration_and_Metadata_Management_Model | Strong | Medium | High | Medium | In Design | No |

### New Capabilities — HRIS Gap Resolution

| PRD Capability | Source Document | Description | Primary Model Owner | Supporting Architecture Models | Coverage Status | Risk Rating | Implementation Priority | Architecture Confidence | Implementation Status | Gap Identified |
|---|---|---|---|---|---|---|---|---|---|---|
| Reporting Hierarchy | HRIS_Module_PRD | Manager-employee reporting relationships and org chart | Reporting_Hierarchy_Model | Organizational_Structure_Model; Employee_Event_and_Status_Change_Model; Security_and_Access_Control_Model | Strong | Low | High | High | In Design | No |
| Position Management | HRIS_Module_PRD | Headcount budgeting, vacancy tracking, advisory position control | Position_Management_Model | Organizational_Structure_Model; Employee_Assignment_Model; Operational_Reporting_and_Analytics_Model | Strong | Low | Medium | High | In Design | No |
| Employee Self-Service | HRIS_Module_PRD | ESS actions — view record, contact update, leave, pay statements, onboarding | SPEC/Self_Service_Model | Security_and_Access_Control_Model; Release_and_Approval_Model; Reporting_Hierarchy_Model | Strong | Low | High | High | In Design | No |
| Manager Self-Service | HRIS_Module_PRD | MSS actions — view team, approve leave, initiate events, org chart | SPEC/Self_Service_Model | Reporting_Hierarchy_Model; Security_and_Access_Control_Model; Release_and_Approval_Model | Strong | Low | High | High | In Design | No |
| Onboarding Workflow | HRIS_Module_PRD | Plan creation, task lifecycle, payroll gate, rehire treatment | SPEC/Onboarding_Workflow | DATA/Entity_Onboarding_Plan; Employee_Event_and_Status_Change_Model; Release_and_Approval_Model | Strong | Low | High | High | In Design | No |

| Benefits Deduction Processing | PRD-1000_Benefits_Boundary | Payroll deduction calculation for benefit elections; pre/post-tax classification | Benefit_and_Deduction_Configuration_Model | Eligibility_and_Enrollment_Lifecycle_Model; Earnings_and_Deductions_Computation_Model; Accumulator_and_Balance_Model | Strong | Low | High | High | In Design | No |
| API Contract Standards | SPEC/API_Contract_Standards | Authentication, versioning, error handling, idempotency, rate limiting | Integration_and_Data_Exchange_Model | Security_and_Access_Control_Model; Monitoring_and_Alerting_Model | Strong | Low | High | High | In Design | No |
| Pay Statement Delivery | SPEC/Pay_Statement_Delivery | Electronic delivery, mobile access, paper suppression, retention, accessibility | Pay_Statement_Model | Net_Pay_and_Disbursement_Model; Pay_Statement_Template_Model; Security_and_Access_Control_Model | Strong | Low | High | High | In Design | No |

| API Surface Map | SPEC/API_Surface_Map | 21 integration points across HRIS, Payroll, Benefits, Compliance | Integration_and_Data_Exchange_Model | Payroll_Interface_and_Export_Model; General_Ledger_and_Accounting_Export_Model; Net_Pay_and_Disbursement_Model | Strong | Low | High | High | In Design | No |

---

## Legend

| Field | Values |
|---|---|
| Coverage Status | Strong / Moderate / Weak / Missing |
| Risk Rating | Low / Medium / High |
| Implementation Priority | High / Medium / Low |
| Architecture Confidence | High / Medium / Low / Unknown |
| Implementation Status | Not Started / In Design / In Build / Verified / Operational |
| Gap Identified | Yes / No |
