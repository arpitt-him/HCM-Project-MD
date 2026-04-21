# Holiday_and_Special_Calendar_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/payroll/Holiday_and_Special_Calendar_Model.md` |
| **Domain** | Payroll |
| **Related Documents** | Multi_Context_Calendar_Model, Payroll_Calendar_Model, Time_Entry_and_Worked_Time_Model, Overtime_and_Premium_Pay_Model, Leave_and_Absence_Management_Model |

## Purpose

Defines structures governing holidays and special calendar dates that affect payroll, premium pay, leave eligibility, and compliance rules.

This model governs calendar-based events that influence:

- worked-time interpretation
- premium eligibility
- leave entitlement interaction
- payroll result generation
- jurisdictional compliance validation

Holiday definitions act as governed temporal events that modify payroll behaviour through rule-driven logic.

---

## 1. Holiday Scope

Federal Holidays, State Holidays, Local Holidays, Company Holidays, Observed Holidays, Floating Holidays, Union Holidays, Special Event Days.

## 2. Core Holiday Entity

Holiday_ID, Holiday_Name, Holiday_Type, Jurisdiction_ID, Holiday_Date, Observed_Date, Calendar_Context_ID, Status.
Holiday_Type: FEDERAL, STATE, LOCAL, COMPANY, UNION, FLOATING, SPECIAL_EVENT.

Additional holiday attributes may include:

Holiday_Version_ID  
Source_Jurisdiction_ID  
Rule_Set_Reference  
Eligibility_Profile_ID  
Holiday_Premium_Profile_ID  

These attributes support deterministic holiday interpretation across replay and retroactive recalculation.

## 3. Observed Date Rules

Holiday on Saturday → Observed Friday. Holiday on Sunday → Observed Monday. Company-specific observed policies. Observed dates must remain auditable.

Observed date determination shall be governed by rule-driven evaluation.

Observed dates must remain:

- versioned
- jurisdiction-aware
- reproducible across historical replay

Observed date logic must never rely on implicit calendar assumptions.

## 4. Holiday Eligibility

Eligibility shall be determined through rule-driven evaluation.

Eligibility factors may include:

- employment status
- department
- work location
- union membership
- service duration
- employment classification

Eligibility resolution shall be performed through Policy_and_Rule_Execution_Model using governed employee and employment context.

## 5. Payroll Impact Handling

Holiday definitions may generate payroll outcomes, including:

- holiday pay earnings
- holiday premium earnings
- work-on-holiday premium
- scheduled holiday substitution earnings

Holiday-triggered earnings shall generate structured result lines associated with Employee Payroll Results.

All holiday-related payroll outcomes must remain traceable to:

- Holiday_ID
- Calendar_Context_ID
- Time_Entry_ID
- Employee_Payroll_Result_ID

## 6. Leave Interaction

Holiday definitions may interact with leave processing, including:

- holiday occurring during approved leave
- holiday exclusion from leave consumption
- holiday substitution during leave periods

Leave interaction logic shall remain:

- rule-driven
- jurisdiction-aware
- traceable to governing policy definitions

Holiday-leave interactions must produce deterministic leave and payroll outcomes.

## 7. Jurisdiction Integration

Federal holiday rules, state-specific observances, local municipality holidays. Jurisdiction_ID determines applicability.

Jurisdictional holiday resolution may follow hierarchical precedence, including:

- national holidays
- regional or state holidays
- municipal holidays
- employer-defined holidays
- union-specific holidays

Jurisdiction hierarchy must remain explicit and version-controlled.

## 8. Special Calendar Events

Company shutdown days, emergency closures, election days, disaster recovery schedules. Special events may trigger non-standard payroll processing.

Special calendar events may trigger:

- payroll schedule changes
- mass leave suppression
- forced payroll recalculation
- operational shutdown workflows

Special events must remain traceable to source authority and approval.

## 9. Relationship to Other Models

This model integrates with:

- Multi_Context_Calendar_Model
- Payroll_Calendar_Model
- Scheduling_and_Shift_Model
- Time_Entry_and_Worked_Time_Model
- Overtime_and_Premium_Pay_Model
- Policy_and_Rule_Execution_Model
- Employee_Payroll_Result_Model
- Payroll_Exception_Model
- Leave_and_Absence_Management_Model
- Payroll_Adjustment_and_Correction_Model


