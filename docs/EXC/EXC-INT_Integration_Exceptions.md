# EXC-INT — Integration Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v1.0 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/EXC/EXC-INT_Integration_Exceptions.md` |
| **Related Documents** | docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md, docs/architecture/interfaces/Payroll_Interface_and_Export_Model.md, docs/architecture/interfaces/Payroll_Provider_Response_Model.md, SPEC/External_Earnings.md |

## Purpose

Defines exceptions arising from integration activities — inbound data failures, outbound transmission failures, format errors, and provider response anomalies.

---

### EXC-INT-001

| Field | Detail |
|---|---|
| **Code** | EXC-INT-001 |
| **Name** | Inbound File Structurally Invalid |
| **Severity** | Hard Stop |
| **Domain** | Inbound Integration |

**Condition:** An inbound integration file fails structural parsing — the file is not valid CSV, XML, JSON, or the declared format; required header rows are missing; encoding is unrecognised.

**System Behaviour:** Entire file rejected. No records staged. Error log created with file fingerprint and failure description.

**Operator Action Required:** Return the file to the source system for correction. Do not attempt to edit imported files directly. Resubmit corrected file with a new Source_Batch_ID.

**Related Codes:** EXC-INT-002

---

### EXC-INT-002

| Field | Detail |
|---|---|
| **Code** | EXC-INT-002 |
| **Name** | Unmapped or Unrecognised Code in Inbound Payload |
| **Severity** | Hard Stop |
| **Domain** | Canonical Translation |

**Condition:** An inbound record contains an earning type, deduction code, tax code, or other classification value that does not map to a canonical internal code in the Code_Classification_and_Mapping_Model.

**System Behaviour:** Affected record rejected. Routed to exception queue with the unmapped value. No partial posting of the batch.

**Operator Action Required:** Add the missing code mapping to the classification table, approve it, and reprocess the rejected records.

**Related Codes:** EXC-CFG-004

---

### EXC-INT-003

| Field | Detail |
|---|---|
| **Code** | EXC-INT-003 |
| **Name** | Duplicate Inbound Submission Detected |
| **Severity** | Hard Stop |
| **Domain** | Idempotency |

**Condition:** An inbound file or API payload carries the same fingerprint or Source_Batch_ID as a previously processed submission.

**System Behaviour:** Submission rejected as duplicate. No records staged. Original submission reference logged.

**Operator Action Required:** Confirm whether this is an accidental resubmission or a genuinely new batch. If new, resubmit with a unique Source_Batch_ID.

**Related Codes:** EXC-INT-001

---

### EXC-INT-004

| Field | Detail |
|---|---|
| **Code** | EXC-INT-004 |
| **Name** | Outbound Export Transmission Failed |
| **Severity** | Hard Stop |
| **Domain** | Outbound Integration |

**Condition:** An outbound export transmission failed — SFTP connection refused, API timeout, credential rejection, or network failure.

**System Behaviour:** Export transitions to STATE-EXP-005 (Failed). Retry initiated if within retry limit. Alert generated to operations team.

**Operator Action Required:** Investigate the transmission failure. Verify credentials, connectivity, and target system availability. Monitor retry progress. If max retries exceeded, intervene manually.

**Related Codes:** EXC-INT-005, EXC-RUN-003

---

### EXC-INT-005

| Field | Detail |
|---|---|
| **Code** | EXC-INT-005 |
| **Name** | Export Max Retry Limit Exceeded |
| **Severity** | Hard Stop |
| **Domain** | Outbound Integration |

**Condition:** An outbound export has exhausted its configured maximum retry attempts without achieving successful delivery confirmation.

**System Behaviour:** Export transitions to STATE-EXP-008 (Closed — failed). No further automatic retries. Alert escalated to Payroll Supervisor.

**Operator Action Required:** Investigate the root cause of all retry failures. Coordinate with the downstream provider. If transmission cannot be completed via the standard channel, initiate a manual delivery process and document the exception.

**Related Codes:** EXC-INT-004

---

### EXC-INT-006

| Field | Detail |
|---|---|
| **Code** | EXC-INT-006 |
| **Name** | Provider Response Unmatched to Export |
| **Severity** | Warning |
| **Domain** | Provider Response |

**Condition:** An inbound provider response cannot be correlated to a known outbound export within the expected time and context window.

**System Behaviour:** Response held in STATE-PRV-006 (Exception Raised). Not processed further. Alert generated.

**Operator Action Required:** Investigate whether the response belongs to a prior export cycle, a different context, or represents a provider error. Do not discard unmatched responses — they must be reviewed and formally closed.

**Related Codes:** EXC-INT-004

---

### EXC-INT-007

| Field | Detail |
|---|---|
| **Code** | EXC-INT-007 |
| **Name** | Control Total Mismatch on Inbound Batch |
| **Severity** | Hard Stop |
| **Domain** | Reconciliation Controls |

**Condition:** An inbound file supplied a control total (record count or sum amount) that does not match the computed total from the file's actual records.

**System Behaviour:** Entire file rejected. Control total discrepancy logged with submitted vs computed values.

**Operator Action Required:** Reconcile the source file against the declared control totals. Correct the file and resubmit.

**Related Codes:** EXC-INT-001
