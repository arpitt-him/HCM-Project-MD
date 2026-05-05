# SPEC — Pay Calendar Generation

| Field | Detail |
|---|---|
| **Document Type** | Functional Specification |
| **Version** | v0.1 |
| **Status** | Draft |
| **Owner** | Payroll Domain |
| **Location** | `docs/SPEC/Pay_Calendar_Generation.md` |
| **Related Documents** | PRD-0300_Payroll_Calendar, docs/architecture/payroll/Payroll_Calendar_Model.md, docs/architecture/payroll/Holiday_and_Special_Calendar_Model.md, SPEC/Payroll_Core_Module.md |

---

## Purpose

Defines the rules and user-facing configuration by which payroll period pay dates, input cutoff dates, and related date controls are computed during calendar generation. This spec governs the `Generate Calendar` UI flow on the Pay Calendar Detail page and any future batch or API-driven generation path.

The central requirement is that pay date computation must be **convention-driven and explicitly chosen by the payroll administrator**, not derived from a mechanical offset that may produce dates inconsistent with the company's pay cycle culture. The convention chosen is stored on the payroll context and used for all future generation within that context.

---

## 1. Scope

This spec covers:

- Convention selection per payroll context (one-time setup)
- Pay date computation for all supported pay frequencies
- Input cutoff date computation relative to pay date
- Weekend adjustment applied to all generated dates
- UI changes to the Generate Calendar dialog
- Data model additions required

Holiday adjustment is out of scope for this version (see `Holiday_and_Special_Calendar_Model.md`).

---

## 2. Foundational Principles

**P-1: Conventions are per context, not per period.**
The pay date convention is a property of the payroll context. All periods generated under a context follow the same convention. Changing the convention after periods are generated does not retroactively alter existing periods.

**P-2: The non-business day rule is always applied after convention computation.**
Regardless of which convention is chosen, if the computed date falls on a weekend or holiday it shall roll back to the prior business day. This adjustment is applied independently to the pay date and the input cutoff date.

**P-3: The stored pay date is the authoritative date.**
Once written to the period record, `PayDate` governs tax calculations, accumulator alignment, and transmission scheduling. It is not recomputed at run time.

**P-4: The user is presented only the choices appropriate to their frequency.**
The UI shall show only the conventions that are meaningful for the selected context's pay frequency. An offset-day input is never shown for anchor-date frequencies (semi-monthly, monthly).

---

## 3. Pay Date Conventions by Frequency

### 3.1 Weekly

The simplest schedule — employees are paid the same day every week. Because each period always ends on the same day of the week, a fixed offset from period end produces a consistent pay day throughout the year.

**Common industry pattern:**

| Decision | Common Choice |
|---|---|
| Pay day | Friday (most common); sometimes Thursday or Wednesday |
| Work week | Sunday–Saturday or Monday–Sunday |
| Lag | Usually 1 week — work week ends Saturday, paid the following Friday |

**Choosing the right offset:**

The offset that delivers Friday pay depends on what day the period ends — which is determined by the first period start anchor chosen at generation time. The table below shows common combinations:

| Period ends on | Offset | Raw pay date | After roll-back | Result |
|---|---|---|---|---|
| Saturday | 6 | Friday | — | Friday ✓ |
| Saturday | 7 | Saturday | Friday | Friday ✓ |
| Sunday | 5 | Friday | — | Friday ✓ |
| Friday | 7 | Friday | — | Friday (following) ✓ |

Either offset=6 (Saturday end) or offset=7 (with roll-back from Saturday) produces Friday pay. The administrator should select an offset consistent with their anchor day.

The user specifies:

| Parameter | Description |
|---|---|
| **Pay Date Offset (days)** | Number of calendar days after `PeriodEnd` on which payment is made. Typical values: 3–7. Default: **6** (Saturday period end → Friday). |
| **Cutoff Offset (days)** | Number of calendar days before `PayDate` that inputs must be received. Default: 3. |

### 3.2 Biweekly

Every two weeks — **not the same as semi-monthly.** Biweekly produces 26 pay periods per year on a fixed day-of-week cycle. Semi-monthly produces 24 periods anchored to specific calendar dates. The distinction matters: biweekly periods float across months and will occasionally produce three paydays in a single calendar month (twice per year); semi-monthly never does.

**Common industry pattern:**

| Decision | Common Choice |
|---|---|
| Pay day | Every other Friday |
| Anchor date | Pick a starting Friday; periods repeat every 14 days from that anchor |
| Lag | Usually 1 week after the two-week period ends |

**Choosing the right offset:**

The correct offset depends on what day the biweekly period ends, which is determined by the anchor (`First Period Start`) the administrator sets at generation time:

