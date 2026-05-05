# SPEC — Accumulator Display

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Module |
| **Location** | `docs/SPEC/Accumulator_Display.md` |
| **Related Documents** | `SPEC/Payroll_Core_Module.md`, `SPEC/Payroll_Calculation_Pipeline.md`, `docs/build/Build_Sequence_Plan.md` (Phase 10), `docs/accumulators/Accumulator_Model_Detailed.md`, `docs/accumulators/Accumulator_and_Balance_Model.md`, `docs/accumulators/Accumulator_Impact_Model.md`, `docs/accumulators/Jurisdiction_Category_Code_Model.md` |

---

## Purpose

Defines the implementation-ready specification for the Accumulator Display page (`/payroll/accumulators`). This page replaces the Phase 4 stub.

**Accumulators are not a reporting layer — they are a state machine.** Each accumulator tracks a running total that the calculation engine reads to enforce rules (wage base caps, annual limits, eligibility thresholds) and that must survive across payroll runs, be reset on defined schedule boundaries, and support retroactive recalculation. This page provides an operational window into that state: current balances, period history, cap status, and the impact line trail that produced each balance.

---

## 1. Conceptual Model

### 1.1 Three-layer architecture

Accumulators are governed by a three-layer model defined in `Accumulator_Model_Detailed.md`:

```
Accumulator_Definition   — defines meaning, scope, reset behavior, cap, reporting semantics
        ↓
Accumulator_Impact       — governs how payroll results mutate accumulator values
        ↓                  (source lineage, retroactivity, reversal, correction handling)
Accumulator_Value        — stores operational balances; governs rollup and reconciliation
```

This page reads from the **Value** layer. No recalculation occurs in the UI. All displayed balances are the authoritative runtime state produced by the calculation engine through the Impact layer.

### 1.2 What an accumulator is

An accumulator is a named running total associated with a **scope** and governed by a **period type**. It is updated by **impact lines** written during payroll calculation and read by calculation steps to enforce limits and determine eligibility.

### 1.3 Rollup behavior

Each accumulator carries one of three rollup behaviors (from `Accumulator_Model_Detailed.md` §2):

| Rollup Type | Meaning | Display implication |
|---|---|---|
| `INDEPENDENT` | Balance posted directly at this scope level | Displayed value is authoritative; no sub-total derivation |
| `DERIVED` | Calculated dynamically from lower-scope accumulators | Displayed value is a computed rollup; a **Derived** badge indicates this |
| `HYBRID` | Combination of direct postings and derived rollup | Both the impact trail and derived components are shown |

Most employee-scope accumulators (SS, Medicare, income tax withholding) are `INDEPENDENT`. Employer-level rollups (entity-wide FUTA totals) may be `DERIVED` from per-jurisdiction values. The rollup type is stored on the accumulator definition and drives display behavior, not calculation logic.

### 1.4 Consumer-oriented views

The two views on this page (By Family and By Employee) map to distinct consumer groups identified in `Accumulator_Model_Detailed.md` §4:

| View | Primary consumers |
|---|---|
| By Family | Payroll Operations (cap monitoring, run-by-run impact verification), Management Accounting (period-total reconciliation) |
| By Employee | Corporate Accounting (individual liability auditing), External Reporting (W-2 reconciliation, carrier file validation), Carrier Reconciliation |

### 1.5 Scope dimensions

Every accumulator balance belongs to exactly one scope:

| Scope | Description | Example |
|---|---|---|
| `EMPLOYEE` | Per employee, entity-wide | Employee SS wage base |
| `EMPLOYER` | Per legal entity | Employer FUTA liability |
| `EMPLOYEE_JURISDICTION` | Per employee per tax jurisdiction | Employee state income tax YTD |
| `EMPLOYER_JURISDICTION` | Per entity per tax jurisdiction | Employer SUTA per state |
| `CLIENT_JURISDICTION` | Per entity per jurisdiction (PEO context) | Client-level FUTA tracking in PEO deployment |

### 1.6 Period types and reset rules

