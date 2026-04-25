# ADR-005 — Background Job Execution Mechanism: .NET IHostedService

| Field | Detail |
|---|---|
| **Document Type** | Architecture Decision Record |
| **Version** | v0.1 |
| **Status** | Accepted |
| **Owner** | Core Platform |
| **Location** | `docs/ADR/ADR-005_Background_Job_Execution.md` |
| **Date** | April 2026 |
| **Related Documents** | PRD-0100_Architecture_Principles, ADR-003_UI_Technology_Stack, ADR-004_Data_Access_Strategy, docs/architecture/processing/Async_Job_Execution_Model.md, docs/architecture/operations/Run_Visibility_and_Dashboard_Model.md |

---

## Context

The platform requires a background job execution mechanism to satisfy the Async Job Execution Model — the architectural requirement that long-running operations (payroll runs, batch imports, bulk corrections, exports) execute on a background processing tier without blocking the UI request/response cycle.

Two distinct concerns needed to be addressed:

**Concern 1 — Reliable background execution:** Jobs must execute asynchronously, survive application restarts, support retry on failure, and be isolated from each other. Multiple concurrent jobs must be supportable without one blocking another.

**Concern 2 — Maximum operator visibility:** A payroll administrator monitoring a live payroll run needs rich, real-time progress information — percentage complete, records processed, records failed, current step, elapsed time. This was identified as the primary concern. An operator watching a payroll run for 250 or 5,000 employees needs to know exactly what is happening at every point. Coarse job state (running / not running) is not sufficient.

The Async Job Execution Model already defines the `Platform_Job` entity with the full set of progress fields (`Progress_Percent`, `Progress_Message`, `Processed_Records`, `Failed_Records`, `Total_Records`) and specifies that progress updates must be visible to the operator within 10 seconds of each event (REQ-AJE-011).

The platform is built on .NET Core with Blazor Server as the UI framework (ADR-003) and Dapper over ADO.NET for data access (ADR-004). The deployment model requires on-premises portability with no mandatory external infrastructure dependencies.

Third-party job scheduling libraries — Hangfire and Quartz.NET — were evaluated. Both were rejected.

---

## Decision

**Background job execution shall use .NET Core's built-in `IHostedService` / `BackgroundService` as the execution mechanism.**

**The `platform_job` database table shall be the authoritative source of truth for all job state and progress information.**

**Blazor Server's existing SignalR connection shall be used to push job progress updates to the operator dashboard in real time — no separate polling infrastructure is required.**

### How It Works

**Job submission:** When an operator initiates a payroll run, batch import, or other async operation, the application:
1. Writes a `Platform_Job` record to the database with status `QUEUED` and all available metadata
2. Returns the `Job_ID` immediately to the caller
3. Enqueues the job reference to an in-memory channel (`System.Threading.Channels.Channel<T>`)

**Job execution:** A `BackgroundService` reads from the channel and executes jobs. During execution the job writes progress updates directly to the `platform_job` table — `Progress_Percent`, `Processed_Records`, `Failed_Records`, `Progress_Message` — at meaningful intervals. On completion or failure it writes the terminal state.

**Operator visibility:** A SignalR hub monitors the `platform_job` table and pushes updates to connected Blazor dashboard components whenever job state or progress changes. The operator sees a live, richly detailed view of every running job with no manual refresh required. This uses the same SignalR connection infrastructure that Blazor Server already maintains — no additional connection or polling mechanism is needed.

**Restart recovery:** On application startup, the `BackgroundService` queries the `platform_job` table for any jobs in `QUEUED` or `RUNNING` state that did not reach a terminal state. These are requeued automatically. This provides restart resilience without requiring an external job store.

---

## Why Not a Third-Party Library

