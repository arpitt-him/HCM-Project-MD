# EXC-AUD — Audit / Retention Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Compliance Domain |
| **Location** | `docs/EXC/EXC-AUD_Audit_Retention_Exceptions.md` |
| **Related Documents** | docs/architecture/governance/Data_Retention_and_Archival_Model.md, docs/architecture/governance/Correction_and_Immutability_Model.md, docs/architecture/governance/Security_and_Access_Control_Model.md |

## Purpose

Defines exceptions arising from audit trail gaps, retention policy violations, and archival failures.

---

### EXC-AUD-001

| Field | Detail |
|---|---|
| **Code** | EXC-AUD-001 |
| **Name** | Audit Record Missing for Mutation |
| **Severity** | Hard Stop |
| **Domain** | Audit Trail Completeness |

**Condition:** A mutation to a financial or HR record has occurred without a corresponding audit record being created. This may indicate a processing failure, a direct database modification, or an audit logging system failure.

**System Behaviour:** Missing audit record flagged. Affected records quarantined from further processing until the audit gap is investigated. Alert escalated to Compliance team.

**Operator Action Required:** Investigate the source of the audit gap. If a direct database change occurred without going through the platform workflows, it must be investigated as a potential security or compliance incident.

**Related Codes:** EXC-SEC-001

---

### EXC-AUD-002

| Field | Detail |
|---|---|
| **Code** | EXC-AUD-002 |
| **Name** | Retention Period Expiring — Legal Hold Check Required |
| **Severity** | Warning |
| **Domain** | Retention Management |

**Condition:** A data record is approaching its configured retention expiration date. Before purge can occur, a legal hold check is required.

**System Behaviour:** Warning logged. Purge process paused for the affected records. Compliance team notified.

**Operator Action Required:** Verify whether a legal hold applies to the records in question. If no hold is in place and the retention period has elapsed, confirm purge authorisation. If a hold applies, apply the hold flag and defer purge.

**Related Codes:** EXC-AUD-003

---

### EXC-AUD-003

| Field | Detail |
|---|---|
| **Code** | EXC-AUD-003 |
| **Name** | Purge Attempted on Record Under Legal Hold |
| **Severity** | Hard Stop |
| **Domain** | Legal Hold Enforcement |

**Condition:** An automated or manual purge action targeted a record that carries an active legal hold flag.

**System Behaviour:** Purge blocked. Attempt logged with actor identity and timestamp. Alert escalated to Compliance and Legal teams.

**Operator Action Required:** Do not proceed with purge. Investigate why the legal hold was not detected earlier in the retention workflow. Legal hold must be formally released by the appropriate authority before purge can be reconsidered.

**Related Codes:** EXC-AUD-002

---

### EXC-AUD-004

| Field | Detail |
|---|---|
| **Code** | EXC-AUD-004 |
| **Name** | Archival Process Failed |
| **Severity** | Hard Stop |
| **Domain** | Archival Operations |

**Condition:** A scheduled archival process failed to complete, leaving records in Active state beyond their archival trigger point.

**System Behaviour:** Archival failure logged. Affected records remain in Active state. Alert generated to platform operations team.

**Operator Action Required:** Investigate the archival failure — storage availability, network, or process error. Resolve the root cause and retry the archival process. Do not delete records that have not been successfully archived.

**Related Codes:** EXC-AUD-002
