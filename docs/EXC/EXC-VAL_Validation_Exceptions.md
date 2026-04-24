# EXC-VAL — Validation Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/EXC/EXC-VAL_Validation_Exceptions.md` |
| **Related Documents** | PRD-0800_Validation_Framework.md, HRIS_Module_PRD.md §17, docs/architecture/governance/Configuration_and_Metadata_Management_Model.md, docs/architecture/processing/Error_Handling_and_Isolation_Model.md |

## Purpose

Defines all addressable validation exceptions for payroll results, HR record changes, and configuration readiness. EXC-VAL rules apply during the validation phase — after calculation, before posting.

---

## Payroll Result Validation (EXC-VAL-001 to 009)

---

### EXC-VAL-001

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-001 |
| **Name** | Negative Earnings Without Description |
| **Severity** | Hard Stop |
| **Domain** | Payroll Result Validation |

**Condition:** A payroll result line carries a negative earnings amount and the Description field is empty or null.

**System Behaviour:** Processing halted for the affected employee. Record routed to exception queue. Run continues for unaffected employees.

**Operator Action Required:** Provide a valid description for the negative earning line, or confirm the line as intentional via an authorised override with documented reason.

**Related Codes:** EXC-VAL-003 (missing required field)

---

### EXC-VAL-002

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-002 |
| **Name** | Net Pay Below Zero Without Approved Override |
| **Severity** | Hold |
| **Domain** | Payroll Result Validation |

**Condition:** Computed net pay for an employee is less than zero and no approved override is on file for this employee and period.

**System Behaviour:** Employee record held in exception queue. Run continues for unaffected employees. Record cannot proceed to posting until Hold is resolved.

**Operator Action Required:** Review deductions and earnings for the employee. Either correct the source data, reduce deductions, or record a formal approved override with documented authorisation.

**Related Codes:** EXC-VAL-001, EXC-DED-001

---

### EXC-VAL-003

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-003 |
| **Name** | Missing Required Payroll Data Field |
| **Severity** | Hard Stop |
| **Domain** | Payroll Result Validation |

**Condition:** A required field on a payroll result record is null or empty. Required fields include: Employment_ID, Period_ID, Payroll_Context_ID, Earning_Type or Deduction_Type, Amount.

**System Behaviour:** Affected record rejected. Employee routed to exception queue. Run continues for unaffected employees.

**Operator Action Required:** Identify the source of the missing field — configuration gap, data intake failure, or system error. Correct the source and re-run for the affected employee.

**Related Codes:** EXC-CFG-001, EXC-RUN-003

---

### EXC-VAL-004

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-004 |
| **Name** | Net Pay Variance Beyond Threshold |
| **Severity** | Warning |
| **Domain** | Payroll Result Validation |

**Condition:** An employee's net pay has changed by more than the configured variance threshold (absolute or percentage) compared to the prior period.

**System Behaviour:** Warning logged and surfaced on the variance review dashboard. Processing continues. No blocking action taken.

**Operator Action Required:** Review the employee's earnings and deductions for the period. Confirm the variance is expected (e.g., bonus, termination, return from leave) or investigate if unexpected.

**Related Codes:** EXC-VAL-002

---

### EXC-VAL-005

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-005 |
| **Name** | Duplicate Payroll Result for Employee and Period |
| **Severity** | Hard Stop |
| **Domain** | Payroll Result Validation |

**Condition:** A payroll result already exists for the same Employment_ID, Period_ID, and Payroll_Context_ID combination, and no correction or void action is in progress.

**System Behaviour:** New result blocked. Employee routed to exception queue. Existing result preserved.

**Operator Action Required:** Determine whether this is a reprocessing scenario (requires void and replacement workflow) or a system error. Do not permit silent overwrite.

**Related Codes:** EXC-RUN-001, EXC-COR-001

---

## HR Record Validation (EXC-VAL-010 to 019)

---

### EXC-VAL-010

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-010 |
| **Name** | Missing Required Field on Hire Record |
| **Severity** | Hard Stop |
| **Domain** | HR Record Validation |

**Condition:** A hire record is missing one or more required fields. Required fields include: Person_ID, Legal_First_Name, Legal_Last_Name, Employment_Start_Date, Legal_Entity_ID, Employment_Type, FLSA_Status.

**System Behaviour:** Hire record rejected. Not committed to the system of record. Routed to exception queue.

**Operator Action Required:** Supply all required fields and resubmit the hire record through the intake workflow.

**Related Codes:** EXC-VAL-003

---

### EXC-VAL-011

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-011 |
| **Name** | Compensation Change Without Approved Reason Code |
| **Severity** | Hold |
| **Domain** | HR Record Validation |

**Condition:** A compensation change record has been submitted without a valid, approved reason code.

**System Behaviour:** Record held. Not applied to the employment record. Approval workflow cannot advance without reason code.

**Operator Action Required:** Select a valid reason code from the approved list and resubmit. Reason codes must be configured in the reference data model before use.

**Related Codes:** EXC-CFG-003

---

