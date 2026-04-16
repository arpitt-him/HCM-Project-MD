# 1. Purpose

This document defines the identity model for the payroll platform.

The model distinguishes between the human being and the
payroll-recognized employment relationship. This separation supports
payroll correctness, rehire scenarios, multi-employment situations,
audit traceability, and future extensibility without weakening the
payroll-centered architecture.

# 2. Core Design Principles

The identity model shall follow these principles:

• Person and employment shall be modeled as distinct concepts.\
• Person_ID represents the human being.\
• Employment_ID represents the payroll-recognized employment
relationship.\
• Payroll calculations, accumulators, results, and exports shall anchor
primarily to Employment_ID.\
• Personal attributes shall not be duplicated unnecessarily across
employment records.\
• The model shall support one person having multiple employment
relationships over time or concurrently.

# 3. Person Definition

A Person represents the individual human being.

Recommended Person fields:

• Person_ID\
• Legal_Name\
• Preferred_Name (optional)\
• Date_of_Birth\
• National_Identifier / SSN (secured)\
• Contact_Attributes (optional)\
• Person_Status

Person records represent enduring human identity and personal attributes
that are independent of any single payroll employment relationship.

# 4. Employment Definition

An Employment represents a payroll-recognized engagement through which
the person is paid.

Recommended Employment fields:

• Employment_ID\
• Person_ID\
• Employer_ID\
• Employee_Number\
• Employment_Type\
• Employment_Start_Date\
• Employment_End_Date (optional)\
• Employment_Status\
• Payroll_Context_ID\
• Home_Country_Code (optional)\
• Home_Legal_Entity_ID (optional)

Employment records represent the unit of payroll calculation, result
production, accumulation, and export.

# 5. Relationship Between Person and Employment

The model supports a one-to-many relationship between Person and
Employment.

Examples:

• One person may have one current employment.\
• One person may have multiple historical employments due to rehire.\
• One person may have multiple concurrent employments where business
policy allows.

Relationship rules:

• Every Employment must reference exactly one Person_ID.\
• A Person may have zero, one, or many Employment_ID values.\
• Employment records may begin and end independently while the Person
record persists.

# 6. Why Employment_ID Is the Payroll Anchor

Payroll operates on the employment relationship rather than the abstract
human being.

Therefore, the following objects shall primarily key to Employment_ID:

• Assignments\
• Calculation results\
• Payables\
• Accumulators\
• Contribution history\
• Export records\
• Payroll status tracking

Person_ID remains important for identity continuity, but payroll state
belongs to the Employment_ID context.

# 7. Rehire Handling

Rehire scenarios shall preserve Person continuity while allowing a
distinct employment relationship where required.

Typical model:

• Person_ID remains constant\
• New Employment_ID is created for the new payroll relationship\
• Historical employment remains traceable

This avoids corrupting prior payroll history while preserving human
identity continuity across employment episodes.

# 8. Concurrent Employment Handling

The model may support concurrent employments for the same person when
permitted by business policy.

Examples may include:

• Multiple legal entities\
• Distinct employment arrangements\
• Separate payroll contexts

In such cases:

• Each employment shall have its own Employment_ID\
• Each employment may have its own Payroll_Context_ID\
• Payroll calculations and accumulators shall remain employment-scoped
unless explicitly defined otherwise

# 9. External Identifier Handling

External-facing payroll and HR systems may use familiar operational
identifiers such as Employee_Number.

Recommended approach:

• Employment_ID serves as the internal canonical payroll identity key\
• Employee_Number serves as an external-facing or operational
identifier\
• Mapping between internal and external identifiers shall be retained

This allows the internal model to remain structurally sound while
preserving operational familiarity.

# 10. Status Models

Person and Employment shall maintain separate status semantics.

Example Person_Status values:

• Active\
• Inactive\
• Deceased\
• Restricted

Example Employment_Status values:

• Pending\
• Active\
• On Leave\
• Suspended\
• Terminated\
• Closed

Employment status governs payroll eligibility more directly than Person
status.

# 11. Effective Dating Considerations

Employment relationships shall support effective dating.

Important dates may include:

• Employment_Start_Date\
• Employment_End_Date\
• Status_Effective_Date\
• Payroll_Context_Effective_Date

Effective dating allows the platform to resolve payroll processing and
assignments correctly across time.

# 12. Data Ownership and Scope

Person records own personal identity attributes.

Employment records own payroll relationship attributes.

Examples:

Person-owned:\
• Legal name\
• Date of birth\
• National identifier

Employment-owned:\
• Employee number\
• Payroll context\
• Employment status\
• Employer assignment

This separation reduces duplication and clarifies stewardship
responsibilities.

# 13. Relationship to Assignment Model

Assignments shall attach to Employment_ID, not directly to Person_ID.

This ensures that:

• Plan eligibility is resolved against the payroll-recognized
relationship\
• Rehires can receive distinct assignments\
• Concurrent employments can carry separate assignment logic

The future assignment model shall build on this identity foundation.

# 14. Audit and Traceability

The platform shall preserve traceability between Person_ID and
Employment_ID across time.

Audit requirements include:

• Link employment history to person continuity\
• Track rehires without destroying historical identity\
• Preserve identifier mappings for downstream systems\
• Support reconstruction of payroll outcomes by employment relationship

# 15. Key Design Principle

Person_ID identifies the human being. Employment_ID identifies the
payroll-recognized relationship through which that person is paid.

Payroll calculations, balances, results, and exports shall anchor to
Employment_ID, while long-lived personal identity continuity shall
anchor to Person_ID.
