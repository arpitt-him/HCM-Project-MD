# Entity — Org Unit

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / HRIS |
| **Location** | `docs/DATA/Entity_Org_Unit.md` |
| **Related Documents** | DATA/Entity_Employee.md, HRIS_Module_PRD.md §7, docs/architecture/core/Organizational_Structure_Model.md |

## Purpose

Defines the Org Unit entity — a node in the organisational hierarchy representing a Legal Entity, Division, Business Unit, Department, Cost Center, Location, or Region. Org Units provide the structural context for HR records, payroll cost allocation, and tax jurisdiction resolution.

---

## 1. Design Principles

- Org unit hierarchies are parent-child and must be acyclic.
- Each unit may have one parent and multiple children.
- All changes are effective-dated and historically preserved.
- Rollup relationships are deterministic for reporting and payroll aggregation.
- Location records include jurisdiction fields that drive tax resolution.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Org_Unit_ID | UUID | Yes | System-generated. Immutable. |
| Org_Unit_Type | Enum | Yes | See values below |
| Org_Unit_Code | String | Yes | Short code; unique within type |
| Org_Unit_Name | String | Yes | Display name |
| Parent_Org_Unit_ID | UUID | No | Null for root nodes |
| Effective_Start_Date | Date | Yes | |
| Effective_End_Date | Date | No | Null for currently active units |
| Org_Status | Enum | Yes | ACTIVE, INACTIVE, ARCHIVED |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Org_Unit_Type Values

| Value | Description |
|---|---|
| LEGAL_ENTITY | Payroll and regulatory boundary |
| DIVISION | Top-level business division |
| BUSINESS_UNIT | Business unit beneath division |
| DEPARTMENT | Operational department |
| COST_CENTER | Financial allocation unit |
| LOCATION | Physical or virtual work location |
| REGION | Geographic grouping |

---

## 4. Legal Entity Additional Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Tax_Registration_Number | String | Yes | EIN for US entities |
| Country_Code | String | Yes | ISO 3166-1 alpha-2 |
| State_of_Incorporation | String | No | US state code |
| Legal_Entity_Type | Enum | No | CORPORATION, LLC, PARTNERSHIP, etc. |

---

## 5. Location Additional Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Address_Line_1 | String | Yes | |
| Address_Line_2 | String | No | |
| City | String | Yes | |
| State_Code | String | Yes | US state code; drives tax jurisdiction |
| Postal_Code | String | Yes | |
| Country_Code | String | Yes | |
| Locality_Code | String | No | Local tax jurisdiction code |
| Work_Location_Type | Enum | Yes | OFFICE, REMOTE, HYBRID |

---

## 6. Hierarchy Rules

- Hierarchies must be acyclic. A unit may not be its own ancestor.
- Legal Entity nodes are typically root nodes or near-root nodes.
- Locations are typically leaf nodes.
- Effective dating applies to both the unit definition and its parent relationship.

---

## 7. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Org Unit → Parent Org Unit | Many-to-one | Null for root |
| Org Unit → Child Org Units | One-to-many | |
| Org Unit → Assignments | One-to-many | Via Department_ID or Location_ID |
| Location → Jurisdiction | Many-to-one | State_Code + Locality_Code resolve tax jurisdiction |

---

## 8. Governance

- Org unit changes require approval workflow completion.
- Location State_Code changes trigger jurisdiction reassignment for all affected employees.
- All org unit changes are audit-logged with timestamp and actor.

---

## 9. Related Architecture Models

| Model | Relevance |
|---|---|
| Organizational_Structure_Model | Full hierarchy rules and rollup definitions |
| Jurisdiction_and_Compliance_Rules_Model | Location-to-jurisdiction resolution |
| Security_and_Access_Control_Model | Org-scoped access control |
