# Employee_Event_and_Status_Change_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Employee_Event_and_Status_Change_Model.md` |
| **Domain** | Core |
| **Related Documents** | ADR-001-Event-Driven-Architecture.md, DATA/Entity-Employee.md, Employment_and_Person_Identity_Model, Employee_Assignment_Model, Correction_and_Immutability_Model, Tax_Classification_and_Obligation_Model |

## Purpose

Defines employee lifecycle events and status changes that affect payroll, benefits, tax handling, eligibility, assignment behaviour, and downstream reporting. Establishes a consistent event-driven control layer for employee state transitions.

---

## 1. Event Scope

Employee events include: Hire, Rehire, Termination, Leave of Absence, Return to Work, Status Change, Compensation Change, Location Transfer, Department Transfer, Work State Change, Job Change.

## 2. Core Employee_Event Entity

Employee_Event_ID, Employee_ID, Employment_ID, Event_Type, Event_Date, Effective_Date, Recorded_Date, Event_Status, Event_Reason_Code, Source_Context_ID.

## 3. Event Type Definitions

HIRE, REHIRE, TERMINATION, LEAVE_OF_ABSENCE, RETURN_TO_WORK, STATUS_CHANGE, COMPENSATION_CHANGE, LOCATION_TRANSFER, DEPARTMENT_TRANSFER, WORK_STATE_CHANGE, JOB_CHANGE, POSITION_CHANGE, LEGAL_ENTITY_TRANSFER, MANAGER_CHANGE, VOLUNTARY_RESIGNATION.

## 4. Status Change Model

Employment status attributes that may change: Employment_Status, Full_or_Part_Time_Status, Regular_or_Temporary_Status, Active_or_Inactive_Status, Benefit_Eligibility_Status, Payroll_Eligibility_Status. Status changes must preserve prior state history.

## 5. Effective Dating and Timing

Each event supports: Event_Date, Effective_Date, Payroll_Effective_Date, Benefit_Effective_Date, Tax_Effective_Date. Downstream modules apply changes on their own schedules.

## 6. Event Impact Routing

Examples: Hire triggers initial payroll eligibility and benefit eligibility evaluation. Termination triggers final pay, benefit termination, and continuation eligibility. Work State Change triggers tax jurisdiction update. Compensation Change triggers future payroll recalculation.

## 7. Retroactive Event Handling

Retroactive_Flag, Retroactive_Start_Date, Retroactive_Adjustment_Required, Affected_Payroll_Periods. Retroactive events must not silently alter historical records without traceable corrections.

## 8. Event Sequencing and Dependency

Examples: Return to Work requires prior Leave of Absence. Rehire follows prior Termination. Department Transfer may coincide with Location Transfer. Event sequencing must prevent invalid state transitions.

## 9. Audit and Historical Preservation

All employee events must remain historically preserved: previous state values, new state values, event source, approval or review trail, correction linkage.

## 10. Relationship to Other Models

This model integrates with: Employee_Assignment_Model, Employment_and_Person_Identity_Model, Benefit_and_Deduction_Configuration_Model, Eligibility_and_Enrollment_Lifecycle_Model, Payroll_Check_Model, Tax_Classification_and_Obligation_Model, Correction_and_Immutability_Model.
