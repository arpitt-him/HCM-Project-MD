# Payroll_Run_Funding_and_Remittance_Map

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Domain |
| **Location** | docs/architecture/processing/Payroll_Run_Funding_and_Remittance_Map.md |
| **Domain** | Payroll Processing / Funding / Remittance / Execution Mapping |
| **Related Documents** | Payroll_Run_Model.md, Payroll_Context_Data_Model.md, Funding_Profile_Data_Model.md, Remittance_Profile_Data_Model.md, Payment_Instruction_Profile_Data_Model.md, Net_Pay_and_Disbursement_Model.md, Payroll_Funding_and_Cash_Management_Model.md |

---

## Purpose

This document defines how **Payroll Run** relates to the governed funding and remittance configuration models at execution time.

The goal is to make explicit the distinction between:

- structural payroll context
- governed configuration
- actual run-time funding behavior
- actual run-time remittance behavior
- actual payment-release and delivery behavior

This document exists to show how the following models come together during payroll execution:

- Payroll Context
- Funding Profile
- Remittance Profile
- Payment Instruction Profile
- Payroll Run

It also clarifies what belongs to configuration and what belongs to execution evidence.

---

## 1. Core Execution Relationship

The core run-time relationship is:

```text
Payroll Context
    ├── Funding Profile
    ├── Remittance Profile
    └── Rule / Calendar Context
            ↓
        Payroll Run
            ├── Funding Use
            ├── Net Pay Disbursement Use
            ├── Remittance Use
            └── Payment Release / Delivery Evidence
```

Payroll Run is the execution instance.

Profiles remain configuration objects.

Payroll Run records which configuration was used, how it was applied, and what execution outputs were produced.

---

## 2. Configuration vs Execution Boundary

### 2.1 Configuration Objects

The following are governed configuration objects:

- Payroll Context
- Funding Profile
- Remittance Profile
- Payment Instruction Profile

These define what should happen under normal governed conditions.

### 2.2 Execution Objects

The following are execution or run-derived objects:

- Payroll Run
- Funding event or funding-use record
- remittance output record
- payment release record
- disbursement output record
- remittance status/result record

These define what did happen during a specific payroll run.

### 2.3 Architectural Rule

Configuration shall not be overwritten by run-time execution.

Execution shall reference configuration by identifier and effective date.

This preserves:

- deterministic replay
- audit traceability
- dispute handling
- operational reconstruction

---

## 3. Payroll Run as Execution Anchor

Payroll Run is the central execution event.

It answers:

- when payroll was run
- which population was processed
- which context governed the run
- which funding profile was used
- which remittance profile was used
- which payment instructions were used
- what outputs were generated
- what failed, held, or completed

Typical structure:

```text
Payroll Run
    ├── Payroll_Context_ID
    ├── Funding_Profile_ID
    ├── Remittance_Profile_ID
    ├── Rule_Pack_Set_ID
    ├── Calendar_ID
    └── Payroll_Run_Result_Set
```

Payroll_Run_Result_Set is the authoritative execution-output container for the run.

Funding use records, remittance use records, payment release evidence, and downstream disbursement outputs shall remain traceable either directly to Payroll_Run_ID or through Payroll_Run_Result_Set_ID where result-set lineage is required.

This preserves consistent linkage between run identity, calculation outputs, financial execution, and replay evidence.

Payroll Run shall retain explicit references to the governing configuration used at execution time, even where those references are inherited from Payroll Context by default.

---

## 4. Payroll Context to Payroll Run Mapping

The normal path is:

```text
Payroll Context
    └── Payroll Run (0..n)
```

At run creation time, Payroll Context provides the baseline execution frame, including:

- legal entity
- payroll calendar
- primary jurisdiction frame
- funding profile
- remittance profile
- rule-pack context
- reporting context

Payroll Run inherits or resolves these inputs into its execution record.

Run-level overrides may be permitted only under governed and auditable conditions.

---

## 5. Funding Profile to Payroll Run Mapping

Funding Profile does not execute payroll.

Funding Profile governs how payroll obligations are financially sourced when the run executes.

Typical relationship:

