-- =============================================================
-- US State Income Tax — Seed Data (2025 rates)
-- Adds payroll_calculation_steps and rate rows for the 45 US
-- state/DC jurisdictions whose jurisdiction rows were established
-- at the bottom of tax_pipeline_seed_data.sql.
--
-- Already handled in tax_pipeline_seed_data.sql:
--   US-CA  California (fully seeded)
--   US-GA  Georgia (fully seeded)
--   US-NY  New York (fully seeded)
--   US-KY  Kentucky (stub step seeded)
--   US-PA  Pennsylvania (stub step seeded)
--   US-WA  Washington (WA Cares LTC step seeded; no income tax)
--
-- No income tax — jurisdiction rows exist; NO steps needed:
--   US-AK  Alaska
--   US-FL  Florida
--   US-NH  New Hampshire  (interest/dividend tax repealed 2025)
--   US-NV  Nevada
--   US-SD  South Dakota
--   US-TN  Tennessee      (Hall income tax repealed 2021)
--   US-TX  Texas
--   US-WY  Wyoming
--
-- CRITICAL: All rates must be verified against official state DOR
-- publications BEFORE December 15 deployment each year.
-- ACH pre-funding means Jan 1 pay dates may run December 26.
--
-- Verification sources per state are noted inline.
-- Rates marked -- VERIFY are best estimates from training data
-- through August 2025; confirm from primary source before use.
--
-- Filing status: NULL = applies to all filing statuses.
-- Where MFJ thresholds differ materially they are noted.
-- Full per-filing-status bracket rows should be added before
-- production deployment for any state in scope.
--
-- Local/county taxes are explicitly deferred:
--   Indiana county taxes  (92 counties)
--   Maryland county taxes (24 jurisdictions)
--   Ohio municipal taxes  (600+ jurisdictions)
--   Pennsylvania local EIT (2,600+ municipalities)
-- =============================================================


-- =============================================================
-- FILING STATUS — states with progressive income tax
-- =============================================================

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-AL'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-AL'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-AL'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-AL'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CT'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CT'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CT'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CT'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-DE'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-DE'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-DE'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-DE'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-HI'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-HI'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-HI'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-HI'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-ME'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-ME'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-ME'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-ME'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MD'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MD'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MD'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MD'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MN'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MN'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MN'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MN'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MT'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MT'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MT'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MT'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NJ'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NJ'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NJ'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NJ'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NM'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NM'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NM'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NM'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OK'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OK'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OK'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OK'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OR'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OR'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OR'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OR'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-RI'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-RI'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-RI'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-RI'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VT'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VT'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VT'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VT'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VA'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VA'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VA'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VA'), 'HOH',    'Head of Household');

INSERT INTO tax_filing_status (jurisdiction_id, filing_status_code, filing_status_name) VALUES
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-WI'), 'SINGLE', 'Single'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-WI'), 'MFJ',    'Married Filing Jointly'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-WI'), 'MFS',    'Married Filing Separately'),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-WI'), 'HOH',    'Head of Household');


-- =============================================================
-- PAYROLL CALCULATION STEPS
-- All state income tax steps use:
--   sequence_number 600   (SUBNATIONAL_TAX income tax)
--   sequence_number 210   (DEDUCTION_ALLOWANCE standard deduction)
-- These sequences are safe to reuse across jurisdictions because
-- the pipeline filters steps by jurisdiction_code for each employee.
-- =============================================================


-- -------------------------------------------------------------
-- FLAT RATE STATES
-- -------------------------------------------------------------

INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES

  -- Arizona: 2.5% flat (effective 2023 — SB 1828/HB 2900 reconciliation)
  -- Source: AZ DOR — VERIFY annually
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-AZ'),
   'US_AZ_INCOME_TAX', 'Arizona Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Arkansas: simplified progressive; top rate 3.9% (2024)
  -- Source: AR DOR — VERIFY: rate reduces each year under Act 532 of 2023
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-AR'),
   'US_AR_INCOME_TAX', 'Arkansas Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Colorado: 4.4% flat (reduced from 4.55% in 2022)
  -- Source: CO DOR — VERIFY: subject to TABOR revenue trigger reductions
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CO'),
   'US_CO_INCOME_TAX', 'Colorado Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Idaho: 5.8% flat (simplified 2023 — HB 1 signed Jan 2023)
  -- Source: ID State Tax Commission — VERIFY annually
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-ID'),
   'US_ID_INCOME_TAX', 'Idaho Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Illinois: 4.95% flat (constitutional; unchanged since 2017)
  -- Source: IL DOR
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-IL'),
   'US_IL_INCOME_TAX', 'Illinois Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Indiana: 3.05% flat (2024); reducing to 3.00% (2025) under HEA 1001
  -- Source: IN DOR — VERIFY: rate reduces each year per schedule
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-IN'),
   'US_IN_INCOME_TAX', 'Indiana Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Iowa: flat rate (transitional; 4.82% for 2024; reducing per HF 2317)
  -- Source: IA DOR — VERIFY: rate reduces each year; check DOR publication
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-IA'),
   'US_IA_INCOME_TAX', 'Iowa Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Louisiana: 3.0% flat (effective 2025 — special session HB 2/SB 1 Nov 2024)
  -- Source: LA DOR — VERIFY: confirm effective date and rate
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-LA'),
   'US_LA_INCOME_TAX', 'Louisiana Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Massachusetts: 5.0% flat (base rate; 4% surtax on income > $1M not modeled here)
  -- Source: MA DOR — VERIFY annually
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MA'),
   'US_MA_INCOME_TAX', 'Massachusetts Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Michigan: 4.25% flat
  -- Source: MI Treasury — VERIFY: rate was temporarily reduced for 2023; confirm restoration
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MI'),
   'US_MI_INCOME_TAX', 'Michigan Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Mississippi: 4.4% flat (2025); reducing under HB 531 toward 4.0% by 2026
  -- Source: MS DOR — VERIFY: rate reduces each year
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MS'),
   'US_MS_INCOME_TAX', 'Mississippi Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- North Carolina: 4.25% flat (2025); reducing further under SL 2023-134
  -- Source: NC DOR — VERIFY: rate reduces each year
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NC'),
   'US_NC_INCOME_TAX', 'North Carolina Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- North Dakota: 2.5% flat (effective 2023 — HB 1158; zero bracket for lower incomes)
  -- Source: ND Office of State Tax Commissioner — VERIFY annually
  -- NOTE: single filers below ~$44,250 effectively pay 0% under ND law; model via
  -- employee standard deduction / personal exemption claim on ND withholding form.
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-ND'),
   'US_ND_INCOME_TAX', 'North Dakota Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Utah: 4.55% flat
  -- Source: UT Tax Commission — VERIFY annually
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-UT'),
   'US_UT_INCOME_TAX', 'Utah Income Tax (Flat)', 'FLAT_RATE', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true);


