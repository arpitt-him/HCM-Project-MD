# SPEC — Pay Statement Delivery

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Core Platform / Payroll |
| **Location** | `docs/SPEC/Pay_Statement_Delivery.md` |
| **Related Documents** | docs/architecture/interfaces/Pay_Statement_Model.md, docs/architecture/interfaces/Pay_Statement_Template_Model.md, docs/architecture/calculation-engine/Net_Pay_and_Disbursement_Model.md, SPEC/Self_Service_Model.md, docs/NFR/HCM_NFR_Specification.md, PRD-0900_Integration_Model |

## Purpose

Defines the implementation-ready requirements for pay statement content, format, delivery channels, employee access, retention, accessibility, and security. Extends the data structure defined in `Pay_Statement_Model.md` with the operational and presentational requirements necessary to produce and deliver a compliant, accessible pay statement to every employee on every pay cycle.

---

## 1. User Stories

**Employee** needs to **access their current and historical pay statements from any device at any time** in order to **verify their pay, complete loan applications, and manage personal finances without contacting HR.**

**Employee** needs to **download a PDF copy of any pay statement** in order to **provide proof of income to a third party such as a landlord or lender.**

**Payroll Administrator** needs to **suppress paper pay statements by default and track employee paper opt-in consent** in order to **reduce paper costs and comply with jurisdictions that permit electronic-only delivery when employee consent is on file.**

**Compliance Auditor** needs to **retrieve any employee's pay statement for any period within the retention window** in order to **respond to regulatory inquiries, wage claims, and legal discovery.**

**HR Administrator** needs to **configure an employer message that appears on all pay statements for a given pay period** in order to **communicate time-sensitive notices (rate changes, benefit updates, holiday schedules) to all employees.**

---

## 2. Scope Boundaries

### In Scope — v1

**REQ-PAY-001**
Electronic pay statement delivery via authenticated web portal and mobile-responsive web interface shall be mandatory in v1.

**REQ-PAY-002**
Pay statement download as a PDF file shall be mandatory in v1.

**REQ-PAY-003**
Paper suppression as the default delivery mode shall be implemented in v1, with paper opt-in tracking per employee.

**REQ-PAY-004**
Pay statement retention and retrieval for a minimum of 7 years shall be implemented in v1.

**REQ-PAY-005**
WCAG 2.1 AA accessibility compliance for electronic pay statements shall be implemented in v1.

**REQ-PAY-006**
Secure delivery — authenticated access only, no PII in transit outside encrypted channels — shall be implemented in v1.

### Out of Scope — v1

**REQ-PAY-007**
Email delivery of pay statement notifications (email with link to portal) is out of scope for v1 but the delivery framework must be designed to accommodate it without structural change.

**REQ-PAY-008**
Push notifications for mobile pay statement availability are out of scope for v1.

**REQ-PAY-009**
Multi-language pay statement delivery is out of scope for v1. English only.

**REQ-PAY-010**
A dedicated native mobile application is out of scope for v1. Mobile-responsive web access is mandatory.

---

## 3. Pay Statement Content Requirements

### 3.1 Required Sections

Every pay statement shall include all of the following sections. Sections with no data for a given employee and period (e.g. no overtime) shall be suppressed rather than displayed as zero-value rows.

#### Section 1 — Employer Block

| Field | Required | Notes |
|---|---|---|
| Employer legal name | Yes | |
| Employer address | Yes | Street, city, state, zip |
| Employer phone number | Yes | |
| Employer EIN (masked) | No | Configurable per template |

#### Section 2 — Employee Block

| Field | Required | Notes |
|---|---|---|
| Employee legal name | Yes | First and last |
| Employee address | Yes | Current address of record |
| Employee ID / Employee Number | Yes | |
| SSN | Yes — last 4 digits only | Full SSN must never appear on a pay statement. Format: XXX-XX-NNNN |
| Department | No | Configurable per template |
| Job title | No | Configurable per template |

#### Section 3 — Pay Period Block

| Field | Required | Notes |
|---|---|---|
| Pay period start date | Yes | |
| Pay period end date | Yes | |
| Pay date | Yes | |
| Check number / Payment reference | No | Configurable per template |

#### Section 4 — Earnings

Columns: Description | Hours | Rate | Current Period Amount | YTD Amount