```text
Funding Profile
    └── Payroll Run Funding Use (0..n)
```

Payroll Run Funding Use should record, at minimum:

- Payroll_Run_ID
- Funding_Profile_ID
- effective configuration reference
- covered obligation scope
- source segmentation used
- override flag where applicable
- release or hold status
- shortfall outcome where applicable

This structure allows one Payroll Run to show exactly how it was funded without turning Funding Profile into a transaction record.

---

## 6. Remittance Profile to Payroll Run Mapping

Remittance Profile governs how obligations are delivered outward.

Typical relationship:

```text
Remittance Profile
    └── Payroll Run Remittance Use (0..n)
```

Payroll Run Remittance Use should record, at minimum:

- Payroll_Run_ID
- Remittance_Profile_ID
- obligation type
- recipient grouping
- due-date logic used
- filing-linked behavior used
- consolidation vs split behavior used
- release status
- transmission status
- exception status

This structure allows the run to capture what remittance behavior was actually used and what outputs resulted.

---

## 7. Payment Instruction Profile to Payroll Run Mapping

Payment Instruction Profile supplies the payment-routing and release configuration for:

- net pay
- remittances
- provider settlements
- garnishments
- check issuance
- file/API/portal payment delivery

Typical relationship:

```text
Payroll Run Funding Use / Payroll Run Remittance Use / Net Pay Disbursement Use
    └── Payment Instruction Profile
```

At execution time, the run should preserve:

- Payment_Instruction_Profile_ID
- payment method used
- channel used
- formatting profile used
- destination/routing snapshot or reference
- release approval state
- return or rejection status where applicable

The run must preserve sufficient traceability to reconstruct why a specific payment path was used.

---

## 8. Net Pay vs Remittance Separation

The payroll run may generate multiple outbound money streams.

At minimum, these should be conceptually separated into:

- **Net Pay Disbursement**
- **Statutory Remittance**
- **Benefit / Provider Remittance**
- **Garnishment Remittance**
- **Other Payroll-Related Outbound Payments**

These streams may share configuration components, but they are not the same thing.

Typical run-time pattern:

```text
Payroll Run
    ├── Net Pay Disbursement Use
    ├── Tax Remittance Use
    ├── Benefit Remittance Use
    ├── Garnishment Remittance Use
    └── Other Outbound Payment Use
```

This separation is critical for:

- audit
- reconciliation
- returns and reversals
- remittance timing
- funding shortfall handling
- exception management

---

## 8.1 Relationship to Employee Payroll Results

Funding, net pay disbursement, and certain remittance obligations originate from Employee Payroll Results generated within the Payroll Run Result Set.

Relationship:

Payroll_Run
        ↓
Payroll_Run_Result_Set
        ↓
Employee_Payroll_Result
        ↓
Net Pay / Employee-Level Obligations
        ↓
Funding and Remittance Use

This relationship ensures that:

- employee-level net pay remains traceable to worker-level payroll results
- employer and employee liabilities remain traceable to the result lines that created them
- reconciliation can explain both aggregate run totals and worker-level financial origins

---

## 8.2 Relationship to Net Pay Disbursement

Net pay disbursement outputs should be represented through governed disbursement records rather than inferred only from payment instruction usage.

Relationship:

Employee_Payroll_Result
        ↓
Net_Pay_Disbursement
        ↓
Payment_Instruction_Profile
        ↓
Payment Release / Delivery Evidence

Payroll_Run_Funding_and_Remittance_Map defines how Payroll Run relates to these disbursement uses at execution time.

Net pay disbursement must remain distinct from:

- statutory remittance
- benefit remittance
- garnishment remittance
- other outbound payroll-related payments

---

## 9. Default Inheritance and Run-Time Override Rules

The default execution path is:

```text
Payroll Context
    ├── Funding Profile
    ├── Remittance Profile
    └── Payment Instruction references where applicable
            ↓
        Payroll Run
```

Run-time overrides may be allowed for:

- off-cycle runs
- emergency funding changes
- authority-specific remittance handling
- bank outage / payment channel substitution
- approved correction processing

Any override must be:

- explicit
- approved where required
- effective-dated or run-specific
- auditable
- queryable after the fact

