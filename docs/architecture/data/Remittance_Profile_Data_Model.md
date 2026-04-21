# Remittance_Profile_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Remittance & Compliance Domain |
| **Location** | docs/architecture/data/Remittance_Profile_Data_Model.md |
| **Domain** | Remittance Profile / Obligation Delivery / Payment & Filing Context |
| **Related Documents** | Payroll_Context_Data_Model.md, Funding_Profile_Data_Model.md, Legal_Entity_Data_Model.md, Jurisdiction_Registration_and_Profile_Data_Model.md, Regulatory_and_Compliance_Reporting_Model.md, Payroll_Run_Model.md, Net_Pay_and_Disbursement_Model.md |

---

# Purpose

This document defines the core data structure for **Remittance Profile** as the governed configuration used to determine how payroll-related obligations are delivered to authorities, providers, garnishment recipients, and other external parties.

Remittance Profile is not Funding Profile.

Remittance Profile is not Payroll Context.

Remittance Profile is not the actual remittance transaction.

Remittance Profile is the governed delivery configuration that defines:

- which obligations are remitted
- to whom they are remitted
- by what method they are remitted
- on what cadence they are remitted
- which filing and payment rules apply
- which delivery instructions govern the obligation

This model exists to support:

- tax remittances
- social insurance remittances
- benefit remittances
- garnishment remittances
- provider payments
- authority-specific payment methods
- filing-linked remittance behavior
- multi-jurisdiction remittance handling

without embedding payment-recipient detail directly into payroll logic or payroll-run records.

---

# Core Structural Role

```text
Legal Entity / Jurisdiction Registration / Payroll Context
    ↓
Remittance Profile
    ↓
Remittance Recipient / Method / Schedule / Filing Context / Payroll Run Output
```

Remittance Profile is the configuration layer between payroll obligation calculation and obligation delivery.

---

# 1. Remittance Profile Definition

A **Remittance Profile** represents a governed configuration describing how payroll obligations are delivered to external recipients for a defined payroll context or compliance scenario.

A Remittance Profile may represent:

- a standard tax remittance arrangement
- a social insurance remittance arrangement
- a benefit-provider payment arrangement
- a garnishment remittance arrangement
- an authority-specific filing/payment configuration
- a special off-cycle remittance handling pattern
- a client-specific remittance arrangement in a PEO model

Remittance Profile shall be modeled as distinct from:

- Funding Profile
- Payroll Context
- Jurisdiction Registration
- Remittance transaction
- Disbursement instruction
- Regulatory report

Remittance Profile is the governed delivery configuration, not the actual payment event.

---

# 2. Remittance Profile Primary Attributes

| Field Name | Description |
|---|---|
| Remittance_Profile_ID | Unique identifier |
| Remittance_Profile_Code | Business/system code |
| Remittance_Profile_Name | Human-readable name |
| Remittance_Profile_Type | Tax, Social_Insurance, Benefit, Garnishment, Provider, Mixed, Other |
| Legal_Entity_ID | Governing Legal Entity reference |
| Client_Company_ID | Parent Client Company reference where relevant |
| Tenant_ID | Parent Tenant reference where relevant |
| Primary_Jurisdiction_Registration_ID | Primary jurisdiction registration reference where relevant |
| Primary_Jurisdiction_Profile_ID | Primary jurisdiction profile reference where relevant |
| Remittance_Profile_Status | Pending, Active, Suspended, Inactive, Closed |
| Effective_Start_Date | Date profile becomes effective |
| Effective_End_Date | Date profile ceases use |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Remittance Profile Functional Attributes

| Field Name | Description |
|---|---|
| Remittance_Method | ACH, Wire, Check, Portal, API, File_Transmission, Other |
| Filing_Linked_Flag | Indicates remittance is linked to filing/reporting cycle |
| Remittance_Frequency_Code | Per_Run, Weekly, Biweekly, Monthly, Quarterly, Annual, Ad_Hoc |
| Due_Date_Rule_Type | Fixed_Date, Relative_To_Pay_Date, Relative_To_Period_End, Filing_Driven, Other |
| Delivery_Channel_Profile_ID | External channel or endpoint profile |
| Payment_Instruction_Profile_ID | Payment instruction/profile reference |
| Currency_Code | Default remittance currency |
| Consolidation_Allowed_Flag | Indicates multiple obligations may be consolidated |
| Separate_By_Obligation_Type_Flag | Indicates obligations must remain separated |
| Off_Cycle_Allowed_Flag | Indicates off-cycle remittance behavior supported |
| Approval_Required_Flag | Indicates approval required before release |
| Notes | Administrative notes |

---

# 4. Remittance Recipients

A Remittance Profile may reference one or more recipients.

Typical structure:

```text
Remittance Profile
    └── Remittance Recipient (1..n)
```

Recipients may include:

- tax authority
- social insurance authority
- benefit carrier
- garnishment agency
- court or legal recipient
- third-party administrator
- payroll provider settlement destination

Recipients shall be governed separately from the profile itself, but the profile defines how they are used operationally.

---

# 5. Relationship to Payroll Context

```text
Payroll Context
    └── Remittance Profile (0..1 default, overrideable by policy)
```

A Payroll Context may reference one default Remittance Profile.

A Remittance Profile may serve one or more Payroll Contexts where governance permits.

This relationship answers:

- how obligations from this payroll grouping are delivered
- whether filings and remittances are linked
- which remittance timing rules apply
- whether separate or consolidated delivery is used

Payroll Context defines the payroll execution frame.

Remittance Profile defines how resulting obligations are delivered outward.

---

# 6. Relationship to Legal Entity and Client Company

Remittance Profile is anchored beneath Legal Entity and may be segmented by Client Company where relevant.

