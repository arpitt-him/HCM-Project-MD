# PRD-800 — Validation Framework

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Validation Framework |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0800_Validation_Framework.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §11 |
| **Related Documents** | PRD-0700_Workflow_Framework, docs/architecture/governance/Configuration_and_Metadata_Management_Model.md, docs/architecture/processing/Error_Handling_and_Isolation_Model.md |

## Purpose

Defines the requirements for the validation and exception framework that governs payroll results, HR record changes, and external data intake across the platform.

---

## 1. Validation Principles

- Validation is a distinct phase from calculation and from posting. Results must pass validation before they may be posted as durable financial state.
- Validation shall be callable on demand, not only during release workflows.
- Partial posting is not permitted when Hard Stop exceptions are present.
- All validation failures shall route to visible, actionable work queues.

## 2. Exception Categories

| Category | Behavior |
|---|---|
| Informational | Logged; does not block processing |
| Warning | Visible to operator; does not block processing |
| Hold | Blocks processing until resolved or overridden with authorization |
| Hard Stop | Blocks processing unconditionally |

## 3. Payroll Validation Examples

| Exception | Category |
|---|---|
| Negative earnings without description | Warning |
| Extremely low or high net pay | Warning / Hold |
| Missing required data | Hard Stop |
| Retroactive event affecting a closed period | Hold |

## 4. HR Record Validation Examples

| Exception | Category |
|---|---|
| Missing required field on hire record | Hard Stop |
| Compensation change without approved reason code | Hold |
| Termination date before hire date | Hard Stop |
| Missing I-9 documentation past required window | Warning |

## 5. Configuration Validation

The platform shall support configuration readiness validation, including:

- Missing required configuration objects
- Broken references between configuration objects
- Effective-date misalignment
- Dependency chain gaps
- Context-specific readiness (e.g., is this employer ready to run payroll?)

## 6. Architecture Model Reference

- `docs/architecture/governance/Configuration_and_Metadata_Management_Model.md`
- `docs/architecture/processing/Error_Handling_and_Isolation_Model.md`
