# CHANGELOG

All significant documentation changes to this repository are recorded here. Entries are listed in reverse chronological order.

Format: `YYYY-MM-DD — Description of change — Author/Owner`

---

## April 2026

### 2026-04-19 — Requirement ID convention established

**New folder: `docs/conventions/`**
- Added `docs/conventions/Requirement_ID_Convention.md` — defines the complete identifier taxonomy for requirements (REQ), state models (STATE), exception rules (EXC), and entity specifications (ENT)

**REQ prefix taxonomy locked** — 27 domain prefixes covering all platform domains from REQ-PLT through REQ-ESS

**STATE prefix taxonomy locked** — 16 domain-scoped prefixes covering all lifecycle domains from STATE-WFL through STATE-YEP, including known state values for STATE-TIM, STATE-DED, STATE-GAR, STATE-TAX, STATE-RET, STATE-GL, STATE-YEP

**EXC prefix taxonomy locked** — 11 domain-scoped prefixes covering all exception domains from EXC-VAL through EXC-RUN, including known exception categories for EXC-TIM, EXC-DED, EXC-TAX, EXC-RUN

**Updated `docs/index.md`** — added Conventions section

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
- Added `docs/index.md` — master documentation index

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
