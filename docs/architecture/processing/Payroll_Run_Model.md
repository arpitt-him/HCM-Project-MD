# Payroll_Run_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/processing/Payroll_Run_Model.md` |
| **Domain** | Processing |
| **Related Documents** | ADR-002_Deterministic_Replayability.md, Payroll_Context_Model, Payroll_Calendar_Model, Calculation_Run_Lifecycle, Release_and_Approval_Model, Correction_and_Immutability_Model, Run_Scope_Model, Run_Lineage_Model |

## Purpose

Defines the Payroll Run model — the discrete execution event within a Payroll Context and Period. Establishes how runs are identified, classified, started, monitored, restarted, corrected, and closed.

This revision normalizes processing taxonomy by distinguishing:

- operational run type
- scoped population type
- lineage relationship type

This model serves as the authoritative source for run identity and run classification within the processing architecture.

---

## 1. Core Design Principles

Every Payroll Run shall belong to exactly one Payroll Context and one Period_ID. Runs shall be explicitly typed and lifecycle-controlled. Run identity shall remain traceable across reruns and related activity. Payroll Runs shall not exist outside calendar and context boundaries.

Finalized parent runs shall remain immutable. Post-finalization correction activity shall be represented through explicit child runs and additive adjustment results rather than destructive overwrite of historical results.

---

## 2. Payroll Run Definition

A Payroll Run SHALL include at minimum:

- Run_ID
- Payroll_Context_ID
- Period_ID
- Run_Type
- Run_Status
- Pay_Date
- Run_Start_Timestamp
- Run_End_Timestamp (optional)
- Initiated_By
- Parent_Run_ID (optional)
- Root_Run_ID (optional)
- Related_Run_Group_ID (optional)
- Run_Scope_ID (optional)
- Relationship_Type (optional)
- Run_Description (optional)

Run identity SHALL remain stable and auditable across all lifecycle transitions.

---

## 3. Canonical Processing Taxonomy

This model defines three distinct but related processing taxonomies.

### 3.1 Run_Type

Run_Type defines the operational purpose of the run.

Supported Run_Type values:

- INITIAL
- RERUN
- ADJUSTMENT
- SUPPLEMENTAL
- SIMULATION
- CATCH_UP
- RETRO
- RECOVERY

Run_Type SHALL be assigned to every Payroll Run.

---

### 3.2 Scope_Type

Scope_Type defines the population semantics of the run when a Run Scope is present.

Supported Scope_Type values:

- FULL
- CATCH_UP
- RETRO
- RECOVERY

Scope_Type SHALL be governed by Run_Scope_Model and SHALL only apply when Run_Scope_ID is populated.

A run without Run_Scope_ID SHALL be treated as FULL population processing unless explicitly defined otherwise by policy.

---

### 3.3 Relationship_Type

Relationship_Type defines the lineage semantics between a child run and its parent run.

Supported Relationship_Type values:

- CATCH_UP
- RETRO
- RECOVERY
- ADJUSTMENT

Relationship_Type SHALL only apply when Parent_Run_ID is populated.

---

## 4. Taxonomy Mapping Rules

The following rules govern alignment across the three taxonomies.

RULE-RUN-001  
Every Payroll Run SHALL have exactly one Run_Type.

RULE-RUN-002  
Scope_Type SHALL only be present or derivable when Run_Scope_ID exists.

RULE-RUN-003  
Relationship_Type SHALL only be present when Parent_Run_ID exists.

RULE-RUN-004  
A post-finalization child run SHALL preserve additive correction semantics.

RULE-RUN-005  
Run_Type, Scope_Type, and Relationship_Type SHALL be internally consistent.

---

### 4.1 Expected Mapping Patterns

| Operational Scenario | Run_Type | Scope_Type | Relationship_Type |
|---|---|---|---|
| Standard payroll execution | INITIAL | FULL | N/A |
| Pre-finalization rerun | RERUN | FULL | N/A or ADJUSTMENT |
| Post-finalization catch-up correction | CATCH_UP | CATCH_UP | CATCH_UP |
| Post-finalization retro correction | RETRO | RETRO | RETRO |
| Post-finalization recovery run | RECOVERY | RECOVERY | RECOVERY |
| Additive financial correction without scoped population | ADJUSTMENT | FULL or N/A | ADJUSTMENT |
| Non-production modelling | SIMULATION | FULL or scoped | N/A |

