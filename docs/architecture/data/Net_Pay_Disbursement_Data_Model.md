# Net_Pay_Disbursement_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Disbursement Domain |
| **Location** | docs/architecture/data/Net_Pay_Disbursement_Data_Model.md |
| **Domain** | Net Pay Disbursement / Employee Payment Delivery / Settlement Output |
| **Related Documents** | Payroll_Run_Funding_and_Remittance_Map.md, Payroll_Context_Data_Model.md, Payment_Instruction_Profile_Data_Model.md, Funding_Profile_Data_Model.md, Net_Pay_and_Disbursement_Model.md, Payroll_Run_Model.md, Employment_Data_Model.md, Person_Data_Model.md |

---

# Purpose

This document defines the core data structure for **Net Pay Disbursement** as the governed and execution-linked structure used to deliver employee net pay.

Net Pay Disbursement is not payroll calculation.

Net Pay Disbursement is not Funding Profile.

Net Pay Disbursement is not Remittance Profile.

Net Pay Disbursement is the structure that defines and records how calculated employee net pay is prepared, routed, released, and tracked for payment delivery.

This model exists to support:

- direct deposit
- split deposit
- live check
- payroll card delivery
- mixed-method payment
- off-cycle payments
- returned or rejected payments
- reversal and reissue handling
- employee-specific payment preferences

without embedding employee payment-routing behavior directly into payroll calculation or funding configuration.

---

# Core Structural Role

```text
Employment / Person / Payroll Run
    ↓
Net Pay Disbursement
    ↓
Payment Instruction Profile / Release / Delivery / Return / Reissue
```

Net Pay Disbursement is the employee-facing outbound payment structure created from payroll results under governed payment rules.

---

# 1. Net Pay Disbursement Definition

A **Net Pay Disbursement** represents the governed payment output through which a worker’s net pay is delivered.

A Net Pay Disbursement may represent:

- single direct deposit payment
- multiple split direct deposits
- payroll card load
- physical/live check
- replacement check
- corrected or reversed payment
- off-cycle payment
- manual exception payment

Net Pay Disbursement shall be modeled as distinct from:

- gross-to-net calculation result
- Funding Profile
- Remittance Profile
- Payment Instruction Profile
- Payroll Run
- bank settlement confirmation

Net Pay Disbursement is the employee payment output record, not the calculation or the external bank event itself.

---

# 2. Net Pay Disbursement Primary Attributes

| Field Name | Description |
|---|---|
| Net_Pay_Disbursement_ID | Unique identifier |
| Payroll_Run_ID | Parent payroll run reference |
| Employment_ID | Employment receiving payment |
| Person_ID | Person receiving payment |
| Payment_Instruction_Profile_ID | Governing payment instruction profile |
| Disbursement_Type | ACH, Split_ACH, Check, Payroll_Card, Wire, Other |
| Disbursement_Status | Pending, Prepared, Released, Settled, Rejected, Returned, Reversed, Reissued, Cancelled |
| Payment_Currency_Code | Currency of payment |
| Net_Pay_Amount | Total disbursement amount |
| Scheduled_Payment_Date | Intended payment date |
| Release_Timestamp | Actual release timestamp where applicable |
| Settlement_Timestamp | Settlement/confirmation timestamp where available |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Net Pay Disbursement Functional Attributes

| Field Name | Description |
|---|---|
| Split_Disbursement_Flag | Indicates multiple employee payment splits |
| Override_Flag | Indicates run-time override from default preference/profile |
| Manual_Intervention_Flag | Indicates manual processing involvement |
| Return_Handling_Type | Reject, Retry, Reissue, Manual_Review, Other |
| Reversal_Eligible_Flag | Indicates reversal support |
| Reissue_Eligible_Flag | Indicates reissue support |
| Notification_Required_Flag | Indicates employee notification required |
| Confidentiality_Level | Standard, Confidential, Restricted |
| Payment_Memo_Text | Optional payment memo/reference |
| Notes | Administrative notes |

---

# 4. Relationship to Payroll Run

```text
Payroll Run
    └── Net Pay Disbursement (0..n)
```

A Payroll Run may produce one or more Net Pay Disbursement records.

Examples:

- one employee → one direct deposit
- one employee → two split deposits
- one employee → one payroll card and one check adjustment
- one run → thousands of disbursement records

Payroll Run remains the execution anchor.

Net Pay Disbursement records the employee-level payment output of that run.

---

# 5. Relationship to Employment and Person

```text
Employment
    └── Net Pay Disbursement (0..n)

Person
    └── Net Pay Disbursement (0..n)
```

Constraints:

- Each Net Pay Disbursement must reference exactly one Employment.
- Each Net Pay Disbursement must reference exactly one Person.
- Person linkage supports durable payment history across employment lifecycle.
- Employment linkage preserves employer-of-record and payroll context traceability.

This supports:

- payroll audit
- reissue history
- payment disputes
- employee-facing payment history
- historical reporting

---