| Earning type | Required | Notes |
|---|---|---|
| Regular / Salary | Yes | Hours and Rate columns for hourly; Rate suppressed for salaried |
| Overtime | Conditional | Only when applicable; Rate shown as 1.5× or 2× base |
| Holiday pay | Conditional | |
| Bonus / Supplemental | Conditional | |
| Commission / Residual | Conditional | |
| Paid leave (PTO, Sick, Vacation) | Conditional | |
| Other earning types | Conditional | Description from payroll item code |
| Gross Pay total | Yes | Current period and YTD |

**REQ-PAY-020**
The earnings section shall display a separate line for each distinct earning code with a non-zero amount for the period.

**REQ-PAY-021**
Hours and Rate columns shall be populated for hourly earnings. For salaried earnings, Hours and Rate may be suppressed or displayed as N/A per template configuration.

**REQ-PAY-022**
The earnings section shall always display a Gross Pay subtotal line showing current period and YTD amounts.

#### Section 5 — Deductions

Deductions shall be displayed in three subsections in this order:

**Pre-Tax Deductions** — Columns: Description | Current | YTD
- 401(k) / retirement contributions
- Pre-tax health, dental, vision premiums
- HSA / FSA contributions
- Other pre-tax deductions
- Pre-Tax Deductions subtotal

**Statutory Taxes** — Columns: Description | Current | YTD
- Federal Income Tax
- Social Security Tax (OASDI)
- Medicare Tax
- State Income Tax (per jurisdiction)
- Local / City / County taxes (per jurisdiction)
- SUI / SDI (employee-paid, where applicable)
- Taxes subtotal

**Post-Tax Deductions** — Columns: Description | Current | YTD
- Roth 401(k) contributions
- Post-tax insurance premiums
- Garnishments (description shall reference order type only, not case details)
- Other post-tax deductions
- Post-Tax Deductions subtotal

**REQ-PAY-023**
Pre-tax deductions, statutory taxes, and post-tax deductions shall appear as distinct subsections with individual subtotals. They shall never be merged into a single deductions list.

**REQ-PAY-024**
Every deduction line shall display both the current period amount and the YTD amount.

#### Section 6 — Federal Taxable Wages Disclosure

**REQ-PAY-025**
The pay statement shall include a Federal Taxable Wages disclosure line showing the employee's federal taxable wages for the period. This is calculated as Gross Pay minus pre-tax deductions and is required to allow employees to verify that pre-tax benefit deductions are being applied correctly.

Format: `Federal taxable wages this period: $X,XXX.XX`

#### Section 7 — Summary Block

| Field | Required | Notes |
|---|---|---|
| Total Earnings (Gross Pay) | Yes | Current and YTD |
| Total Pre-Tax Deductions | Yes | Current and YTD |
| Total Taxes | Yes | Current and YTD |
| Total Post-Tax Deductions | Yes | Current and YTD |
| Net Pay | Yes | Current and YTD — prominently displayed |

**REQ-PAY-026**
Net Pay shall be the most visually prominent value on the pay statement.

#### Section 8 — Leave / Accrual Balances (Optional)

| Field | Notes |
|---|---|
| Leave type name | e.g. Vacation, Sick, PTO |
| Hours / Days used this period | |
| Hours / Days available | Current balance |

**REQ-PAY-027**
Leave balance display is configurable per employer. When enabled, each configured leave type shall display hours used in the period and hours available as of the pay date.

#### Section 9 — Payment Information (Optional)

| Field | Notes |
|---|---|
| Payment method | e.g. Direct Deposit, Check |
| Bank name | Optional — configurable |
| Account number | Last 4 digits only if displayed |
| Check number | For printed check payments |

#### Section 10 — Employer Messages (Optional)

**REQ-PAY-028**
The pay statement shall support a configurable free-text message field that an employer or payroll administrator can populate for a given pay period. The message shall appear at the bottom of the statement. Maximum length: 500 characters.

---

## 4. Format Requirements

**REQ-PAY-030**
The electronic pay statement shall render correctly on screen widths from 375px (mobile) to 1440px (desktop) without horizontal scrolling or content truncation.

**REQ-PAY-031**
The downloadable pay statement shall be generated as a PDF/A file (ISO 19005 archival format) to ensure long-term readability and print fidelity.

