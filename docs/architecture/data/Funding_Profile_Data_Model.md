# Funding_Profile_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Funding & Cash Management Domain |
| **Location** | docs/architecture/data/Funding_Profile_Data_Model.md |
| **Domain** | Funding Profile / Payroll Funding / Cash Management Context |
| **Related Documents** | Payroll_Context_Data_Model.md, Legal_Entity_Data_Model.md, Payroll_Funding_and_Cash_Management_Model.md, Net_Pay_and_Disbursement_Model.md, Remittance_Profile_Data_Model.md, Payroll_Run_Model.md |

---

# Purpose

This document defines the core data structure for **Funding Profile** as the governed payroll funding configuration used to determine how payroll obligations are financially sourced and prepared for disbursement.

Funding Profile is not Payroll Context.

Funding Profile is not a bank account.

Funding Profile is not the disbursement instruction itself.

Funding Profile is the governed funding configuration that defines:

- where payroll funding is sourced from
- how funding is segmented
- which funding rules apply
- which obligations are covered by which funding arrangements
- how payroll funding behavior is controlled for a payroll population or run context

This model exists to support:

- standard payroll funding
- multiple funding sources
- entity-specific funding structures
- client-segmented funding in PEO models
- special funding rules for off-cycle payroll
- controlled funding overrides
- auditability of funding configuration over time

without embedding cash-management detail directly into payroll logic or run records.

---

# Core Structural Role

```text
Legal Entity / Client Company / Payroll Context
    ↓
Funding Profile
    ↓
Funding Source / Funding Rules / Payroll Run Funding Behavior
```

Funding Profile is the configuration layer between payroll execution context and actual funding execution.

---

# 1. Funding Profile Definition

A **Funding Profile** represents a governed configuration describing how payroll and payroll-related obligations are funded for a defined payroll context or operational scenario.

A Funding Profile may represent:

- a standard payroll funding arrangement
- a legal-entity-specific funding configuration
- a client-specific funding arrangement in a PEO model
- a separate off-cycle funding arrangement
- a split funding arrangement across multiple sources
- a net-pay-only funding pattern
- a full-obligation funding pattern covering taxes and remittances

Funding Profile shall be modeled as distinct from:

- Payroll Context
- Legal Entity
- Bank Account
- Payroll Run
- Remittance Profile
- Net Pay Disbursement Instruction

Funding Profile is the governed funding configuration, not the funding transaction itself.

---

# 2. Funding Profile Primary Attributes

| Field Name | Description |
|---|---|
| Funding_Profile_ID | Unique identifier |
| Funding_Profile_Code | Business/system code |
| Funding_Profile_Name | Human-readable name |
| Funding_Profile_Type | Standard, Split, Off_Cycle, Entity_Specific, Client_Specific, Other |
| Legal_Entity_ID | Governing Legal Entity reference |
| Client_Company_ID | Parent Client Company reference where relevant |
| Tenant_ID | Parent Tenant reference where relevant |
| Funding_Profile_Status | Pending, Active, Suspended, Inactive, Closed |
| Effective_Start_Date | Date profile becomes effective |
| Effective_End_Date | Date profile ceases use |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Funding Profile Functional Attributes

| Field Name | Description |
|---|---|
| Default_Currency_Code | Default funding currency |
| Funding_Mode | Prefund, Same_Day, Drawdown, Mixed, Other |
| Funding_Segmentation_Type | Combined, NetPay_vs_Remittance, By_Pay_Group, By_Entity, Other |
| Net_Pay_Covered_Flag | Indicates net pay funding covered |
| Tax_Remittance_Covered_Flag | Indicates employer/employee tax remittance covered |
| Benefit_Remittance_Covered_Flag | Indicates benefit remittance funding covered |
| Garnishment_Remittance_Covered_Flag | Indicates garnishment funding covered |
| Off_Cycle_Allowed_Flag | Indicates off-cycle use permitted |
| Shortfall_Handling_Type | Reject, Hold, Partial, Escalate, Other |
| Funding_Approval_Required_Flag | Indicates approval required before funding execution |
| Notes | Administrative notes |

---

# 4. Funding Sources

A Funding Profile may reference one or more funding sources.

Typical structure:

```text
Funding Profile
    └── Funding Source (1..n)
```

Funding sources may include:

- designated payroll bank account
- clearing account
- client trust account
- employer operating account
- reserve or settlement account
- provider-managed drawdown arrangement

Funding sources shall be governed separately from the Funding Profile itself, but the profile must define how those sources are used.

---

# 5. Relationship to Payroll Context

```text
Payroll Context
    └── Funding Profile (0..1 default, overrideable by policy)
```

A Payroll Context may reference one default Funding Profile.

A Funding Profile may serve one or more Payroll Contexts where governance permits.

This relationship answers:

- how payroll in this context is funded
- which obligations are covered
- whether special approval or segmentation rules apply

Payroll Context defines the payroll execution frame.

Funding Profile defines how that execution frame is funded.

---

