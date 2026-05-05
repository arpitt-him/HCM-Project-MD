-- =============================================================
-- Tax Calculation Pipeline — Seed Data
-- Covers: lkp_tax_form_type, tax_jurisdiction, tax_filing_status,
--         payroll_calculation_steps, and all effective-dated rate
--         tables for the six Phase 5 gate jurisdictions:
--         Barbados (BB), Canada Federal (CA-FED),
--         US Federal (US-FED), Georgia (US-GA),
--         New York (US-NY), California (US-CA)
--
-- Rate years seeded: 2025 (primary), 2026 where confirmed
-- IMPORTANT: All rate values must be verified annually against
--   official publications before December 15 deployment.
--   Payroll runs for January 1 pay dates may be initiated as
--   early as December 26 for ACH pre-funding — new-year rates
--   must be live before that date, not merely before December 31.
--
-- Verification sources:
--   US Federal: IRS Rev. Proc. (annual), IRS Pub 15-T
--   Canada:     CRA T4032 and T4008 guides (annual)
--   Barbados:   Barbados Revenue Authority publications
--   Georgia:    Georgia DOR (publishes rate Oct–Nov each year)
--   New York:   NYS DTF Publication NYS-50 (annual)
--   California: FTB Publication DE 44 (annual)
-- =============================================================


-- =============================================================
-- LKP TAX FORM TYPE
-- =============================================================

INSERT INTO lkp_tax_form_type (code, name) VALUES
  ('W4_2020',    'US Federal W-4 (2020+)'),
  ('W4_LEGACY',  'US Federal W-4 (Pre-2020)'),
  ('IT_2104',    'New York IT-2104'),
  ('DE_4',       'California DE-4'),
  ('G_4',        'Georgia G-4'),
  ('TD1',        'Canada TD1 (Federal)'),
  ('TD1X',       'Canada TD1X (Additional)'),
  ('BB_TD4',     'Barbados TD4');


-- =============================================================
-- TAX JURISDICTION
-- =============================================================

INSERT INTO tax_jurisdiction (jurisdiction_code, jurisdiction_name, country_code, is_active) VALUES
  ('BB',     'Barbados',               'BB', true),
  ('CA-FED', 'Canada Federal',         'CA', true),
  ('US-FED', 'United States Federal',  'US', true),
  ('US-GA',  'Georgia',                'US', true),
  ('US-NY',  'New York',               'US', true),
  ('US-CA',  'California',             'US', true);


-- =============================================================
-- TAX FILING STATUS
-- Seeded for jurisdictions that differentiate by filing status.
-- Barbados and Canada Federal do not use filing status.
-- =============================================================

-- US Federal filing statuses
INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-FED'), 'SINGLE', 'Single or Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-FED'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-FED'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-FED'), 'HOH',    'Head of Household');

-- Georgia filing statuses
INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-GA'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-GA'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-GA'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-GA'), 'HOH',    'Head of Household');

-- New York State filing statuses
INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'HOH',    'Head of Household');

-- California filing statuses
INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CA'), 'SINGLE', 'Single or Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CA'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CA'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CA'), 'HOH',    'Head of Household');


-- =============================================================
-- PAYROLL CALCULATION STEPS
-- =============================================================

-- -------------------------------------------------------------
-- Barbados (BB)
-- -------------------------------------------------------------
INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'BB'), 'BB_INCOME_TAX',      'Barbados Income Tax',      'PROGRESSIVE_BRACKET', 'INCOME_TAX',       310, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'BB'), 'BB_NIS',             'National Insurance (NIS)', 'TIERED_FLAT',         'SOCIAL_INSURANCE',  510, 'BOTH',     'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'BB'), 'BB_RESILIENCE_FUND', 'Barbados Resilience Fund', 'FLAT_RATE',           'SOCIAL_INSURANCE',  520, 'EMPLOYEE', 'ACTIVE', true);

