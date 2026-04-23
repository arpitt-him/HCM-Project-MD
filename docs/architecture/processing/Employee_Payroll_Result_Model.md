# Employee_Payroll_Result_Model

| Field | Detail |
|---|---|
| **Document Type** | Data Model |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll Processing Domain |
| **Location** | docs/architecture/processing/Employee_Payroll_Result_Model.md |
| **Domain** | Employee Payroll Results / Gross-to-Net / Payroll Output Detail |
| **Related Documents** | Payroll_Run_Result_Set_Model.md, Employment_Data_Model.md, Net_Pay_Disbursement_Data_Model.md, Rule_Pack_Model.md, Tax_Classification_and_Obligation_Model.md, Accumulator_Model_Detailed.md, Pay_Statement_Model.md |

---

# Purpose

This document defines the core data structure for **Employee Payroll Result** as the detailed payroll outcome for an individual Employment within a Payroll Run Result Set.

Employee Payroll Result is the governed structure that captures how payroll resolved for one worker relationship in one payroll execution context.

It exists to preserve:

- earnings detail
- deduction detail
- tax detail
- employer contribution detail
- net pay derivation
- accumulator impacts
- jurisdictional splits
- pay-statement-ready output structure

This model supports:

- deterministic replay
- pay statement generation
- audit reconstruction
- tax and deduction tracing
- reconciliation
- correction and adjustment handling
- employee inquiry resolution

without reducing employee-level payroll outcomes to only gross pay and net pay totals.

---

# Core Structural Role

```text
Payroll Run Result Set
    └── Employee Payroll Result
            ├── Earnings Result Lines
            ├── Deduction Result Lines
            ├── Tax Result Lines
            ├── Employer Contribution Result Lines
            ├── Net Pay Result
            ├── Accumulator Impacts
            └── Pay Statement Output Reference
```

Employee Payroll Result is the detailed worker-level execution output beneath the Payroll Run Result Set.

---

# 1. Employee Payroll Result Definition

An **Employee Payroll Result** represents the full detailed payroll outcome for one Employment within one Payroll Run Result Set.

An Employee Payroll Result may include:

- regular earnings
- overtime earnings
- premium earnings
- supplemental earnings
- deductions
- employee taxes
- employer taxes and contributions
- net pay outcomes
- accumulator updates
- jurisdictional allocation details

Employee Payroll Result shall be modeled as distinct from:

- Employment
- Payroll Run
- Payroll Run Result Set
- Net Pay Disbursement
- Funding Result Set
- Remittance Result Set
- Pay Statement document

Employee Payroll Result is the detailed payroll outcome record, not the employment relationship or the payment itself.

---

# 2. Employee Payroll Result Primary Attributes

| Field Name | Description |
|---|---|
| Employee_Payroll_Result_ID | Unique identifier |
| Payroll_Run_Result_Set_ID | Parent payroll run result set reference |
| Payroll_Run_ID | Parent payroll run reference |
| Run_Scope_ID | Run scope reference identifying the governed population segment |
| Employment_ID | Employment reference |
| Person_ID | Person reference |
| Payroll_Context_ID | Payroll context reference |
| Source_Period_ID | Original payroll period to which results logically belong |
| Execution_Period_ID | Period during which processing execution occurred |
| Parent_Employee_Payroll_Result_ID | Prior worker-level result in lineage where applicable |
| Root_Employee_Payroll_Result_ID | Root worker-level result in lineage chain |
| Result_Lineage_Sequence | Sequence number within worker-level result lineage |
| Correction_Reference_ID | Governing correction reference where applicable |
| Result_Status | Calculated, Approved, Released, Finalized, Corrected, Reversed |
| Pay_Period_Start_Date | Period start date |
| Pay_Period_End_Date | Period end date |
| Pay_Date | Scheduled pay date |
| Gross_Pay_Amount | Total gross earnings |
| Total_Deductions_Amount | Total deductions |
| Total_Employee_Tax_Amount | Total employee tax |
| Total_Employer_Contribution_Amount | Total employer contribution |
| Net_Pay_Amount | Final net pay |
| Created_Timestamp | Record creation timestamp |
| Updated_Timestamp | Last update timestamp |

