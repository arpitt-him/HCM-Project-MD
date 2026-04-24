# SPEC — API Surface Map

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.3 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/SPEC/API_Surface_Map.md` |
| **Related Documents** | SPEC/API_Contract_Standards.md, PRD-0900_Integration_Model, docs/architecture/interfaces/Integration_and_Data_Exchange_Model.md, docs/architecture/interfaces/Payroll_Interface_and_Export_Model.md, docs/architecture/interfaces/General_Ledger_and_Accounting_Export_Model.md, docs/architecture/interfaces/Pay_Statement_Model.md |

## Purpose

Defines the complete set of integration points on the HCM platform — organised by domain, with direction, trigger, key inputs, key outputs, transport method, and governing documentation for each. This document is the integration architect's entry point. It is not an endpoint catalogue and does not define field-level schemas. It answers the question: *what integration points exist, what do they do, and where do I go for detail?*

All integration points listed here must comply with `SPEC/API_Contract_Standards.md` for REST API surfaces, and with `PRD-0900_Integration_Model` for all transport and validation standards.

---

## 1. How to Read This Document

Each integration point entry contains:

| Field | Meaning |
|---|---|
| **ID** | Unique surface identifier used for cross-referencing |
| **Name** | Short descriptive name |
| **Direction** | INBOUND (external → platform), OUTBOUND (platform → external), or EVENT (platform → subscriber) |
| **Pattern** | API_REQUEST_RESPONSE, BATCH_FILE, SCHEDULED_EXPORT, SCHEDULED_IMPORT, EVENT_NOTIFICATION |
| **Trigger** | What initiates the exchange |
| **Key Inputs** | Primary data elements the platform receives |
| **Key Outputs** | Primary data elements the platform returns or sends |
| **SLA** | Applicable processing SLA |
| **Governing Documents** | Where the detailed spec lives |

---

## 2. HRIS Domain

---

### INT-HRS-001 — Employee Record Create / Update

| Field | Detail |
|---|---|
| **ID** | INT-HRS-001 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE |
| **Trigger** | External system (e.g. recruiting platform, manual HR admin action) submits a new hire or employment record change |
| **Key Inputs** | Person identity fields, employment attributes, Legal_Entity_ID, Employment_Type, FLSA_Status, start date |
| **Key Outputs** | Employment_ID (on create), validation result, exception codes if rejected |
| **SLA** | Response within 2 seconds; critical updates (pay rate change, job change) processed within 1 minute |
| **Auth / Scope** | `hris:employees:write` |
| **Governing Documents** | DATA/Entity_Employee.md, DATA/Entity_Person.md, EXC-VAL_Validation_Exceptions.md |

---

### INT-HRS-002 — Employee Record Read

| Field | Detail |
|---|---|
| **ID** | INT-HRS-002 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE |
| **Trigger** | External system or integration queries employment data |
| **Key Inputs** | Employment_ID or Employee_Number; optional effective date for point-in-time resolution |
| **Key Outputs** | Employment record, current assignment, current compensation rate, employment status |
| **SLA** | Response within 2 seconds |
| **Auth / Scope** | `hris:employees:read` |
| **Governing Documents** | DATA/Entity_Employee.md, DATA/Entity_Assignment.md, DATA/Entity_Compensation_Record.md |

---

### INT-HRS-003 — Employee Batch Import

| Field | Detail |
|---|---|
| **ID** | INT-HRS-003 |
| **Direction** | INBOUND |
| **Pattern** | BATCH_FILE |
| **Trigger** | Scheduled or manual batch file submission (CSV, XML, XLSX) containing multiple employee records |
| **Key Inputs** | Batch file with employee records; Source_Batch_ID; control totals |
| **Key Outputs** | Job_ID for async tracking; per-record validation results; accepted/rejected counts |
| **SLA** | File accepted and acknowledged within 5 seconds; full processing within 15 minutes |
| **Auth / Scope** | `hris:employees:write` + `hris:batch:submit` |
| **Governing Documents** | PRD-0900_Integration_Model §2, Integration_and_Data_Exchange_Model, EXC-INT_Integration_Exceptions.md |
| **Notes** | Dry-run mode supported — validates without posting. Supports incremental and full-replacement modes. |

---

### INT-HRS-004 — Employee Lifecycle Event Submission

| Field | Detail |
|---|---|
| **ID** | INT-HRS-004 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE |
| **Trigger** | External system or self-service action submits a lifecycle event (hire, termination, compensation change, transfer) |
| **Key Inputs** | Employment_ID, Event_Type, Effective_Date, Event_Reason_Code, event-specific payload |
| **Key Outputs** | Employee_Event_ID, workflow state (Draft / Submitted), validation result |
| **SLA** | Response within 2 seconds; critical events (pay rate change, work state change) available to Payroll within 1 minute of approval |
| **Auth / Scope** | `hris:events:write` |
| **Governing Documents** | HRIS_Module_PRD §9, Employee_Event_and_Status_Change_Model, STATE-WFL_Workflow_Approval.md |
| **Notes** | Events enter workflow; they do not take effect immediately. Retroactive events generate EXC-VAL-014. |

---

### INT-HRS-005 — Org Structure Read

| Field | Detail |
|---|---|
| **ID** | INT-HRS-005 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE |
| **Trigger** | External system queries organisational hierarchy |
| **Key Inputs** | Org_Unit_ID, Org_Unit_Type filter, or full hierarchy request; optional effective date |
| **Key Outputs** | Org unit records with parent-child relationships, effective dates, location attributes |
| **SLA** | Response within 2 seconds |
| **Auth / Scope** | `hris:org:read` |
| **Governing Documents** | DATA/Entity_Org_Unit.md, Organizational_Structure_Model |

---

### INT-HRS-006 — Employee Event Publication (Outbound)

| Field | Detail |
|---|---|
| **ID** | INT-HRS-006 |
| **Direction** | EVENT |
| **Pattern** | EVENT_NOTIFICATION |
| **Trigger** | An HRIS lifecycle event reaches STATE-WFL-006 (Effective) |
| **Key Inputs** | N/A — platform-initiated |
| **Key Outputs** | Employee_Event payload: Employment_ID, Event_Type, Effective_Date, changed fields, event-specific delta |
| **SLA** | Event delivered to subscribers within 5 minutes of effective state |
| **Consumers** | Payroll module (mandatory), Benefits module (future), Time & Attendance (future) |
| **Governing Documents** | ADR-001_Event_Driven_Architecture, Employee_Event_and_Status_Change_Model, Integration_and_Data_Exchange_Model |
| **Notes** | Primary integration contract between HRIS and Payroll. Payroll must not poll HRIS; it subscribes to this event stream. |

---

## 3. Payroll Domain

---

### INT-PAY-001 — External Earnings Import

| Field | Detail |
|---|---|
| **ID** | INT-PAY-001 |
| **Direction** | INBOUND |
| **Pattern** | BATCH_FILE or API_REQUEST_RESPONSE |
| **Trigger** | Commission system, incentive platform, or operator submits externally calculated earnings for inclusion in payroll |
| **Key Inputs** | Employment_ID, Earning_Type, Amount, Period_ID, Source_Batch_ID, Description |
| **Key Outputs** | Staged earning records; Job_ID; validation result with per-record exception codes |
| **SLA** | Batch: acknowledged within 5 seconds, processed within 15 minutes. API: response within 2 seconds. |
| **Auth / Scope** | `payroll:earnings:write` |
| **Governing Documents** | SPEC/External_Earnings.md, SPEC/Residual_Commissions.md, EXC-INT_Integration_Exceptions.md |
| **Notes** | Staged records require approval before inclusion in a payroll run. Dry-run mode supported. |

---

### INT-PAY-002 — Payroll Run Initiation

| Field | Detail |
|---|---|
| **ID** | INT-PAY-002 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE |
| **Trigger** | Payroll administrator initiates a payroll run for a context and period |
| **Key Inputs** | Payroll_Context_ID, Period_ID, Run_Type |
| **Key Outputs** | Run_ID, initial Run_Status (CREATED), readiness check result |
| **SLA** | Response within 2 seconds; run creation blocked and error returned if readiness check fails |
| **Auth / Scope** | `payroll:runs:write` (initiator role) |
| **Governing Documents** | DATA/Entity_Payroll_Run.md, STATE-RUN_Payroll_Run.md, EXC-RUN_Payroll_Run_Exceptions.md |
| **Notes** | Requires pre-run readiness check to pass (EXC-VAL-024). Separation of duties enforced — initiator and approver must be different users. |

---

### INT-PAY-003 — Payroll Run Status Query

| Field | Detail |
|---|---|
| **ID** | INT-PAY-003 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE |
| **Trigger** | Operator or downstream system polls run status |
| **Key Inputs** | Run_ID |
| **Key Outputs** | Run_Status, Run_Type, Period_ID, Pay_Date, participant count, exception count, timestamps |
| **SLA** | Response within 2 seconds |
| **Auth / Scope** | `payroll:runs:read` |
| **Governing Documents** | DATA/Entity_Payroll_Run.md, STATE-RUN_Payroll_Run.md |

---

### INT-PAY-004 — Payroll Results Read

| Field | Detail |
|---|---|
| **ID** | INT-PAY-004 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE |
| **Trigger** | Downstream system or reporting tool queries payroll results for a run or employee |
| **Key Inputs** | Run_ID and/or Employment_ID; optional period range |
| **Key Outputs** | Payroll check records with result lines — earnings, deductions, taxes, net pay, YTD values |
| **SLA** | Response within 2 seconds for single employee; paginated collection within 3 seconds |
| **Auth / Scope** | `payroll:results:read` |
| **Governing Documents** | DATA/Entity_Payroll_Check.md, DATA/Entity_Payroll_Item.md, Pay_Statement_Model |
| **Notes** | Only returns results for runs in STATE-RUN-008 (Calculated) or later. |

---

### INT-PAY-005 — Pay Statement Access

| Field | Detail |
|---|---|
| **ID** | INT-PAY-005 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE |
| **Trigger** | Employee self-service portal or authorised system requests a pay statement |
| **Key Inputs** | Employment_ID, Check_ID or pay period; optional format (HTML or PDF) |
| **Key Outputs** | Rendered pay statement (HTML) or signed PDF download URL |
| **SLA** | HTML response within 2 seconds; PDF generation within 3 seconds; signed URL expiry 15 minutes |
| **Auth / Scope** | `payroll:statements:read` (employee — own only); `payroll:statements:read:all` (HR admin) |
| **Governing Documents** | SPEC/Pay_Statement_Delivery.md, Pay_Statement_Model, Pay_Statement_Template_Model |

---

### INT-PAY-006 — Accumulator / YTD Balance Query

| Field | Detail |
|---|---|
| **ID** | INT-PAY-006 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE |
| **Trigger** | External system queries YTD or period-to-date balances for an employee |
| **Key Inputs** | Employment_ID, Accumulator_Family (optional), Period_Context (PTD / QTD / YTD / LTD) |
| **Key Outputs** | Accumulator balance records with current values, last updated run, and period context |
| **SLA** | Response within 500 milliseconds |
| **Auth / Scope** | `payroll:accumulators:read` |
| **Governing Documents** | DATA/Entity_Accumulator.md, Accumulator_and_Balance_Model |

---

## 4. Outbound Payroll Exports

---

### INT-EXP-001 — Payment File Export (ACH / Direct Deposit)

| Field | Detail |
|---|---|
| **ID** | INT-EXP-001 |
| **Direction** | OUTBOUND |
| **Pattern** | SCHEDULED_EXPORT |
| **Trigger** | Payroll run reaches STATE-RUN-012 (Approved); payment file generation triggered |
| **Key Inputs** | N/A — platform-initiated from approved run results |
| **Key Outputs** | NACHA ACH file (or equivalent) containing net pay disbursement instructions per employee |
| **SLA** | File generated within 10 minutes of approval; transmitted within 5 minutes of generation |
| **Governing Documents** | Net_Pay_and_Disbursement_Model, Payroll_Interface_and_Export_Model, Payroll_Funding_and_Cash_Management_Model |
| **Notes** | Idempotent — same Export_ID never produces duplicate payment instructions. Retry on transmission failure per EXC-INT-004. |

---

### INT-EXP-002 — GL Journal Entry Export

| Field | Detail |
|---|---|
| **ID** | INT-EXP-002 |
| **Direction** | OUTBOUND |
| **Pattern** | SCHEDULED_EXPORT |
| **Trigger** | Payroll run reaches STATE-RUN-015 (Completed); GL export triggered |
| **Key Inputs** | N/A — platform-initiated from posted payroll results |
| **Key Outputs** | Balanced journal entries mapping payroll results to chart of accounts — wage expense, tax liability, employer tax expense, cash disbursement, benefits expense |
| **SLA** | Available to GL system within 15 minutes of payroll posting |
| **Governing Documents** | General_Ledger_and_Accounting_Export_Model, Integration_and_Data_Exchange_Model |
| **Notes** | Journal must balance (total debits = total credits) before export. Duplicate protection via Journal_Fingerprint. Supports cost allocation by department, location, and cost centre. |

---

### INT-EXP-003 — Tax Filing Export

| Field | Detail |
|---|---|
| **ID** | INT-EXP-003 |
| **Direction** | OUTBOUND |
| **Pattern** | SCHEDULED_EXPORT |
| **Trigger** | Payroll run completion (for periodic filings) or year-end processing (for annual filings) |
| **Key Inputs** | N/A — platform-initiated |
| **Key Outputs** | Jurisdiction-formatted tax filing data — federal (941, 940), state, and local returns; W-2 data file for year-end |
| **SLA** | Available to tax system within 15 minutes of payroll posting |
| **Governing Documents** | Regulatory_and_Compliance_Reporting_Model, Tax_Classification_and_Obligation_Model, Jurisdiction_and_Compliance_Rules_Model |
| **Notes** | Tax filing transmission to government authorities is a future integration. v1 produces the filing data file; transmission is manual or via a tax service integration. |

---

### INT-EXP-004 — Provider / Carrier Billing Export

| Field | Detail |
|---|---|
| **ID** | INT-EXP-004 |
| **Direction** | OUTBOUND |
| **Pattern** | SCHEDULED_EXPORT |
| **Trigger** | Payroll run completion; billing period close |
| **Key Inputs** | N/A — platform-initiated from approved payroll results |
| **Key Outputs** | Employee-level invoice allocation data — employer benefit contributions, employer taxes, service fees, worker comp charges, per invoice period |
| **SLA** | Available within 15 minutes of payroll posting |
| **Governing Documents** | Provider_Billing_and_Charge_Model, Code_Classification_and_Mapping_Model |
| **Notes** | Applies primarily to PEO operating environments. Charge families: 401k/Roth, employer benefits (AET005, LIFEX, etc.), FICA-M, FICA-O, FUTA, SUI, service fees. |

---

### INT-EXP-005 — Provider Response Ingest

| Field | Detail |
|---|---|
| **ID** | INT-EXP-005 |
| **Direction** | INBOUND |
| **Pattern** | BATCH_FILE or API_REQUEST_RESPONSE |
| **Trigger** | Downstream provider (payroll processor, tax service, carrier) returns an acceptance, rejection, or acknowledgment |
| **Key Inputs** | Export_ID correlation reference, response type (accepted / rejected / partial), record-level status if applicable |
| **Key Outputs** | Provider_Response_ID; reconciliation state update; exception queue items if rejected records exist |
| **SLA** | Acknowledgment expected within 15 minutes of transmission; unmatched responses flagged within 5 minutes |
| **Governing Documents** | Payroll_Provider_Response_Model, Payroll_Reconciliation_Model, EXC-INT_Integration_Exceptions.md |
| **Notes** | Unmatched responses (cannot correlate to a known export) generate EXC-INT-006 and are held for manual review. |

---

## 5. Benefits Deduction Domain

---

### INT-BEN-001 — Benefit Deduction Election Import

| Field | Detail |
|---|---|
| **ID** | INT-BEN-001 |
| **Direction** | INBOUND |
| **Pattern** | BATCH_FILE or API_REQUEST_RESPONSE |
| **Trigger** | External benefits administration system or HR administrator submits employee benefit election amounts |
| **Key Inputs** | Employment_ID, Deduction_Code, Employee_Amount, Employer_Contribution (optional), Effective_Start_Date, Effective_End_Date |
| **Key Outputs** | Staged election records; Job_ID; validation result |
| **SLA** | Batch: processed within 15 minutes. API: response within 2 seconds. |
| **Auth / Scope** | `benefits:elections:write` |
| **Governing Documents** | PRD-1000_Benefits_Boundary, Benefit_and_Deduction_Configuration_Model, EXC-DED_Benefits_Deductions_Exceptions.md |
| **Notes** | v1 only — election amounts are imported, not calculated. Plan design and enrollment logic reside in the external system. |

---

## 6. Garnishment / Legal Order Domain

---

### INT-GAR-001 — Legal Order Submission

| Field | Detail |
|---|---|
| **ID** | INT-GAR-001 |
| **Direction** | INBOUND |
| **Pattern** | API_REQUEST_RESPONSE or MANUAL_UPLOAD |
| **Trigger** | HR administrator or court document intake process submits a new garnishment or legal order |
| **Key Inputs** | Employment_ID, Order_Type, Issuing_Authority, Jurisdiction_ID, Order_Reference_Number, Effective_Date, withholding parameters |
| **Key Outputs** | Legal_Order_ID, initial Order_Status (RECEIVED), validation result |
| **SLA** | Response within 2 seconds |
| **Auth / Scope** | `compliance:legal-orders:write` |
| **Governing Documents** | DATA/Entity_Legal_Order.md, Garnishment_and_Legal_Order_Model, STATE-GAR_Garnishment.md |
| **Notes** | Orders enter RECEIVED state; must be validated and moved to PENDING_SETUP before payroll will calculate withholding. Priority sequencing among concurrent orders is governed by Garnishment_and_Legal_Order_Model. |

---

### INT-GAR-002 — Garnishment Remittance Export

| Field | Detail |
|---|---|
| **ID** | INT-GAR-002 |
| **Direction** | OUTBOUND |
| **Pattern** | SCHEDULED_EXPORT |
| **Trigger** | Payroll run completion; remittance schedule for active legal orders |
| **Key Inputs** | N/A — platform-initiated |
| **Key Outputs** | Remittance file or payment instruction per active legal order — payee, amount, order reference, employee reference |
| **SLA** | Available within 15 minutes of payroll posting |
| **Governing Documents** | Garnishment_and_Legal_Order_Model, Net_Pay_and_Disbursement_Model |

---

## 7. Time & Attendance Domain

These integration points are defined here to establish the expected contract for the future Time & Attendance module. They are not implemented in v1.

---

### INT-TIM-001 — Time Entry Import

| Field | Detail |
|---|---|
| **ID** | INT-TIM-001 |
| **Direction** | INBOUND |
| **Pattern** | BATCH_FILE or API_REQUEST_RESPONSE |
| **Trigger** | Time & Attendance system submits approved time entries for payroll consumption |
| **Key Inputs** | Employment_ID, Work_Date, Time_Category, Hours, Approval_Status |
| **Key Outputs** | Staged time records; validation result; Job_ID |
| **SLA** | Processed within 15 minutes of submission |
| **Governing Documents** | Time_Entry_and_Worked_Time_Model, EXC-TIM_Time_Attendance_Exceptions.md |
| **Notes** | Only APPROVED timecards are eligible for payroll. Unapproved time at cutoff generates EXC-TIM-002. |

---

## 8. Integration Surface Summary

| ID | Name | Direction | Pattern | Domain | v1 Status |
|---|---|---|---|---|---|
| INT-HRS-001 | Employee Record Create / Update | INBOUND | API | HRIS | In Scope |
| INT-HRS-002 | Employee Record Read | INBOUND | API | HRIS | In Scope |
| INT-HRS-003 | Employee Batch Import | INBOUND | Batch | HRIS | In Scope |
| INT-HRS-004 | Employee Lifecycle Event Submission | INBOUND | API | HRIS | In Scope |
| INT-HRS-005 | Org Structure Read | INBOUND | API | HRIS | In Scope |
| INT-HRS-006 | Employee Event Publication | EVENT | Event | HRIS | In Scope |
| INT-PAY-001 | External Earnings Import | INBOUND | API / Batch | Payroll | In Scope |
| INT-PAY-002 | Payroll Run Initiation | INBOUND | API | Payroll | In Scope |
| INT-PAY-003 | Payroll Run Status Query | INBOUND | API | Payroll | In Scope |
| INT-PAY-004 | Payroll Results Read | INBOUND | API | Payroll | In Scope |
| INT-PAY-005 | Pay Statement Access | INBOUND | API | Payroll | In Scope |
| INT-PAY-006 | Accumulator / YTD Balance Query | INBOUND | API | Payroll | In Scope |
| INT-EXP-001 | Payment File Export (ACH) | OUTBOUND | Scheduled | Payroll | In Scope |
| INT-EXP-002 | GL Journal Entry Export | OUTBOUND | Scheduled | Payroll | In Scope |
| INT-EXP-003 | Tax Filing Export | OUTBOUND | Scheduled | Payroll | In Scope |
| INT-EXP-004 | Provider / Carrier Billing Export | OUTBOUND | Scheduled | Payroll / PEO | In Scope |
| INT-EXP-005 | Provider Response Ingest | INBOUND | API / Batch | Payroll | In Scope |
| INT-BEN-001 | Benefit Deduction Election Import | INBOUND | API / Batch | Benefits | In Scope |
| INT-GAR-001 | Legal Order Submission | INBOUND | API | Compliance | In Scope |
| INT-GAR-002 | Garnishment Remittance Export | OUTBOUND | Scheduled | Compliance | In Scope |
| INT-TIM-001 | Time Entry Import | INBOUND | API / Batch | Time & Attendance | In Scope |
