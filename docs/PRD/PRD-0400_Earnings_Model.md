# PRD-400 — Earnings Model

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Earnings Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Payroll Domain |
| **Location** | `docs/PRD/PRD-0400_Earnings_Model.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §6, §9 |
| **Related Documents** | PRD-0200_Core_Entity_Model, PRD-0900_Integration_Model, SPEC/External_Earnings.md, SPEC/Residual_Commissions.md, docs/architecture/calculation-engine/Earnings_and_Deductions_Computation_Model.md, docs/architecture/calculation-engine/External_Result_Import_Specification.md |

## Purpose

Defines the supported earnings types, their calculation origins, and the requirements for importing externally calculated earnings into the payroll platform.

---

## 1. Supported Earnings Types

| Earning Type | Origin |
|---|---|
| Salary | Internal calculation |
| Hourly | Internal calculation |
| Overtime | Internal calculation |
| Bonus | Internal calculation or import |
| Commission | External import |
| Residual Commission | External import |
| Adjustments | Internal or external |
| Reversals | Internal (correction-driven) |

## 2. External Earnings Requirements

Residual commissions and certain other earnings types are calculated externally and imported into payroll. All external earnings must supply:

| Field | Requirement |
|---|---|
| Employee ID | Required |
| Amount | Required |
| Earning Type | Required — must map to a valid internal earning code |
| Earning Period | Required |
| Source System | Required |
| Reference ID | Required |
| Short Description | Required — must fit on pay statement |

Short descriptions are customer-facing and must be suitable for display on the pay statement. Length limits apply per pay statement template configuration.

## 3. External Earnings Validation

All external earnings require validation prior to payroll processing. Invalid records shall be routed to exception queues and shall not be committed to the payroll run.

## 4. Import Methods

External earnings may be imported via:

- Batch CSV file upload
- API intake
- XML file

See `SPEC/External_Earnings.md` and `SPEC/Residual_Commissions.md` for detailed import specifications.

## 5. Architecture Model Reference

Computation rules, deduction logic, and earning type classification are governed by:

- `docs/architecture/calculation-engine/Earnings_and_Deductions_Computation_Model.md`
- `docs/architecture/calculation-engine/External_Result_Import_Specification.md`
