**Provider Billing and Charge Model**

*HCM Platform Architecture*

  ----------------------------------------------------------------------------------------------
  **Document**      Provider_Billing_and_Charge_Model.docx   **Version**       0.1
  ----------------- ---------------------------------------- ----------------- -----------------
  **Status**        Draft                                    **Domain**        Interfaces /
                                                                               Billing

  **Basis**         Validated from real PEO example reports  **Date**          April 15, 2026
  ----------------------------------------------------------------------------------------------

  -----------------------------------------------------------------------
  **Design premise.** Provider billing is a downstream financial view
  derived from payroll results, employer obligations, and
  provider-specific fees. It must remain separate from canonical payroll
  truth while still being fully reconcilable to it.
  -----------------------------------------------------------------------

  -----------------------------------------------------------------------

# 1. Purpose and scope

> **•** Define the canonical model for employer-facing provider billing,
> employee-level invoice allocations, and charge classification in
> PEO-style operating environments.
>
> **•** Separate payroll execution facts from provider billing artifacts
> even when external reports blend them into a single surface.
>
> **•** Support custom reporting windows, including non-calendar tax
> years and client-specific date ranges.

# 2. Key observations from source artifacts

> **•** Check detail exports show one coded line per employee check,
> including earnings, deductions, taxes, imputed income, employer
> contributions, and invoice-level charges.
>
> **•** Invoice breakout reports aggregate employer-side costs by
> employee and period, with charge families such as employer benefits,
> employer payroll taxes, worker comp, fees, and billing adjustments.
>
> **•** Identical plan or code values can appear in multiple financial
> contexts. For example, a life insurance plan can produce employer
> contribution, employee deduction, and imputed-income results.
>
> **•** Client reporting periods may follow custom tax-year windows
> rather than calendar year boundaries.

# 3. Core design principles

> **•** Payroll remains authoritative; billing is derived.
>
> **•** Employee-facing payroll semantics and client-facing provider
> billing semantics are distinct canonical classes.
>
> **•** Code meaning is context-sensitive. External code plus external
> code type determines canonical interpretation.
>
> **•** Calendar context must be explicit on billing, reporting, and
> reconciliation artifacts.
>
> **•** Totals should be reproducible from atomic values rather than
> trusted only as imported summaries.

# 4. Canonical domain boundary

The model distinguishes three related but separate financial domains:

  -----------------------------------------------------------------------
  **Domain**              **Primary grain**       **Typical content**
  ----------------------- ----------------------- -----------------------
  Payroll execution       Employee + check +      Earnings, deductions,
                          result line             taxes, imputed income,
                                                  net-pay impacts

  Employer obligation     Employee + period +     Employer taxes,
                          obligation class        employer-paid benefits,
                                                  worker comp, statutory
                                                  and insurance costs

  Provider billing        Employee + invoice      Fees, adjustments,
                          period + charge         billed contributions,
                          allocation              invoice totals,
                                                  client-facing costs
  -----------------------------------------------------------------------

# 5. Conceptual data model

## 5.1 Provider_Invoice

**Required fields:** Invoice_ID, Provider_ID, Client_Entity_ID,
Invoice_Date, Billing_Period_Start, Billing_Period_End,
Calendar_Context_ID, Currency_Code, Invoice_Status,
Imported_Source_Artifact_ID

## 5.2 Employee_Invoice_Allocation

**Required fields:** Employee_Invoice_Allocation_ID, Invoice_ID,
Employee_ID, Employment_ID, Allocation_Period_Start,
Allocation_Period_End, Total_Wages_Basis, Total_Employer_Charges,
Total_Adjustments, Total_Billed_Amount

## 5.3 Provider_Charge_Line

**Required fields:** Provider_Charge_Line_ID,
Employee_Invoice_Allocation_ID, Charge_Family, Charge_Class,
External_Code_Type, External_Code, External_Code_Description, Amount,
Calculation_Mode, Derived_From_Result_Line_ID (optional),
Jurisdiction_ID (optional), Plan_ID (optional), Is_Adjustment,
Is_Summary_Line

