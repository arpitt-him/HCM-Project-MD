# SPEC — API Contract Standards

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/API_Contract_Standards.md` |
| **Related Documents** | PRD-0900_Integration_Model, PRD-0100_Architecture_Principles, docs/architecture/governance/Security_and_Access_Control_Model.md, docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md, docs/NFR/HCM_NFR_Specification.md |

## Purpose

Defines the behavioural requirements governing all external-facing APIs on the HCM platform. This document specifies what the API must do — authentication standards, versioning policy, request and response format, error handling, rate limiting, and idempotency. It is not an endpoint catalogue. Individual endpoint specifications are produced separately per domain as implementation progresses.

All APIs produced by the platform must comply with this document. Deviations require a documented ADR.

---

## 1. User Stories

**Integration Engineer** needs to **rely on a consistent request and response format across all platform APIs** in order to **build integrations once and apply the same patterns regardless of which domain endpoint is being called.**

**Platform Security Administrator** needs to **enforce authentication and authorisation standards uniformly across all APIs** in order to **ensure no endpoint bypasses access control requirements.**

**External Developer** needs to **understand how the API communicates errors** in order to **handle failure cases correctly without guessing at the meaning of response codes or error payloads.**

**Payroll Operations Team** needs to **submit critical updates (job changes, pay rate changes) via API and receive confirmation within 1 minute** in order to **meet payroll input cutoff deadlines without manual fallback.**

---

## 2. Scope Boundaries

### In Scope — v1

**REQ-PLT-060**
All external-facing platform APIs shall comply with this specification in v1.

**REQ-PLT-061**
REST over HTTPS is the required API style for all v1 external APIs.

**REQ-PLT-062**
JSON is the required payload format for all v1 API requests and responses.

### Out of Scope — v1

**REQ-PLT-063**
GraphQL, gRPC, and WebSocket APIs are out of scope for v1. The platform architecture must not preclude their future addition.

**REQ-PLT-064**
A developer portal or interactive API documentation UI is out of scope for v1. Machine-readable OpenAPI specifications are the primary documentation artefact.

---

## 3. Authentication

**REQ-PLT-065**
All API requests shall be authenticated. Unauthenticated requests shall be rejected with HTTP 401.

**REQ-PLT-066**
The platform shall support OAuth 2.0 Client Credentials flow as the primary authentication mechanism for server-to-server integrations.

**REQ-PLT-067**
The platform shall support API key authentication as a secondary mechanism for simpler integrations where OAuth 2.0 is not feasible. API keys must be rotatable without service interruption.

**REQ-PLT-068**
Access tokens issued via OAuth 2.0 shall have a maximum lifetime of 1 hour. Refresh token lifetime is configurable per client registration.

**REQ-PLT-069**
All API transport shall use TLS 1.2 or higher. Connections using TLS 1.1 or earlier shall be rejected.

**REQ-PLT-070**
API credentials shall never appear in URL query strings. Credentials must be passed in request headers only.

---

## 4. Authorisation

**REQ-PLT-071**
Every API endpoint shall enforce role-based authorisation. A valid authenticated token that does not carry the required scope for the endpoint shall be rejected with HTTP 403.

**REQ-PLT-072**
API scopes shall be granular — read access and write access to a resource shall be distinct scopes. Possession of write scope does not imply possession of read scope unless explicitly granted.

**REQ-PLT-073**
Multi-tenant API requests shall be tenant-scoped. A request authenticated as Tenant A shall never return or modify data belonging to Tenant B. Violations generate EXC-SEC-002.

**REQ-PLT-074**
Sensitive field access (SSN, bank account number) via API shall require an explicit sensitive-data scope in addition to the base resource scope.

---

## 5. Versioning

**REQ-PLT-075**
All APIs shall be versioned. The version shall be expressed in the URL path as a major version prefix: `/v1/`, `/v2/`, etc.

**REQ-PLT-076**
A new major version shall be introduced only when a breaking change is required. Breaking changes include: removing a field, changing a field type, changing the meaning of an existing field, removing an endpoint, changing a required field to a different name.

**REQ-PLT-077**
Adding a new optional field, adding a new endpoint, or adding a new enum value to a response are non-breaking changes and do not require a new major version.

**REQ-PLT-078**
When a new major version is released, the prior major version shall remain supported for a minimum of 12 months from the announcement date to allow consumers time to migrate.

**REQ-PLT-079**
The deprecation timeline for a prior major version shall be communicated to registered API consumers at least 90 days before the version is retired.

---

## 6. Request Format

**REQ-PLT-080**
All API request bodies shall be JSON with Content-Type: application/json.

**REQ-PLT-081**
All datetime values in request payloads shall use ISO 8601 format with UTC offset: `YYYY-MM-DDTHH:MM:SSZ` or `YYYY-MM-DDTHH:MM:SS±HH:MM`.

**REQ-PLT-082**
All date-only values shall use ISO 8601 date format: `YYYY-MM-DD`.

**REQ-PLT-083**
All monetary amounts shall be expressed as decimal numbers with exactly two decimal places. Currency codes shall use ISO 4217 three-letter codes.

**REQ-PLT-084**
Field names in request and response payloads shall use snake_case consistently.

**REQ-PLT-085**
Requests that exceed the configured maximum payload size shall be rejected with HTTP 413 and a descriptive error message identifying the limit.

---

## 7. Response Format

**REQ-PLT-086**
All API responses shall be JSON with Content-Type: application/json.

**REQ-PLT-087**
Successful single-resource responses shall follow this envelope:

```json
{
  "data": { },
  "meta": {
    "request_id": "uuid",
    "timestamp": "ISO8601"
  }
}
```

**REQ-PLT-088**
Successful collection responses shall follow this envelope:

```json
{
  "data": [ ],
  "meta": {
    "request_id": "uuid",
    "timestamp": "ISO8601",
    "page": 1,
    "page_size": 100,
    "total_count": 4523
  }
}
```

**REQ-PLT-089**
Collection responses shall support cursor-based pagination. Offset-based pagination is not permitted for collections exceeding 1,000 records.

**REQ-PLT-090**
Responses shall never include null fields for optional attributes. Absent optional fields shall be omitted from the response entirely.

---

## 8. Error Handling

**REQ-PLT-091**
All error responses shall use the following structure:

```json
{
  "error": {
    "code": "EXC-VAL-001",
    "message": "Human-readable description of the error",
    "field": "field_name_if_applicable",
    "request_id": "uuid"
  }
}
```

**REQ-PLT-092**
The `code` field in error responses shall reference the platform's EXC-prefixed exception codes where applicable. Generic HTTP status codes alone are not sufficient.

**REQ-PLT-093**
HTTP status codes shall be used correctly and consistently:

| Status | Meaning |
|---|---|
| 200 OK | Successful read or synchronous update |
| 201 Created | Resource successfully created |
| 202 Accepted | Request accepted for asynchronous processing |
| 400 Bad Request | Malformed request syntax or invalid field value |
| 401 Unauthorized | Missing or invalid authentication |
| 403 Forbidden | Authenticated but insufficient authorisation scope |
| 404 Not Found | Resource does not exist |
| 409 Conflict | Request conflicts with current resource state (e.g. duplicate) |
| 413 Payload Too Large | Request body exceeds size limit |
| 422 Unprocessable Entity | Request is syntactically valid but semantically invalid (e.g. failed business rule) |
| 429 Too Many Requests | Rate limit exceeded |
| 500 Internal Server Error | Unexpected server error |
| 503 Service Unavailable | Planned maintenance or temporary unavailability |

**REQ-PLT-094**
422 responses shall include one error object per failed validation rule. A request that fails five validation rules shall return five error entries, not just the first.

**REQ-PLT-095**
500 responses shall include a request_id to enable server-side log correlation. They shall never include stack traces or internal implementation details in the response body.

---

## 9. Idempotency

**REQ-PLT-096**
All mutating API requests (POST, PUT, PATCH) shall support an `Idempotency-Key` request header. The value shall be a client-generated UUID.

**REQ-PLT-097**
If two requests arrive with the same `Idempotency-Key` within the idempotency window (configurable; minimum 24 hours), the second request shall return the same response as the first without re-executing the operation.

**REQ-PLT-098**
Idempotency keys shall be stored server-side for the duration of the idempotency window. After expiry, reuse of a prior key shall be treated as a new request.

**REQ-PLT-099**
If a request is received with an `Idempotency-Key` that matches a prior request but with a different request body, the server shall reject the request with HTTP 422 and an error indicating the key conflict.

---

## 10. Rate Limiting

**REQ-PLT-100**
All API endpoints shall enforce rate limiting. Rate limits shall be applied per authenticated client, not per IP address.

**REQ-PLT-101**
Rate limit thresholds shall be configurable per client registration to support different integration tiers (standard, elevated, bulk processing).

**REQ-PLT-102**
All API responses shall include the following rate limit headers:

| Header | Meaning |
|---|---|
| `X-RateLimit-Limit` | Maximum requests permitted in the current window |
| `X-RateLimit-Remaining` | Requests remaining in the current window |
| `X-RateLimit-Reset` | Unix timestamp when the window resets |

**REQ-PLT-103**
Requests that exceed the rate limit shall receive HTTP 429 with a `Retry-After` header indicating the number of seconds until the client may retry.

**REQ-PLT-104**
Bulk import endpoints (batch file submission) shall have separate, higher rate limits from per-record API endpoints. Bulk endpoints shall not be subject to the same per-request throttle as transactional endpoints.

---

## 11. Asynchronous Operations

**REQ-PLT-105**
Long-running operations (payroll run initiation, bulk import processing, large export generation) shall return HTTP 202 Accepted immediately with a Job_ID rather than blocking the connection.

**REQ-PLT-106**
Asynchronous job status shall be queryable via a dedicated status endpoint: `GET /v1/jobs/{job_id}`.

**REQ-PLT-107**
Job status responses shall include: Job_ID, status (PENDING, PROCESSING, COMPLETED, FAILED), created_at, updated_at, and a result or error payload when terminal status is reached.

**REQ-PLT-108**
Webhook callbacks for async job completion shall be supported as an optional alternative to polling. Webhook registration, retry policy, and signature verification shall be configurable per client.

---

## 12. Performance Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following SLAs apply specifically to API behaviour.

**REQ-PLT-110**
Synchronous read endpoints (single record lookup, employee profile, pay statement) shall return within 2 seconds at the 99th percentile under normal load.

**REQ-PLT-111**
Synchronous write endpoints (single record create or update) shall return within 2 seconds at the 99th percentile under normal load.

**REQ-PLT-112**
Critical update endpoints (job change, pay rate change, tax election) shall return a 202 Accepted response within 1 second and complete processing within 1 minute.

**REQ-PLT-113**
Bulk import endpoints shall accept and acknowledge a file submission within 5 seconds regardless of file size. Processing time is governed by the batch SLAs in the platform NFR document.

**REQ-PLT-114**
The API layer shall support the platform's scalability targets: more than 10,000 job changes per hour and more than 5,000 payroll adjustments per minute without degradation below the defined SLAs.

---

## 13. Audit and Observability

**REQ-PLT-115**
Every API request shall generate an audit log entry containing: client identity, endpoint, HTTP method, request_id, timestamp, response status code, and processing duration.

**REQ-PLT-116**
Audit logs for API requests involving sensitive fields (SSN, bank account) shall mask the sensitive values in the log entry.

**REQ-PLT-117**
API error rates and latency percentiles shall be surfaced in the platform's operational monitoring dashboard within 5 minutes of occurrence.
