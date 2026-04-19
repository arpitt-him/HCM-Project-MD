# PRD-600 — Jurisdiction Model

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Jurisdiction Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Compliance Domain |
| **Location** | `docs/PRD/PRD-0600_Jurisdiction_Model.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §8 |
| **Related Documents** | PRD-0200_Core_Entity_Model, docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md, docs/rules/Tax_Classification_and_Obligation_Model.md |

## Purpose

Defines the requirements for jurisdiction modeling — the levels of government authority the platform must support, and the principles governing how jurisdictions interact with payroll calculation and compliance.

---

## 1. Supported Jurisdiction Levels

The platform shall support all of the following jurisdiction levels for U.S. payroll:

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

- Jurisdictions are hierarchical in structure but operate independently for calculation purposes.
- A single employee may be subject to multiple simultaneous jurisdictions.
- Jurisdiction applicability is determined by work location, residency, and statutory rules.
- Jurisdiction rules shall be effective-dated and version-controlled.

## 3. Multi-Jurisdiction Handling

The platform shall correctly calculate and attribute tax obligations across all applicable jurisdictions for each employee in each payroll period. Jurisdiction resolution shall be deterministic and traceable.

## 4. Future Expansion

Initial scope is U.S.-only. The jurisdiction model shall be designed for extensibility to support non-U.S. jurisdictions in future releases without requiring core model redesign.

## 5. Architecture Model Reference

- `docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md`
- `docs/rules/Tax_Classification_and_Obligation_Model.md`