# 6. Relationship to Payment Instruction Profile

Net Pay Disbursement consumes payment-routing configuration from Payment Instruction Profile.

Typical path:

```text
Net Pay Disbursement
    └── Payment Instruction Profile
```

The disbursement record shall preserve the instruction profile used at execution time, including any explicit run-time override.

This supports:

- routing traceability
- bank/channel audit
- return handling
- payment reissue analysis

Payment Instruction Profile remains a configuration object.

Net Pay Disbursement remains an execution/output object.

---

# 7. Relationship to Funding Profile

Funding Profile governs how payroll is funded.

Net Pay Disbursement is one of the outbound uses of that funded obligation.

Typical path:

```text
Payroll Context
    └── Funding Profile
            └── Payroll Run
                    └── Net Pay Disbursement
```

Net Pay Disbursement may record or reference the funding lineage used for traceability, but it shall not replace Funding Profile as the governing funding configuration.

---

# 8. Employee Payment Preference and Split Handling

Net Pay Disbursement may be driven by employee payment preference structures.

Supported patterns may include:

- single destination payment
- percentage split
- fixed-amount split
- residual-to-primary account
- payroll card plus residual check
- emergency replacement check

A single Employment/Person may therefore produce multiple Net Pay Disbursement records in one Payroll Run.

Split handling must be:

- deterministic
- ordered where required
- auditable
- replayable

---

# 9. Payment Lifecycle and Status Flow

Net Pay Disbursement should support a lifecycle such as:

```text
Pending
    ↓
Prepared
    ↓
Released
    ↓
Settled
```

Exception paths may include:

```text
Prepared → Rejected
Released → Returned
Released → Reversed
Returned → Reissued
Pending → Cancelled
```

Status transitions shall be governed and auditable.

No disbursement status change shall silently erase prior state history.

---

# 10. Return, Reversal, and Reissue Handling

Net Pay Disbursement must support downstream exception handling.

Examples:

- rejected ACH due to invalid account
- returned payment due to closed account
- check lost and reissued
- payroll reversal following correction
- replacement payment after fraud/security event

The model should support fields or subordinate records that preserve:

- original disbursement reference
- reversal reference
- return reason
- reissue reason
- replacement disbursement reference

This supports full payment lineage.

---

# 11. Multi-Currency and International Considerations

Net Pay Disbursement may support multi-currency scenarios where allowed by payroll policy and jurisdiction.

Examples:

- local payroll currency
- home-country reporting currency
- international contractor or special-assignment settlement currency

Where multiple currencies are involved, the disbursement record should preserve:

- payment currency
- calculation/reporting currency where relevant
- conversion reference where applicable

Currency handling must remain explicit and auditable.

---

# 12. Effective Dating and Historical Preservation

Net Pay Disbursement is an execution artifact and is therefore naturally historical.

However, where payment preference or routing rules influence the disbursement, the run must preserve:

- the instruction profile used
- the payment method used
- the split logic used
- any override used
- the effective payment date used

Historical payment outputs must never be silently replaced.

Corrections should occur through reversal, replacement, adjustment, or reissue structures.

---

# 13. Validation Rules

Examples of validation rules:

- Payroll_Run_ID is required
- Employment_ID is required
- Person_ID is required
- Payment_Instruction_Profile_ID is required where profile-driven payment is used
- Net_Pay_Amount must be valid and non-negative unless special correction handling permits otherwise
- Scheduled_Payment_Date is required
- Split disbursement totals must reconcile to calculated net pay
- Released or Settled disbursements may not be edited directly outside governed correction logic
- Reissue records must reference original disbursement lineage where policy requires

These validations may be enforced through payroll release, treasury, and payment processing controls.

---

# 14. Audit and Traceability Requirements

The system shall preserve:

- disbursement creation history
- status transition history
- payment instruction profile linkage history
- split allocation history
- release history
- settlement history
- return/reversal/reissue lineage
- notification history where applicable

This supports:

- payroll audit
- employee inquiry handling
- treasury reconciliation
- bank return analysis
- legal/payment dispute response

---

# 15. Relationship to Other Models

This model integrates with:

- Payroll_Run_Funding_and_Remittance_Map
- Payroll_Context_Data_Model
- Payment_Instruction_Profile_Data_Model
- Funding_Profile_Data_Model
- Net_Pay_and_Disbursement_Model
- Payroll_Run_Model
- Employment_Data_Model
- Person_Data_Model

---

# 16. Summary

This model establishes Net Pay Disbursement as the employee-facing outbound payment output of payroll execution.

Key principles:

- Net Pay Disbursement is distinct from payroll calculation, funding, and remittance configuration
- Net Pay Disbursement records how employee net pay is actually delivered
- Net Pay Disbursement attaches to Payroll Run, Employment, and Person
- Net Pay Disbursement consumes Payment Instruction Profile without replacing it
- Split deposits, returns, reversals, and reissues must remain explicit and traceable
- Historical integrity and payment lineage are mandatory
