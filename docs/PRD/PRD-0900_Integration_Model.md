# PRD-900 — Integration Model

| Field | Detail |
|---|---|
| **Document Type** | Product Requirements — Integration Model |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/PRD/PRD-0900_Integration_Model.md` |
| **Replaces** | `docs/PRD/HCM_Platform_PRD.md` §14 |
| **Related Documents** | PRD-0400_Earnings_Model, ADR-001_Event_Driven_Architecture, docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md |

## Purpose

Defines the platform-level requirements for integration with external systems — how data enters, how it exits, and the standards that govern those exchanges.

---

## 1. Supported Integration Patterns

| Pattern | Description |
|---|---|
| External data imports | Inbound earnings, provider data, employee records |
| Scheduled batch jobs | Periodic file-based exchanges |
| API integrations | Synchronous request-response intake and export |
| Event-driven data ingestion | Downstream modules subscribing to platform events |

## 2. Inbound Integration Requirements

All external data entering the platform shall:

- Be validated against schema and referential integrity rules before posting
- Pass through a canonical translation layer — no direct external-to-core posting is permitted
- Route invalid records to exception queues rather than allowing partial posting
- Carry a reference ID enabling idempotent replay without duplicate effect
- Produce an audit record identifying source, timestamp, and intake operator

## 3. Outbound Integration Requirements

All outbound data exports shall:

- Occur only after results have been approved for release
- Be traceable to the source payroll run, period, and context
- Support replay without generating duplicate downstream effects
- Be fully auditable including transmission status and confirmation

## 4. Supported Transport Methods

- SFTP
- HTTPS API
- Secure object storage
- Managed provider portals

## 5. Supported Payload Formats

- CSV
- XLSX
- JSON
- XML
- Fixed-width
- EDI

## 6. Security Requirements

All integrations shall enforce:

- Encryption in transit
- Encryption at rest
- Credential management and key rotation
- Access control
- Transport audit logging

## 7. Architecture Model Reference

- `docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md`
- `docs/architecture/interfaces/Payroll_Interface_and_Export_Model.md`
