# 1. Purpose

This document defines the structure, behavior, and lifecycle rules
governing accumulators and balances within the payroll platform.

Accumulators represent persisted payroll balances and their supporting
contribution history. The design ensures accurate payroll outcomes,
supports reruns and adjustments, preserves audit traceability, and
aligns with payroll calendar and run lifecycle rules.

# 2. Core Design Principles

The accumulator model shall follow these principles:

• Current balances and contribution history shall be stored separately.\
• Balances shall provide fast access to current values.\
• Contribution history shall preserve audit traceability.\
• Recalculation shall not cause participant values to be counted more
than once.\
• Reset and accumulation logic shall align with payroll calendar
periods.\
• Historical traceability shall remain intact after release.

# 3. Accumulator Balance Structure

Accumulator Balance records represent the current authoritative value
for a defined scope.

Recommended Balance Fields:

• Accumulator_ID\
• Scope_Type\
• Participant_ID (if applicable)\
• Employer_ID (if applicable)\
• Plan_ID (if applicable)\
• Period_Context\
• Current_Value\
• Last_Updated_Run_ID\
• Last_Update_Timestamp\
• Balance_Status

Balance records are optimized for quick lookup and update operations.

# 4. Accumulator Contribution History Structure

Contribution History records represent the individual calculation
effects that produced the current balance.

Recommended Contribution Fields:

• Contribution_ID\
• Accumulator_ID\
• Scope_Keys (Participant_ID, Employer_ID, etc.)\
• Source_Run_ID\
• Source_Batch_ID\
• Period_ID\
• Contribution_Amount\
• Contribution_Type\
• Before_Value (optional)\
• After_Value (optional)\
• Reason_Code\
• Creation_Timestamp

Contribution records provide traceability and reconstruction capability.

# 5. Accumulator Scope Types

Accumulators may operate at multiple scopes.

Common Scope Types:

• Participant-Level\
• Participant + Employer\
• Employer-Level\
• Regulatory-Level\
• Plan-Specific\
• Organizational-Level

Scope determines:

• Storage keys\
• Reset logic\
• Update eligibility\
• Retrieval behavior.

# 6. Time Dimensions

Accumulators operate across defined time dimensions.

Supported Dimensions:

• Current Period\
• Quarter-To-Date\
• Year-To-Date\
• Plan-Year\
• Lifetime\
• Custom Period Windows

Time alignment shall reference Payroll_Context_ID and Period_ID from the
Payroll Calendar Model.

# 7. Reset Rules

Accumulator reset behavior shall be explicitly defined.

Supported Reset Types:

• Calendar-Year Reset\
• Plan-Year Reset\
• Quarter Reset\
• No Reset\
• Conditional Reset

Reset logic shall execute at defined calendar boundaries and shall
preserve historical traceability.

# 8. Update Timing Rules

Accumulator updates occur during controlled lifecycle stages.

Typical Update Points:

• During participant calculation\
• During rerun recalculation\
• During adjustment processing\
• During corrective recalculation

Updates shall be transactional and consistent within the scope of a run.

# 9. Recalculation and Replacement Policy

Recalculation shall not cause the same participant result to be counted
more than once for the same calculation context.

Behavior shall follow these rules:

Before Release:

• Prior unreleased participant results may be refreshed or replaced.\
• Contribution history associated with replaced results may be marked
superseded.\
• The balance shall reflect only the latest recalculated values.

After Release:

• Prior released results shall not be silently replaced.\
• Corrections shall be applied through auditable adjustment methods.\
• Adjustments may use reversal, reposting, or delta-based correction.\
• Contribution history shall reflect correction activity.

In all cases:

• Persisted balances shall represent the participant only once for the
applicable calculation context.\
• Historical traceability shall remain intact.

# 10. Idempotency Requirements

Accumulator processing shall support safe rerun behavior.

Repeated processing of the same participant shall:

• Produce identical net results when inputs remain unchanged.\
• Avoid duplicate balance updates.\
• Avoid duplicate contribution records.\
• Maintain consistent state integrity across reruns.

Idempotency shall be enforced through calculation context identification
and controlled persistence rules.

# 11. Adjustment Handling

Adjustments shall update balances and record supporting contributions.

Adjustment behavior may include:

• Prior-period corrections\
• Supplemental adjustments\
• Retroactive recalculations\
• Policy-driven recalculation updates

Adjustment processing shall maintain historical traceability and correct
final balances.

# 12. Audit and Traceability

Accumulator systems shall support complete audit reconstruction.

Required audit capabilities:

• Track all balance changes\
• Track all contribution entries\
• Link contributions to runs and batches\
• Record timestamps and origin sources\
• Maintain historical continuity across recalculations

Audit traceability is mandatory for payroll verification and compliance.

# 13. Performance Considerations

Balance and contribution separation supports performance optimization.

Balance records shall support:

• Fast lookup\
• Minimal contention\
• Efficient update behavior

Contribution history shall support:

• Indexed retrieval\
• Efficient filtering\
• Historical reconstruction capability

Performance tuning shall not compromise data integrity.

# 14. Key Design Principle

Accumulator balances represent current payroll state, while contribution
history represents how that state was produced.

Both shall be preserved independently to support correctness,
auditability, rerun safety, and long-term operational reliability.