---

# 3. Earnings Result Lines

Employee Payroll Result shall support one or more **Earnings Result Lines**.

```text
Employee Payroll Result
    └── Earnings Result Line (0..n)
```

Earnings Result Lines may represent:

- regular pay
- overtime
- shift premium
- bonus
- commission
- retro earning
- leave-paid earnings
- holiday earnings
- imputed income
- other earning types

Minimum fields:

| Field Name | Description |
|---|---|
| Earnings_Result_Line_ID | Unique identifier |
| Employee_Payroll_Result_ID | Parent reference |
| Earnings_Code | Earnings type/code |
| Earnings_Description | Human-readable description |
| Quantity | Hours, units, or quantity |
| Rate | Applied rate |
| Calculated_Amount | Resulting amount |
| Jurisdiction_Split_Flag | Indicates split across jurisdictions |
| Taxable_Flag | Indicates taxable treatment |
| Accumulator_Impact_Flag | Indicates accumulator impact |

Each earnings line must remain traceable to the rule and source logic that produced it.

Earnings result lines shall preserve linkage to source payroll result lineage and source rule execution context where applicable.

---

# 4. Deduction Result Lines

Employee Payroll Result shall support one or more **Deduction Result Lines**.

```text
Employee Payroll Result
    └── Deduction Result Line (0..n)
```

Deduction Result Lines may represent:

- benefit deductions
- garnishments
- retirement contributions
- union dues
- charitable deductions
- post-tax deductions
- pre-tax deductions
- loan repayments
- arrears catch-up deductions

Minimum fields:

| Field Name | Description |
|---|---|
| Deduction_Result_Line_ID | Unique identifier |
| Employee_Payroll_Result_ID | Parent reference |
| Deduction_Code | Deduction type/code |
| Deduction_Description | Human-readable description |
| Deduction_Category | PreTax, PostTax, Garnishment, Benefit, Other |
| Calculated_Amount | Resulting amount |
| Withholding_Order | Deduction sequence/order |
| Accumulator_Impact_Flag | Indicates accumulator impact |

Deduction lines must preserve enough detail to reconstruct priority and ordering behavior.

Deduction result lines shall preserve linkage to source payroll result lineage, withholding priority, and correction lineage where applicable.

---

# 5. Tax Result Lines

Employee Payroll Result shall support one or more **Tax Result Lines**.

```text
Employee Payroll Result
    └── Tax Result Line (0..n)
```

Tax Result Lines may represent:

- federal withholding
- state withholding
- local withholding
- social insurance taxes
- unemployment taxes where employee share applies
- treaty adjustments
- special authority taxes

Minimum fields:

| Field Name | Description |
|---|---|
| Tax_Result_Line_ID | Unique identifier |
| Employee_Payroll_Result_ID | Parent reference |
| Tax_Code | Tax type/code |
| Tax_Description | Human-readable description |
| Jurisdiction_ID | Jurisdiction reference |
| Taxable_Wage_Base | Wage base used |
| Tax_Rate | Applied rate where applicable |
| Calculated_Amount | Resulting tax amount |
| Employer_vs_Employee_Flag | Indicates employee or employer side |

Tax lines must preserve enough detail to reconstruct jurisdiction-specific tax treatment.

Tax result lines shall preserve linkage to tax classification lineage, jurisdiction context, and source payroll result lineage.

---

# 6. Employer Contribution Result Lines

Employee Payroll Result shall support one or more **Employer Contribution Result Lines**.

```text
Employee Payroll Result
    └── Employer Contribution Result Line (0..n)
```

These lines may represent:

- employer social taxes
- employer retirement contributions
- employer health contributions
- employer-paid benefit amounts
- employer payroll fees where allocated at employee level

Minimum fields:

