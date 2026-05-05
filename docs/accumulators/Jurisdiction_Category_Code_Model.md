# Jurisdiction Category Code Model

| Field | Detail |
|---|---|
| **Document Type** | Architecture Model |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/accumulators/Jurisdiction_Category_Code_Model.md` |
| **Domain** | Accumulators / Jurisdiction |
| **Related Documents** | `Accumulator_Model_Detailed.md`, `Accumulator_and_Balance_Model.md`, `docs/SPEC/Accumulator_Display.md`, `docs/SPEC/Benefits_Minimum_Module.md` |

---

## Purpose

Defines the classification layer that sits above accumulator definitions and governs how accumulator balances are grouped for display, reconciliation, and reporting. Two fundamentally different classification hierarchies apply depending on whether the accumulator is tax-driven or benefit-driven. The two hierarchies run in **opposite directions** and must not be conflated.

---

## 1. Tax Classification — Authority-Down

Tax categories are mandated by the governing tax authority of the national jurisdiction. A legal entity has no authority to define or alter tax categories — it can only operate within the categories the tax authority has established. This makes the hierarchy strictly top-down.

```
National Jurisdiction  (defines all base tax category codes — IRS, CRA, HMRC, ATO)
        ↓
Sub-Jurisdiction       (additive state/province codes — SDI, PFL, local income tax)
        ↓
Legal Entity           (references category codes; defines nothing)
        ↓
Accumulator Definition (links to one tax_category_code)
```

### 1.1 National jurisdiction

The national jurisdiction establishes the tax categories that apply to all legal entities operating under its authority. These categories are seeded by platform administrators when a new jurisdiction is supported; legal entities cannot modify them.

Examples:
- **US (IRS):** Social Security (employee and employer), Medicare (employee and employer), Federal Income Tax, FUTA, SUTA
- **Canada (CRA):** CPP (employee and employer), EI (employee and employer), Federal Income Tax
- **UK (HMRC):** PAYE, National Insurance (employee and employer)

### 1.2 Sub-jurisdiction (state/province)

Sub-jurisdictions add tax categories that do not exist at the national level. These are **strictly additive** — they extend the national set; they do not replace national codes except in documented supersession cases (see §1.3).

Sub-jurisdiction codes are only created for tax types that are genuinely absent at the national level. Tax types that exist nationally but vary by rate or wage base at the state level (SUTA, State Income Tax) remain national-level codes with `EMPLOYER_JURISDICTION` or `EMPLOYEE_JURISDICTION` accumulator scope — the scope dimension on the accumulator handles the state-level value variation without requiring a new category code.

Sub-jurisdiction code examples:
- **California:** SDI (employee), PFL (employee)
- **New York:** SDI (employee), PFL (employee)
- **New Jersey:** TDI (employee and employer), FLI (employee)
- **Washington:** PFML (employee and employer)
- **Massachusetts:** PFML (employee and employer)

### 1.3 Supersession

In rare cases a sub-jurisdiction replaces a national-level category rather than adding to it. The canonical example is **Quebec**: the Quebec Pension Plan (QPP) replaces the Canada Pension Plan (CPP) for Quebec employees. The sub-jurisdiction code carries a `supersedes_tax_category_code_id` reference pointing to the national code it replaces. The accumulator engine uses the sub-jurisdiction code for employees in that province and ignores the national code.

---

## 2. Benefit Classification — Entity-Up

Benefit arrangements are formed through contracts between a legal entity and third-party benefit providers (insurers, retirement plan custodians, HSA administrators). No two legal entities necessarily have the same provider arrangements. The classification therefore starts at the entity level and maps upward to jurisdiction-defined plan types.

```
Legal Entity            (defines benefit plan codes from its provider contracts)
        ↑ maps to
National Jurisdiction   (defines recognized benefit type codes — IRS-recognized plan types)
        ↓
