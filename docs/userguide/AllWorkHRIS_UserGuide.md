# AllWorkHRIS User Guide

**Version:** Phase 6 — Benefits Complete  
**Updated:** 2026-05-03

---

## Contents

1. [Getting Started](#1-getting-started)
2. [Roles and Access](#2-roles-and-access)
3. [Navigation](#3-navigation)
4. [Employees](#4-employees)
5. [Organisation](#5-organisation)
6. [Jobs & Positions](#6-jobs--positions)
7. [Work Queue](#7-work-queue)
8. [Doc Expiration](#8-doc-expiration)
9. [Pay Calendars](#9-pay-calendars)
10. [Payroll Profiles](#10-payroll-profiles)
11. [Tax Profiles](#11-tax-profiles)
12. [Payroll Runs](#12-payroll-runs)
13. [Pay Register](#13-pay-register)
14. [Accumulators](#14-accumulators)
15. [Benefits — Deduction Codes](#15-benefits--deduction-codes)
16. [Benefits — Elections](#16-benefits--elections)
17. [Benefits — Import Elections](#17-benefits--import-elections)
18. [Tax Configuration](#18-tax-configuration)
19. [Legal Entities](#19-legal-entities)
20. [Temporal Date Override](#20-temporal-date-override)

---

## 1. Getting Started

AllWorkHRIS is a web-based HR and payroll platform. Access it at the URL provided by your administrator (development: `https://localhost:5001`).

Sign in with your credentials through the Keycloak identity provider. Your name appears in the top-right corner alongside a **Sign out** link.

### Legal Entity

Most pages display a **Legal Entity** selector immediately below the top navigation — either a badge (single entity), a tab strip (2–8 entities), or a searchable list (9+ entities). Click to switch the view to that company's data. All employees, payroll runs, and documents are scoped to the selected legal entity.

---

## 2. Roles and Access

Access to pages and actions is controlled by Keycloak realm roles. A user may hold multiple roles.

| Role | What they can do |
|------|-----------------|
| `HrisViewer` | Read-only access to employee list, employee detail, organisation, and jobs |
| `HrisAdmin` | Full HRIS access — hire, terminate, transfer, manage leave, upload documents, view work queue, benefits read |
| `Manager` | Work queue access only |
| `PayrollOperator` | View payroll runs, pay register, accumulators, tax profiles, benefit elections |
| `PayrollAdmin` | Full payroll access — create runs, approve, manage calendars and profiles; also can use tax config (read + preview) |
| `TaxAdmin` | Manage tax calculation steps and form fields — create, submit for review, archive; view rate reference and preview sandbox |
| `ComplianceReviewer` | Approve or reject items submitted by TaxAdmin; also view all Tax Config pages |
| `BenefitsAdmin` | Manage deduction codes, create and terminate benefit elections, run imports |
| `SystemAdmin` | Manage legal entities; read-only access to Tax Config pages |

> **Note:** Roles are additive. A user with both `HrisAdmin` and `BenefitsAdmin` can do everything both roles allow. Ask your administrator to assign roles in Keycloak.

---

## 3. Navigation

The left sidebar is divided into sections. Only the sections for your assigned roles are visible.

**EMPLOYEES** (requires `HrisViewer` or `HrisAdmin`)
- Employees
- Organisation
- Jobs & Positions
- Work Queue *(HrisAdmin or Manager)*
- Doc Expiration *(HrisAdmin)*

**PAYROLL** (requires `PayrollOperator` or `PayrollAdmin`)
- Payroll Runs
- Pay Register
- Accumulators
- Pay Calendars *(PayrollAdmin)*
- Payroll Profiles *(PayrollAdmin)*
- Tax Profiles

**BENEFITS** (requires `HrisAdmin`, `BenefitsAdmin`, or `PayrollOperator`)
- Deduction Codes *(HrisAdmin or BenefitsAdmin)*
- Elections
- Import *(HrisAdmin or BenefitsAdmin)*

**TAX CONFIGURATION** (requires `TaxAdmin`, `ComplianceReviewer`, `PayrollAdmin`, or `SystemAdmin`)
- Calculation Steps
- Form Fields
- Rate Reference
- Preview Sandbox
- Review & Approve *(ComplianceReviewer)*

**CONFIGURATION** (requires `SystemAdmin`)
- Legal Entities

**About** — developer tools and version information (all authenticated users)

---

## 4. Employees

### 4.1 Employee List

Navigate to **Employees** in the sidebar. The list page shows four summary cards at the top:

| Card | Meaning |
|------|---------|
| Active | Employees with active employment status |
| On Leave | Employees currently on approved leave |
| Contractors | Active contractors |
| Departments | Number of departments with at least one employee |

Below the cards the employee table lists: **Employee** (avatar + name, links to detail), **Job Title**, **Department**, **Location**, **Status** (Active/On Leave badge), **Start Date**, and a **View** link.

Click **+ Add Employee** (top right, `HrisAdmin` only) to start the hire flow.

### 4.2 Hiring an Employee

The hire wizard collects information across six steps:

| Step | Fields |
|------|--------|
| 1 — Personal | Legal name, preferred name, date of birth, gender, pronouns, marital status, national identifier |
| 2 — Employment | Employee number, hire date, employment type, legal entity |
| 3 — Assignment | Department, location, manager |
| 4 — Job | Job from the catalogue |
| 5 — Compensation | Rate type (Salary / Hourly), pay rate, pay frequency; optionally select a payroll context |
| 6 — Onboarding | Target start date; system generates a standard onboarding task list automatically |

After completing all steps and clicking **Hire**, the employee appears in the list with **ACTIVE** status and a standard set of onboarding tasks is created.

### 4.3 Employee Detail

Click any employee name or the **View** link to open the detail page.

**Header** shows: avatar circle with initials, full name, employee number (e.g., EMP-00234), and a status badge (Active / On Leave / Terminated).

**Action buttons** (top right, `HrisAdmin` only):

| Button | Action |
|--------|--------|
| Change Compensation | Record a pay rate or type change (effective-dated; prior rate is preserved) |
| Transfer | Move the employee to a different department, location, or manager |
| Change Manager | Update the reporting line only |
| Place on Leave | Begin a leave event |
| Terminate (red) | Initiate the termination workflow |

**Tabs** give access to all employee data. Each data-heavy tab loads its content the first time you click it:

#### Profile

Personal information: Legal Name, Preferred Name, Date of Birth, Gender, Pronouns, Marital Status.

#### Employment

Employment record: hire date, employment type, legal entity, and termination date (if applicable).

#### Assignment

Current department, location, manager, and job assignment. Effective-dated — full history is preserved.

#### Compensation

Current pay rate, rate type (Salary/Hourly), pay frequency, and effective date. Previous rates are retained in the compensation history.

#### Leave

Leave balances and any approved or pending leave requests.

#### Documents

All compliance and HR documents attached to the employee.

| Column | Description |
|--------|-------------|
| Type | Document category (Form W-4, Form I-9, Employment Contract, License, Certification, etc.) |
| Name | Document name |
| Ver. | Version reference |
| Status | **Active** (green) or **Expired** (red) |
| Effective | Date the document became effective |
| Expires | Expiration date, or — if no expiry |
| Verified | Date verified by HR, or — if pending |
| Download | Link to download the file |

Click **+ Upload Document** to attach a new document. Select the document type, provide effective/expiry dates, and upload the file.

#### Onboarding

The Onboarding Plan shows the employee's structured onboarding checklist.

**Header fields**

| Field | Description |
|-------|-------------|
| Target Start Date | The employee's planned first day |
| Completion Date | Populated automatically when all tasks are done |
| Status badge | **Blocking Complete** (amber) — all blocking tasks done and payroll enrollment can proceed; **Completed** (green) — all tasks done |

**Task table**

| Column | Description |
|--------|-------------|
| Task | Task name |
| Type | Payroll Profile Setup / Equipment Request / IT Provisioning / Document Completion / Manager Introduction / Training Assignment / Benefits Enrollment |
| Owner | HrisAdmin / Employee / Manager — who is responsible |
| Due | Due date |
| Blocking | **Blocking** badge (amber) if this task must be completed before payroll enrollment |
| Status | Completed (green) / Pending (grey) / Waive link for non-blocking tasks |

An employee cannot be enrolled in payroll until all **Blocking** tasks are marked Completed. Standard blocking tasks: Set Up Payroll Profile, Complete W-4, Complete I-9.

#### Benefits

Shows the employee's active and historical benefit elections.

| Column | Description |
|--------|-------------|
| Code | Deduction code (e.g., `HEALTH_PRE`) |
| Treatment | `PRE_TAX` (blue) or `POST_TAX` (orange) |
| Emp Amount | Employee deduction amount per pay period |
| ER Contrib | Employer contribution amount per pay period, or — if none |
| Effective Start | First date the election is active |
| Effective End | Last date, or — if ongoing |
| Status | **ACTIVE** (green) / **PENDING** (yellow) / **SUSPENDED** (orange) / **TERMINATED** (red) |

This tab is read-only. To add or terminate an election, use the [Elections](#16-benefits--elections) page in the Benefits section.

#### Community

Employee social profile and community information (internal directory details).

#### History

A dated audit log of all changes made to the employee record — compensation changes, transfers, status changes, and document activity.

---

## 5. Organisation

Navigate to **Organisation** in the sidebar.

### Hierarchy View

The default Hierarchy view shows the organisation tree for the selected legal entity:

```
Legal Entity  Acme Manufacturing Inc.  ACME-MAN
  Division    Engineering  ENG
    Department  Backend Development  ENG-BE
```

Toggle to **List** for a flat table view of all org units.

Click **+ Add Org Unit** to add a new division, department, or team node.

### Multiple Legal Entities

Use the legal entity selector at the top to switch between companies. Each legal entity has its own separate org hierarchy.

---

## 6. Jobs & Positions

Navigate to **Jobs & Positions** in the sidebar.

Two summary cards: **Active Jobs** and **Active Positions**.

### Jobs

The Jobs table defines the job catalogue — the set of roles that can be assigned to employees.

| Column | Description |
|--------|-------------|
| Code | Short job code (e.g., `JOB-HR-MGR`) |
| Title | Job title (e.g., HR Manager) |
| Family | Job family grouping (Human Resources, Finance, Technology, etc.) |
| Level | Seniority level (Manager, Individual Contributor, etc.) |
| FLSA Classification | Exempt / Non-Exempt / Executive / Professional |
| EEO Category | EEO-1 reporting category |
| Effective Date | Date the job definition became active |

Click **+ Add Job** to define a new job.

### Positions

Positions are specific budgeted slots within the org structure (e.g., three Software Engineer positions in the Engineering department). Click **+ Add Position** to create one.

---

## 7. Work Queue

Navigate to **Work Queue** in the sidebar (`HrisAdmin` or `Manager`). The Work Queue aggregates all pending HR actions across all employees.

### Summary Cards

| Card | Description |
|------|-------------|
| Open Items | Total pending actions requiring attention |
| High Priority | Items flagged HIGH priority |

### Filters

- Filter by employee name (text field)
- Filter by due date range
- Filter by status (All / Open / etc.)

Click **Refresh** to reload the queue from the server.

### Document Alerts

The top section lists documents that are expiring soon or have already expired.

| Column | Description |
|--------|-------------|
| Title | Alert description (e.g., "CERTIFICATION document expiring in 4 days") |
| Employee | Employee name (links to their detail page) |
| Description | Document type and specific expiry date |
| Priority | **HIGH** (red) / **MEDIUM** (orange) / **NORMAL** (grey) badge |
| Days / Expiry | Days until expiry and the expiry date |

### Onboarding Tasks

The lower section lists open onboarding tasks across all employees.

| Column | Description |
|--------|-------------|
| Title | Task name (e.g., Onboarding Payroll Profile Setup) |
| Employee | Employee name |
| Priority | Priority badge |
| Due | Due date |

Click an employee name to go directly to their Onboarding tab.

---

## 8. Doc Expiration

Navigate to **Doc Expiration** in the sidebar (`HrisAdmin`). This standalone report shows all expiring and expired documents across the selected legal entity.

### Summary Cards

| Card | Threshold | Colour |
|------|-----------|--------|
| Expired | Already past expiry | Red |
| Expiring ≤ 30 days | Expiring within a month | Amber |
| Expiring 31–90 days | Expiring within a quarter | Yellow |

### Filters

- **Employee name** — free-text filter
- **Document type** — dropdown (All document types / specific type)
- **Status** — dropdown (All statuses / Expired / Active / etc.)

Click **Refresh** to reload.

### Report Table

| Column | Description |
|--------|-------------|
| Employee | Employee name (links to their Documents tab) |
| Document Name | Name of the document |
| Type | Document category |
| Effective | Date the document became effective |
| Expiration | Expiration date |
| Status | **Expired Xd ago** badge (red) or days-remaining indicator |
| Download | Download link for the file |

---

## 9. Pay Calendars

Navigate to **Pay Calendars** in the sidebar (`PayrollAdmin`). Pay Calendars defines the payroll contexts (pay groups) and their period schedules.

### Payroll Context List

The list shows all payroll contexts for the selected legal entity, each with its context code, frequency, and status. Click a context name to view its period calendar.

Click **+ New Context** to create a new pay group.

### Creating a Payroll Context

| Field | Description |
|-------|-------------|
| Context Code | Short identifier (e.g., `CORP-BW`, `AMI-CORP-MNTH`) |
| Context Name | Display name (e.g., Corporate Biweekly) |
| Rate Type | Salary or Hourly |
| Pay Frequency | Biweekly / Monthly / Semi-Monthly / Weekly |
| Effective Start Date | Date from which this context is valid |
| Pay Date Convention | How the pay date relates to the period end — four options with descriptions shown inline |
| Input Cutoff | Number of days before period end that payroll input must be finalised |

Click **Create Context** to save.

### Payroll Context Detail

Opening a context shows its summary and the period calendar.

**Context summary fields**

| Field | Description |
|-------|-------------|
| Code | Short code |
| Pay Frequency | Monthly / Biweekly / etc. |
| Effective From | Start date of the context |
| Effective To | End date, or — if still active |
| Periods on Record | Total periods generated |
| Open Periods | Periods not yet closed |

**Status badge** (top right): **ACTIVE** (green) or INACTIVE.

**Delete Context** button is available when no runs exist for this context.

### Generating the Period Calendar

Use the **Year** dropdown and **Status** filter to navigate. Click **Generate Calendar for [Year]** to auto-generate all periods based on the context's frequency and pay date convention.

To remove a generated year's periods (before any runs have been initiated), click **Clear [Year] Calendar**.

### Period Grid

| Column | Description |
|--------|-------------|
| Period | Period label (P1–P12 for monthly; 1–26 for biweekly) |
| Start Date | First day of the pay period |
| End Date | Last day of the pay period |
| Cutoff | Input cutoff date |
| Run Date | Scheduled date to run payroll — click **edit** to adjust |
| Pay Date | Date employees are paid |
| Status | **OPEN** (teal) — ready for a run |

---

## 10. Payroll Profiles

Navigate to **Payroll Profiles** in the sidebar (`PayrollAdmin`). This page manages which employees are enrolled in which payroll contexts.

### Summary Cards

| Card | Description |
|------|-------------|
| Enrolled | Employees currently active in a payroll context |
| Final Pay Pending | Employees with a pending termination final pay |
| Disenrolled | Profiles that have been manually disenrolled |
| Terminated | Profiles ended due to employment termination |

### Bulk Enroll

Use the Bulk Enroll section to enroll one or more employees in a payroll context at once.

1. Select the **Payroll Context** from the dropdown.
2. Set the **Effective Date** for enrollment.
3. Optionally filter the employee list by Division, Department, Location, Rate Type, or Pay Frequency.
4. Check the employees to enroll in the table.
5. Click **Enroll Selected**.

> **Note:** An employee must have all blocking onboarding tasks completed before they can be enrolled.

### Automatic Enrollment (AUTO_HIRE)

When an employee is hired and a matching payroll context exists, the system automatically creates a payroll profile. These profiles show **AUTO_HIRE** in the Source column. Manually created profiles show **MANUAL**.

### Enrolled Profiles Table

| Column | Description |
|--------|-------------|
| Employee | Employee name |
| Payroll Context | The pay group the employee belongs to |
| Enrollment Status | **ACTIVE** (green) / DISENROLLED / TERMINATED |
| Source | MANUAL or AUTO_HIRE |
| Effective From | First date the profile is active |
| Effective To | Last date, or — if ongoing |
| Final Pay | Indicator if this is a final-pay profile |

---

## 11. Tax Profiles

Navigate to **Tax Profiles** in the sidebar (`PayrollAdmin` or `PayrollOperator`). This page records each employee's tax withholding elections for every jurisdiction they are subject to.

### Selecting an Employee

Type in the search box to find an employee by name. Click their name in the results dropdown to select them.

Once selected, the page shows one collapsible card per jurisdiction. Click a card header to expand it.

### Jurisdiction Cards

Each jurisdiction card shows:
- Country flag and jurisdiction name (e.g., 🇺🇸 US Federal, 🇺🇸 Georgia, 🇨🇦 Canada Federal)
- **On file** badge (green) if a tax form submission exists; **No form** (grey) if not yet recorded

Expand a card to see the form fields for that jurisdiction. The fields vary by jurisdiction:

| Jurisdiction | Form | Key fields |
|---|---|---|
| US Federal | W-4 (2020+) | Filing status, additional withholding, other income, deductions |
| Georgia | G-4 | Filing status, allowances |
| New York | IT-2104 | Allowances, additional withholding |
| California | DE-4 | Filing status, allowances |
| Canada Federal | TD1 | Claim amount, other deductions |
| Barbados | BB TD4 | Allowances |

Click **Edit** (or the card header if not yet submitted) to enter form values. Click **Save** to record the election. The calculation engine uses these values when computing tax withholding for payroll runs.

---

## 12. Payroll Runs

Navigate to **Payroll Runs** in the sidebar (`PayrollOperator` or `PayrollAdmin`). This is the primary payroll processing area.

### Context Selector

The runs list is scoped to a payroll context. The active context appears below the page heading. Click **Change** to switch to a different context.

### Summary Cards

| Card | Description |
|------|-------------|
| Open Runs | Runs in Draft, Calculating, Calculated, or Approved state |
| Pending Approval | Runs waiting for an approver |
| Last Pay Date | Most recent completed pay date |
| Next Open Pay Date | Upcoming scheduled pay date |

### Run List

| Column | Description |
|--------|-------------|
| Description | Run name (links to detail) |
| Period | Pay period (e.g., 2026 P9 04/23–05/06) |
| Pay Date | Scheduled employee pay date |
| Type | Regular / Supplemental / Off-Cycle |
| Status | Current run status |
| Actions | View link |

### Creating a New Run

Click **+ New Run** (`PayrollAdmin` or `PayrollOperator`). Provide:
- **Period** — select from the open periods in the calendar
- **Run Type** — Regular / Supplemental / Off-Cycle
- **Description** — label for this run
- **Parent Run** (optional) — for supplemental runs linked to a prior regular run

If the selected period's pay date is still in the future, a confirmation panel (amber) appears before submission. Click **Yes, initiate early** to proceed, or **Go back** to return to the form. This early-initiation is by design — ACH pre-processing often begins before the pay date.

The run is created in **Draft** status and queued for the calculation engine immediately.

### Run Lifecycle

```
Draft → Calculating → Calculated → Approved → Releasing → Released → Closed
                                       ↓
                                   Cancelled
```

| Status | Description |
|--------|-------------|
| Draft | Created, queued for calculation |
| Calculating | Calculation engine is processing employees |
| Calculated | All employees processed; results available for review |
| Approved | Approved; ready for release |
| Releasing | Release in progress |
| Released | Payments have been released |
| Closed | Run is finalised and locked |
| Cancelled | Run was cancelled before release |
| Failed | Calculation encountered a fatal error |

### Run Detail — Summary Tab

**Run Details**

| Field | Description |
|-------|-------------|
| Run ID | Abbreviated unique identifier |
| Payroll Context | The pay group this run belongs to |
| Period | Pay period (date range) |
| Pay Date | Employee pay date |
| Run Type | Regular / Supplemental / Off-Cycle |
| Started | Timestamp when calculation began |
| Completed | Timestamp when calculation finished |

**Run Totals**

| Field | Description |
|-------|-------------|
| Employees | Number of employees included |
| Gross Pay | Total gross earnings |
| Total Deductions | Total pre-tax and post-tax deductions |
| Employee Tax | Total employee-side tax withheld |
| Employer Contribution | Total employer-side contributions (benefits + employer payroll taxes) |
| Net Pay | Total take-home pay |

**Actions**

| Run Status | Available Actions |
|------------|-------------------|
| Calculated | **Approve**, **Cancel Run** |
| Approved | **Release** |
| Released / Closed | No actions (read-only) |
| Draft / Calculating | No manual actions |

### Run Detail — Pay Register Tab

The Pay Register tab shows the per-employee breakdown.

| Column | Description |
|--------|-------------|
| Employee | Employee name |
| Pay Period | Date range |
| Gross Pay | Total gross earnings |
| Deductions | Total deductions (pre-tax benefits) |
| Emp Tax | Employee tax withheld |
| Er Contrib | Employer contributions (employer taxes + employer benefit contributions) |
| Net Pay | Take-home amount |
| Status | Calculating / Calculated / Exception |

A **Totals** row aggregates all columns. Click an employee name to drill into their individual result (earnings lines, deduction breakdown, tax lines).

---

## 13. Pay Register

The **Pay Register** sidebar link is a convenience shortcut. Because the register is run-specific, it redirects you with instructions:

> To view the pay register for a specific run, open that run from Payroll Runs and select the Pay Register tab.

A cross-run register report with filtering and export is planned for a future release.

---

## 14. Accumulators

The **Accumulators** page will display year-to-date and period-to-date balances by employee, accumulator type, and legal entity. This view is planned for a future release.

Accumulator data is calculated and stored as part of each payroll run and is accessible via the per-employee run result detail in the interim.

---

## 15. Benefits — Deduction Codes

Navigate to **Deduction Codes** under **BENEFITS** in the sidebar (`HrisAdmin` or `BenefitsAdmin`). Deduction codes are the master catalogue of benefit deduction types. Every benefit election must reference a deduction code.

### Code List

The table shows all deduction codes, active and inactive.

| Column | Description |
|--------|-------------|
| Code | Short identifier (e.g., `HEALTH_PRE`, `DENTAL_POST`) |
| Description | Human-readable name |
| Tax Treatment | **PRE_TAX** (blue) — deducted before income tax; **POST_TAX** (orange) — deducted after all tax |
| Status | **ACTIVE** (green) or **INACTIVE** (grey) |
| Effective Start | First date the code is valid |
| Effective End | Last date, or — if ongoing |
| Actions | **Edit** button |

Click **+ Add Code** to create a new deduction code.

### Adding a Deduction Code

| Field | Required | Description |
|-------|----------|-------------|
| Code | Yes | Up to 30 characters; automatically uppercased. Cannot be changed after creation. |
| Tax Treatment | Yes | PRE_TAX or POST_TAX. Cannot be changed after creation. |
| Description | Yes | Up to 200 characters. |
| Effective Start | Yes | Date the code becomes valid. |
| Effective End | No | Leave blank for an open-ended code. |

New codes are always created with **ACTIVE** status.

### Editing a Deduction Code

Click **Edit** on any row. Code and Tax Treatment are locked (cannot be changed). You can update:
- Description
- Status (ACTIVE / INACTIVE)
- Effective End date

> **Important:** Setting a code to INACTIVE does not terminate existing elections — it only prevents new elections from being created against that code. To remove a code from active payroll processing, terminate the individual elections.

### How Tax Treatment Affects Payroll

- **PRE_TAX** deductions are applied before income tax is calculated. They reduce the employee's taxable wage base, resulting in lower income tax withholding for that period.
- **POST_TAX** deductions are applied after all tax has been calculated. They reduce net pay only and do not affect tax amounts.

---

## 16. Benefits — Elections

Navigate to **Elections** under **BENEFITS** in the sidebar (`HrisAdmin`, `BenefitsAdmin`, or `PayrollOperator`). The Elections page shows all employee benefit elections across all employees.

> **PayrollOperator** can view elections but cannot add or terminate them.

### Filters

Use the filter bar to narrow the list:
- **Code** — type a deduction code to filter by code
- **Status** — dropdown: All / Pending / Active / Suspended / Terminated

Click **Filter** to apply. Pagination controls appear when there are more than 20 results.

### Election List

| Column | Description |
|--------|-------------|
| Employee | First 8 characters of the Employment ID (unique internal identifier) |
| Code | Deduction code |
| Treatment | PRE_TAX or POST_TAX badge |
| Emp Amount | Employee deduction per pay period |
| ER Amount | Employer contribution per pay period, or — |
| Effective Start | First date the election applies |
| Effective End | Last date, or — |
| Status | **ACTIVE** / **PENDING** / **SUSPENDED** / **TERMINATED** |
| Source | **MANUAL** (entered in the UI) or **IMPORT** (loaded via CSV) |
| Actions | **Terminate** button for ACTIVE or PENDING elections (`HrisAdmin` and `BenefitsAdmin` only) |

### Adding an Election

Click **+ Add Election** (`HrisAdmin` or `BenefitsAdmin`).

| Field | Required | Description |
|-------|----------|-------------|
| Employment ID | Yes | The employee's UUID (from their record). Must be a valid UUID. |
| Deduction Code | Yes | Select from active deduction codes. |
| Employee Amount | Yes | Deduction amount per pay period. Must be ≥ 0. |
| Employer Contribution | No | Employer-side contribution per pay period. |
| Effective Start | Yes | Date the election becomes active. |
| Effective End | No | Leave blank for an ongoing election. |

If the employee already has an active election for the same code, the system will still create the new election but log a warning. Review duplicate elections before the next payroll run.

### Election Status Lifecycle

```
(created with start date in past)  → ACTIVE
(created with start date in future) → PENDING  → ACTIVE (on start date)
ACTIVE  → SUSPENDED (when employee goes on unpaid leave)
SUSPENDED → ACTIVE  (when employee returns from leave)
ACTIVE or PENDING → TERMINATED (manual termination or employment termination)
```

### Terminating an Election

Click **Terminate** on an ACTIVE or PENDING election. A confirmation panel appears inline:

> Terminate election **HEALTH_PRE** for employment **a3f2c1d0…**?

Click **Yes, Terminate** to confirm. The election's status changes to TERMINATED and the effective end date is set to today. The election will not appear in subsequent payroll runs.

### Automatic Election Events

The system automatically adjusts elections in response to HRIS events:

| HRIS Event | Effect on Benefits |
|---|---|
| Employee terminated | All ACTIVE and PENDING elections terminated automatically |
| Employee placed on unpaid leave | All ACTIVE elections suspended |
| Employee returns from leave | All SUSPENDED elections reinstated to ACTIVE |

---

## 17. Benefits — Import Elections

Navigate to **Import** under **BENEFITS** in the sidebar (`HrisAdmin` or `BenefitsAdmin`). The Import page loads benefit elections in bulk from a CSV file.

### CSV Format

The file must have a header row. Columns must be in this exact order:

```
employment_id, deduction_code, employee_amount, employer_contribution_amount, effective_start_date, effective_end_date
```

- `employment_id` — UUID of the employee's employment record
- `deduction_code` — must match an existing active deduction code
- `employee_amount` — numeric, must be ≥ 0
- `employer_contribution_amount` — numeric, optional (leave blank if none)
- `effective_start_date` — date in `YYYY-MM-DD` format
- `effective_end_date` — date in `YYYY-MM-DD` format, optional (leave blank for open-ended)

Maximum file size: 5 MB.

### Import Process

The import is a two-step process:

**Step 1 — Upload and Validate**

1. Click **Choose File** and select your CSV.
2. Click **Validate**.
3. The system reads all rows and checks each one without posting any data.

After validation, you see a summary:

| Card | Description |
|------|-------------|
| Total Records | Total rows in the file (excluding header) |
| Valid | Rows that passed all validation checks |
| Invalid | Rows with errors |

If there are invalid rows, a table lists each one with the row number, the field that failed, and the error message. Fix these rows in your CSV and re-upload if needed.

**Step 2 — Review and Import**

If there are valid records, click **Import N Valid Records**. The valid rows are posted and the elections are created. Invalid rows are skipped — they are not imported even partially.

A confirmation message shows a Job ID for tracking the batch submission.

Click **Start Over** to upload a new file.

> **Note:** The import creates new elections — it does not update or terminate existing ones. If an employee already has an election for the same code, a duplicate warning is logged but the new election is still created. Review the elections list after import.

---

## 18. Tax Configuration

The Tax Configuration section is accessible from the sidebar to users with `TaxAdmin`, `ComplianceReviewer`, `PayrollAdmin`, or `SystemAdmin` roles. It provides visibility into and control over the payroll calculation pipeline.

> **How tax calculation works:** Every payroll run passes each employee's gross pay through a pipeline of ordered calculation steps. Each step applies one tax rule — a progressive income tax bracket, a flat FICA rate, a standard deduction, etc. Steps are sorted by sequence number, so pre-tax benefit deductions (sequence 100–199) run before income tax steps (300–399), ensuring that pre-tax elections correctly reduce the taxable base.

### 18.1 Rate Reference

Navigate to **Rate Reference** (read-only, all Tax Config roles). This page shows all **ACTIVE** calculation steps and their current rate data, grouped by jurisdiction. Use it to verify what rates are currently in effect.

Jurisdictions shown: `BB` (Barbados), `CA-FED` (Canada Federal), `US-CA` (California), `US-FED` (US Federal), `US-GA` (Georgia), `US-NY` (New York).

For each step you can see:
- Sequence number (determines calculation order)
- Step code and name
- Step type (Progressive, Flat Rate, Tiered, Allowance, Credit, etc.)
- Who the step applies to (ALL_EMPLOYEES, EMPLOYER_ONLY, etc.)
- Current rate rows with their effective dates and summaries

### 18.2 Calculation Steps

Navigate to **Calculation Steps** (`TaxAdmin`, `ComplianceReviewer`, `PayrollAdmin`, `SystemAdmin`). This page shows all steps for a selected jurisdiction and allows TaxAdmin to manage their lifecycle.

Select a **Jurisdiction** from the dropdown to load its steps.

**Step table columns**

| Column | Description |
|--------|-------------|
| Seq | Sequence number — determines order of execution in the pipeline |
| Step Code | Internal identifier |
| Name | Human-readable description |
| Type | Algorithm used (Progressive, Flat Rate, Tiered, Std Deduction, Credit, % of Prior) |
| Applies To | Which employees this step applies to |
| Status | DRAFT / PENDING_REVIEW / APPROVED / ACTIVE / ARCHIVED |

**Actions per status:**

| Status | Available actions |
|--------|------------------|
| DRAFT | Submit for Review, Archive |
| PENDING_REVIEW | Awaiting ComplianceReviewer approval (no actions for TaxAdmin) |
| APPROVED | Activate |
| ACTIVE | Archive |

Click **Rates** next to any step to expand a panel showing all rate rows for that step, including effective date ranges and a human-readable summary.

**Step status lifecycle:**
```
DRAFT → PENDING_REVIEW → APPROVED → ACTIVE → ARCHIVED
                ↓
             DRAFT (if rejected by ComplianceReviewer)
```

A **Recent Activity** audit log appears at the bottom showing who made each status change and any review notes.

### 18.3 Form Fields

Navigate to **Form Fields** (`TaxAdmin`, `ComplianceReviewer`, `PayrollAdmin`, `SystemAdmin`). This page shows the field definitions for each tax withholding form.

Select a **Form Type** from the dropdown:

| Code | Form |
|------|------|
| `W4_2020` | US Federal W-4 (2020+) |
| `W4_LEGACY` | US Federal W-4 (Pre-2020) |
| `G_4` | Georgia G-4 |
| `IT_2104` | New York IT-2104 |
| `DE_4` | California DE-4 |
| `TD1` | Canada TD1 (Federal) |
| `BB_TD4` | Barbados TD4 |

The field table shows each field's display order, section, label, internal key, data type (text, number, dropdown, checkbox), and whether it is Required or Optional.

The **Required** checkbox can be toggled inline. Use **Submit**, **Activate**, and **Archive** buttons to manage field lifecycle (same DRAFT → PENDING_REVIEW → APPROVED → ACTIVE flow as steps).

### 18.4 Preview Sandbox

Navigate to **Preview Sandbox** (`TaxAdmin`, `ComplianceReviewer`, `PayrollAdmin`, `SystemAdmin`). This tool runs a hypothetical payroll calculation against the current pipeline configuration. **No payroll records are created or modified.**

| Field | Description |
|-------|-------------|
| Jurisdiction | Select the jurisdiction to preview |
| Pay Date | The pay date for the calculation (defaults to today) |
| Gross Pay (period) | Hypothetical gross pay for the period |
| Pay Periods / Year | 52 (weekly), 26 (biweekly), 24 (semi-monthly), 12 (monthly) |
| Filing Status | Optional — select from the jurisdiction's available filing statuses |

Click **Run Preview**. The result shows:

- **Gross Pay** — the input gross pay
- **Computed Tax** — total employee tax withholding
- **Employer Cost** — total employer-side taxes and contributions
- **Net Pay** — gross minus all employee deductions

Below the summary, two tables break down the result step by step:

**Employee Step Results** — each step code, the amount it withheld, and its percentage of gross pay.

**Employer Step Results** — each employer-side contribution (e.g., employer FICA match).

Use the Preview Sandbox to verify that a new rate configuration produces the expected result before activating the steps.

### 18.5 Review & Approve

Navigate to **Review & Approve** (`ComplianceReviewer` only). This page shows all items submitted by TaxAdmin that are waiting for approval.

| Column | Description |
|--------|-------------|
| Type | Step or Form Field |
| Jurisdiction / Form | The jurisdiction code or form type |
| Item | Step code or field key |
| Submitted By | Who submitted it |
| Submitted At | Timestamp |
| Actions | Approve… / Reject… buttons |

Clicking **Approve…** or **Reject…** on a row opens an inline confirmation panel with an optional **Note** field. Click **Confirm Approve** or **Confirm Reject** to finalise.

- **Approve** moves the item from PENDING_REVIEW to APPROVED. A TaxAdmin can then activate it.
- **Reject** returns the item to DRAFT status for the TaxAdmin to revise.

---

## 19. Legal Entities

Navigate to **Legal Entities** under **CONFIGURATION** in the sidebar (`SystemAdmin` only). This page manages the top-level companies in the system.

Legal entities are the root of the org hierarchy. Every employee, payroll context, and payroll run belongs to a legal entity.

Click **+ Add Legal Entity** to create a new company. Provide:
- Legal name
- Short code (used as the identifier across the system)
- Legal entity type (Corporation, LLC, Partnership, Non-Profit, etc.)

---

## 20. Temporal Date Override

The Temporal Date Override (TDO) is a **developer tool** that shifts the system's operative date for all temporal queries — useful for testing date-sensitive logic such as document expiration, period cutoffs, and effective-dated records.

### Accessing TDO

Open the **About** page (link in the sidebar footer or directly at `/about`). Scroll to the **Developer Tools** section.

### Setting an Override Date

1. Enter a date in the date picker under **Temporal Date Override**.
2. Click **Set** (a confirmation panel appears — click **Confirm Set** to proceed).

A persistent amber banner appears at the top of every page:

> **DEV** &nbsp; ⏰ Operative Date: **2026-06-22**

All pages that use temporal filtering reflect the overridden date. The banner is a reminder that real-time data is not being shown.

### Clearing the Override

Click **Clear** in the Developer Tools panel (confirm in the confirmation panel). The banner disappears and the system returns to the real current date.

> **Warning:** The TDO affects all temporal queries globally. It affects: HRIS effective-date queries, document expiration, payroll period cutoffs, pay date comparisons, tax rate effective dates, and benefit election date filtering. Do not leave an override active unintentionally.

---

## Appendix A — Status Reference

### Employment Status

| Status | Meaning |
|--------|---------|
| ACTIVE | Employee is actively employed |
| ON_LEAVE | Employee is on approved leave |
| TERMINATED | Employment has ended |

### Payroll Run Status

| Status | Meaning |
|--------|---------|
| Draft | Created, queued for calculation |
| Calculating | Engine is processing |
| Calculated | Results ready for review |
| Approved | Approved for release |
| Releasing | Release in progress |
| Released | Payments sent |
| Closed | Finalised and locked |
| Cancelled | Cancelled before release |
| Failed | Fatal calculation error |

### Benefit Election Status

| Status | Meaning |
|--------|---------|
| PENDING | Election created with a future start date; not yet in payroll |
| ACTIVE | Election is in effect and included in each payroll run |
| SUSPENDED | Temporarily paused (employee on unpaid leave) |
| TERMINATED | Election has ended; no longer in payroll |

### Tax Calculation Step Status

| Status | Meaning |
|--------|---------|
| DRAFT | Being configured; not yet submitted |
| PENDING_REVIEW | Submitted by TaxAdmin; awaiting ComplianceReviewer action |
| APPROVED | Approved by ComplianceReviewer; TaxAdmin can activate |
| ACTIVE | In use by the calculation engine |
| ARCHIVED | Retired; no longer in use |

---

## Appendix B — Payroll Calculation Order

Every payroll run passes gross pay through a sorted pipeline of steps. The sequence number determines order:

| Sequence range | Type | Examples |
|---------------|------|---------|
| 100–199 | Pre-tax benefit deductions | Health premium, 401k, FSA, HSA — reduce taxable wage base |
| 200–299 | Standard deductions and allowances | Personal exemptions |
| 300–399 | Income tax — progressive brackets | US Federal, Georgia, New York, California |
| 400–499 | Income tax — flat rates | Barbados income tax |
| 500–599 | FICA / payroll tax | Social Security, Medicare, Canada CPP/EI |
| 600–699 | Credits | Basic Personal Amount (Canada) |
| 700–799 | Employer-only steps | Employer FICA match, employer CPP/EI |
| 800–899 | Post-tax benefit deductions | Roth 401k, supplemental life — reduce net pay only |

Pre-tax deductions (100–199) run before all tax steps, so they correctly reduce the taxable base. Post-tax deductions (800–899) run after all tax, so they only reduce take-home pay.

---

*AllWorkHRIS — Internal Development Build — Phase 6 Complete*
