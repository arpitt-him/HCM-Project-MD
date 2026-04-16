# 1. Purpose

This document defines the payroll calendar model used to control
period-based processing across payroll contexts.

Each payroll context maintains its own calendar. Calendar entries
provide the authoritative dates used for payroll calculation,
validation, and release processing. Execution timestamps are recorded
separately for audit purposes but do not control calculation logic.

# 2. Core Principle

Each payroll context shall maintain an independent calendar.

Payroll calculations shall execute using the calendar entry associated
with the specific Payroll_Context_ID and Period_ID. No global payroll
date shall be assumed or inferred.

# 3. Payroll Context Definition

A Payroll Context represents a logical grouping of employees sharing a
common payroll schedule and processing rules.

Typical examples include:

• Weekly Hourly Payroll\
• Bi-Weekly Salaried Payroll\
• Semi-Monthly Payroll\
• Monthly Payroll\
• Country-specific payroll groups\
• Legal-entity-specific payroll groups

Recommended Payroll Context Fields:

• Payroll_Context_ID\
• Payroll_Context_Name\
• Pay_Frequency\
• Legal_Entity_ID (optional)\
• Country_Code (optional)\
• Status

# 4. Payroll Calendar Entry Definition

Each Payroll Context contains multiple calendar entries, each
representing one payroll period.

Recommended Calendar Entry Fields:

• Payroll_Context_ID\
• Period_ID\
• Period_Start_Date\
• Period_End_Date\
• Pay_Date\
• Check_Date (optional if distinct from Pay_Date)\
• Cutoff_Date\
• Calendar_Status

Calendar_Status values may include:

• Open\
• In Progress\
• Calculated\
• Approved\
• Released\
• Closed

# 5. Authoritative Date Usage

The Pay_Date associated with the calendar entry shall be treated as the
authoritative calculation date.

This date governs:

• Tax table resolution\
• Deduction limits\
• Accumulator year determination\
• Benefit logic\
• Regulatory rule selection

Execution timestamps shall be used for audit logging only and shall not
override the Pay_Date logic.

# 6. Multiple Payroll Context Support

The system shall support multiple active payroll contexts
simultaneously.

Examples:

• Weekly Hourly Payroll --- Pay Date: Jan 8\
• Bi-Weekly Payroll --- Pay Date: Jan 15\
• Monthly Payroll --- Pay Date: Jan 31

Each context operates independently using its own calendar entries.

# 7. Rerun Handling

If a payroll run must be repeated, the rerun shall reference the same
Payroll_Context_ID and Period_ID.

The Pay_Date associated with that calendar entry shall remain unchanged,
regardless of the actual system execution date.

Example:

Original Execution:\
Period_ID: December 2026\
Pay_Date: Dec 31 2026\
Execution_Timestamp: Dec 31 2026

Rerun Execution:\
Period_ID: December 2026\
Pay_Date: Dec 31 2026\
Execution_Timestamp: Jan 2 2027

In both cases, December tax logic shall be applied.

# 8. Calendar Lifecycle States

Each calendar entry shall move through defined lifecycle states.

Typical progression:

Open → In Progress → Calculated → Approved → Released → Closed

State transitions should be controlled by authorized users or approved
system processes.

# 9. Relationship to Batch Processing

Batch intake and processing activities shall reference the
Payroll_Context_ID and Period_ID.

This ensures:

• Correct date resolution\
• Accurate accumulator alignment\
• Predictable rerun behavior\
• Clear audit traceability

All batch records must be associated with a valid calendar entry before
calculation begins.

# 10. Future Expansion Considerations

Future enhancements may include:

• Automated calendar generation\
• Holiday-aware pay-date adjustments\
• Calendar simulation capabilities\
• Multi-country regulatory calendars\
• Exception-based cutoff handling

These features should extend the existing context-based calendar model
without altering the core design principle.

# 11. Key Design Principle

All payroll processing shall occur within a defined payroll context and
calendar period.

No payroll calculation shall execute without a valid Payroll_Context_ID
and Period_ID reference.
