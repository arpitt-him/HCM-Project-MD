# Async_Job_Execution_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/processing/Async_Job_Execution_Model.md` |
| **Domain** | Processing |
| **Related Documents** | PRD-0100_Architecture_Principles, Payroll_Run_Model, Run_Scope_Model, Run_Visibility_and_Dashboard_Model, Monitoring_and_Alerting_Model, Exception_and_Work_Queue_Model, Error_Handling_and_Isolation_Model, Integration_and_Data_Exchange_Model, Security_and_Access_Control_Model, Time_Entry_and_Worked_Time_Model, Benefit_Deduction_Election_Model, Payroll_Adjustment_and_Correction_Model |

---

## Purpose

Defines the architecture for asynchronous job execution — the platform's mechanism for ensuring that long-running, resource-intensive, or computationally heavy operations execute on a dedicated processing tier, isolated from the UI request/response cycle, so that interactive user experience is not degraded by background processing activity.

Any operation that is not expected to complete within a UI-acceptable response time shall be executed as an async job. The submitting UI or API caller receives an immediate acknowledgement containing a Job_ID and can subsequently poll for status or receive status events via the dashboard.

Status events from async jobs feed into the `Run_Visibility_and_Dashboard_Model` and `Monitoring_and_Alerting_Model`, providing operators with live progress visibility without requiring the UI to block.

This model governs the job entity structure, submission pattern, status lifecycle, progress reporting, error handling, and the classification of which platform operations must use async execution.

---

## 1. Core Design Principles

**Long-running operations shall never execute synchronously in the UI request/response cycle.** A UI action that submits a payroll run, triggers a batch import, or initiates a bulk correction shall return immediately with a Job_ID. The actual work executes on the background processing tier.

**The UI shall always have a way to know what is happening.** Job status shall be queryable at any time via the Job_ID. Status transitions shall be published as events to the dashboard. No job shall silently succeed or fail.

**Jobs shall be isolated from each other.** A failed or slow job shall not delay or corrupt another job executing concurrently. Resource contention shall be managed by the job scheduler, not by individual jobs.

**Jobs shall be retry-safe.** Where a job fails mid-execution, it shall be retryable without producing duplicate results. Job design shall account for idempotency at the operation level.

**Jobs shall be auditable.** Every job submission, status transition, progress event, and completion or failure shall be recorded with actor identity and timestamp.

---

## 2. Operations That Require Async Execution

The following platform operations shall always execute as async jobs:

### Payroll Processing
- Payroll run initiation and calculation (all run types: REGULAR, SUPPLEMENTAL, ADJUSTMENT, CORRECTION)
- Run scope processing
- Post-calculation validation phase
- Payroll run approval and release

### Batch Imports
- Employee record batch import (INT-HRS-003)
- Time entry batch import (INT-TIM-001)
- Benefit deduction election batch import (INT-BEN-001)
- External earnings import (INT-PAY-001)
- Legal order batch submission (INT-GAR-001)

### Bulk Operations
- Bulk retroactive correction processing
- Bulk accumulator recalculation
- Mass employment lifecycle events (e.g. organisation restructure affecting large populations)

### Exports and Transmissions
- ACH payment file generation and transmission (INT-EXP-001)
- GL journal entry export (INT-EXP-002)
- Tax filing export (INT-EXP-003)
- Provider/carrier billing export (INT-EXP-004)

### Reporting
- Any built-in report whose result set exceeds a configurable row threshold (default: 10,000 rows)
- All user-defined reports (future — Reporting advanced module)

Operations not listed above may execute synchronously unless their observed execution time under load warrants promotion to async.

---

## 3. Core Job Entity

A **Platform_Job** record is created for every async operation submitted to the background processing tier.

### Primary Attributes

| Field | Type | Description |
|---|---|---|
| Job_ID | UUID | Unique identifier. System-generated. Returned to the caller immediately on submission. |
| Job_Type | Enum | See §4 |
| Job_Status | Enum | See §5 |
| Tenant_ID | UUID | The tenant context in which the job executes |
| Submitted_By | String | Identity of the operator or system that submitted the job |
| Submitted_Timestamp | Datetime | When the job was received by the platform |
| Started_Timestamp | Datetime | When the background processor began execution |
| Completed_Timestamp | Datetime | When the job reached a terminal state |
| Source_Entity_Type | String | The type of entity that triggered the job (e.g. Payroll_Run, Batch_Import) |
| Source_Entity_ID | UUID | The ID of the triggering entity |
| Progress_Percent | Integer | 0–100. Updated by the job as it progresses. |
| Progress_Message | String | Human-readable status message. Updated during execution. |
| Total_Records | Integer | Total records to process where applicable |
| Processed_Records | Integer | Records processed so far |
| Failed_Records | Integer | Records that failed processing |
| Result_Reference_ID | UUID | Reference to the primary output artifact on completion (e.g. Payroll_Run_Result_Set_ID, Import_Result_ID) |
| Error_Summary | String | High-level error description on failure |
| Retry_Count | Integer | Number of retry attempts made |
| Max_Retries | Integer | Configured maximum retries for this job type |
| Priority | Enum | CRITICAL, HIGH, NORMAL, LOW |
| Created_Timestamp | Datetime | Record creation timestamp |
| Updated_Timestamp | Datetime | Last update timestamp |