No override shall silently replace the original configuration lineage.

---

## 9.1 Source Period vs Execution Period

Funding and remittance behavior may be associated with both:

- Source_Period_ID — the original payroll period to which the obligation logically belongs
- Execution_Period_ID — the period in which processing, correction, or release activity occurs

These may differ in cases such as:

- retroactive correction runs
- supplemental runs
- post-finalization adjustment runs
- reissued or delayed disbursements
- remittance retries or corrected releases

Preserving both values supports:

- reporting attribution
- remittance timing analysis
- replay reconstruction
- reconciliation across corrections and reruns

---

## 10. Funding and Remittance Outcome Recording

Payroll Run should preserve run-time outcome records distinct from configuration records.

Examples include:

### 10.1 Funding Outcomes
- funded in full
- partially funded
- funding held
- funding rejected
- shortfall detected
- override funding source used

### 10.2 Remittance Outcomes
- remittance prepared
- remittance released
- remittance transmitted
- remittance accepted
- remittance rejected
- filing hold applied
- retry required

### 10.3 Payment Outcomes
- ACH file generated
- wire released
- check printed
- portal payment submitted
- API payment acknowledged
- return/reversal initiated

These outcomes belong to execution evidence, not to the profile definitions.

---

## 11. Reconciliation and Audit Implications

Because Payroll Run brings together payroll results, funding behavior, and remittance behavior, it must preserve enough linkage for downstream reconciliation.

At minimum, reconciliation should be able to answer:

- which run produced this obligation
- which profile governed it
- which instruction profile routed it
- whether it was released
- whether it settled or failed
- whether it was retried, reversed, or corrected

This supports:

- payroll reconciliation
- treasury reconciliation
- remittance reconciliation
- provider settlement review
- audit inquiry response

---

## 12. Suggested Runtime Mapping Structures

The implementation may use one or more runtime mapping records such as:

### 12.1 Payroll_Run_Funding_Use
- Payroll_Run_ID
- Funding_Profile_ID
- Funding_Source_Set_ID
- Covered_Obligation_Type
- Funding_Status
- Override_Flag

### 12.2 Payroll_Run_Remittance_Use
- Payroll_Run_ID
- Remittance_Profile_ID
- Recipient_Group_ID
- Obligation_Type
- Remittance_Status
- Filing_Linked_Flag

### 12.3 Payroll_Run_Payment_Instruction_Use
- Payroll_Run_ID
- Payment_Instruction_Profile_ID
- Payment_Method
- Channel_Type
- Release_Status
- Transmission_Status

These are illustrative structures, not required final implementation names.

---

## 13. Relationship to Exception and Correction Handling

Funding and remittance behavior may generate exceptions or require governed correction activity.

Examples include:

- funding shortfall
- invalid payment instruction
- expired remittance profile
- closed payment channel
- rejected ACH file
- filing dependency not satisfied
- authority-specific validation failure
- remittance reversal or retry
- disbursement reissue after return

These events shall remain traceable through:

- Payroll_Exception_Model
- Payroll_Adjustment_and_Correction_Model

The run must preserve enough mapping detail for exceptions to be routed, investigated, resolved, and, where necessary, corrected without losing original configuration or result lineage.

---

## 14. Relationship to Other Models

This map integrates with:

- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Payroll_Context_Data_Model
- Funding_Profile_Data_Model
- Remittance_Profile_Data_Model
- Payment_Instruction_Profile_Data_Model
- Net_Pay_and_Disbursement_Model
- Net_Pay_Disbursement_Data_Model
- Payroll_Exception_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Funding_and_Cash_Management_Model
- Payroll_Reconciliation_Model

---

## 15. Summary

This document establishes how Payroll Run brings together governed funding and remittance configuration at execution time.

Key principles:

- Payroll Run is the execution anchor
- Profiles remain configuration objects
- Execution must reference configuration, not overwrite it
- Funding, remittance, and payment routing outcomes must be captured separately
- Net pay and remittance streams must remain distinct
- Overrides must be explicit and auditable
- The model must support replay, reconciliation, and audit reconstruction