| Period ends on | Offset | Raw pay date | After roll-back | Result |
|---|---|---|---|---|
| Saturday | 6 | Friday | — | Friday ✓ |
| Saturday | 7 | Saturday | Friday | Friday ✓ |
| Friday | 7 | Friday (following) | — | Friday ✓ |
| Sunday | 5 | Friday | — | Friday ✓ |

An offset of 5 with a Saturday period end produces Thursday — not the industry-standard Friday — and should be avoided. The recommended default is **7**, which produces Friday pay via roll-back regardless of whether the period ends Friday or Saturday.

Example: period ends Friday, offset = 7 days → raw pay date = following Friday. No roll-back needed; Friday is already a business day. The administrator sets the `First Period Start` date to establish the anchor; all 26 periods for the year derive from it.

| Parameter | Description |
|---|---|
| **Pay Date Offset (days)** | Number of calendar days after `PeriodEnd` on which payment is made. Typical values: 3–14. Default: **7** (produces Friday pay via roll-back for Saturday period-end; lands directly on following Friday for Friday period-end). |
| **Cutoff Offset (days)** | Number of calendar days before `PayDate` that inputs must be received. Default: 3. |

Computation:

```
rawPayDate  = PeriodEnd + PayDateOffsetDays
rawCutoff   = rawPayDate − CutoffOffsetDays
PayDate     = ShiftOffWeekend(rawPayDate)
InputCutoff = ShiftOffWeekend(rawCutoff)
```

No convention choice is presented to the user for these frequencies. The offset fields are sufficient.

---

### 3.3 Monthly

The period always spans the full calendar month (1st through last day). The pay date is determined by one of four conventions. The administrator selects exactly one at context setup time and it applies to all twelve months.

| Code | Label | Pay Date Logic |
|---|---|---|
| `MONTH_END` | Last day of the month | `PayDate = last day of PeriodMonth` |
| `MID_MONTH` | 15th of the month | `PayDate = 15th of PeriodMonth` |
| `FIRST_FOLLOWING` | 1st of following month | `PayDate = 1st of PeriodMonth + 1` |
| `FIXED_25` | 25th of the month | `PayDate = 25th of PeriodMonth` |

In all cases, the non-business day roll-back rule (§4) is applied after the convention date is computed. The convention defines the target anchor date; the actual stored pay date may be earlier if that anchor falls on a weekend or holiday.

**When to choose each:**

- `MONTH_END` — **(Most common.)** Aligns with the accounting period close. Employees are paid for the full month on the last working day of that month. The pay date and the period end are the same working day; there is no lag.
- `MID_MONTH` — Mid-month payment. Simple and predictable — employees always know pay arrives on the 15th.
- `FIRST_FOLLOWING` — Gives the payroll team the full month to process; pay is slightly delayed. Employees receive their monthly pay on the 1st of the following month (e.g., January wages paid February 1). **Year boundary:** December's pay date is January 1 of the following year. The period record remains attributed to the December calendar year; only the pay date crosses into the new year. The calculation engine uses the stored `PayDate` for tax period attribution, so no special handling is required at generation time.
- `FIXED_25` — Gives employees money before month-end bills are due while giving payroll most of the month to process. Pay is slightly early relative to period end.

**Cutoff computation (monthly, all conventions):**

```
rawCutoff   = PayDate − CutoffOffsetDays
InputCutoff = ShiftOffWeekend(rawCutoff)
```

The administrator specifies `CutoffOffsetDays` (default: 5). This is the only numeric input shown for monthly calendars alongside the convention selector.

---

### 3.4 Semi-Monthly

Two periods per month: Period A covers the 1st through the 15th; Period B covers the 16th through the last day of the month. The administrator selects one convention; it governs both periods for all twelve months.

| Code | Label | Period A Pay Date | Period B Pay Date | Common For |
|---|---|---|---|---|
| `SM_15_AND_END` | 15th and last day | 15th of month | Last day of month | Most common semi-monthly |
| `SM_1_AND_15` | 1st and 15th | 1st of month | 15th of month | Government, education |
| `SM_10_AND_25` | 10th and 25th | 10th of month | 25th of month | Less common |

The non-business day roll-back rule (§4) applies to each anchor date independently after it is computed. The anchor date is the target; the actual stored pay date may be earlier if the anchor falls on a weekend or holiday.

**Notes:**

- `SM_15_AND_END` — Pay falls on the last day of each period. Employees are paid for work already completed. No processing lag.
- `SM_1_AND_15` — Fixed dates that employees and agencies plan around. The 1st-of-month payment covers the prior Period B; the 15th covers the prior Period A. Standard in many public sector and education payrolls.
- `SM_10_AND_25` — Gives the payroll team 10 days of processing time after each period close while still delivering pay before month-end bills are due.

