# CHANGELOG

All significant documentation changes to this repository are recorded here. Entries are listed in reverse chronological order.

Format: `YYYY-MM-DD — Description of change — Author/Owner`

--- 

## April-2026

### 2026-04-24 — Entity payroll run model update

**Document update: `docs/architecture/Entity_Payroll_Run.md`**
- Updated file information block with expanded list of related documents
- Updated section 2: Core attributes
- Updated section 6: Governance

### 2026-04-24 — Operational temporal date override document

**New document: `docs/SPEC/Temporal_Override.md`**
- Describes the ability to shift the operative current date forward in time within a single tenant
- Affects every date-sensitive process in the platform
- Unavailable in production environments

### 2026-04-24 — Operational reporting & analytics model update

**Document update: `docs/architecture/Operational_Reporting_and_Analytics_Model.md`**
- Updated file information block with expanded list of related documents
- Updated Purpose section
- Updated section 1: Reporting Scope
- Updated section 3: Report Categories
- Updated section 4: Data Aggregation Sources
- Updated section 10: Relationship to Other Models

### 2026-04-24 — Time entry & worked time model update

**Document update: `docs/architecture/Time_Entry_and_Worked_Time_Model.md`**
- Updated file information block with expanded list of related documents
- Updated section 4: Approval Lifecycle
- Updated section 11: Relationship to Other Models

### 2026-04-24 — STATE-TIM Time Entry state values

**New document: `docs/STATE/STATE-TIM_Time_Entry.md`**

### 2026-04-24 — End to End Run Lineage map updated

**Document update: `docs/architecture/End_to_End_Run_Lineage_Map.md`**
- Rewritten for posterity to include recent PRD changes

### 2026-04-24 — Reporting (minimum)

**New document: `docs/PRD/PRD-1200_Reporting_Minimum.md`**
- Produces HR and Payroll operational reports
- Not in scope for v1: User-designed reports, ad-hoc query tools, analytical data feeds, and workforce analytics dashboards

### 2026-04-24 — API surface map updated

**Document update: `docs/PRD/PRD-0000_Core_Vision.md`**
Scope for Version 1 of this platform updated to also include:
	Benefits Administration (minimum)
	Time & Attendance (minimum)
	Reporting

### 2026-04-24 — Time and Attendance

**New document: `docs/PRD/PRD-1100_Time_and_Attendance.md`**
- Produces worked time consumed by Payroll either manually or from external source
- Not in scope for v1: Advanced scheduling optimization, workforce management analytics, biometric capture, and complex union-rule engines

### 2026-04-24 — API surface map updated

**Document update: `docs/SPEC/API_Surface_Map.md`**
- INT-TIM-001 (Time entry import) status updated to `In Scope`

### 2026-04-23 — Repository file version re-numbering

**ADR re-number: All ADR- files, version re-numbered from v1.x to v0.x**
**EXC re-number: All EXC- files, version re-numbered from v1.x to v0.x**
**PRD re-number: All PRD- files, version re-numbered from v1.x to v0.x**
**STATE re-number: All STATE- files, version re-numbered from v1.x to v0.x**

### 2026-04-23 — Accumulator & balance model document updated

**Document update: docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md**
- Updated section 4 to make Contribution dependency explicit

### 2026-04-23 — Accumulator impact model document updated

**Document update: docs/architecture/processing/Accumulator_Impact_Model.md**
- Updated section 4 to add Cross-Reference in Balance Model
- Updated section 7 to make Contribution explicit

### 2026-04-23 — Accumulator & balance model document updated

**Document update: docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md**
- Updated section 2 to increase number of layers governing Accumulator runtime behavior
- Updated section 4 to add 4 new Recommended Contribution Fields
- Updated section 10 to explicitly preserve Contribution lineage

### 2026-04-22 — Payroll run result set model document updated

**Document update: `docs/architecture/processing/Payroll_Run_Result_Set_Model.md`**
- Updated section 2 to add 4 Payroll Run Result Set lineage fields
- Rename Section 3 heading to Employee Payroll Results
- Updated section 8 to strengthen Audit Snapshot
- Updated section 9 to strengthen Result Set Lifecycle
- Replaced section 11 to strengthen Replay and Deterministic Execution Support
- Added new section 12: Dependencies
- Replaced section 13: Relationship to Other Models

### 2026-04-22 — Payroll run funding & remittance model document updated

**Document update: `docs/architecture/processing/Payroll_Run_Funding_and_Remittance_Map.md`**
- Updated section 11: Reconciliation and Audit Implications
- Updated sub-section 12.1 to strengthen Payroll_Run_Funding_Use runtime mapping structure
- Updated sub-section 12.2 to strengthen Payroll_Run_Remittance_Use runtime mapping structure
- Updated sub-section 12.3 to strengthen Payroll_Run_Payment_Instruction_Use runtime mapping structure
- Added new section 14: Deterministic Replay Requirements
- Added new section 15: Dependencies
- Replaced section 16: Relationship to Other Models

### 2026-04-22 — Employee payroll result data model document updated

**Document update: `docs/architecture/processing/Employee_Payroll_Result_Model.md`**
- Updated section 2 to add Employee Payroll Result lineage fields
- Updated section 3 to strengthen Earnings Result line-level traceability language
- Updated section 4 to strengthen Deduction Result line-level traceability language
- Updated section 5 to strengthen Tax Result line-level traceability language
- Updated section 6 to strengthen Employer Contribution Result line-level traceability language
- Updated section 7 to strengthen Net Pay Result section
- Updated section 11 to strengthen Relationship to Pay Statement Output
- Added new section 15 to add deterministic replay section
- Added new section 17: Dependencies
- Replaced section 18: Relationship to Other Models

### 2026-04-22 — Accumulator impact model document updated

**Document update: docs/architecture/processing/Accumulator_Impact_Model.md**
- Updated section 4 to strengthen Relationship to Employee Payroll Result
- Updated section 5 to strengthen Relationship to Payroll Run Result Set
- Updated section 9 to clarify derived posting behavior
- Added new section 15 to add deterministic replay section
- Added new section 17: Dependencies
- Replaced section 18: Relationship to Other Models

### 2026-04-22 — Accumulator & balance model document updated

**Document update: docs/architecture/calculation-engine/Accumulator_and_Balance_Model.md**
- Replaced Purpose section with updated text to explicitly acknowledge the newer stack 
- Added new section 2: Relationship to Definition and Impact Models
- Replaced section 3 to modernize Accumulator Balance Structure
- Replaced section 4 to reposition Contribution History relative to Accumulator Impact
- Updated section 6 to strengthen time dimensions
- Updated section 8 to strengthen update timing rules
- Updated section 9 to strengthen rerun and recalculation safety
- Updated section 10 to strengthen correction handling
- Added new section 13: Deterministic Replay Requirements
- Added new section 16: Relationship to Other Models
- Added new section 17: Dependencies
- Replaced section 18 to update Key Design Principle

### 2026-04-22 — Payroll context model document updated

**Document update: docs/architecture/operations/Payroll_Context_Model.md**
- Added new section 3: Payroll Context Lineage
- Updated section 2 to expand Payroll Context Definition for lineage-safe governance
- Added new section 8: Relationship to Payroll Execution Artifacts
- Added new section 10: Deterministic Payroll Context Resolution
- Added new section 11: Dependencies
- Replaced section 12 to expand Relationship to Other Models

### 2026-04-22 — Payroll calendar model document updated

**Document update: docs/architecture/operations/Payroll_Calendar_Model.md**
- Added new section 5: Payroll Calendar Lineage
- Updated section 4 to expand Calendar Entry Entity for lineage-safe governance
- Added new section 9: Deterministic Payroll Calendar Interpretation
- Added new section 10: Dependencies
- Replaced section 11 to expand Relationship to Other Models

### 2026-04-22 — Multi-context calendar model document updated

**Document update: docs/architecture/operations/Multi_Context_Calendar_Model.md**
- Added new section 3: Calendar Context Lineage
- Updated section 2 to expand Core Calendar_Context Entity
- Updated section 5 to strengthen Calendar Relationships
- Added new section 7: Relationship to Payroll Execution Artifacts
- Replaced section 9 to strengthen Cycle-Date Handling
- Added new section 10: Deterministic Calendar Interpretation
- Added new section 11: Dependencies
- Replaced section 12 to expand Relationship to Other Models

### 2026-04-22 — System maintenance & upgrade model document updated

**Document update: docs/architecture/operations/System_Maintenance_and_Upgrade_Model.md**
- Added new section 3: Maintenance Lineage Model
- Updated section 2 to expand Maintenance_Context Entity
- Updated section 4 to strengthen Version Management Model
- Updated section 5 to strengthen Upgrade Sequencing
- Replaced section 6 to strengthen Configuration Migration Handling
- Updated section 7 to expand Compatibility Validation
- Replaced section 8 to strengthen Rollback and Recovery
- Updated section 9 to expand Patch and Hotfix Support
- Replaced section 10 to expand Post-Upgrade Verification
- Added new section 11: Deterministic Upgrade Behavior
- Added new section 12: Dependencies
- Replaced section 13 to expand Relationship to Other Models

### 2026-04-22 — System initialization & bootstrap model document updated

