# SPEC — Pay Register Drilldown

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Module |
| **Location** | `docs/SPEC/Pay_Register_Drilldown.md` |
| **Related Documents** | `SPEC/Payroll_Core_Module.md`, `SPEC/Time_Attendance_Minimum_Module.md`, `docs/build/Build_Sequence_Plan.md` (Phase 9) |

---

## Purpose

Defines the implementation-ready specification for the Pay Register Drilldown page (`/payroll/pay-register`). This page replaces the Phase 4 stub.

The Pay Register is a **pure reporting and auditing tool**. It contains no business logic, no state, and no carry-forward between runs. Every number it displays is a direct aggregation of result lines already written by the calculation engine. Its only job is to present those numbers at the level of aggregation the viewer needs.

Three aggregation levels are provided, all scoped to a single payroll run:

| Level | Primary audience | Question answered |
|---|---|---|
| Company Summary | Executive, CFO, controller | What did this payroll cost the company in total? |
| Org Rollup | Finance, HR, department managers | How is that cost distributed across the organization? |
| Employee Detail | Payroll administrators, auditors | What did each employee receive and have withheld? |

---

## 1. Run Selection

The Pay Register is always scoped to **one payroll run**. Run selection uses a two-step hierarchical picker:

**Step 1 — Year/Month navigator**
A collapsible list on the left side of the page (or a compact dropdown for smaller screens) groups completed runs by calendar year, then by month within each year. Only runs with status `APPROVED` or `COMPLETED` are shown. Sorted descending — most recent year and month first.

**Step 2 — Run selector**
Expanding a month shows all runs whose `pay_date` falls in that month. Selecting a run loads all three view tabs for that run. The selected run's name, pay date, and period are shown in a persistent header above the tabs.

No run is selected on initial page load. The most recent eligible run is pre-selected on first visit within a session.

---

## 2. View Tabs

Once a run is selected, three tabs are available:

```
[ Company Summary ]  [ Org Rollup ]  [ Employee Detail ]
```

Default tab: **Company Summary**.

---

## 3. Company Summary Tab

A single-page summary of the selected run. No pagination, no expansion — all figures on one screen.

### 3.1 Payroll Cost Summary

| Line | Source |
|---|---|
| Total Gross Payroll | Sum of GROSS result lines across all employee results |
| Total Employer Taxes | Sum of FICA_ER, FUTA, SUTA result lines |
| Total Employer Benefit Contributions | Sum of BENEFIT_ER_CONTRIBUTION result lines |
| **Total Employer Cost** | Gross + Employer Taxes + Employer Benefit Contributions |
| Total Employee Tax Withholdings | Sum of FED_TAX, STATE_TAX, LOCAL_TAX, FICA_EE result lines |
| Total Employee Benefit Deductions | Sum of BENEFIT_DEDUCTION, RETIREMENT_DEDUCTION, GARNISHMENT result lines |
| **Total Net Pay** | Sum of NET result lines |
| **Total Cash Required** | Net Pay + Employer Taxes + Employer Benefit Contributions |

"Total Cash Required" is the figure the controller uses for ACH pre-funding.

### 3.2 Tax Liability Summary

| Line | Source |
|---|---|
| Federal Income Tax Withheld | Sum of FED_TAX result lines |
| Social Security — Employee | Sum of SS_EE result lines |
| Social Security — Employer | Sum of SS_ER result lines |
| Medicare — Employee | Sum of MEDICARE_EE result lines |
| Medicare — Employer | Sum of MEDICARE_ER result lines |
| State Income Tax Withheld | Sum of STATE_TAX result lines, grouped by state |
| Local Tax Withheld | Sum of LOCAL_TAX result lines, grouped by jurisdiction |
| FUTA | Sum of FUTA result lines |
| SUTA | Sum of SUTA result lines, grouped by state |

State and local rows are shown only when amounts are non-zero.

### 3.3 Benefit Summary

| Line | Source |
|---|---|
| Total Employee Deductions | Sum of BENEFIT_DEDUCTION result lines |
| Total Employer Contributions | Sum of BENEFIT_ER_CONTRIBUTION result lines |
| Total Retirement Deductions (EE) | Sum of RETIREMENT_DEDUCTION result lines |

### 3.4 Hours Summary

*(Available after Phase 8 T&A is complete. Section is hidden until T&A data flows into result lines.)*

| Line | Source |
|---|---|
| Total Regular Hours | Sum of HOURS_REGULAR result lines |
| Total Overtime Hours | Sum of HOURS_OT result lines |
| Total PTO Hours | Sum of HOURS_PTO result lines |
| Total Hours Worked | Regular + Overtime |

### 3.5 Headcount

| Line | Source |
|---|---|
| Employees Included | Count of distinct employment_id in employee_payroll_result for the run |
| Employees with Supplemental Pay | Count where any SUPPLEMENTAL result line exists |

---

## 4. Org Rollup Tab

Aggregates the run's result lines by organizational dimension. Three sub-views selectable by a secondary toggle:

```
[ By Department ]  [ By Location ]  [ By Job ]
```

All three sub-views share the same column structure and aggregation behavior. Only the grouping key differs.

### 4.1 Shared Column Structure

| Column | Description |
|---|---|
| Group | Department name / Location name / Job title |
| Headcount | Distinct employee count |
| Gross Wages | Sum of GROSS |
| Regular Hours | Sum of HOURS_REGULAR *(hidden until T&A)* |
| Overtime Cost | Sum of OT earnings result lines *(hidden until T&A)* |
| Employee Tax Withheld | Sum of FED_TAX + STATE_TAX + LOCAL_TAX + FICA_EE |
| Employer Tax Cost | Sum of FICA_ER + FUTA + SUTA |
| Employer Benefit Cost | Sum of BENEFIT_ER_CONTRIBUTION |
| Net Pay | Sum of NET |
| Total Employer Cost | Gross + Employer Tax Cost + Employer Benefit Cost |

