-- Migration 012 — Benefits Timing Alignment  (idempotent)
-- Adds proration policy and employer match timing model to support:
--   Monthly benefits on biweekly/weekly payrolls
--   Annual benefits on weekly payrolls (extra-period handling)
--   Employer match per-period vs. annual true-up
--   Mid-period coverage changes and hire/terminate proration

-- ─────────────────────────────────────────────────────────────────────────────
-- 1.  Payroll context — partial period proration policy
-- ─────────────────────────────────────────────────────────────────────────────
-- Controls how benefit deductions are prorated when an election does not cover
-- the full pay period (hire mid-period, termination mid-period, or coverage
-- change mid-period).
--
--   PRORATE_DAYS      Deduction = full_amount × (coverage_days / period_days)
--   FIRST_FULL_PERIOD No deduction in the first or last partial period;
--                     full deduction from the first complete period onward
--   FULL_PERIOD       Always charge the full period amount regardless of
--                     coverage start/end within the period

ALTER TABLE payroll_context
    ADD COLUMN IF NOT EXISTS partial_period_rule varchar(20) NOT NULL DEFAULT 'PRORATE_DAYS';

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_payroll_context_partial_period_rule'
          AND  conrelid = 'payroll_context'::regclass
    ) THEN
        ALTER TABLE payroll_context
            ADD CONSTRAINT ck_payroll_context_partial_period_rule
                CHECK (partial_period_rule IN ('PRORATE_DAYS','FIRST_FULL_PERIOD','FULL_PERIOD'));
    END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.  Deduction employer match — match timing model
-- ─────────────────────────────────────────────────────────────────────────────
-- Controls when the employer match is computed and paid.
--
--   PER_PERIOD       Match computed and paid each pay period based on that
--                    period's employee contribution.  If the employee hits the
--                    IRS annual limit mid-year and stops contributing, match
--                    also stops — no catch-up.
--
--   ANNUAL_TRUE_UP   Best-effort per-period match is paid each period, but on
--                    the last payroll of the year a true-up is computed:
--                        entitlement = min(ytd_ee, annual_cap) × match_rate
--                        true_up     = max(0, entitlement − ytd_match_paid)
--                    Handles the case where an employee front-loads contributions
--                    and hits the IRS limit before year-end.

ALTER TABLE deduction_employer_match
    ADD COLUMN IF NOT EXISTS match_type varchar(20) NOT NULL DEFAULT 'PER_PERIOD';

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_employer_match_type'
          AND  conrelid = 'deduction_employer_match'::regclass
    ) THEN
        ALTER TABLE deduction_employer_match
            ADD CONSTRAINT ck_employer_match_type
                CHECK (match_type IN ('PER_PERIOD','ANNUAL_TRUE_UP'));
    END IF;
END $$;