-- -------------------------------------------------------------
-- Canada Federal (CA-FED)
-- -------------------------------------------------------------
INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'CA-FED'), 'CA_FED_INCOME_TAX',  'Canada Federal Income Tax',    'PROGRESSIVE_BRACKET', 'INCOME_TAX',           300, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'CA-FED'), 'CA_FED_BPA_CREDIT',  'Basic Personal Amount Credit', 'CREDIT',              'CREDIT',               410, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'CA-FED'), 'CA_FED_CPP',         'Canada Pension Plan (CPP)',    'TIERED_FLAT',         'SOCIAL_INSURANCE',     500, 'BOTH',     'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'CA-FED'), 'CA_FED_CPP2',        'Canada Pension Plan 2 (CPP2)', 'TIERED_FLAT',         'SOCIAL_INSURANCE',     501, 'BOTH',     'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'CA-FED'), 'CA_FED_EI',          'Employment Insurance (EI)',    'FLAT_RATE',           'SOCIAL_INSURANCE',     505, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'CA-FED'), 'CA_FED_EI_ER',       'Employment Insurance Employer','FLAT_RATE',           'EMPLOYER_CONTRIBUTION',905, 'EMPLOYER', 'ACTIVE', true);

-- -------------------------------------------------------------
-- US Federal (US-FED)
-- -------------------------------------------------------------
INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-FED'), 'US_FED_INCOME_TAX',    'US Federal Income Tax',                  'PROGRESSIVE_BRACKET', 'INCOME_TAX',       300, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-FED'), 'US_FED_SS',            'Social Security (OASDI)',                'FLAT_RATE',           'SOCIAL_INSURANCE', 510, 'BOTH',     'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-FED'), 'US_FED_MEDICARE',      'Medicare (HI)',                          'FLAT_RATE',           'SOCIAL_INSURANCE', 511, 'BOTH',     'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-FED'), 'US_FED_MEDICARE_ADDL', 'Additional Medicare (0.9% above $200K)', 'FLAT_RATE',           'SOCIAL_INSURANCE', 512, 'EMPLOYEE', 'ACTIVE', true);

-- -------------------------------------------------------------
-- Georgia (US-GA)
-- NOTE: GA_INCOME_TAX rate is revenue-trigger-conditional.
--   Published annually by Georgia DOR in October-November.
--   Verify and update this seed before December 15 each year.
-- -------------------------------------------------------------
INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-GA'), 'US_GA_STD_DEDUCTION', 'Georgia Standard Deduction', 'STANDARD_DEDUCTION', 'DEDUCTION_ALLOWANCE', 210, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-GA'), 'US_GA_INCOME_TAX',    'Georgia Income Tax (Flat)',   'FLAT_RATE',          'SUBNATIONAL_TAX',     600, 'EMPLOYEE', 'ACTIVE', true);

-- -------------------------------------------------------------
-- New York (US-NY)
-- US_NY_CITY_INCOME applies only to NYC residents (IsResident flag on CalculationContext)
-- US_NY_YONKERS is PERCENTAGE_OF_PRIOR reading US_NY_STATE_INCOME result
-- -------------------------------------------------------------
INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'US_NY_STATE_INCOME', 'New York State Income Tax',                'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX',  610, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'US_NY_CITY_INCOME',  'New York City Income Tax',                 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX',  620, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'US_NY_YONKERS',      'Yonkers Income Tax Surcharge',             'PERCENTAGE_OF_PRIOR', 'DERIVED_TAX',      710, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'US_NY_MCTMT',        'Metropolitan Commuter Transportation Tax', 'FLAT_RATE',           'DERIVED_TAX',      720, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'US_NY_SDI',          'NY State Disability Insurance',            'FLAT_RATE',           'SOCIAL_INSURANCE', 730, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NY'), 'US_NY_PFL',          'NY Paid Family Leave',                     'FLAT_RATE',           'SOCIAL_INSURANCE', 740, 'EMPLOYEE', 'ACTIVE', true);