**Document update: docs/architecture/operations/System_Initialization_and_Bootstrap_Model.md**
- Added new section 3: Bootstrap Lineage Model
- Updated section 2 to expand Bootstrap_Context Entity
- Updated section 4 to strengthen Seed Configuration Loading
- Updated section 5 to strengthen Dependency Initialization Sequence 
- Updated section 6 to expand Tenant and Company Provisioning
- Updated section 7 to strengthen Bootstrap Validation Process
- Updated section 8 to expand Bootstrap Logging and Audit
- Replaced section 9 to strengthen Retry and Recovery Handling
- Added new section 10: Deterministic Bootstrap Behavior
- Added new section 11: Dependencies
- Replaced section 12 to expand Relationship to Other Models

### 2026-04-22 — Attendance & exception tracking model document updated

**Document update: docs/architecture/operations/Attendance_and_Exception_Tracking_Model.md**
- Updated related documents in file details block
- Added new section 3: Relationship to Payroll Execution Artifacts
- Updated section 2 to expand Core Attendance_Exception Entity
- Updated section 5 to strengthen Detection Mechanisms
- Replaced section 7 to expand Exception Resolution Workflow 
- Replaced section 8 to strengthen Payroll Impact Integration
- Added new section 9 to add relationship to Exception and Work Queue model
- Updated section 10 to expand Notification and Escalation
- Updated section 11 to expand Historical Tracking and Audit
- Added new section 12: Deterministic Exception Reconstruction
- Added new section 13 to strengthen Reporting and Analytics 
- Added new section 14: Dependencies
- Replaced section 15 to expand Relationship to Other Models

### 2026-04-22 — Payroll check model document updated

**Document update: docs/architecture/processing/Payroll_Check_Model.md**
- Replaced Purpose section with updated text 
- Updated section 1 to expand Core Payroll_Check Entity
- Added new section 2: Relationship to Payroll Execution Artifacts
- Replaced section 4 with updated text to have Payroll_Check reference/render check lines derived from governed results
- Replaced section 6 with fix to Accumulator Posting Boundary
- Replaced section 7 with fix to Idempotency Boundary
- Updated section 8 to expand Correction Lifecycle
- Updated section 9 to expand Reporting Integration
- Added new section 10: Deterministic Replay Requirements
- Added new section 11: Dependencies
- Replaced section 12 to expand Relationship to Other Models

### 2026-04-22 — Pay statement template model document updated

**Document update: docs/architecture/interfaces/Pay_Statement_Template_Model.md**
- Updated section 1 to expand Core Template Entity
- Added new section 2: Relationship to Rendered Pay Statements
- Updated section 4 to strengthen Section Configuration with clearer governance language
- Updated section 6 to strengthen Field Mapping
- Updated section 7 to expand Conditional Display Rules
- Updated section 8 to strengthen Localization Support
- Replaced section 9: Versioning and Governance
- Added new section 10: Deterministic Template Rendering
- Added new section 11: Dependencies
- Added new section 12: Relationship to Other Models

### 2026-04-22 — Pay statement model document updated

**Document update: docs/architecture/interfaces/Pay_Statement_Model.md**
- Updated section 1 to expand Core Pay_Statement Entity
- Added new section 2: Relationship to Payroll Execution Artifacts
- Updated section 3 to strengthen Earnings/Deductions/Tax sections with lineage-safe derivation
- Updated section 4: Deductions Section
- Updated section 5: Tax Withholding Section
- Added new section 9: Statement Correction and Reissue
- Replaced section 10 to expand Year-to-Date (YTD) Values
- Added new section 12: Deterministic Statement Rendering
- Added new section 13: Dependencies
- Added new section 14: Relationship to Other Models

### 2026-04-22 — Provider billing & charge model document updated

**Document update: docs/architecture/interfaces/Provider_Billing_and_Charge_Model.md**
- Added new section 3: Relationship to Payroll Execution Artifacts
- Updated section 4 to expand Provider_Invoice Entity
- Updated section 6 to strengthen Provider_Charge_Line Entity
- Updated section 9 to strengthen Reconciliation Design Principles
- Added new section 11: Deterministic Replay Requirements
- Added new section 12: Dependencies
- Added new section 13: Relationship to Other Models

### 2026-04-22 — Payroll funding & cash management model document updated

**Document update: docs/architecture/interfaces/Payroll_Funding_and_Cash_Management_Model.md**
- Added new section 3: Relationship to Payroll Execution Artifacts
- Updated section 2 to expand Core Payroll_Funding_Batch Entity
- Updated section 4 to expand Funding Components with obligation linkage
- Updated section 6 to strengthen Funding Timing and Lead Rules 
- Updated section 7 to expand Tax Liability Funding
- Updated section 8 to expand Benefit and Vendor Funding
- Updated section 9 to strengthen Cash Reconciliation
- Updated section 10 to expand Failed Funding Handling
- Updated section 11 to expand Audit and Compliance
- Added new section 12: Deterministic Replay Requirements
- Added new section 13: Dependencies
- Added new section 14: Relationship to Other Models

### 2026-04-22 — Integration & data exchange model document updated

**Document update: docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md**
- Updated section 2 to expand Core Integration_Endpoint Entity
- Updated section 5 to strengthen Canonical Translation Layer
- Added new section 6: Relationship to Payroll Execution Artifacts
- Updated section 7 to expand Validation and Control Rules
- Updated section 8 to strengthen Idempotency and Replay
- Updated section 10 to expand Error Handling and Exception Routing
- Updated section 11 to expand Versioning and Change Management
- Added new section 12: Deterministic Integration Behavior
- Added new section 13: Dependencies
- Added new section 14: Relationship to Other Models

### 2026-04-22 — Tenant client company legal entity & jurisdiction structural relationship map model document updated

**Document update: docs/architecture/core/Tenant_Client_Company_Legal_Entity_and_Jurisdiction_Structural_Relationship_Map.md**
- Added new section 5: Structural Lineage Principle
- Added new section 8: Deterministic Structural Resolution Guarantee
- Added new section 11: Dependencies

### 2026-04-22 — Reporting hierarchy model document updated

**Document update: docs/architecture/core/Reporting_Hierarchy_Model.md**
- Added new sub-section 1.1: Reporting Lineage Principle
- Updated section 2 to expand Reporting Relationship Definition
- Updated section 3 to add Point-in-Time Hierarchy Guarantee
- Updated section 4 to strengthen Lifecycle Event Integration
- Updated section 5 to add Manager Reassignment Governance
- Updated section 6 to strengthen Org Chart Derivation
- Updated section 7 to expand Manager Self-Service Scoping
- Updated section 8 to expand Constraints and Rules
- Added new sub-section 8.1: Deterministic Hierarchy Reconstruction
- Added new section 9: Dependencies
- Added new section 10: Relationship to Other Models

### 2026-04-22 — Position management model document updated

**Document update: docs/architecture/core/Position_Management_Model.md**
- Added new sub-section 1.1: Position Identity Stability Principle
- Added new sub-section 2.1: Organizational Lineage Awareness
- Updated section 4 to clarify Vacancy Derivation Semantics
- Updated section 5 to add Assignment Lineage Reference
- Updated section 5 to add Position Freeze Governance
- Updated section 6 to strengthen Department Budget Governance
- Updated section 7 to add Deterministic Reporting Guarantee
- Added new sub-section 7.1: Structural Invariants
- Added new section 9: Dependencies
- Added new section 10: Relationship to Other Models

### 2026-04-22 — Platform composition & extensibility model document updated

**Document update: docs/architecture/core/Platform_Composition_and_Extensibility_Model.md**
- Removed section 1 number from Purpose section
- Added new section 2: Platform Execution Context Model
- Added new sub-section 3.4: Platform Stability Boundary
- Added new sub-section 4.3: Cross-Module Dependency Constraints
- Updated section 6 to strengthen Integration Surface Governance
- Added new sub-section 6.3: Extensibility Governance Lifecycle
- Updated section 8 to strengthen Jurisdiction Resolution Traceability
- Added new section 13: Relationship to Other Models
- Added new section 14: Dependencies
- Added new section 15: Deterministic Platform Behavior Guarantee


### 2026-04-22 — Calculation engine model document updated

**Document update:  /docs/architecture/calculation-engine/Calculation_Engine.md
- Updated section 1 by replacing entire `Outputs include` text block
- Added new section 2: Relationship to Payroll Execution Artifacts
- Updated section 3 to strengthen Core Design Principle
- Updated section 4 by adding 5 new `In Scope` items
- Replaced section 5 to expand list of Functional Highlights 
- Updated section 6 to strengthen Non-Functional Requirements
- Replaced section 7 to expand list of logical Entities
- Added new section 8: Deterministic Replay Requirements
- Updated section 9 to expand list of Open Design Decisions
- Added new section 10: Relationship to Other Models
- Added new section 11: Dependencies

### 2026-04-22 — Result & payable model document updated

**Document update:  /docs/architecture/calculation-engine/External_Result_Import_Specification.md
- Updated section 3 by recommending 5 new fields for the CSV File Structure
- Updated section 4 to strengthen Adjustment Model with explicit lineage
- Added new section 6: Relationship to Payroll Execution Artifacts
- Updated section 7 by adding 5 new Validation Rules
- Updated section 8 to add correction / replay statement to Error Handling
- Updated section 9 to strengthen Reconciliation Controls to explicitly include payroll reconciliation linkage
- Updated section 10 to expand Audit Requirements with version/lineage details
- Added new section 13: Deterministic Replay Requirements
- Added new section 14: Relationship to Other Models