A **Totals** row at the bottom of each sub-view sums all columns. Totals must equal the Company Summary figures exactly.

### 4.2 By Department

Groups by `org_unit_id` on the employment record. The org unit name is displayed; the org unit hierarchy (Division → Department) is shown as an indented two-level tree if the legal entity uses that structure. Unassigned employees (no org unit on the employment record) appear in an **Unassigned** row at the bottom.

### 4.3 By Location

Groups by the work location on the employment record (state + city or location name). Primarily useful for multi-state employers to see state-level tax exposure and headcount. Rows sorted by state code then location name.

### 4.4 By Job

Groups by job code on the employment record. Useful for labor cost analysis by job family and identifying overtime distribution and compensation concentration. Rows sorted by job code.

### 4.5 Expansion

Each group row is expandable inline to show the employee rows that belong to it (same columns as Employee Detail Tab, §5). This allows a manager to verify the departmental total against the individuals contributing to it without switching tabs.

---

## 5. Employee Detail Tab

One row per `EmployeePayrollResult` for the selected run. This is the foundational audit layer.

### 5.1 Columns

| Column | Source |
|---|---|
| Employee Number | `employment.employee_number` |
| Employee Name | `person.legal_last_name`, `person.legal_first_name` |
| Department | `org_unit.name` via employment |
| Gross | GROSS result line |
| Regular Hours | HOURS_REGULAR *(hidden until T&A)* |
| OT Hours | HOURS_OT *(hidden until T&A)* |
| PTO Hours | HOURS_PTO *(hidden until T&A)* |
| Federal Tax | FED_TAX result line |
| SS (EE) | SS_EE result line |
| Medicare (EE) | MEDICARE_EE result line |
| State Tax | STATE_TAX result lines (summed across states) |
| Local Tax | LOCAL_TAX result lines (summed) |
| Benefit Deductions | BENEFIT_DEDUCTION result lines (summed) |
| Retirement (EE) | RETIREMENT_DEDUCTION result lines (summed) |
| Garnishments | GARNISHMENT result lines (summed) |
| Net Pay | NET result line |
| Employer SS | SS_ER result line |
| Employer Medicare | MEDICARE_ER result line |
| Employer Benefit | BENEFIT_ER_CONTRIBUTION result lines (summed) |

### 5.2 Expansion

Each employee row is expandable inline to show individual result lines — one row per line item with its result class label, amount, and (where applicable) the tax jurisdiction. This is the full audit trail for a single employee within the run.

### 5.3 Sorting and Filtering

Default sort: employee number ascending. User can re-sort by any column header. Filter input above the table filters by employee number or name (client-side, no round-trip).

### 5.4 Pagination

20 rows per page. Pagination controls at the bottom. "Show All" option for runs with fewer than 100 employees; suppressed for larger runs.

---

## 6. Export

A **Download CSV** button is present on each tab. The export contains all rows and columns for the current tab and sub-view. Exports are audit-logged (actor, run id, tab, timestamp).

The export from Employee Detail contains the unexpanded view (one row per employee). A separate **Export with Line Detail** button exports one row per result line, suitable for GL import.

---

## 7. Access Control

| Role | Access |
|---|---|
| `HrisAdmin` | All tabs |
| `PayrollAdmin` | All tabs |
| `PayrollOperator` | All tabs |
| `BenefitsAdmin` | Benefit Summary section of Company Summary only; no Org Rollup or Employee Detail |
| All other roles | No access |

---

## 8. Data Notes

- All figures are read directly from `result_line` rows. No re-calculation occurs in the UI layer.
- Negative result line amounts (reversals, corrections) are displayed as negative and shown in red.
- Multi-state employees appear once in Employee Detail; their state tax amounts are summed across jurisdictions. In the Org Rollup By Location sub-view, their results appear in each location row proportionally only if the result lines carry location tags — otherwise they appear in the primary work location.
- Currency displayed as `$#,##0.00` throughout.
- Hours columns are conditionally rendered: hidden when no HOURS_* result lines exist for the run (i.e., before Phase 8 T&A is complete). When visible, formatted as `###0.00`.

---

## 9. Gate Test Cases — TC-PREG

| ID | Description |
|---|---|
| TC-PREG-001 | Year/month navigator lists all years containing approved or completed runs; selecting a month shows the correct runs. |
| TC-PREG-002 | Company Summary totals match the sum of all employee NET result lines for the run. |
| TC-PREG-003 | Total Cash Required equals Net Pay + Employer Taxes + Employer Benefit Contributions. |
| TC-PREG-004 | Org Rollup By Department totals equal Company Summary totals. |
| TC-PREG-005 | Org Rollup By Department "Unassigned" row captures employees with no org unit on their employment record. |
| TC-PREG-006 | Employee Detail row count equals the count of EmployeePayrollResult records for the run. |
| TC-PREG-007 | Employee row expansion shows individual result lines; result line amounts sum to the employee's column totals. |
| TC-PREG-008 | CSV export from Employee Detail contains one row per employee; column values match the on-screen figures. |
| TC-PREG-009 | Export with Line Detail contains one row per result line for the run. |
| TC-PREG-010 | A user with only `BenefitsAdmin` role can see Company Summary benefit section but cannot access Employee Detail or Org Rollup. |
| TC-PREG-011 | Hours columns are absent when no HOURS_* result lines exist; present and correct after T&A integration. |