These mappings SHALL guide reporting, replay, approval routing, and downstream integration behavior.

---

## 5. Run Status Lifecycle

The Payroll Run status lifecycle is:

Defined → Ready → In Progress → Completed / Completed with Exceptions → Awaiting Approval → Approved → Released → Failed → Closed

Status transitions shall remain auditable and SHALL be governed together with Calculation_Run_Lifecycle and related state models.

---

## 6. Payroll Calendar Linkage

Every run references a valid payroll calendar entry through Payroll_Context_ID and Period_ID. Pay_Date and all processing deadlines are inherited from the calendar entry.

All reruns, scoped child runs, and additive correction runs SHALL remain anchored to the applicable payroll calendar context unless an explicit policy-approved exception exists.

---

## 7. Parent and Root Run Linkage

Parent_Run_ID identifies the immediate parent run when the current run is a post-finalization child run.

Root_Run_ID identifies the first finalized run in the lineage chain.

The following rules apply:

RULE-RUN-006  
A child run SHALL reference exactly one immediate Parent_Run_ID.

RULE-RUN-007  
All descendant child runs SHALL preserve referenceability to the Root_Run_ID.

RULE-RUN-008  
Parent-child linkage SHALL be explicit and auditable.

These references SHALL support replay reconstruction, correction lineage tracing, and audit review.

---

## 8. Pre-Finalization Reruns

A pre-finalization rerun is a rerun performed before the original run has been finalized and released.

Pre-finalization reruns:

- reference the same calendar entry
- may supersede prior in-flight calculation results
- preserve auditable linkage to earlier attempts
- shall not create conflicting released financial results

Because the prior run is not finalized, supersession is permitted at the in-flight result level.

---

## 9. Post-Finalization Child Runs

A post-finalization child run is any run executed after its parent run has been finalized.

These include:

- CATCH_UP
- RETRO
- RECOVERY
- ADJUSTMENT

Post-finalization child runs:

- SHALL reference Parent_Run_ID
- MAY reference Root_Run_ID
- SHALL preserve immutable parent results
- SHALL generate additive results only
- SHALL participate in explicit lineage sequencing

Post-finalization child runs SHALL NOT destructively replace finalized historical postings.

---

## 10. Run Isolation

Each run is isolated to its Payroll_Context_ID. Cross-context contamination is not permitted. Run failures in one context do not affect other contexts.

Where Run_Scope_ID exists, the scope SHALL act as an additional containment boundary. Scope-level failures SHALL be handled according to Error_Handling_and_Isolation_Model and SHALL NOT invalidate unrelated contexts or finalized parent runs.

---

## 11. Approval and Release Implications

Standard runs, scoped child runs, and additive correction runs MAY have different approval requirements based on financial impact, risk, and policy.

Release status SHALL indicate the run is authorized for downstream operational consumption.

Post-finalization child runs SHALL follow approval routing appropriate to their Run_Type and Relationship_Type.

---

## 12. Audit and Traceability

All run lifecycle transitions shall be logged with timestamp and actor. Run records shall be retained per the Data_Retention_and_Archival_Model.

At minimum, auditability SHALL support:

- run identity tracing
- parent-child linkage tracing
- root-run tracing
- scope-aware processing tracing
- replay reconstruction support

---

## 13. Relationship to Other Models

This model integrates with:

- Payroll_Context_Model
- Payroll_Calendar_Model
- Calculation_Run_Lifecycle
- Release_and_Approval_Model
- Correction_and_Immutability_Model
- Run_Visibility_and_Dashboard_Model
- Accumulator_and_Balance_Model
- Run_Scope_Model
- Run_Lineage_Model
- Error_Handling_and_Isolation_Model

---

## 14. Cross-Validation Notes

This revision establishes Payroll_Run_Model as the canonical source for processing taxonomy alignment.

Specifically:

- Run_Type expresses operational purpose
- Scope_Type expresses population semantics
- Relationship_Type expresses lineage semantics

These distinctions SHALL govern:

- lifecycle interpretation
- reporting classification
- approval routing
- replay ordering
- correction handling
- exception containment boundaries

---

## End of Document