### 6.1 Legal Entity Relationship

Each Remittance Profile must reference one governing Legal Entity.

This preserves:

- statutory accountability
- authority alignment
- reporting identity consistency
- audit traceability

### 6.2 Client Company Relationship

In PEO or segmented business models, Remittance Profile may also reference Client Company.

This supports:

- client-specific remittance instructions
- trust-account segregation patterns
- client-level provider arrangements
- delegated approval paths

Client Company may refine operational ownership, but Legal Entity remains the core compliance anchor.

---

# 7. Relationship to Jurisdiction Registration and Profile

Remittance Profile may reference jurisdictional structures directly where remittance obligations are authority-specific.

Typical path:

```text
Legal Entity
    → Jurisdiction Registration
        → Jurisdiction Profile
            → Remittance Profile
```

This is especially important where:

- one Legal Entity has multiple registrations
- remittance schedules differ by state, province, or country
- one payroll context covers multiple authority obligations
- foreign-employer registrations create distinct remittance duties

Remittance Profile consumes statutory context rather than replacing it.

---

# 8. Relationship to Funding Profile

Funding Profile and Remittance Profile are complementary but distinct.

- **Funding Profile** answers: how obligations are financially sourced
- **Remittance Profile** answers: how obligations are delivered to recipients

A Payroll Context may reference both:

```text
Payroll Context
    ├── Funding Profile
    └── Remittance Profile
```

These models must align operationally, but neither should absorb the responsibilities of the other.

---

# 9. Relationship to Payroll Run

A Payroll Run may use the Remittance Profile assigned through Payroll Context or a governed override.

Typical path:

```text
Payroll Context
    └── Remittance Profile
            └── Payroll Run Remittance Use
```

Payroll Run captures the actual remittance outputs generated in a specific execution event.

Remittance Profile captures the governing delivery rules behind those outputs.

Any run-level override must be explicit, approved where required, and auditable.

---

# 10. Remittance Segmentation Model

A Remittance Profile may define how obligations are segmented for delivery.

Examples:

- combined payment to one authority
- separate payments by tax type
- separate payments by employee/employer share
- separate remittances by jurisdiction
- separate remittances by provider
- consolidated benefit payments with detail file support

The profile defines whether obligations may be:

- consolidated
- split
- grouped by recipient
- grouped by filing
- grouped by legal entity
- grouped by pay period

Segmentation behavior must remain explicit and queryable.

---

# 11. Filing and Reporting Linkage

Some remittances are tightly linked to filing obligations.

Examples:

- payroll tax filing with payment due upon filing
- social insurance reporting with remittance batch
- quarterly tax returns
- year-end authority remittance obligations

Remittance Profile may therefore define:

- filing-linked behavior
- filing dependency rules
- release sequencing
- hold-until-filing logic

This supports coordination between remittance and regulatory reporting processes.

---

# 12. Remittance Profile Status Model

Suggested Remittance_Profile_Status values:

| Status | Meaning |
|---|---|
| Pending | Defined but not yet available for operational use |
| Active | Available for remittance use |
| Suspended | Temporarily restricted from use |
| Inactive | Retained historically but not in current use |
| Closed | Permanently retired and retained for history |

Status transitions shall be governed and auditable.

Closed or Inactive Remittance Profiles may not be assigned to new active Payroll Contexts or Payroll Runs without formal reactivation or approved override.

---

# 13. Effective Dating and Historical Preservation

Remittance Profile shall support effective-dated lifecycle management.

Changes that may require historical preservation include:

- recipient changes
- remittance method changes
- payment instruction changes
- filing-linked logic changes
- due-date rule changes
- jurisdiction registration changes
- segmentation changes
- approval requirement changes

Historical values must be preserved.

Silent overwrite is not permitted where changes affect compliance, remittance auditability, reporting, or dispute handling.

---

# 14. Validation Rules

Examples of validation rules:

- Remittance_Profile_Name is required
- Legal_Entity_ID is required
- Effective_Start_Date is required
- Effective_End_Date may not precede Effective_Start_Date
- Remittance_Method is required
- Currency_Code must be valid where payment is generated
- Filing-linked profiles must reference valid filing logic where required
- Suspended or Closed profiles may not be newly assigned to active Payroll Contexts
- Separate_By_Obligation_Type_Flag and Consolidation_Allowed_Flag must not conflict without governed exception handling

These validations may be enforced through payroll configuration governance and compliance control workflows.

---

# 15. Audit and Traceability Requirements

The system shall preserve:

- remittance profile creation history
- status transition history
- legal entity linkage history
- jurisdiction linkage history
- recipient assignment history
- method and channel history
- due-date rule history
- run-level override history

This supports:

- remittance audit
- regulatory review
- payment dispute handling
- authority inquiry response
- processing lineage reconstruction

---

# 16. Relationship to Other Models

This model integrates with:

- Payroll_Context_Data_Model
- Funding_Profile_Data_Model
- Legal_Entity_Data_Model
- Jurisdiction_Registration_and_Profile_Data_Model
- Regulatory_and_Compliance_Reporting_Model
- Payroll_Run_Model
- Net_Pay_and_Disbursement_Model

---

# 17. Summary

This model establishes Remittance Profile as the governed delivery configuration for payroll-related obligations.

Key principles:

- Remittance Profile is distinct from Funding Profile, Payroll Context, and Payroll Run
- Remittance Profile defines how obligations are delivered to external recipients
- Remittance Profile attaches beneath Legal Entity and may be segmented by Client Company and jurisdiction
- Remittance Profile may define filing-linked behavior, recipient segmentation, and due-date rules
- Historical integrity and effective dating are mandatory
