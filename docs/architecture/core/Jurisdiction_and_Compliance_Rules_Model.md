# Jurisdiction and Compliance Rules Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Architecture Team |
| **Domain** | Governance and Compliance Architecture |
| **Proposed Location** | docs/architecture/governance/Jurisdiction_and_Compliance_Rules_Model.md |
| **Related Documents** | Platform_Composition_and_Extensibility_Model.md, Organizational_Structure_Model.md, Employment_and_Person_Identity_Model.md, Payroll_Module_PRD.md |

---

# 1. Purpose

This document defines how jurisdictional responsibility and statutory compliance rules are determined within the platform.

The model establishes:

- Legal Entity as the primary statutory nexus anchor
- Jurisdiction Profile as the rule-resolution context
- A layered jurisdiction resolution sequence
- Support for multi-country and multi-entity operations
- Rule-pack extensibility for jurisdictional variation

The goal is to ensure statutory accuracy while maintaining architectural flexibility.

---

# 2. Jurisdiction Resolution Overview

Jurisdictional responsibility originates from statutory nexus.

Nexus is determined primarily by:

- Employer-of-Record Legal Entity
- Work Location
- Employee Residence
- Additional statutory factors

Jurisdiction resolution determines:

- tax withholding rules
- employer contributions
- reporting obligations
- statutory leave requirements
- remittance targets

---

# 3. Legal Entity as Primary Nexus Anchor

Legal Entity is the primary statutory reference point.

Every Employment record must reference exactly one Legal Entity.

Legal Entity establishes:

- employer-of-record identity
- regulatory responsibility
- taxation authority relationships
- statutory reporting obligations

---

## 3.1 Legal Entity Core Attributes

Typical attributes include:

- Legal_Entity_ID
- Registered_Name
- Country_Code
- Tax_Registration_Number
- Employer_Registration_Number
- Registration_Effective_Date
- Registration_Status

---

# 4. Jurisdiction Profile Model

Jurisdiction Profile represents the operational rule environment attached to a Legal Entity.

Jurisdiction Profile defines:

- applicable statutory rules
- regulatory authorities
- remittance destinations
- reporting obligations

---

## 4.1 Jurisdiction Profile Structure

Typical attributes include:

- Jurisdiction_Profile_ID
- Country_Code
- Primary_Tax_Authority
- Social_Insurance_Authority
- Leave_Regulatory_Authority
- Currency_Code
- Default_Reporting_Calendar
- Effective_Date
- Expiration_Date

---

## 4.2 Jurisdiction Profile Assignment

Each Legal Entity shall be associated with:

- exactly one active Jurisdiction Profile at any given time

Historical profiles must be preserved.

This supports:

- statutory auditing
- historical recalculation
- compliance traceability

---

# 5. Jurisdiction Resolution Sequence

Jurisdiction resolution shall follow a layered decision model.

---

## 5.1 Primary Resolution Step

Resolve jurisdiction from:

Legal Entity → Jurisdiction Profile

---

## 5.2 Secondary Resolution Step

Refine jurisdiction using:

Work Location

Work location may introduce:

- municipal rules
- locality taxes
- regional employment rules

---

## 5.3 Tertiary Resolution Step

Refine jurisdiction using:

Employee Residence

This may introduce:

- resident taxation rules
- reciprocal agreements
- withholding adjustments

---

## 5.4 Additional Nexus Factors

Where required, jurisdiction may consider:

- remote work designation
- assignment location
- benefit jurisdiction
- special regulatory programs

---

# 6. Rule Pack Model

Rule Packs represent executable logic associated with jurisdictional behavior.

Rule Packs may include:

- income tax logic
- employer tax logic
- statutory deduction logic
- leave accrual logic
- compliance reporting logic

---

## 6.1 Rule Pack Assignment

Rule Packs shall be assigned to:

Jurisdiction Profile

Not directly to:

Tenant  
Client Company  
Employee  

This preserves legal accuracy.

---

## 6.2 Rule Pack Versioning

Rule Packs shall support:

- effective dating
- scheduled activation
- historical retention

This supports:

- legislative change tracking
- retroactive recalculation
- audit replay capability

---

# 7. Multi-Jurisdiction Processing

The platform must support concurrent multi-jurisdiction processing.

This includes:

- multiple Legal Entities
- multiple Jurisdiction Profiles
- mixed-country payroll operations

within a single deployment.

---

## 7.1 Concurrent Rule Execution

Multiple jurisdiction rule sets may execute during:

- a single payroll cycle
- a single reporting window
- a single compliance period

Each rule set operates independently.

---

# 8. Jurisdiction and Payroll Relationship

Payroll processing consumes jurisdictional context.

Payroll engines do not determine jurisdiction.

They execute using resolved jurisdiction inputs.

---

## 8.1 Payroll Context Inputs

Payroll processing shall receive:

- Legal_Entity_ID
- Jurisdiction_Profile_ID
- Work_Location_ID
- Employee_Residence_ID

These values define payroll execution context.

---

# 9. Cross-Border Employment Considerations

Certain employment scenarios require multi-layer jurisdiction handling.

Examples:

- remote employees
- cross-border commuters
- temporary foreign assignments
- regional work assignments

These scenarios must be supported without altering core architecture.

---

# 10. Jurisdiction Data Governance

Jurisdictional configuration is highly sensitive.

Changes must be controlled.

---

## 10.1 Governance Requirements

Jurisdiction Profile changes shall require:

- approval workflows
- effective dating
- audit logging

---

## 10.2 Audit Requirements

The platform shall preserve:

- historical jurisdiction states
- applied rule versions
- remittance mappings

This supports regulatory audits.

---

# 11. Acceptance Criteria

| Requirement | Acceptance |
|---|---|
| Legal Entity nexus defined | Legal Entity identified as statutory anchor |
| Jurisdiction Profile defined | Profile structure documented |
| Rule Pack linkage defined | Rule packs assigned to jurisdiction |
| Multi-jurisdiction capability defined | Concurrent operations supported |
| Governance defined | Change control requirements documented |

---

# 12. Summary

This model establishes jurisdiction resolution as a structured, repeatable process.

Key architectural truths:

- Legal Entity is the primary nexus anchor.
- Jurisdiction Profile defines operational compliance context.
- Rule Packs provide executable statutory logic.
- Payroll consumes jurisdictional decisions.
- Multi-country operations are supported concurrently.
- Historical rule integrity is preserved.
