# Organizational_Structure_Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.2 |
| **Status** | Approved |
| **Owner** | Core Platform |
| **Location** | `docs/architecture/core/Organizational_Structure_Model.md` |
| **Domain** | Core |
| **Related Documents** | PRD-200-Core-Entity-Model.md, Employment_and_Person_Identity_Model, Reference_Data_Model, Jurisdiction_and_Compliance_Rules_Model, Security_and_Access_Control_Model |

## Purpose

Defines the structure, hierarchy, and lifecycle management of organisational entities within the payroll platform.

Supports employee assignment resolution, payroll-context alignment, reporting rollups, eligibility determination, legal compliance, jurisdictional alignment, and replay-safe historical interpretation.

Organisational structures provide governed context that influences payroll calculation, taxation, remittance, accounting export, and reconciliation.

---

## 1. Core Design Principles

Organisational units shall be hierarchical and support effective dating. Changes shall preserve historical lineage. Organisational relationships shall be auditable. Rollup relationships shall be deterministic.

## 2. Organisational Unit Definition

Org_Unit_ID, Org_Unit_Type, Org_Unit_Code, Org_Unit_Name, Parent_Org_Unit_ID (optional), Org_Level, Effective_Start_Date, Effective_End_Date (optional), Org_Status, Creation_Timestamp, Last_Update_Timestamp.

Additional organisational attributes may include:

Org_Unit_Version_ID  
Jurisdiction_ID  
Source_Event_ID  
Source_Period_ID  
Execution_Period_ID  

These attributes support deterministic organisational interpretation during payroll execution and replay.

## 3. Organisational Unit Types

Legal Entity, Division, Business Unit, Department, Cost Center, Location, Region, Country. Each type shall be managed as a distinct classification.

## 4. Hierarchy Relationships

Parent-child relationships define reporting structure. Each unit may have one parent and multiple children. Hierarchies shall prevent circular relationships. Hierarchy changes shall maintain historical traceability.

Hierarchy changes must not silently redefine historical payroll, reporting, tax, or accounting outcomes.

Historical hierarchy states shall remain queryable for replay, audit, and reconciliation.

## 5. Effective Dating Requirements

Changes create new effective-dated records. Historical structures remain preserved. Future organisational changes may be staged. Lookups shall resolve by effective date.

Effective-dated lookups must resolve the organisational state that was in force at the time of payroll execution, export generation, and reconciliation.

## 6. Rollup and Aggregation Behaviour

Department totals roll up to Business Unit totals. Business Units roll up to Legal Entity totals. Locations roll up to regional totals. Rollup behaviour shall remain consistent and deterministic.

Rollup behaviour shall support:

- payroll reporting
- liability aggregation
- remittance grouping
- accounting export summarisation
- reconciliation analysis

Rollup resolution must remain deterministic across historical periods.

## 7. Legal Entity Modelling

Legal_Entity_ID, Legal_Entity_Code, Legal_Entity_Name, Country_Code, Tax_Registration_Number, Effective_Start_Date, Effective_End_Date. Legal entities define taxation and regulatory jurisdiction boundaries.

Legal entities also govern:

- payroll context boundaries
- remittance responsibility
- accounting export ownership
- employer-level accumulator scope

Legal-entity interpretation must remain stable for historical payroll periods.

## 8. Location Modelling

Location_ID, Location_Code, Location_Name, Address_Attributes, Country_Code, State_Code, Locality_Code, Effective_Start_Date, Effective_End_Date. Locations influence tax jurisdiction resolution and reporting.

Locations may influence:

- tax jurisdiction resolution
- premium eligibility
- scheduling and time interpretation
- leave eligibility
- reporting attribution

Location history must remain reconstructable for payroll replay.

## 9. Department and Cost Center Modelling

Department_ID, Department_Code, Department_Name, Parent_Department_ID, Effective_Start_Date, Effective_End_Date. Cost centers support financial allocation and reporting.

## 10. Organisational Assignment Integration

Employment_ID links to Department_ID, Location_ID, Legal_Entity_ID, and other organisational dimensions as required.

Organisational assignments support:

- eligibility and calculation logic
- payroll context participation
- tax routing
- reporting and reconciliation attribution
- accounting export dimensions

Resolved organisational context shall remain traceable to payroll execution artifacts, including payroll runs and employee payroll results where applicable.

## 11. Audit and Traceability

Organisational change history, effective date lineage, parent-child relationship changes, and responsible user or system must all be captured. Audit supports regulatory and financial reporting requirements.

Audit and traceability shall also support reconstruction of the organisational state used for:

- payroll calculation
- result generation
- export creation
- remittance grouping
- reconciliation analysis

## 11.1 Relationship to Other Models

This model integrates with:

- Employment_and_Person_Identity_Model
- Employee_Assignment_Model
- Payroll_Context_Model
- Payroll_Run_Result_Set_Model
- Employee_Payroll_Result_Model
- Tax_Classification_and_Obligation_Model
- Payroll_Run_Funding_and_Remittance_Map
- General_Ledger_and_Accounting_Export_Model
- Payroll_Reconciliation_Model
- Security_and_Access_Control_Model
- Reference_Data_Model
- Jurisdiction_and_Compliance_Rules_Model

## 12. Key Design Principle

Organisational structures define where employees belong within the enterprise. Effective-dated hierarchical structures ensure accurate payroll processing, reporting, and compliance across organisational boundaries.