# 6. Relationship to Legal Entity and Client Company

Funding Profile may be anchored beneath Legal Entity and optionally segmented by Client Company.

### 6.1 Legal Entity Relationship

Each Funding Profile must reference one governing Legal Entity.

This preserves:

- employer liability alignment
- cash-management accountability
- payroll funding traceability

### 6.2 Client Company Relationship

In PEO or segmented business models, Funding Profile may also reference Client Company.

This supports:

- client-specific funding arrangements
- trust segregation
- billing and funding separation
- client-level approval paths

Client Company may refine funding responsibility, but Legal Entity remains the primary employer-of-record anchor for payroll obligations.

---

# 7. Funding Segmentation Model

Funding Profile may define how payroll obligations are segmented for funding purposes.

Examples:

- one funding source for all obligations
- one source for net pay and one for remittances
- separate source by payroll population
- separate source by pay group
- separate source by obligation category

Typical segmentation categories include:

- net pay
- tax remittances
- benefit remittances
- garnishments
- fees or provider charges

The Funding Profile defines the intended funding pattern; the actual funding event occurs downstream in payroll execution or treasury processes.

---

# 8. Relationship to Payroll Run

A Payroll Run may use the Funding Profile assigned through Payroll Context or a governed override.

Typical path:

```text
Payroll Context
    └── Funding Profile
            └── Payroll Run Funding Use
```

Payroll Run captures the actual execution instance.

Funding Profile captures the governing funding configuration.

Where a run-level override is permitted, the override must be explicit, approved where required, and auditable.

---

# 9. Relationship to Remittance Profile

Funding Profile and Remittance Profile are related but distinct.

- **Funding Profile** answers: how obligations are financially sourced
- **Remittance Profile** answers: how obligations are delivered to authorities or recipients

A Payroll Context may reference both:

```text
Payroll Context
    ├── Funding Profile
    └── Remittance Profile
```

The two models must align, but neither replaces the other.

---

# 10. Currency and Cash-Management Considerations

Funding Profile may define a default funding currency and related cash-management behavior.

This supports:

- local payroll funding
- foreign-currency payroll execution
- funding conversion control
- multi-currency employer operations

Where multiple currencies are involved, the Funding Profile shall identify whether conversion occurs:

- prior to funding
- during disbursement preparation
- through external treasury process

Currency handling must remain explicit and auditable.

---

# 11. Funding Profile Status Model

Suggested Funding_Profile_Status values:

| Status | Meaning |
|---|---|
| Pending | Defined but not yet available for operational use |
| Active | Available for payroll funding use |
| Suspended | Temporarily restricted from use |
| Inactive | Retained historically but not in current use |
| Closed | Permanently retired and retained for history |

Status transitions shall be governed and auditable.

Closed or Inactive Funding Profiles may not be assigned to new active Payroll Contexts or Payroll Runs without formal reactivation or approved override.

---

# 12. Effective Dating and Historical Preservation

Funding Profile shall support effective-dated lifecycle management.

Changes that may require historical preservation include:

- funding source changes
- segmentation changes
- covered-obligation changes
- approval requirement changes
- currency changes
- off-cycle handling changes
- shortfall handling changes

Historical values must be preserved.

Silent overwrite is not permitted where changes affect payroll audit, funding traceability, or cash-management accountability.

---

# 13. Validation Rules

Examples of validation rules:

- Funding_Profile_Name is required
- Legal_Entity_ID is required
- Effective_Start_Date is required
- Effective_End_Date may not precede Effective_Start_Date
- At least one covered obligation flag should be true
- Suspended or Closed profiles may not be newly assigned to active Payroll Contexts
- Default_Currency_Code must be valid
- Split funding rules must reference valid segmentation logic where required
- Off_Cycle_Allowed_Flag must be compatible with profile type where policy requires

These validations may be enforced through payroll configuration governance and treasury control workflows.

---

# 14. Audit and Traceability Requirements

The system shall preserve:

- funding profile creation history
- status transition history
- legal entity linkage history
- client company linkage history
- funding source assignment history
- covered-obligation history
- segmentation configuration history
- run-level override history

This supports:

- payroll funding audit
- treasury review
- client-funding dispute handling
- operational reconstruction
- compliance review

---

# 15. Relationship to Other Models

This model integrates with:

- Payroll_Context_Data_Model
- Legal_Entity_Data_Model
- Payroll_Funding_and_Cash_Management_Model
- Net_Pay_and_Disbursement_Model
- Remittance_Profile_Data_Model
- Payroll_Run_Model

---

# 16. Summary

This model establishes Funding Profile as the governed funding configuration for payroll obligations.

Key principles:

- Funding Profile is distinct from Payroll Context, bank accounts, and payroll runs
- Funding Profile defines how payroll obligations are financially sourced
- Funding Profile attaches beneath Legal Entity and may be segmented by Client Company
- Funding Profile may cover net pay, remittances, and other payroll obligations
- Funding Profile may define segmentation and shortfall behavior
- Historical integrity and effective dating are mandatory
