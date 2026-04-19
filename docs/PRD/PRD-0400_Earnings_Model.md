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

**REQ-ERN-001**
The platform shall support salary earnings calculated internally.

**REQ-ERN-002**
The platform shall support hourly earnings calculated internally from time entry data.

**REQ-ERN-003**
The platform shall support overtime earnings calculated internally per applicable jurisdiction rules.

**REQ-ERN-004**
The platform shall support bonus earnings sourced either from internal configuration or external import.

**REQ-ERN-005**
The platform shall support commission earnings sourced from external import.

**REQ-ERN-006**
The platform shall support residual commission earnings sourced from external import.

**REQ-ERN-007**
The platform shall support earning adjustments sourced either internally or from external import.

**REQ-ERN-008**
The platform shall support earning reversals generated internally as part of correction processing.

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

**REQ-ERN-010**
All external earnings imports shall supply Employee ID, Amount, Earning Type, Earning Period, Source System, Reference ID, and Short Description.

**REQ-ERN-011**
The Earning Type field shall map to a valid canonical internal earning code. Records with unmapped earning types shall be rejected and routed to the exception queue.

**REQ-ERN-012**
Short descriptions shall be customer-facing and suitable for display on the pay statement. Length limits shall be enforced per pay statement template configuration.

## 3. External Earnings Validation

**REQ-ERN-013**
All external earnings shall be validated prior to inclusion in a payroll run.

**REQ-ERN-014**
Invalid external earning records shall be routed to exception queues and shall not be committed to the payroll run.

**REQ-ERN-015**
Partial posting of an external earnings batch is not permitted. A batch either commits fully or is rejected in full, subject to configured policy.

## 4. Import Methods

**REQ-ERN-020**
External earnings shall be importable via batch CSV file upload.

**REQ-ERN-021**
External earnings shall be importable via API intake.

**REQ-ERN-022**
External earnings shall be importable via XML file.

See `SPEC/External_Earnings.md` and `SPEC/Residual_Commissions.md` for detailed import specifications.

## 5. Architecture Model Reference

Computation rules, deduction logic, and earning type classification are governed by:

- `docs/architecture/calculation-engine/Earnings_and_Deductions_Computation_Model.md`
- `docs/architecture/calculation-engine/External_Result_Import_Specification.md`

---

## 6. User Stories

**Payroll Administrator** needs to **import externally calculated commission and residual earnings via file upload** in order to **include those amounts in the payroll run without recalculating them inside the platform.**

**Payroll Administrator** needs to **validate all external earnings before they are committed to a run** in order to **prevent invalid records from corrupting payroll results.**

**Commission Operations Manager** needs to **submit residual commission amounts for a period and receive confirmation of acceptance** in order to **verify that the amounts submitted were accurately received and will appear on employee pay statements.**

**Payroll Engineer** needs to **classify every earning using the canonical code mapping** in order to **ensure correct tax treatment, accumulator routing, and pay statement display regardless of source system.**

---

## 7. Scope Boundaries

### In Scope — v1

**REQ-ERN-030**
All eight earning types defined in §1 (salary, hourly, overtime, bonus, commission, residual commission, adjustments, reversals) shall be supported in v1.

**REQ-ERN-031**
All three external import methods (CSV batch, API, XML) shall be supported in v1.

**REQ-ERN-032**
The staging and approval workflow for external earnings shall be required for all imports in v1.

### Out of Scope — v1

**REQ-ERN-033**
Real-time commission calculation within the platform is out of scope for v1. The platform accepts externally calculated commission amounts only.

**REQ-ERN-034**
Piece-rate, tip income, and per-diem earning types are out of scope for v1.

---

## 8. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-ERN-001 | A salaried employee's gross earnings for a standard period match the configured annual salary divided by the number of periods per year, within rounding tolerance. |
| REQ-ERN-002 | An hourly employee's gross earnings equal hours worked multiplied by the configured hourly rate. |
| REQ-ERN-003 | Overtime earnings are calculated at the correct multiplier for the applicable jurisdiction rule. |
| REQ-ERN-010 | An external earnings CSV missing any required field is rejected entirely with ERR-EXT-001 to ERR-EXT-015 as applicable. |
| REQ-ERN-011 | An external earnings record with an unmapped Earning_Type is rejected with ERR-EXT-011 and routed to the exception queue. |
| REQ-ERN-012 | A Description field exceeding the pay statement character limit produces ERR-EXT-016 (warning) and the description is truncated. |
| REQ-ERN-013 | An external earnings batch with one invalid record follows the configured policy: reject all (default) or accept valid records and reject invalid. |
| REQ-ERN-014 | An approved external earnings batch appears as earning lines on the employee's pay statement with the correct Description, Amount, and Code. |
| REQ-ERN-020 | A batch file submitted via CSV is accepted and processed identically to the same data submitted via API. |
| REQ-ERN-021 | A resubmitted file with the same Source_Batch_ID is rejected as a duplicate with ERR-EXT-004. |
| REQ-ERN-022 | A negative recovery earning reduces the employee's gross wages accumulator for the period. |

---

## 9. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.


**REQ-ERN-040**
An external earnings batch file containing 50,000 records shall complete validation within 5 minutes.

**REQ-ERN-041**
An API-based external earnings submission (single record) shall receive a validation response within 2 seconds.

**REQ-ERN-042**
Earnings code classification lookup shall return a canonical mapping within 500 milliseconds for any valid code.
