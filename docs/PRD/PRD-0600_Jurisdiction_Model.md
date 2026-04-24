# PRD-600 — Jurisdiction Model

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Jurisdiction Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Compliance Domain |
| **Location** | `docs/PRD/PRD-0600_Jurisdiction_Model.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §8 |
| **Related Documents** | PRD-0200_Core_Entity_Model, docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md, docs/rules/Tax_Classification_and_Obligation_Model.md |

## Purpose

Defines the requirements for jurisdiction modelling — the levels of government authority the platform must support, and the principles governing how jurisdictions interact with payroll calculation and compliance.

---

## 1. Supported Jurisdiction Levels

The platform shall support all of the following jurisdiction levels for U.S. payroll:

**REQ-JUR-001**
The platform shall support Federal jurisdiction for payroll tax calculation and compliance reporting.

**REQ-JUR-002**
The platform shall support State jurisdiction including income tax, SUI, and SDI.

**REQ-JUR-003**
The platform shall support County jurisdiction including county income tax.

**REQ-JUR-004**
The platform shall support City jurisdiction including city wage tax and local income tax.

**REQ-JUR-005**
The platform shall support School District jurisdiction including earned income tax.

**REQ-JUR-006**
The platform shall support Special District jurisdiction including transit and infrastructure levies.

**REQ-JUR-007**
The platform shall support Tribal Authority jurisdiction for tribal payroll tax.

| Level | Examples |
|---|---|
| Federal | IRS, FICA, FUTA |
| State | Income tax, SUI, SDI |
| County | County income tax |
| City | City wage tax, local income tax |
| School District | Earned income tax |
| Special District | Transit, infrastructure levies |
| Tribal Authority | Tribal jurisdiction payroll tax |

## 2. Jurisdiction Principles

**REQ-JUR-010**
Jurisdictions shall be hierarchical in structure but shall operate independently for calculation purposes.

**REQ-JUR-011**
A single employee may be subject to multiple simultaneous jurisdictions. The platform shall calculate and attribute tax obligations across all applicable jurisdictions for each employee in each payroll period.

**REQ-JUR-012**
Jurisdiction applicability shall be determined by work location, residency, and statutory rules.

**REQ-JUR-013**
Jurisdiction rules shall be effective-dated and version-controlled.

**REQ-JUR-014**
Jurisdiction resolution shall be deterministic and traceable — the system must be able to explain which jurisdictions applied to a given employee in a given period and why.

## 3. Future Expansion

**REQ-JUR-020**
The jurisdiction model shall be designed for extensibility to support non-U.S. jurisdictions in future releases without requiring core model redesign.

## 4. Architecture Model Reference

- `docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md`
- `docs/rules/Tax_Classification_and_Obligation_Model.md`

---

## 5. User Stories

**Payroll Engineer** needs to **determine the complete set of applicable tax jurisdictions for each employee in each period** in order to **calculate the correct federal, state, and local tax obligations without manual intervention.**

**Compliance Officer** needs to **verify that the correct jurisdictions were applied to each employee's payroll** in order to **confirm that multi-state employees were taxed correctly and that no jurisdiction was missed.**

**Payroll Administrator** needs to **configure jurisdiction rules that take effect on a specific date** in order to **ensure that mid-year jurisdiction changes (e.g., employee moves states) are applied from the correct effective date.**

**Platform Architect** needs to **add a new U.S. jurisdiction type without redesigning the core jurisdiction model** in order to **respond to new tax authority requirements without a major platform release.**

---

## 6. Scope Boundaries

### In Scope — v1

**REQ-JUR-030**
All seven U.S. jurisdiction levels defined in §1 (Federal, State, County, City, School District, Special District, Tribal) shall be supported in v1.

**REQ-JUR-031**
Multi-jurisdiction resolution for employees with work location and residence in different states shall be supported in v1.

**REQ-JUR-032**
Jurisdiction rules shall be effective-dated and version-controlled in v1.

### Out of Scope — v1

**REQ-JUR-033**
Non-U.S. jurisdiction structures are out of scope for v1. The model must be extensible but no non-U.S. jurisdiction data or rules shall be implemented.

**REQ-JUR-034**
Automated reciprocity agreement application (where the platform automatically determines the correct treatment based on state-to-state agreements without HR input) is deferred to a future release. Reciprocity conflicts surface as EXC-TAX-003 requiring operator resolution in v1.

---

## 7. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-JUR-001 | Federal income tax, Social Security, and Medicare are calculated for every employee in every payroll run regardless of work location. |
| REQ-JUR-002 | An employee working in Georgia has Georgia state income tax and Georgia SUI correctly calculated. |
| REQ-JUR-003 | An employee in a county with a county income tax has that tax calculated in addition to federal and state taxes. |
| REQ-JUR-004 | An employee in a city with a city wage tax has that tax calculated correctly alongside all applicable higher-level jurisdictions. |
| REQ-JUR-010 | An employee who changes work location from one state to another mid-year has the old state jurisdiction applied up to the change date and the new state applied from the change date. |
| REQ-JUR-011 | An employee whose work state and residence state differ has both jurisdictions evaluated and the correct treatment applied per applicable rules. |
| REQ-JUR-012 | A jurisdiction rule updated mid-year with an effective date applies to runs on or after that date and does not affect prior closed runs. |
| REQ-JUR-013 | An employee with no jurisdiction assignment generates EXC-TAX-002 and is excluded from the run until the assignment is provided. |
| REQ-JUR-014 | The system can correctly calculate tax for an employee subject to Federal + State + County + City simultaneously. |
| REQ-JUR-020 | A new jurisdiction type can be added to the jurisdiction hierarchy and assigned to employees without requiring a platform code change. |

---

## 8. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.


**REQ-JUR-040**
Jurisdiction resolution for a single employee (determining all applicable jurisdictions and rules) shall complete within 1 second.

**REQ-JUR-041**
Jurisdiction rule lookup (retrieving the active rule version for a jurisdiction and effective date) shall return within 500 milliseconds.

**REQ-JUR-042**
The jurisdiction hierarchy shall support at least 10,000 distinct jurisdiction nodes without performance degradation below defined SLAs.
