# EXC-SEC — Security / Access Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Compliance Domain |
| **Location** | `docs/EXC/EXC-SEC_Security_Access_Exceptions.md` |
| **Related Documents** | docs/architecture/governance/Security_and_Access_Control_Model.md, docs/architecture/governance/Data_Retention_and_Archival_Model.md |

## Purpose

Defines exceptions arising from security and access control violations — unauthorised access attempts, permission boundary breaches, and cross-tenant data access violations.

---

### EXC-SEC-001

| Field | Detail |
|---|---|
| **Code** | EXC-SEC-001 |
| **Name** | Unauthorised Action Attempted |
| **Severity** | Hard Stop |
| **Domain** | Access Control |

**Condition:** A user or process attempted an action for which they do not hold the required role or permission. Examples: non-approver attempting to approve a payroll run; operator attempting to release without Release role; read-only user attempting to modify a record.

**System Behaviour:** Action blocked. Attempt logged with user identity, action attempted, target record, and timestamp. Security alert generated.

**Operator Action Required:** No operator payroll action required. Review the access log. Determine whether the attempt was accidental (misconfigured role) or intentional (potential security incident). Escalate to security team if intentional.

**Related Codes:** EXC-AUD-001

---

### EXC-SEC-002

| Field | Detail |
|---|---|
| **Code** | EXC-SEC-002 |
| **Name** | Cross-Tenant Data Access Violation |
| **Severity** | Hard Stop |
| **Domain** | Tenant Isolation |

**Condition:** A query, API call, or process attempted to access data belonging to a different client or tenant without explicit multi-tenant authorisation.

**System Behaviour:** Access blocked immediately. Violation logged with full context. Alert escalated to platform security team and Compliance.

**Operator Action Required:** This is a potential data breach scenario. Escalate immediately to platform security. Investigate the source of the cross-tenant access attempt. Do not attempt to resolve through normal operational channels.

**Related Codes:** EXC-SEC-001, EXC-AUD-001

---

### EXC-SEC-003

| Field | Detail |
|---|---|
| **Code** | EXC-SEC-003 |
| **Name** | Separation of Duties Violation |
| **Severity** | Hard Stop |
| **Domain** | Segregation of Duties |

**Condition:** The same user attempted to perform two actions on the same payroll run or HR event that are required to be performed by different individuals under separation of duties rules. Examples: the same user calculating and approving a payroll run; the same user initiating and approving a compensation change.

**System Behaviour:** Second action blocked. Violation logged. Alert generated to Payroll Supervisor.

**Operator Action Required:** Assign the second action to a different qualified user. Review whether the separation of duties configuration is correctly set for the relevant action types.

**Related Codes:** EXC-SEC-001

---

### EXC-SEC-004

| Field | Detail |
|---|---|
| **Code** | EXC-SEC-004 |
| **Name** | Sensitive Field Access Without Authorisation |
| **Severity** | Hard Stop |
| **Domain** | Data Privacy |

**Condition:** An attempt was made to view or export a sensitive field (SSN, bank account number, national identifier) by a user who does not hold the required sensitive-data access role.

**System Behaviour:** Field value masked or access blocked. Attempt logged. Alert generated.

**Operator Action Required:** Verify whether the user should have access to the sensitive field. If legitimate access is needed, update the user's role assignment through the authorised provisioning workflow.

**Related Codes:** EXC-SEC-001, EXC-AUD-001
