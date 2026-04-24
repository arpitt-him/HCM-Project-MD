# PRD-200 — Core Entity Model

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Core Entity Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0200_Core_Entity_Model.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §4 |
| **Related Documents** | PRD-0100_Architecture_Principles, DATA/Entity_Person.md, DATA/Entity_Employee.md, DATA/Entity_Payroll_Item.md |

## Purpose

Defines the conceptual entity model for the HCM platform — the primary objects that the system manages, their purpose, and their relationships. This is the platform-level view; detailed field-level specifications live in the DATA documents.

---

## 1. Primary Entities

| Entity | Description |
|---|---|
| **Person** | Represents a human being. Owns legal identity, contact, and biographical attributes. Persists across employment episodes. |
| **Employee / Employment** | Represents the employment relationship between a Person and an Employer. Owns payroll-relevant status and operational context. |
| **Employment Record** | Historical record of an employment period. Supports point-in-time reconstruction. |
| **Job** | A defined role classification within the organization. |
| **Position** | A specific organizational slot that may be filled by an employee. |
| **Assignment** | The association of an Employment to a Job, Position, Department, and Location. |
| **Payroll Profile** | Defines the payroll characteristics of an employment (pay group, frequency, tax setup). |
| **Payroll Calendar** | Defines the period structure for payroll processing. |
| **Payroll Item** | A single earnings, deduction, or tax line within a payroll result. |
| **Accumulator** | Running totals maintained for compliance, tax, and reporting purposes. |
| **Liability** | Money owed to a jurisdiction or provider. |
| **Remittance** | A payment made to satisfy a liability. |
| **Jurisdiction** | A government authority with taxing or regulatory power. |
| **Document** | Supporting records associated with a Person or Employment (I-9, W-4, POA, etc.). |

## 2. Identity Anchoring

**REQ-PLT-040**
Person_ID shall be the enduring human identity key. It shall persist across all employment episodes, including rehires, and shall never be reassigned or reused.

**REQ-PLT-041**
Employment_ID shall be the payroll and HR operational anchor. All downstream module records — payroll results, accumulators, benefits enrolments — shall key to Employment_ID, not Person_ID.

**REQ-PLT-042**
A new Employment_ID shall be created for each new hire or rehire. Historical employment records shall remain associated with their original Employment_ID.

This separation is defined in detail in `docs/architecture/core/Employment_and_Person_Identity_Model.md`.

## 3. Organizational Entities

| Entity | Description |
|---|---|
| **Legal Entity** | Payroll and regulatory boundary. Defines taxation jurisdiction. |
| **Org Unit** | A node in the organizational hierarchy (Division, Department, Cost Center, Location). |

**REQ-PLT-043**
Organisational structures shall support effective dating, hierarchical rollup, and historical traceability.

Defined in detail in `docs/architecture/core/Organizational_Structure_Model.md`.

## 4. Entity Relationships (Conceptual)

```
Person (1) ──── (many) Employment
Employment (1) ──── (1) Payroll Profile
Employment (1) ──── (many) Assignment
Assignment ──── Job, Position, Org Unit, Location
Employment (1) ──── (many) Payroll Item
Payroll Item ──── Accumulator, Liability
Liability ──── (many) Remittance
Employment (1) ──── (many) Document
```

## 5. Governing Architecture Models

| Concern | Architecture Model |
|---|---|
| Person / Employment identity separation | Employment_and_Person_Identity_Model |
| Employment lifecycle events | Employee_Event_and_Status_Change_Model |
| Assignment structure | Employee_Assignment_Model |
| Organizational hierarchy | Organizational_Structure_Model |
| Payroll item computation | Earnings_and_Deductions_Computation_Model |
| Accumulator management | Accumulator_and_Balance_Model |
| Document storage | Data_Retention_and_Archival_Model |

---

## 6. User Stories

**Platform Architect** needs to **reference a single authoritative entity model** in order to **ensure all modules use consistent identity anchoring and avoid conflicting data ownership.**

**Payroll Engineer** needs to **resolve all financial records to Employment_ID** in order to **correctly associate payroll results, accumulators, and liabilities with the right employment episode, including rehires.**

**HR Administrator** needs to **maintain a Person record that persists across terminations and rehires** in order to **preserve the full employment history of an individual without creating duplicate person records.**

**Compliance Auditor** needs to **reconstruct the organisational and employment state as of any historical date** in order to **verify that payroll was calculated using the correct entity relationships at the time.**

---

## 7. Scope Boundaries

### In Scope — v1

**REQ-PLT-044**
All entities listed in §1 shall be implemented in v1: Person, Employment, Job, Position, Assignment, Payroll Profile, Payroll Calendar, Payroll Item, Accumulator, Liability, Remittance, Jurisdiction, Document.

**REQ-PLT-045**
Person_ID / Employment_ID identity separation shall be enforced in all v1 modules. No module shall use Person_ID as a payroll calculation anchor.

**REQ-PLT-046**
Organisational structure shall support all unit types defined in §3 in v1.

### Out of Scope — v1

**REQ-PLT-047**
Skills, competencies, and talent profile entities are out of scope for v1.

**REQ-PLT-048**
Applicant and candidate entities (pre-hire identity) are out of scope for v1.

**REQ-PLT-049**
Non-U.S. legal entity structures requiring country-specific fields beyond those defined in §3 are out of scope for v1.

---

## 8. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-PLT-040 | A rehired employee's prior payroll results remain queryable under the original Employment_ID after rehire. The new Employment_ID produces no results for prior periods. |
| REQ-PLT-041 | A point-in-time query for an employee's org unit membership on any historical date returns the correct department and location without ambiguity. |
| REQ-PLT-042 | All downstream module records (payroll results, accumulators, benefit enrollments) reference Employment_ID. A search for records by Person_ID returns all episodes; a search by Employment_ID returns only that episode. |
| REQ-PLT-043 | An organisational hierarchy with 10 levels renders without circular reference errors and all rollup calculations resolve correctly. |

---

## 9. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.


**REQ-PLT-050**
A point-in-time entity resolution query (e.g., what was this employee's department on date X) shall return a result within 2 seconds for any single employee regardless of history depth.

**REQ-PLT-051**
The entity model shall support at least 500,000 active Employment records in a single deployment without degradation in query performance below the 2-second SLA.
