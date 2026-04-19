# Requirement ID Convention

| Field | Detail |
|---|---|
| **Document Type** | Convention Reference |
| **Version** | v1.0 |
| **Status** | Locked |
| **Owner** | Core Platform |
| **Location** | `docs/conventions/Requirement_ID_Convention.md` |
| **Related Documents** | docs/index.md, docs/PRD/, docs/architecture/ |

## Purpose

Defines the identifier prefixes and numbering conventions used throughout the HCM platform documentation to make requirements, state models, and exception rules uniquely addressable. Addressable identifiers enable testing, traceability, debugging, and audit.

---

## 1. General Numbering Rules

- Identifiers take the form `PREFIX-NNN` where NNN is a zero-padded three-digit number (001, 002, etc.)
- Numbers are sequential within a prefix but gaps are permitted as documents evolve
- Numbers are never reused once assigned, even if a requirement is retired
- Retired requirements are marked `[RETIRED]` in place rather than deleted
- Each prefix is owned by the document type and domain it covers — cross-domain requirements use REQ-PLT

---

## 2. REQ — Requirement Prefixes

Used in PRD documents and architecture models to express discrete, testable functional requirements.

| Prefix | Domain |
|---|---|
| REQ-PLT | Platform (cross-cutting) |
| REQ-CAL | Payroll Calendar |
| REQ-ERN | Earnings |
| REQ-BAL | Accumulators / Balances (financial) |
| REQ-ACR | Accruals (PTO / Time-Off entitlements) |
| REQ-JUR | Jurisdiction |
| REQ-TAX | Taxation |
| REQ-WFL | Workflow / Approval |
| REQ-VAL | Validation / Exceptions |
| REQ-INT | Integration |
| REQ-HRS | HRIS |
| REQ-PAY | Payroll Run / Processing |
| REQ-NET | Net Pay |
| REQ-DIS | Disbursement |
| REQ-BNK | Banking |
| REQ-SEC | Security / Access |
| REQ-AUD | Audit / Retention |
| REQ-TIM | Time & Attendance |
| REQ-BEN | Benefits / Deductions |
| REQ-GAR | Garnishments / Levies |
| REQ-GL | General Ledger / Accounting |
| REQ-BIL | Provider Billing / PEO Charges |
| REQ-RPT | Reporting |
| REQ-YER | Year-End |
| REQ-COR | Corrections / Retroactive Adjustments |
| REQ-ONB | Onboarding |
| REQ-ESS | Employee Self-Service |

### REQ Format Example

```
REQ-CAL-001
Payroll calendars shall support weekly periods.

REQ-CAL-002
Payroll calendars shall support biweekly periods.
```

---

## 3. STATE — State Model Prefixes

Used to define named states within a lifecycle and the valid transitions between them. State models appear in architecture models and SPEC documents wherever a workflow or lifecycle is defined.

| Prefix | Domain |
|---|---|
| STATE-WFL | Workflow / Approval states |
| STATE-RUN | Payroll run states |
| STATE-EMP | Employment lifecycle states |
| STATE-LEV | Leave request states |
| STATE-DOC | Document states |
| STATE-EXP | Export states |
| STATE-REC | Reconciliation states |
| STATE-PRV | Provider response states |
| STATE-ONB | Onboarding task states |
| STATE-TIM | Time & Attendance (timecard / timesheet) |
| STATE-DED | Benefits / Deductions / Enrollment |
| STATE-GAR | Garnishments |
| STATE-TAX | Tax Elections / Jurisdiction assignments |
| STATE-RET | Retro / Adjustments |
| STATE-GL | General Ledger Posting |
| STATE-YEP | Year-End Processing |

### STATE Format Example

```
STATE-WFL-001  Draft
STATE-WFL-002  Submitted
STATE-WFL-003  Under Review
STATE-WFL-004  Approved
STATE-WFL-005  Rejected
STATE-WFL-006  Effective
STATE-WFL-007  Cancelled
```

### Known State Values by Prefix

**STATE-TIM** — Timecard / Timesheet
Draft → Submitted → Approved → Rejected → Locked for payroll → Corrected

**STATE-DED** — Benefits / Deductions / Enrollment
Pending enrollment → Active → Suspended → Terminated → Awaiting evidence of insurability

**STATE-GAR** — Garnishments
Received → Pending setup → Active → Suspended → Satisfied → Terminated

**STATE-TAX** — Tax Elections / Jurisdiction
Pending verification → Active → Locked → Expired

**STATE-RET** — Retro / Adjustments
Identified → Calculated → Applied → Reversed → Finalized

**STATE-GL** — General Ledger Posting
Generated → Validated → Posted → Failed → Reposted

**STATE-YEP** — Year-End Processing (W-2, 1099, etc.)
Draft → Corrected → Final → Filed → Reissued

---

## 4. EXC — Exception Rule Prefixes

Used to define named, addressable exception and validation rules. Exception rules appear in architecture models, SPEC documents, and PRD validation sections.

| Prefix | Domain |
|---|---|
| EXC-VAL | Validation exceptions |
| EXC-INT | Integration exceptions |
| EXC-CFG | Configuration exceptions |
| EXC-CAL | Calculation exceptions |
| EXC-AUD | Audit / Retention violations |
| EXC-SEC | Security / Access violations |
| EXC-COR | Correction workflow exceptions |
| EXC-TIM | Time & Attendance exceptions |
| EXC-DED | Benefits / Deductions exceptions |
| EXC-TAX | Taxation exceptions |
| EXC-RUN | Payroll run lifecycle exceptions |

### EXC Format Example

```
EXC-VAL-001
Negative earnings without description → Hard Stop

EXC-VAL-002
Net pay below zero without approved override → Hold
```

### Known Exception Categories by Prefix

**EXC-TIM** — Time & Attendance
Missing punches, invalid timecard states, overtime rule violations, unapproved time at payroll cutoff.

**EXC-DED** — Benefits / Deductions
Invalid deduction amounts, missing benefit enrollment, pre-tax/post-tax conflict, garnishment priority violations.

**EXC-TAX** — Taxation
Invalid withholding elections, missing jurisdiction assignment, reciprocity conflicts, tax engine calculation failures.

**EXC-RUN** — Payroll Run Lifecycle
Run failed to start, run stuck in processing, run aborted, run requires manual intervention.

---

## 5. ENT — Entity Specification Prefixes

Used in DATA document filenames and cross-references to identify canonical entity specifications.

Entity files follow the naming convention `docs/DATA/Entity_{Name}.md`.

Examples:
- `docs/DATA/Entity_Person.md`
- `docs/DATA/Entity_Employment.md`
- `docs/DATA/Entity_Assignment.md`

There is no numeric sequence for ENT — entity files are identified by their entity name, not a number.

---

## 6. Severity Levels for EXC Rules

Every exception rule must declare a severity level:

| Severity | Behaviour |
|---|---|
| **Informational** | Logged; does not block processing |
| **Warning** | Visible to operator; does not block processing |
| **Hold** | Blocks processing until resolved or overridden with authorisation |
| **Hard Stop** | Blocks processing unconditionally; cannot be overridden |

---

## 7. Convention Maintenance

- New prefixes require a documentation update to this file before use
- Prefix additions must be reviewed for overlap with existing prefixes
- This file is version-controlled and changes are logged in `CHANGELOG.md`
