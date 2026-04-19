# EXC-COR — Correction Workflow Exceptions

| Field | Detail |
|---|---|
| **Document Type** | Exception Catalogue |
| **Version** | v1.0 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/EXC/EXC-COR_Correction_Exceptions.md` |
| **Related Documents** | docs/architecture/governance/Correction_and_Immutability_Model.md, docs/rules/Posting_Rules_and_Mutation_Semantics.md, docs/STATE/STATE-RET_Retro_Adjustments.md |

## Purpose

Defines exceptions arising from correction and retro workflows — attempts to modify released data, conflicting correction states, and immutability violations.

---

### EXC-COR-001

| Field | Detail |
|---|---|
| **Code** | EXC-COR-001 |
| **Name** | Attempt to Directly Overwrite Released Payroll Data |
| **Severity** | Hard Stop |
| **Domain** | Immutability Enforcement |

**Condition:** A direct modification was attempted on a payroll result, accumulator, or export record that has reached STATE-RUN-017 (Closed) or later. Direct overwrites of released data are not permitted under any circumstance.

**System Behaviour:** Modification blocked. Attempt logged with actor identity, timestamp, and targeted record. Alert generated.

**Operator Action Required:** Use the correction workflow (void + replacement or adjustment) rather than direct editing. The original record must remain intact for audit purposes.

**Related Codes:** EXC-COR-002, EXC-VAL-005

---

### EXC-COR-002

| Field | Detail |
|---|---|
| **Code** | EXC-COR-002 |
| **Name** | Correction Targets a Record Under Active Reconciliation |
| **Severity** | Hold |
| **Domain** | Correction Sequencing |

**Condition:** A correction action targets a payroll record or export that is currently in an active reconciliation state (STATE-REC-002 through STATE-REC-006). Applying a correction while reconciliation is open may produce an irreconcilable state.

**System Behaviour:** Correction held. Not applied. Operator notified that the target record is under active reconciliation.

**Operator Action Required:** Wait for the reconciliation to reach STATE-REC-007 (Verified) or STATE-REC-008 (Closed) before applying the correction, or coordinate with the reconciliation owner to determine safe sequencing.

**Related Codes:** EXC-COR-001

---

### EXC-COR-003

| Field | Detail |
|---|---|
| **Code** | EXC-COR-003 |
| **Name** | Retro Correction Affects Multiple Closed Periods |
| **Severity** | Hold |
| **Domain** | Retroactive Corrections |

**Condition:** A retroactive correction has an effective date that spans multiple closed payroll periods, requiring recalculation across more than one period.

**System Behaviour:** Correction held pending operator review. The system identifies all affected periods and generates an impact summary.

**Operator Action Required:** Review the multi-period impact summary. Determine whether to process as a single multi-period correction or as individual period-specific corrections. Approve the approach before processing begins.

**Related Codes:** EXC-VAL-014, EXC-CAL-006

---

### EXC-COR-004

| Field | Detail |
|---|---|
| **Code** | EXC-COR-004 |
| **Name** | Correction Produces Zero Net Delta |
| **Severity** | Informational |
| **Domain** | Correction Outcomes |

**Condition:** A correction was processed and the net financial delta across all affected accounts, accumulators, and tax obligations is zero. The correction had no financial impact.

**System Behaviour:** Correction completed. Informational record created noting zero net delta. Audit trail preserved.

**Operator Action Required:** No action required. Review if the zero-delta result was unexpected — it may indicate that the original issue was already resolved by a prior correction.

**Related Codes:** None

---

### EXC-COR-005

| Field | Detail |
|---|---|
| **Code** | EXC-COR-005 |
| **Name** | Year-End Correction After Filing |
| **Severity** | Hard Stop |
| **Domain** | Year-End Corrections |

**Condition:** A correction affects wages, taxes, or accumulators for a period within a tax year for which a W-2 or equivalent year-end form has already reached STATE-YEP-004 (Filed).

**System Behaviour:** Correction blocked from automatic application. Alert generated to Payroll Supervisor and Compliance team.

**Operator Action Required:** Determine whether a corrected form (W-2c or equivalent) is required. If so, initiate the year-end reissue workflow. Document all decisions for audit purposes. Do not apply corrections silently to filed tax years.

**Related Codes:** EXC-COR-001, EXC-AUD-001
