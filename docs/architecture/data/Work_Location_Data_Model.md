# Work_Location_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Operations & Workforce Domain |
| **Location** | docs/architecture/data/Work_Location_Data_Model.md |
| **Domain** | Work Location / Operational Geography / Workplace Context |
| **Related Documents** | Address_Data_Model.md, Address_Association_Model.md, Employment_Data_Model.md, Organizational_Structure_Model.md, Jurisdiction_Registration_and_Profile_Data_Model.md, Multi_Context_Calendar_Model.md, Scheduling_and_Shift_Model.md, Time_Entry_and_Worked_Time_Model.md |

---

# Purpose

This document defines the core data structure for **Work Location** as the operational workplace reference used by the platform.

Work Location is not merely an Address.

Work Location is not merely an Org Unit.

Work Location is the governed operational place at which work is expected, assigned, tracked, reported, or evaluated for compliance purposes.

This model exists to support:

- physical worksites
- remote work locations
- hybrid work patterns
- jurisdictional refinement for payroll and labor rules
- time and attendance context
- scheduling context
- reporting and analytics by workplace
- operational assignment and cost allocation

without embedding workplace semantics directly into raw address fields.

---

# Core Structural Role

```text
Legal Entity / Org Unit / Employment / Assignment
    ↓
Work Location
    ↓
Address Association / Jurisdiction Refinement / Calendar / Scheduling / Time Tracking
```

Work Location is the operational workplace construct.

Address provides postal/physical details.

Work Location provides business and compliance meaning.

---

# 1. Work Location Definition

A **Work Location** represents a governed operational place where work may be performed or attributed.

A Work Location may represent:

- headquarters
- branch office
- warehouse
- retail store
- field office
- client site
- home/remote worksite
- hybrid location grouping
- temporary project site

Work Location shall be modeled as distinct from:

- Address
- Legal Entity
- Org Unit
- Employment
- Schedule
- Jurisdiction
- Payroll Context

Work Location is the operational place construct, not the employer, not the address, and not the payroll result.

---

# 2. Work Location Primary Attributes

| Field Name | Description |
|---|---|
| Work_Location_ID | Unique identifier |
| Work_Location_Code | Business/system code |
| Work_Location_Name | Human-readable location name |
| Work_Location_Type | Office, Store, Warehouse, Plant, Client_Site, Remote, Hybrid, Other |
| Legal_Entity_ID | Governing Legal Entity reference |
| Org_Unit_ID | Optional related org unit reference |
| Address_Association_ID | Primary address association reference |
| Work_Location_Status | Pending, Active, Suspended, Inactive, Closed |
| Effective_Start_Date | Date location becomes operationally effective |
| Effective_End_Date | Date location ceases operational use |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Work Location Functional Attributes

| Field Name | Description |
|---|---|
| Default_Time_Zone_Code | Default local time zone |
| Payroll_Locality_Relevance_Flag | Indicates payroll locality relevance |
| Labor_Law_Relevance_Flag | Indicates labor-rule relevance |
| Scheduling_Enabled_Flag | Indicates scheduling applicability |
| Time_Tracking_Enabled_Flag | Indicates time-capture applicability |
| Attendance_Tracking_Enabled_Flag | Indicates attendance control applicability |
| Capacity_Count | Optional workplace capacity/headcount indicator |
| Remote_Eligible_Flag | Indicates remote assignment compatibility |
| Calendar_Context_ID | Default calendar reference |
| Cost_Center_ID | Optional cost allocation reference |
| Manager_Position_ID | Optional local workplace manager reference |
| Notes | Administrative notes |

---

# 4. Work Location as Operational Context

Work Location establishes the operational context for work performance.

It may influence:

- schedule assignment
- shift planning
- attendance rules
- time-entry validation
- payroll locality refinement
- labor-law applicability
- headcount reporting
- workplace analytics

Work Location does not replace Legal Entity as the employer-of-record or statutory anchor.

Instead, Work Location refines operational and jurisdictional context within the broader legal structure.

---

# 5. Relationship to Address

Work Location may reference one or more Addresses through Address Association.

Typical structure:

```text
Work Location
    └── Address Association (1..n)
            └── Address
```

A Work Location may have:

- primary site address
- mailing address
- service entrance address
- temporary operational address

Address provides location details.

Work Location provides operational meaning.

The same Address may sometimes support more than one Work Location where governance permits, but the platform must preserve explicit ownership and role semantics.

---

# 6. Relationship to Legal Entity

```text
Legal Entity
    └── Work Location (0..n)
```

Constraints:

- Each Work Location must reference exactly one governing Legal Entity.
- A Legal Entity may operate multiple Work Locations.
- A Work Location may not span multiple Legal Entities unless explicitly modeled as separate records.

