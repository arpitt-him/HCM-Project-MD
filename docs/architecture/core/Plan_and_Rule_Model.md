# 1. Purpose

This document defines the structure and behavior of Plans, Rules, and
Rate Tables within the payroll calculation platform.

Plans provide configuration context for payroll calculations. Rules
define reusable executable logic. Plans reference rules through
structured associations rather than embedding logic directly. This
design supports reuse, flexibility, versioning, and long-term
maintainability.

# 2. Core Design Principle

Plans define configuration context. Rules define executable logic.

Plans shall reference one or more rules through structured associations.
Rules shall remain independently defined and reusable wherever
practical. Plan-specific behavior shall be achieved through
parameterization rather than rule duplication.

# 3. Plan Definition

A Plan represents a payroll or compensation configuration applied to an
employment relationship through assignment.

Recommended Plan fields:

• Plan_ID\
• Plan_Name\
• Plan_Type\
• Plan_Status\
• Payroll_Context_ID\
• Plan_Start_Date\
• Plan_End_Date (optional)\
• Plan_Version_ID\
• Creation_Timestamp\
• Last_Update_Timestamp

Plans act as orchestration containers that determine which rules and
rate tables participate in calculations.

# 4. Rule Definition

A Rule represents reusable executable decision logic.

Recommended Rule fields:

• Rule_ID\
• Rule_Name\
• Rule_Type\
• Rule_Version_ID\
• Rule_Status\
• Rule_Description\
• Default_Execution_Order\
• Creation_Timestamp\
• Last_Update_Timestamp

Rule types may include:

• Eligibility Rule\
• Threshold Rule\
• Rate Selection Rule\
• Cap Rule\
• Floor Rule\
• Recovery Rule\
• Override Rule

Rules remain independent of specific plans to maximize reuse and
maintain consistency.

# 5. Plan--Rule Association Model

Plans shall reference rules through structured association records.

Recommended Plan_Rule_Assignment fields:

• Plan_Rule_Assignment_ID\
• Plan_ID\
• Rule_ID\
• Execution_Order\
• Rule_Parameter_Set_ID\
• Effective_Start_Date\
• Effective_End_Date (optional)\
• Assignment_Status

This association layer enables rules to be reused across multiple plans
while allowing plan-specific behavior through parameterization.

# 6. Rule Parameterization

Rules shall support parameter sets to allow variation without
duplication.

Recommended Parameter fields:

• Rule_Parameter_Set_ID\
• Parameter_Name\
• Parameter_Value\
• Parameter_Data_Type\
• Effective_Start_Date\
• Effective_End_Date

Parameterization allows the same rule logic to operate differently
across plans or periods.

# 7. Rule Sequencing

Rules shall execute in a defined deterministic order.

Typical execution sequence may include:

1\. Eligibility validation\
2. Threshold determination\
3. Rate selection\
4. Cap or floor application\
5. Recovery or adjustment\
6. Final validation

Execution order shall be configurable through Plan_Rule_Assignment
records.

# 8. Rate Table Definition

Rate tables provide structured lookup values used by rules.

Recommended Rate_Table fields:

• Rate_Table_ID\
• Rate_Table_Name\
• Rate_Table_Type\
• Rate_Table_Status\
• Effective_Start_Date\
• Effective_End_Date

Recommended Rate_Row fields:

• Rate_Row_ID\
• Rate_Table_ID\
• Tier_Start_Value\
• Tier_End_Value (optional)\
• Rate_Value\
• Currency_Code\
• Effective_Start_Date\
• Effective_End_Date

Rate tables shall support reuse across multiple plans.

# 9. Plan Versioning Model

Plans shall support versioning rather than overwrite behavior.

Versioning rules:

• Plan changes shall generate new Plan_Version_ID values.\
• Historical versions shall remain preserved.\
• Future versions may be staged prior to activation.\
• Assignments shall reference specific plan versions where required.

Versioning ensures historical reproducibility and audit compliance.

# 10. Rule Versioning Model

Rules shall support independent versioning.

Versioning rules:

• Rule logic changes shall create new Rule_Version_ID values.\
• Prior rule versions shall remain preserved.\
• Plan_Rule_Assignment records shall reference specific rule versions
where necessary.

Rule versioning ensures deterministic recalculation capability.

# 11. Retroactive Plan and Rule Changes

Retroactive changes shall be supported under controlled conditions.

Supported behaviors:

• Backdated plan updates\
• Backdated rule parameter changes\
• Rate table corrections\
• Plan-rule association adjustments

Retroactive changes shall trigger recalculation of impacted periods
while preserving historical lineage.

# 12. Plan Scope Considerations

Plans may operate at multiple organizational scopes.

Typical scopes include:

• Individual Employment\
• Job Classification\
• Department\
• Location\
• Legal Entity\
• Payroll Context

Scope resolution shall integrate with assignment logic.

# 13. Audit and Traceability

All plan and rule activity shall support traceability.

Required audit capabilities:

• Identify which Plan_ID and Plan_Version_ID were used\
• Identify which Rule_ID and Rule_Version_ID executed\
• Identify which Rate_Table_ID and Rate_Row applied\
• Track parameter values used during execution

Audit traceability supports regulatory compliance and calculation
validation.

# 14. Relationship to Assignment Model

Assignments determine which plan applies to an employment relationship.

Processing sequence:

Employment_ID → Assignment → Plan → Rule → Rate → Result

Assignments provide the bridge between employment identity and
executable logic.

# 15. Key Design Principle

Plans orchestrate calculation structure. Rules execute calculation
logic. Rate tables supply values. Parameterization enables flexibility.
Versioning preserves history.