-- -------------------------------------------------------------
-- PROGRESSIVE / BRACKET STATES (steps)
-- -------------------------------------------------------------

INSERT INTO payroll_calculation_steps
  (jurisdiction_id, step_code, step_name, step_type, calculation_category, sequence_number, applies_to, status_code, is_active)
VALUES

  -- Alabama
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-AL'),
   'US_AL_STD_DEDUCTION', 'Alabama Standard Deduction', 'STANDARD_DEDUCTION', 'DEDUCTION_ALLOWANCE', 210, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-AL'),
   'US_AL_INCOME_TAX', 'Alabama Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Connecticut
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-CT'),
   'US_CT_INCOME_TAX', 'Connecticut Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Delaware
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-DE'),
   'US_DE_STD_DEDUCTION', 'Delaware Standard Deduction', 'STANDARD_DEDUCTION', 'DEDUCTION_ALLOWANCE', 210, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-DE'),
   'US_DE_INCOME_TAX', 'Delaware Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- District of Columbia
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-DC'),
   'US_DC_INCOME_TAX', 'District of Columbia Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Hawaii
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-HI'),
   'US_HI_STD_DEDUCTION', 'Hawaii Standard Deduction', 'STANDARD_DEDUCTION', 'DEDUCTION_ALLOWANCE', 210, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-HI'),
   'US_HI_INCOME_TAX', 'Hawaii Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Kansas
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-KS'),
   'US_KS_INCOME_TAX', 'Kansas Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Maine
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-ME'),
   'US_ME_STD_DEDUCTION', 'Maine Standard Deduction', 'STANDARD_DEDUCTION', 'DEDUCTION_ALLOWANCE', 210, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-ME'),
   'US_ME_INCOME_TAX', 'Maine Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Maryland (state brackets only; county tax deferred)
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MD'),
   'US_MD_STD_DEDUCTION', 'Maryland Standard Deduction', 'STANDARD_DEDUCTION', 'DEDUCTION_ALLOWANCE', 210, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MD'),
   'US_MD_INCOME_TAX', 'Maryland Income Tax (State)', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Minnesota
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MN'),
   'US_MN_INCOME_TAX', 'Minnesota Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Missouri
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MO'),
   'US_MO_INCOME_TAX', 'Missouri Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Montana
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-MT'),
   'US_MT_INCOME_TAX', 'Montana Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Nebraska
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NE'),
   'US_NE_INCOME_TAX', 'Nebraska Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- New Jersey
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NJ'),
   'US_NJ_INCOME_TAX', 'New Jersey Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- New Mexico
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-NM'),
   'US_NM_INCOME_TAX', 'New Mexico Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Ohio
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OH'),
   'US_OH_INCOME_TAX', 'Ohio Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Oklahoma
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OK'),
   'US_OK_INCOME_TAX', 'Oklahoma Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Oregon
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OR'),
   'US_OR_STD_DEDUCTION', 'Oregon Standard Deduction', 'STANDARD_DEDUCTION', 'DEDUCTION_ALLOWANCE', 210, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-OR'),
   'US_OR_INCOME_TAX', 'Oregon Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Rhode Island
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-RI'),
   'US_RI_INCOME_TAX', 'Rhode Island Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- South Carolina
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-SC'),
   'US_SC_INCOME_TAX', 'South Carolina Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Vermont
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VT'),
   'US_VT_INCOME_TAX', 'Vermont Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Virginia
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VA'),
   'US_VA_STD_DEDUCTION', 'Virginia Standard Deduction', 'STANDARD_DEDUCTION', 'DEDUCTION_ALLOWANCE', 210, 'EMPLOYEE', 'ACTIVE', true),
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-VA'),
   'US_VA_INCOME_TAX', 'Virginia Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- West Virginia
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-WV'),
   'US_WV_INCOME_TAX', 'West Virginia Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true),

  -- Wisconsin
  ((SELECT jurisdiction_id FROM tax_jurisdiction WHERE jurisdiction_code = 'US-WI'),
   'US_WI_INCOME_TAX', 'Wisconsin Income Tax', 'PROGRESSIVE_BRACKET', 'SUBNATIONAL_TAX', 600, 'EMPLOYEE', 'ACTIVE', true);


