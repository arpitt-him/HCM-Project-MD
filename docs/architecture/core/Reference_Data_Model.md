# Reference_Data_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Reference_Data_Model.md` |
| **Domain** | Core |
| **Related Documents** | PRD-100-Architecture-Principles.md, Plan_and_Rule_Model, Code_Classification_and_Mapping_Model, Organizational_Structure_Model |

## Purpose

Defines the structure, governance, and lifecycle management of reference data used throughout the payroll platform. Reference data represents standardised codes, classifications, and lookup values used across all system processes.

---

## 1. Core Design Principles

Reference values shall be standardised and reusable. Reference data shall be versioned and effective-dated where required. Reference values shall not be duplicated unnecessarily. Changes shall remain auditable. Reference values shall support validation across all system processes.

## 2. Reference Data Definition

Reference_Type, Reference_Code, Reference_Description, Reference_Status, Effective_Start_Date, Effective_End_Date (optional), Reference_Version_ID, Creation_Timestamp, Last_Update_Timestamp.

## 3. Common Reference Data Categories

Employment_Status, Assignment_Type, Plan_Type, Rule_Type, Result_Type, Payable_Type, Deduction_Type, Tax_Type, Currency_Code, Country_Code, Legal_Entity_Code, Location_Code, Department_Code, Job_Code, Organizational_Unit_Code.

## 4. Reference Data Hierarchies

Certain categories support hierarchical relationships (e.g., organisational hierarchy, department hierarchy, location hierarchy). Parent_Code, Child_Code, Hierarchy_Level, Effective_Start_Date, Effective_End_Date.

## 5. Effective Dating Requirements

Reference values shall not be overwritten. New versions shall be created when changes occur. Historical values shall remain available for recalculation. Future-dated values shall be supported.

## 6. Reference Versioning Model

Changes generate new Reference_Version_ID values. Historical versions remain preserved. Assignments and calculations reference specific versions where required. Version lineage shall remain traceable.

## 7. Validation Integration

Reject invalid codes during data intake. Validate assignments against allowed values. Enforce valid rule configuration values. Validate export formatting requirements.

## 8. Reference Data Governance

Defining allowable reference values, approving reference changes, maintaining reference documentation, monitoring usage consistency, managing retirement of obsolete codes. Governance ensures reliable system-wide standardisation.

## 9. Reference Change Management

Change request submission, impact analysis, approval workflow, version creation, effective-date activation, historical retention. Reference changes must not disrupt historical calculations.

## 10. Reference Retirement Handling

Retired values shall not be deleted. Retired values shall be marked inactive. Historical records referencing retired values shall remain valid. New assignments shall not use retired values.

## 11. Relationship to Other Models

Reference data supports all other system models: identity (status codes), assignment (assignment types), plan (plan classifications), rule (rule categories), result (payable types), export (formatting codes), reconciliation (classification values).