---

### 3.4.1 Common Gotcha: 53rd / 27th Pay Period

Because a calendar year is 365 days (366 in a leap year) and neither 52 × 7 nor 26 × 14 divides evenly into every year, weekly and biweekly payrolls will occasionally produce an extra pay period depending on where the anchor Friday falls.

| Frequency | Normal periods | Extra period | Approximate recurrence |
|---|---|---|---|
| Weekly | 52 | 53rd | Every 5–6 years; more likely in a leap year |
| Biweekly | 26 | 27th | Every 5–6 years; more likely in a leap year |

**Why it happens:** A standard year has 52 weeks plus 1 extra day (2 extra in a leap year). If the anchor pay date falls early enough in the year, 52 full biweekly cycles will still leave enough remaining days for a 27th period to begin before December 31.

**Why it matters:** Salaried employees whose annual compensation is divided by the number of periods (salary ÷ 26) will receive a 27th payment at that same per-period rate, effectively overpaying them by 1/26 of their annual salary unless the administrator takes action.

**Policy flag — stored on the payroll context:**

The payroll context shall carry an `extra_period_policy` field that governs how the calculation engine treats the extra period when it occurs. The administrator sets this policy at context setup time; it does not need to be revisited at generation time unless they wish to change it.

| Code | Label | Behaviour |
|---|---|---|
| `ADJUST_ALL` | Adjust all checks — divide salary by 27 | The per-period salary rate for the entire year is recalculated as `AnnualSalary ÷ 27`. All 27 periods pay the adjusted (slightly lower) amount. Employees receive their correct annual salary across the year. |
| `EXTRA_SPECIAL` | Pay 26 normal, treat 27th as special | The first 26 periods pay at the standard rate (`AnnualSalary ÷ 26`). The 27th period is flagged as a special-case run; the calculation engine does not automatically compute a salary line for it. The payroll team handles it manually — typically as a bonus, a withheld period, or a zero-dollar administrative run. |
| `PER_EMPLOYEE` | Let HR decide per employee | The 27th period is generated normally. Each employee record may carry an `extra_period_override` flag set by HR that instructs the calculation engine to either include or suppress the standard salary line for that employee in the extra period. Employees without an explicit override receive their standard per-period pay. |

**System behaviour at generation time:** The generator shall detect when a weekly or biweekly year will produce more periods than the standard count and display a prominent warning before generation completes, showing the configured policy:

> ⚠ This calendar will contain **27 pay periods** (standard is 26). Configured policy: **Adjust all checks (÷ 27)**. Review before proceeding.

The warning does not block generation. The administrator acknowledges and proceeds.

---

### 3.5 Quarterly and Annual

These frequencies are used for non-regular disbursements (bonuses, profit-sharing, annual compensation). The offset model is used. No convention selector is presented.

| Parameter | Description |
|---|---|
| **Pay Date Offset (days)** | Calendar days after `PeriodEnd`. Default: 10. |
| **Cutoff Offset (days)** | Calendar days before `PayDate`. Default: 5. |

---

### 3.6 Processing Chain — Calculation Date and Transmission Date

Each pay period has two operational dates beyond the pay date and input cutoff:

| Date | Meaning |
|---|---|
| `CalculationDate` | The day payroll is actually run and validated. All input must be complete by `InputCutoffDate`; the calculation engine processes the batch on this date. |
| `TransmissionDate` | The day the payroll file is transmitted to the bank / ACH processor. Must be received by the processor at least 2 banking days before `PayDate` for standard ACH settlement. |

**Processing chain (all frequencies):**

```
PeriodEnd
  → (+offset or convention)          → raw PayDate → ShiftToBusinessDay → PayDate
  → PayDate − CutoffOffsetDays       → raw Cutoff  → ShiftToBusinessDay → InputCutoffDate
  → PayDate − CalculationLeadDays    → raw CalcDate → ShiftToBusinessDay → CalculationDate
  → PayDate − 2 banking days         →                                    TransmissionDate
```

**Generated dates are a first cut, not final.** The generator computes `CalculationDate` and `TransmissionDate` from the configured leads and stores them on the period record. The payroll administrator may edit these dates on individual periods after generation — for example, to accommodate a specific holiday, a vendor deadline, or a one-off schedule change. Editing a generated date does not affect other periods or the context configuration.

**Constraint:** `CalculationDate` must be on or after `InputCutoffDate`. The generator shall validate this at generation time and warn the administrator if the configured leads would violate this constraint.

**Why TransmissionDate is fixed at 2 banking days:**

Standard ACH requires the originating bank to submit the file 2 banking days before the settlement date. This is a banking-system requirement, not a configurable business rule. For a Friday pay date the transmission deadline is Wednesday; a Monday pay date (holiday-shifted) means transmission must occur the prior Thursday.