### 2026-04-22 — Result & payable model document updated

**Document update:  /docs/architecture/calculation-engine/Result_and_Payable_Model.md
- Updated section 2 by adding 6 new fields to Result Record
- Updated section 4 by adding 3 new fields to Payable Record Definition
- Updated section 6 to expand Accumulator Integration
- Updated section 7 to expand Adjustment Handling with lineage binding
- Added new section 8: Result Lineage Model
- Updated section 10 to expand Traceability Requirements
- Added new section 11: Deterministic Replay Requirements
- Added new section 12: Dependencies
- Replaced section 13: Relationship to Other Models 

### 2026-04-22 — Accumulator definition model document updated

**Document update:  /docs/architecture/processing/Accumulator_Definition_Model.md
- Added new sub-section 4.1: Cross-Scope Reconciliation Requirements
- Added new sub-section 5.1: Reset Boundary Governance
- Added new sub-section 8.1: Relationship to Payroll Result Lineage
- Added new sub-section 13.1: Threshold Interaction Governance
- Added new sub-section 16.1: Definition Immutability Enforcement
- Updated section 17 to add 4 new Validation Rules
- Added new sub-section 17.1: Deterministic Reset Guarantee
- Added new section 21: Dependencies

### 2026-04-22 — Processing lineage validation model document updated

**Document update:  /docs/architecture/processing/Processing_Lineage_Validation_Model.md
- Added section numbering 
- Added new sub-section 4.5: Correction Relationship Validation
- Added new sub-section 4.7: Result Set and Result Lineage Validation
- Updated section 5 to add 4 new Validation Rules `(RULE-PLV-011 - RULE-PLV-014)`
- Updated section 8 to add 4 new Failure Conditions
- Updated section 12 to add 4 new Audit Requirements
- Replaced section 13: Dependencies to expand list
- Added new section 14: Relationship to Other Models
- Added new section 17: Deterministic Replay Guarantee

### 2026-04-22 — Rule versioning model document updated

**Document update:  /docs/rules/Rule_Versioning_Model.md
- Added new section 11: Relationship to Rule Packs
- Renumbered sections to fix section 14 duplicates
- Updated section 14 to include Activation of Accumulator Definitions workflow
- Added new section 15: Accumulator Definition Lineage Model
- Added new section 17: Deterministic Replay and Recalculation Requirements

### 2026-04-22 — Rule pack model document updated

**Document update:  /docs/rules/Rule_Pack_Model.md
- Added new section 17 to add Rule Pack Lineage Binding
- Added new section 18 to add Runtime Resolution Trace Capture
- Added new section 19 to add Dependency Validation Requirement
- Added new section 20 to strengthen Replay Requirement

### 2026-04-22 — Tax classification & obligation model document updated

**Document update:  /docs/rules/Tax_Classification_and_Obligation_Model.md
- Added new sub-section 4.2 to add Rule Pack Binding
- Added new section 11: Multi-Jurisdiction Tax Applicability
- Added new section 12: Tax Liability Lifecycle
- Added new section 13: Deterministic Replay Requirements

### 2026-04-22 — Garnishment & legal order model document updated

**Document update:  /docs/architecture/governance/Garnishment_and_Legal_Order_Model.md
- Updated section 3 to add Priority Resolution Model Binding
- Added new section 11: Legal Order Lineage and Execution Traceability
- Added new section 12: Deterministic Replayability Requirements
- Added new section 13: Multi-Jurisdiction Order Conflict Resolution

### 2026-04-22 — Correction & immutability model document updated

**Document update:  /docs/architecture/governance/Correction_and_Immutability_Model.md
- Updated section 2 to tie Immutability to Result Sets
- Updated section 5 to connect to Accumulator Impact Model
- Added new section 9: Lineage and Correction Chain Enforcement
- Added new section 10: Deterministic Replayability Requirements

### 2026-04-22 — Operational reporting & analytics model document updated

**Document update:  /docs/architecture/operations/Operational_Reporting_and_Analytics_Model.md
- Replaced Purpose section with updated text to explicitly distinguish operational analytics from regulatory reporting and tie analytics to governed execution data
- Replaced section 4 to modernize aggregation sources
- Updated section 5 to strengthen metric definitions
- Updated section 6 to expand time-series analysis
- Replaced section 7 to strengthen exception analytics
- Updated section 8 to strengthen forecasting support
- Replaced section 9 to strengthen security and access control
- Replaced section 10 to expand Relationship to Other Models

### 2026-04-22 — Regulatory & compliance reporting model document updated

**Document update:  /docs/architecture/governance/Regulatory_and_Compliance_Reporting_Model.md
- Updated section 1 to strengthen Reporting Scope
- Updated section 2 to add execution lineage linkage to the Core Regulatory_Report entity
- Updated section 6 to expand Validation and Reconciliation
- Updated section 7 to strengthen Correction Handling
- Updated section 8 to strengthen Output Format semantics
- Updated section 9 to expand Audit and Retention
- Replaced section 10 to expand Relationship to Other Models

### 2026-04-22 — Data retention & archival model document updated

**Document update:  /docs/architecture/governance/Data_Retention_and_Archival_Model.md
- Replaced Purpose section with updated text to explicitly mention execution lineage and correction history
- Updated section 3 to expand Data Categories
- Updated section 5 to strengthen Archival Lifecycle to explicitly say archived data remains historically queryable
- Updated section 6 to strengthen Archive Strategy by including lineage language
- Replaced section 8 to strengthen Retrieval and Replay Support by explicitly including correction and lineage replay
- Updated section 9 to strengthen Purge Governance by explicitly protecting lineage-dependent records
- Replaced section 11 to expand Relationship to Other Models

### 2026-04-22 — Security & access control model document updated

**Document update:  /docs/architecture/governance/Security_and_Access_Control_Model.md
- Replaced Purpose section with updated text to explicitly connect security to execution artifacts and governed actions
- Updated section 2 to expand Security Scope to include lineage and scoped processing
- Updated section 3 to strengthen Authorization Dimensions to include run scope and legal entity explicitly
- Updated section 4 to strengthen Role Model by adding operationally distinct roles
- Updated section 5 to expand Permission Categories by reflecting correction and queue handling more explicitly
- Updated section 7 to strengthen Scope-Based Access Control
- Added sub-section 9.1 to show the Relationship to Payroll Execution Artifacts
- Replaced section 10 to expand Relationship to Other Models

### 2026-04-22 — Run visibility & dashboard model document updated

**Document update:  /docs/architecture/operations/Run_Visibility_and_Dashboard_Model.md
- Replaced Purpose section with updated text to make execution-artifact lineage more explicit
- Updated section 1 to expand Core Design Principles 
- Updated section 2 to expand Visibility Hierarchy
- Updated section 5 to expand Payroll Context Dashboard
- Updated section 6 to expand Run Detail Dashboard
- Updated section 7 to strengthen Role-Based Dashboard Views
- Added sub-section 7.1 to add execution-artifact bridge
- Replaced section 8 to expand Relationship to Other Models

### 2026-04-21 — Monitoring & alerting model document updated

**Document update:  /docs/architecture/processing/Monitoring_and_Alerting_Model.md
- Replaced Purpose section with updated text to make lineage and release-risk more explicit
- Updated section 2 to expand Monitoring Scope 
- Updated section 3 to expand alert categories
- Updated section 6 to strengthen Run Monitoring Rules
- Updated section 7 to strengthen Export Monitoring
- Updated section 8 to expand Escalation Model
- Added sub-section 9.1 to add execution-artifact bridge
- Updated section 10 to expand Relationship to Other Models

### 2026-04-21 — Payroll adjustment & correction model document updated

**Document update:  /docs/architecture/processing/Payroll_Adjustment_and_Correction_Model.md
- Updated section 3 to add run-lineage linkage 
- Updated section 6 to add result-lineage language
- Updated section 9 to modernize accumulator relationship
- Updated section 16 to expand Relationship to Other Models

### 2026-04-21 — Rule resolution engine model document updated

**Document update:  /docs/rules/Rule_Resolution_Engine.md
- Updated section 6 to strengthen Exception linkage 
- Updated section 5 to add Rule Execution Outcome Identity
- Updated sub-section 10.1 to expand Relationship to Other Models

### 2026-04-21 — Payroll exception model document updated

**Document update:  /docs/architecture/processing/Payroll_Exception_Model.md
- Updated section 3 to expand list of Exception Context Attributes
- Updated sub-section 4.1 to strengthen Hard Stop semantics
- Updated section 7 to strengthen Relationship to Funding/Remittance
- Updated section 8 to strengthen Exception Status Model by adding `Awaiting_Approval ` to status list
- Updated section 12 to add Exception Lineage Trigger Linkage
- Updated section 16 to expand Relationship to Other Models

### 2026-04-21 — Run lineage model document updated

**Document update:  /docs/architecture/processing/Run_Lineage_Model.md
- Updated Lineage Structure section to stipulate that lineage must be able to relate not only runs, but the result artifacts produced by those runs
- Updated Replay Sequencing section to add that replay order is not merely chronological execution order; it is business-governed lineage order
- Updated Dependencies section to expand list 
- Added sub-section `Relationship to Approval and Release` before section called `Failure and Isolation Considerations`

