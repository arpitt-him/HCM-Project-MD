# Entity — Payroll Run

| Field | Detail |
|---|---|
| **Document Type** | Data Entity Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/DATA/Entity_Payroll_Run.md` |
| **Related Documents** | DATA/Entity_Payroll_Check.md, docs/STATE/STATE-RUN_Payroll_Run.md, docs/architecture/processing/Payroll_Run_Model.md, docs/architecture/processing/Calculation_Run_Lifecycle.md |

## Purpose

Defines the Payroll Run entity — a discrete execution event within a Payroll Context and Period. The Payroll Run is the primary execution anchor for all payroll calculation activity. Every payroll check, result, and accumulator update is traceable to a run.

---

## 1. Design Principles

- Every Payroll Run belongs to exactly one Payroll Context and one Period_ID.
- Runs are explicitly typed and lifecycle-controlled.
- The Pay_Date is inherited from the payroll calendar entry and is immutable even if the run is reprocessed after the original date.
- Run identity remains stable across reruns via Parent_Run_ID linkage.
- Payroll Runs do not exist outside calendar and context boundaries.

---

## 2. Core Attributes

| Attribute | Type | Required | Notes |
|---|---|---|---|
| Run_ID | UUID | Yes | System-generated. Immutable. |
| Payroll_Context_ID | UUID | Yes | The payroll group this run belongs to |
| Period_ID | UUID | Yes | The payroll calendar period |
| Pay_Date | Date | Yes | Inherited from calendar entry; immutable |
| Run_Type | Enum | Yes | See values below |
| Run_Status | Enum | Yes | References STATE-RUN; see values below |
| Run_Description | String | No | Optional operator notes |
| Parent_Run_ID | UUID | No | Links correction or rerun to original |
| Related_Run_Group_ID | UUID | No | Groups related supplemental or adjustment runs |
| Rule_and_Config_Version_Reference | String | No | Snapshot of configuration version used |
| Initiated_By | UUID | Yes | User or system that created the run |
| Run_Start_Timestamp | Datetime | No | When calculation began |
| Run_End_Timestamp | Datetime | No | When calculation completed |
| Created_By | UUID | Yes | |
| Creation_Timestamp | Datetime | Yes | System-generated |
| Last_Updated_By | UUID | Yes | |
| Last_Update_Timestamp | Datetime | Yes | |

---

## 3. Run_Type Values

| Value | Description |
|---|---|
| REGULAR | Standard scheduled payroll run |
| ADJUSTMENT | Post-run adjustment for corrections |
| CORRECTION | Correction of a prior run |
| REPROCESSING | Rerun of a failed or partial run |
| SUPPLEMENTAL | Additional run for bonuses or off-cycle payments |
| SIMULATION | Test run; produces no durable results |

---

## 4. Run_Status Values (references STATE-RUN)

| Value | STATE-RUN Reference |
|---|---|
| CREATED | STATE-RUN-001 |
| OPEN | STATE-RUN-002 |
| VALIDATING | STATE-RUN-003 |
| VALIDATION_FAILED | STATE-RUN-004 |
| READY_FOR_CALCULATION | STATE-RUN-005 |
| CALCULATING | STATE-RUN-006 |
| CALCULATION_FAILED | STATE-RUN-007 |
| CALCULATED | STATE-RUN-008 |
| IN_REVIEW | STATE-RUN-009 |
| READY_FOR_APPROVAL | STATE-RUN-010 |
| APPROVAL_PENDING | STATE-RUN-011 |
| APPROVED | STATE-RUN-012 |
| EXECUTING | STATE-RUN-013 |
| EXECUTION_FAILED | STATE-RUN-014 |
| COMPLETED | STATE-RUN-015 |
| POST_PROCESSING | STATE-RUN-016 |
| CLOSED | STATE-RUN-017 |
| REOPENED | STATE-RUN-018 |
| REVERSED | STATE-RUN-019 |

---

## 5. Relationships

| Relationship | Cardinality | Notes |
|---|---|---|
| Payroll Run → Payroll Context | Many-to-one | |
| Payroll Run → Calendar Period | Many-to-one | |
| Payroll Run → Payroll Checks | One-to-many | Each run produces one check per employee |
| Payroll Run → Parent Run | Many-to-one | Optional; for corrections and reruns |

---

## 6. Governance

- Runs are created through platform-controlled workflows; direct creation is not permitted.
- Run_Status may only advance through valid STATE-RUN transitions.
- Closed and Reversed runs are immutable; corrections require new run records.
- All run lifecycle transitions are audit-logged with timestamp and actor.

---

## 7. Related Architecture Models

| Model | Relevance |
|---|---|
| Payroll_Run_Model | Full run lifecycle and isolation rules |
| Calculation_Run_Lifecycle | Stage-by-stage processing detail |
| Payroll_Context_Model | Context and calendar linkage |
| Release_and_Approval_Model | Approval and release governance |
