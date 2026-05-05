-- Migration 011 — Benefits Deduction Calculation Model  (idempotent rewrite)
-- Renames deduction_code → deduction and adds rule-based calculation support.
--
-- All steps are guarded so the file can be re-run safely after a partial failure.
--
-- Changes:
--   deduction_code table   → renamed to deduction; PK column code_id → deduction_id;
--                            adds calculation_mode, wage_base, age_as_of_rule
--   benefit_deduction_election → deduction_code varchar replaced by deduction_id uuid FK;
--                                adds mode-specific election parameters
--   NEW: deduction_rate_table      rate lookup tables for COVERAGE_BASED mode
--   NEW: deduction_rate_entry      rows within a rate table
--   NEW: deduction_employer_match  employer match rules for PCT modes
--   payroll_context                adds three_paycheck_month_rule

-- ─────────────────────────────────────────────────────────────────────────────
-- 1.  Rename table and primary key column
-- ─────────────────────────────────────────────────────────────────────────────

DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM pg_class WHERE relname = 'deduction_code' AND relkind = 'r') THEN
        ALTER TABLE deduction_code RENAME TO deduction;
    END IF;
END $$;

DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE  table_name = 'deduction' AND column_name = 'code_id'
    ) THEN
        ALTER TABLE deduction RENAME COLUMN code_id TO deduction_id;
    END IF;
END $$;

-- Rename constraints only if the old names still exist on the table
DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'pk_deduction_code'
          AND  conrelid = 'deduction'::regclass
    ) THEN
        ALTER TABLE deduction RENAME CONSTRAINT pk_deduction_code TO pk_deduction;
    END IF;
END $$;

DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'uq_deduction_code_code'
          AND  conrelid = 'deduction'::regclass
    ) THEN
        ALTER TABLE deduction RENAME CONSTRAINT uq_deduction_code_code TO uq_deduction_code;
    END IF;
END $$;

DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_deduction_code_tax_treatment'
          AND  conrelid = 'deduction'::regclass
    ) THEN
        ALTER TABLE deduction RENAME CONSTRAINT ck_deduction_code_tax_treatment TO ck_deduction_tax_treatment;
    END IF;
END $$;

DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_deduction_code_status'
          AND  conrelid = 'deduction'::regclass
    ) THEN
        ALTER TABLE deduction RENAME CONSTRAINT ck_deduction_code_status TO ck_deduction_status;
    END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 2.  Add calculation model columns to deduction
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE deduction
    ADD COLUMN IF NOT EXISTS calculation_mode  varchar(20) NOT NULL DEFAULT 'FIXED_PER_PERIOD',
    ADD COLUMN IF NOT EXISTS wage_base         varchar(20),
    ADD COLUMN IF NOT EXISTS age_as_of_rule    varchar(10);

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_deduction_calculation_mode'
          AND  conrelid = 'deduction'::regclass
    ) THEN
        ALTER TABLE deduction
            ADD CONSTRAINT ck_deduction_calculation_mode CHECK (calculation_mode IN (
                'FIXED_ANNUAL',
                'FIXED_MONTHLY',
                'FIXED_PER_PERIOD',
                'PCT_PRE_TAX',
                'PCT_POST_TAX',
                'COVERAGE_BASED'
            ));
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_deduction_wage_base'
          AND  conrelid = 'deduction'::regclass
    ) THEN
        ALTER TABLE deduction
            ADD CONSTRAINT ck_deduction_wage_base CHECK (
                wage_base IS NULL
                OR wage_base IN ('ALL','REGULAR_ONLY','ELIGIBLE_ONLY','OT_ONLY')
            );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_deduction_age_as_of_rule'
          AND  conrelid = 'deduction'::regclass
    ) THEN
        ALTER TABLE deduction
            ADD CONSTRAINT ck_deduction_age_as_of_rule CHECK (
                age_as_of_rule IS NULL
                OR age_as_of_rule IN ('JAN_1','PAY_DATE')
            );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_deduction_wage_base_mode'
          AND  conrelid = 'deduction'::regclass
    ) THEN
        ALTER TABLE deduction
            ADD CONSTRAINT ck_deduction_wage_base_mode CHECK (
                wage_base IS NULL
                OR calculation_mode IN ('PCT_PRE_TAX','PCT_POST_TAX')
            );
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_deduction_age_as_of_mode'
          AND  conrelid = 'deduction'::regclass
    ) THEN
        ALTER TABLE deduction
            ADD CONSTRAINT ck_deduction_age_as_of_mode CHECK (
                age_as_of_rule IS NULL
                OR calculation_mode = 'COVERAGE_BASED'
            );
    END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 3.  Rate tables  (COVERAGE_BASED mode)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS deduction_rate_table (
    rate_table_id   uuid            NOT NULL DEFAULT gen_random_uuid(),
    deduction_id    uuid            NOT NULL,
    rate_type       varchar(20)     NOT NULL,   -- COVERAGE_TIER | AGE_BAND | SALARY_BAND
    effective_from  date            NOT NULL,
    effective_to    date,
    description     varchar(200),
    created_at      timestamptz     NOT NULL DEFAULT now(),
    CONSTRAINT pk_deduction_rate_table PRIMARY KEY (rate_table_id),
    CONSTRAINT fk_rate_table_deduction
        FOREIGN KEY (deduction_id) REFERENCES deduction (deduction_id),
    CONSTRAINT ck_rate_table_type
        CHECK (rate_type IN ('COVERAGE_TIER','AGE_BAND','SALARY_BAND'))
);

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE  indexname = 'ix_deduction_rate_table_deduction'
    ) THEN
        CREATE INDEX ix_deduction_rate_table_deduction ON deduction_rate_table (deduction_id);
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS deduction_rate_entry (
    rate_entry_id   uuid            NOT NULL DEFAULT gen_random_uuid(),
    rate_table_id   uuid            NOT NULL,
    -- COVERAGE_TIER entries
    tier_code       varchar(20),    -- EE_ONLY | EE_SPOUSE | EE_CHILD | FAMILY
    -- AGE_BAND and SALARY_BAND entries
    band_min        numeric(12,4),  -- lower bound inclusive
    band_max        numeric(12,4),  -- upper bound inclusive (null = no upper limit)
    -- Rates
    -- For COVERAGE_TIER:  monthly flat amount
    -- For AGE_BAND:       rate per $1,000 of coverage amount
    -- For SALARY_BAND:    rate per $1 of salary, or flat amount if band_min = band_max
    employee_rate   numeric(12,6)   NOT NULL,
    employer_rate   numeric(12,6),
    CONSTRAINT pk_deduction_rate_entry PRIMARY KEY (rate_entry_id),
    CONSTRAINT fk_rate_entry_table
        FOREIGN KEY (rate_table_id) REFERENCES deduction_rate_table (rate_table_id),
    CONSTRAINT ck_rate_entry_tier_or_band CHECK (
        (tier_code IS NOT NULL AND band_min IS NULL AND band_max IS NULL)
        OR
        (tier_code IS NULL AND band_min IS NOT NULL)
    ),
    CONSTRAINT ck_rate_entry_tier_code CHECK (
        tier_code IS NULL
        OR tier_code IN ('EE_ONLY','EE_SPOUSE','EE_CHILD','FAMILY')
    )
);

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE  indexname = 'ix_deduction_rate_entry_table'
    ) THEN
        CREATE INDEX ix_deduction_rate_entry_table ON deduction_rate_entry (rate_table_id);
    END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 4.  Employer match rules  (PCT modes)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS deduction_employer_match (
    match_id                uuid            NOT NULL DEFAULT gen_random_uuid(),
    deduction_id            uuid            NOT NULL,
    employee_group_id       uuid,           -- null = applies to all employees
    match_rate              numeric(8,6)    NOT NULL,   -- e.g. 0.500000 = 50% match
    -- Exactly one cap type must be set
    match_cap_pct_of_gross  numeric(8,6),               -- e.g. 0.060000 = match on up to 6% of gross
    match_cap_annual_amount numeric(12,4),               -- alternative: dollar cap per year
    effective_from          date            NOT NULL,
    effective_to            date,
    created_at              timestamptz     NOT NULL DEFAULT now(),
    CONSTRAINT pk_deduction_employer_match PRIMARY KEY (match_id),
    CONSTRAINT fk_employer_match_deduction
        FOREIGN KEY (deduction_id) REFERENCES deduction (deduction_id),
    CONSTRAINT ck_employer_match_cap CHECK (
        (match_cap_pct_of_gross IS NOT NULL AND match_cap_annual_amount IS NULL)
        OR
        (match_cap_pct_of_gross IS NULL AND match_cap_annual_amount IS NOT NULL)
    )
);

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE  indexname = 'ix_deduction_employer_match_deduction'
    ) THEN
        CREATE INDEX ix_deduction_employer_match_deduction
            ON deduction_employer_match (deduction_id);
    END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 5.  Extend benefit_deduction_election
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE benefit_deduction_election
    ADD COLUMN IF NOT EXISTS deduction_id             uuid,
    ADD COLUMN IF NOT EXISTS contribution_pct         numeric(8,6),
    ADD COLUMN IF NOT EXISTS coverage_tier            varchar(20),
    ADD COLUMN IF NOT EXISTS annual_coverage_amount   numeric(12,4),
    ADD COLUMN IF NOT EXISTS annual_election_amount   numeric(12,4),
    ADD COLUMN IF NOT EXISTS monthly_election_amount  numeric(12,4);

