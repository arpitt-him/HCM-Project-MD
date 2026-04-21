# Role_and_Permission_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Security & Identity Domain |
| **Location** | docs/architecture/data/Role_and_Permission_Model.md |
| **Domain** | Authorization / Role-Based Access / Permission Scope |
| **Related Documents** | User_Account_Data_Model.md, Security_and_Access_Control_Model.md, Tenant_Data_Model.md, Client_Company_Data_Model.md, Legal_Entity_Data_Model.md, Platform_Composition_and_Extensibility_Model.md |

---

# Purpose

This document defines the core data structures for **Role**, **Permission**, and **Role Assignment** as the governed authorization framework of the platform.

This model exists to define:

- what a user is allowed to do
- where a user is allowed to do it
- how access is granted
- how access is constrained
- how access changes are audited

The authorization framework must support:

- tenant isolation
- client company segmentation
- legal entity scoping
- functional module boundaries
- least-privilege access
- delegated administration
- service-account restrictions

This model is distinct from authentication.

Authentication answers:

- who are you?

Authorization answers:

- what are you allowed to do, and within what scope?

---

# Core Structural Role

```text
Person
    ↓
User Account
    ↓
Role Assignment
    ↓
Role
    ↓
Permission Set
    ↓
Scoped Access
```

Role and Permission provide the decision structure for platform access.

They are the core mechanism for operational authorization.

---

# 1. Role Definition

A **Role** represents a governed collection of permissions intended to support a recognizable operational responsibility.

A Role may represent:

- employee self-service user
- manager
- HR administrator
- payroll administrator
- benefits administrator
- client administrator
- tenant administrator
- auditor
- integration/service account
- read-only reviewer

A Role shall be modeled as distinct from:

- User Account
- Permission
- Security Policy
- Workflow Approval Chain
- Tenant
- Client Company
- Legal Entity

Role is the logical access package, not the user or the scope itself.

---

# 2. Role Primary Attributes

| Field Name | Description |
|---|---|
| Role_ID | Unique identifier |
| Role_Code | Unique business/system code |
| Role_Name | Human-readable role name |
| Role_Category | Employee, Manager, HR, Payroll, Admin, Auditor, Service, Other |
| Role_Status | Draft, Active, Inactive, Retired |
| System_Defined_Flag | Indicates platform-defined role |
| Custom_Role_Flag | Indicates tenant-configurable role |
| Delegable_Flag | Indicates whether role assignment may be delegated |
| Sensitive_Access_Flag | Indicates role grants sensitive data access |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Permission Definition

A **Permission** represents a discrete allowed capability.

Permissions may control:

- view access
- create access
- update access
- delete/logical delete access
- approval authority
- export authority
- configuration authority
- workflow action authority
- module administration
- report access
- document access

Permissions should be granular enough to support least privilege, while remaining governable and understandable.

---

# 4. Permission Primary Attributes

| Field Name | Description |
|---|---|
| Permission_ID | Unique identifier |
| Permission_Code | Unique business/system code |
| Permission_Name | Human-readable permission name |
| Permission_Category | Read, Write, Approve, Configure, Export, Admin, Other |
| Module_Scope | Payroll, HRIS, Benefits, Time, Reporting, Shared, Other |
| Resource_Type | Person, Employment, Document, Payroll_Run, Config, Report, Other |
| Action_Type | View, Create, Update, Delete_Logical, Approve, Execute, Export, Assign, Administer |
| Sensitive_Action_Flag | Indicates elevated-risk action |
| Permission_Status | Active, Inactive, Retired |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 5. Role-to-Permission Relationship

A Role is composed of one or more Permissions.

```text
Role
    └── Role Permission (1..n)
            └── Permission
```

Constraints:

- A Role may contain many Permissions.
- A Permission may appear in many Roles.
- Role-to-permission linkage must be explicit and auditable.
- Sensitive permissions should be grouped carefully and intentionally.

This structure supports:

- system-defined roles
- custom roles
- modular permission composition
- permission reuse without role duplication

---

# 6. Role Assignment Definition

A **Role Assignment** represents the governed linkage between a User Account, a Role, and an access scope.

Role Assignment determines:

- which role a user has
- where that role applies
- when it becomes effective
- when it ends
- whether special restrictions apply

Role Assignment is the operational application of authorization.

---

# 7. Role Assignment Primary Attributes

| Field Name | Description |
|---|---|
| Role_Assignment_ID | Unique identifier |
| User_Account_ID | Assigned user account |
| Role_ID | Assigned role |
| Scope_Type | Tenant, Client_Company, Legal_Entity, Department, Module, Global_Read_Only, Other |
| Scope_Object_ID | Object to which the role applies |
| Assignment_Status | Pending, Active, Suspended, Expired, Revoked |
| Effective_Start_Date | Assignment start date |
| Effective_End_Date | Assignment end date |
| Assigned_By | User/process creating assignment |
| Assignment_Reason | Optional rationale |
| Delegated_Flag | Indicates delegated assignment |
| Notes | Administrative notes |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 8. Scope Model