# 6. Charge families and canonical classes

  --------------------------------------------------------------------------------------
  **Observed        **Representative   **Canonical class**             **Notes**
  family**          external values**                                  
  ----------------- ------------------ ------------------------------- -----------------
  Employer benefits AET005, AET009,    Benefit_Contribution            Employer-paid or
                    AETDEN, KAI004,                                    billed benefit
                    LIFEX                                              costs; may share
                                                                       codes with
                                                                       employee
                                                                       deductions.

  Employer payroll  FICA-M, FICA-O,    Employer_Statutory_Obligation   Distinct from
  taxes             FUTA, FUTA Debt,                                   employee tax
                    State Unemployment                                 withholding
                                                                       lines.

  Worker comp       WCPEONOT / Worker  Insurance_Charge                May be
                    Comp                                               wage-driven or
                                                                       class-code
                                                                       driven.

  Fees              Service Fee,       Administrative_Fee              Provider
                    Participant Fees,                                  commercial
                    ACA Fees                                           charges, not
                                                                       payroll facts.

  Adjustments       Credit Billing     Billing_Adjustment              Supports negative
                    Adjustment, Return                                 or reversing
                    Deduction                                          charges.

  Wage basis        Regular, HOL,      Wage_Basis_Component            Used as a billing
                    SepPay1x                                           driver, not
                                                                       itself a provider
                                                                       fee.
  --------------------------------------------------------------------------------------

# 7. Relationship to payroll and obligation results

Provider billing may be derived from completed payroll runs, posted
result lines, or imported provider allocations. Regardless of source,
payroll records remain canonical and must never be overwritten by
billing artifacts.

One logical plan can generate multiple financial manifestations. A life
insurance plan, for example, may produce an employer contribution, an
employee deduction, imputed income, and resulting tax effects. The
billing model must preserve these distinctions while allowing
traceability across them.

Where a provider export mixes payroll and billing rows in one report,
the import process must classify each row into the correct canonical
domain before reconciliation or downstream reporting.

# 8. Calendar-context requirements

  -----------------------------------------------------------------------
  **Calendar context**    **Purpose**             **Implication for
                                                  billing model**
  ----------------------- ----------------------- -----------------------
  Payroll calendar        Run scheduling, pay     Provides source periods
                          periods, pay dates      and completion
                                                  boundaries.

  Invoice calendar        Provider billing cycles Defines invoice
                          and invoice dates       grouping and allocation
                                                  windows.

  Tax reporting calendar  Client-specific         Must support
                          tax-year or reporting   non-calendar annual
                          windows                 ranges such as October
                                                  through September.

  Fiscal accounting       Financial close and     May influence report
  calendar                external accounting     requests and
                          workflow                reconciliations but not
                                                  payroll truth.
  -----------------------------------------------------------------------

# 9. Reconciliation rules

> **•** Invoice totals must reconcile to the sum of atomic employee
> allocations and charge lines.
>
> **•** Imported provider summary columns are informative but not
> canonical; system-computed totals should be reproducible from detailed
> values.
>
> **•** Billing charges derived from payroll should retain traceability
> to source payroll runs, result lines, and source files when available.
>
> **•** Negative charges, credits, and return deductions must be modeled
> explicitly rather than netted away silently.
>
> **•** Multi-period on-demand reports must preserve the requested date
> range and calendar context used to generate them.

# 10. Example mapping from validated source patterns

  ----------------------------------------------------------------------------------------------
  **Source pattern**      **Interpretation**   **Canonical destination**       **Calculation
                                                                               mode**
  ----------------------- -------------------- ------------------------------- -----------------
  Invoice_Level_Charges / Per-participant      Administrative_Fee              FIXED
  Participant Fees        billed provider fee                                  

  ConB / LIFEX / ER       Employer-paid life   Benefit_Contribution            DERIVED
  Benefits                benefit cost                                         

  ImpI / LIFEX / Life X   Imputed income       Payroll result, not provider    DERIVED
                          linked to            billing                         
                          employer-paid life                                   
                          coverage                                             

  TaxU / GASWT            Employee Georgia     Payroll result, not provider    PERCENTAGE
                          withholding tax      billing                         

  Employer payroll taxes  Employer statutory   Employer_Statutory_Obligation   DERIVED
  / FUTA                  tax charge                                           

  Wages / Regular         Employee wage basis  Wage_Basis_Component            HOURLY or
                          used in allocation                                   IMPORTED
                          report                                               
  ----------------------------------------------------------------------------------------------

# 11. Non-goals

> **•** This model does not redefine payroll result semantics already
> covered by Result_and_Payable_Model.
>
> **•** This model does not specify provider-specific import file
> parsing rules in full detail.
>
> **•** This model does not replace the need for a separate code
> classification and mapping document.

# 12. Open decisions and follow-on documents

> **•** Create Code_Classification_and_Mapping_Model.docx to formalize
> external-code interpretation across payroll and billing domains.
>
> **•** Decide whether Payroll_Check should be promoted to an explicit
> model document or remain embedded within payroll run and result
> models.
>
> **•** Extend calendar architecture to support named calendar contexts
> and configurable annual boundaries.
>
> **•** Confirm whether company-level invoice totals and invoice
> hierarchy require a separate provider statement or invoice summary
> model.