This relationship matters for:

- payroll refinement
- local compliance
- workforce reporting
- operational accountability

Work Location does not replace the statutory chain; it exists beneath Legal Entity.

---

# 7. Relationship to Org Structure

Work Location may also relate to Organizational Structure.

Examples:

- branch as an Org Unit with a linked Work Location
- department operating primarily at a Work Location
- region grouping multiple Work Locations

Where Work Location and Org Unit are both modeled:

- Org Unit answers structural reporting questions
- Work Location answers operational workplace questions

The two may be linked, but they are not interchangeable.

---

# 8. Relationship to Employment and Assignment

Work Location may attach to Employment or Assignment as the expected place of work.

Typical structures:

```text
Employment
    └── Default Work Location

Assignment
    └── Work Location
```

Work Location may change over time without ending the underlying Employment.

Examples:

- transfer from Store A to Store B
- temporary project-site assignment
- remote-work designation
- hybrid office rotation

For many operational scenarios, Work Location belongs more naturally to Assignment than to core Employment.

A default Work Location on Employment may still be useful for payroll, reporting, and self-service.

---

# 9. Relationship to Scheduling and Time Tracking

Work Location may provide the context for:

- shift assignment
- attendance rules
- break rules
- premium pay conditions
- geofenced time capture
- worksite-based approval workflows

Examples:

```text
Work Location
    └── Schedule Context
    └── Time Tracking Rules
    └── Attendance Controls
```

Work Location is often the key bridge between geographic reality and operational labor control.

---

# 10. Relationship to Jurisdiction and Compliance

Work Location may refine jurisdictional and compliance behavior.

Examples:

- city tax applicability
- county payroll tax applicability
- local labor-law obligations
- state sick leave rules
- municipal reporting requirements

However, Work Location shall not replace Legal Entity and Jurisdiction Registration as the primary compliance path.

The broader path remains:

```text
Employment
    → Legal Entity
        → Jurisdiction Registration
            → Jurisdiction Profile
```

Work Location contributes locality and operational refinement, not statutory anchor identity.

---

# 11. Work Location Status Model

Suggested Work_Location_Status values:

| Status | Meaning |
|---|---|
| Pending | Created but not yet operational |
| Active | Operationally available |
| Suspended | Temporarily not available for operational use |
| Inactive | Retained historically but not in current use |
| Closed | Permanently closed and retained for history |

Status transitions shall be governed and auditable.

Closed or Inactive Work Locations may not receive new schedules, time entries, or active assignments without explicit reactivation or governed exception handling.

---

# 12. Effective Dating and Historical Preservation

Work Location shall support effective-dated lifecycle management.

Changes that may require historical preservation include:

- opening or closing of a worksite
- change of primary address
- worksite reclassification
- labor-rule applicability changes
- calendar context changes
- cost center reassignment
- remote/hybrid designation changes

Historical values must be preserved.

Silent overwrite is not permitted where changes affect payroll locality, labor compliance, reporting, or historical operational analysis.

---

# 13. Validation Rules

Examples of validation rules:

- Work_Location_Name is required
- Work_Location_Type is required
- Legal_Entity_ID is required
- Effective_Start_Date is required
- Effective_End_Date may not precede Effective_Start_Date
- Closed locations may not receive new active assignments
- Time_Tracking_Enabled_Flag may require calendar and time-zone configuration
- Remote Work_Location_Type may require explicit policy handling
- Payroll_Locality_Relevance_Flag may require address validation where applicable

These validations may be enforced through validation frameworks, workflow controls, and scheduling/time policies.

---

# 14. Audit and Traceability Requirements

The system shall preserve:

- work location creation history
- status transition history
- legal entity linkage history
- address association history
- calendar context history
- assignment usage history
- labor/payroll relevance flag history

This supports:

- payroll replay
- local compliance analysis
- workforce reporting
- operational change review
- audit reconstruction

---

# 15. Relationship to Other Models

This model integrates with:

- Address_Data_Model
- Address_Association_Model
- Employment_Data_Model
- Organizational_Structure_Model
- Jurisdiction_Registration_and_Profile_Data_Model
- Multi_Context_Calendar_Model
- Scheduling_and_Shift_Model
- Time_Entry_and_Worked_Time_Model

---

# 16. Summary

This model establishes Work Location as the governed operational workplace construct of the platform.

Key principles:

- Work Location is distinct from Address, Org Unit, and Legal Entity
- Work Location provides workplace semantics, not merely postal detail
- Work Location attaches beneath Legal Entity and may relate to Org Units, Employment, and Assignment
- Work Location may refine payroll locality and labor-law context
- Work Location supports scheduling, attendance, and time tracking
- Historical integrity and effective dating are mandatory