| Field Name | Description |
|---|---|
| Employer_Contribution_Result_Line_ID | Unique identifier |
| Employee_Payroll_Result_ID | Parent reference |
| Contribution_Code | Contribution type/code |
| Contribution_Description | Human-readable description |
| Jurisdiction_ID | Jurisdiction reference where relevant |
| Calculated_Amount | Resulting amount |
| Accumulator_Impact_Flag | Indicates accumulator impact |

Employer contribution lines support employer liability tracing and reporting.

Employer contribution lines shall preserve linkage to employer liability lineage and source payroll result lineage where applicable.

---

# 7. Net Pay Result

Employee Payroll Result shall contain one **Net Pay Result**.

```text
Employee Payroll Result
    └── Net Pay Result (1)
```

Minimum fields:

| Field Name | Description |
|---|---|
| Net_Pay_Result_ID | Unique identifier |
| Employee_Payroll_Result_ID | Parent reference |
| Gross_Pay_Amount | Gross total |
| Total_Reductions_Amount | Deductions + employee tax total |
| Net_Pay_Amount | Final net result |
| Negative_Net_Pay_Flag | Indicates negative outcome |
| Hold_Flag | Indicates hold before disbursement |
| Review_Required_Flag | Indicates manual review required |

Net Pay Result captures the worker-level gross-to-net summary, while the detailed lines preserve full derivation.

Net Pay Result shall remain distinct from payment execution, while preserving linkage to downstream disbursement and replacement/reissue lineage where applicable.

---

# 8. Accumulator Impacts

Employee Payroll Result shall support one or more **Accumulator Impact** records.

```text
Employee Payroll Result
    └── Accumulator Impact (0..n)
```

Accumulator impacts may update:

- YTD earnings
- YTD tax
- YTD deductions
- YTD employer contributions
- leave-related balances
- jurisdiction-specific reporting totals

Minimum fields:

| Field Name | Description |
|---|---|
| Accumulator_Impact_ID | Unique identifier |
| Employee_Payroll_Result_ID | Parent reference |
| Accumulator_Code | Accumulator reference |
| Prior_Value | Value before update |
| Delta_Value | Change applied |
| New_Value | Value after update |

Accumulator impacts must remain explicit to support replay and reporting integrity.

---

# 9. Jurisdictional Split Handling

Employee Payroll Result may require jurisdictional allocation across multiple authorities.

Examples include:

- work in multiple localities
- residence/work split tax treatment
- multistate work allocation
- authority-specific taxable wage allocation

The model shall support:

- multiple tax result lines by jurisdiction
- multiple earnings allocation references where needed
- explicit jurisdiction identifiers on relevant result lines

Jurisdictional allocation must be deterministic and traceable.

---

# 10. Relationship to Net Pay Disbursement

Employee Payroll Result is not the payment itself, but it is the immediate source of worker payment obligation.

Typical relationship:

```text
Employee Payroll Result
    └── Net Pay Disbursement (0..n)
```

This supports:

- one net pay result → one payment
- one net pay result → split payments
- one net pay result → held payment pending review
- one net pay result → reissued or reversed payment lineage

The payroll result must remain preserved even if disbursement fails, is returned, or is replaced.

---

# 11. Relationship to Pay Statement Output

Employee Payroll Result provides the data basis for pay statement generation.

Typical path:

```text
Employee Payroll Result
    └── Pay Statement Output / Reference
```

Pay statements may be generated from the result using:

- earnings lines
- deduction lines
- tax lines
- employer contribution display logic
- accumulator/YTD values
- net pay result

Employee Payroll Result remains the underlying governed source even if a rendered pay statement is later regenerated.

Rendered pay statements may be regenerated using governed template versions, but Employee Payroll Result remains the authoritative worker-level source artifact for statement content.

---

# 12. Result Status Model

Suggested Result_Status values:

| Status | Meaning |
|---|---|
| Calculated | Computation complete, not yet approved |
| Approved | Approved for downstream release |
| Released | Released for disbursement/remittance processes |
| Finalized | Locked as final result |
| Corrected | Superseded or adjusted by correction process |
| Reversed | Reversed through governed correction logic |

