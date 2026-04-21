# Jurisdiction_Registration_and_Profile_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Governance / Compliance Domain |
| **Location** | docs/architecture/data/Jurisdiction_Registration_and_Profile_Data_Model.md |
| **Domain** | Jurisdiction & Compliance |
| **Related Documents** | Jurisdiction_and_Compliance_Rules_Model.md, Organizational_Structure_Model.md, Rule_Resolution_Engine.md |

---

# Purpose

This document defines the core data structures supporting jurisdictional compliance and rule resolution.

It introduces two primary constructs:

- **Jurisdiction Registration**
- **Jurisdiction Profile**

These constructs allow a Legal Entity to operate in one or more jurisdictions while maintaining accurate statutory compliance and audit traceability.

---

# Core Structural Model

```text
Legal Entity
    ↓
Jurisdiction Registration(s)
    ↓
Jurisdiction Profile
    ↓
Rule Resolution
```

---

# 1. Jurisdiction Registration Model

A **Jurisdiction Registration** represents the formal compliance presence of a Legal Entity within a jurisdiction.

This includes employer registration with tax and regulatory authorities.

---

## 1.1 Jurisdiction Registration Attributes

| Field Name | Description |
|-------------|-------------|
| Jurisdiction_Registration_ID | Unique identifier |
| Legal_Entity_ID | Parent Legal Entity reference |
| Jurisdiction_ID | Associated jurisdiction |
| Registration_Number | Employer registration identifier |
| Authority_Name | Issuing authority |
| Registration_Type | Payroll, Tax, Labor, etc. |
| Effective_Start_Date | Registration start |
| Effective_End_Date | Registration end |
| Status | Active / Suspended / Closed |
| Local_Representative_Required | Boolean indicator |
| Local_Representative_Reference | Optional reference |
| Notes | Administrative notes |

---

## 1.2 Registration Scope

Jurisdiction Registration supports:

- multi-state operations
- multi-province operations
- foreign employer registrations
- special authority enrollment

---

# 2. Jurisdiction Profile Model

A **Jurisdiction Profile** defines the operational compliance context associated with a Jurisdiction Registration.

It determines which rules apply and how they are executed.

---

## 2.1 Jurisdiction Profile Attributes

| Field Name | Description |
|-------------|-------------|
| Jurisdiction_Profile_ID | Unique identifier |
| Jurisdiction_Registration_ID | Parent registration reference |
| Country_Code | Country of operation |
| Currency_Code | Default currency |
| Primary_Tax_Authority | Main authority |
| Reporting_Calendar_ID | Reporting schedule reference |
| Default_Rule_Set_ID | Linked rule set |
| Effective_Start_Date | Profile start |
| Effective_End_Date | Profile end |
| Status | Active / Archived |

---

## 2.2 Profile Responsibilities

Jurisdiction Profile defines:

- applicable statutory rules
- remittance structures
- reporting schedules
- currency handling
- filing cadence

---

# 3. Registered Jurisdiction Components

Each Jurisdiction Registration may include:

```text
Jurisdiction Registration
├── Tax Authority
├── Social Insurance Authority
├── Labor Authority
├── Local Authority (optional)
```

These authorities may operate independently.

---

# 4. Effective Dating Model

Both Registration and Profile structures support:

- effective start dates
- effective end dates
- version replacement
- historical preservation

This ensures:

- audit reconstruction
- rule replay capability
- legislative transition support

---

# 5. Relationship to Legal Entity

```text
Legal Entity
    ├── Jurisdiction Registration (1..n)
            ├── Jurisdiction Profile (1..n, effective-dated)
```

Constraints:

- A Legal Entity may have multiple Jurisdiction Registrations.
- Each Registration must reference one Legal Entity.
- Each Registration must resolve to exactly one active Profile at a time.

---

# 6. Multi-Country Support Model

Supports:

- multi-state US employers
- multi-country regional employers
- foreign employer registrations
- PEO-managed multi-entity structures

Example:

```text
Legal Entity: Global Services Ltd

Registrations:
├── United States (IRS, CA EDD, NY DOL)
├── Canada (CRA Registration)
├── United Kingdom (HMRC PAYE)
```

Each produces its own Jurisdiction Profile.

---

# 7. Rule Resolution Binding

Jurisdiction Profile connects to Rule Resolution through:

| Field | Purpose |
|------|---------|
| Default_Rule_Set_ID | Primary rule reference |
| Override_Rule_Set_ID | Optional override |
| Rule_Version_ID | Version tracking |
| Activation_Date | Rule activation |

---

# 8. Audit and Traceability Requirements

The system must retain:

- full registration history
- profile history
- rule version history
- authority linkage history

This supports:

- statutory audit validation
- dispute resolution
- historical payroll recalculation

---

# 9. Future Expansion

Potential enhancements include:

- treaty relationship modeling
- cross-border employment flags
- jurisdiction dependency mapping
- automated compliance validation

---

# 10. Summary

This model establishes the operational structure required for jurisdiction-aware payroll and compliance.

Key truths:

- Legal Entity establishes statutory identity.
- Jurisdiction Registration establishes operational presence.
- Jurisdiction Profile establishes rule context.
- Rule Resolution executes statutory logic.