**Typical run-day guidance by frequency:**

| Frequency | Typical Calculation Day | Lead (business days before PayDate) | Why |
|---|---|---|---|
| Weekly | Tuesday or Wednesday | 2–3 | Tight turnaround — short processing window |
| Biweekly | Monday or Tuesday of pay week | 3–4 | Same logic; slightly more breathing room |
| Semi-Monthly | 3–5 business days before pay date | 3–5 | Variable period lengths; salary proration adds complexity |
| Monthly | 5–7 business days before pay date | 5–7 | Largest batch; most adjustments; final month-end data needed |
| Quarterly / Annual | 7–10 business days before pay date | 7–10 | Bonus and special-comp logic requires extended review |

**Recommended `CalculationLeadDays` defaults by frequency** (stored on payroll context):

| Frequency | Default `calculation_lead_days` | Rationale |
|---|---|---|
| Weekly | 2 | Run Wednesday; transmit Wednesday; pay Friday |
| Biweekly | 3 | Run Tuesday; transmit Wednesday; pay Friday |
| Semi-Monthly | 4 | Mid-range of 3–5; allows adjustment window |
| Monthly | 6 | Mid-range of 5–7; accommodates month-end close |
| Quarterly | 8 | Extended review for bonus/equity calculations |
| Annual | 8 | Same as quarterly |

These defaults are pre-populated by the context creation form (see §9.5). The administrator may increase them; the only hard floor is that `CalculationDate >= InputCutoffDate`.

---

### 3.7 Processing Timelines, Arrears, and Data Lock Gates

#### The Three Zones of a Pay Period

Every pay period spans three distinct zones, each with corresponding dates on the period record:

```
|--- Work Period ---|-- Processing Window --|-- Pay Date
                    ^                       ^
                 Cutoff                   Funds land
```

| Zone | Dates on record | What happens here |
|---|---|---|
| Work period | `PeriodStartDate` → `PeriodEndDate` | Employees work and log time |
| Processing window | `InputCutoffDate` → `CalculationDate` → `TransmissionDate` | Payroll collects, reviews, calculates, and transmits |
| Pay date | `PayDate` | Funds settle in employee accounts |

The system generates first-cut values for all three zones at calendar generation time. Administrators may edit individual period dates after the fact.

---

#### Arrears vs. Current Pay

The relationship between the work period and the processing window depends on whether the payroll runs in **arrears** or **current**:

| Model | How it works | Common with |
|---|---|---|
| **Arrears** (most common) | Work first, get paid later. The period closes before payroll begins processing. | Weekly, biweekly, hourly employees |
| **Current** | Paid within the same period you work. Processing begins before the period closes, based on estimates or fixed amounts. | Monthly salaried |

Arrears gives the payroll team time to collect actual hours worked — no guesswork. Current pay works for salaried employees because the amount is fixed and predictable; there are no timesheets to wait for, so payroll can open a preliminary run mid-period and finalise before the close date.

**Implication for calendar generation:** For arrears frequencies (weekly, biweekly, semi-monthly with lag), `InputCutoffDate` always falls after `PeriodEndDate`. For current-pay monthly contexts, `CalculationDate` may precede `PeriodEndDate` — the preliminary run happens mid-month on estimated figures.

---

#### Data Lock Gates — What Locks When

The processing window is also the window during which the system enforces data locks. As each gate date passes, a different class of data becomes read-only for that period:

| Gate | Date | What locks |
|---|---|---|
| **Input cutoff** | `InputCutoffDate` | Timesheets, PTO requests, new-hire effective dates |
| **Run date** | `CalculationDate` | Pay rates, deductions, tax elections, benefit elections |
| **Pay date** | `PayDate` | Everything — period is closed and reconciled |

These locks protect the integrity of each run. An administrator may override a lock on an individual period (with appropriate role), but the calendar record tracks which gate has been crossed.

---

#### Period State Machine

Each period moves through a defined sequence of states. State transitions are triggered by the gate dates above and are not reversible without an admin override:

```
UPCOMING → OPEN → CUTOFF → PROCESSING → SUBMITTED → PAID
```

| State | Entered when | Data that becomes editable |
|---|---|---|
| `UPCOMING` | Period generated; start date is in the future | No data entry permitted yet |
| `OPEN` | `PeriodStartDate` reached | Timesheets, PTO, new hires for this period |
| `CUTOFF` | `InputCutoffDate` reached | Timesheets and PTO lock; pay rates still adjustable |
| `PROCESSING` | `CalculationDate` reached | Pay rates, deductions, tax elections, benefit elections lock |
| `SUBMITTED` | `TransmissionDate` reached — ACH file sent | All calculation data locks; correction window may still be open |
| `PAID` | `PayDate` reached | Period fully closed; all data read-only without override |

