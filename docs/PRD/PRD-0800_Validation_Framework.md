# PRD-800 — Validation Framework

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Validation Framework |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0800_Validation_Framework.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §11 |
| **Related Documents** | PRD-0700_Workflow_Framework, docs/architecture/governance/Configuration_and_Metadata_Management_Model.md, docs/architecture/processing/Error_Handling_and_Isolation_Model.md |

## Purpose

Defines the requirements for the validation and exception framework that governs payroll results, HR record changes, and external data intake across the platform.

---

## 1. Validation Principles

**REQ-VAL-001**
Validation shall be a distinct phase from calculation and from posting. Results must pass validation before they may be posted as durable financial state.

**REQ-VAL-002**
Validation shall be callable on demand, not only during release workflows.

**REQ-VAL-003**
Partial posting shall not be permitted when Hard Stop exceptions are present.

**REQ-VAL-004**
All validation failures shall route to visible, actionable work queues.

## 2. Exception Categories

**REQ-VAL-010**
The platform shall support the following exception severity levels:

| Severity | Behaviour |
|---|---|
| Informational | Logged; does not block processing |
| Warning | Visible to operator; does not block processing |
| Hold | Blocks processing until resolved or overridden with authorisation |
| Hard Stop | Blocks processing unconditionally; cannot be overridden |

## 3. Payroll Validation Rules

**EXC-VAL-001**
Negative earnings without description → Hard Stop

**EXC-VAL-002**
Net pay below zero without approved override → Hold

**EXC-VAL-003**
Missing required payroll data fields → Hard Stop

**EXC-VAL-004**
Extremely low or high net pay beyond configured threshold → Warning

## 4. HR Record Validation Rules

**EXC-VAL-010**
Missing required field on hire record → Hard Stop

**EXC-VAL-011**
Compensation change without approved reason code → Hold

**EXC-VAL-012**
Termination date before hire date → Hard Stop

**EXC-VAL-013**
Missing I-9 documentation past legally required window → Warning

**EXC-VAL-014**
Retroactive event affecting a closed payroll period → Hold (requires Payroll confirmation)

## 5. Configuration Validation

**REQ-VAL-020**
The platform shall support configuration readiness validation covering: missing required configuration objects, broken references, effective-date misalignment, dependency chain gaps, and context-specific readiness.

**REQ-VAL-021**
Configuration validation shall identify blocking vs non-blocking issues and provide operator guidance on remediation.

**REQ-VAL-022**
Blocking configuration validation failures shall prevent payroll run initiation.

## 6. Architecture Model Reference

- `docs/architecture/governance/Configuration_and_Metadata_Management_Model.md`
- `docs/architecture/processing/Error_Handling_and_Isolation_Model.md`

---

## 7. User Stories

**Payroll Administrator** needs to **run pre-calculation validation on demand** in order to **identify and resolve blocking exceptions before the calculation phase begins, reducing the risk of a failed run.**

**Payroll Engineer** needs to **validate configuration readiness before initiating a run** in order to **detect missing or misconfigured objects that would cause a calculation failure mid-run.**

**HR Administrator** needs to **receive immediate validation feedback when entering a hire record** in order to **correct data errors at point of entry rather than discovering them during payroll processing.**

**Compliance Auditor** needs to **retrieve the complete validation history for any payroll run** in order to **demonstrate which exceptions were raised, how they were resolved, and who authorised any overrides.**

---

## 8. Scope Boundaries

### In Scope — v1

**REQ-VAL-030**
All four exception severity levels (Informational, Warning, Hold, Hard Stop) shall be implemented in v1.

**REQ-VAL-031**
All EXC-VAL-001 to EXC-VAL-024 rules defined in `docs/EXC/EXC-VAL_Validation_Exceptions.md` shall be enforced in v1.

**REQ-VAL-032**
Configuration readiness validation (pre-run check) shall be available as an on-demand operation in v1.

**REQ-VAL-033**
All validation failures shall route to visible, operator-actionable work queues in v1.

### Out of Scope — v1

**REQ-VAL-034**
Machine-learning-based anomaly detection (e.g., predictive variance flagging based on historical patterns) is out of scope for v1. Variance detection uses configured thresholds only.

**REQ-VAL-035**
Automated exception resolution (system self-correcting validation failures without operator intervention) is out of scope for v1.

---

## 9. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-VAL-001 | A payroll result that passes validation can be posted. A payroll result with an unresolved Hard Stop exception cannot be posted under any circumstance. |
| REQ-VAL-002 | Validation can be triggered independently of the payroll run initiation without initiating a run. |
| REQ-VAL-003 | A payroll run with 100 employees where 5 have Hard Stop exceptions completes successfully for the 95 unaffected employees. The 5 affected employees are routed to the exception queue. |
| REQ-VAL-004 | Every exception raised during validation appears in the operator's work queue within 1 minute of detection. |
| REQ-VAL-010 | EXC-VAL-001 (negative earnings without description) prevents posting for the affected employee and produces a Hard Stop work queue item. |
| REQ-VAL-011 | EXC-VAL-002 (net pay below zero) produces a Hold that prevents posting until resolved or overridden with documented authorisation. |
| REQ-VAL-020 | A pre-run readiness check identifies all missing required configuration objects and lists them with severity and remediation guidance. |
| REQ-VAL-021 | A pre-run readiness check that identifies at least one Hard Stop blocks run initiation. |
| REQ-VAL-022 | An operator-acknowledged override of a Hold exception is recorded in the audit log with actor identity, timestamp, and override reason. |

---

## 10. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.


**REQ-VAL-040**
Pre-run configuration readiness validation for a single payroll context shall complete within 2 minutes regardless of the number of configuration objects in scope.

**REQ-VAL-041**
Post-calculation validation for a run of 25,000 employees shall complete within 10% of the total calculation time for that run.

**REQ-VAL-042**
Gross-to-net automated variance checks shall complete within 5 minutes for any payroll run size.

**REQ-VAL-043**
A full payroll register generation shall complete within 30 minutes for any payroll run size.

**REQ-VAL-044**
Exception work queue items shall be visible to operators within 1 minute of exception detection under normal load conditions.
