# Entity — Jurisdiction

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Compliance Domain |
| **Location** | `docs/DATA/Entity_Jurisdiction.md` |
| **Related Documents** | PRD-0600_Jurisdiction_Model.md, DATA/Entity_Org_Unit.md, docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md, docs/rules/Tax_Classification_and_Obligation_Model.md |

## Purpose

Defines the Jurisdiction entity — a government authority with taxing or regulatory power over payroll activities. Jurisdictions form a hierarchy (Federal → State → County → City → Special District) and are the reference point for all tax rule resolution, compliance reporting, and garnishment priority rules.

---

## 1. Design Principles

- Jurisdictions are hierarchical but operate independently for calculation purposes.
- A single employee may be subject to multiple simultaneous jurisdictions.
- Jurisdiction rules are effective-dated and version-controlled.
- The model is designed for U.S.-first but extensible to non-U.S. jurisdictions without core model redesign.
- Non-geographic jurisdictions (school districts, transit authorities) are supported via the Is_Geographic_Flag.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Jurisdiction_ID | UUID | Yes | System-generated. Immutable. |
| Jurisdiction_Name | String | Yes | Display name |
| Jurisdiction_Type | Enum | Yes | See values below |
| Jurisdiction_Code | String | Yes | Standard code (e.g., US-GA for Georgia) |
| Parent_Jurisdiction_ID | UUID | No | Null for Federal |
| Jurisdiction_Level_Number | Integer | Yes | 1=Federal, 2=State, 3=County, 4=City, 5=Special |
| Country_Code | String | Yes | ISO 3166-1; US for initial scope |
| Is_Geographic_Flag | Boolean | Yes | False for school districts, transit authorities, etc. |
| Effective_Start_Date | Date | Yes | |
| Effective_End_Date | Date | No | |
| Jurisdiction_Status | Enum | Yes | ACTIVE, INACTIVE, ARCHIVED |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Jurisdiction_Type Values

| Value | Level | Description |
|---|---|---|
| FEDERAL | 1 | IRS, FICA, FUTA |
| STATE | 2 | State income tax, SUI, SDI |
| COUNTY | 3 | County income tax |
| CITY | 4 | City wage tax, local income tax |
| SCHOOL_DISTRICT | 5 | Earned income tax |
| SPECIAL_DISTRICT | 5 | Transit, infrastructure levies |
| TRIBAL | 5 | Tribal jurisdiction payroll tax |

---

## 4. Jurisdiction Group (Optional)

Jurisdictions may belong to groups for rule inheritance and reciprocity:

| Attribute | Type | Notes |
|---|---|---|
| Group_ID | UUID | |
| Group_Name | String | E.g., "Multi-State Reciprocity Agreement" |
| Group_Type | Enum | RECIPROCITY, REPORTING_REGION, REGULATORY_ZONE |
| Member_Jurisdiction_List | UUID[] | |

---

## 5. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Jurisdiction → Parent Jurisdiction | Many-to-one | Null for Federal |
| Jurisdiction → Child Jurisdictions | One-to-many | |
| Jurisdiction → Tax Rules | One-to-many | Rules are versioned and effective-dated |
| Jurisdiction → Org Unit (Location) | One-to-many | Locations resolve to jurisdictions via State_Code and Locality_Code |
| Jurisdiction → Legal Orders | One-to-many | Governs garnishment priority rules |

---

## 6. Jurisdiction Resolution

An employee's applicable jurisdictions are determined by:
1. Primary work location State_Code and Locality_Code → work state + local jurisdictions
2. Employee residence (if different state) → potential reciprocity or dual filing
3. Special district membership → school district, transit authority, etc.

---

## 7. Governance

- Jurisdiction records are platform-managed reference data; they are not created by individual operators.
- Jurisdiction rule versions are updated as tax law changes occur.
- All changes are audit-logged.

---

## 8. Related Architecture Models

| Model | Relevance |
|---|---|
| Jurisdiction_and_Compliance_Rules_Model | Jurisdiction hierarchy, grouping, and rule resolution |
| Tax_Classification_and_Obligation_Model | Tax rules applied within each jurisdiction |
| Garnishment_and_Legal_Order_Model | Jurisdiction governs garnishment priority |
