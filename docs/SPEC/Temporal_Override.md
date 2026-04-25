# SPEC — Temporal Override

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/Temporal_Override.md` |
| **Related Documents** | PRD-0100_Architecture_Principles, Configuration_and_Metadata_Management_Model, Tenant_Data_Model, Security_and_Access_Control_Model, Payroll_Calendar_Model, Multi_Context_Calendar_Model, Correction_and_Immutability_Model |

---

## Purpose

Defines the requirements governing the Temporal Override capability — the ability to displace the platform's operative current date forward in time within a single tenant, without changing any server or infrastructure date, for the purpose of testing date-sensitive behaviour.

Every date-sensitive process in the platform — payroll period resolution, accumulator resets, effective-date enforcement, jurisdiction rule lookups, calendar period boundaries, leave accrual, wage base threshold application — depends on what the platform believes today's date to be. Without a governed mechanism to advance that date, testing year-end behaviour, plan-year resets, multi-period scenarios, and future-effective configuration requires waiting for calendar time to pass or manipulating server infrastructure, both of which are unacceptable in a professional testing context.

Temporal Override addresses this by establishing a **governed operative date** as the authoritative source of current date for all platform processes within a tenant, replacing direct system clock consumption. In normal operation the governed operative date resolves to the real current date. When an override is active, it resolves to the configured displacement date instead.

This capability is unavailable in production environments.

---

## 1. User Stories

**QA Engineer** needs to **advance the operative date to December 31 within a test tenant** in order to **verify that year-end accumulator resets, wage base threshold resets, and tax year transitions execute correctly without waiting for the calendar year to end.**

**Implementation Consultant** needs to **simulate multiple payroll periods in sequence within a client test tenant** in order to **validate that period-over-period accumulator behaviour, YTD totals, and pay statement values are correct before go-live.**

**Platform Developer** needs to **test future-effective configuration changes by advancing the operative date past their effective dates** in order to **confirm that rule versioning, jurisdiction updates, and compensation changes activate at the correct time.**

**QA Engineer** needs to **reset the operative date back to the real current date** in order to **restore normal platform behaviour after temporal testing is complete.**

---

## 2. Scope Boundaries

### In Scope — v1

**REQ-TMP-001**
The platform shall support a governed operative date that serves as the authoritative current date for all date-sensitive processes within a tenant.

**REQ-TMP-002**
The governed operative date shall be configurable at the tenant level. An override applied to Tenant A shall have no effect on Tenant B.

**REQ-TMP-003**
When no override is active, the governed operative date shall resolve to the real current date from the platform's system clock.

**REQ-TMP-004**
When an override is active, the governed operative date shall resolve to the configured displacement date for all processes within the tenant.

**REQ-TMP-005**
Temporal Override shall be restricted to non-production environments. The capability shall be gated by an environment classification flag on the tenant or deployment configuration. A tenant classified as Production shall not permit override activation under any circumstances.

**REQ-TMP-006**
The displacement date shall be permitted to be any date in the future relative to the real current date. Displacement to a date in the past shall not be permitted.

**REQ-TMP-007**
Advancing the operative date forward shall be permitted at any time while an override is active. Reversing the operative date backward — other than resetting to the real current date — shall not be permitted.

**REQ-TMP-008**
The override shall be resettable to the real current date at any time by an authorised operator.

### Out of Scope — v1

**REQ-TMP-009**
Temporal Override is not available in Production environments under any circumstances, including emergency or exceptional scenarios.

**REQ-TMP-010**
Displacement to a date in the past is not supported. Historical state reconstruction uses the correction and replay model, not temporal override.

**REQ-TMP-011**
Sub-day time-of-day displacement (advancing by hours or minutes rather than whole days) is out of scope for v1.

**REQ-TMP-012**
Automated time advancement (scheduling the operative date to advance on a timer without operator action) is out of scope for v1.

---

## 3. The Governed Operative Date

**REQ-TMP-020**
All platform processes that require knowledge of the current date shall consume the governed operative date from a single authoritative resolution function. Direct consumption of the system clock (`Date.now()`, `System.currentDate()`, or equivalent) is not permitted in any module.

**REQ-TMP-021**
The governed operative date resolution function shall accept a Tenant_ID and return the effective current date for that tenant — either the real date or the override date, depending on override state.

**REQ-TMP-022**
The following processes shall consume the governed operative date:

- Payroll period resolution and calendar period boundary evaluation
- Accumulator reset trigger evaluation
- Effective-date enforcement for all records (employment, compensation, rules, configuration)
- Jurisdiction rule version selection
- Leave accrual trigger evaluation
- Wage base threshold reset evaluation
- Deduction election effective date enforcement
- Time entry payroll period assignment
- Document expiration date evaluation
- Any scheduled job or batch process that evaluates date-based eligibility

**REQ-TMP-023**
Date values written to the database as a result of processes that ran under an override shall reflect the governed operative date, not the real system clock date. This is intentional — it allows test runs and records to have realistic date values consistent with the scenario being tested.

---

## 4. Override Configuration Entity

The Temporal Override state for a tenant is stored as a governed configuration record.

### Core Fields

| Field | Type | Description |
|---|---|---|
| Override_ID | UUID | Unique identifier. System-generated. |
| Tenant_ID | UUID | The tenant to which this override applies |
| Override_Status | Enum | INACTIVE, ACTIVE |
| Override_Date | Date | The displacement date. Null when INACTIVE. |
| Activated_By | String | Identity of the operator who activated the override |
| Activated_Timestamp | Datetime | When the override was activated |
| Last_Advanced_By | String | Identity of the operator who last advanced the date |
| Last_Advanced_Timestamp | Datetime | When the date was last advanced |
| Deactivated_By | String | Identity of the operator who deactivated the override |
| Deactivated_Timestamp | Datetime | When the override was reset to real date |

**REQ-TMP-030**
Each tenant shall have at most one Override record. Override activation updates the existing record; it does not create a new one.

**REQ-TMP-031**
The Override record shall be retained after deactivation. It shall not be deleted. This preserves the history of when overrides were active and what dates were used.

---

## 5. Access Control

**REQ-TMP-040**
Activating, advancing, and deactivating a Temporal Override shall require a dedicated role or permission that is distinct from standard operator roles. This permission shall not be included in any default role assignment.

**REQ-TMP-041**
The Temporal Override permission shall not be assignable in a Production-classified tenant or deployment. Attempts to assign it in a production context shall be rejected.

**REQ-TMP-042**
All override activation, advancement, and deactivation actions shall be recorded in the platform audit log with actor identity, timestamp, prior date value, and new date value.

---

## 6. Interaction with Payroll Runs

**REQ-TMP-050**
A payroll run initiated while a Temporal Override is active shall use the governed operative date for all date-dependent calculations within that run — period resolution, rule version selection, accumulator reset evaluation, and effective-date enforcement.

**REQ-TMP-051**
Payroll results, accumulator contributions, and disbursement records produced under an override shall carry the governed operative dates that were in effect at calculation time. These are test records and their dates will reflect the test scenario.

**REQ-TMP-052**
The Payroll_Run record shall record whether a Temporal Override was active at the time of run initiation, and what the Override_Date was. This supports post-test analysis and distinguishes test runs from production runs in shared non-production environments.

---

## 7. Environment Classification Gate

**REQ-TMP-060**
The platform deployment configuration shall include an Environment_Classification field with at minimum the values: PRODUCTION, NON_PRODUCTION.

**REQ-TMP-061**
Temporal Override activation shall be blocked at the platform level when Environment_Classification is PRODUCTION. This check shall occur in the platform infrastructure layer, not only in the application layer, so that it cannot be bypassed by application-level configuration changes.

**REQ-TMP-062**
The Environment_Classification shall be set at deployment time and shall require a deployment-level change to modify. It shall not be changeable by tenant operators or platform administrators operating within the application.

---

## 8. Relationship to Other Models and Documents

| Document | Relationship |
|---|---|
| Configuration_and_Metadata_Management_Model | Governs how the Override configuration record is stored, validated, and made available to the platform |
| Tenant_Data_Model | Override is scoped to a single tenant; Tenant_ID is the primary key for override resolution |
| Security_and_Access_Control_Model | Governs the dedicated permission required to activate and manage overrides |
| Payroll_Calendar_Model | Payroll period and pay date resolution consumes the governed operative date |
| Multi_Context_Calendar_Model | All calendar context evaluations consume the governed operative date |
| Correction_and_Immutability_Model | Temporal Override does not affect immutability rules; locked records remain locked regardless of operative date |
| PRD-0100_Architecture_Principles | The governed operative date principle shall be referenced as an architectural constraint applicable to all modules |

---

## 9. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-TMP-001 | All date-sensitive processes in the platform consume the governed operative date. A grep or static analysis of the codebase finds no direct system clock calls in business logic. |
| REQ-TMP-002 | Activating an override on Tenant A and advancing its date to December 31 does not change the operative date experienced by any process running under Tenant B. |
| REQ-TMP-005 | Attempting to activate a Temporal Override on a tenant classified as PRODUCTION returns an error and does not activate the override. |
| REQ-TMP-006 | Attempting to set an Override_Date in the past returns a validation error. The override is not activated. |
| REQ-TMP-007 | Attempting to advance the Override_Date to a date earlier than the current Override_Date returns a validation error. The date is not changed. |
| REQ-TMP-020 | A payroll run initiated with Override_Date = December 31 correctly evaluates YTD accumulator reset logic as if it were December 31, producing reset balances in the new period. |
| REQ-TMP-023 | Records created during a payroll run under an active override carry date values consistent with the Override_Date, not the real system clock date. |
| REQ-TMP-031 | After deactivation, the Override record remains queryable and shows the full history of activation, advancement, and deactivation events. |
| REQ-TMP-040 | A standard payroll operator cannot activate or advance a Temporal Override. The action is rejected with an authorisation error. |
| REQ-TMP-052 | The Payroll_Run record for a run executed under an override includes the Override_Date that was active at initiation time. |
| REQ-TMP-061 | The environment classification gate blocking production override cannot be bypassed by any application-level setting, role assignment, or API call. |

---

## 10. Non-Functional Requirements

**REQ-TMP-070**
The governed operative date resolution function shall add no more than 1 millisecond of latency per call under normal operating conditions. It shall not be a performance bottleneck in high-frequency calculation loops.

**REQ-TMP-071**
Override state shall be cached per tenant with a maximum staleness of 1 second. Platform processes shall not query the override configuration record on every date resolution call.

**REQ-TMP-072**
Override activation and deactivation shall take effect within 5 seconds of the operator action for all processes running within the affected tenant.