### 2026-04-21 — Calculation-run lifecycle model document updated

**Document update:  /docs/architecture/processing/Calculation_Run_Lifecycle.md
- Updated section 2 to expand the list of fields in the Run Context Definition
- Updated section 6 to clarify that Ready implies validation success
- Updated section 13 to strengthen Approval and Release Controls
- Updated section 16 to modernize Relationship to Other Models

### 2026-04-21 — Error handling & isolation model document updated

**Document update:  /docs/architecture/processing/Error_Handling_and_Isolation_Model.md
- Updated section 5 to extend Error Record Structure field list
- Updated sub-section 6.5 to strengthen configuration recovery linkage
- Added sub-section 12.1: Relationship to Release Readiness
- Updated section 13 to expand Relationship to Other Models

### 2026-04-21 — Exception & work queue model document updated

**Document update:  /docs/architecture/operations/Exception_and_Work_Queue_Model.md
- Replaced Purpose section with updated text to explicitly mention execution artifacts and release/correction consequences
- Updated section 2 to expand Payroll Context-Specific Queue Model with execution scope and release impact
- Updated section 3 to strengthen Exception Queue Definition
- Updated section 4 to strengthen Retry Queue Definition
- Updated section 5 to strengthen Correction Queue Definition
- Updated section 6 to strengthen Reconciliation Exception Queue
- Updated section 7 to expand list of Queue Item Status values
- Updated section 8 to expand Escalation Rules with release-readiness impact
- Added sub-section 8.1: Relationship to Release Readiness 
- Replaced section 9 to expand Relationship to Other Models

### 2026-04-21 — Release & approval model document updated

**Document update:  /docs/architecture/governance/Release_and_Approval_Model.md
- Replaced Purpose section with updated text to connect to execution lineage
- Updated section 2 to expand Approval Workflow States with lineage identifiers
- Updated section 3 to strengthen Release Readiness Conditions
- Updated section 4 to strengthen Exception Approval Handling
- Updated section 6 to strengthen Release Locking Behaviour
- Updated section 7 to expand Conditional Release Handling
- Updated section 9 to strengthen Interaction with Immutability Model
- Added sub-section 9.1: Relationship to Other Models

### 2026-04-21 — Configuration & metadata management model document updated

**Document update:  /docs/architecture/governance/Configuration_and_Metadata_Management_Model.md
- Replaced Purpose section with updated text to support run-time linkage
- Updated section 2 to expand Configuration_Validation_Run with execution linkage
- Updated section 3 to expand Validation_Result with run-level lineage awareness
- Updated section 4 to strengthen Execution_Reachability_Profile and make execution linkage explicit
- Updated section 5 to strengthen Reachability-Based Validation Principle
- Updated section 8 to strengthen Dependency Chain Validation by adding correction lineage awareness
- Updated section 9 to expand Alignment Diagnostics by adding replay sensitivity
- Added sub-section 11.1: Relationship to Other Models


### 2026-04-21 — Jurisdiction & compliance rules model document updated

**Document update:  /docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md
- Updated section 6 to expand Jurisdiction Profiles with Rule Packs to define behavior
- Updated section 6 to add effective dating to Jurisdiction Profile
- Updated section 9 to add cross-border employment awareness
- Updated section 12 to add Payroll Processing relationship

### 2026-04-21 — Organizational structure model document updated

**Document update:  /docs/architecture/core/Organizational_Structure_Model.md
- Replaced Purpose section with updated text to explicitly mention payroll execution and replay-safe organizational context
- Updated section 2 to expand Organisational Unit Definition with lineage fields to preserve more execution-aware context
- Updated section 3 to strengthen Hierarchy Relationships and explicitly protect historical payroll interpretation
- Updated section 5 to strengthen Effective Dating Requirements and make replay explicit
- Updated section 6 to strengthen Rollup and Aggregation Behaviour by tying to payroll and finance outputs more explicitly
- Updated section 7 to expand Legal Entity Modelling by tying more explicitly to payroll context and remittance/export consequences
- Updated section 8 to strengthen Location Modelling by explicitly stating tax/premium/time interaction
- Replaced section 10 to strengthen Organisational Assignment Integration to explicitly tie to execution artifacts
- Updated section 11 to expand Audit and Traceability by adding execution lineage relevance
- Added sub-section 11.1: Relationship to Other Models

### 2026-04-21 — Employment & person identity model document updated

**Document update:  /docs/architecture/core/Employment_and_Person_Identity_Model.md
- Replaced Purpose section with updated text to explicitly mention execution lineage and replay
- Updated section 3 to expand Employment Definition with lineage fields to include more execution-aware identifiers
- Updated section 4 to strengthen Relationship Between Person and Employment
- Replaced section 5 to expand on Why Employment_ID Is the Payroll Anchor
- Updated section 6 to strengthen Rehire Handling to explicitly explicitly include correction/replay language
- Updated section 7 to strengthen Concurrent Employment Handling
- Updated section 8 to expand External Identifier Handling by acknowledging interface lineage
- Updated section 9 to strengthen Status Models to align more explicitly with eligibility and event routing
- Added sub-section 10.1: Relationship to Other Models

### 2026-04-21 — Eligibility & enrollment lifecycle model document updated

**Document update:  /docs/architecture/core/Eligibility_and_Enrollment_Lifecycle_Model.md
- Replaced Purpose section with updated text to explicitly mention payroll result effects and replay-safe enrollment state
- Updated section 2 to strengthen Eligibility Determination to explicitly connect to governed rule execution and assignment context
- Updated section 3 to expand Enrollment Event Entity with lineage fields
- Updated section 4 to strengthen Coverage Activation Rules to explicitly protect replay behavior
- Updated section 5 to expand Change Event Handling to link more explicitly to the employee event model
- Replaced section 6 to strengthen Retroactive Adjustment Handling by tying into correction workflows and payroll consequences
- Updated section 7 to strengthen Termination of Coverage to be more explicit about payroll consequence
- Replaced section 9 to strengthen Historical Preservation to explicitly include payroll-result linkage
- Replaced section 10 to strengthen Integration with Payroll Timing to explicitly connect to result generation
- Replaced section 11 with expanded Relationship to Other Models

### 2026-04-21 — Benefit & deduction configuration model document updated

**Document update:  /docs/architecture/core/Benefit_and_Deduction_Configuration_Model.md
- Replaced Purpose section with updated text to explicitly mention payroll result generation, replay, and downstream financial consequences
- Updated section 2 to expand Core Benefit_or_Deduction_Plan Entity with lineage/context fields
- Updated section 3 to strengthen Plan Component Structure with mutation semantics
- Replaced section 4 to strengthen Contribution Definitions with replay and correction language
- Replaced section 5 to strengthen Eligibility Rules with rule-resolution linkage
- Updated section 6 to strengthen Enrollment Handling with payroll lineage
- Updated section 7 to expand Tax Treatment Integration to explicitly connect to tax result and accumulator impact behavior 
- Replaced section 8 to strengthen Employer Contribution Handling to point to liabilities and remittance more explicitly
- Updated section 9 to strengthen Deduction Scheduling by tying more explicitly to payroll calendar context
- Replaced section 10 to strengthen Plan Versioning and Governance with explicit correction/replay linkage 
- Added sub-section 10.1 to add a bridge to payroll execution results
- Replaced section 11 with expanded Relationship to Other Models

### 2026-04-21 — Reference data model document updated

**Document update:  /docs/architecture/core/Reference_Data_Model.md
- Replaced Purpose section with updated text to explicitly state that reference data participates in deterministic execution and replay
- Updated section 2 to expand Reference Data Definition with lineage fields
- Updated section 3 to expand Common Reference Data Categories by using more execution-specific categories
- Replaced section 5 to strengthen Effective Dating Requirements with explicit replay linkage
- Updated section 6 to strengthen Reference Versioning Model by explicitly mentioning runtime models consuming versioned references
- Replaced section 7 to strengthen Validation Integration by explicitly including payroll execution validation
- Updated section 9 to expand Reference Change Management with correction semantics
- Added sub-section 10.1 to add a runtime consumption bridge
- Replaced section 11 with expanded Relationship to Other Models

### 2026-04-21 — Plan & rule model document updated

**Document update:  /docs/architecture/core/Plan_and_Rule_Model.md
- Replaced Purpose section with updated text to explicitly state that artifacts are execution inputs to payroll result generation
- Updated section 2 to expand Plan Definition with lineage/context fields
- Updated section 3 to expand Rule Definition with execution impact semantics
- Replaced section 4 to strengthen Plan-Rule Association Model to explicitly preserve execution lineage
- Updated section 5 to strengthen Rule Parameterisation with replay language
- Replaced section 6 to strengthen Rule Sequencing with execution-result linkage
- Updated section 7 to expand Rate Table Definition with lineage controls
- Replaced section 8 to strengthen Plan and Rule Versioning by aligning more tightly with correction/replay logic
- Added sub-section 8.1 to add relationship to execution outputs
- Replaced section 9 with expanded Relationship to Other Models

### 2026-04-21 — Compensation & pay rate model document updated