### EXC-VAL-012

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-012 |
| **Name** | Termination Date Before Hire Date |
| **Severity** | Hard Stop |
| **Domain** | HR Record Validation |

**Condition:** The Employment_End_Date on a termination record is earlier than the Employment_Start_Date on the same employment record.

**System Behaviour:** Termination record rejected. Not committed. Routed to exception queue.

**Operator Action Required:** Correct the termination date. If the hire date itself is in error, that must be corrected first via an amendment workflow before processing the termination.

**Related Codes:** None

---

### EXC-VAL-013

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-013 |
| **Name** | Missing I-9 Documentation Past Required Window |
| **Severity** | Warning |
| **Domain** | HR Record Validation |

**Condition:** An employee's I-9 documentation is missing or expired and the legally required completion window has passed (3 business days from hire start date for new hires).

**System Behaviour:** Warning logged. Processing continues. Compliance alert surfaced on HR operations dashboard.

**Operator Action Required:** Collect and upload the required I-9 documentation. Escalate to HR compliance team if window has been significantly exceeded.

**Related Codes:** EXC-AUD-001

---

### EXC-VAL-014

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-014 |
| **Name** | Retroactive Event Affecting Closed Payroll Period |
| **Severity** | Hold |
| **Domain** | HR Record Validation |

**Condition:** An HR lifecycle event (e.g., compensation change, hire date correction) has an effective date that falls within a payroll period that has already been closed (STATE-RUN-017).

**System Behaviour:** Event held. Not applied. Routed to exception queue with Payroll confirmation required.

**Operator Action Required:** Payroll team must review the closed period impact, determine whether a retro correction run is required, and confirm or deny the retroactive application. HR record is not updated until Payroll confirms.

**Related Codes:** EXC-COR-001, EXC-RUN-004

---

## Configuration Validation (EXC-VAL-020 to 029)

---

### EXC-VAL-020

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-020 |
| **Name** | Missing Required Configuration Object |
| **Severity** | Hard Stop |
| **Domain** | Configuration Validation |

**Condition:** A configuration object required for payroll execution is absent. Examples: no payroll calendar defined for the context and period; no tax rule for a required jurisdiction; no pay code mapping for an active earning type.

**System Behaviour:** Payroll run initiation blocked. Validation run identifies missing objects and surfaces them in the readiness report.

**Operator Action Required:** Create and approve the missing configuration object before initiating the payroll run.

**Related Codes:** EXC-CFG-001

---

### EXC-VAL-021

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-021 |
| **Name** | Broken Configuration Reference |
| **Severity** | Hard Stop |
| **Domain** | Configuration Validation |

**Condition:** A configuration object references another object that does not exist or has been deleted. Examples: a pay rule referencing a deleted rate table; a benefit plan referencing an inactive carrier code.

**System Behaviour:** Affected configuration object flagged as invalid. Dependent payroll contexts blocked from running.

**Operator Action Required:** Repair the broken reference by either restoring the referenced object or updating the configuration to reference a valid object.

**Related Codes:** EXC-CFG-002, EXC-VAL-020

---

### EXC-VAL-022

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-022 |
| **Name** | Configuration Effective Date Misalignment |
| **Severity** | Hold |
| **Domain** | Configuration Validation |

**Condition:** A configuration object's effective dates do not cover the payroll period being processed. Examples: a tax rule effective start date is after the period start; a plan effective end date is before the period end.

**System Behaviour:** Affected employees or payroll contexts held. Validation report identifies the misaligned objects and the periods they fail to cover.

**Operator Action Required:** Extend or correct the effective dates on the configuration object, or create a new version covering the required period.

**Related Codes:** EXC-CFG-003, EXC-VAL-020

---

### EXC-VAL-023

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-023 |
| **Name** | Configuration Dependency Chain Gap |
| **Severity** | Hard Stop |
| **Domain** | Configuration Validation |

**Condition:** A required upstream configuration dependency is missing or invalid. Examples: benefit plan exists but contribution rules are missing; garnishment order exists but remittance target is not configured.

**System Behaviour:** Dependent execution path blocked. Validation identifies the full dependency chain and the specific missing link.

**Operator Action Required:** Supply the missing upstream configuration object. The dependency chain must be complete before the dependent object is executable.

**Related Codes:** EXC-CFG-001, EXC-VAL-021

---

### EXC-VAL-024

| Field | Detail |
|---|---|
| **Code** | EXC-VAL-024 |
| **Name** | Context Not Ready for Payroll Run |
| **Severity** | Hard Stop |
| **Domain** | Configuration Validation |

**Condition:** A payroll context fails the pre-run readiness assessment. The context may have incomplete configuration, unresolved prior-period exceptions, or an incomplete calendar definition for the target period.

**System Behaviour:** Run initiation blocked for the affected context. Readiness report generated identifying all blocking conditions.

**Operator Action Required:** Resolve all blocking conditions identified in the readiness report before initiating the run.

**Related Codes:** EXC-VAL-020, EXC-VAL-021, EXC-VAL-022, EXC-VAL-023, EXC-RUN-001