Status transitions shall be governed and auditable.

Finalized results must not be silently edited.

Corrections shall be handled through adjustment, reversal, or replacement models.

---

## 12.1 Exception Association

Employee Payroll Result may be associated with one or more Payroll Exception records.

```text
Employee Payroll Result
        └── Payroll Exception (0..n)
```

---

# 13. Effective Dating and Historical Preservation

Employee Payroll Result is an execution artifact and is therefore naturally historical.

However, the model must preserve:

- the exact calculation outputs
- the exact lines produced
- the exact accumulator impacts
- the exact jurisdictional allocations
- the exact net pay derivation
- the exact configuration lineage used

Historical results must never be overwritten in place once finalized.

This is mandatory for replay, audit, and correction integrity.

---

# 14. Validation Rules

Examples of validation rules:

- Payroll_Run_Result_Set_ID is required
- Employment_ID is required
- Person_ID is required
- Gross_Pay_Amount must equal the total of earnings lines where applicable
- Net_Pay_Amount must reconcile to gross minus deductions and taxes
- Tax line totals must reconcile to Total_Employee_Tax_Amount where applicable
- Accumulator impacts must reference valid accumulators
- Finalized results may not be edited outside governed correction logic
- Jurisdictional splits must reconcile to total taxable wage and total tax where applicable

These validations shall be enforced before finalization.

---

# 15. Deterministic Replay Requirements

Employee Payroll Result reconstruction shall remain deterministic.

Given identical:

- Payroll_Run_Result_Set_ID
- Employment_ID
- Payroll_Context_ID
- Source_Period_ID
- Execution_Period_ID
- rule and configuration lineage
- applicable calendar and jurisdiction context

the platform shall reconstruct the same worker-level payroll result, including:

- earnings lines
- deduction lines
- tax lines
- employer contribution lines
- net pay result
- accumulator impacts
- jurisdictional allocations

Later rule, configuration, calendar, or scope changes shall not silently reinterpret historical employee payroll results.

---

# 16. Audit and Traceability Requirements

The system shall preserve:

- result creation history
- result status history
- earnings line history
- deduction line history
- tax line history
- employer contribution line history
- accumulator impact history
- jurisdiction allocation history
- disbursement linkage history
- correction/reversal lineage

This supports:

- payroll audit
- employee inquiry handling
- tax review
- compliance investigation
- deterministic replay
- correction traceability

---

# 17. Dependencies

This model depends on:

- Payroll_Run_Result_Set_Model
- Payroll_Run_Model
- Run_Scope_Model
- Payroll_Context_Model
- Payroll_Calendar_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Rule_Pack_Model
- Tax_Classification_and_Obligation_Model
- Accumulator_Impact_Model
- Correction_and_Immutability_Model

---

# 18. Relationship to Other Models

This model integrates with:

- Payroll_Run_Result_Set_Model
- Payroll_Run_Model
- Run_Scope_Model
- Payroll_Context_Model
- Payroll_Adjustment_and_Correction_Model
- Payroll_Exception_Model
- Net_Pay_and_Disbursement_Model
- Rule_Pack_Model
- Tax_Classification_and_Obligation_Model
- Accumulator_Impact_Model
- Accumulator_Model_Detailed
- Pay_Statement_Model
- Payroll_Check_Model

---

# 19. Summary

This model establishes Employee Payroll Result as the detailed worker-level payroll outcome beneath the Payroll Run Result Set.

Key principles:

- Employee Payroll Result is the detailed gross-to-net outcome for one Employment in one run
- Employee Payroll Result preserves earnings, deductions, taxes, employer contributions, net pay, and accumulator impacts
- Employee Payroll Result supports jurisdictional splits and downstream pay statement generation
- Employee Payroll Result remains distinct from disbursement, remittance, and funding configuration
- Historical integrity and replayability are mandatory