-- =============================================================
-- FLAT RATES
-- =============================================================

INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES

  -- Arizona 2.5% (effective 2023)
  -- Source: AZ DOR — VERIFY annually
  ('US_AZ_INCOME_TAX', '2023-01-01', NULL, 0.025000, NULL, NULL, NULL, NULL),

  -- Colorado 4.4% (effective 2024; was 4.55% previously)
  -- Source: CO DOR — VERIFY: TABOR surplus may trigger further reductions
  ('US_CO_INCOME_TAX', '2024-01-01', NULL, 0.044000, NULL, NULL, NULL, NULL),

  -- Idaho 5.8% flat (effective 2023 — HB 1)
  -- Source: ID State Tax Commission — VERIFY annually
  ('US_ID_INCOME_TAX', '2023-01-01', NULL, 0.058000, NULL, NULL, NULL, NULL),

  -- Illinois 4.95% (constitutional flat tax; no change since 2017)
  -- Source: IL DOR
  ('US_IL_INCOME_TAX', '2017-07-01', NULL, 0.049500, NULL, NULL, NULL, NULL),

  -- Indiana: 3.05% for 2024; 3.00% from 2025 per HEA 1001
  -- Source: IN DOR — VERIFY: continues reducing per schedule
  ('US_IN_INCOME_TAX', '2024-01-01', '2024-12-31', 0.030500, NULL, NULL, NULL, NULL),
  ('US_IN_INCOME_TAX', '2025-01-01', NULL,          0.030000, NULL, NULL, NULL, NULL),

  -- Iowa (transitional flat rate under HF 2317)
  -- Source: IA DOR — VERIFY: confirm exact rate for 2025 from DOR publication
  ('US_IA_INCOME_TAX', '2024-01-01', '2024-12-31', 0.048200, NULL, NULL, NULL, NULL),  -- 4.82% (2024) VERIFY
  ('US_IA_INCOME_TAX', '2025-01-01', NULL,          0.039000, NULL, NULL, NULL, NULL),  -- 3.9%  (2025) VERIFY

  -- Louisiana 3.0% flat (special session Nov 2024 — HB 2/SB 1)
  -- Source: LA DOR — VERIFY effective date and rate
  ('US_LA_INCOME_TAX', '2025-01-01', NULL, 0.030000, NULL, NULL, NULL, NULL),

  -- Massachusetts 5.0% (base rate; surtax on $1M+ not modeled)
  -- Source: MA DOR — VERIFY annually
  ('US_MA_INCOME_TAX', '2020-01-01', NULL, 0.050000, NULL, NULL, NULL, NULL),

  -- Michigan 4.25%
  -- Source: MI Treasury — VERIFY: was temporarily 4.05% for 2023; confirm restoration
  ('US_MI_INCOME_TAX', '2024-01-01', NULL, 0.042500, NULL, NULL, NULL, NULL),

  -- Mississippi: 4.7% (2024) reducing to 4.4% (2025) under HB 531
  -- Source: MS DOR — VERIFY: rate reduces each year toward 4.0%
  ('US_MS_INCOME_TAX', '2024-01-01', '2024-12-31', 0.047000, NULL, NULL, NULL, NULL),
  ('US_MS_INCOME_TAX', '2025-01-01', NULL,          0.044000, NULL, NULL, NULL, NULL),

  -- North Carolina: 4.5% (2024); 4.25% (2025) under SL 2023-134
  -- Source: NC DOR — VERIFY: continues reducing per schedule
  ('US_NC_INCOME_TAX', '2024-01-01', '2024-12-31', 0.045000, NULL, NULL, NULL, NULL),
  ('US_NC_INCOME_TAX', '2025-01-01', NULL,          0.042500, NULL, NULL, NULL, NULL),

  -- North Dakota 2.5% flat (effective 2023 — HB 1158)
  -- Source: ND State Tax Commissioner — VERIFY annually
  ('US_ND_INCOME_TAX', '2023-01-01', NULL, 0.025000, NULL, NULL, NULL, NULL),

  -- Utah 4.55%
  -- Source: UT Tax Commission — VERIFY annually
  ('US_UT_INCOME_TAX', '2022-01-01', NULL, 0.045500, NULL, NULL, NULL, NULL);


-- =============================================================
-- TAX BRACKETS
-- All rows use NULL for filing_status_code (applies to all
-- filing statuses) using the single-filer rate schedule.
-- MFJ-specific bracket rows should be added before production
-- for any jurisdiction brought into active use.
-- Lower/upper limits are ANNUAL income amounts.
-- =============================================================


