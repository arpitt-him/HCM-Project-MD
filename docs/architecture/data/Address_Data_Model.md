# Address_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Shared Reference & Identity Domain |
| **Location** | docs/architecture/data/Address_Data_Model.md |
| **Domain** | Address / Location Reference / Postal Identity |
| **Related Documents** | Person_Data_Model.md, Employment_Data_Model.md, Legal_Entity_Data_Model.md, Client_Company_Data_Model.md, Tenant_Data_Model.md, Organizational_Structure_Model.md, Jurisdiction_Registration_and_Profile_Data_Model.md |

---

# Purpose

This document defines the core data structure for **Address** as a reusable, governed postal and location reference object within the platform.

Address exists to support:

- person residential and mailing addresses
- employment-related work addresses
- legal entity registered and operational addresses
- client company business addresses
- tenant-level commercial or administrative addresses
- jurisdictional and payroll-relevant location references
- correspondence and document delivery

This model ensures address data is handled as a shared governed structure rather than duplicated field sets embedded inconsistently across other models.

---

# Core Structural Role

```text
Tenant / Client Company / Legal Entity / Person / Employment / Org Unit
    ↓
Address
    ↓
Jurisdiction / Postal Validation / Effective Dating / Audit
```

Address may be referenced by multiple owning or related objects.

Address is not itself the governing business object; it is the reusable location/identity structure attached to those objects.

---

# 1. Address Definition

An **Address** represents a structured postal or physical location reference used by the platform.

An Address may represent:

- residential location
- mailing location
- registered business address
- operational business address
- work location
- remittance/correspondence address
- service-of-process address
- tax registration address

Address shall be modeled as distinct from:

- Person
- Employment
- Legal Entity
- Client Company
- Tenant
- Org Unit
- Jurisdiction
- Work Location schedule context

Address is a reusable location record, not the owning business object.

---

# 2. Address Primary Attributes

| Field Name | Description |
|---|---|
| Address_ID | Unique identifier |
| Address_Type | Residential, Mailing, Registered, Operational, Work, Billing, Other |
| Address_Line_1 | Primary street or delivery line |
| Address_Line_2 | Secondary line |
| Address_Line_3 | Optional tertiary line |
| City_or_Locality | City, town, or locality |
| County_or_Region | County, parish, region, or equivalent |
| State_Province_Code | State/province/administrative area code |
| Postal_Code | Postal or ZIP code |
| Country_Code | ISO-style country code |
| Address_Status | Active, Inactive, Invalid, Historical, Restricted |
| Effective_Start_Date | Date address becomes effective |
| Effective_End_Date | Date address ceases to be effective |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Address Functional Attributes

| Field Name | Description |
|---|---|
| Address_Label | Optional display label, e.g. Home, Headquarters, Mailing |
| Address_Usage_Primary_Flag | Indicates primary use within an owner context |
| Validated_Flag | Indicates postal or location validation completed |
| Validation_Source | USPS, Royal Mail, manual, external service, etc. |
| Latitude | Optional geo-coordinate |
| Longitude | Optional geo-coordinate |
| Time_Zone_Code | Optional time zone derived or assigned |
| Delivery_Instruction_Text | Optional delivery/correspondence notes |
| Confidentiality_Level | Standard, Confidential, Restricted |
| Notes | Administrative notes |

---

# 4. Address Ownership and Reference Model

Address is a reusable referenced structure.

Typical ownership/reference patterns include:

```text
Person
    └── Address (1..n)

Employment
    └── Address (0..n)

Legal Entity
    └── Address (1..n)

Client Company
    └── Address (0..n)

Tenant
    └── Address (0..n)

Org Unit / Location
    └── Address (0..n)
```

An Address may be:

- directly attached to one owner
- reused by multiple related records where governance permits
- versioned historically through effective dating or replacement

Where address sharing is allowed, the system must preserve clarity about which object treats that address as primary.

---

# 5. Relationship to Person

Person may reference one or more addresses.

Typical person-linked address uses include:

- home address
- mailing address
- emergency correspondence address
- former address for historical continuity

Person-linked addresses may change over time and shall preserve historical continuity where legally or operationally required.

A Person may designate one primary residential address and one primary mailing address where policy requires.

---

# 6. Relationship to Employment

Employment may reference one or more addresses where the employment relationship requires address context independent from Person.

Examples:

- designated work location address
- payroll mailing address override
- employment-specific correspondence address
- remote-work location for compliance handling

Employment-linked addresses do not replace the Person’s durable residential identity record unless explicitly modeled as a shared address reference.

---

# 7. Relationship to Legal Entity

Legal Entity may reference one or more addresses.