**Document update:  /docs/architecture/core/Compensation_and_Pay_Rate_Model.md
- Replaced Purpose section with updated text to explicitly state that compensation records are governed payroll computation inputs and replay-sensitive artifacts
- Updated section 2 to expand Core Pay_Rate Entity with lineage fields
- Updated section 4 to strengthen Rate Assignment Model to link more clearly to assignment and payroll context resolution
- Replaced section 5 to expand Multiple Rate Handling with deterministic precedence
- Updated section 6 to strengthen Salary Compensation Handling to explicitly acknowledge payroll period interaction
- Replaced section 7 to strengthen Hourly Compensation Handling to explicitly connect to time-entry and premium-resolution workflows
- Updated section 8 to strengthen Rate Change and Versioning by more explicitly  stating that prior states govern historical replay
- Replaced section 9 to strengthen Retroactive Rate Changes by connecting to correction artifacts
- Replaced section 10 to expand Reporting and Audit Support to be more explicit about replay
- Replaced section 11 with expanded Relationship to Other Models

### 2026-04-21 — Employee assignment model document updated

**Document update:  /docs/architecture/core/Employee_Assignment_Model.md
- Replaced Purpose section with updated text to explicitly mention execution lineage and replay
- Updated section 2 to expand Assignment Definition with lineage fields
- Updated section 4 to strengthen Effective Dating Rules to explicitly protect historical replay
- Updated section 5 to expand Overlap Handling with exception model alignment
- Replaced section 7 to strengthen Assignment Resolution Logic
- Updated section 9 to strengthen Retroactive Assignment Changes to tie more explicitly to correction architecture
- Replaced section 10 to expand Audit and Traceability with lineage clarity
- Replaced section 11 with expanded Relationship to Other Models

### 2026-04-21 — Employee event & status change model document updated

**Document update:  /docs/architecture/core/Employee_Event_and_Status_Change_Model.md
- Replaced Purpose section with updated text to make event lineage explicit
- Updated section 2 to expand Core Employee_Event Entity with execution linkage anchors
- Updated section 4 to strengthen Status Change Model to preserve before/after state lineage
- Updated section 5 to expand Effective Dating and Timing with period lineage awareness
- Replaced section 6 to strengthen Event Impact Routing
- Replaced section 7 to expand Retroactive Event Handling
- Updated section 8 to strengthen Event Sequencing and Dependency with validation semantics
- Replaced section 9 to expand Audit and Historical Preservation with deeper lineage structure
- Replaced section 10 with expanded Relationship to Other Models

### 2026-04-21 — Accrual & entitlement model document updated

**Document update:  /docs/architecture/core/Accrual_and_Entitlement_Model.md
- Replaced Purpose section with updated text including mutation and replay language
- Updated section 2 to expand Core Entitlement_Plan Entity with policy lineage
- Updated section 3 to strengthen Accrual Rule Definition with execution semantics
- Updated section 4 to expand Entitlement Balance Entity with lineage fields
- Replaced section 5 to strengthen Accrual Triggers with governed source-event language
- Replaced section 6 to strengthen Consumption and Deduction with leave/payroll linkage
- Updated section 7 to expand Carryover and Expiration with calendar and jurisdiction lineage
- Updated section 8 to strengthen Service-Tier and Eligibility Interaction with rule resolution linkage
- Replaced section 9 to expand Manual Adjustments and Corrections with correction model linkage
- Replaced section 10 to expand Reporting and Audit Support with replay expectations
- Replaced section 11 with expanded Relationship to Other Models

### 2026-04-21 — Leave & absence management model document updated

**Document update:  /docs/architecture/core/Leave_and_Absence_Management_Model.md
- Replaced Purpose section with updated text making leave execution-aware
- Updated section 2 to expand Core Leave_Request Entity with lineage attributes
- Updated section 3 to expand Leave_Type Definition with payroll behaviour references
- Updated section 4 to strengthen Leave Status Lifecycle with consumption gating
- Replaced section 6 - Payroll Impact Handling becomes structured output model
- Updated section 7 to strengthen Accrual Integration with mutation semantics
- Updated section 8 to expand Compliance Leave Handling with jurisdiction resolution 
- Updated section 9 to expand Return to Work Handling with payroll reactivation semantics
- Replaced section 10 to strengthen Historical Tracking — critical replay dependency
- Replaced section 11 with expanded Relationship to Other Models

### 2026-04-21 — Holiday & special calendar model document updated

**Document update:  /docs/architecture/payroll/Holiday_and_Special_Calendar_Model.md
- Replaced Purpose section with updated text to make calendar authoritative
- Updated section 2 to expand Core Holiday Entity with version lineage
- Updated section 3 to strengthen Observed Date Rules with deterministic logic
- Replaced section 4 to expand Holiday Eligibility into rule-driven resolution
- Replaced section 5 to strengthen Payroll Impact Handling with result lineage
- Replaced section 6 to strengthen Leave Interaction — critical edge case domain
- Updated section 7 to expand Jurisdiction Integration into hierarchical model
- Updated section 8 to strengthen Special Calendar Events
- Replaced section 9 with expanded Relationship to Other Models

### 2026-04-21 — Scheduling & shift model document updated

**Document update:  /docs/architecture/core/Scheduling_and_Shift_Model.md
- Replaced Purpose section with updated text including execution consequences
- Updated section 2 to expand Core Schedule Entity with lineage/versioning attributes
- Updated section 3 to expand Shift Definition with compliance and premium semantics
- Updated section 5 to strengthen Employee Schedule Assignment with traceability
- Replaced section 6 to strengthen Planned vs Actual Time with payroll lineage
- Replaced section 7 to strengthen Shift Premium Interaction with rule resolution
- Replaced section 8 to expand Schedule Changes with correction semantics
- Updated section 9 to expand Compliance and Labour Rules with validation semantics
- Replaced section 10 with expanded Relationship to Other Models

### 2026-04-21 — Time entry & worked time model document updated

**Document update:  /docs/architecture/core/Time_Entry_and_Worked_Time_Model.md
- Replaced Purpose section with updated text including execution lineage language
- Updated section 2 to expand Core Time_Entry Entity with lineage identifiers
- Updated section 4 to strengthen Approval Lifecycle with governance linkage
- Updated section 5 to strengthen Aggregation Discipline
- Replaced section 6 to strengthen Payroll Integration with result lineage
- Updated section 7 to strengthen Premium Rule Triggering
- Replaced section 8 to expand Retro Correction Handling
- Replaced section 11 with expanded Relationship to Other Models

### 2026-04-21 — Overtime & premium pay model document updated

**Document update:  /docs/architecture/core/Overtime_and_Premium_Pay_Model.md
- Replaced Purpose section with updated text including result-line discipline
- Updated section 2 to expand Core Premium_Rule Entity with resolution lineage
- Updated section 3 to strengthen threshold definitions with context lineage
- Updated section 6 to expand Premium Calculation Flow with result-line identity
- Added sub-section 6.1 to add explicit interaction with taxable wage formation 
- Updated section 7 to strengthen time-entry interaction with lineage
- Replaced section 8 with expanded retroactive adjustment handling
- Replaced section 9 with expanded Relationship to Other Models

### 2026-04-21 — Earnings & deductions computation model document updated

**Document update:  /docs/architecture/calculation-engine/Earnings_and_Deductions_Computation.md
- Replaced Purpose section with updated text including execution-artifact language
- Updated section 2 to expand Core Computation Context with result lineage
- Updated section 6 to strengthen Result Line Generation with canonical structure linkage
- Added sub-section 6.1: Relationship to Accumulator Impact
- Updated section 7 to strengthen taxable wage formation with jurisdiction linkage
- Updated section 8 to expand arrears and catch-up handling with posting alignment
- Updated section 9 to strengthen retroactive recalculation semantics
- Replaced section 10 with expanded Relationship to Other Models

### 2026-04-21 — posting rules & mutation semantics model document updated

**Document update:  /docs/rules/Posting_Rules_and_Mutation_Semantics.md
- Replaced Purpose section with updated text including execution-artifact language
- Added sub-section 2.1: Relationship to Payroll Execution Results
- Updated section 3 to strengthen posting trigger classes with result-line lineage
- Updated section 4 to expand atomic transaction boundary with exception integration
- Updated section 6 to replace `Accumulator and liability mutation order` with explicit impact language
- Updated section 7 to strengthen correction behavior with correction-model linkage
- Updated section 8 to strengthen replay with execution lineage and review controls
- Updated section 9 to expand finalization semantics with downstream models
- Added sub-section 9.1: Relationship to Other Models

### 2026-04-21 — policy & rule execution model document updated

**Document update:  /docs/rules/Policy_and_Rule_Execution_Model.md
- Replaced Purpose section with updated text including execution outcomes
- Updated section 2 to expand Policy Execution Context with execution lineage
- Updated section 3 to expand Rule Invocation Framework to include mutation targets
- Replaced section 4 with stronger phase sequencing model
- Updated section 5 to expand Conditional Rule Evaluation with classification linkage
- Updated section 6 to strengthen Rule Chaining discipline 
- Replaced section 7 with updated text to expand Execution Logging into Execution Trace discipline
- Replaced section 8 with updated text to strengthen Error Handling with exception model integration
- Replaced section 9  with updated text to expand Integration Points 

### 2026-04-21 — rule resolution model document updated

