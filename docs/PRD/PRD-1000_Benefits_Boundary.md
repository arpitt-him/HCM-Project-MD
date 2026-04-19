# PRD-1000 — Benefits Boundary

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Benefits Boundary Definition |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-1000_Benefits_Boundary.md` |
| **Related Documents** | PRD-0000_Core_Vision, PRD-0400_Earnings_Model, PRD-0500_Accumulator_Strategy, HRIS_Module_PRD, docs/architecture/core/Benefit_and_Deduction_Configuration_Model.md, docs/architecture/core/Eligibility_and_Enrollment_Lifecycle_Model.md, docs/EXC/EXC-DED_Benefits_Deductions_Exceptions.md |

## Purpose

Defines the precise boundary between what the platform supports for benefits in v1 versus what is deferred to a future Benefits Administration module. The existence of benefit-related architecture models — `Benefit_and_Deduction_Configuration_Model` and `Eligibility_and_Enrollment_Lifecycle_Model` — has created ambiguity about the scope of v1 benefits support. This document resolves that ambiguity with explicit, addressable requirements.

The core distinction is:

- **In scope v1:** Payroll deduction processing — the platform calculates and posts benefit-related deductions from payroll results based on elections received from an external source or manually configured by an HR administrator.
- **Out of scope v1:** Benefits plan administration — plan design, carrier integration, open enrollment workflow, evidence of insurability, COBRA, and ACA reporting.

---

## 1. User Stories

**Payroll Administrator** needs to **configure and process employee benefit deductions in payroll** in order to **correctly reduce gross pay by pre-tax and post-tax benefit amounts without requiring a separate benefits administration system in v1.**

**Payroll Engineer** needs to **classify each benefit deduction as pre-tax or post-tax** in order to **correctly calculate taxable wages, apply the right accumulator targets, and produce accurate pay statements.**

**HR Administrator** needs to **manually enter or import employee benefit election amounts** in order to **drive payroll deduction processing when a full benefits administration system is not yet in place.**

**Implementation Consultant** needs to **understand precisely what benefit functionality is and is not available in v1** in order to **correctly scope implementation work and set client expectations.**

---

## 2. Scope Boundaries

### In Scope — v1 (Payroll Deduction Processing)

**REQ-BEN-001**
The platform shall support the configuration of benefit deduction codes mapped to canonical deduction types (pre-tax, post-tax) per the Code_Classification_and_Mapping_Model.

**REQ-BEN-002**
The platform shall support per-employee benefit deduction elections specifying: deduction code, employee amount, employer contribution amount (if applicable), effective start date, and effective end date.

**REQ-BEN-003**
The platform shall calculate and post benefit deductions in each payroll run for employees with active deduction elections in STATE-DED-003 (Active).

**REQ-BEN-004**
The platform shall correctly classify benefit deductions as pre-tax or post-tax for purposes of taxable wage calculation. Pre-tax deductions shall reduce the taxable wage base before tax calculation.

**REQ-BEN-005**
The platform shall support employer contribution amounts associated with benefit deductions. Employer contributions shall be tracked separately from employee deductions and shall not affect employee net pay.

**REQ-BEN-006**
The platform shall track benefit deduction accumulators (employee deduction YTD, employer contribution YTD) per the Accumulator_and_Balance_Model.

**REQ-BEN-007**
The platform shall support benefit deduction elections entered manually by an HR administrator through the platform UI.

**REQ-BEN-008**
The platform shall support benefit deduction elections imported via batch file or API per the Integration_and_Data_Exchange_Model.

**REQ-BEN-009**
The platform shall enforce deduction effective dates — a deduction election shall not apply to payroll periods before its effective start date or after its effective end date.

**REQ-BEN-010**
The platform shall generate EXC-DED-002 (Warning) when a benefit-eligible employee has no active deduction election for a deduction type configured as required for their employment classification.

**REQ-BEN-011**
The platform shall support the suspension and termination of benefit deductions via lifecycle events (leave of absence, termination) per the STATE-DED state model.

**REQ-BEN-012**
Benefit deduction lines shall appear on the employee pay statement with correct description, current-period amount, and YTD amount, separated into pre-tax and post-tax sections.

### Out of Scope — v1 (Benefits Administration)

**REQ-BEN-020**
Benefits plan design and configuration — plan types, coverage tiers, premium schedules, carrier definitions — are out of scope for v1. Plan-level data must be maintained in an external system and communicated to the platform as deduction election amounts.

**REQ-BEN-021**
Open enrollment workflow — eligibility windows, employee benefit selections, plan comparison, dependent management — is out of scope for v1.

**REQ-BEN-022**
Evidence of Insurability (EOI) processing — carrier underwriting workflows, approval tracking, coverage effective date management — is out of scope for v1.

**REQ-BEN-023**
COBRA administration — qualifying event tracking, election notices, COBRA premium billing — is out of scope for v1.

**REQ-BEN-024**
ACA compliance reporting — 1095-C generation, ALE status determination, offer-of-coverage tracking — is out of scope for v1.

**REQ-BEN-025**
Carrier integration — EDI 834 file generation, carrier premium remittance, carrier reconciliation — is out of scope for v1.

**REQ-BEN-026**
Dependent tracking — dependent records, relationship types, dependent eligibility — is out of scope for v1. Deduction amounts are accepted as-is without dependent-level decomposition.

**REQ-BEN-027**
Life event processing — marriage, birth, divorce, adoption triggering benefit changes outside of open enrollment — is out of scope for v1.

---

## 3. Architecture Model Clarification

The following architecture models exist in v1 to support payroll deduction processing, not full benefits administration:

| Model | v1 Role |
|---|---|
| Benefit_and_Deduction_Configuration_Model | Defines the deduction code structure and pre/post-tax classification used by the payroll calculation engine. Does not include plan design or carrier configuration. |
| Eligibility_and_Enrollment_Lifecycle_Model | Defines the enrollment state model (STATE-DED) governing when deductions are active, suspended, or terminated within payroll. Does not include open enrollment or EOI workflows. |

Both models are deliberately scoped to support payroll deduction processing only. They are designed to be extended by a future Benefits Administration module without requiring core redesign.

---

## 4. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-BEN-001 | A deduction code configured as PRE_TAX is applied before tax calculation. A deduction code configured as POST_TAX is applied after tax calculation. The taxable wage differs between the two scenarios by the deduction amount. |
| REQ-BEN-002 | An employee deduction election with an employer contribution amount produces separate payroll item lines — one for the employee deduction and one for the employer contribution — on the payroll check. |
| REQ-BEN-003 | A deduction election in STATE-DED-003 (Active) is applied in every payroll run during its effective date range. A deduction in STATE-DED-004 (Suspended) is not applied. |
| REQ-BEN-004 | A pre-tax 401(k) deduction of $200 reduces the federal taxable wage base by $200 before federal income tax is calculated. |
| REQ-BEN-006 | An employee's YTD benefit deduction accumulator equals the sum of all benefit deduction amounts posted across all payroll runs in the tax year. |
| REQ-BEN-009 | A deduction election with an effective start date of April 1 is not applied to a March payroll run even if entered before March processing begins. |
| REQ-BEN-011 | A termination event triggers transition of active deduction elections to STATE-DED-005 (Terminated). The deduction is not applied to any payroll run after the termination date. |
| REQ-BEN-012 | Pre-tax benefit deductions and post-tax benefit deductions appear as distinct sections on the employee pay statement with separate subtotals. |

---

## 5. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.

**REQ-BEN-030**
A benefit deduction election import file containing 50,000 records shall complete validation and staging within 5 minutes.

**REQ-BEN-031**
A benefit deduction code lookup (resolving pre/post-tax classification for a given code) shall return within 500 milliseconds.

**REQ-BEN-032**
Benefit deduction processing shall not increase total payroll calculation time by more than 5% for a run of equivalent size without benefit deductions.