Accumulator Definition  (links to one legal_entity_benefit_plan, which carries a benefit_type_code)
```

### 2.1 National benefit type codes

The national jurisdiction defines the recognized benefit plan types that carry tax treatment implications under its rules. These codes classify *what kind of benefit* a plan is for accumulator rollup, cap enforcement, and reporting purposes. Legal entities cannot define new types at this level — they can only instantiate the types the jurisdiction recognizes.

US examples: `401K`, `403B`, `457`, `SIMPLE_IRA`, `HSA`, `FSA_HEALTH`, `FSA_DEPENDENT`, `MEDICAL`, `DENTAL`, `VISION`, `LIFE_BASIC`, `LIFE_SUPPLEMENTAL`, `STD`, `LTD`

Canada examples: `RRSP`, `DPSP`, `TFSA`, `GROUP_BENEFITS`

### 2.2 Legal entity benefit plan codes

Each legal entity defines its own benefit plan codes that represent the specific arrangements it has contracted with providers. A plan code records:

- The provider name and plan identity (e.g., "Fidelity 401(k) Plan", "Aetna Medical PPO")
- The national benefit type it instantiates (e.g., `401K`, `MEDICAL`)
- Plan year start date (for `PLAN_YEAR` accumulator period types)
- Effective date range for the arrangement

Multiple plans at the entity level may map to the same national benefit type (e.g., an entity may offer both a traditional 401k and a Roth 401k — both map to the `401K` national type, distinguished by the pre/post-tax posting direction on the accumulator definition).

### 2.3 Two rollup views from one data set

Because the accumulator definition links through the entity plan code to the national type code, two distinct rollup views are possible from the same accumulator data:

| Consumer | Groups by | Answers |
|---|---|---|
| Management Accounting | National benefit type | Total 401k contributions this period across all plans |
| Carrier Reconciliation | Entity plan code | What to remit to Fidelity vs. Aetna vs. Delta Dental |

This is why `Carrier Reconciliation` appears as a distinct consumer group in `Accumulator_Model_Detailed.md` §4. The By Employee view on the Accumulator Display page primarily serves the accounting rollup; carrier-level remittance reporting is a separate operational output.

---

## 3. Schema Definitions

### 3.1 `national_jurisdiction`

| Column | Type | Description |
|---|---|---|
| `national_jurisdiction_id` | UUID PK | |
| `iso_country_code` | CHAR(2) | ISO 3166-1 alpha-2 (US, CA, GB, AU) |
| `display_name` | VARCHAR | "United States", "Canada" |
| `tax_authority_name` | VARCHAR | "IRS", "CRA", "HMRC", "ATO" |
| `primary_currency_code` | CHAR(3) | ISO 4217 (USD, CAD, GBP, AUD) |

### 3.2 `sub_jurisdiction`

| Column | Type | Description |
|---|---|---|
| `sub_jurisdiction_id` | UUID PK | |
| `national_jurisdiction_id` | UUID FK | |
| `code` | VARCHAR | State/province code (CA, NY, QC, ON) |
| `display_name` | VARCHAR | "California", "Quebec" |
| `sub_jurisdiction_type` | VARCHAR | STATE, PROVINCE, TERRITORY |

### 3.3 `tax_category_code`

| Column | Type | Description |
|---|---|---|
| `tax_category_code_id` | UUID PK | |
| `national_jurisdiction_id` | UUID FK | Always set |
| `sub_jurisdiction_id` | UUID FK nullable | Set only for sub-jurisdiction codes |
| `code` | VARCHAR | e.g., `SS_EE`, `MEDICARE_ER`, `SDI_EE` |
| `display_name` | VARCHAR | e.g., "Social Security (Employee)" |
| `scope` | VARCHAR | EMPLOYEE, EMPLOYER, EMPLOYEE_JURISDICTION, EMPLOYER_JURISDICTION |
| `period_type` | VARCHAR | CALENDAR_YEAR, QUARTER, PERIOD, LIFETIME |
| `posting_side` | VARCHAR | EMPLOYEE (withheld), EMPLOYER (liability), BOTH |
| `rollup_group` | VARCHAR | FICA, UNEMPLOYMENT, INCOME_WITHHOLDING, DISABILITY — for display grouping |
| `supersedes_tax_category_code_id` | UUID FK nullable | For sub-jurisdiction supersession (QPP → CPP) |
| `effective_start_date` | DATE | |
| `effective_end_date` | DATE nullable | |

### 3.4 `benefit_type_code`

| Column | Type | Description |
|---|---|---|
| `benefit_type_code_id` | UUID PK | |
| `national_jurisdiction_id` | UUID FK | |
| `code` | VARCHAR | e.g., `401K`, `HSA`, `MEDICAL`, `RRSP` |
| `display_name` | VARCHAR | e.g., "401(k) Retirement", "Health Savings Account" |
| `period_type` | VARCHAR | PLAN_YEAR, CALENDAR_YEAR, MONTHLY — MONTHLY applies to IRS Section 132(f) commuter benefits (transit pass and parking), which have per-month IRS limits rather than annual limits |
| `has_employee_side` | BOOLEAN | |
| `has_employer_side` | BOOLEAN | |
| `is_tax_preferential` | BOOLEAN | Whether contributions carry IRS/CRA cap implications |
| `rollup_group` | VARCHAR | RETIREMENT, HEALTH, INSURANCE, DISABILITY, COMMUTER |
| `governing_code_reference` | VARCHAR nullable | e.g., "IRC Section 401(k)", "IRC Section 223" |
| `effective_start_date` | DATE | |
| `effective_end_date` | DATE nullable | |

### 3.6 `sub_jurisdiction_reciprocity`

Records bilateral state/province income tax reciprocity agreements. When a valid agreement exists between an employee's work state and residence state, and the employee has filed the required exemption form, the SIT accumulator posts to the *residence* state rather than the work state.

| Column | Type | Description |
|---|---|---|
| `reciprocity_id` | UUID PK | |
| `national_jurisdiction_id` | UUID FK | Both sub-jurisdictions must belong to the same national jurisdiction |
| `jurisdiction_a_id` | UUID FK → `sub_jurisdiction` | First party to the agreement (e.g., NJ) |
| `jurisdiction_b_id` | UUID FK → `sub_jurisdiction` | Second party to the agreement (e.g., PA) |
| `applicable_tax_category_code_id` | UUID FK → `tax_category_code` | Always `SIT`; reciprocity never applies to SUTA, FUTA, or local taxes |
| `exemption_form_a_resident` | VARCHAR | Form filed by a jurisdiction_a resident working in jurisdiction_b (e.g., NJ-165) |
| `exemption_form_b_resident` | VARCHAR | Form filed by a jurisdiction_b resident working in jurisdiction_a (e.g., REV-419) |
| `effective_start_date` | DATE | Date the agreement took effect |
| `effective_end_date` | DATE nullable | Date the agreement was terminated; NULL while still in force. Must be tracked — agreements can be terminated on notice |

**Scope resolution rule when a reciprocity record is active:** The calculation engine checks whether a valid `sub_jurisdiction_reciprocity` row exists for the employee's work-state / residence-state pair, and whether the employee has filed the exemption form (recorded on the employee's tax profile). If both conditions are met, SIT posts to the residence-state `EMPLOYEE_JURISDICTION` accumulator; otherwise SIT posts to the work-state accumulator per the default rule.

**Local taxes are explicitly excluded.** The `applicable_tax_category_code_id` constraint to `SIT` ensures local income taxes (Philadelphia wage tax, NYC surcharge, etc.) are never affected by reciprocity agreements, even where the overlapping states have one.

**NJ–PA reciprocity — documented example:**

| Field | Value |
|---|---|
| jurisdiction_a | NJ |
| jurisdiction_b | PA |
| applicable category | SIT |
| exemption_form_a_resident | NJ-165 (filed by NJ resident with PA employer) |
| exemption_form_b_resident | REV-419 (filed by PA resident with NJ employer) |
| effective_start_date | Decades prior to platform inception |
| effective_end_date | NULL — agreement survived 2016–2017 termination notice and remains fully in force |

Result: an NJ resident working in PA who has filed NJ-165 has PA SIT suppressed; NJ SIT is withheld. A PA resident working in NJ who has filed REV-419 has NJ SIT suppressed; PA SIT is withheld.

### 3.5 `legal_entity_benefit_plan`

| Column | Type | Description |
|---|---|---|
| `benefit_plan_id` | UUID PK | |
| `legal_entity_id` | UUID FK | |
| `benefit_type_code_id` | UUID FK | Maps this plan to the national plan type |
| `code` | VARCHAR | Entity-defined code ("FIDELITY_401K", "AETNA_MEDICAL_PPO") |
| `display_name` | VARCHAR | "Fidelity 401(k) Plan", "Aetna Medical PPO" |
| `provider_name` | VARCHAR nullable | "Fidelity Investments", "Aetna" |
| `plan_year_start_month` | SMALLINT nullable | For PLAN_YEAR types |
| `plan_year_start_day` | SMALLINT nullable | |
| `effective_start_date` | DATE | |
| `effective_end_date` | DATE nullable | |
| `status` | VARCHAR | ACTIVE, INACTIVE |

---

## 4. Accumulator Definition Integration

An accumulator definition is classified as either tax or benefit — never both. The definition carries a nullable pair:

| Field | Set for | Null for |
|---|---|---|
| `tax_category_code_id` | Tax accumulators | Benefit accumulators |
| `benefit_plan_id` | Benefit accumulators | Tax accumulators |

Exactly one of the two must be non-null (application-layer constraint).

For benefit accumulators, the `benefit_type_code_id` is accessed through `benefit_plan_id → legal_entity_benefit_plan → benefit_type_code_id`. This two-hop join supports both the entity-plan-level view (carrier reconciliation) and the national-type-level view (accounting rollup) from the same accumulator data.

---

## 5. Consumer Group Rollup Views

| Consumer Group | Tax rollup key | Benefit rollup key |
|---|---|---|
| Payroll Operations | `tax_category_code.code` | `benefit_type_code.code` |
| Management Accounting | `tax_category_code.rollup_group` | `benefit_type_code.rollup_group` |
| Corporate Accounting | `tax_category_code.code` per employee | `benefit_type_code.code` per employee |
| External Reporting | `tax_category_code.code` (W-2 box mapping) | `benefit_type_code.code` (W-2 box mapping) |
| Carrier Reconciliation | N/A | `legal_entity_benefit_plan.code` (provider-level remittance) |

---

## 6. US Jurisdiction Seed Data

Seeded when the US national jurisdiction is initialized. These records are owned by the platform and are not editable by legal entities.

### 6.1 US national tax category codes

| Code | Display Name | Scope | Period Type | Rollup Group | Posting Side |
|---|---|---|---|---|---|
| `SS_EE` | Social Security (Employee) | EMPLOYEE | CALENDAR_YEAR | FICA | EMPLOYEE |
| `SS_ER` | Social Security (Employer) | EMPLOYER | CALENDAR_YEAR | FICA | EMPLOYER |
| `MEDICARE_EE` | Medicare (Employee) | EMPLOYEE | CALENDAR_YEAR | FICA | EMPLOYEE |
| `MEDICARE_ER` | Medicare (Employer) | EMPLOYER | CALENDAR_YEAR | FICA | EMPLOYER |
| `FIT` | Federal Income Tax | EMPLOYEE | CALENDAR_YEAR | INCOME_WITHHOLDING | EMPLOYEE |
| `SIT` | State Income Tax | EMPLOYEE_JURISDICTION | CALENDAR_YEAR | INCOME_WITHHOLDING | EMPLOYEE |
| `LOCAL_TAX` | Local Income Tax | EMPLOYEE_JURISDICTION | CALENDAR_YEAR | INCOME_WITHHOLDING | EMPLOYEE |
| `FUTA` | Federal Unemployment Tax | EMPLOYER | CALENDAR_YEAR | UNEMPLOYMENT | EMPLOYER |
| `SUTA` | State Unemployment Tax | EMPLOYER_JURISDICTION | CALENDAR_YEAR | UNEMPLOYMENT | EMPLOYER |

### 6.2 US sub-jurisdiction tax category code examples

| State | Code | Display Name | Scope | Posting Side |
|---|---|---|---|---|
| CA | `SDI_EE` | CA State Disability Insurance (Employee) | EMPLOYEE_JURISDICTION | EMPLOYEE |
| CA | `PFL_EE` | CA Paid Family Leave (Employee) | EMPLOYEE_JURISDICTION | EMPLOYEE |
| NY | `SDI_EE` | NY State Disability Insurance (Employee) | EMPLOYEE_JURISDICTION | EMPLOYEE |
| NY | `PFL_EE` | NY Paid Family Leave (Employee) | EMPLOYEE_JURISDICTION | EMPLOYEE |
| NJ | `TDI_EE` | NJ Temporary Disability Insurance (Employee) | EMPLOYEE_JURISDICTION | EMPLOYEE |
| NJ | `TDI_ER` | NJ Temporary Disability Insurance (Employer) | EMPLOYER_JURISDICTION | EMPLOYER |
| NJ | `FLI_EE` | NJ Family Leave Insurance (Employee) | EMPLOYEE_JURISDICTION | EMPLOYEE |
| WA | `PFML_EE` | WA Paid Family and Medical Leave (Employee) | EMPLOYEE_JURISDICTION | EMPLOYEE |
| WA | `PFML_ER` | WA Paid Family and Medical Leave (Employer) | EMPLOYER_JURISDICTION | EMPLOYER |

This list is illustrative, not exhaustive. Sub-jurisdiction codes are added as the platform is extended to support additional states.

### 6.3 US national benefit type codes

| Code | Display Name | Period Type | Tax Preferential | Rollup Group |
|---|---|---|---|---|
| `401K` | 401(k) Retirement | PLAN_YEAR | Yes | RETIREMENT |
| `403B` | 403(b) Retirement | PLAN_YEAR | Yes | RETIREMENT |
| `457` | 457(b) Deferred Compensation | PLAN_YEAR | Yes | RETIREMENT |
| `SIMPLE_IRA` | SIMPLE IRA | CALENDAR_YEAR | Yes | RETIREMENT |
| `HSA` | Health Savings Account | CALENDAR_YEAR | Yes | HEALTH |
| `FSA_HEALTH` | Health Flexible Spending Account | PLAN_YEAR | Yes | HEALTH |
| `FSA_DEPENDENT` | Dependent Care FSA | PLAN_YEAR | Yes | HEALTH |
| `MEDICAL` | Medical Insurance | PLAN_YEAR | No | HEALTH |
| `DENTAL` | Dental Insurance | PLAN_YEAR | No | HEALTH |
| `VISION` | Vision Insurance | PLAN_YEAR | No | HEALTH |
| `LIFE_BASIC` | Basic Life Insurance | PLAN_YEAR | No | INSURANCE |
| `LIFE_SUPPLEMENTAL` | Supplemental Life Insurance | PLAN_YEAR | No | INSURANCE |
| `STD` | Short-Term Disability | PLAN_YEAR | No | DISABILITY |
| `LTD` | Long-Term Disability | PLAN_YEAR | No | DISABILITY |
| `HRA` | Health Reimbursement Arrangement | PLAN_YEAR | Yes | HEALTH |
| `COMMUTER_TRANSIT` | Commuter Transit Pass | MONTHLY | Yes | COMMUTER |
| `COMMUTER_PARKING` | Commuter Parking | MONTHLY | Yes | COMMUTER |

**HRA note:** Employer-side only (`has_employee_side = false`, `has_employer_side = true`). HRA funds are employer-owned until claimed; no employee contribution accumulator exists. The cap is the employer's annual HRA contribution limit as defined in the plan document, not an IRS limit.

**Commuter benefit note:** IRC Section 132(f) transit and parking benefits use `MONTHLY` period type. The IRS sets a per-month exclusion limit (indexed annually). Unused monthly amounts do not carry forward under most plan designs. The accumulator cap is the monthly IRS limit, not an annual limit — the cap enforcement logic must apply the limit per calendar month, not per year.

---

## 7. US Sub-Jurisdiction Reciprocity Agreements

The `sub_jurisdiction_reciprocity` table records bilateral state income tax reciprocity agreements. See §3.6 for the full schema.

### 7.1 Reciprocity agreements vs. credit agreements

These are architecturally distinct and must not be conflated.

**True reciprocity agreement:**
- The employee pays SIT only to their **home (residence) state**
- The work state is fully exempt — no SIT withheld there
- The employee files an exemption certificate with their **work-state employer**
- Payroll system impact: work-state SIT withholding is suppressed when the certificate is on file
- `sub_jurisdiction_reciprocity` table applies

**Credit agreement (standard interstate mechanism — NOT reciprocity):**
- The employee pays SIT to the **work state** in full
- The employee also files a return in their home state
- The home state grants a credit for taxes paid to the work state
- The employee still files two state returns and still owes the work state
- Payroll system impact: none — both states' SIT accrues normally
- `sub_jurisdiction_reciprocity` table does NOT apply

**Example of the distinction:** California and Arizona have a credit agreement, not a reciprocity agreement. An Arizona resident working in California pays California SIT in full. Arizona then credits those taxes against the Arizona return. From a payroll withholding perspective this is identical to working in any non-reciprocal state. The `sub_jurisdiction_reciprocity` table must never contain credit agreements.

### Scope of reciprocity — withholding only

Reciprocity agreements govern **income tax withholding only**. They have no effect on unemployment tax.

**SUI (SUTA) always follows the work state**, regardless of any reciprocity agreement. A New Jersey resident working in Pennsylvania under the NJ–PA reciprocity agreement pays no Pennsylvania income tax — but their employer still owes Pennsylvania SUTA on those wages, not New Jersey SUTA. The reciprocity agreement is between the employee and the taxing authority; SUTA is an employer obligation assessed by the state where the work is performed and is outside the scope of any bilateral income tax agreement.

This means the `sub_jurisdiction_reciprocity` table affects only `SIT` accumulator scope resolution. `SUTA` accumulator posting is never redirected by a reciprocity record — it always posts to the `EMPLOYER_JURISDICTION` accumulator of the work state. The `applicable_tax_category_code_id` FK constraint on the table enforces this at the data level.

### 7.2 Complete US reciprocity agreement table

Each row represents one unique bilateral agreement. The exemption form is issued by (or associated with) the **employee's home state** and filed with the **work-state employer** to suppress that employer's SIT withholding obligation.

Form numbers are current as of model authoring. They are subject to annual change by state departments of revenue and should be verified against current DOR publications before seeding.

| State A | State B | A Resident Working in B Files with B Employer | B Resident Working in A Files with A Employer |
|---|---|---|---|
| AZ | IN | AZ A-4 *(verify)* | IN WH-47 |
| AZ | OR | AZ A-4 *(verify)* | OR WC (verify) |
| AZ | VA | AZ A-4 *(verify)* | VA VA-4 |
| DC | MD | DC D-4A | MD MW507 |
| DC | VA | DC D-4A | VA VA-4 |
| IL | IA | IL IL-W-5-NR | IA 44-016 |
| IL | IN | IL IL-W-5-NR | IN WH-47 |
| IL | KY | IL IL-W-5-NR | KY 42A809 |
| IL | MI | IL IL-W-5-NR | MI MI-W4 |
| IL | WI | IL IL-W-5-NR | WI W-220 |
| IN | KY | IN WH-47 | KY 42A809 |
| IN | MI | IN WH-47 | MI MI-W4 |
| IN | OH | IN WH-47 | OH IT 4NR |
| IN | PA | IN WH-47 | PA REV-419 |
| IN | WI | IN WH-47 | WI W-220 |
| KY | MI | KY 42A809 | MI MI-W4 |
| KY | OH | KY 42A809 | OH IT 4NR |
| KY | VA | KY 42A809 | VA VA-4 |
| KY | WV | KY 42A809 | WV WV/IT-104 |
| KY | WI | KY 42A809 | WI W-220 |
| MD | PA | MD MW507 | PA REV-419 |
| MD | VA | MD MW507 | VA VA-4 |
| MD | WV | MD MW507 | WV WV/IT-104 |
| MI | MN | MI MI-W4 | MN MWR |
| MI | OH | MI MI-W4 | OH IT 4NR |
| MI | WI | MI MI-W4 | WI W-220 |
| MN | ND | MN MWR | ND NDW-R |
| MT | ND | MT *(verify)* | ND NDW-R |
| NJ | PA | NJ NJ-165 | PA REV-419 |
| OH | PA | OH IT 4NR | PA REV-419 |
| OH | WV | OH IT 4NR | WV WV/IT-104 |
| PA | VA | PA REV-419 | VA VA-4 |
| PA | WV | PA REV-419 | WV WV/IT-104 |
| VA | WV | VA VA-4 | WV WV/IT-104 |

**NJ–PA noted:** NJ resident working in PA files NJ-165 with PA employer. PA resident working in NJ files REV-419 with NJ employer. Agreement in effect for decades; survived 2016–2017 termination notice and remains fully in force.

### 7.3 Administrative rules

This table is seeded and maintained by platform administrators. Reciprocity agreements are not editable by legal entities.

When a state terminates an agreement, `effective_end_date` is set on the `sub_jurisdiction_reciprocity` row. The calculation engine stops applying the scope override for pay periods after that date. Mid-year terminations create a retroactive correction scenario — the accumulator must be reconciled between work-state and residence-state postings for the affected portion of the calendar year, as both SIT definitions carry `CALENDAR_YEAR` period type.

The employee's filed exemption certificate is recorded on the employee's tax withholding profile. The calculation engine checks **both** conditions before applying the reciprocity override: (1) a valid unexpired `sub_jurisdiction_reciprocity` row exists for the work-state / residence-state pair, and (2) the employee has an active filed certificate on record. If either condition is absent, default work-state SIT withholding applies.

---

## 8. Known Gaps and Deferred Design Items

The following are acknowledged gaps that require additional design before implementation. They are documented here rather than silently omitted.

### 8.1 Age-stratified caps and combined limits (401k / catch-up)

The current model assumes one cap value per accumulator definition. Three IRS constraints break this:

1. **Catch-up contributions (age 50+):** Employees 50 and older may contribute more than the standard limit. The effective cap is age-conditional and cannot be a single value on the definition.
2. **Super catch-up (ages 60–63, effective 2026, SECURE 2.0):** A third, higher limit tier for this age band.
3. **Combined pre-tax + Roth limit:** An employee's traditional 401k and Roth 401k contributions share one IRS annual limit. A `combined_limit_group_id` concept is needed — definitions in the same group share a cap pool, and the engine must enforce the combined total rather than each independently.

**Deferred to:** Accumulator Definition Model revision before Phase 10 cap enforcement is implemented.

### 8.2 Partial supersession (Quebec — QPIP / EI)

The `supersedes_tax_category_code_id` mechanism on `tax_category_code` handles clean full replacement (QPP replaces CPP for Quebec employees). Quebec's QPIP is a partial supersession: Quebec employees pay EI at a *reduced rate* (not zero) and also pay into QPIP. The current binary supersession flag cannot express this — a `supersession_type` (FULL / PARTIAL) and a `residual_rate_factor` are needed.

**Deferred to:** Canadian jurisdiction seed data phase.

### 8.3 US territories (Puerto Rico)

Puerto Rico has its own tax authority (Hacienda) and its own income tax act, but participates in federal SS and Medicare under the same IRS rules as the 50 states. It is neither a clean `sub_jurisdiction` of US (understates its fiscal independence) nor a separate `national_jurisdiction` (overstates separation from federal FICA). A `territory_type` flag on `sub_jurisdiction` or an intermediate jurisdiction tier may be needed.

**Deferred to:** PEO / multi-territory deployment phase.

### 8.4 Multi-national / expatriate employees

The model assumes one `national_jurisdiction_id` per legal entity. An employee on international assignment creates overlapping tax obligations in two national jurisdictions simultaneously. This requires a separate international assignment model and is out of scope for the current platform phase.

---

## 9. Adding a New Jurisdiction

Supporting a new national jurisdiction requires:

1. Insert a row in `national_jurisdiction`.
2. Seed `tax_category_code` rows for the jurisdiction's tax authority-defined categories.
3. Seed `benefit_type_code` rows for the jurisdiction's recognized plan types.
4. If the jurisdiction has sub-jurisdictions with distinct tax categories, insert `sub_jurisdiction` rows and the corresponding `tax_category_code` rows scoped to them.
5. Seed any known `sub_jurisdiction_reciprocity` agreements applicable within the jurisdiction.
6. Legal entities operating in the jurisdiction are linked by `national_jurisdiction_id`; they then define their own `legal_entity_benefit_plan` rows against the new jurisdiction's benefit type codes.

No application code changes are required to support a new jurisdiction — the classification layer is data-driven. The accumulator display page reads category codes through the jurisdiction chain at runtime.

---

## 10. Relationship to Other Models

| Model | Relationship |
|---|---|
| `Accumulator_Model_Detailed.md` | Accumulator definitions reference `tax_category_code_id` or `benefit_plan_id`; the category code governs display grouping and rollup behavior |
| `Accumulator_and_Balance_Model.md` | Accumulator balances inherit their classification from the definition's category code link |
| `Accumulator_Impact_Model.md` | Impact lines post against accumulator definitions; the category code determines which consumer group view an impact contributes to |
| `docs/SPEC/Accumulator_Display.md` | The By Family view groups and labels by `tax_category_code.display_name` or `benefit_type_code.display_name`; the Carrier Reconciliation view groups by `legal_entity_benefit_plan.display_name` |
| `docs/SPEC/Benefits_Minimum_Module.md` | Benefit deduction plans link to `legal_entity_benefit_plan`; the plan's `benefit_type_code_id` drives accumulator family classification |