**Document update:  /docs/rules/Rule_Resolution_Engine.md
- Updated Related Documents entry in document info table
- Replaced Purpose section with updated text which includes execution consequences
- Updated section 1 to expand Resolution Context Model with run/result lineage
- Added sub-section 2.1: Relationship to Payroll Result Generation
- Updated section 6 to strengthen Failure Handling with exception integration 
- Updated section 7 to strengthen caching section with replay restrictions
- Updated section 9 to expand determinism guarantees with correction handling
- Added sub-section 10.1: Relationship to Other Models

### 2026-04-21 — code classification & mapping model document updated

**Document update:  /docs/rules/Code_Classification_and_Mapping_Model.md
- Replaced Purpose section with updated text to explicitly mention payroll results, accumulator impacts, and downstream financial consequences
- Updated section 4 to expand canonical classification attributes with rule/version lineage
- Added sub-section 4.1: Relationship to Employee Payroll Result
- Replaced section 7 with updated text to strengthen accumulator routing with newer accumulator architecture 
- Added sub-section 9.1: Replay and Correction Handling
- Updated section 10 to expand error handling for downstream impact
- Replaced section 11 with updated Relationship to Other Models

### 2026-04-20 — Tax classification & obligation model document updated

**Document update:  /docs/rules/Tax_Classification_and_Obligation.md
- Replaced Purpose section with updated text to include downstream reporting, remittance, export, and correction consequences
- Updated section 5 to expand Tax Component Attributes to include obligation semantics
- Added sub-section 5.1: Relationship to Employee Payroll Result
- Replaced section 7 with newer accumulator architecture in Tax Accumulator Alignment
- Added sub-section 10.1: Correction and Reversal Handling
- Added sub-section 10.2: Downstream Obligation Alignment
- Replaced section 11 with updated Relationship to Other Models

### 2026-04-20 — Payroll-to-accounting model document updated

**Document update:  /docs/architecture/interfaces/General_Ledger_and_Accounting_Export_Model.md
- Replaced Purpose section with updated text to include execution lineage
- Updated section 2 to expand Journal_Entry entity with result-set lineage
- Updated section 3 to expand Journal_Line entity with worker/result lineage
- Added sub-section 5.1: Accounting Export Source Lineage
- Updated section 7 to add explicit balancing treatment for correction runs
- Updated section 10 to add correction-aware export behavior
- Replaced section 11 with strengthened reconciliation and validation
- Replaced section 12 with updated Relationship to Other Models

### 2026-04-20 — Payroll provider response model document updated

**Document update:  /docs/architecture/interfaces/Payroll_Provider_Response_Model.md
- Updated section 1 with appended text on preserving lineage
- Updated section 3 with additional lineage fields
- Updated section 6 to strengthen correlation keys with result-set lineage
- Added sub-section 6.1: Response Lineage Classification
- Updated section 7 with additional record-level lineage fields
- Replaced section 15 with Interaction with Reconciliation
- Updated section 16 with appended text for lineage linkage 
- Updated section 18 with appended text for lineage depth 
- Replaced section 19 with updated Relationship to Other Models

### 2026-04-20 — Payroll interface & export model document updated

**Document update:  /docs/architecture/interfaces/Payroll_Interface_and_Export_Model.md
- Updated Purpose section to include result-set lineage
- Updated section 2 to add Payroll_Run_Result_Set_ID to Export Unit Definition
- Updated section 3 to strengthen Export Record Structure with worker/result lineage
- Added sub-section 3.1: Export Source Lineage
- Added sub-section 4.1: Export Type Classification
- Updated section 7, 8 & 9 with appended text
- Replaced section 10 with updated Relationship to Other Models

### 2026-04-20 — Payroll reconciliation model document updated

**Document update:  /docs/architecture/governance/Payroll_Reconciliation_Model.md
- Updated Purpose section
- Added sub-section 1.1: Reconciliation Anchors
- Added sub-section 4.1: Financial Reconciliation Dimensions
- Updated section 4 with Additional matching criteria
- Updated section 6, 7 & 8 with appended text
- Replaced section 9 with updated Relationship to Other Models

### 2026-04-20 — Payroll net pay model document updated

**Document update:  /docs/architecture/calculation-engine/Net_Pay_and_Disbursement_Model.md
- Updated section 2 on Core Net_Pay Entity
- Added sub-section 3.1: Payment Instruction Profile Association
- Updated section 8 on Off-cycle payments to associate Payroll Run types
- Updated section 12 to reference Payroll_Run_Result_Set_Model

### 2026-04-20 — Payroll run scope model document updated

**Document update:  /docs/architecture/processing/Run_Scope_Model.md
- Added section on Relationship to Payroll Context
- Added section on Period Alignment Rules
- Updated section on Dependencies

### 2026-04-20 — Payroll context model document updated

**Document update:  /docs/architecture/payroll/Payroll_Context_Model.md
- Added sub-section 3.1: Processing Population Scope
- Added sub-section 4.1: Funding and Remittance Configuration Association
- Updated sub-section 8 on Relationship to Other Models

### 2026-04-20 — Payroll calendar model document updated

**Document update:  /docs/architecture/payroll/Payroll_Calendar_Model.md
- Added sub-section 6.1: Source Period vs Execution Period
- Added sub-section 7.1: Multiple Payroll Runs Per Period
- Updated sub-section 8 on Relationship to Other Models

### 2026-04-20 — Architectural accumulator data model document added

**New document: `docs/architecture/processing/Accumulator_Impact_Model.md`**
Model supports:
- Deterministic replay
- Accumulator traceability
- Tax and reporting reconstruction
- Retroactive recalculation
- Reversal and correction integrity
- Cross-scope rollup validation
- Auditability of accumulator mutation

### 2026-04-20 — Payroll run model document updated

**Document update:  /docs/architecture/processing/Payroll_Run_Model.md
- Added sub-section 13.1 on processing outcome relationships

### 2026-04-20 — Core Platform accumulator document updated

**Document update:  /docs/accumulators/Accumulator_Model_Detailed.md
- Added new Sections 7, 7.1 on relationships to other accumulator model files

### 2026-04-20 — Architectural payroll processing data model document added

**New document: `docs/architecture/processing/Accumulator_Definition_Model.md`**
Model defines:
- What an accumulator represents
- What kinds of results feed it
- How it resets
- How it is scoped
- How it participates in payroll calculation and reporting
- How correction and replay logic affect it

### 2026-04-20 — Architectural payroll processing data model document added

**New document: `docs/architecture/processing/Payroll_Adjustment_and_Correction_Model.md`**
Model preserves:
- Correction lineage
- Reversal logic
- Replacement logic
- Supplementary payroll outcomes
- Audit and replay integrity
- Accumulator correction traceability
- Payment and remittance correction handling

### 2026-04-20 — Architectural payroll processing data model document added

**New document: `docs/architecture/processing/Payroll_Exception_Model.md`**
Model preserves:
- Validation failures
- Calculation anomalies
- Funding issues
- Remittance issues
- Disbursement issues
- Configuration issues
- Approval holds
- Manual review requirements

### 2026-04-20 — Architectural payroll processing data model document added

**New document: `docs/architecture/processing/Employee_Payroll_Result_Model.md`**
Model preserves:
- Earnings detail
- Deduction detail
- Tax detail
- Employer contribution detail
- Net pay derivation
- Accumulator impacts
- Jurisdictional splits
- Pay-statement-ready output structure

### 2026-04-20 — Architectural payroll processing data model document added

**New document: `docs/architecture/processing/Payroll_Run_Result_Set_Model.md`**
Model preserves:
- Calculation outputs
- Employee-level results
- Funding outcomes
- Remittance outputs
- Disbursement results
- Audit and reconciliation artifacts

### 2026-04-20 — Architectural payment data model document added

**New document: `docs/architecture/data/Net_Pay_Disbursement_Data_Model.md`**
Model supports:
- Direct deposit
- Split deposit
- Live check
- Payroll card delivery
- Mixed-method payment
- Off-cycle payments
- Returned or rejected payments
- Reversal and reissue handling
- Employee-specific payment preferences

### 2026-04-20 — Architectural payroll processing data model document added

**New document: `docs/architecture/processing/Payroll_Run_Funding_and_Remittance_Map.md`**
Distinguishes between:
- Structural payroll context
- Governed configuration
- Actual run-time funding behavior
- Actual run-time remittance behavior
- Actual payment-release and delivery behavior

### 2026-04-20 — Architectural payment data model document added

**New document: `docs/architecture/data/Payment_Instruction_Profile_Data_Model.md`**
Model defines:
- Where money is sent
- How money is sent
- Which banking or settlement instructions apply
- Which payment formatting rules apply
- Which release constraints or approval controls apply
- Which payment channel is used

### 2026-04-20 — Architectural payment data model document added

**New document: `docs/architecture/data/Remittance_Profile_Data_Model.md`**
Model defines:
- Which obligations are remitted
- To whom they are remitted
- By what method they are remitted
- On what cadence they are remitted
- Which filing and payment rules apply
- Which delivery instructions govern the obligation

### 2026-04-20 — Architectural funding data model document added

**New document: `docs/architecture/data/Funding_Profile_Data_Model.md`**
Model defines:
- Where payroll funding is sourced from
- How funding is segmented
- Which funding rules apply
- Which obligations are covered by which funding arrangements
- How payroll funding behavior is controlled for a payroll population or run context