---

## 4. Job Types

| Job_Type | Description | Priority |
|---|---|---|
| PAYROLL_RUN_CALCULATION | Full payroll calculation for a run | CRITICAL |
| PAYROLL_RUN_VALIDATION | Post-calculation validation phase | CRITICAL |
| PAYROLL_RUN_APPROVAL | Approval workflow execution for a run | HIGH |
| PAYROLL_RUN_RELEASE | Payment release and export initiation | CRITICAL |
| RUN_SCOPE_EXECUTION | Scoped population processing | HIGH |
| BATCH_EMPLOYEE_IMPORT | Employee record batch import | HIGH |
| BATCH_TIME_ENTRY_IMPORT | Time entry batch import | HIGH |
| BATCH_BENEFIT_ELECTION_IMPORT | Benefit deduction election batch import | HIGH |
| BATCH_EXTERNAL_EARNINGS_IMPORT | External earnings batch import | HIGH |
| BATCH_LEGAL_ORDER_IMPORT | Legal order batch submission | HIGH |
| BULK_RETRO_CORRECTION | Bulk retroactive correction processing | HIGH |
| BULK_ACCUMULATOR_RECALC | Bulk accumulator recalculation | NORMAL |
| BULK_LIFECYCLE_EVENT | Mass employment lifecycle event | NORMAL |
| EXPORT_ACH | ACH payment file generation and transmission | CRITICAL |
| EXPORT_GL | GL journal entry export | HIGH |
| EXPORT_TAX_FILING | Tax filing export | HIGH |
| EXPORT_PROVIDER_BILLING | Provider/carrier billing export | NORMAL |
| REPORT_GENERATION | Large built-in report generation | NORMAL |
| REPORT_USER_DEFINED | User-defined report execution (future) | LOW |

---

## 5. Job Status Lifecycle

| Status | Description | Terminal? |
|---|---|---|
| QUEUED | Job received and queued; not yet started | No |
| RUNNING | Actively executing on the background tier | No |
| PAUSED | Execution temporarily suspended (e.g. awaiting approval gate) | No |
| COMPLETED | Executed successfully | Yes |
| FAILED | Execution failed; retry may be available | No |
| FAILED_PERMANENT | Execution failed; max retries exhausted or non-retryable error | Yes |
| CANCELLED | Cancelled by operator before or during execution | Yes |
| RETRYING | Previous attempt failed; queued for retry | No |

**Terminal states:** COMPLETED, FAILED_PERMANENT, CANCELLED.

### Key Transitions

| From | To | Trigger |
|---|---|---|
| QUEUED | RUNNING | Background processor picks up the job |
| RUNNING | COMPLETED | Job executes successfully |
| RUNNING | PAUSED | Job reaches a gate requiring external input (e.g. approval) |
| PAUSED | RUNNING | Gate condition resolved |
| RUNNING | FAILED | Unrecoverable error during execution |
| FAILED | RETRYING | Retry policy permits another attempt |
| RETRYING | RUNNING | Background processor picks up retry |
| FAILED | FAILED_PERMANENT | Max retries exhausted or error classified as non-retryable |
| QUEUED / RUNNING / PAUSED | CANCELLED | Operator cancels the job |

---

## 6. Submission Pattern

**REQ-AJE-001**
All async job submissions shall return an immediate HTTP 202 Accepted response containing the Job_ID, current Job_Status (QUEUED), and a status polling URL. The response shall never block on job completion.

**REQ-AJE-002**
The caller shall use the Job_ID to poll for status via a governed status endpoint, or to subscribe to job status events via the dashboard event stream.

**REQ-AJE-003**
The status endpoint shall return the current Job_Status, Progress_Percent, Progress_Message, Processed_Records, Failed_Records, and Result_Reference_ID (when COMPLETED) for any Job_ID within the caller's authorised scope.

**REQ-AJE-004**
Status polling shall be rate-limited per caller. The recommended polling interval is configurable and shall be communicated in the submission response. Default: 5 seconds.

**REQ-AJE-005**
Job status events shall be published to the `Run_Visibility_and_Dashboard_Model` at each status transition and at configurable progress intervals (default: every 10% progress increment or every 60 seconds, whichever occurs first).

---

## 7. Progress Reporting

**REQ-AJE-010**
Jobs that process a known record set (batch imports, payroll runs, bulk corrections) shall report Progress_Percent, Processed_Records, and Failed_Records at a configurable update frequency.