| Period Type | Reset Trigger | Applies To |
|---|---|---|
| `CALENDAR_YEAR` | January 1 of each year | All IRS payroll tax accumulators |
| `PLAN_YEAR` | Plan year start date defined on the accumulator definition | Benefit plan accumulators (401k, HSA, health deductible) |
| `QUARTER` | First day of each calendar quarter | Some state unemployment accumulators |
| `PERIOD` | Each payroll run | PTD accumulators |
| `LIFETIME` | Never resets | LTD accumulators |

**IRS rule:** All federal and state payroll tax accumulators (SS, Medicare, FUTA, SUTA, Federal/State income tax withholding) use `CALENDAR_YEAR` regardless of the legal entity's fiscal year. This is a non-negotiable IRS mandate. The entity's fiscal year calendar has no effect on tax accumulator resets.

**Benefit plan accumulators** use `PLAN_YEAR`. The plan year start date is stored on the accumulator definition. A plan year that begins January 1 is indistinguishable from `CALENDAR_YEAR` in its reset behavior but remains classified as `PLAN_YEAR` so that a future plan year change does not require reclassification.

### 1.7 Accumulator families

The `lkp_accumulator_family` lookup defines the named groupings used for display. Current values:

| Family Code | Display Name | Scope | Period Type | Cap |
|---|---|---|---|---|
| `SS_EMPLOYEE` | Social Security (Employee) | EMPLOYEE | CALENDAR_YEAR | $168,600 wage base |
| `SS_EMPLOYER` | Social Security (Employer) | EMPLOYER | CALENDAR_YEAR | Mirrors SS_EMPLOYEE |
| `MEDICARE_EMPLOYEE` | Medicare (Employee) | EMPLOYEE | CALENDAR_YEAR | None |
| `MEDICARE_ER` | Medicare (Employer) | EMPLOYER | CALENDAR_YEAR | None |
| `FED_INCOME_TAX` | Federal Income Tax Withheld | EMPLOYEE | CALENDAR_YEAR | None |
| `STATE_INCOME_TAX` | State Income Tax Withheld | EMPLOYEE_JURISDICTION | CALENDAR_YEAR | None |
| `LOCAL_TAX` | Local Tax Withheld | EMPLOYEE_JURISDICTION | CALENDAR_YEAR | None |
| `FUTA` | FUTA | EMPLOYER | CALENDAR_YEAR | $7,000 wage base |
| `SUTA` | SUTA | EMPLOYER_JURISDICTION | CALENDAR_YEAR | State-specific |
| `401K_PRE_TAX` | 401(k) Pre-Tax | EMPLOYEE | PLAN_YEAR | IRS annual limit |
| `401K_ROTH` | 401(k) Roth (Post-Tax) | EMPLOYEE | PLAN_YEAR | IRS annual limit (combined with pre-tax) |
| `HSA` | HSA Contribution | EMPLOYEE | PLAN_YEAR | IRS annual limit |
| `SDI` | State Disability Insurance | EMPLOYEE_JURISDICTION | CALENDAR_YEAR | State-specific |
| `PFL` | Paid Family Leave | EMPLOYEE_JURISDICTION | CALENDAR_YEAR | State-specific |

Cap amounts are stored on the accumulator definition record and displayed alongside balances. Cap amounts are updated annually via the Tax Rate configuration UI.

---

## 2. Page Structure

The Accumulator Display page has two primary views, selectable via a top-level toggle:

```
[ By Family ]   [ By Employee ]
```

Default view: **By Family**.

---

## 3. By Family View

The primary operational view. Shows the current state of each accumulator family across all employees for the selected legal entity.

### 3.1 Family selector

A left-side panel lists all accumulator families that have at least one balance record for the entity. Families with no balances are omitted. Selecting a family loads the detail panel on the right.

### 3.2 Family detail panel

The detail panel for a selected family has three sections:

**Header strip**
- Family display name
- Period type and current period label (e.g., "Calendar Year 2026" or "Plan Year Oct 2025 – Sep 2026")
- Cap amount (if applicable): shown as `Cap: $168,600.00`
- Reset date: next scheduled reset date

**Period navigator**
A horizontal tab row showing available periods in descending order:
```
[ 2026 ]  [ 2025 ]  [ 2024 ]
```
For `PLAN_YEAR` families, tabs are labeled by plan year (e.g., "PY 2025–2026"). Selecting a tab loads balances for that period.

