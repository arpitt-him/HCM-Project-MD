# CHANGELOG

All significant documentation changes to this repository are recorded here. Entries are listed in reverse chronological order.

Format: `YYYY-MM-DD — Description of change — Author/Owner`

--- 

## April 2026

### 2026-04-21 — Accrual & entitlement model document updated

**Document update:  /docs/architecture/core/Accrual_and_Entitlement_Model.md
- Replaced Purpose section with updated text including mutation and replay language
- Updated section 2 to expand Core Entitlement_Plan Entity with policy lineage
- Updated section 3 to strengthen Accrual Rule Definition with execution semantics
- Updated section 4 to expand Entitlement Balance Entity with lineage fields
- Replaced section 5 to strengthen Accrual Triggers with governed source-event language
- Replaced section 6 to strengthenConsumption and Deduction with leave/payroll linkage
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
- Added sub-section 6.1 on Relationship to Accumulator Impact
- Updated section 7 to strengthen taxable wage formation with jurisdiction linkage
- Updated section 8 to expand arrears and catch-up handling with posting alignment
- Updated section 9 to strengthen retroactive recalculation semantics
- Replaced section 10 with expanded Relationship to Other Models

### 2026-04-21 — posting rules & mutation semantics model document updated

**Document update:  /docs/rules/Posting_Rules_and_Mutation_Semantics.md
- Replaced Purpose section with updated text including execution-artifact language
- Added sub-section 2.1 on Relationship to Payroll Execution Results
- Updated section 3 to strengthen posting trigger classes with result-line lineage
- Updated section 4 to expand atomic transaction boundary with exception integration
- Updated section 6 to replace `Accumulator and liability mutation order` with explicit impact language
- Updated section 7 to strengthen correction behavior with correction-model linkage
- Updated section 8 to strengthen replay with execution lineage and review controls
- Updated section 9 to expand finalization semantics with downstream models
- Added sub-section 9.1 on Relationship to Other Models

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
- Added sub-section 2.1 on Relationship to Payroll Result Generation
- Updated section 6 to strengthen Failure Handling with exception integration 
- Updated section 7 to strengthen caching section with replay restrictions
- Updated section 9 to expand determinism guarantees with correction handling
- Added sub-section 10.1 on Relationship to Other Models

### 2026-04-21 — code classification & mapping model document updated

**Document update:  /docs/rules/Code_Classification_and_Mapping_Model.md
- Replaced Purpose section with updated text to explicitly mention payroll results, accumulator impacts, and downstream financial consequences
- Updated section 4 to expand canonical classification attributes with rule/version lineage
- Added sub-section 4.1 on Relationship to Employee Payroll Result
- Replaced section 7 with updated text to strengthen accumulator routing with newer accumulator architecture 
- Added sub-section 9.1 on Replay and Correction Handling
- Updated section 10 to expand error handling for downstream impact
- Replaced section 11 with updated Relationship to Other Models

### 2026-04-20 — Tax classification & obligation model document updated

**Document update:  /docs/rules/Tax_Classification_and_Obligation.md
- Replaced Purpose section with updated text to include downstream reporting, remittance, export, and correction consequences
- Updated section 5 to expand Tax Component Attributes to include obligation semantics
- Added sub-section 5.1 on Relationship to Employee Payroll Result
- Replaced section 7 with newer accumulator architecture in Tax Accumulator Alignment
- Added sub-section 10.1 on Correction and Reversal Handling
- Added sub-section 10.2 on Downstream Obligation Alignment
- Replaced section 11 with updated Relationship to Other Models

### 2026-04-20 — Payroll-to-accounting model document updated

**Document update:  /docs/architecture/interfaces/General_Ledger_and_Accounting_Export_Model.md
- Replaced Purpose section with updated text to include execution lineage
- Updated section 2 to expand Journal_Entry entity with result-set lineage
- Updated section 3 to expand Journal_Line entity with worker/result lineage
- Added sub-section 5.1 on Accounting Export Source Lineage
- Updated section 7 to add explicit balancing treatment for correction runs
- Updated section 10 to add correction-aware export behavior
- Replaced section 11 with strengthened reconciliation and validation
- Replaced section 12 with updated Relationship to Other Models

### 2026-04-20 — Payroll provider response model document updated

**Document update:  /docs/architecture/interfaces/Payroll_Provider_Response_Model.md
- Updated section 1 with appended text on preserving lineage
- Updated section 3 with additional lineage fields
- Updated section 6 to strengthen correlation keys with result-set lineage
- Added sub-section 6.1 on Response Lineage Classification
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
- Added sub-section 3.1 on Export Source Lineage
- Added sub-section 4.1 on Export Type Classification
- Updated section 7, 8 & 9 with appended text
- Replaced section 10 with updated Relationship to Other Models

### 2026-04-20 — Payroll reconciliation model document updated

**Document update:  /docs/architecture/governance/Payroll_Reconciliation_Model.md
- Updated Purpose section
- Added sub-section 1.1 on Reconciliation Anchors
- Added sub-section 4.1 on Financial Reconciliation Dimensions
- Updated section 4 with Additional matching criteria
- Updated section 6, 7 & 8 with appended text
- Replaced section 9 with updated Relationship to Other Models

### 2026-04-20 — Payroll net pay model document updated

**Document update:  /docs/architecture/calculation-engine/Net_Pay_and_Disbursement_Model.md
- Updated section 2 on Core Net_Pay Entity
- Added sub-section 3.1 on Payment Instruction Profile Association
- Updated section 8 on Off-cycle payments to associate Payroll Run types
- Updated section 12 to reference Payroll_Run_Result_Set_Model

### 2026-04-20 — Payroll run scope model document updated

**Document update:  /docs/architecture/processing/Run_Scope_Model.md
- Added section on Relationship to Payroll Context
- Added section on Period Alignment Rules
- Updated section on Dependencies

### 2026-04-20 — Payroll context model document updated

**Document update:  /docs/architecture/payroll/Payroll_Context_Model.md
- Added sub-section 3.1 on Processing Population Scope
- Added sub-section 4.1 on Funding and Remittance Configuration Association
- Updated sub-section 8 on Relationship to Other Models

### 2026-04-20 — Payroll calendar model document updated

**Document update:  /docs/architecture/payroll/Payroll_Calendar_Model.md
- Added sub-section 6.1 on Source Period vs Execution Period
- Added sub-section 7.1 on Multiple Payroll Runs Per Period
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