**Hangfire** was evaluated. Hangfire handles job scheduling and execution reliably and persists jobs to a database. It was rejected for two reasons. First, its built-in job state model (Enqueued / Processing / Succeeded / Failed) is too coarse — it has no native concept of percentage complete, records processed, or mid-job progress messages. Achieving the operator visibility required by REQ-AJE-010 and REQ-AJE-011 requires implementing a separate progress layer on top of Hangfire anyway, which means Hangfire's scheduling machinery is present without contributing to the primary concern. Second, Hangfire's built-in dashboard is a developer tool — it is not tenant-scoped, not styled to the product, and not suitable for production operator use. A custom Blazor dashboard would be required regardless.

**Quartz.NET** was evaluated. Quartz.NET is the .NET port of the Java Quartz scheduler and offers sophisticated trigger, calendar, and misfire handling. It was rejected for the same progress visibility reason as Hangfire — it tracks job execution state but has no native concept of mid-job progress reporting. Its scheduling sophistication, while familiar from the Java ecosystem, exceeds what the platform's job execution pattern requires. Most platform jobs are operator-initiated on demand rather than time-scheduled. The few scheduled jobs (automated payroll calendar triggers, year-end processing) are not complex enough to justify the library's full feature set.

**The core insight** that drove both rejections: the primary requirement is not job scheduling — it is operator visibility. The richest source of operator visibility is the `platform_job` table, which the application already owns and writes to. No third-party library can provide better visibility into that table than the application itself. A thin execution mechanism that stays out of the way is preferable to a feature-rich library that imposes its own state model between the job and the operator.

---

## Consequences

**Positive:**
- No third-party dependencies for the execution mechanism — `IHostedService` and `System.Threading.Channels` are part of the .NET Core framework
- Complete control over job progress state — `platform_job` is fully owned by the application; progress fields are written at exactly the granularity the application chooses
- Real-time operator visibility via existing Blazor Server SignalR infrastructure — no additional connection or polling layer
- Tenant-scoped dashboard — the Blazor job dashboard queries `platform_job` with full tenant and role scoping, styled to the product
- DBMS portability maintained — job persistence uses the same Dapper / ADO.NET data access layer as the rest of the application; no separate job store database required
- On-premises deployment friendly — no external message queue, Redis instance, or managed service required

**Constraints to manage:**
- The in-memory `Channel<T>` job queue does not survive application restarts — mitigated by the startup recovery query against `platform_job` for unfinished jobs
- Concurrent job execution is managed by the application rather than a library scheduler — the `BackgroundService` must implement concurrency controls (semaphores, priority queues) explicitly
- There is no built-in misfire handling for time-scheduled jobs — the small number of scheduled jobs (payroll calendar triggers, year-end) must implement their own schedule-check logic on startup
- Job isolation (REQ-AJE design principle) must be implemented explicitly — a long-running job must not starve the channel for other jobs

**Future consideration:**
- If the platform scales to very high concurrent job volumes or requires distributed execution across multiple application instances, an external message broker (RabbitMQ, Azure Service Bus) can be introduced as the channel backing store without changing the `platform_job` table, the progress reporting model, or the Blazor dashboard. The execution mechanism is the only layer that changes.

---

## Alternatives Considered

**Hangfire**
Mature .NET job scheduling library with database-backed persistence. Rejected — coarse built-in state model insufficient for operator visibility requirements; custom progress layer required on top regardless; built-in dashboard not suitable for production operator use; adds a dependency that contributes primarily to scheduling, not to the primary concern of operator visibility.

**Quartz.NET**
.NET port of Java Quartz scheduler. Rejected — same progress visibility gap as Hangfire; scheduling sophistication exceeds platform requirements for mostly on-demand job execution; familiar from Java context but does not justify the added dependency given the gap in native progress reporting.

**Separate .NET Worker Service process**
Background jobs run in a dedicated process separate from the web application. Rejected for v1 — adds operational complexity for on-premises deployments; inter-process communication adds latency to progress updates; the scale profile does not justify the separation. Remains a viable future option if the background processing tier needs to scale independently of the web tier.

**External message queue (RabbitMQ, Azure Service Bus, AWS SQS)**
Most robust option for distributed, high-throughput job execution. Rejected — introduces infrastructure dependencies that conflict with the on-premises portability requirement; the concurrent user and job volume profile does not justify the operational overhead at v1 scale.