**REQ-AJE-011**
Progress updates shall be visible in the dashboard without the operator needing to refresh or poll manually. Dashboard status shall reflect job progress within 10 seconds of each progress event.

**REQ-AJE-012**
On completion, the job shall publish a terminal status event containing Result_Reference_ID, total Processed_Records, total Failed_Records, and elapsed duration.

---

## 8. Error Handling and Retry

**REQ-AJE-020**
A job that encounters a recoverable error shall transition to FAILED and be eligible for retry according to its configured retry policy. The error details shall be recorded in the Platform_Job record and surfaced in the dashboard.

**REQ-AJE-021**
Retry attempts shall be idempotent. A retry shall not produce duplicate results for records that were successfully processed in a prior attempt.

**REQ-AJE-022**
Each job type shall have a configured maximum retry count. Jobs that exhaust retries shall transition to FAILED_PERMANENT and route to the operator work queue via `Exception_and_Work_Queue_Model`.

**REQ-AJE-023**
Non-retryable errors (e.g. data validation failures, schema errors) shall cause immediate transition to FAILED_PERMANENT without consuming retry attempts.

**REQ-AJE-024**
Partial completion shall be supported for batch import jobs. Records that fail validation shall be collected and reported in a failed-record summary without preventing successfully validated records from posting.

---

## 9. Priority and Scheduling

**REQ-AJE-030**
The background processing tier shall support job prioritisation. CRITICAL jobs shall be scheduled ahead of HIGH, NORMAL, and LOW jobs when resources are constrained.

**REQ-AJE-031**
Payroll deadline proximity shall be a factor in dynamic priority adjustment. A NORMAL-priority export job approaching a statutory deadline may be elevated to CRITICAL by the scheduler.

**REQ-AJE-032**
Job scheduling shall be tenant-isolated. A resource-intensive job in Tenant A shall not starve jobs in Tenant B.

---

## 10. Access Control

**REQ-AJE-040**
Job submission shall require the same role and scope permissions as the operation being submitted. Submitting a payroll run requires Payroll_Operator or higher. Submitting a batch import requires the relevant import permission.

**REQ-AJE-041**
Job status queries shall be scoped to the submitting user's authorised tenant, client, and operational scope. A user shall not query the status of jobs outside their scope.

**REQ-AJE-042**
Job cancellation shall require the same or higher permission level as job submission. Cancellation of a running payroll job shall require Payroll_Supervisor or higher.

---

## 11. Integration with Dashboard and Monitoring

**REQ-AJE-050**
All job status transitions shall publish events to the `Run_Visibility_and_Dashboard_Model`. The dashboard shall reflect the current state of all active and recently completed jobs within the operator's scope.

**REQ-AJE-051**
Jobs in FAILED or FAILED_PERMANENT status shall generate alerts in the `Monitoring_and_Alerting_Model` with severity appropriate to the job type and operational impact.

**REQ-AJE-052**
CRITICAL-priority jobs that remain in QUEUED state beyond a configurable threshold shall generate a Queue Delay Alert in the `Monitoring_and_Alerting_Model`.

**REQ-AJE-053**
The dashboard shall display per-job progress including Job_Type, Job_Status, Progress_Percent, Processed_Records, Failed_Records, and elapsed time for all active jobs within scope.

---

## 12. Audit Requirements

**REQ-AJE-060**
Every job submission, status transition, progress event, and terminal state shall be recorded in the audit log with Job_ID, actor identity, timestamp, and state transition detail.

**REQ-AJE-061**
Audit records for jobs shall be retained for a minimum of seven years, consistent with `Data_Retention_and_Archival_Model`, to support post-incident review and regulatory audit.

---

## 13. Relationship to Other Models

| Model | Relationship |
|---|---|
| Payroll_Run_Model | Payroll run calculation and release execute as async jobs; Run_ID is the Source_Entity_ID for payroll run jobs |
| Run_Scope_Model | Scoped execution runs execute as async jobs |
| Run_Visibility_and_Dashboard_Model | Receives all job status events for operator visibility |
| Monitoring_and_Alerting_Model | Receives failure and delay alerts from the job execution tier |
| Exception_and_Work_Queue_Model | Receives FAILED_PERMANENT jobs for operator investigation and resolution |
| Error_Handling_and_Isolation_Model | Governs error classification and isolation behaviour within job execution |
| Integration_and_Data_Exchange_Model | Batch imports execute as async jobs; import job outcomes feed back to the integration layer |
| Time_Entry_and_Worked_Time_Model | Batch time entry import executes as an async job |
| Benefit_Deduction_Election_Model | Batch benefit election import executes as an async job |
| Payroll_Adjustment_and_Correction_Model | Bulk retroactive corrections execute as async jobs |
| Security_and_Access_Control_Model | Governs job submission, status query, and cancellation permissions |
| Data_Retention_and_Archival_Model | Governs audit log retention for job records |
| Operational_Reporting_and_Analytics_Model | Large report generation executes as an async job above the configured row threshold |
