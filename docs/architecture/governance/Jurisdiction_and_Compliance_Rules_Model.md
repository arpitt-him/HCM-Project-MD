# Jurisdiction_and_Compliance_Rules_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.3 |
| **Status** | Draft (Revision from v0.2) |
| **Owner** | Compliance Domain |
| **Location** | docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md |
| **Domain** | Governance |
| **Related Documents** | Platform_Composition_and_Extensibility_Model.md, Tax_Classification_and_Obligation_Model, Rule_Resolution_Engine, Organizational_Structure_Model, Garnishment_and_Legal_Order_Model, Regulatory_and_Compliance_Reporting_Model, Multi_Context_Calendar_Model |

---

## Purpose

Enhances jurisdiction support to allow multi-country operation, non-geographic authorities, and hierarchical flexibility. Defines how jurisdiction-level rules are structured, resolved, and applied to payroll calculation and compliance reporting.

This revision strengthens alignment with platform-level architectural principles, including:

- Employer-of-Record Legal Entity as primary statutory anchor
- Client Company as a first-class organizational grouping
- Jurisdiction Profiles as rule-resolution containers
- Support for multi-entity and PEO-style operating models

---

## 1. Employer-of-Record Legal Entity

The Employer-of-Record Legal Entity is the primary statutory nexus anchor.

Governments typically determine taxation authority by identifying:

"Who is the company of record, and do we have taxing authority over that company?"

Accordingly:

- Every Employment record must reference exactly one Legal Entity.
- Each Legal Entity represents a statutory compliance boundary.
- Jurisdiction resolution originates from the Legal Entity.

Legal Entity defines:

- taxation responsibility
- remittance responsibility
- regulatory reporting accountability
- employer compliance obligations

Jurisdiction determination shall not originate from tenant or client-level configuration.

---

## 2. Enhanced Jurisdiction Entity

Jurisdiction attributes include:

Jurisdiction_ID, Jurisdiction_Name, Jurisdiction_Type, Parent_Jurisdiction_ID, Country_Code, Jurisdiction_Level_Number, Is_Geographic_Flag, Effective_Start_Date, Effective_End_Date, Status.

Jurisdictions may represent:

- geographic authorities
- regulatory authorities
- special-purpose governing bodies

---

## 3. Jurisdiction Level Number

Level numbering supports deterministic rule resolution.

Examples:

Level 1 → Country  
Level 2 → Province/State  
Level 3 → District  
Level 4 → Municipality  

Levels shall be configurable by country.

Lower-level jurisdictions may override higher-level rules where legally required.

---

## 4. Non-Geographic Jurisdiction Support

Some jurisdictions are authority-based rather than geographic.

Examples:

- Church Tax Region  
- School District Authority  
- Transit Authority  
- Tax Collection Agency  

These are supported using:

Is_Geographic_Flag = False

Non-geographic jurisdictions may coexist with geographic jurisdictions.

---

## 5. Jurisdiction Grouping

Jurisdiction_Group includes:

Group_ID  
Group_Name  
Group_Type  
Member_Jurisdiction_List  

Examples:

- EU Region  
- Multi-State Tax Agreement  
- Regional Labor Zone  

Grouping supports:

- rule inheritance
- conditional rule activation
- cross-region regulatory alignment

---

## 6. Jurisdiction Profile Model

Jurisdiction Profiles provide a structured container for rule resolution.

A Jurisdiction Profile represents the operational statutory environment associated with a Legal Entity.

Jurisdiction Profiles define:

- applicable statutory rules
- regulatory authorities
- remittance targets
- reporting requirements
- statutory calendars
- currency handling

Each Legal Entity shall be associated with:

- one active Jurisdiction Profile at any given time
- historical profiles retained for audit and replay

Jurisdiction Profiles support:

- legislative change tracking
- historical recalculation
- compliance traceability

---

## 7. Rule Resolution Enhancements

Rule application uses:

- jurisdiction hierarchy
- jurisdiction level ordering
- group membership inheritance

Resolution priority:

Higher level → inherited  
Lower level → override  
Group → conditional application  

Resolution shall be:

- deterministic
- auditable
- reproducible

---

## 8. Supported Jurisdiction Levels (US)

Supported levels include:

- Federal  
- State  
- County  
- City  
- School District  
- Special District  
- Tribal Authority  

Jurisdictions are hierarchical in structure but operate independently for calculation purposes.

---

## 9. Multi-Jurisdiction Handling

A single employee may be subject to multiple simultaneous jurisdictions.

Jurisdiction applicability is determined by:

- work location
- residency
- statutory rules

Resolution shall remain:

- deterministic
- traceable
- reproducible

Multiple jurisdiction contexts may execute concurrently.

---

## 10. Client Company Alignment

Client Company functions as an administrative and reporting boundary above Legal Entities.

Client Company:

- groups related Legal Entities
- supports reporting aggregation
- enables payroll segmentation
- supports governance delegation

Client Company does not define jurisdiction.

Jurisdiction always resolves from:

Legal Entity → Jurisdiction Profile

---

## 11. Future Expansion

Initial scope supports US-first implementation.

The jurisdiction model is designed for extensibility to support:

- Caribbean jurisdictions
- multi-country regional deployments
- non-US tax structures
- specialized regulatory authorities

---

## 12. Relationship to Other Models

This model integrates with:

- Tax_Classification_and_Obligation_Model
- Rule_Resolution_Engine
- Organizational_Structure_Model
- Garnishment_and_Legal_Order_Model
- Regulatory_and_Compliance_Reporting_Model
- Multi_Context_Calendar_Model
- Platform_Composition_and_Extensibility_Model