Scope controls the boundary within which a Role may be exercised.

Supported scope patterns include:

```text
Tenant
Client Company
Legal Entity
Department
Module
Global Read-Only
```

Examples:

- Tenant Admin role scoped to Tenant A
- Payroll Admin role scoped to Legal Entity B
- HR Reviewer role scoped to Client Company C
- Employee Self-Service role scoped to own record context
- Auditor role scoped to read-only reporting domain

Scope must remain explicit.

The platform shall not assume broad visibility where no explicit scope has been granted.

---

# 9. Relationship to Tenant, Client Company, and Legal Entity

Role Assignment may apply at multiple layers.

### 9.1 Tenant Scope

A role scoped to Tenant applies across all allowed objects within that tenant, subject to permission boundaries.

### 9.2 Client Company Scope

A role scoped to Client Company applies only within that business grouping.

### 9.3 Legal Entity Scope

A role scoped to Legal Entity applies only to the employer-of-record or business records within that entity boundary.

These scopes must remain distinct.

A tenant-scoped role does not automatically imply unrestricted access to all data unless the assigned role and permissions explicitly permit such access.

---

# 10. Self-Service and Contextual Roles

Some roles are contextual rather than purely administrative.

Examples:

- Employee Self-Service
- Manager Self-Service
- Approver
- Reviewer

These roles may require dynamic filtering rules in addition to static scope.

Examples include:

- employee can only view own records
- manager can only view direct or permitted indirect reports
- approver can only act within assigned workflow chain

Contextual access constraints must be modeled explicitly and must not rely on role name alone.

---

# 11. Service and Integration Roles

Service accounts may also receive Roles and Permissions.

Examples:

- payroll integration execution
- reporting export service
- directory synchronization account
- API automation identity

Service roles shall support:

- minimal privilege
- non-interactive access
- restricted scopes
- elevated audit scrutiny

Service accounts must not receive broad human-administrator roles without explicit governance.

---

# 12. Sensitive Permission Controls

Certain permissions are high risk.

Examples:

- view national identifiers
- modify payroll configuration
- approve payroll posting
- export restricted documents
- unlock user accounts
- override validation holds

Sensitive permissions shall support:

- elevated approval requirements
- stronger audit logging
- optional MFA enforcement
- segregation-of-duties controls
- restricted assignment policies

Sensitive access must be identifiable at both the permission and role-assignment layers.

---

# 13. Segregation of Duties Considerations

The platform should support segregation-of-duties controls.

Examples:

- user who configures payroll rules should not also approve payroll posting without exception approval
- user who creates a user account should not automatically approve their own privilege elevation
- user with broad document export authority should not also bypass retention controls without oversight

Segregation rules may be defined through:

- prohibited role combinations
- prohibited permission combinations
- elevated approval workflows
- alerting and exception review

---

# 14. Effective Dating and Historical Preservation

Roles, Permissions, and Role Assignments shall support historical preservation.

This includes:

- role lifecycle changes
- permission lifecycle changes
- assignment lifecycle changes
- scope changes
- delegation changes
- revocation history

Effective dating shall support:

- temporary access assignments
- time-limited approvals
- audit reconstruction
- historical access review

Silent overwrite is not permitted for materially important authorization state.

---

# 15. Validation Rules

Examples of validation rules:

- Role_Name is required
- Permission_Code is required
- User_Account_ID is required for Role Assignment
- Role_ID is required for Role Assignment
- Scope_Type is required
- Scope_Object_ID is required unless the scope type explicitly permits omission
- Effective_End_Date may not precede Effective_Start_Date
- Retired roles may not receive new active assignments
- Inactive permissions may not be newly assigned to active roles
- Restricted scope combinations must be validated before activation

These validations may be enforced through governance workflows and security rules.

---

# 16. Audit and Traceability Requirements

The system shall preserve:

- role creation history
- permission creation history
- role-permission mapping history
- role assignment history
- scope change history
- delegation history
- revocation history
- sensitive-permission access history

This supports:

- security audit
- compliance review
- incident investigation
- access certification
- privileged access review

---

# 17. Relationship to Security and Access Control

This model provides the structural authorization layer used by Security_and_Access_Control_Model.

Security_and_Access_Control_Model defines:

- broader access principles
- enforcement expectations
- confidentiality handling
- data visibility boundaries
- operational security requirements

Role_and_Permission_Model defines the underlying structural records that support those controls.

---

# 18. Relationship to Other Models

This model integrates with:

- User_Account_Data_Model
- Security_and_Access_Control_Model
- Tenant_Data_Model
- Client_Company_Data_Model
- Legal_Entity_Data_Model
- Platform_Composition_and_Extensibility_Model

---

# 19. Summary

This model establishes Roles, Permissions, and Role Assignments as the governed authorization framework of the platform.

Key principles:

- Role is a logical access package
- Permission is a discrete allowed capability
- Role Assignment binds Role to User Account within an explicit scope
- Scope must remain explicit and auditable
- Sensitive permissions require elevated controls
- Service accounts must remain least-privileged
- Historical authorization state must be preserved
