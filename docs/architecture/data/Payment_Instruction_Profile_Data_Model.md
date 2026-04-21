# Payment_Instruction_Profile_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payments & Treasury Domain |
| **Location** | docs/architecture/data/Payment_Instruction_Profile_Data_Model.md |
| **Domain** | Payment Instruction Profile / Payment Routing / Settlement Configuration |
| **Related Documents** | Funding_Profile_Data_Model.md, Remittance_Profile_Data_Model.md, Net_Pay_and_Disbursement_Model.md, Payroll_Context_Data_Model.md, Legal_Entity_Data_Model.md, Jurisdiction_Registration_and_Profile_Data_Model.md |

---

# Purpose

This document defines the core data structure for **Payment Instruction Profile** as the governed configuration used to describe how a payment or remittance is routed, formatted, and released to an external financial or settlement destination.

Payment Instruction Profile is not Funding Profile.

Payment Instruction Profile is not Remittance Profile.

Payment Instruction Profile is not the actual payment transaction.

Payment Instruction Profile is the reusable payment-routing configuration that defines:

- where money is sent
- how money is sent
- which banking or settlement instructions apply
- which payment formatting rules apply
- which release constraints or approval controls apply
- which payment channel is used

This model exists to support:

- ACH and wire payments
- check production instructions
- authority remittance payments
- provider settlement instructions
- garnishment payments
- multi-bank and multi-channel payment handling
- country-specific payment formats
- reusable payment routing across payroll contexts

without embedding payment-routing detail directly into payroll run records or remittance calculation logic.

---

# Core Structural Role

```text
Funding Profile / Remittance Profile / Net Pay Disbursement
    ↓
Payment Instruction Profile
    ↓
Banking / Routing / Channel / Format / Release Control
    ↓
Payment Execution
```

Payment Instruction Profile is the configuration layer between a governed obligation or disbursement context and the actual payment execution event.

---

# 1. Payment Instruction Profile Definition

A **Payment Instruction Profile** represents a governed reusable payment-routing configuration for a defined payment scenario.

A Payment Instruction Profile may represent:

- employee net-pay ACH instructions
- authority wire instructions
- provider settlement instructions
- garnishment payment instructions
- check printing instructions
- payroll-card settlement instructions
- domestic payment routing
- international payment routing

Payment Instruction Profile shall be modeled as distinct from:

- Funding Profile
- Remittance Profile
- bank account master record
- Payroll Run
- disbursement transaction
- remittance transaction

Payment Instruction Profile is the governed payment-routing configuration, not the payment itself.

---

# 2. Payment Instruction Profile Primary Attributes

| Field Name | Description |
|---|---|
| Payment_Instruction_Profile_ID | Unique identifier |
| Payment_Instruction_Profile_Code | Business/system code |
| Payment_Instruction_Profile_Name | Human-readable name |
| Payment_Instruction_Profile_Type | Net_Pay, Tax_Remittance, Benefit_Remittance, Garnishment, Provider_Settlement, Check, Other |
| Legal_Entity_ID | Governing Legal Entity reference |
| Client_Company_ID | Parent Client Company reference where relevant |
| Tenant_ID | Parent Tenant reference where relevant |
| Currency_Code | Governing payment currency |
| Payment_Instruction_Profile_Status | Pending, Active, Suspended, Inactive, Closed |
| Effective_Start_Date | Date profile becomes effective |
| Effective_End_Date | Date profile ceases use |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Payment Instruction Functional Attributes

| Field Name | Description |
|---|---|
| Payment_Method | ACH, Wire, Check, RTP, Payroll_Card, Portal, Other |
| Payment_Channel_Type | Bank_File, API, Portal, Manual_Release, Print, Other |
| Settlement_Direction | Outbound, Inbound_Adjustment, Mixed |
| Recipient_Type | Employee, Authority, Provider, Garnishment_Agency, Internal_Settlement, Other |
| Formatting_Profile_ID | File or message formatting profile reference |
| Release_Approval_Required_Flag | Indicates approval required before release |
| Release_Window_Type | Immediate, Scheduled, Cutoff_Driven, Filing_Driven, Other |
| Holiday_Handling_Type | Advance, Delay, Prior_Business_Day, Next_Business_Day, Other |
| Return_Handling_Type | Reject, Retry, Exception_Queue, Manual_Review, Other |
| Prenote_Required_Flag | Indicates prenote handling where applicable |
| Notes | Administrative notes |

---

# 4. Payment Destination and Routing

A Payment Instruction Profile may reference one or more destination/routing records.

Typical structure:

```text
Payment Instruction Profile
    └── Payment Destination (1..n)
```

Destination and routing details may include:

- receiving bank reference
- account number or tokenized account reference
- routing/transit number
- SWIFT/BIC code
- IBAN
- check payee configuration
- provider settlement endpoint
- authority payment portal identifier

These routing details shall be governed separately from the profile where separation improves security and reuse.

The profile defines how routing is used operationally.

---

# 5. Relationship to Funding Profile

Funding Profile defines how payroll obligations are funded.

Payment Instruction Profile defines how money is routed once funding and payment release occur.

Typical relationship:

```text
Funding Profile
    └── Payment Instruction Profile (0..n)
```

Examples:

- one funding profile may use a bank transfer instruction for prefunding
- one funding profile may use multiple payment instruction profiles by obligation type
- one funding profile may define different instructions for net pay and remittances

The two models are related but distinct.

---

# 6. Relationship to Remittance Profile