### 2026-04-20 — Architectural location data model document added

**New document: `docs/architecture/data/Work_Location_Data_Model.md`**
Model supports:
- physical worksites
- remote work locations
- hybrid work patterns
- jurisdictional refinement for payroll and labor rules
- time and attendance context
- scheduling context
- reporting and analytics by workplace
- operational assignment and cost allocation

### 2026-04-20 — Architectural authorization data model document added

**New document: `docs/architecture/data/Role_and_Permission_Model.md`**
Model defines:
- What a user is allowed to do
- Where a user is allowed to do it
- How access is granted
- How access is constrained
- How access changes are audited

### 2026-04-20 — Architectural identity data model document added

**New document: `docs/architecture/data/User_Account_Data_Model.md`**
Model represents:
- System access identity
- Authentication credential linkage
- Role-based authorization anchor
- Tenant-scoped access boundary
- Session-enabled platform participation

### 2026-04-20 — Architectural identity data model document added

**New document: `docs/architecture/data/Address_Association_Model.md`**
Model defines:
- Who the address belongs to
- How the address is used
- When the address is effective
- Whether the address is primary for that use
- How historical address usage is preserved

### 2026-04-20 — Architectural identity data model document added

**New document: `docs/architecture/data/Address_Data_Model.md`**
Model supports:
- person residential and mailing addresses
- employment-related work addresses
- legal entity registered and operational addresses
- client company business addresses
- tenant-level commercial or administrative addresses
- jurisdictional and payroll-relevant location references
- correspondence and document delivery

### 2026-04-20 — Architectural identity data model document added

**New document: `docs/architecture/data/Document_Data_Model.md`**
Document is a record associated with:
- Person
- Employment
- Legal Entity
- Client Company
- Tenant
- Onboarding process
- Compliance workflow

### 2026-04-20 — Architectural identity data model document added

**New document: `docs/architecture/data/Person_Data_Model.md`**
Model supports:
- rehire scenarios
- concurrent employments
- cross-entity movement
- historical continuity of identity
- document linkage
- self-service identity continuity
- secure handling of personally identifiable information

### 2026-04-20 — Architectural organization data model document added

**New document: `docs/architecture/data/Employment_Data_Model.md`**
Defines Employment explicitly as:
- Operational relationship between Person and Legal Entity
- Distinct from Assignment, Compensation, and Payroll
- Place where rehire and concurrent employment are anchored
- Entry point into downstream payroll and jurisdiction traversal

### 2026-04-20 — Core Platform structure document updated

**New document: `docs/architecture/core/Tenant_Client_Company_Legal_Entity_and_Jurisdiction_Structural_Relationship_Map.md`**
- Ties together four core structural models:
	Tenant
	Client Company
	Legal Entity
	Jurisdiction Registration and Jurisdiction Profile

### 2026-04-20 — Architectural organization data model document added

**New document: `docs/architecture/data/Tenant_Data_Model.md`**
Model exists to support:
- data isolation
- security scoping
- configuration ownership
- operational separation
- billing separation
- environment-level governance
- module enablement and service activation

### 2026-04-20 — Architectural organization data model document added

**New document: `docs/architecture/data/Client_Company_Data_Model.md`**
Model formalizes Client Company as:
- Grouping layer under Tenant
- Parent of one or more Legal Entities
- Preferred level for reporting and billing segmentation
- Distinct from employer-of-record and jurisdiction authority

### 2026-04-20 — Architectural legal entity data model document added

**New document: `docs/architecture/data/Legal_Entity_Data_Model.md`**
Model establishes:
- employer-of-record identity
- statutory compliance
- payroll jurisdiction resolution
- employer registration relationships
- remittance and reporting accountability

### 2026-04-20 — Architectural Rules model document added

**New document: `docs/rules/Rule_Pack_Model.md`**
Model separates:
- Jurisdictional context
- Rule packaging
- Rule execution
- Version control
- Override behavior

### 2026-04-20 — Architectural jurisdiction data model document added

**New document: `docs/architecture/data/Jurisdiction_Registration_and_Profile_Data_Model.md`**
Model introduces:
- Jurisdiction Registration
- Jurisdiction Profile
- Allows a Legal Entity to operate in one or more jurisdictions
- Maintains accurate statutory compliance and audit traceability

### 2026-04-20 — Core Platform jurisdiction document updated

**Core document update: `docs/architecture/core/Jurisdiction_and_Compliance_Rules_Model.md`**
Updates enable:
- Multi-country operation
- Effective-dated rule changes
- Deterministic replay
- Audit reconstruction

### 2026-04-20 — Core Platform composition document added

**New document: `docs/architecture/core/Platform_Composition_and_Extensibility_Model.md`**
Model establishes:
- HRIS Core System as the canonical platform center
- Optional plug-in modules as domain extensions
- Client Company as a first-class grouping construct
- Legal Entity as the statutory compliance boundary
- Jurisdiction resolution anchored to Employer-of-Record entities
- Internal extension seams supporting jurisdictional and provider variability

### 2026-04-19 — Processing Lineage architecture model added

**New document: `docs/architecture/processing/Processing_Lineage_Validation_Model.md`**
Model supports:
- Lineage integrity verification
- Replay sequencing validation
- Parent-child relationship checks
- Root run consistency checks
- Scope-to-lineage consistency validation
- Recovery and replacement chain safety

### 2026-04-19 — Processing architecture models updated

**Processing document update: `docs/architecture/processing/Payroll_Run_Model.md`**
- Normalizes processing taxonomy by distinguishing:
	operational run type
	scoped population type
	lineage relationship type

**Processing document update: `docs/architecture/processing/Error_Handling_and_Isolation_Model.md`**
- Adds the missing scope-level error class 
- Aligns containment rules across:
	participant
	scope
	batch
	run/system
- Also ties error handling back to:
	immutable parent runs
	additive child-run recovery
	lineage-aware replay

**Processing document update: `docs/architecture/processing/Calculation_Run_Lifecycle.md`**
- Splits pre-finalization rerun behavior out from post-finalization additive correction
- Adds the Run_Scope_ID
- Adds the scope validation before Ready
- Defines scope-level failure isolation
- Ties lifecycle behavior to lineage-aware replay

### 2026-04-19 — Run Scope processing architecture model added

**State model documents — 2 new STATE files added to `docs/STATE/`:**
- Payroll: STATE-RSC, STATE-RLN

### 2026-04-19 — Run Lineage processing architecture model added

**New document: `docs/architecture/processing/Run_Lineage_Model.md`**
- Establishes explicit parent-child run relationships between payroll runs

### 2026-04-19 — Run Scope processing architecture model added

**New Entity specification — 1 new DATA file added:**
- Payroll: Entity_Run_Scope

**New document: `docs/architecture/processing/Run_Scope_Model.md`**
- Introduces scoped payroll execution capability
- Enables post-finalization catch-up batch processing
- Supports explicit employee selection and query-based population
- Establishes parent-child payroll run lineage structure
- Enables adjustment-only correction processing
- Improves deterministic replay compatibility
- Reduces operational risk during recovery scenarios

**Control artifact updates:**
- index.md updated — Processing section expanded
- Architecture_Model_Inventory.md updated — Run Scope model registered
- PRD_to_Architecture_Coverage_Map.md updated — Scoped recovery capability added

### 2026-04-19 — API surface map added

**New document: `docs/SPEC/API_Surface_Map.md`**
- 21 integration points catalogued across 7 domains: HRIS, Payroll, Outbound Exports, Benefits, Compliance, and Time & Attendance (future)
- Each entry: direction, pattern, trigger, key inputs, key outputs, SLA, auth scope, governing documents
- Summary table at §8 provides a single-view inventory of the full integration surface
- Inbound API points: INT-HRS-001 to 005, INT-PAY-001 to 006, INT-BEN-001, INT-GAR-001
- Outbound export points: INT-EXP-001 to 005, INT-GAR-002
- Event publication: INT-HRS-006 (Employee Event — primary HRIS → Payroll contract)
- Future placeholder: INT-TIM-001 (Time entry import)
- Architecture_Model_Inventory updated to v3.2
- Coverage map and index updated

---

### 2026-04-19 — Benefits boundary, API contract standards, pay statement delivery

**New document: `docs/PRD/PRD-1000_Benefits_Boundary.md`**
- Resolves v1 benefits scope ambiguity explicitly with REQ-BEN-001 to 032
- In scope: payroll deduction processing, pre/post-tax classification, election management, accumulator tracking
- Out of scope: plan design, open enrollment, EOI, COBRA, ACA, carrier integration, dependents, life events
- Clarifies role of Benefit_and_Deduction_Configuration_Model and Eligibility_and_Enrollment_Lifecycle_Model as payroll-deduction-only in v1
- Cross-referenced in PRD-0400, PRD-0500, and HRIS_Module_PRD