Examples:

- registered office
- principal place of business
- tax registration address
- remittance correspondence address
- service-of-process address

A Legal Entity may require multiple address roles simultaneously.

Address role clarity shall be explicit and queryable.

---

# 8. Relationship to Client Company and Tenant

Client Company and Tenant may also reference addresses for:

- commercial correspondence
- billing correspondence
- headquarters or administrative office
- service contract notices
- tenant operational administration

These addresses do not define statutory employer identity, but they are operationally significant and must remain governed.

---

# 9. Relationship to Org Structure and Work Location

Addresses may support Organizational Structure or work-location modeling.

Examples:

- office location
- branch office
- warehouse
- field service center
- worksite

Where Org Units are location-bearing, they may reference Address as a reusable structure rather than embedding address lines directly.

Address does not replace richer location models where scheduling, capacity, or workplace semantics are required.

---

# 10. Relationship to Jurisdiction and Compliance

Address contributes to jurisdiction and compliance resolution, but it is not itself the statutory anchor.

Address may supply:

- country
- state/province
- locality
- postal code
- region

These values may refine:

- tax applicability
- local labor law handling
- payroll locality rules
- filing authority determination
- service area logic

However, jurisdiction resolution must still respect the broader model:

```text
Employment
    → Legal Entity
        → Jurisdiction Registration
            → Jurisdiction Profile
```

Address may refine context, but it shall not replace Employer-of-Record Legal Entity as the primary statutory anchor.

---

# 11. Address Status Model

Suggested Address_Status values:

| Status | Meaning |
|---|---|
| Active | Current valid address |
| Inactive | Not currently used operationally |
| Invalid | Known invalid or undeliverable |
| Historical | Retained for prior-state history |
| Restricted | Address exists but access is tightly limited |

Status transitions shall be governed and auditable.

Historical addresses shall remain queryable where required for tax, payroll, correspondence, or audit purposes.

---

# 12. Effective Dating and Historical Preservation

Address shall support effective-dated lifecycle management.

Changes that may require historical preservation include:

- residence changes
- mailing changes
- legal entity registered office changes
- worksite changes
- remittance address changes
- jurisdiction-relevant locality changes

Historical address values must be preserved.

Silent overwrite is not permitted where address changes affect compliance, payroll, taxation, reporting, or legally relevant correspondence.

---

# 13. Validation and Standardization

Address validation may include:

- required field checks
- country-specific format checks
- postal code validation
- normalization/standardization
- geocoding
- locality code derivation
- deliverability validation

Validation standards may vary by country and jurisdiction.

The platform shall support:

- manual entry with validation warnings
- imported address normalization
- validated and non-validated address states
- country-specific parsing and formatting

---

# 14. Privacy and Confidentiality Considerations

Some addresses are highly sensitive.

Examples:

- protected employee home addresses
- domestic violence shelter addresses
- executive restricted addresses
- legal service addresses

The platform shall support:

- access restriction by role and purpose
- masking where appropriate
- restricted confidentiality levels
- protected-address workflows
- audit logging of access

Address confidentiality must be governed separately from generic owner visibility where required.

---

# 15. Validation Rules

Examples of validation rules:

- Country_Code is required
- Address_Line_1 is required unless country rules permit alternative structure
- City_or_Locality is required where jurisdiction rules require it
- Effective_End_Date may not precede Effective_Start_Date
- Only one primary address of a given type may exist per owner context where policy requires
- Restricted addresses may not be exposed outside approved scopes
- Invalid addresses may not be used for official correspondence without override authorization

These validations may be enforced through validation frameworks, workflow approvals, and external address-standardization services.

---

# 16. Audit and Traceability Requirements

The system shall preserve:

- address creation history
- address change history
- owner linkage history
- validation history
- standardization history
- status transition history
- confidentiality classification history

This supports:

- audit reconstruction
- jurisdiction review
- payroll and tax traceability
- correspondence dispute handling
- privacy compliance

---

# 17. Relationship to Other Models

This model integrates with:

- Person_Data_Model
- Employment_Data_Model
- Legal_Entity_Data_Model
- Client_Company_Data_Model
- Tenant_Data_Model
- Organizational_Structure_Model
- Jurisdiction_Registration_and_Profile_Data_Model

---

# 18. Summary

This model establishes Address as a governed shared reference structure.

Key principles:

- Address is reusable across multiple owner types
- Address is distinct from Person, Employment, Legal Entity, and Location semantics
- Address supports effective dating and historical preservation
- Address may refine jurisdiction context but does not replace Legal Entity as statutory anchor
- Address validation and standardization must be country-aware
- Sensitive addresses require strong access control and auditability