Remittance Profile defines how obligations are delivered to recipients conceptually.

Payment Instruction Profile defines the concrete routing and release instructions for those deliveries.

Typical relationship:

```text
Remittance Profile
    └── Payment Instruction Profile (0..n)
```

Examples:

- a tax remittance profile may point to an ACH authority payment instruction
- a garnishment profile may point to check-based or ACH-based instruction
- a provider remittance profile may point to API settlement or wire instruction

Remittance Profile answers the what and when.

Payment Instruction Profile answers the how.

---

# 7. Relationship to Net Pay Disbursement

For employee payments, Payment Instruction Profile may also support net-pay disbursement behavior.

Examples:

- ACH direct deposit pattern
- payroll card transfer pattern
- live check pattern
- international employee payment instruction

Typical path:

```text
Net Pay Disbursement
    └── Payment Instruction Profile
```

This allows employee-facing payment mechanics to reuse the same governed routing model without conflating net-pay preference with payroll funding.

---

# 8. Relationship to Legal Entity, Client Company, and Tenant

Payment Instruction Profile is anchored beneath Legal Entity and may be segmented by Client Company and Tenant where relevant.

### 8.1 Legal Entity Relationship

Each Payment Instruction Profile must reference one governing Legal Entity.

This preserves:

- financial accountability
- payment authority alignment
- treasury traceability
- employer-of-record consistency

### 8.2 Client Company Relationship

In PEO and segmented business models, Payment Instruction Profile may also reference Client Company.

This supports:

- client-specific settlement arrangements
- segregated remittance routing
- separate payment approval patterns

### 8.3 Tenant Relationship

Tenant reference may exist for scoping, configuration ownership, or reporting convenience, but Tenant is not the statutory or financial payment anchor.

Legal Entity remains the primary operational anchor.

---

# 9. Payment Formatting and Channel Handling

Payment Instruction Profile may reference formatting and channel behavior needed for execution.

Examples:

- NACHA file format
- ISO 20022 payment message
- authority-specific remittance file
- provider-specific API payload
- check print layout

Formatting requirements may vary by:

- country
- bank
- authority
- provider
- payment method

The profile shall support country-aware and channel-aware formatting selection.

---

# 10. Release and Approval Controls

Payment Instruction Profile may define release controls.

Examples:

- manual approval required before payment release
- dual approval required above threshold
- filing must complete before payment release
- release only within designated payment window
- hold on failed prenote validation

Release controls may depend on:

- payment type
- amount threshold
- recipient type
- jurisdiction
- payment channel

These controls must be explicit and auditable.

---

# 11. Payment Instruction Profile Status Model

Suggested Payment_Instruction_Profile_Status values:

| Status | Meaning |
|---|---|
| Pending | Defined but not yet available for operational use |
| Active | Available for payment execution use |
| Suspended | Temporarily restricted from use |
| Inactive | Retained historically but not in current use |
| Closed | Permanently retired and retained for history |

Status transitions shall be governed and auditable.

Closed or Inactive Payment Instruction Profiles may not be assigned to new active Funding Profiles, Remittance Profiles, or disbursement uses without formal reactivation or approved override.

---

# 12. Effective Dating and Historical Preservation

Payment Instruction Profile shall support effective-dated lifecycle management.

Changes that may require historical preservation include:

- destination account changes
- routing changes
- payment method changes
- payment channel changes
- formatting changes
- release control changes
- holiday handling changes
- return handling changes

Historical values must be preserved.

Silent overwrite is not permitted where changes affect payment auditability, treasury traceability, regulatory handling, or dispute resolution.

---

# 13. Validation Rules

Examples of validation rules:

- Payment_Instruction_Profile_Name is required
- Legal_Entity_ID is required
- Currency_Code is required
- Payment_Method is required
- Payment_Channel_Type is required
- Effective_Start_Date is required
- Effective_End_Date may not precede Effective_Start_Date
- Suspended or Closed profiles may not be newly assigned to active funding or remittance contexts
- Prenote_Required_Flag may only apply to compatible payment methods
- Formatting_Profile_ID must be valid for the chosen payment channel where required
- Release approval requirements must not conflict with upstream funding/remittance controls without governed exception handling

These validations may be enforced through treasury configuration governance, security controls, and payment-channel integration rules.

---

# 14. Audit and Traceability Requirements

The system shall preserve:

- payment instruction profile creation history
- status transition history
- legal entity linkage history
- client company linkage history
- destination/routing history
- payment method and channel history
- formatting profile history
- release control history
- run-level override history

This supports:

- payment audit
- treasury review
- authority/payment dispute handling
- incident investigation
- processing lineage reconstruction

---

# 15. Relationship to Other Models

This model integrates with:

- Funding_Profile_Data_Model
- Remittance_Profile_Data_Model
- Net_Pay_and_Disbursement_Model
- Payroll_Context_Data_Model
- Legal_Entity_Data_Model
- Jurisdiction_Registration_and_Profile_Data_Model

---

# 16. Summary

This model establishes Payment Instruction Profile as the governed routing and release configuration for outbound payments.

Key principles:

- Payment Instruction Profile is distinct from Funding Profile, Remittance Profile, and payment transactions
- Payment Instruction Profile defines how money is routed and released
- Payment Instruction Profile attaches beneath Legal Entity and may be segmented by Client Company
- Payment Instruction Profile supports banking, channel, formatting, and release-control behavior
- Historical integrity and effective dating are mandatory
