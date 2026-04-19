# CHANGELOG

All significant documentation changes to this repository are recorded here. Entries are listed in reverse chronological order.

Format: `YYYY-MM-DD — Description of change — Author/Owner`

---

## April 2026

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