-- -------------------------------------------------------------
-- California (US-CA)
-- US_CA_MENTAL_HEALTH applies only above $1,000,000 annual income
-- US_CA_SDI is uncapped as of 2024 SB 951
-- -------------------------------------------------------------
INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CA'), 'US_CA_INCOME_TAX',    'California Income Tax',             'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX',  600, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CA'), 'US_CA_MENTAL_HEALTH', 'CA Mental Health Services Tax (1%)', 'FLAT_RATE',           'SUBNATIONAL_TAX',  601, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CA'), 'US_CA_SDI',           'CA State Disability Insurance',     'FLAT_RATE',           'SOCIAL_INSURANCE', 730, 'EMPLOYEE', 'ACTIVE', true);


-- =============================================================
-- TAX BRACKETS — 2025
-- Verify all figures against official publications before use.
-- =============================================================

-- -------------------------------------------------------------
-- Barbados Income Tax 2025 — no filing status differentiation
-- Source: Barbados Revenue Authority
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('BB_INCOME_TAX', NULL, '2025-01-01', NULL,  0.0000,    50000.0000, 0.125000),
  ('BB_INCOME_TAX', NULL, '2025-01-01', NULL, 50000.0000, NULL,       0.285000);

-- -------------------------------------------------------------
-- Canada Federal Income Tax 2025
-- Source: CRA T4032 — verify indexation amounts each October
-- 2026: Bottom bracket rate reduces to 14% per 2024 Budget
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('CA_FED_INCOME_TAX', NULL, '2025-01-01', '2025-12-31',   0.0000,     57375.0000,  0.150000),
  ('CA_FED_INCOME_TAX', NULL, '2025-01-01', '2025-12-31',  57375.0000, 114750.0000,  0.205000),
  ('CA_FED_INCOME_TAX', NULL, '2025-01-01', '2025-12-31', 114750.0000, 158519.0000,  0.260000),
  ('CA_FED_INCOME_TAX', NULL, '2025-01-01', '2025-12-31', 158519.0000, 220000.0000,  0.290000),
  ('CA_FED_INCOME_TAX', NULL, '2025-01-01', '2025-12-31', 220000.0000, NULL,         0.330000);

-- Canada Federal 2026 — verify bracket thresholds via CRA indexation announcement
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('CA_FED_INCOME_TAX', NULL, '2026-01-01', NULL,   0.0000,     57375.0000,  0.140000),  -- 14% per 2024 Budget; verify threshold
  ('CA_FED_INCOME_TAX', NULL, '2026-01-01', NULL,  57375.0000, 114750.0000,  0.205000),
  ('CA_FED_INCOME_TAX', NULL, '2026-01-01', NULL, 114750.0000, 158519.0000,  0.260000),
  ('CA_FED_INCOME_TAX', NULL, '2026-01-01', NULL, 158519.0000, 220000.0000,  0.290000),
  ('CA_FED_INCOME_TAX', NULL, '2026-01-01', NULL, 220000.0000, NULL,         0.330000);

-- -------------------------------------------------------------
-- US Federal Income Tax 2025
-- Source: IRS Rev. Proc. 2024-40
-- Four filing statuses: SINGLE, MFJ, MFS, HOH
-- -------------------------------------------------------------

