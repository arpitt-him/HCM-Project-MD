# PRD-700 — Workflow Framework

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Workflow Framework |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0700_Workflow_Framework.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §10 |
| **Related Documents** | PRD-0100_Architecture_Principles, docs/architecture/governance/Release_and_Approval_Model.md |

## Purpose

Defines the requirements for approval workflow governance across all platform modules. Workflows are the mechanism by which changes move from intent to effect without bypassing controls.

---

## 1. Workflow Applicability

Approval workflows shall apply to:

- Payroll run submission, approval, and release
- Configuration changes (pay rules, tax setup, calendar definitions)
- HR lifecycle events (hire, transfer, compensation change, termination)
- Leave requests
- Organizational structure changes
- External earnings import approval
- Document-sensitive field updates

## 2. Workflow States

All approval workflows shall support the following standard state lifecycle:

| State | Description |
|---|---|
| Draft | Change initiated but not submitted |
| Submitted | Submitted for review |
| Under Review | Actively being evaluated |
| Approved | Approved and staged for effect |
| Rejected | Returned without approval |
| Effective | Applied to the system of record |
| Cancelled | Withdrawn before completion |

## 3. Workflow Configuration Requirements

- Workflows shall be configurable by event type, organizational unit, and employment level.
- Multi-level approval chains shall be supported.
- Delegation of approval authority shall be supported.
- Approval deadlines and escalation rules shall be configurable.
- Self-service actions shall initiate workflow events — they shall not write directly to canonical records.

## 4. Workflow Integrity

- A change that is Approved but not yet Effective shall not affect payroll calculation.
- Rejection of a workflow shall not leave partial state mutations.
- All workflow transitions shall be auditable with timestamp and actor.

## 5. Architecture Model Reference

- `docs/architecture/governance/Release_and_Approval_Model.md`