Each transition locks the relevant data class and prevents edits to that class for that period without an explicit admin override. The override is logged and auditable.

_Note: the current implementation uses simplified status codes (`OPEN`, `CLOSED`, `LOCKED`). The full six-state machine above is the target model and will require a migration and status-transition logic layer._

---

#### Frequency Timelines

The following timelines illustrate the operational rhythm for each common frequency. Dates are relative to the period end unless otherwise noted.

---

**Weekly — Friday Pay Date**

> **Extremely tight.** This is why weekly payroll is operationally the most expensive frequency. There is almost no room for errors — a single missed step pushes the pay date.

| Day | Activity |
|---|---|
| Sunday midnight | Period closes |
| Monday | Timesheets due from managers |
| Tuesday | Payroll reviews, approves time data |
| Wednesday | Payroll submitted to bank (ACH file transmitted) |
| Thursday | ACH processing by banking system |
| Friday | **Pay day — funds settle** |

_Worked example — Week of Jan 4, 2026:_

```
Sun Jan  4   Period closes (Dec 29 – Jan 4)
Mon Jan  5   Timesheets due                      ← InputCutoffDate
Tue Jan  6   Payroll reviews and approves
Wed Jan  7   ACH file transmitted                ← CalculationDate / TransmissionDate
Thu Jan  8   Bank processing
Fri Jan  9   Pay day                             ← PayDate
```

The calculation and transmission fall on the same day. The 5-day end-to-pay cycle leaves no buffer for corrections.

---

**Biweekly — Every Other Friday**

Biweekly has one more business day of breathing room than weekly, but the same structural constraints apply. The anchor determines the period boundaries for the entire year.

| Day | Activity |
|---|---|
| Sunday midnight | Two-week period closes |
| Monday | Timesheets due |
| Tuesday | Review, corrections |
| Wednesday | Final approval, submit to bank |
| Thursday | ACH processing |
| Friday | **Pay day — funds settle** |

_Worked example — Period 1 of 2026 (biweekly):_

```
Sun Jan 18   Period closes (Jan 5 – Jan 18)
Mon Jan 19   Timesheets due                      ← InputCutoffDate
Tue Jan 20   Review and corrections
Wed Jan 21   Final approval, ACH transmitted     ← CalculationDate / TransmissionDate
Thu Jan 22   Bank processing
Fri Jan 23   Pay day                             ← PayDate
```

---

**Semi-Monthly (15th and Last Day of Month)**

Because period end and pay date are close together for `SM_15_AND_END` (pay on the close date itself), some payroll teams process on estimated figures for the last day or two and true-up next period. Conventions with a built-in lag (`SM_10_AND_25`, `SM_1_AND_15`) are more forgiving — the processing window opens naturally after the period closes.

| Day | Activity |
|---|---|
| Period end | Period closes (15th or last day of month) |
| Period end + 1 | Timesheets and adjustments due |
| Period end + 2–3 | Payroll review and approval |
| Period end + 3–4 | Submit to bank |
| Period end + 5 | **Pay day — funds settle** |

_Worked example — Period A February 2026 (SM\_10\_AND\_25):_

```
Sun Feb 15   Period A closes (Feb 1 – Feb 15)
Mon Feb 16   Timesheets/adjustments due          ← InputCutoffDate
Tue–Wed Feb 17–18   Payroll review
Thu Feb 19   Approved; ACH submitted             ← CalculationDate / TransmissionDate
Fri–Tue Feb 20–24   Bank processing window
Wed Feb 25   Pay day                             ← PayDate  (Feb 25, no weekend adjustment)
```

SM\_10\_AND\_25 provides a consistent 10-calendar-day lag from period end to pay date, making it the most processing-friendly semi-monthly convention.

---

**Monthly — Last Day of Month**

Monthly is the most complex batch — largest headcount, most adjustments, commissions and overtime must be captured — but also the most forgiving schedule. The preliminary run on fixed salaries can begin mid-month while variable components are still being finalised.

| Day | Activity |
|---|---|
| ~20th–22nd | Preliminary payroll run (estimates for salaried employees) |
| ~25th | Final adjustments added: overtime, commissions, bonuses |
| ~26th–27th | Payroll approved and submitted to bank |
| ~28th–29th | ACH processing |
| Last day | **Pay day — funds settle** |

_Worked example — January 2026 (MONTH\_END):_