-- SINGLE
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_FED_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,      0.0000,    11925.0000,  0.100000),
  ('US_FED_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  11925.0000,    48475.0000,  0.120000),
  ('US_FED_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  48475.0000,   103350.0000,  0.220000),
  ('US_FED_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 103350.0000,   197300.0000,  0.240000),
  ('US_FED_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 197300.0000,   250525.0000,  0.320000),
  ('US_FED_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 250525.0000,   626350.0000,  0.350000),
  ('US_FED_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 626350.0000,   NULL,         0.370000);

-- MFJ
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_FED_INCOME_TAX', 'MFJ', '2025-01-01', NULL,      0.0000,    23850.0000,  0.100000),
  ('US_FED_INCOME_TAX', 'MFJ', '2025-01-01', NULL,  23850.0000,    96950.0000,  0.120000),
  ('US_FED_INCOME_TAX', 'MFJ', '2025-01-01', NULL,  96950.0000,   206700.0000,  0.220000),
  ('US_FED_INCOME_TAX', 'MFJ', '2025-01-01', NULL, 206700.0000,   394600.0000,  0.240000),
  ('US_FED_INCOME_TAX', 'MFJ', '2025-01-01', NULL, 394600.0000,   501050.0000,  0.320000),
  ('US_FED_INCOME_TAX', 'MFJ', '2025-01-01', NULL, 501050.0000,   751600.0000,  0.350000),
  ('US_FED_INCOME_TAX', 'MFJ', '2025-01-01', NULL, 751600.0000,   NULL,         0.370000);

-- MFS
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_FED_INCOME_TAX', 'MFS', '2025-01-01', NULL,      0.0000,    11925.0000,  0.100000),
  ('US_FED_INCOME_TAX', 'MFS', '2025-01-01', NULL,  11925.0000,    48475.0000,  0.120000),
  ('US_FED_INCOME_TAX', 'MFS', '2025-01-01', NULL,  48475.0000,   103350.0000,  0.220000),
  ('US_FED_INCOME_TAX', 'MFS', '2025-01-01', NULL, 103350.0000,   197300.0000,  0.240000),
  ('US_FED_INCOME_TAX', 'MFS', '2025-01-01', NULL, 197300.0000,   250525.0000,  0.320000),
  ('US_FED_INCOME_TAX', 'MFS', '2025-01-01', NULL, 250525.0000,   375800.0000,  0.350000),
  ('US_FED_INCOME_TAX', 'MFS', '2025-01-01', NULL, 375800.0000,   NULL,         0.370000);

-- HOH
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_FED_INCOME_TAX', 'HOH', '2025-01-01', NULL,      0.0000,    17000.0000,  0.100000),
  ('US_FED_INCOME_TAX', 'HOH', '2025-01-01', NULL,  17000.0000,    64850.0000,  0.120000),
  ('US_FED_INCOME_TAX', 'HOH', '2025-01-01', NULL,  64850.0000,   103350.0000,  0.220000),
  ('US_FED_INCOME_TAX', 'HOH', '2025-01-01', NULL, 103350.0000,   197300.0000,  0.240000),
  ('US_FED_INCOME_TAX', 'HOH', '2025-01-01', NULL, 197300.0000,   250500.0000,  0.320000),
  ('US_FED_INCOME_TAX', 'HOH', '2025-01-01', NULL, 250500.0000,   626350.0000,  0.350000),
  ('US_FED_INCOME_TAX', 'HOH', '2025-01-01', NULL, 626350.0000,   NULL,         0.370000);

-- -------------------------------------------------------------
-- New York State Income Tax 2025 — SINGLE
-- Source: NYS DTF Publication NYS-50-T-NYS
-- MFJ, MFS, HOH: verify thresholds from NYS-50 before adding
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_NY_STATE_INCOME', 'SINGLE', '2025-01-01', NULL,         0.0000,     17150.0000, 0.040000),
  ('US_NY_STATE_INCOME', 'SINGLE', '2025-01-01', NULL,     17150.0000,     23600.0000, 0.045000),
  ('US_NY_STATE_INCOME', 'SINGLE', '2025-01-01', NULL,     23600.0000,     27900.0000, 0.052500),
  ('US_NY_STATE_INCOME', 'SINGLE', '2025-01-01', NULL,     27900.0000,    161550.0000, 0.058500),
  ('US_NY_STATE_INCOME', 'SINGLE', '2025-01-01', NULL,    161550.0000,    323200.0000, 0.062500),
  ('US_NY_STATE_INCOME', 'SINGLE', '2025-01-01', NULL,    323200.0000,   2155350.0000, 0.068500),
  ('US_NY_STATE_INCOME', 'SINGLE', '2025-01-01', NULL,   2155350.0000,   5000000.0000, 0.096500),
  ('US_NY_STATE_INCOME', 'SINGLE', '2025-01-01', NULL,   5000000.0000,  25000000.0000, 0.103000),
  ('US_NY_STATE_INCOME', 'SINGLE', '2025-01-01', NULL,  25000000.0000,  NULL,          0.109000);

-- New York City Income Tax 2025 — SINGLE (NYC residents only)
-- Source: NYC Finance — verify MFJ/HOH from NYC Finance tables
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_NY_CITY_INCOME', 'SINGLE', '2025-01-01', NULL,     0.0000,   12000.0000, 0.030780),
  ('US_NY_CITY_INCOME', 'SINGLE', '2025-01-01', NULL, 12000.0000,   25000.0000, 0.037620),
  ('US_NY_CITY_INCOME', 'SINGLE', '2025-01-01', NULL, 25000.0000,   50000.0000, 0.038190),
  ('US_NY_CITY_INCOME', 'SINGLE', '2025-01-01', NULL, 50000.0000,   NULL,       0.038760);

-- -------------------------------------------------------------
-- California Income Tax 2025 — SINGLE
-- Source: FTB Publication DE 44
-- MFJ/MFS/HOH: verify from DE 44 tables before adding
-- Mental Health surtax (1% above $1M) handled by US_CA_MENTAL_HEALTH flat rate
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_CA_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,      0.0000,    10756.0000, 0.010000),
  ('US_CA_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  10756.0000,    25499.0000, 0.020000),
  ('US_CA_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  25499.0000,    40245.0000, 0.040000),
  ('US_CA_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  40245.0000,    55866.0000, 0.060000),
  ('US_CA_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  55866.0000,    70606.0000, 0.080000),
  ('US_CA_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  70606.0000,   360659.0000, 0.093000),
  ('US_CA_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 360659.0000,   432787.0000, 0.103000),
  ('US_CA_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 432787.0000,   721314.0000, 0.113000),
  ('US_CA_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 721314.0000,   NULL,        0.123000);


-- =============================================================
-- TAX FLAT RATES — 2025
-- =============================================================

-- -------------------------------------------------------------
-- Barbados Resilience Fund — 0.3%, no cap
-- -------------------------------------------------------------
INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES
  ('BB_RESILIENCE_FUND', '2025-01-01', NULL, 0.003000, NULL, NULL, NULL, NULL);

-- -------------------------------------------------------------
-- Canada EI — employee 1.66%, annual cap CAD 1,049.12
-- Source: ESDC EI premium rates table (verify each October)
-- -------------------------------------------------------------
INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES
  ('CA_FED_EI',    '2025-01-01', NULL, 0.016600, 63200.0000, NULL, 1049.12, NULL),
  ('CA_FED_EI_ER', '2025-01-01', NULL, 0.023240, 63200.0000, NULL, 1468.77, NULL);  -- 1.4 × employee rate

-- -------------------------------------------------------------
-- US Federal — SS, Medicare, Additional Medicare
-- Source: IRS Rev. Proc. 2024-40
-- SS wage base $176,100 for 2025 — verify annually (indexed to AWI)
-- Additional Medicare: 0.9% on wages above $200,000 annual threshold
-- -------------------------------------------------------------
INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES
  ('US_FED_SS',            '2025-01-01', NULL, 0.062000, 176100.0000, NULL, NULL, NULL),
  ('US_FED_MEDICARE',      '2025-01-01', NULL, 0.014500, NULL,        NULL, NULL, NULL),
  ('US_FED_MEDICARE_ADDL', '2025-01-01', NULL, 0.009000, NULL,        NULL, NULL, NULL);  -- threshold applied in FlatRateStep via AnnualizedGross check

-- -------------------------------------------------------------
-- Georgia Income Tax — flat rate
-- NOTE: 2025 rate is 5.19%. 2026 rate subject to revenue trigger.
-- Georgia DOR publishes confirmed rate October-November each year.
-- Update effective_to on the 2025 row and insert a 2026 row
-- after DOR confirmation, before December 15 deployment deadline.
-- -------------------------------------------------------------
INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES
  ('US_GA_INCOME_TAX', '2025-01-01', '2025-12-31', 0.051900, NULL, NULL, NULL, NULL);
-- 2026 row: INSERT after DOR confirmation (target: October-November 2025)
-- ('US_GA_INCOME_TAX', '2026-01-01', NULL, 0.050900, NULL, NULL, NULL, NULL);  -- 5.09% if revenue trigger met

-- -------------------------------------------------------------
-- New York MCTMT — 0.34%, no cap
-- New York SDI — 0.5%, period cap $0.60/week ($1.20 bi-weekly)
-- New York PFL — 0.388%, annual cap $411.91 (2025)
-- Source: NYS DTF, NY Workers' Comp Board
-- Yonkers surcharge — 16.75% of NY state income tax
-- -------------------------------------------------------------
INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES
  ('US_NY_MCTMT',   '2025-01-01', NULL, 0.003400, NULL, NULL,   NULL,   NULL),
  ('US_NY_SDI',     '2025-01-01', NULL, 0.005000, NULL, 0.60,   NULL,   NULL),   -- $0.60/week period cap; seeded for weekly; bi-weekly cap applied by CalculationEngine
  ('US_NY_PFL',     '2025-01-01', NULL, 0.003880, NULL, NULL,   411.91, NULL),
  ('US_NY_YONKERS', '2025-01-01', NULL, 0.167500, NULL, NULL,   NULL,   'US_NY_STATE_INCOME');

-- -------------------------------------------------------------
-- California SDI — 1.1%, uncapped (SB 951, effective 2024)
-- California Mental Health surtax — 1% on income above $1,000,000
-- Source: EDD (SDI rate verified annually)
-- -------------------------------------------------------------
INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES
  ('US_CA_SDI',           '2025-01-01', NULL, 0.011000, NULL,          NULL, NULL, NULL),
  ('US_CA_MENTAL_HEALTH', '2025-01-01', NULL, 0.010000, NULL,          NULL, NULL, NULL);  -- wage_base threshold ($1M annual) applied in FlatRateStep


-- =============================================================
-- TAX TIERED BRACKETS — 2025
-- =============================================================

-- -------------------------------------------------------------
-- Barbados NIS 2025
-- 11% on earnings from $0 to $63,360 annual; max $6,969.60/year
-- Source: National Insurance Department — verify thresholds annually
-- NIS applies to both employee and employer (BOTH)
-- -------------------------------------------------------------
INSERT INTO tax_tiered_brackets (step_code, effective_from, effective_to, lower_limit, upper_limit, rate, period_cap_amount, annual_cap_amount) VALUES
  ('BB_NIS', '2025-01-01', NULL, 0.0000, 63360.0000, 0.110000, NULL, 6969.6000);

-- -------------------------------------------------------------
-- Canada CPP 2025
-- CPP:  5.95% on earnings from $3,500 (YBE) to $71,300 (YMPE)
-- CPP2: 4.00% on earnings from $71,300 (YMPE) to $81,900 (YAMPE)
-- Source: CRA — verify YMPE/YAMPE each November
-- -------------------------------------------------------------
INSERT INTO tax_tiered_brackets (step_code, effective_from, effective_to, lower_limit, upper_limit, rate, period_cap_amount, annual_cap_amount) VALUES
  ('CA_FED_CPP',  '2025-01-01', NULL,  3500.0000,  71300.0000, 0.059500, NULL, 4034.10),  -- (71300-3500) × 5.95%
  ('CA_FED_CPP2', '2025-01-01', NULL, 71300.0000,  81900.0000, 0.040000, NULL,  424.00);  -- (81900-71300) × 4%


-- =============================================================
-- TAX ALLOWANCES — 2025
-- =============================================================

-- -------------------------------------------------------------
-- Georgia Standard Deduction 2025
-- Single/MFS/HOH: $5,400; MFJ: $7,100
-- Source: Georgia Form 500 instructions
-- -------------------------------------------------------------
INSERT INTO tax_allowances (step_code, filing_status_code, effective_from, effective_to, annual_amount) VALUES
  ('US_GA_STD_DEDUCTION', 'SINGLE', '2025-01-01', NULL, 5400.0000),
  ('US_GA_STD_DEDUCTION', 'MFJ',    '2025-01-01', NULL, 7100.0000),
  ('US_GA_STD_DEDUCTION', 'MFS',    '2025-01-01', NULL, 5400.0000),
  ('US_GA_STD_DEDUCTION', 'HOH',    '2025-01-01', NULL, 5400.0000);


-- =============================================================
-- TAX CREDITS — 2025
-- =============================================================

-- -------------------------------------------------------------
-- Canada BPA (Basic Personal Amount) Credit 2025
-- Annual BPA: CAD 16,129 × 15% = CAD 2,419.35 annual credit
-- Source: CRA — BPA indexed annually; verify each October
-- 2026: BPA amount will be re-indexed; update effective_to and
--   insert a 2026 row after CRA publishes November indexation.
-- -------------------------------------------------------------
INSERT INTO tax_credits (step_code, effective_from, effective_to, annual_amount, credit_rate, is_refundable) VALUES
  ('CA_FED_BPA_CREDIT', '2025-01-01', NULL, 16129.0000, 0.150000, false);


-- =============================================================
-- US STATE JURISDICTION STUBS — Phase 5.9 Survey (2026-05-02)
-- =============================================================
-- All 50 US states + DC are assigned to a coverage category in
-- SPEC/Payroll_Calculation_Pipeline.md §15.  The six Phase 5
-- gate jurisdictions (US-FED, US-GA, US-NY, US-CA, BB, CA-FED)
-- are fully seeded above.  The remaining 47 entries below
-- establish the jurisdiction record and — for Category A+/B
-- states — the minimal step and rate rows needed to confirm the
-- calculation model.  Category A (no income tax) and Category C
-- (simple allowance form) states carry no steps here; steps will
-- be added when those jurisdictions are brought into scope.
--
-- Scope decisions for local-tax overlay jurisdictions:
--   Indiana county taxes  — deferred (92 counties; local tax phase)
--   Maryland county taxes — deferred (24 jurisdictions; local tax phase)
--   Ohio municipal taxes  — deferred (600+ jurisdictions; local tax phase)
--   Pennsylvania local EIT— deferred (2,600+ municipalities; local tax phase)
-- =============================================================


-- -------------------------------------------------------------
-- JURISDICTION ROWS — US states not already seeded
-- Ordered alphabetically by state name.
-- -------------------------------------------------------------
INSERT INTO tax_jurisdiction (jurisdiction_code, jurisdiction_name, country_code, is_active) VALUES
  ('US-AL', 'Alabama',              'US', true),
  ('US-AK', 'Alaska',               'US', true),
  ('US-AZ', 'Arizona',              'US', true),
  ('US-AR', 'Arkansas',             'US', true),
  ('US-CO', 'Colorado',             'US', true),
  ('US-CT', 'Connecticut',          'US', true),
  ('US-DE', 'Delaware',             'US', true),
  ('US-DC', 'District of Columbia', 'US', true),
  ('US-FL', 'Florida',              'US', true),
  ('US-HI', 'Hawaii',               'US', true),
  ('US-ID', 'Idaho',                'US', true),
  ('US-IL', 'Illinois',             'US', true),
  ('US-IN', 'Indiana',              'US', true),
  ('US-IA', 'Iowa',                 'US', true),
  ('US-KS', 'Kansas',               'US', true),
  ('US-KY', 'Kentucky',             'US', true),
  ('US-LA', 'Louisiana',            'US', true),
  ('US-ME', 'Maine',                'US', true),
  ('US-MD', 'Maryland',             'US', true),
  ('US-MA', 'Massachusetts',        'US', true),
  ('US-MI', 'Michigan',             'US', true),
  ('US-MN', 'Minnesota',            'US', true),
  ('US-MS', 'Mississippi',          'US', true),
  ('US-MO', 'Missouri',             'US', true),
  ('US-MT', 'Montana',              'US', true),
  ('US-NE', 'Nebraska',             'US', true),
  ('US-NV', 'Nevada',               'US', true),
  ('US-NH', 'New Hampshire',        'US', true),
  ('US-NJ', 'New Jersey',           'US', true),
  ('US-NM', 'New Mexico',           'US', true),
  ('US-NC', 'North Carolina',       'US', true),
  ('US-ND', 'North Dakota',         'US', true),
  ('US-OH', 'Ohio',                 'US', true),
  ('US-OK', 'Oklahoma',             'US', true),
  ('US-OR', 'Oregon',               'US', true),
  ('US-PA', 'Pennsylvania',         'US', true),
  ('US-RI', 'Rhode Island',         'US', true),
  ('US-SC', 'South Carolina',       'US', true),
  ('US-SD', 'South Dakota',         'US', true),
  ('US-TN', 'Tennessee',            'US', true),
  ('US-TX', 'Texas',                'US', true),
  ('US-UT', 'Utah',                 'US', true),
  ('US-VT', 'Vermont',              'US', true),
  ('US-VA', 'Virginia',             'US', true),
  ('US-WA', 'Washington',           'US', true),
  ('US-WV', 'West Virginia',        'US', true),
  ('US-WI', 'Wisconsin',            'US', true),
  ('US-WY', 'Wyoming',              'US', true);


-- -------------------------------------------------------------
-- CATEGORY B — Flat rate, no form
-- Kentucky: flat 4.5% (effective 2023; verify annually)
-- Pennsylvania: flat 3.07%; no state withholding certificate
-- Source: KY DOR; PA DOR
-- -------------------------------------------------------------
INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-KY'),
   'US_KY_INCOME_TAX', 'Kentucky Income Tax (Flat)',     'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-PA'),
   'US_PA_INCOME_TAX', 'Pennsylvania Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true);

INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES
  ('US_KY_INCOME_TAX', '2023-01-01', NULL, 0.045000, NULL, NULL, NULL, NULL),  -- 4.5%; verify annually
  ('US_PA_INCOME_TAX', '2004-01-01', NULL, 0.030700, NULL, NULL, NULL, NULL);  -- 3.07%; stable since 2004; verify annually


-- -------------------------------------------------------------
-- CATEGORY A+ — Payroll levy, no income tax
-- Washington WA Cares LTC Fund: 0.58%, annual cap $1,542 (2025)
-- Source: WA Cares Fund (https://wacaresfund.wa.gov)
-- Verify rate and cap each year — both are subject to adjustment.
-- Employees may file for exemption; exempt_flag on submission row
-- skips this step (handled by FlatRateStep exempt check).
-- 2026 rate and cap: update effective_to on 2025 row and insert
-- a 2026 row after WA Cares Fund publishes the annual adjustment.
-- -------------------------------------------------------------
INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-WA'),
   'US_WA_CARES', 'Washington WA Cares LTC Fund', 'FLAT_RATE', 'SOCIAL_INSURANCE', 730, 'EMPLOYEE', 'ACTIVE', true);

INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES
  ('US_WA_CARES', '2025-01-01', '2025-12-31', 0.005800, NULL, NULL, 1542.00, NULL);
-- 2026 row: INSERT after WA Cares Fund publishes annual rate (typically October)
-- ('US_WA_CARES', '2026-01-01', NULL, 0.005800, NULL, NULL, <2026_cap>, NULL);


-- =============================================================
-- END US STATE STUBS
-- =============================================================