**REQ-PAY-032**
PDF pay statements shall be tagged for accessibility — heading structure, reading order, and alt text for any non-text elements — to support screen reader compatibility.

**REQ-PAY-033**
PDF file names shall follow this format: `{EmployeeID}_{YYYY-MM-DD}_PayStatement.pdf` where the date is the Pay Date.

**REQ-PAY-034**
The pay statement template shall support employer logo placement in the header block. Logo display is optional and configurable per employer.

**REQ-PAY-035**
Numeric amounts shall use comma-separated thousands formatting and two decimal places throughout: `$1,234.56`. Negative amounts shall be displayed with a leading minus sign: `-$123.45`.

---

## 5. Delivery Channels

### 5.1 Web Portal (Mandatory)

**REQ-PAY-040**
Employees shall access pay statements through the authenticated self-service portal (ESS-004 per SPEC/Self_Service_Model.md).

**REQ-PAY-041**
The pay statement list view shall display all statements for the employee in reverse chronological order with pay date, pay period, and net pay amount visible without opening each statement.

**REQ-PAY-042**
An employee shall be able to filter pay statements by date range and download individual or multiple statements as PDF files.

**REQ-PAY-043**
Pay statements shall be available in the portal within 2 hours of the associated payroll run reaching STATE-RUN-015 (Completed).

### 5.2 Mobile Web (Mandatory)

**REQ-PAY-044**
The pay statement portal shall be fully functional on mobile browsers without requiring a native app. All statement viewing, filtering, and PDF download capabilities shall be available on mobile.

**REQ-PAY-045**
The mobile pay statement view shall present sections in a single-column stacked layout. Net Pay shall be visible without scrolling on initial load.

**REQ-PAY-046**
PDF download on mobile shall trigger the device's native file handling (download to device or open in PDF viewer) rather than attempting to render the PDF in the browser.

### 5.3 Paper (Opt-In Only)

**REQ-PAY-047**
Paper pay statement delivery shall be suppressed by default for all employees. Electronic delivery is the default.

**REQ-PAY-048**
An employee who wishes to receive paper pay statements shall explicitly opt in. The opt-in action shall be recorded with timestamp and the identity of the actor (employee self-service or HR administrator on behalf of employee).

**REQ-PAY-049**
Jurisdictions that require explicit employee consent before suppressing paper delivery shall be supported via a consent tracking flag on the Employment record. The system shall not suppress paper for employees in those jurisdictions until the consent flag is set.

**REQ-PAY-050**
Paper opt-in and opt-out events shall be permanently retained in the audit log and shall not be modifiable after the fact.

---

## 6. Retention and Access

**REQ-PAY-055**
Pay statements shall be retained and accessible to employees for a minimum of 7 years from the pay date.

**REQ-PAY-056**
Pay statements for terminated employees shall remain accessible to those employees in the portal for the full retention period. Termination shall not revoke an employee's access to their own historical statements.

**REQ-PAY-057**
HR administrators with appropriate scope shall be able to retrieve any employee's pay statements for any period within the retention window.

**REQ-PAY-058**
Every access to a pay statement — view or download — shall generate an audit log entry containing: actor identity, employment ID, pay statement ID, pay period, access type (view or download), and timestamp.

**REQ-PAY-059**
Pay statements shall be stored in a format that supports retrieval within 3 seconds for any statement within the 7-year retention window.

---

## 7. Security Requirements

**REQ-PAY-060**
Pay statement access shall require authenticated session. Unauthenticated access to any pay statement endpoint shall return HTTP 401.

**REQ-PAY-061**
An employee shall only be able to access their own pay statements. Attempting to access another employee's statement shall return HTTP 403 and generate EXC-SEC-001.

**REQ-PAY-062**
Pay statement PDF files shall not be served via publicly accessible URLs. All PDF delivery shall be through authenticated, time-limited signed URLs that expire within 15 minutes of generation.

**REQ-PAY-063**
Pay statements shall be encrypted at rest using AES-256 or equivalent.

**REQ-PAY-064**
No PII shall be transmitted in email notifications. If email notifications are implemented in a future release, the email body shall contain only a link to the authenticated portal — never the statement content, net pay amount, or any employee identifiers beyond first name.