```
Wed Jan 21   Preliminary run opens               ← CalculationDate (preliminary)
Sun Jan 25   Adjustments finalised
Mon Jan 26   Payroll approved
Tue Jan 27   ACH file transmitted                ← TransmissionDate
Wed Jan 28   Bank processing begins
Thu Jan 29   Correction window                   ← CorrectionWindowCloseDate
Fri Jan 30   Pay day                             ← PayDate  (Jan 31 Sat → rolled back to Jan 30)
```

`InputCutoffDate` for monthly is reached on approximately Jan 25 (5 business days before pay date), when variable data must be locked. The preliminary run at ~Jan 21 precedes the cutoff — this is the current-pay pattern: salaried lines process before the period formally closes.

---

## 4. Non-Business Day Adjustment Rule

Applied universally after any convention or offset computation produces a raw date. A **business day** is any day that is neither a weekend nor a recognised holiday for the payroll context.

### 4.1 Rule

**Always pay early, never late.** Step backward one day at a time until a business day is reached:

```
while PayDate is Saturday, Sunday, or a Holiday:
    PayDate = PayDate − 1 day
```

This handles cascading cases — for example, if the computed date is a Monday holiday and the preceding Friday is also a holiday, the result will be Thursday.

### 4.2 Explicit cases

| Computed date falls on | Result |
|---|---|
| Saturday | Pay on Friday |
| Sunday | Pay on Friday (two days back) |
| Holiday (weekday) | Pay on prior business day |
| Holiday that is also Saturday | Pay on prior business day before the holiday |
| Holiday that is also Sunday | Pay on prior business day before the holiday |

### 4.3 Scope of adjustment

Both `PayDate` and `InputCutoff` are independently adjusted using this rule. The adjustment is applied at generation time and stored. It is not recomputed at run time.

### 4.4 Holiday calendar dependency

Application of the holiday rule requires a holiday calendar scoped to the payroll context's legal entity. If no holiday calendar is defined for the context, only the weekend adjustment is applied (Saturday → Friday, Sunday → Friday). Holiday adjustment is a no-op when no holidays are configured — generation does not fail.

This behaviour is consistent with REQ-CAL-017: holiday calendar automation is optional in v1. The adjustment logic is in place; the data that feeds it may be absent.

---

## 5. Convention Storage — Data Model

The payroll context record shall be extended with the following fields:

| Field | Type | Description |
|---|---|---|
| `pay_date_convention` | `VARCHAR(30)` | Convention code from §3. Null for weekly/biweekly (offset model only). |
| `pay_date_offset_days` | `INTEGER NOT NULL DEFAULT 5` | Days after period end for pay date. Used by weekly, biweekly, quarterly, annual only. DB default of 5 is a safe floor for migrated rows; new contexts should receive a frequency-specific value per §9.5. |
| `cutoff_offset_days` | `INTEGER NOT NULL DEFAULT 3` | Days before pay date for input cutoff. Used by all frequencies. |
| `calculation_lead_days` | `INTEGER NOT NULL DEFAULT 3` | Business days before pay date on which payroll is calculated. Must satisfy `CalculationDate >= InputCutoffDate`. Frequency-specific defaults per §3.6. |
| `extra_period_policy` | `VARCHAR(20) NOT NULL DEFAULT 'EXTRA_SPECIAL'` | How the calculation engine handles a 27th biweekly or 53rd weekly period. Applies only to weekly and biweekly contexts; ignored for all other frequencies. |

Valid values for `pay_date_convention`: `MONTH_END`, `MID_MONTH`, `FIRST_FOLLOWING`, `FIXED_25`, `SM_15_AND_END`, `SM_1_AND_15`, `SM_10_AND_25`.

Valid values for `extra_period_policy`: `ADJUST_ALL`, `EXTRA_SPECIAL`, `PER_EMPLOYEE`. Default is `EXTRA_SPECIAL` — the safest choice, as it prevents an unintended extra paycheck from processing automatically and requires an explicit decision by the payroll team.

The generation logic reads these values from the context record. The `Generate Calendar` dialog displays the stored convention as a read-only confirmation line — it does not re-present the selector. Convention changes must be made on the context record itself, not overridden at generation time. Offset fields (pay date offset, cutoff offset) remain editable in the dialog since these may legitimately differ by year.

---

## 6. UI Specification — Generate Calendar Dialog

The dialog is rendered conditionally based on the context's `PayFrequencyCode`. Layout changes per frequency.

### 6.1 Weekly / Biweekly

```
┌─ Calendar Generation ───────────────────────────────────┐
│  Year:               [2026         ▼]                    │
│  First Period Start: [2026-01-01   📅]                   │
│  Pay Date Offset:    [6] days after period end   ← weekly default (6); biweekly default (7)
│  Cutoff Offset:      [3] days before pay date            │
│                      [Generate]  [Cancel]                │
└─────────────────────────────────────────────────────────┘
```