**New document: `docs/SPEC/API_Contract_Standards.md`**
- Authentication: OAuth 2.0 Client Credentials, API key fallback, TLS 1.2+ (REQ-PLT-065 to 070)
- Authorisation: role-based scopes, tenant isolation, sensitive field scope (REQ-PLT-071 to 074)
- Versioning: URL path major version, 12-month deprecation window, 90-day notice (REQ-PLT-075 to 079)
- Request/response format: JSON, ISO 8601 dates, snake_case, response envelopes (REQ-PLT-080 to 090)
- Error handling: EXC-code errors, full HTTP status taxonomy, 422 multi-error (REQ-PLT-091 to 095)
- Idempotency: Idempotency-Key header, 24-hour window, conflict detection (REQ-PLT-096 to 099)
- Rate limiting: per-client limits, rate limit headers, Retry-After (REQ-PLT-100 to 104)
- Async operations: 202 + Job_ID pattern, job status endpoint, webhook callbacks (REQ-PLT-105 to 108)
- Performance SLAs aligned to platform NFR targets (REQ-PLT-110 to 114)

**New document: `docs/SPEC/Pay_Statement_Delivery.md`**
- Content: 10 required/optional sections with field-level requirements — employer block, employee block, pay period, earnings, deductions (pre-tax / statutory / post-tax), federal taxable wages disclosure, summary, leave balances, payment info, messages
- SSN: last 4 digits only (XXX-XX-NNNN format); full SSN prohibited on all statements
- Format: mobile-responsive HTML, PDF/A archival format, tagged accessible PDFs (REQ-PAY-030 to 035)
- Delivery: web portal mandatory, mobile web mandatory, paper opt-in only with consent tracking (REQ-PAY-040 to 050)
- Retention: 7-year minimum, terminated employee access preserved (REQ-PAY-055 to 059)
- Security: authenticated access only, 15-minute signed URL expiry, AES-256 at rest (REQ-PAY-060 to 065)
- Accessibility: WCAG 2.1 AA, screen-reader-friendly tables, tagged PDFs, 4.5:1 contrast ratio (REQ-PAY-070 to 074)
- 16 acceptance criteria and 5 performance SLAs

**Control artifact updates:**
- Architecture_Model_Inventory updated to v3.1
- PRD_to_Architecture_Coverage_Map updated with 3 new capability rows
- index.md updated

---

### 2026-04-19 — PRD enhancement pass; gap resolution; documentation reconciliation

**PRD enhancements — all 11 PRD files updated:**
- Added user stories (concise role-action-outcome format) to PRD-0200 through PRD-0900 and HRIS_Module_PRD
- Added explicit scope boundaries (in scope / out of scope for v1) with REQ IDs to all 11 PRDs
- Added acceptance criteria tables tied to existing REQ IDs to all 11 PRDs
- Added non-functional requirements with specific SLA targets to all 11 PRDs
- SLA targets cover: page load times, search performance, payroll calculation, retro processing, integration throughput, batch processing, open enrollment load, year-end processing, availability, disaster recovery, data consistency, scalability, and concurrent user targets

**HRIS gap resolution — 4 new documents:**
- `docs/architecture/core/Reporting_Hierarchy_Model.md` — Employment-to-Employment manager relationship, org chart data structure, manager termination handling, hierarchy traversal
- `docs/architecture/core/Position_Management_Model.md` — Advisory position control, headcount at position and department level, vacancy tracking, EXC-HRS-002 to 005
- `docs/SPEC/Self_Service_Model.md` — ESS/MSS action specifications, role permission matrix, event model, 5 ESS + 5 MSS actions with full inputs/outputs
- `docs/SPEC/Onboarding_Workflow.md` — Plan creation, task due date calculation, payroll activation gate, rehire vs new hire treatment, IT/Benefits/Payroll integration touch points, EXC-ONB-001 to 004

**Entity specifications — 13 new DATA files added:**
- HRIS: Entity_Assignment, Entity_Compensation_Record, Entity_Leave_Request, Entity_Document, Entity_Onboarding_Plan, Entity_Org_Unit, Entity_Job, Entity_Position
- Payroll: Entity_Payroll_Run, Entity_Payroll_Check, Entity_Accumulator
- Compliance: Entity_Legal_Order, Entity_Jurisdiction

**State model documents — 16 new STATE files added to `docs/STATE/`:**
STATE-WFL, STATE-RUN (19 states), STATE-EMP (14 states across 3 sub-entities), STATE-LEV, STATE-DOC, STATE-ONB, STATE-TIM, STATE-DED, STATE-GAR, STATE-TAX, STATE-RET, STATE-GL, STATE-YEP, STATE-EXP, STATE-REC, STATE-PRV

**Exception catalogues — 11 new EXC files added to `docs/EXC/`:**
EXC-VAL (10 rules), EXC-CAL (7), EXC-CFG (6), EXC-RUN (6), EXC-INT (7), EXC-TAX (6), EXC-TIM (5), EXC-DED (5), EXC-COR (5), EXC-AUD (4), EXC-SEC (4)

**Requirement ID convention — `docs/conventions/Requirement_ID_Convention.md` updated:**
- STATE-YER renamed to STATE-YEP
- EXC-TIM, EXC-DED, EXC-TAX, EXC-RUN prefixes added with known exception categories
- Full STATE transition values documented for all 16 prefixes

**Control artifact updates:**
- `Architecture_Model_Inventory.md` updated to v3.0 — reflects all new DATA, SPEC, STATE, EXC, and architecture model files
- `PRD_to_Architecture_Coverage_Map.md` updated — added reporting hierarchy, position management, ESS, MSS, and onboarding workflow capabilities
- `index.md` updated — DATA section restructured by domain; STATE, EXC, and new SPEC entries added; new architecture core models added

**Naming convention enforcement:**
- All PRD files renamed from 3-digit to 4-digit format (PRD-000 → PRD-0000, etc.)
- All PRD, ADR, DATA, and SPEC files renamed to use underscores throughout
- `index.md` relocated from `docs/index.md` to repo root `index.md`
- All internal cross-references updated across all files

---

### 2026-04-19 — Requirement ID convention established

**New folder: `docs/conventions/`**
- Added `docs/conventions/Requirement_ID_Convention.md` — defines the complete identifier taxonomy for requirements (REQ), state models (STATE), exception rules (EXC), and entity specifications (ENT)

**REQ prefix taxonomy locked** — 27 domain prefixes covering all platform domains from REQ-PLT through REQ-ESS

**STATE prefix taxonomy locked** — 16 domain-scoped prefixes covering all lifecycle domains from STATE-WFL through STATE-YEP, including known state values for STATE-TIM, STATE-DED, STATE-GAR, STATE-TAX, STATE-RET, STATE-GL, STATE-YEP

**EXC prefix taxonomy locked** — 11 domain-scoped prefixes covering all exception domains from EXC-VAL through EXC-RUN, including known exception categories for EXC-TIM, EXC-DED, EXC-TAX, EXC-RUN

**Updated `index.md`** — added Conventions section

---

### 2026-04-19 — Repository restructure and documentation expansion

**PRD restructure:**
- Split `docs/PRD/HCM_Platform_PRD.md` (monolithic) into 10 numbered PRD documents:
  - `PRD-0000_Core_Vision.md`
  - `PRD-0100_Architecture_Principles.md`
  - `PRD-0200_Core_Entity_Model.md`
  - `PRD-0300_Payroll_Calendar.md`
  - `PRD-0400_Earnings_Model.md`
  - `PRD-0500_Accumulator_Strategy.md`
  - `PRD-0600_Jurisdiction_Model.md`
  - `PRD-0700_Workflow_Framework.md`
  - `PRD-0800_Validation_Framework.md`
  - `PRD-0900_Integration_Model.md`
- Deleted `docs/PRD/HCM_Platform_PRD.md` (content fully migrated to above)

**New PRD:**
- Added `docs/PRD/HRIS_Module_PRD.md` — HRIS module requirements (v0.1, Draft)

**New NFR:**
- Added `docs/NFR/HCM_NFR_Specification.md` — Platform non-functional requirements (v0.1, Draft)

**New ADR documents:**
- Added `docs/ADR/ADR-001_Event_Driven_Architecture.md`
- Added `docs/ADR/ADR-002_Deterministic_Replayability.md`

**New DATA entity documents:**
- Added `docs/DATA/Entity_Person.md`
- Added `docs/DATA/Entity_Employee.md`
- Added `docs/DATA/Entity_Payroll_Item.md`

**New SPEC documents:**
- Added `docs/SPEC/External_Earnings.md`
- Added `docs/SPEC/Residual_Commissions.md`

**New index:**
- Added `index.md` — master documentation index

---

### 2026-04-15 — Initial architecture model baseline

- Established architecture model inventory (`docs/architecture/Architecture_Model_Inventory.md`)
- Established PRD-to-architecture coverage map (`docs/architecture/PRD_to_Architecture_Coverage_Map.md`)
- Published architecture models across domains: Calculation Engine, Core, Governance, Interfaces, Operations, Payroll, Processing, Rules
- Published rules models: Code Classification, Policy Execution, Posting Rules, Rule Resolution, Rule Versioning, Tax Classification
- Published accumulator model: `docs/accumulators/Accumulator_Model_Detailed.md`
- Initial monolithic PRD locked: `docs/PRD/HCM_Platform_PRD.md`

---

## Conventions

- PRD documents use `PRD-NNN-` prefix and sequential numbering by domain area.
- ADR documents use `ADR-NNN-` prefix and sequential numbering by decision date.
- DATA documents use `Entity_` prefix.
- SPEC documents use descriptive names without numbering unless a series develops.
- Architecture model documents use `PascalCase_With_Underscores` naming per existing convention.