-- -------------------------------------------------------------
-- Alabama 2025
-- Source: AL DOR Form A-4 instructions — VERIFY annually
-- Same brackets for all filing statuses; standard deduction differs
-- NOTE: AL uses SINGLE brackets below for NULL (conservative);
--   MFJ brackets have wider bands — add MFJ rows before production
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_AL_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,    0.0000,   500.0000, 0.020000),
  ('US_AL_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  500.0000,  3000.0000, 0.040000),
  ('US_AL_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 3000.0000,  NULL,      0.050000),
  ('US_AL_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,    0.0000,  1000.0000, 0.020000),
  ('US_AL_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 1000.0000,  6000.0000, 0.040000),
  ('US_AL_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 6000.0000,  NULL,      0.050000);


-- -------------------------------------------------------------
-- Arkansas 2024 — simplified two-tier (top rate 3.9%)
-- Source: AR DOR — VERIFY: rate reduces annually under Act 532 of 2023
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_AR_INCOME_TAX', NULL, '2024-01-01', NULL,     0.0000,  4999.0000, 0.020000),
  ('US_AR_INCOME_TAX', NULL, '2024-01-01', NULL,  4999.0000, NULL,       0.039000);


-- -------------------------------------------------------------
-- Connecticut 2025
-- Source: CT DRS Publication IP 2025(1) — VERIFY annually
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_CT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,      0.0000,   10000.0000, 0.030000),
  ('US_CT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  10000.0000,   50000.0000, 0.050000),
  ('US_CT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  50000.0000,  100000.0000, 0.055000),
  ('US_CT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 100000.0000,  200000.0000, 0.060000),
  ('US_CT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 200000.0000,  250000.0000, 0.065000),
  ('US_CT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 250000.0000,  500000.0000, 0.069000),
  ('US_CT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 500000.0000,  NULL,        0.069900),
  -- MFJ thresholds are doubled
  ('US_CT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,      0.0000,   20000.0000, 0.030000),
  ('US_CT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,  20000.0000,  100000.0000, 0.050000),
  ('US_CT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 100000.0000,  200000.0000, 0.055000),
  ('US_CT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 200000.0000,  400000.0000, 0.060000),
  ('US_CT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 400000.0000,  500000.0000, 0.065000),
  ('US_CT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 500000.0000, 1000000.0000, 0.069000),
  ('US_CT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,1000000.0000,  NULL,        0.069900);


-- -------------------------------------------------------------
-- Delaware 2025
-- Source: DE Division of Revenue — VERIFY annually
-- Same brackets for all filing statuses
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_DE_INCOME_TAX', NULL, '2025-01-01', NULL,     0.0000,   2000.0000, 0.000000),
  ('US_DE_INCOME_TAX', NULL, '2025-01-01', NULL,  2000.0000,   5000.0000, 0.022000),
  ('US_DE_INCOME_TAX', NULL, '2025-01-01', NULL,  5000.0000,  10000.0000, 0.039000),
  ('US_DE_INCOME_TAX', NULL, '2025-01-01', NULL, 10000.0000,  20000.0000, 0.048000),
  ('US_DE_INCOME_TAX', NULL, '2025-01-01', NULL, 20000.0000,  25000.0000, 0.052000),
  ('US_DE_INCOME_TAX', NULL, '2025-01-01', NULL, 25000.0000,  60000.0000, 0.055500),
  ('US_DE_INCOME_TAX', NULL, '2025-01-01', NULL, 60000.0000,  NULL,       0.066000);


-- -------------------------------------------------------------
-- District of Columbia 2025
-- Source: DC Office of Tax and Revenue — VERIFY annually
-- DC does not differentiate by filing status for withholding
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_DC_INCOME_TAX', NULL, '2025-01-01', NULL,      0.0000,   10000.0000, 0.040000),
  ('US_DC_INCOME_TAX', NULL, '2025-01-01', NULL,  10000.0000,   40000.0000, 0.060000),
  ('US_DC_INCOME_TAX', NULL, '2025-01-01', NULL,  40000.0000,   60000.0000, 0.065000),
  ('US_DC_INCOME_TAX', NULL, '2025-01-01', NULL,  60000.0000,  250000.0000, 0.085000),
  ('US_DC_INCOME_TAX', NULL, '2025-01-01', NULL, 250000.0000,  500000.0000, 0.092500),
  ('US_DC_INCOME_TAX', NULL, '2025-01-01', NULL, 500000.0000, 1000000.0000, 0.097500),
  ('US_DC_INCOME_TAX', NULL, '2025-01-01', NULL,1000000.0000,  NULL,        0.107500);


-- -------------------------------------------------------------
-- Hawaii 2025
-- Source: HI DOTAX — VERIFY annually (brackets indexed periodically)
-- Using SINGLE schedule for NULL; MFJ thresholds are approximately doubled
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL,      0.0000,    2400.0000, 0.014000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL,   2400.0000,    4800.0000, 0.032000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL,   4800.0000,    9600.0000, 0.055000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL,   9600.0000,   14400.0000, 0.064000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL,  14400.0000,   19200.0000, 0.068000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL,  19200.0000,   24000.0000, 0.072000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL,  24000.0000,   36000.0000, 0.076000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL,  36000.0000,   48000.0000, 0.079000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL,  48000.0000,  150000.0000, 0.082500),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL, 150000.0000,  175000.0000, 0.090000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL, 175000.0000,  200000.0000, 0.100000),
  ('US_HI_INCOME_TAX', NULL, '2025-01-01', NULL, 200000.0000,  NULL,        0.110000);


-- -------------------------------------------------------------
-- Kansas 2024
-- Source: KS DOR — VERIFY: significant reform was debated in 2024;
--   confirm enacted bracket structure from KS DOR publication
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_KS_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,     0.0000,  15000.0000, 0.031000),
  ('US_KS_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 15000.0000,  30000.0000, 0.052500),
  ('US_KS_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 30000.0000,  NULL,       0.057000),
  ('US_KS_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,     0.0000,  30000.0000, 0.031000),
  ('US_KS_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 30000.0000,  60000.0000, 0.052500),
  ('US_KS_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 60000.0000,  NULL,       0.057000);


-- -------------------------------------------------------------
-- Maine 2024
-- Source: ME Revenue Services — VERIFY: brackets indexed annually
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_ME_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,     0.0000,  24500.0000, 0.058000),
  ('US_ME_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 24500.0000,  58050.0000, 0.067500),
  ('US_ME_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 58050.0000,  NULL,       0.071500),
  ('US_ME_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,     0.0000,  49050.0000, 0.058000),
  ('US_ME_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 49050.0000, 116100.0000, 0.067500),
  ('US_ME_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,116100.0000,  NULL,       0.071500);


-- -------------------------------------------------------------
-- Maryland 2025 — state brackets only; county tax deferred
-- Source: MD Comptroller — VERIFY annually
-- Same bracket schedule for all filing statuses
-- NOTE: MD also levies county income tax (2.25–3.2% depending on
--   county of residence). County tax is deferred to the local tax phase.
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_MD_INCOME_TAX', NULL, '2025-01-01', NULL,      0.0000,    1000.0000, 0.020000),
  ('US_MD_INCOME_TAX', NULL, '2025-01-01', NULL,   1000.0000,    2000.0000, 0.030000),
  ('US_MD_INCOME_TAX', NULL, '2025-01-01', NULL,   2000.0000,    3000.0000, 0.040000),
  ('US_MD_INCOME_TAX', NULL, '2025-01-01', NULL,   3000.0000,  100000.0000, 0.047500),
  ('US_MD_INCOME_TAX', NULL, '2025-01-01', NULL, 100000.0000,  125000.0000, 0.050000),
  ('US_MD_INCOME_TAX', NULL, '2025-01-01', NULL, 125000.0000,  150000.0000, 0.052500),
  ('US_MD_INCOME_TAX', NULL, '2025-01-01', NULL, 150000.0000,  250000.0000, 0.055000),
  ('US_MD_INCOME_TAX', NULL, '2025-01-01', NULL, 250000.0000,  NULL,        0.057500);


-- -------------------------------------------------------------
-- Minnesota 2025
-- Source: MN DOR — VERIFY: brackets indexed annually for inflation
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_MN_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,      0.0000,   31690.0000, 0.053500),
  ('US_MN_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  31690.0000,  104090.0000, 0.068000),
  ('US_MN_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 104090.0000,  193240.0000, 0.078500),
  ('US_MN_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 193240.0000,  NULL,        0.098500),
  ('US_MN_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,      0.0000,   46330.0000, 0.053500),
  ('US_MN_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,  46330.0000,  184040.0000, 0.068000),
  ('US_MN_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 184040.0000,  322050.0000, 0.078500),
  ('US_MN_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 322050.0000,  NULL,        0.098500);


-- -------------------------------------------------------------
-- Missouri 2024 — top rate 4.8% (reduced; was 4.95%)
-- Source: MO DOR — VERIFY: rate may reduce further under SB 3 (2023)
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_MO_INCOME_TAX', NULL, '2024-01-01', NULL,    0.0000,  1207.0000, 0.015000),
  ('US_MO_INCOME_TAX', NULL, '2024-01-01', NULL, 1207.0000,  2414.0000, 0.020000),
  ('US_MO_INCOME_TAX', NULL, '2024-01-01', NULL, 2414.0000,  3621.0000, 0.025000),
  ('US_MO_INCOME_TAX', NULL, '2024-01-01', NULL, 3621.0000,  4828.0000, 0.030000),
  ('US_MO_INCOME_TAX', NULL, '2024-01-01', NULL, 4828.0000,  6034.0000, 0.035000),
  ('US_MO_INCOME_TAX', NULL, '2024-01-01', NULL, 6034.0000,  7241.0000, 0.040000),
  ('US_MO_INCOME_TAX', NULL, '2024-01-01', NULL, 7241.0000,  8448.0000, 0.045000),
  ('US_MO_INCOME_TAX', NULL, '2024-01-01', NULL, 8448.0000,  NULL,      0.048000);


-- -------------------------------------------------------------
-- Montana 2024 — simplified two-bracket (SB 399 signed 2021, eff 2024)
-- Source: MT DOR — VERIFY: confirm thresholds for 2025 (indexed)
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_MT_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,     0.0000,  20500.0000, 0.047000),
  ('US_MT_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 20500.0000,  NULL,       0.059000),
  ('US_MT_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,     0.0000,  41000.0000, 0.047000),
  ('US_MT_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 41000.0000,  NULL,       0.059000);


-- -------------------------------------------------------------
-- Nebraska 2024 — top rate 5.84% (LB 754; reducing annually)
-- Source: NE DOR — VERIFY: rate reduces each year per schedule
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_NE_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,     0.0000,   3700.0000, 0.024600),
  ('US_NE_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,  3700.0000,  22170.0000, 0.035100),
  ('US_NE_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 22170.0000,  35730.0000, 0.050100),
  ('US_NE_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 35730.0000,  NULL,       0.058400),
  ('US_NE_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,     0.0000,   7390.0000, 0.024600),
  ('US_NE_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,  7390.0000,  44350.0000, 0.035100),
  ('US_NE_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 44350.0000,  71460.0000, 0.050100),
  ('US_NE_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 71460.0000,  NULL,       0.058400);


-- -------------------------------------------------------------
-- New Jersey 2025
-- Source: NJ Division of Taxation — VERIFY annually
-- SINGLE brackets below; MFJ brackets differ at middle incomes
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_NJ_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,      0.0000,   20000.0000, 0.014000),
  ('US_NJ_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  20000.0000,   35000.0000, 0.017500),
  ('US_NJ_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  35000.0000,   40000.0000, 0.035000),
  ('US_NJ_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  40000.0000,   75000.0000, 0.055250),
  ('US_NJ_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  75000.0000,  500000.0000, 0.063700),
  ('US_NJ_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 500000.0000, 1000000.0000, 0.089700),
  ('US_NJ_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,1000000.0000,  NULL,        0.107500),
  -- MFJ: same rates but different break points at middle income
  ('US_NJ_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,      0.0000,   20000.0000, 0.014000),
  ('US_NJ_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,  20000.0000,   50000.0000, 0.017500),
  ('US_NJ_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,  50000.0000,   70000.0000, 0.024500),
  ('US_NJ_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,  70000.0000,   80000.0000, 0.035000),
  ('US_NJ_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,  80000.0000,  150000.0000, 0.055250),
  ('US_NJ_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 150000.0000,  500000.0000, 0.063700),
  ('US_NJ_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 500000.0000, 1000000.0000, 0.089700),
  ('US_NJ_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,1000000.0000,  NULL,        0.107500);


-- -------------------------------------------------------------
-- New Mexico 2024
-- Source: NM Taxation and Revenue — VERIFY annually
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_NM_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,      0.0000,    5500.0000, 0.017000),
  ('US_NM_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,   5500.0000,   11000.0000, 0.032000),
  ('US_NM_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,  11000.0000,   16000.0000, 0.047000),
  ('US_NM_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,  16000.0000,  210000.0000, 0.049000),
  ('US_NM_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 210000.0000,  NULL,        0.059000),
  ('US_NM_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,      0.0000,    8000.0000, 0.017000),
  ('US_NM_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,   8000.0000,   16000.0000, 0.032000),
  ('US_NM_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,  16000.0000,   24000.0000, 0.047000),
  ('US_NM_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,  24000.0000,  315000.0000, 0.049000),
  ('US_NM_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 315000.0000,  NULL,        0.059000);


-- -------------------------------------------------------------
-- Ohio 2024 — significantly simplified (HB 96 / prior reforms)
-- Source: OH Department of Taxation — VERIFY: rates and thresholds
--   reduced substantially in recent years; confirm from DOR publication
-- First bracket 0% represents the income exempt from taxation
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_OH_INCOME_TAX', NULL, '2024-01-01', NULL,      0.0000,   26050.0000, 0.000000),
  ('US_OH_INCOME_TAX', NULL, '2024-01-01', NULL,  26050.0000,  100000.0000, 0.027500),
  ('US_OH_INCOME_TAX', NULL, '2024-01-01', NULL, 100000.0000,  NULL,        0.035000);


-- -------------------------------------------------------------
-- Oklahoma 2024
-- Source: OK Tax Commission — VERIFY annually
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_OK_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,    0.0000,  1000.0000, 0.002500),
  ('US_OK_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 1000.0000,  2500.0000, 0.007500),
  ('US_OK_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 2500.0000,  3750.0000, 0.017500),
  ('US_OK_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 3750.0000,  4900.0000, 0.027500),
  ('US_OK_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 4900.0000,  7200.0000, 0.037500),
  ('US_OK_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 7200.0000,  NULL,      0.047500),
  ('US_OK_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,    0.0000,  2000.0000, 0.002500),
  ('US_OK_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 2000.0000,  5000.0000, 0.007500),
  ('US_OK_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 5000.0000,  7500.0000, 0.017500),
  ('US_OK_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 7500.0000,  9800.0000, 0.027500),
  ('US_OK_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 9800.0000, 12200.0000, 0.037500),
  ('US_OK_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,12200.0000,  NULL,      0.047500);


-- -------------------------------------------------------------
-- Oregon 2025
-- Source: OR DOR Publication 150-206-436 — VERIFY annually
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_OR_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,      0.0000,   18400.0000, 0.047500),
  ('US_OR_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  18400.0000,   46200.0000, 0.067500),
  ('US_OR_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  46200.0000,  250000.0000, 0.087500),
  ('US_OR_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 250000.0000,  NULL,        0.099000),
  ('US_OR_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,      0.0000,   36800.0000, 0.047500),
  ('US_OR_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,  36800.0000,   92300.0000, 0.067500),
  ('US_OR_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,  92300.0000,  500000.0000, 0.087500),
  ('US_OR_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 500000.0000,  NULL,        0.099000);


-- -------------------------------------------------------------
-- Rhode Island 2025
-- Source: RI Division of Taxation — VERIFY: brackets indexed annually
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_RI_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,      0.0000,   77450.0000, 0.037500),
  ('US_RI_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  77450.0000,  176050.0000, 0.047500),
  ('US_RI_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 176050.0000,  NULL,        0.059900),
  ('US_RI_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,      0.0000,  154950.0000, 0.037500),
  ('US_RI_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 154950.0000,  352050.0000, 0.047500),
  ('US_RI_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 352050.0000,  NULL,        0.059900);


-- -------------------------------------------------------------
-- South Carolina 2024 — reducing top rate (HB 3516, 2022)
-- Source: SC DOR — VERIFY: top rate reduces annually; confirm current year
-- Two-tier structure as of 2024 (previous multi-bracket collapsed)
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_SC_INCOME_TAX', NULL, '2024-01-01', '2024-12-31',    0.0000,  3200.0000, 0.000000),
  ('US_SC_INCOME_TAX', NULL, '2024-01-01', '2024-12-31', 3200.0000,  NULL,      0.064000),
  ('US_SC_INCOME_TAX', NULL, '2025-01-01',  NULL,            0.0000,  3200.0000, 0.000000),
  ('US_SC_INCOME_TAX', NULL, '2025-01-01',  NULL,         3200.0000,  NULL,      0.063000);


-- -------------------------------------------------------------
-- Vermont 2025
-- Source: VT Department of Taxes — VERIFY: brackets indexed annually
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_VT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,      0.0000,   45400.0000, 0.033500),
  ('US_VT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL,  45400.0000,  110050.0000, 0.066000),
  ('US_VT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 110050.0000,  229550.0000, 0.076000),
  ('US_VT_INCOME_TAX', 'SINGLE', '2025-01-01', NULL, 229550.0000,  NULL,        0.087500),
  ('US_VT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,      0.0000,   75850.0000, 0.033500),
  ('US_VT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL,  75850.0000,  183400.0000, 0.066000),
  ('US_VT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 183400.0000,  279450.0000, 0.076000),
  ('US_VT_INCOME_TAX', 'MFJ',   '2025-01-01', NULL, 279450.0000,  NULL,        0.087500);


-- -------------------------------------------------------------
-- Virginia 2025
-- Source: VA Department of Taxation — VERIFY: rates unchanged for many
--   years but standard deduction increased; confirm current deduction amount
-- Same bracket schedule for all filing statuses
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_VA_INCOME_TAX', NULL, '2025-01-01', NULL,     0.0000,  3000.0000, 0.020000),
  ('US_VA_INCOME_TAX', NULL, '2025-01-01', NULL,  3000.0000,  5000.0000, 0.030000),
  ('US_VA_INCOME_TAX', NULL, '2025-01-01', NULL,  5000.0000, 17000.0000, 0.050000),
  ('US_VA_INCOME_TAX', NULL, '2025-01-01', NULL, 17000.0000,  NULL,      0.057500);


-- -------------------------------------------------------------
-- West Virginia 2024 — reduced rates (HB 2526, 2023 — 21.25% cut)
-- Source: WV State Tax Division — VERIFY: further reductions scheduled
-- Same brackets for all filing statuses
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_WV_INCOME_TAX', NULL, '2024-01-01', NULL,     0.0000,  10000.0000, 0.023600),
  ('US_WV_INCOME_TAX', NULL, '2024-01-01', NULL, 10000.0000,  25000.0000, 0.031500),
  ('US_WV_INCOME_TAX', NULL, '2024-01-01', NULL, 25000.0000,  40000.0000, 0.035400),
  ('US_WV_INCOME_TAX', NULL, '2024-01-01', NULL, 40000.0000,  60000.0000, 0.047200),
  ('US_WV_INCOME_TAX', NULL, '2024-01-01', NULL, 60000.0000,  NULL,       0.051200);


-- -------------------------------------------------------------
-- Wisconsin 2024
-- Source: WI DOR — VERIFY annually
-- -------------------------------------------------------------
INSERT INTO tax_brackets (step_code, filing_status_code, effective_from, effective_to, lower_limit, upper_limit, rate) VALUES
  ('US_WI_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,      0.0000,   14320.0000, 0.035000),
  ('US_WI_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,  14320.0000,   28640.0000, 0.044000),
  ('US_WI_INCOME_TAX', 'SINGLE', '2024-01-01', NULL,  28640.0000,  315310.0000, 0.053000),
  ('US_WI_INCOME_TAX', 'SINGLE', '2024-01-01', NULL, 315310.0000,  NULL,        0.076500),
  ('US_WI_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,      0.0000,   19090.0000, 0.035000),
  ('US_WI_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,  19090.0000,   38190.0000, 0.044000),
  ('US_WI_INCOME_TAX', 'MFJ',   '2024-01-01', NULL,  38190.0000,  420420.0000, 0.053000),
  ('US_WI_INCOME_TAX', 'MFJ',   '2024-01-01', NULL, 420420.0000,  NULL,        0.076500);


-- =============================================================
-- TAX ALLOWANCES (standard deductions)
-- =============================================================

-- -------------------------------------------------------------
-- Alabama: $2,500 (SINGLE), $7,500 (MFJ)
-- Source: AL DOR — VERIFY: deduction phases out at higher incomes;
--   these are the base amounts applicable to most employees
-- -------------------------------------------------------------
INSERT INTO tax_allowances (step_code, filing_status_code, effective_from, effective_to, annual_amount) VALUES
  ('US_AL_STD_DEDUCTION', 'SINGLE', '2025-01-01', NULL, 2500.0000),
  ('US_AL_STD_DEDUCTION', 'MFJ',    '2025-01-01', NULL, 7500.0000),
  ('US_AL_STD_DEDUCTION', 'MFS',    '2025-01-01', NULL, 2500.0000),
  ('US_AL_STD_DEDUCTION', 'HOH',    '2025-01-01', NULL, 2500.0000);

-- -------------------------------------------------------------
-- Delaware: $3,250 (SINGLE), $6,500 (MFJ)
-- Source: DE Division of Revenue — VERIFY annually
-- -------------------------------------------------------------
INSERT INTO tax_allowances (step_code, filing_status_code, effective_from, effective_to, annual_amount) VALUES
  ('US_DE_STD_DEDUCTION', 'SINGLE', '2025-01-01', NULL, 3250.0000),
  ('US_DE_STD_DEDUCTION', 'MFJ',    '2025-01-01', NULL, 6500.0000),
  ('US_DE_STD_DEDUCTION', 'MFS',    '2025-01-01', NULL, 3250.0000),
  ('US_DE_STD_DEDUCTION', 'HOH',    '2025-01-01', NULL, 3250.0000);

-- -------------------------------------------------------------
-- Hawaii: $2,200 (SINGLE), $4,400 (MFJ)
-- Source: HI DOTAX — VERIFY annually
-- -------------------------------------------------------------
INSERT INTO tax_allowances (step_code, filing_status_code, effective_from, effective_to, annual_amount) VALUES
  ('US_HI_STD_DEDUCTION', 'SINGLE', '2025-01-01', NULL, 2200.0000),
  ('US_HI_STD_DEDUCTION', 'MFJ',    '2025-01-01', NULL, 4400.0000),
  ('US_HI_STD_DEDUCTION', 'MFS',    '2025-01-01', NULL, 2200.0000),
  ('US_HI_STD_DEDUCTION', 'HOH',    '2025-01-01', NULL, 2200.0000);

-- -------------------------------------------------------------
-- Maine: $14,600 (SINGLE), $29,200 (MFJ) — matches federal for 2025
-- Source: ME Revenue Services — VERIFY: ME conforms to federal STD deduction
-- -------------------------------------------------------------
INSERT INTO tax_allowances (step_code, filing_status_code, effective_from, effective_to, annual_amount) VALUES
  ('US_ME_STD_DEDUCTION', 'SINGLE', '2025-01-01', NULL, 14600.0000),
  ('US_ME_STD_DEDUCTION', 'MFJ',    '2025-01-01', NULL, 29200.0000),
  ('US_ME_STD_DEDUCTION', 'MFS',    '2025-01-01', NULL, 14600.0000),
  ('US_ME_STD_DEDUCTION', 'HOH',    '2025-01-01', NULL, 21900.0000);

-- -------------------------------------------------------------
-- Maryland: min $1,600, max $2,400 (SINGLE) = 15% of gross income
-- For withholding purposes MD uses the maximum deduction amount.
-- Source: MD Comptroller — VERIFY annually
-- -------------------------------------------------------------
INSERT INTO tax_allowances (step_code, filing_status_code, effective_from, effective_to, annual_amount) VALUES
  ('US_MD_STD_DEDUCTION', 'SINGLE', '2025-01-01', NULL, 2400.0000),
  ('US_MD_STD_DEDUCTION', 'MFJ',    '2025-01-01', NULL, 4800.0000),
  ('US_MD_STD_DEDUCTION', 'MFS',    '2025-01-01', NULL, 2400.0000),
  ('US_MD_STD_DEDUCTION', 'HOH',    '2025-01-01', NULL, 2400.0000);

-- -------------------------------------------------------------
-- Oregon: $2,420 (SINGLE), $4,840 (MFJ) — not indexed
-- Source: OR DOR — VERIFY: OR standard deduction is not inflation-indexed
-- -------------------------------------------------------------
INSERT INTO tax_allowances (step_code, filing_status_code, effective_from, effective_to, annual_amount) VALUES
  ('US_OR_STD_DEDUCTION', 'SINGLE', '2025-01-01', NULL, 2420.0000),
  ('US_OR_STD_DEDUCTION', 'MFJ',    '2025-01-01', NULL, 4840.0000),
  ('US_OR_STD_DEDUCTION', 'MFS',    '2025-01-01', NULL, 2420.0000),
  ('US_OR_STD_DEDUCTION', 'HOH',    '2025-01-01', NULL, 3450.0000);

-- -------------------------------------------------------------
-- Virginia: $8,000 (SINGLE), $16,000 (MFJ)
-- Source: VA Department of Taxation — VERIFY: increased in recent years
-- -------------------------------------------------------------
INSERT INTO tax_allowances (step_code, filing_status_code, effective_from, effective_to, annual_amount) VALUES
  ('US_VA_STD_DEDUCTION', 'SINGLE', '2025-01-01', NULL, 8000.0000),
  ('US_VA_STD_DEDUCTION', 'MFJ',    '2025-01-01', NULL,16000.0000),
  ('US_VA_STD_DEDUCTION', 'MFS',    '2025-01-01', NULL, 8000.0000),
  ('US_VA_STD_DEDUCTION', 'HOH',    '2025-01-01', NULL, 8000.0000);


-- =============================================================
-- Kentucky rate correction
-- tax_pipeline_seed_data.sql seeded KY at 4.5% from 2023.
-- KY reduced to 4.0% effective 2024 (HB 1, 2023 session).
-- Source: KY DOR — VERIFY: further reduction to 3.5% if revenue
--   trigger is met (check KY DOR announcement each October).
-- =============================================================
UPDATE tax_flat_rates
   SET effective_to = '2023-12-31'
 WHERE step_code = 'US_KY_INCOME_TAX'
   AND effective_from = '2023-01-01'
   AND effective_to IS NULL;

INSERT INTO tax_flat_rates (step_code, effective_from, effective_to, rate, wage_base, period_cap_amount, annual_cap_amount, depends_on_step_code) VALUES
  ('US_KY_INCOME_TAX', '2024-01-01', NULL, 0.040000, NULL, NULL, NULL, NULL);


-- =============================================================
-- END
-- =============================================================
