# Pay_Statement_Template_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
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

Additional governed attributes may include:

- Template_Version_Number
- Approval_Reference_ID
- Jurisdiction_Profile_ID (optional)
- Legal_Entity_ID (optional)
- Client_Company_ID (optional)
- Rendering_Engine_Type
- Template_Status_Reason

## 2. Relationship to Rendered Pay Statements

Pay statement templates do not define payroll truth.

They define the governed presentation structure used to render employee-facing pay statement artifacts.

Template usage shall remain traceable to:

- Pay_Statement_ID
- Payroll_Check_ID
- Payroll_Run_Result_Set_ID where applicable
- Employee_Payroll_Result_ID where applicable
- Template_ID
- Template_Version_Number

This ensures historical pay statements remain reproducible using the exact template version active at render time.

## 3. Template Sections

Supported sections: Header, Employee Information, Earnings, Deductions, Tax, Employer Contributions, Totals, Payment, Messages, Footer.

## 4. Section Configuration

Section_ID, Section_Name, Display_Order, Visibility_Rule, Formatting_Rule.
Visibility may depend on: presence of data, client configuration, jurisdiction requirements.

Section configuration shall remain versioned and effective-dated.

Changes to section visibility, order, or formatting shall not silently reinterpret previously rendered pay statements.

## 5. Branding Elements

Company Logo, Company Name, Client Name, Color Scheme, Font Settings. Supports multi-client payroll providers and white-label environments.

## 6. Field Mapping

Each display field maps to a data source. Field_Label, Data_Source, Format_Type, Alignment, Display_Condition.
Examples: Employee_Name → Employee_Master; Gross_Earnings → Payroll_Check; YTD_Taxes → Accumulator.

Field mappings shall resolve only against governed source artifacts.

Examples of governed sources include:

- Pay_Statement_Model
- Payroll_Check_Model
- Employee_Payroll_Result_Model
- Accumulator_Definition_Model / Accumulator_Impact_Model
- Code_Classification_and_Mapping_Model

Template mappings shall not introduce independent financial semantics.

## 7. Conditional Display Rules

Show Employer Contributions only if configured. Show Paycard details if Payment_Method = PAYCARD. Show State Tax only if applicable.

Conditional display rules may also depend on:

- jurisdiction-specific disclosure requirements
- legal entity display obligations
- client-specific white-label rules where permitted
- statement correction or reissue status

## 8. Localization Support

Currency formatting, date formatting, language translation, jurisdiction-specific disclosures.

Localization support shall also include jurisdiction-specific statement disclosures, statutory phrasing requirements, and required formatting variations where applicable.

## 9. Versioning and Governance

Template versioning shall support:

- layout changes
- branding changes
- field mapping changes
- conditional display changes
- localization or disclosure changes

Governed attributes include:

- Version_Number
- Approval_Status
- Effective_Date
- Change_Description

Historical templates must remain accessible for audit replay and historical pay statement reconstruction.

Later template versions shall not silently reinterpret previously rendered pay statements.

## 10. Deterministic Template Rendering

Template rendering shall remain deterministic.

Given identical:

- Pay statement source artifact
- template version
- field mappings
- localization settings
- conditional display rules

the platform shall produce the same rendered pay statement output.

Deterministic template rendering is required for:

- audit review
- employee inquiry resolution
- regulatory defensibility
- corrected or reissued statement reconstruction

## 11. Dependencies

This model depends on:

- Pay_Statement_Model
- Payroll_Check_Model
- Employee_Payroll_Result_Model
- Code_Classification_and_Mapping_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Multi_Context_Calendar_Model
- Organizational_Structure_Model
- Correction_and_Immutability_Model

## 12. Relationship to Other Models

This model integrates with:

- Pay_Statement_Model
- Payroll_Check_Model
- Employee_Payroll_Result_Model
- Code_Classification_and_Mapping_Model
- Accumulator_Definition_Model
- Accumulator_Impact_Model
- Multi_Context_Calendar_Model
- Organizational_Structure_Model
- Correction_and_Immutability_Model
- Pay_Statement_Delivery specification where applicable
