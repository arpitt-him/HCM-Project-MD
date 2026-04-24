# PRD-900 — Integration Model

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Integration Model |
| **Version** | v0.2 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0900_Integration_Model.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §14 |
| **Related Documents** | PRD-0400_Earnings_Model, ADR-001_Event_Driven_Architecture, docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md |

## Purpose

Defines the platform-level requirements for integration with external systems — how data enters, how it exits, and the standards that govern those exchanges.

---

## 1. Supported Integration Patterns

**REQ-INT-001**
The platform shall support inbound external data imports including earnings, provider data, and employee records.

**REQ-INT-002**
The platform shall support scheduled batch job exchanges for periodic file-based integration.

**REQ-INT-003**
The platform shall support synchronous API integrations for request-response intake and export.

**REQ-INT-004**
The platform shall support event-driven data ingestion for downstream modules subscribing to platform events.

## 2. Inbound Integration Requirements

**REQ-INT-010**
All external data entering the platform shall be validated against schema and referential integrity rules before posting.

**REQ-INT-011**
All external data shall pass through a canonical translation layer. Direct external-to-core posting is not permitted under any circumstance.

**REQ-INT-012**
Invalid inbound records shall route to exception queues rather than allowing partial posting.

**REQ-INT-013**
All inbound exchanges shall carry a reference ID enabling idempotent replay without duplicate effect.

**REQ-INT-014**
All inbound exchanges shall produce an audit record identifying source, timestamp, and intake operator.

## 3. Outbound Integration Requirements

**REQ-INT-020**
Outbound data exports shall occur only after results have been approved for release.

**REQ-INT-021**
All outbound exports shall be traceable to the source payroll run, period, and context.

**REQ-INT-022**
Outbound exports shall support replay without generating duplicate downstream effects.

**REQ-INT-023**
All outbound transmission activity shall be auditable including transmission status and delivery confirmation.

## 4. Supported Transport Methods

**REQ-INT-030**
The platform shall support SFTP as an integration transport method.

**REQ-INT-031**
The platform shall support HTTPS API as an integration transport method.

**REQ-INT-032**
The platform shall support secure object storage as an integration transport method.

**REQ-INT-033**
The platform shall support managed provider portals as an integration transport method.

## 5. Supported Payload Formats

**REQ-INT-040**
The platform shall support CSV payload format for integrations.

**REQ-INT-041**
The platform shall support XLSX payload format for integrations.

**REQ-INT-042**
The platform shall support JSON payload format for integrations.

**REQ-INT-043**
The platform shall support XML payload format for integrations.

**REQ-INT-044**
The platform shall support fixed-width file format for integrations.

**REQ-INT-045**
The platform shall support EDI format for integrations.

## 6. Security Requirements

**REQ-INT-050**
All integrations shall enforce encryption in transit.

**REQ-INT-051**
All integrations shall enforce encryption at rest for stored payloads.

**REQ-INT-052**
Integration credentials shall be managed with key rotation support.

**REQ-INT-053**
All integration access and transport activity shall be audit-logged.

## 7. Architecture Model Reference

- `docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md`
- `docs/architecture/interfaces/Payroll_Interface_and_Export_Model.md`

---

## 8. User Stories

**Payroll Administrator** needs to **monitor outbound export status in real time** in order to **confirm that payment files, GL exports, and tax files were successfully delivered to downstream systems before the payroll close window expires.**

**Integration Engineer** needs to **replay a failed inbound file without risk of duplicate posting** in order to **recover from transient system failures without corrupting payroll data.**

**Finance Controller** needs to **receive a balanced GL journal entry from payroll within 15 minutes of payroll posting** in order to **meet the financial close SLA.**

**Security Administrator** needs to **rotate integration credentials without interrupting active integrations** in order to **comply with credential rotation policies without causing payroll processing failures.**

---

## 9. Scope Boundaries

### In Scope — v1

**REQ-INT-060**
All six supported transport methods (SFTP, HTTPS API, secure object storage, managed provider portals — and two additional per §4) shall be implemented in v1.

**REQ-INT-061**
All six supported payload formats (CSV, XLSX, JSON, XML, fixed-width, EDI) shall be supported in v1.

**REQ-INT-062**
Idempotency controls (duplicate detection via fingerprint/batch ID) shall be enforced on all inbound and outbound integrations in v1.

**REQ-INT-063**
The canonical translation layer shall be enforced for all inbound data in v1. No direct external-to-core posting shall be permitted.

### Out of Scope — v1

**REQ-INT-064**
Real-time streaming integrations (sub-second event delivery via WebSocket or server-sent events) are out of scope for v1.

**REQ-INT-065**
Integration with non-U.S. payroll providers and non-U.S. tax filing authorities is out of scope for v1.

---

## 10. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-INT-001 | An inbound external earnings file is accepted, validated, staged, approved, and committed without manual data transformation. |
| REQ-INT-010 | An inbound file that fails schema validation is rejected entirely. No records from the file appear in staging. |
| REQ-INT-011 | An inbound record with an unmapped code is rejected and routed to the exception queue. The remaining valid records in the batch follow the configured rejection policy. |
| REQ-INT-013 | A resubmitted inbound file with an identical fingerprint is detected as a duplicate and rejected with ERR-EXT-004. |
| REQ-INT-020 | An outbound export is not generated until the associated payroll run has reached STATE-RUN-012 (Approved). |
| REQ-INT-022 | A retransmitted export with the same Export_ID does not produce a duplicate posting in the downstream system. |
| REQ-INT-030 | An SFTP-delivered file is accepted and processed identically to the same data delivered via HTTPS API. |
| REQ-INT-050 | All integration transport activity is recorded in the audit log with actor, timestamp, delivery status, and file fingerprint. |
| REQ-INT-051 | An integration credential rotation does not interrupt an active inbound or outbound integration session in progress. |
| REQ-INT-052 | A failed outbound transmission generates an alert within 5 minutes and initiates a retry within the configured retry window. |

---

## 11. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for the capabilities defined in this document.


**REQ-INT-070**
Scheduled inbound integration feeds shall be fully processed within 15 minutes of file arrival.

**REQ-INT-071**
Event-driven API updates (per-record inbound) shall receive a validation response within 5 minutes.

**REQ-INT-072**
Critical inbound updates (job change, pay rate change) shall be processed and available to downstream modules within 1 minute of submission.

**REQ-INT-073**
Outbound export files shall be generated within 10 minutes of the export trigger.

**REQ-INT-074**
Outbound SFTP or API transmissions shall complete within 5 minutes of file generation.

**REQ-INT-075**
Provider acknowledgment shall be received and matched within 15 minutes of transmission.

**REQ-INT-076**
Integration errors shall surface to the monitoring dashboard within 5 minutes of detection.

**REQ-INT-077**
Automated integration retry cycles shall complete within 30 minutes of the initial failure.
