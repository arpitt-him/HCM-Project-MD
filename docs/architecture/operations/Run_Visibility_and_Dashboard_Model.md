# Run_Visibility_and_Dashboard_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/operations/Run_Visibility_and_Dashboard_Model.md` |
| **Domain** | Operations |
| **Related Documents** | Monitoring_and_Alerting_Model, Payroll_Run_Model, Exception_and_Work_Queue_Model, Release_and_Approval_Model, Payroll_Context_Model |

## Purpose

Defines the dashboard and run visibility model used to support operational payroll execution.

Provides real-time and historical insight into payroll progress, risk exposure, exception states, lineage state, and release readiness across multiple clients, companies, payroll contexts, and runs.

Dashboard visibility must remain traceable to the underlying payroll execution artifacts so that operational views are reproducible during audit, replay, and post-incident review.

---

## 1. Core Design Principles

Visibility shall prioritise payroll completion safety. Dashboards shall reflect operational state, not static data. Views shall be role-specific. Visibility shall support multi-client and multi-company operation. Dashboard state shall be auditable and reproducible.

Visibility shall support lineage-aware investigation, including scoped runs, child correction runs, and replay-sensitive execution history.

## 2. Visibility Hierarchy

Enterprise View → Client or Company View → Payroll Context View → Run View → Result Set / Scope View → Run Detail View

## 3. Enterprise-Level Dashboard

Active payroll contexts, contexts at risk, critical alert counts, queue backlog summary, export failure counts, reconciliation delays, external dependency failures.

## 4. Client or Company-Level Dashboard

Active payroll runs, runs awaiting approval, runs awaiting release, queue volumes, deadline risk indicators, reconciliation status.

## 5. Payroll Context Dashboard

Run progress percentage, completed employee count, failed employee count, exception queue counts, retry queue counts, approval readiness, export readiness, reconciliation readiness.

Additional indicators may include:

- blocking exception counts
- scope-level failure indicators
- child-run activity indicators
- release blocker summary

## 6. Run Detail Dashboard

Employment-level processing status, exception details, retry attempts, correction history, processing timestamps, calculation completion markers.

## 7. Role-Based Dashboard Views

Dashboards shall be filtered by operational role. Payroll Operator sees context-level detail. Supervisor sees cross-context summary. Auditor sees read-only historical view.

Role-based filtering shall respect security boundaries, legal-entity boundaries, and operational scope boundaries.

## 7.1 Relationship to Payroll Execution Artifacts

Dashboard views shall be derived from governed payroll execution artifacts, including:

- Payroll_Run_ID
- Payroll_Run_Result_Set_ID
- Employee_Payroll_Result_ID where applicable
- Run_Scope_ID where applicable

This ensures dashboard state reflects actual operational execution state rather than derived or manually maintained summaries.

## 8. Relationship to Other Models

This model integrates with:

- Monitoring_and_Alerting_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Run_Scope_Model
- Run_Lineage_Model
- Exception_and_Work_Queue_Model
- Release_and_Approval_Model
- Payroll_Reconciliation_Model
- Payroll_Provider_Response_Model
- Operational_Reporting_and_Analytics_Model
