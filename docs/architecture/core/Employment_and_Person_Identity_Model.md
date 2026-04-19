# Employment_and_Person_Identity_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Employment_and_Person_Identity_Model.md` |
| **Domain** | Core |
| **Related Documents** | PRD-200-Core-Entity-Model.md, DATA/Entity-Person.md, DATA/Entity-Employee.md, Employee_Assignment_Model, Employee_Event_and_Status_Change_Model |

## Purpose

Defines the identity model for the payroll platform, distinguishing between the human being (Person) and the payroll-recognised employment relationship (Employment). This separation supports payroll correctness, rehire scenarios, multi-employment situations, and audit traceability.

---

## 1. Core Design Principles

Person and employment shall be modelled as distinct concepts. Person_ID represents the human being. Employment_ID represents the payroll-recognised employment relationship. Payroll calculations, accumulators, results, and exports shall anchor to Employment_ID. The model supports one person having multiple employment relationships over time or concurrently.

## 2. Person Definition

Person_ID, Legal_Name, Preferred_Name (optional), Date_of_Birth, National_Identifier / SSN (secured), Contact_Attributes (optional), Person_Status. Person records represent enduring human identity independent of any single employment relationship.

## 3. Employment Definition

Employment_ID, Person_ID, Employer_ID, Employee_Number, Employment_Type, Employment_Start_Date, Employment_End_Date (optional), Employment_Status, Payroll_Context_ID, Home_Country_Code (optional), Home_Legal_Entity_ID (optional). Employment records represent the unit of payroll calculation, result production, accumulation, and export.

## 4. Relationship Between Person and Employment

One-to-many: one person may have one current employment, multiple historical employments due to rehire, or multiple concurrent employments where policy allows. Every Employment must reference exactly one Person_ID.

## 5. Why Employment_ID Is the Payroll Anchor

Payroll operates on the employment relationship, not the abstract human being. Assignments, calculation results, payables, accumulators, contribution history, export records, and payroll status tracking all key to Employment_ID.

## 6. Rehire Handling

Person_ID remains constant. New Employment_ID created for the new payroll relationship. Historical employment remains traceable. Avoids corrupting prior payroll history while preserving human identity continuity.

## 7. Concurrent Employment Handling

Each concurrent employment has its own Employment_ID and may have its own Payroll_Context_ID. Payroll calculations and accumulators remain employment-scoped unless explicitly defined otherwise.

## 8. External Identifier Handling

Employment_ID is the internal canonical payroll identity key. Employee_Number is the external-facing operational identifier. Mapping between internal and external identifiers shall be retained.

## 9. Status Models

Person_Status values: Active, Inactive, Deceased, Restricted. Employment_Status values: Pending, Active, On Leave, Suspended, Terminated, Closed. Employment status governs payroll eligibility more directly than Person status.

## 10. Data Ownership

Person-owned: legal name, date of birth, national identifier. Employment-owned: employee number, payroll context, employment status, employer assignment. This separation reduces duplication and clarifies stewardship responsibilities.

## 11. Key Design Principle

Person_ID identifies the human being. Employment_ID identifies the payroll-recognised relationship through which that person is paid. Payroll calculations, balances, results, and exports anchor to Employment_ID; long-lived personal identity continuity anchors to Person_ID.