The Pay Date Offset field pre-populates from the context's stored `pay_date_offset_days` value. On the New Context form, when the administrator selects a frequency, the field is initialised to the recommended default for that frequency (see §9.5).

### 6.2 Monthly

```
┌─ Calendar Generation ───────────────────────────────────┐
│  Year:               [2026         ▼]                    │
│  Pay Date Convention:                                    │
│    ● Last day of the month              ← default        │
│    ○ 1st of the following month                          │
│    ○ 15th of the month                                   │
│    ○ 25th of the month                                   │
│  Cutoff Offset:      [5] days before pay date            │
│                      [Generate]  [Cancel]                │
└─────────────────────────────────────────────────────────┘
```

No period-start input is shown for monthly — periods always begin on the 1st of each month.

The selected convention is shown as a preview before the user generates:

> _Preview: January pay date = 2026-02-02 (Mon Feb 2 — shifted from Sat Feb 1)_

### 6.3 Semi-Monthly

```
┌─ Calendar Generation ───────────────────────────────────┐
│  Year:               [2026         ▼]                    │
│  Pay Date Convention:                                    │
│    ● 15th and last day of month         ← default        │
│    ○ 1st and 15th of month                               │
│    ○ 10th and 25th of month                              │
│  Cutoff Offset:      [5] days before pay date            │
│                      [Generate]  [Cancel]                │
└─────────────────────────────────────────────────────────┘
```

### 6.4 Quarterly / Annual

Same layout as Weekly/Biweekly with no first-period-start input (period boundaries are fixed to quarter or year boundaries).

---

## 7. Computation Reference — All Frequencies

| Frequency | Convention | Period A (or only) PayDate | Period B PayDate |
|---|---|---|---|
| WEEKLY | Offset | PeriodEnd + N days | — |
| BIWEEKLY | Offset | PeriodEnd + N days | — |
| MONTHLY | MONTH_END | Last day of month | — |
| MONTHLY | MID_MONTH | 15th of month | — |
| MONTHLY | FIRST_FOLLOWING | 1st of next month | — |
| MONTHLY | FIXED_25 | 25th of month | — |
| SEMI_MONTHLY | SM_15_AND_END | 15th of month | Last day of month |
| SEMI_MONTHLY | SM_1_AND_15 | 1st of month | 15th of month |
| SEMI_MONTHLY | SM_10_AND_25 | 10th of month | 25th of month |
| QUARTERLY | Offset | PeriodEnd + N days | — |
| ANNUAL | Offset | PeriodEnd + N days | — |

Non-business day roll-back (→ prior business day, §4) applied to every PayDate cell after convention computation.

---

## 8. Validation Rules

| Rule | Condition | Error |
|---|---|---|
| Convention required | Monthly context, no convention selected | "Select a pay date convention before generating." |
| Convention required | Semi-monthly context, no convention selected | "Select a pay date convention before generating." |
| Offset range | `PayDateOffsetDays` outside 1–30 (offset-model frequencies only) | "Pay date offset must be between 1 and 30 days." |
| Cutoff range (offset model) | `CutoffOffsetDays` outside 1–`PayDateOffsetDays` (weekly, biweekly, quarterly, annual) | "Cutoff offset must be at least 1 and less than the pay date offset." |
| Cutoff range (convention model) | `CutoffOffsetDays` < 1 (monthly, semi-monthly) | "Cutoff offset must be at least 1." |
| Calculation before cutoff | `CalculationDate` would precede `InputCutoffDate` given configured leads | Warn before generating; do not block. Administrator may adjust leads or edit individual periods post-generation. |
| No duplicate periods | Period number already exists for year | Skip silently (existing behaviour). |
| Year match | Weekly/biweekly first period start not in selected year | "First period start must be in [year]." |

---

## 9. Implementation Notes

### 9.1 `ComputePeriodSpans` is unchanged

The existing method returns `(PeriodStart, PeriodEnd)` tuples. Pay date computation is a separate concern applied after spans are known.

### 9.2 Extract a `PayDateComputer` helper

The pay date logic for each convention shall be in a single static helper method to keep `GenerateCalendarAsync` clean and the logic independently testable:

```csharp
static DateOnly ComputePayDate(
    DateOnly periodEnd, string freqCode, string? convention, int offsetDays)
```

### 9.3 Context record migration

A database migration is required to add `pay_date_convention`, `cutoff_offset_days`, and `pay_date_offset_days` to `payroll_context`. Existing rows shall default to `null` convention (weekly/biweekly offset model), `cutoff_offset_days = 5`, `pay_date_offset_days = 5`. These defaults match the current hard-coded behaviour so existing contexts are unaffected.

### 9.4 Context setup flow

