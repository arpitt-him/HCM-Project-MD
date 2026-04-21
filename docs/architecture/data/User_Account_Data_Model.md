# User_Account_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Security & Identity Domain |
| **Location** | docs/architecture/data/User_Account_Data_Model.md |
| **Domain** | User Account / Authentication / Access Identity |
| **Related Documents** | Person_Data_Model.md, Tenant_Data_Model.md, Client_Company_Data_Model.md, Legal_Entity_Data_Model.md, Security_and_Access_Control_Model.md, Role_and_Permission_Model.md |

---

# Purpose

This document defines the core data structure for **User Account** as the governed authentication and platform-access identity associated with a Person.

User Account represents:

- system access identity
- authentication credential linkage
- role-based authorization anchor
- tenant-scoped access boundary
- session-enabled platform participation

User Account is **not** the Person identity.

User Account is the **access identity**, not the human identity.

---

# Core Structural Role

```text
Person
    ↓
User Account
    ↓
Tenant Scope
    ↓
Roles / Permissions
    ↓
System Access
```

User Account enables a Person to interact with the platform under governed access policies.

---

# 1. User Account Definition

A **User Account** represents a governed access identity used to authenticate into the platform.

A User Account may represent:

- employee self-service user
- manager self-service user
- HR administrator
- payroll administrator
- client administrator
- integration/service account
- auditor or restricted reviewer
- system-level automation identity

User Account shall be modeled as distinct from:

- Person
- Employment
- Role Assignment
- Session
- Security Token
- Authentication Provider

User Account is the access credential identity.

---

# 2. User Account Primary Attributes

| Field Name | Description |
|---|---|
| User_Account_ID | Unique identifier |
| Person_ID | Linked Person reference |
| Username | Login username or identifier |
| User_Account_Status | Pending, Active, Locked, Suspended, Disabled, Closed |
| Account_Type | Human_User, Service_Account, Integration_User, External_User |
| Primary_Tenant_ID | Default Tenant scope |
| Email_Address | Primary login or notification email |
| MFA_Required_Flag | Indicates multi-factor authentication requirement |
| Password_Required_Flag | Indicates password-based authentication |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. User Account Functional Attributes

| Field Name | Description |
|---|---|
| Authentication_Method | Password, SSO, OAuth, Token, Certificate |
| Identity_Provider_ID | External identity provider reference |
| Last_Login_Timestamp | Last successful login |
| Failed_Login_Count | Number of failed login attempts |
| Lockout_Expiration_Timestamp | Lock expiration where applicable |
| Password_Last_Changed_Timestamp | Last password change |
| Password_Expiration_Timestamp | Password expiration date |
| MFA_Method | SMS, Authenticator_App, Email, Hardware_Token |
| Session_Timeout_Value | Default session timeout |
| Notes | Administrative notes |

---

# 4. Relationship to Person

```text
Person
    └── User Account (0..n)
```

Constraints:

- A Person may have zero or more User Accounts.
- A User Account must reference exactly one Person.
- A Person identity persists independently of User Account lifecycle.
- User Accounts may be disabled without removing Person identity.

Examples:

- Employee with self-service login
- Former employee with disabled login
- Contractor with limited portal access

---

# 5. Relationship to Tenant

User Accounts are tenant-scoped.

```text
Tenant
    └── User Account (1..n)
```

Constraints:

- A User Account must belong to at least one Tenant.
- A User Account may support multi-tenant access where policy permits.
- Tenant boundary controls data visibility and permissions.

Tenant assignment ensures secure isolation between customers.

---

# 6. Relationship to Roles and Permissions

User Accounts receive authorization through role assignment.

```text
User Account
    └── Role Assignment (1..n)
            └── Permission Set
```

Roles determine:

- system capabilities
- feature access
- data visibility
- workflow permissions

Role assignment may be:

- tenant-level
- client-company-level
- legal-entity-level
- module-level

---

# 7. Relationship to Authentication Providers

User Accounts may authenticate through:

- internal credential store
- enterprise identity provider
- third-party authentication service
- federated identity system

Typical structure:

```text
User Account
    └── Authentication Provider Link
```

Supported provider types:

- SAML
- OAuth
- OpenID Connect
- LDAP
- Certificate-based authentication

Authentication provider relationships shall remain auditable.

---

# 8. User Account Status Model

Suggested User_Account_Status values:

| Status | Meaning |
|---|---|
| Pending | Account created but not activated |
| Active | Account operational |
| Locked | Temporarily locked due to security event |
| Suspended | Administrative suspension |
| Disabled | Permanently disabled |
| Closed | Historical record retained |

Status transitions shall be governed and auditable.

Disabled or Closed accounts shall not authenticate into the system.

---

# 9. Multi-Factor Authentication (MFA)

User Accounts shall support MFA where policy requires.

MFA configuration may include:

- multiple authentication methods
- backup authentication channels
- recovery verification
- device registration

MFA shall be configurable at:

- tenant level
- role level
- user level

MFA usage must be logged and auditable.

---

# 10. Service and Integration Accounts

User Accounts may represent automated or system identities.

Examples:

- payroll integration service
- API automation process
- external reporting agent
- scheduled job identity

Service accounts shall support:

- restricted permissions
- non-interactive authentication
- controlled credential rotation
- audit visibility

Service accounts must never be treated as human identities.

---

# 11. Password and Credential Management

Where password authentication is used, the platform shall support:

- password complexity policies
- password expiration policies
- password history retention
- forced password reset workflows
- credential encryption
- credential rotation

Password storage shall use secure hashing methods.

Plaintext password storage is strictly prohibited.

---

# 12. Session and Login Tracking

User login activity shall be recorded.

Tracked data may include:

- login timestamp
- logout timestamp
- session duration
- IP address
- device fingerprint
- failed login attempts

Session monitoring supports:

- security detection
- fraud prevention
- access audit
- incident investigation

---

# 13. Access Scope Model

User Account access scope shall support hierarchical boundaries.

Examples:

- Tenant-level access
- Client Company-level access
- Legal Entity-level access
- Department-level access
- Role-based functional access

Access scope definitions must remain explicit and auditable.

Implicit privilege inheritance shall be governed.

---

# 14. Validation Rules

Examples of validation rules:

- Person_ID is required
- Username must be unique within tenant scope
- Email_Address format must be valid
- User_Account_Status must be defined
- Disabled accounts must not authenticate
- Failed login threshold must trigger lockout
- Password expiration must trigger reset workflow
- MFA configuration must be validated before activation where policy requires

Validation enforcement shall occur at both authentication and administrative layers.

---

# 15. Audit and Traceability Requirements

The system shall preserve:

- account creation history
- login history
- password change history
- role assignment history
- tenant assignment history
- MFA configuration history
- account status change history

This supports:

- security audit
- compliance review
- forensic analysis
- incident response

---

# 16. Security Requirements

User Account security shall support:

- encryption of sensitive credentials
- secure session handling
- brute-force protection
- rate limiting
- anomaly detection
- credential rotation enforcement
- secure logout behavior

Security policies must remain configurable at tenant level.

---

# 17. Relationship to Other Models

This model integrates with:

- Person_Data_Model
- Tenant_Data_Model
- Client_Company_Data_Model
- Legal_Entity_Data_Model
- Security_and_Access_Control_Model
- Role_and_Permission_Model

---

# 18. Summary

This model establishes User Account as the governed access identity of the platform.

Key principles:

- User Account is distinct from Person
- User Account controls authentication and access
- User Account is tenant-scoped
- Role assignments define permissions
- MFA and credential security are mandatory
- Access activity must remain auditable
- Service accounts must remain governed and restricted
