# Reference_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Reference_Data_Model.md` |
| **Domain** | Core |
| **Related Documents** | PRD-100-Architecture-Principles.md, Plan_and_Rule_Model, Code_Classification_and_Mapping_Model, Organizational_Structure_Model |

## Purpose

Defines the structure, governance, and lifecycle management of reference data used throughout the payroll platform.

Reference data represents standardised codes, classifications, and lookup values used across all system processes.

This model governs how reference values support:

- payroll configuration
- runtime validation
- result classification
- export formatting
- reconciliation
- deterministic replay

Reference data must remain versioned, auditable, and historically reconstructable so that past payroll outcomes continue to interpret codes exactly as they were defined at execution time.

---

## 1. Core Design Principles

Reference values shall be standardised and reusable. Reference data shall be versioned and effective-dated where required. Reference values shall not be duplicated unnecessarily. Changes shall remain auditable. Reference values shall support validation across all system processes.

## 2. Reference Data Definition

Reference_Type, Reference_Code, Reference_Description, Reference_Status, Effective_Start_Date, Effective_End_Date (optional), Reference_Version_ID, Creation_Timestamp, Last_Update_Timestamp.

Additional attributes may include:

Source_System_ID  
Reference_Category_ID  
Jurisdiction_ID  
Usage_Context  
Retirement_Reason_Code  

These attributes support context-sensitive validation and replay-safe interpretation.

## 3. Common Reference Data Categories

Employment_Status, Assignment_Type, Plan_Type, Rule_Type, Result_Type, Payable_Type, Deduction_Type, Tax_Type, Currency_Code, Country_Code, Legal_Entity_Code, Location_Code, Department_Code, Job_Code, Organizational_Unit_Code.

Additional categories may include:

Run_Type  
Scope_Type  
Relationship_Type  
Result_Status  
Exception_Type  
Payment_Method  
Remittance_Type  
Holiday_Type  
Leave_Type  
Accrual_Method  
Premium_Type

## 4. Reference Data Hierarchies

Certain categories support hierarchical relationships (e.g., organisational hierarchy, department hierarchy, location hierarchy). Parent_Code, Child_Code, Hierarchy_Level, Effective_Start_Date, Effective_End_Date.

## 5. Effective Dating Requirements

Reference values shall not be overwritten. New versions shall be created when changes occur. Historical values shall remain available for recalculation. Future-dated values shall be supported.

Historical payroll replay shall reference the reference-data version effective at the time of original execution.

Reference changes must never silently redefine historical payroll, tax, accrual, export, or reconciliation outcomes.

## 6. Reference Versioning Model

Changes generate new Reference_Version_ID values. Historical versions remain preserved. Assignments and calculations reference specific versions where required. Version lineage shall remain traceable.

Runtime models may reference specific reference-data versions where deterministic execution requires it, including:

- plan and rule resolution
- result classification
- tax treatment
- export formatting
- reconciliation matching

## 7. Validation Integration

Reference data supports validation across all system processes.

Examples include:

- reject invalid codes during data intake
- validate assignments against allowed values
- enforce valid rule configuration values
- validate payroll result classification values
- validate export formatting requirements
- validate reconciliation matching dimensions

Invalid or retired reference values must not be allowed to create silent financial or reporting impact.

## 8. Reference Data Governance

Defining allowable reference values, approving reference changes, maintaining reference documentation, monitoring usage consistency, managing retirement of obsolete codes. Governance ensures reliable system-wide standardisation.

## 9. Reference Change Management

Change request submission, impact analysis, approval workflow, version creation, effective-date activation, historical retention. Reference changes must not disrupt historical calculations.

Where a reference-data change affects historical interpretation, the platform must preserve the prior reference version and route any necessary downstream correction through governed replay or adjustment workflows rather than redefining history in place.

## 10. Reference Retirement Handling

Retired values shall not be deleted. Retired values shall be marked inactive. Historical records referencing retired values shall remain valid. New assignments shall not use retired values.

## 10.1 Relationship to Runtime Execution

Reference data is not only administrative metadata; it is a governed execution dependency.

Runtime processes may consume reference data for:

- assignment resolution
- plan and rule selection
- employee payroll result classification
- accumulator routing
- remittance grouping
- export formatting
- reconciliation matching

This ensures that reference values remain part of deterministic execution lineage rather than passive lookup tables only.

## 11. Relationship to Other Models

This model integrates with:

- Plan_and_Rule_Model
- Code_Classification_and_Mapping_Model
- Rule_Resolution_Engine
- Tax_Classification_and_Obligation_Model
- Employee_Assignment_Model
- Employee_Payroll_Result_Model
- Accumulator_Impact_Model
- Payroll_Interface_and_Export_Model
- Payroll_Reconciliation_Model
- Payroll_Exception_Model
- Organizational_Structure_Model