**Balance table**
One row per employee (for `EMPLOYEE` and `EMPLOYEE_JURISDICTION` scopes) or one row for the entity (for `EMPLOYER` and `EMPLOYER_JURISDICTION` scopes).

Employee-scope columns:

| Column | Description |
|---|---|
| Employee Number | Links to HRIS employee detail |
| Employee Name | |
| Opening Balance | Balance at start of period (zero for first period) |
| YTD Contributions | Sum of all impact lines in the period |
| Closing Balance | Current running total |
| Cap Amount | From accumulator definition |
| Cap Remaining | Cap Amount − Closing Balance; shown in amber when ≤ 10% remaining; red and labeled **CAP REACHED** when zero or negative |
| Last Updated | Date of the most recent impact line |

Employer-scope columns (entity-level):

| Column | Description |
|---|---|
| Period | Period label |
| Opening Balance | |
| Total Contributions | Sum across all runs in the period |
| Closing Balance | |
| Cap Amount | If applicable |
| Cap Remaining | |

### 3.3 Row expansion — Impact line trail

Each employee row is expandable inline to show the impact lines that produced the balance. One row per impact line:

| Column | Description |
|---|---|
| Run Date | Pay date of the payroll run that wrote this impact |
| Run Name | Links to PayrollRunDetailPage |
| Impact Type | `CONTRIBUTION`, `REVERSAL`, `CORRECTION` |
| Amount | Positive for contributions; negative for reversals |
| Running Balance | Cumulative balance after this impact |
| Notes | Retroactive flag if impact was posted by a corrective run |

Reversals and retroactive corrections are highlighted visually to distinguish them from regular contributions.

---

## 4. By Employee View

Allows a payroll administrator to pull up a single employee and see all their accumulator balances across all families and periods. Useful for auditing an individual's YTD position or investigating a cap-related calculation issue.

### 4.1 Employee selector

Search by employee number or name. Displays a confirmation chip once selected showing employee number, name, and entity.

### 4.2 Employee accumulator summary

Once an employee is selected, a table shows all accumulator families for which the employee has a balance:

| Column | Description |
|---|---|
| Family | Accumulator family display name |
| Period Type | CALENDAR_YEAR / PLAN_YEAR / etc. |
| Current Period | e.g., "2026" or "PY 2025–2026" |
| YTD Balance | Closing balance in the current period |
| Cap Amount | If applicable |
| Cap Remaining | With amber/red visual indicators |
| Prior Period Balance | Closing balance of the most recently completed period |

### 4.3 Family drill-in

Clicking any family row opens the impact line trail for that employee and family (same format as §3.3), pre-filtered to the current period. A period selector allows viewing prior periods.

---

## 5. Retroactivity Display

When a corrective payroll run reverses and re-posts accumulator impacts, the balance trail must reflect this clearly. The following visual rules apply:

- Reversal impact lines are shown in red with a `REVERSAL` type badge.
- The replacement contribution line (if any) is shown immediately after the reversal with a `CORRECTION` badge.
- A banner above the impact trail warns when the current balance has been affected by at least one retroactive correction: "This balance includes retroactive adjustments. See highlighted rows."
- The running balance column reflects the corrected state — the final closing balance is always the authoritative current value.

---

## 6. Cap Enforcement Display

When an employee approaches or reaches a wage base cap (e.g., SS $168,600):

- **≥ 90% consumed:** Cap Remaining cell shown in amber.
- **100% consumed (cap reached):** Cap Remaining cell shows `$0.00` in red with a **CAP REACHED** badge. The engine will stop writing contributions to this accumulator for the remainder of the period.
- **Over-cap (reversal/correction scenario):** Cap Remaining shown as a negative value in red with a **REVIEW REQUIRED** badge. This indicates a correction has produced a balance that exceeds the cap — a payroll administrator must investigate.

---

## 7. Period Reset Audit

A **Reset History** section at the bottom of each family's detail panel shows the history of period resets for the entity:

| Column | Description |
|---|---|
| Period | The period that was closed |
| Reset Date | Calendar date the reset occurred |
| Closing Balance | Final balance at reset |
| Opened By | `SYSTEM` for automatic resets; actor name for manual resets |
| Notes | Any override or manual adjustment notes |

This provides an audit trail confirming that resets occurred correctly and on schedule.

---

## 8. Access Control

