# Run_Visibility_and_Dashboard_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/operations/Run_Visibility_and_Dashboard_Model.md` |
| **Domain** | Operations |
| **Related Documents** | Monitoring_and_Alerting_Model, Payroll_Run_Model, Exception_and_Work_Queue_Model, Release_and_Approval_Model, Payroll_Context_Model |

## Purpose

Defines the dashboard and run visibility model used to support operational payroll execution. Provides real-time insight into payroll progress, risk exposure, exception states, and release readiness across multiple clients, companies, and payroll contexts.

---

## 1. Core Design Principles

Visibility shall prioritise payroll completion safety. Dashboards shall reflect operational state, not static data. Views shall be role-specific. Visibility shall support multi-client and multi-company operation. Dashboard state shall be auditable and reproducible.

## 2. Visibility Hierarchy

Enterprise View → Client or Company View → Payroll Context View → Run Detail View. This hierarchy allows progressive investigation from summary to operational detail.

## 3. Enterprise-Level Dashboard

Active payroll contexts, contexts at risk, critical alert counts, queue backlog summary, export failure counts, reconciliation delays, external dependency failures.

## 4. Client or Company-Level Dashboard

Active payroll runs, runs awaiting approval, runs awaiting release, queue volumes, deadline risk indicators, reconciliation status.

## 5. Payroll Context Dashboard

Run progress percentage, completed employee count, failed employee count, exception queue counts, retry queue counts, approval readiness, export readiness, reconciliation readiness.

## 6. Run Detail Dashboard

Employment-level processing status, exception details, retry attempts, correction history, processing timestamps, calculation completion markers.

## 7. Role-Based Dashboard Views

Dashboards shall be filtered by operational role. Payroll Operator sees context-level detail. Supervisor sees cross-context summary. Auditor sees read-only historical view.

## 8. Relationship to Other Models

This model integrates with: Monitoring_and_Alerting_Model, Payroll_Run_Model, Exception_and_Work_Queue_Model, Release_and_Approval_Model, Operational_Reporting_and_Analytics_Model.
