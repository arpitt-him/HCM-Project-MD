# Pay_Statement_Template_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Reviewed |
| **Owner** | Architecture Team |
| **Location** | `docs/architecture/interfaces/Pay_Statement_Template_Model.md` |
| **Domain** | Interfaces |
| **Related Documents** | Pay_Statement_Model, Payroll_Check_Model, Code_Classification_and_Mapping_Model, Multi_Context_Calendar_Model, Organizational_Structure_Model |

## Purpose

Defines reusable pay statement templates that control layout, branding, field placement, and conditional display logic across multiple clients or organisations.

---

## 1. Core Template Entity

Pay_Statement_Template: Template_ID, Template_Name, Organization_ID, Template_Type, Effective_Start_Date, Effective_End_Date, Status.
Template_Type examples: STANDARD, PEO_CLIENT, MULTI_ENTITY, REGULATORY_SPECIAL.

## 2. Template Sections

Supported sections: Header, Employee Information, Earnings, Deductions, Tax, Employer Contributions, Totals, Payment, Messages, Footer.

## 3. Section Configuration

Section_ID, Section_Name, Display_Order, Visibility_Rule, Formatting_Rule.
Visibility may depend on: presence of data, client configuration, jurisdiction requirements.

## 4. Branding Elements

Company Logo, Company Name, Client Name, Color Scheme, Font Settings. Supports multi-client payroll providers and white-label environments.

## 5. Field Mapping

Each display field maps to a data source. Field_Label, Data_Source, Format_Type, Alignment, Display_Condition.
Examples: Employee_Name → Employee_Master; Gross_Earnings → Payroll_Check; YTD_Taxes → Accumulator.

## 6. Conditional Display Rules

Show Employer Contributions only if configured. Show Paycard details if Payment_Method = PAYCARD. Show State Tax only if applicable.

## 7. Localization Support

Currency formatting, date formatting, language translation, jurisdiction-specific disclosures.

## 8. Versioning and Governance

Version_Number, Approval_Status, Effective_Date, Change_Description. Historical templates remain accessible for audit replay.

## 9. Relationship to Other Models

This model integrates with: Pay_Statement_Model, Payroll_Check_Model, Code_Classification_and_Mapping_Model, Multi_Context_Calendar_Model, Organizational_Structure_Model.