| Role | Access |
|---|---|
| `HrisAdmin` | Full access — By Family and By Employee views |
| `PayrollAdmin` | Full access |
| `PayrollOperator` | Full access |
| All other roles | No access |

---

## 9. Data Notes

- All balances are read from the Accumulator_Value layer (`accumulator_balance`). No recalculation occurs in the UI.
- Impact lines are read from the Accumulator_Impact layer (`accumulator_impact` joined to `accumulator_contribution`). Each impact line carries source lineage traceable to the originating payroll result, applicable rule version, and any retroactive/correction context per `Accumulator_Impact_Model.md`.
- The "current period" for a `CALENDAR_YEAR` family is always the calendar year of `ITemporalContext.GetOperativeDate()` — never the legal entity's fiscal year.
- For `PLAN_YEAR` families, the current period is determined by the plan year start date on the accumulator definition and the operative date.
- Balances for employer-scope families (`EMPLOYER`, `EMPLOYER_JURISDICTION`) are entity-wide and do not have per-employee rows in the By Family view.
- The By Employee view shows only `EMPLOYEE` and `EMPLOYEE_JURISDICTION` scoped families; employer-scope families are not displayed per-employee.
- `DERIVED` accumulators display a **Derived** badge in the header strip. Their balance is a computed rollup from lower-scope values rather than a direct posting; no impact line trail exists at the derived scope — the trail is visible at the source scope.
- Cross-scope validation discrepancies (per `Accumulator_Model_Detailed.md` §5) are surfaced as a **SCOPE MISMATCH** warning banner on the affected family's detail panel. This is an operational exception state, not an error in the display — the administrator must investigate using the source-scope impact trails.
- Rule versioning: each impact line's rule version ID is stored and available for replay compatibility. The impact line trail columns may be extended to show rule version context in a future phase.
- Reconciliation relationship type (EXACT_SUM / SUM_PLUS_ADJUSTMENTS / INFORMATIONAL_ROLLUP / NO_DIRECT_RELATIONSHIP per `Accumulator_Model_Detailed.md` §3) is stored on the accumulator definition and is not displayed in the UI at this phase. It governs back-office reconciliation behavior rather than operational display.

---

## 10. Gate Test Cases — TC-ACUM

| ID | Description |
|---|---|
| TC-ACUM-001 | By Family view lists SS_EMPLOYEE and MEDICARE_EMPLOYEE families after at least one completed payroll run with tax. |
| TC-ACUM-002 | SS_EMPLOYEE closing balance for an employee equals the sum of all SS_EE impact lines for that employee in the calendar year. |
| TC-ACUM-003 | Cap Remaining for SS_EMPLOYEE is Cap Amount minus Closing Balance; cell shows amber indicator when ≤ 10% remaining. |
| TC-ACUM-004 | CAP REACHED badge appears on an employee whose SS wage base has been fully consumed. |
| TC-ACUM-005 | Impact line trail for an employee shows one row per accumulator_impact record; running balance column is cumulative and correct. |
| TC-ACUM-006 | A retroactive reversal and re-post is visible in the impact trail with REVERSAL and CORRECTION badges; the closing balance reflects the corrected value. |
| TC-ACUM-007 | 401K_PRE_TAX family uses PLAN_YEAR period label; period tab is labeled by plan year dates, not calendar year. |
| TC-ACUM-008 | By Employee view for a selected employee shows only EMPLOYEE and EMPLOYEE_JURISDICTION scoped families. |
| TC-ACUM-009 | Operative date drives the "current period" determination — a TDO shift to a prior year changes the current period label and the balance shown. |
| TC-ACUM-010 | Families with no balance records for the entity are absent from the family selector. |
| TC-ACUM-011 | Reset History shows a row for each period reset with correct closing balance and reset date. |
| TC-ACUM-012 | A user without PayrollAdmin, PayrollOperator, or HrisAdmin role receives an access-denied response. |
| TC-ACUM-013 | A DERIVED-rollup accumulator family shows the **Derived** badge in its header strip and presents no impact line trail at the derived scope level. |
| TC-ACUM-014 | When a cross-scope validation discrepancy is present on a family, a **SCOPE MISMATCH** banner appears on that family's detail panel; families without discrepancies show no banner. |
