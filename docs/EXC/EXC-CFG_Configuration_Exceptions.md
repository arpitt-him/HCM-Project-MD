# EXC-CFG — Configuration Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v0.2 |
| **Status** | Draft |
| **Owner** | Core Platform |
| **Location** | `docs/EXC/EXC-CFG_Configuration_Exceptions.md` |
| **Related Documents** | docs/architecture/governance/Configuration_and_Metadata_Management_Model.md, docs/architecture/operations/System_Initialization_and_Bootstrap_Model.md, EXC-VAL_Validation_Exceptions.md |

## Purpose

Defines exceptions arising from configuration problems — missing objects, broken references, version conflicts, and readiness failures. EXC-CFG rules fire during configuration validation runs and pre-run readiness checks.

---

### EXC-CFG-001

| Field | Detail |
|---|---|
| **Code** | EXC-CFG-001 |
| **Name** | Required Configuration Object Missing |
| **Severity** | Hard Stop |
| **Domain** | Configuration Completeness |

**Condition:** A configuration object that is required for a payroll context, employee population, or processing path does not exist in the system.

**System Behaviour:** Affected execution path blocked. Readiness check fails. Blocking object listed in the readiness report.

**Operator Action Required:** Create the missing configuration object, complete required fields, and submit through the approval workflow before retrying.

**Related Codes:** EXC-VAL-020

---

### EXC-CFG-002

| Field | Detail |
|---|---|
| **Code** | EXC-CFG-002 |
| **Name** | Broken Configuration Reference |
| **Severity** | Hard Stop |
| **Domain** | Referential Integrity |

**Condition:** A configuration object references another object by ID, and that referenced object does not exist, has been deleted, or is in an inactive state.

**System Behaviour:** Owning configuration object marked invalid. Dependent execution paths blocked. Full dependency chain logged.

**Operator Action Required:** Restore the referenced object, update the reference to a valid object, or retire the owning object if it is no longer needed.

**Related Codes:** EXC-VAL-021, EXC-CFG-001

---

### EXC-CFG-003

| Field | Detail |
|---|---|
| **Code** | EXC-CFG-003 |
| **Name** | Configuration Effective Date Gap |
| **Severity** | Hold |
| **Domain** | Effective Dating |

**Condition:** A configuration object has no version active during a required processing period. Either the object has expired before the period, has not yet become effective, or has a gap between versions.

**System Behaviour:** Affected employees or payroll contexts held. Gap details identified in the readiness report.

**Operator Action Required:** Create a new version of the configuration object covering the required period, or extend the effective dates of an existing version.

**Related Codes:** EXC-VAL-022

---

### EXC-CFG-004

| Field | Detail |
|---|---|
| **Code** | EXC-CFG-004 |
| **Name** | Code Mapping Not Found for Earning or Deduction Type |
| **Severity** | Hard Stop |
| **Domain** | Code Classification |

**Condition:** An earning, deduction, or tax code present in a payroll result or external import does not have a mapping in the Code_Classification_and_Mapping_Model.

**System Behaviour:** Affected record blocked from processing. Routed to exception queue with the unmapped code value.

**Operator Action Required:** Add the missing code mapping to the canonical code classification table, approve it, and reprocess the affected records.

**Related Codes:** EXC-INT-002, EXC-VAL-021

---

### EXC-CFG-005

| Field | Detail |
|---|---|
| **Code** | EXC-CFG-005 |
| **Name** | Calendar Not Defined for Payroll Context and Period |
| **Severity** | Hard Stop |
| **Domain** | Calendar Configuration |

**Condition:** A payroll run is attempted for a Payroll_Context_ID and Period_ID for which no payroll calendar entry exists.

**System Behaviour:** Run initiation blocked. Error surfaced immediately on run creation attempt.

**Operator Action Required:** Generate the required calendar period for the payroll context and ensure it is in an Open state before initiating the run.

**Related Codes:** EXC-VAL-024, EXC-RUN-001

---

### EXC-CFG-006

| Field | Detail |
|---|---|
| **Code** | EXC-CFG-006 |
| **Name** | Rule Version Conflict — Multiple Active Versions |
| **Severity** | Hard Stop |
| **Domain** | Rule Versioning |

**Condition:** More than one version of the same rule is active for an overlapping effective date range and applicability domain, creating an ambiguous resolution state.

**System Behaviour:** Affected rule family flagged as ambiguous. Dependent calculation paths blocked.

**Operator Action Required:** Review the overlapping rule versions. Retire or close the superseded version, or adjust effective dates to eliminate the overlap.

**Related Codes:** EXC-CAL-002
