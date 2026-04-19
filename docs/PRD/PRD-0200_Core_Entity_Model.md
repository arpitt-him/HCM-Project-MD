# PRD-200 — Core Entity Model

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Core Entity Model |
| **Version** | v1.0 |
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

**Person_ID** is the enduring human identity key. It persists across all employment episodes, including rehires.

**Employment_ID** is the payroll and HR operational anchor. All downstream module records (payroll results, accumulators, benefits enrollments) key to Employment_ID, not Person_ID.

This separation is defined in detail in `docs/architecture/core/Employment_and_Person_Identity_Model.md`.

## 3. Organizational Entities

| Entity | Description |
|---|---|
| **Legal Entity** | Payroll and regulatory boundary. Defines taxation jurisdiction. |
| **Org Unit** | A node in the organizational hierarchy (Division, Department, Cost Center, Location). |

Organizational structures support effective dating, hierarchical rollup, and historical traceability. Defined in detail in `docs/architecture/core/Organizational_Structure_Model.md`.

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