-- Backfill deduction_id from the deduction_code string (idempotent — only touches null rows)
UPDATE benefit_deduction_election e
SET    deduction_id = d.deduction_id
FROM   deduction d
WHERE  d.code = e.deduction_code
  AND  e.deduction_id IS NULL;

-- Add FK if it does not already exist
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'fk_election_deduction'
          AND  conrelid = 'benefit_deduction_election'::regclass
    ) THEN
        ALTER TABLE benefit_deduction_election
            ADD CONSTRAINT fk_election_deduction
                FOREIGN KEY (deduction_id) REFERENCES deduction (deduction_id);
    END IF;
END $$;

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_indexes
        WHERE  indexname = 'ix_benefit_election_deduction_id'
    ) THEN
        CREATE INDEX ix_benefit_election_deduction_id
            ON benefit_deduction_election (deduction_id);
    END IF;
END $$;

-- Drop legacy varchar reference only if the FK is in place and the column still exists
DO $$ BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE  table_name = 'benefit_deduction_election'
          AND  column_name = 'deduction_code'
    ) AND EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'fk_election_deduction'
          AND  conrelid = 'benefit_deduction_election'::regclass
    ) THEN
        ALTER TABLE benefit_deduction_election DROP COLUMN deduction_code;
    END IF;
END $$;

-- Coverage tier check constraint
DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_election_coverage_tier'
          AND  conrelid = 'benefit_deduction_election'::regclass
    ) THEN
        ALTER TABLE benefit_deduction_election
            ADD CONSTRAINT ck_election_coverage_tier CHECK (
                coverage_tier IS NULL
                OR coverage_tier IN ('EE_ONLY','EE_SPOUSE','EE_CHILD','FAMILY')
            );
    END IF;
END $$;

-- ─────────────────────────────────────────────────────────────────────────────
-- 6.  Payroll context — three-paycheck month rule
-- ─────────────────────────────────────────────────────────────────────────────

ALTER TABLE payroll_context
    ADD COLUMN IF NOT EXISTS three_paycheck_month_rule varchar(10) NOT NULL DEFAULT 'PRORATE';

DO $$ BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE  conname = 'ck_payroll_context_three_pay_rule'
          AND  conrelid = 'payroll_context'::regclass
    ) THEN
        ALTER TABLE payroll_context
            ADD CONSTRAINT ck_payroll_context_three_pay_rule
                CHECK (three_paycheck_month_rule IN ('PRORATE','SKIP'));
    END IF;
END $$;
