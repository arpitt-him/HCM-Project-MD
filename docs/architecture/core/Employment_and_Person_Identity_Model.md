# Employment_and_Person_Identity_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Employment_and_Person_Identity_Model.md` |
| **Domain** | Core |
| **Related Documents** | PRD-200-Core-Entity-Model.md, DATA/Entity-Person.md, DATA/Entity-Employee.md, Employee_Assignment_Model, Employee_Event_and_Status_Change_Model |

## Purpose

Defines the identity model for the payroll platform, distinguishing between the human being (Person) and the payroll-recognised employment relationship (Employment).

This separation supports payroll correctness, rehire scenarios, multi-employment situations, deterministic replay, and audit traceability.

Person provides enduring human identity continuity. Employment provides the governed execution anchor for payroll participation, result generation, accumulation, export, and correction workflows.

---

## 1. Core Design Principles

Person and employment shall be modelled as distinct concepts. Person_ID represents the human being. Employment_ID represents the payroll-recognised employment relationship. Payroll calculations, accumulators, results, and exports shall anchor to Employment_ID. The model supports one person having multiple employment relationships over time or concurrently.

## 2. Person Definition

Person_ID, Legal_Name, Preferred_Name (optional), Date_of_Birth, National_Identifier / SSN (secured), Contact_Attributes (optional), Person_Status. Person records represent enduring human identity independent of any single employment relationship.

## 3. Employment Definition

Employment_ID, Person_ID, Employer_ID, Employee_Number, Employment_Type, Employment_Start_Date, Employment_End_Date (optional), Employment_Status, Payroll_Context_ID, Home_Country_Code (optional), Home_Legal_Entity_ID (optional). Employment records represent the unit of payroll calculation, result production, accumulation, and export.

Additional employment attributes may include:

Employment_Version_ID  
Source_Event_ID  
Run_Scope_Eligibility_Flag  
Source_Period_ID  
Execution_Period_ID  

These attributes support deterministic payroll routing, replay, and correction handling.

## 4. Relationship Between Person and Employment

One-to-many: one person may have one current employment, multiple historical employments due to rehire, or multiple concurrent employments where policy allows. Every Employment must reference exactly one Person_ID.

The Person-to-Employment relationship must remain historically preservable.

Changes to employment state must not alter prior person-employment linkage history for completed payroll periods.

## 5. Why Employment_ID Is the Payroll Anchor

Payroll operates on the employment relationship, not the abstract human being.

Assignments, payroll contexts, run scopes, employee payroll results, accumulators, contribution history, export records, reconciliation artifacts, and payroll status tracking all key to Employment_ID.

Person_ID remains necessary for human identity continuity, but Employment_ID remains the governed payroll execution anchor.

## 6. Rehire Handling

Person_ID remains constant. New Employment_ID created for the new payroll relationship. Historical employment remains traceable. Avoids corrupting prior payroll history while preserving human identity continuity.

Rehire handling must preserve deterministic replay by ensuring historical payroll results continue to reference the original Employment_ID under which they were produced.

Rehire must never silently merge old and new payroll execution histories.

## 7. Concurrent Employment Handling

Each concurrent employment has its own Employment_ID and may have its own Payroll_Context_ID. Payroll calculations and accumulators remain employment-scoped unless explicitly defined otherwise.

Concurrent employments must remain independently traceable in:

- payroll runs
- employee payroll results
- accumulators
- exports
- reconciliation workflows

Shared person identity must not collapse payroll execution separation.

## 8. External Identifier Handling

Employment_ID is the internal canonical payroll identity key. Employee_Number is the external-facing operational identifier. Mapping between internal and external identifiers shall be retained.

Mappings between internal and external identifiers must remain historically queryable so that payroll exports, provider responses, and reconciliation outcomes can be traced back to the correct Employment_ID.

## 9. Status Models

Person_Status values: Active, Inactive, Deceased, Restricted. Employment_Status values: Pending, Active, On Leave, Suspended, Terminated, Closed. Employment status governs payroll eligibility more directly than Person status.

Employment status changes shall remain traceable to Employee_Event_and_Status_Change_Model and must support deterministic routing of payroll eligibility, leave handling, benefit eligibility, and tax treatment updates.

## 10. Data Ownership

Person-owned: legal name, date of birth, national identifier. Employment-owned: employee number, payroll context, employment status, employer assignment. This separation reduces duplication and clarifies stewardship responsibilities.

## 10.1 Relationship to Other Models

This model integrates with:

- Employee_Event_and_Status_Change_Model
- Employee_Assignment_Model
- Payroll_Context_Model
- Run_Scope_Model
- Employee_Payroll_Result_Model
- Payroll_Run_Result_Set_Model
- Accumulator_Impact_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Tax_Classification_and_Obligation_Model
- Correction_and_Immutability_Model

## 11. Key Design Principle

Person_ID identifies the human being. Employment_ID identifies the payroll-recognised relationship through which that person is paid. Payroll calculations, balances, results, and exports anchor to Employment_ID; long-lived personal identity continuity anchors to Person_ID.
