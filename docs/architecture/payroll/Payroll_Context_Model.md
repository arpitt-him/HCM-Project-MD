# Payroll_Context_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Payroll Domain |
| **Location** | `docs/architecture/payroll/Payroll_Context_Model.md` |
| **Domain** | Payroll |
| **Related Documents** | Payroll_Calendar_Model, Payroll_Run_Model, Security_and_Access_Control_Model, Organizational_Structure_Model, Multi_Context_Calendar_Model |

## Purpose

Defines the structure, identity, lifecycle, and operational scope of Payroll Contexts. A Payroll Context represents the operational boundary within which payroll calculation, validation, approval, export, and reconciliation activities occur.

---

## 1. Core Design Principles

Payroll Contexts shall define operational payroll boundaries. They shall isolate processing activity, support multi-client and multi-company environments, and be explicitly associated with payroll calendars. Configuration shall be auditable.

## 2. Payroll Context Definition

Payroll_Context_ID, Payroll_Context_Name, Client_ID (if applicable), Company_ID, Payroll_Calendar_ID, Payroll_Type, Default_Pay_Date_Rule, Active_Status, Effective_Date, Termination_Date (optional).

## 3. Relationship to Client and Company

One Client may support multiple Payroll Contexts. One Company may support multiple Payroll Contexts. Each Payroll Context belongs to one Client and one Company. Enables controlled segmentation in multi-tenant environments.

## 3.1 Processing Population Scope

A Payroll Context shall define the population scope within which payroll processing occurs.

Processing scope may be defined by:

- Legal_Entity_ID
- Company_ID
- Organizational_Unit_ID (optional)
- Work_Location_ID (optional)
- Payroll_Group_ID (optional)

The defined scope determines:

- which employees are eligible for inclusion in payroll runs
- which accumulators apply
- which reporting obligations apply
- which remittance obligations apply
- which jurisdictional rules apply

Scope definitions shall remain explicit and auditable.

A Payroll Context must not rely on implicit population resolution.

## 4. Payroll Type Classification

Weekly, Biweekly, Semi-Monthly, Monthly, Off-Cycle, Supplemental.

## 4.1 Funding and Remittance Configuration Association

A Payroll Context may be associated with governed financial execution configurations.

These may include:

- Funding_Profile_ID
- Remittance_Profile_ID
- Payment_Instruction_Profile_ID

These configurations define:

- how payroll funding is sourced
- how liabilities are remitted
- how net pay disbursement instructions are generated
- how banking and payment routing occurs

Associations shall remain explicit and auditable.

Funding and remittance behavior shall not be inferred from payroll runs alone.

## 5. Context Lifecycle States

Defined, Configured, Active, Suspended, Closed. Lifecycle transitions shall be auditable and controlled.

## 6. Payroll Run Association

Payroll Runs are associated with a Payroll Context. A context may have many runs. Runs cannot span multiple contexts.

## 7. Security and Access Scoping

Access to a Payroll Context is role-governed. Users may be scoped to specific contexts. Cross-context access requires explicit authorisation.

## 8. Relationship to Other Models

This model integrates with:

- Payroll_Calendar_Model
- Payroll_Run_Model
- Payroll_Run_Result_Set_Model
- Payroll_Adjustment_and_Correction_Model
- Funding_Profile_Data_Model
- Remittance_Profile_Data_Model
- Payment_Instruction_Profile_Data_Model
- Security_and_Access_Control_Model
- Organizational_Structure_Model
- Multi_Context_Calendar_Model
- Run_Visibility_and_Dashboard_Model
