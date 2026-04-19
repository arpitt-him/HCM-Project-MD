# Payroll_Run_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/processing/Payroll_Run_Model.md` |
| **Domain** | Processing |
| **Related Documents** | ADR-002-Deterministic-Replayability.md, Payroll_Context_Model, Payroll_Calendar_Model, Calculation_Run_Lifecycle, Release_and_Approval_Model, Correction_and_Immutability_Model |

## Purpose

Defines the Payroll Run model — the discrete execution event within a Payroll Context and Period. Establishes how runs are identified, classified, started, monitored, restarted, corrected, and closed.

---

## 1. Core Design Principles

Every Payroll Run shall belong to exactly one Payroll Context and one Period_ID. Runs shall be explicitly typed and lifecycle-controlled. Run identity shall remain traceable across reruns and related activity. Payroll Runs shall not exist outside calendar and context boundaries.

## 2. Payroll Run Definition

Run_ID, Payroll_Context_ID, Period_ID, Run_Type, Run_Status, Pay_Date, Run_Start_Timestamp, Run_End_Timestamp (optional), Initiated_By, Parent_Run_ID (optional), Related_Run_Group_ID (optional), Run_Description (optional).

## 3. Run Type Classification

Regular Run, Adjustment Run, Correction Run, Reprocessing Run, Supplemental Run, Simulation Run. Run type supports operational routing and reporting.

## 4. Run Status Lifecycle

Defined → Ready → In Progress → Completed / Completed with Exceptions → Awaiting Approval → Approved → Released → Failed → Closed. Status transitions shall remain auditable.

## 5. Payroll Calendar Linkage

Every run references a valid payroll calendar entry through Payroll_Context_ID and Period_ID. Pay_Date and all processing deadlines are inherited from the calendar entry.

## 6. Rerun and Correction Runs

Reruns reference the same calendar entry as the original run. Correction runs may reference a prior run via Parent_Run_ID. All reruns and corrections must preserve traceability to the original.

## 7. Run Isolation

Each run is isolated to its Payroll_Context_ID. Cross-context contamination is not permitted. Run failures in one context do not affect other contexts.

## 8. Audit and Traceability

All run lifecycle transitions shall be logged with timestamp and actor. Run records shall be retained per the Data_Retention_and_Archival_Model.

## 9. Relationship to Other Models

This model integrates with: Payroll_Context_Model, Payroll_Calendar_Model, Calculation_Run_Lifecycle, Release_and_Approval_Model, Correction_and_Immutability_Model, Run_Visibility_and_Dashboard_Model, Accumulator_and_Balance_Model.
