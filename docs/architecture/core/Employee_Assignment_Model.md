# 1. Purpose

This document defines the Employee Assignment Model used to associate
Employment_ID values with payroll plans, calculation rules, and
eligibility structures.

Assignments determine which plans, rates, and calculation logic apply to
an employment relationship at any point in time. This model supports
effective dating, rehire handling, retroactivity, and consistent
calculation resolution.

# 2. Core Design Principles

The assignment model shall follow these principles:

• Assignments attach to Employment_ID, not Person_ID.\
• Assignments shall be effective-dated.\
• Multiple assignments may exist across time.\
• Assignment overlap rules shall be explicitly defined.\
• Assignment resolution shall be deterministic.\
• Historical assignments shall remain preserved for audit and
retroactivity.

# 3. Assignment Definition

An Assignment represents the association between an employment
relationship and a payroll or calculation plan.

Recommended Assignment fields:

• Assignment_ID\
• Employment_ID\
• Plan_ID\
• Assignment_Type\
• Assignment_Start_Date\
• Assignment_End_Date (optional)\
• Assignment_Status\
• Payroll_Context_ID\
• Assignment_Priority (optional)\
• Creation_Timestamp\
• Last_Update_Timestamp

Assignments define the applicable calculation configuration for an
employment relationship.

# 4. Assignment Types

Assignments may be categorized by purpose.

Typical Assignment_Type values:

• Primary Assignment\
• Secondary Assignment\
• Temporary Assignment\
• Supplemental Assignment\
• Override Assignment

Assignment type helps determine resolution precedence and behavior.

# 5. Effective Dating Rules

Assignments shall be governed by effective dating.

Required behaviors:

• Every assignment must have an Assignment_Start_Date.\
• Assignment_End_Date may be null for active assignments.\
• Assignments shall not produce gaps unless explicitly allowed.\
• Retroactive assignments shall be permitted when business rules allow.\
• Future-dated assignments shall be supported.

Effective dating ensures accurate historical and future resolution.

# 6. Overlap Handling

Assignment overlaps must be handled through defined resolution rules.

Supported behaviors may include:

• Single active assignment enforcement\
• Multiple concurrent assignments with precedence rules\
• Assignment stacking where applicable\
• Conflict detection and exception generation

Overlap resolution shall be deterministic and auditable.

# 7. Assignment Priority Rules

Where multiple assignments exist simultaneously, priority determines
precedence.

Priority may be defined by:

• Assignment_Priority value\
• Assignment_Type hierarchy\
• Plan precedence configuration\
• Business-defined ranking

Higher priority assignments override lower priority assignments when
conflicts exist.

# 8. Assignment Resolution Logic

Assignment resolution determines which assignment applies during
calculation.

Typical resolution sequence:

1\. Identify Employment_ID\
2. Identify Payroll_Context_ID\
3. Identify Period_ID\
4. Select assignments active during the period\
5. Apply priority rules\
6. Resolve applicable Plan_ID\
7. Execute calculation logic

Resolution logic shall produce a single deterministic outcome per
calculation event unless stacking rules apply.

# 9. Assignment Status Model

Assignments shall maintain defined lifecycle states.

Example Assignment_Status values:

• Pending\
• Active\
• Suspended\
• Expired\
• Terminated\
• Closed

Status affects eligibility and calculation participation.

# 10. Rehire Assignment Handling

Rehire scenarios shall generate new Employment_ID values and
corresponding new assignments.

Behavior:

• Historical assignments remain associated with prior Employment_ID.\
• New assignments attach to the new Employment_ID.\
• No historical reassignment shall occur automatically.\
• Retroactivity shall be explicitly controlled.

This ensures historical accuracy across employment cycles.

# 11. Assignment Scope

Assignments may operate at different scopes.

Typical scopes include:

• Plan-Level\
• Department-Level\
• Location-Level\
• Job-Level\
• Role-Level\
• Individual Override-Level

Scope determines how eligibility and calculation rules apply.

# 12. Relationship to Calculation Model

Assignments provide the link between Employment_ID and calculation
rules.

Assignments determine:

• Which plans apply\
• Which rates are selected\
• Which accumulators are used\
• Which results are generated

Without assignment resolution, calculation logic cannot execute
reliably.

# 13. Retroactive Assignment Changes

Retroactive assignment changes shall trigger recalculation events.

Supported retro behaviors include:

• Backdated assignment correction\
• Plan change retroactivity\
• Assignment termination adjustment\
• Assignment priority correction

Retroactive changes must preserve audit traceability.

# 14. Audit and Traceability

Assignment history shall be preserved for audit purposes.

Required audit capabilities:

• Track assignment creation\
• Track assignment modification\
• Track assignment termination\
• Link assignments to calculation runs\
• Preserve historical assignment state

Assignment traceability supports regulatory compliance and payroll
verification.

# 15. Key Design Principle

Assignments define how an employment relationship participates in
payroll calculation.

Employment_ID determines who is paid. Assignment determines how they are
paid.