When a new payroll context is created, the context creation form shall present the same convention selector described in §6 so the convention is stored at context creation time, not deferred to calendar generation. The Generate Calendar dialog reads the stored convention and pre-selects it, allowing a one-time override before generation.

### 9.5 Frequency-sensitive offset defaults

A single hard-coded default for `pay_date_offset_days` will produce wrong results for some frequencies. The New Context form and the Generate Calendar dialog shall initialise the offset field to the recommended value for the selected frequency:

| Frequency | Recommended `pay_date_offset_days` default | Rationale |
|---|---|---|
| WEEKLY | 6 | Saturday period end → Friday pay date, no roll-back needed |
| BIWEEKLY | 7 | Friday or Saturday period end → Friday pay date (direct or via roll-back) |
| QUARTERLY | 10 | Gives payroll team ~2 weeks after quarter close |
| ANNUAL | 10 | Same rationale as quarterly |

On the New Context form, when the administrator changes the frequency selector, the pay date offset and calculation lead fields shall update to the recommended defaults for that frequency. This update only applies if the fields have not been manually edited by the user (i.e., they still hold the previous default); manually entered values are preserved.

The full set of frequency-sensitive defaults:

| Frequency | `pay_date_offset_days` | `cutoff_offset_days` | `calculation_lead_days` |
|---|---|---|---|
| Weekly | 6 | 3 | 2 |
| Biweekly | 7 | 3 | 3 |
| Semi-Monthly | — (convention) | 3 | 4 |
| Monthly | — (convention) | 5 | 6 |
| Quarterly | 10 | 5 | 8 |
| Annual | 10 | 5 | 8 |

The database column default of `5` remains as a safe floor for rows migrated from before this spec. New contexts created through the UI will always receive a frequency-appropriate value.

---

## 10. Acceptance Test Cases

Representative inputs and expected outputs. All assume no holidays configured unless stated.

| # | Frequency | Convention | Period End | Raw PayDate | Expected PayDate | Reason |
|---|---|---|---|---|---|---|
| 1 | MONTHLY | MONTH_END | 2026-01-31 (Sat) | 2026-01-31 | **2026-01-30** | Jan 31 is Saturday → prior Friday |
| 2 | MONTHLY | MONTH_END | 2026-03-31 (Tue) | 2026-03-31 | **2026-03-31** | Tuesday; no adjustment |
| 3 | MONTHLY | FIRST_FOLLOWING | 2026-11-30 (Mon) | 2026-12-01 | **2026-12-01** | December 1 is Tuesday; no adjustment |
| 4 | MONTHLY | FIRST_FOLLOWING | 2026-12-31 (Thu) | 2027-01-01 | **2026-12-31** | Jan 1 is New Year's Day (holiday) → prior business day = Dec 31 |
| 5 | MONTHLY | MID_MONTH | 2026-02-28 (Sat) | 2026-02-15 | **2026-02-13** | Feb 15 is Sunday → prior Friday |
| 6 | MONTHLY | FIXED_25 | 2026-04-30 (Thu) | 2026-04-25 | **2026-04-24** | Apr 25 is Saturday → prior Friday |
| 7 | SEMI_MONTHLY | SM_15_AND_END | Period A, March | 2026-03-15 (Sun) | **2026-03-13** | Mar 15 is Sunday → prior Friday |
| 8 | SEMI_MONTHLY | SM_15_AND_END | Period B, March | 2026-03-31 (Tue) | **2026-03-31** | Tuesday; no adjustment |
| 9 | SEMI_MONTHLY | SM_10_AND_25 | Period B, May | 2026-05-25 (Mon) | **2026-05-25** | Monday; no adjustment |
| 10 | BIWEEKLY | Offset = 7 | 2026-07-03 (Fri) | 2026-07-10 | **2026-07-09** | Jul 4 holiday falls on Saturday; Jul 10 is Friday — no adjustment needed, but if holiday observed on Jul 3, prior business day = Jul 2 |
| 11 | WEEKLY | Offset = 6 | 2026-12-26 (Sat) | 2026-01-01 | **2026-12-31** | Jan 1 is holiday → Dec 31 |

**Cascading case (holiday on Friday):**

| # | Scenario | Expected |
|---|---|---|
| 12 | PayDate lands on Monday May 25 (Memorial Day). Prior day is Sunday. Day before is Saturday. Day before is Friday May 22 — business day. | **2026-05-22** |

---

## 11. Out of Scope

- Holiday adjustment to computed pay dates (governed by `Holiday_and_Special_Calendar_Model.md`, not yet implemented)
- Custom anchor days (e.g., "always the third Friday of the month")
- Retroactive recomputation of existing period pay dates when convention changes
- Non-Gregorian calendar systems (REQ-CAL-018)