**REQ-PAY-065**
SSN shall never appear in full on any pay statement, PDF, or API response related to pay statements. The last 4 digits only shall be displayed, in the format XXX-XX-NNNN.

---

## 8. Accessibility Requirements

**REQ-PAY-070**
Electronic pay statements shall comply with WCAG 2.1 Level AA.

**REQ-PAY-071**
All pay statement content shall be accessible to screen readers. Tabular data shall use proper HTML table semantics with column headers marked up correctly.

**REQ-PAY-072**
The pay statement shall support high-contrast display mode. Colour shall never be the sole means of conveying information (e.g. negative amounts shall use both colour and a minus sign).

**REQ-PAY-073**
PDF pay statements shall be tagged PDFs with a defined reading order, heading structure, and alt text for all non-text elements. Untagged PDFs are not acceptable.

**REQ-PAY-074**
Text in the pay statement shall meet a minimum contrast ratio of 4.5:1 against the background for normal text and 3:1 for large text, per WCAG 2.1 Success Criterion 1.4.3.

---

## 9. Acceptance Criteria

| REQ ID | Acceptance Criterion |
|---|---|
| REQ-PAY-001 | An employee can log into the self-service portal from a desktop browser and view their most recent pay statement without assistance. |
| REQ-PAY-002 | An employee can download their pay statement as a PDF file. The PDF renders correctly in Adobe Acrobat and the system's default PDF viewer. |
| REQ-PAY-003 | A newly created employee record has paper suppression enabled by default. No paper statement is generated unless the employee explicitly opts in. |
| REQ-PAY-020 | A pay statement for an hourly employee with regular, overtime, and holiday earnings displays three separate earning lines with hours, rate, current amount, and YTD amount on each. |
| REQ-PAY-023 | A pay statement with a 401(k) pre-tax deduction, federal income tax, and a Roth 401(k) post-tax deduction displays three distinct deduction sections with separate subtotals. |
| REQ-PAY-025 | A pay statement for an employee with a $200 pre-tax 401(k) deduction on $3,000 gross earnings displays Federal taxable wages as $2,800. |
| REQ-PAY-026 | Net Pay is the largest or most prominently styled numeric value visible on the pay statement on both desktop and mobile. |
| REQ-PAY-043 | Pay statements are available in the portal within 2 hours of the payroll run reaching STATE-RUN-015. |
| REQ-PAY-044 | All pay statement functionality (view, filter, download) operates correctly on a 375px viewport mobile browser without horizontal scrolling. |
| REQ-PAY-047 | No paper statement is generated for any employee by default. The paper suppression setting can be confirmed by inspecting the employee's delivery preferences. |
| REQ-PAY-055 | A pay statement from 6 years and 11 months ago is retrievable by the employee from the portal. |
| REQ-PAY-056 | A terminated employee can log into the portal and retrieve their pay statements from their employment period. |
| REQ-PAY-062 | A pay statement PDF URL expires after 15 minutes. Attempting to access the URL after expiry returns HTTP 403. |
| REQ-PAY-065 | No API response, rendered statement, or PDF related to pay statements contains a full 9-digit SSN. |
| REQ-PAY-070 | The pay statement portal passes automated WCAG 2.1 AA checks using a recognised accessibility auditing tool. |
| REQ-PAY-073 | The pay statement PDF passes PDF/UA validation with a tagged PDF checker. |

---

## 10. Non-Functional Requirements

Platform-wide NFRs are governed by `docs/NFR/HCM_NFR_Specification.md`. The following requirements state domain-specific SLAs for pay statement delivery.

**REQ-PAY-080**
Pay statement list page load shall complete within 2 seconds for an employee with up to 10 years of statement history.

**REQ-PAY-081**
Individual pay statement view (HTML) shall load within 2 seconds.

**REQ-PAY-082**
Pay statement PDF generation shall complete within 3 seconds for any single statement.

**REQ-PAY-083**
Pay statement retrieval from the 7-year archive shall return within 3 seconds regardless of the age of the statement.

**REQ-PAY-084**
The pay statement delivery system shall support the platform's open enrollment load target: 5–10× normal concurrent access without page load times exceeding 4 seconds (e.g. when all employees check statements simultaneously after a major payroll event).
