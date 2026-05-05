-- =============================================================
-- Form Field Definitions — Seed Data
-- Covers the seven Phase 5 gate form types:
--   W4_2020    US Federal W-4 (2020+)
--   W4_LEGACY  US Federal W-4 (Pre-2020)
--   G_4        Georgia G-4
--   IT_2104    New York IT-2104
--   DE_4       California DE-4
--   TD1        Canada TD1 (Federal)
--   BB_TD4     Barbados TD4
--
-- detail_column_name  = physical column in employee_tax_form_detail
-- promotes_to_column  = CalculationContext property name
-- enum_values_json    = JSON array of allowed values for ENUM fields
-- status_code         = ACTIVE for all seed rows
--
-- Survey date: 2026-05-02 (Phase 5.9 deliverable)
-- Re-verify annually per §15 schedule.
-- =============================================================


-- =============================================================
-- W4_2020 — US Federal W-4 (2020+)
-- =============================================================

INSERT INTO form_field_definition
  (form_type_code, effective_from, field_key, display_label, field_type,
   section_key, section_label, display_order, is_required,
   detail_column_name, promotes_to_column,
   enum_values_json, help_text, status_code, is_active)
VALUES
  ('W4_2020', '2020-01-01', 'filing_status_code', 'Filing Status', 'ENUM',
   'step1', 'Step 1 — Personal Information', 10, true,
   'filing_status_code', 'FilingStatusCode',
   '["SINGLE","MFJ","MFS","HOH"]',
   'SINGLE = Single or Married Filing Separately; MFJ = Married Filing Jointly or Qualifying Surviving Spouse; HOH = Head of Household.',
   'ACTIVE', true),

  ('W4_2020', '2020-01-01', 'credits_amount', 'Total Credits (Step 3)', 'DECIMAL',
   'step3', 'Step 3 — Claim Dependents', 20, false,
   'credits_amount', 'CreditsAmount',
   NULL,
   'Enter the total dollar amount from Step 3 of the employee''s W-4. Qualifying children and other dependents reduce withholding.',
   'ACTIVE', true),

  ('W4_2020', '2020-01-01', 'other_income_amount', 'Other Income — Step 4a', 'DECIMAL',
   'step4', 'Step 4 — Other Adjustments (Optional)', 30, false,
   'other_income_amount', 'OtherIncomeAmount',
   NULL,
   'Income from other sources (not jobs) the employee wants withheld for. Adds to the annualized wage base before bracket application.',
   'ACTIVE', true),

  ('W4_2020', '2020-01-01', 'deductions_amount', 'Deductions — Step 4b', 'DECIMAL',
   'step4', 'Step 4 — Other Adjustments (Optional)', 40, false,
   'deductions_amount', 'DeductionsAmount',
   NULL,
   'Additional deductions the employee expects to claim (e.g. itemized deductions above standard deduction). Reduces the annualized wage base.',
   'ACTIVE', true),

  ('W4_2020', '2020-01-01', 'additional_withholding', 'Extra Withholding Per Period — Step 4c', 'DECIMAL',
   'step4', 'Step 4 — Other Adjustments (Optional)', 50, false,
   'additional_withholding', 'AdditionalWithholding',
   NULL,
   'Fixed dollar amount to add to withholding each pay period, regardless of computed tax.',
   'ACTIVE', true);


-- =============================================================
-- W4_LEGACY — US Federal W-4 (Pre-2020)
-- =============================================================

INSERT INTO form_field_definition
  (form_type_code, effective_from, field_key, display_label, field_type,
   section_key, section_label, display_order, is_required,
   detail_column_name, promotes_to_column,
   enum_values_json, help_text, status_code, is_active)
VALUES
  ('W4_LEGACY', '2000-01-01', 'filing_status_code', 'Filing Status', 'ENUM',
   'main', NULL, 10, true,
   'filing_status_code', 'FilingStatusCode',
   '["SINGLE","MFJ"]',
   'Pre-2020 W-4: SINGLE = Single / Married but withhold at higher Single rate; MFJ = Married.',
   'ACTIVE', true),

  ('W4_LEGACY', '2000-01-01', 'allowance_count', 'Total Allowances', 'INTEGER',
   'main', NULL, 20, true,
   'allowance_count', 'AllowanceCount',
   NULL,
   'Total allowances from Line H of the pre-2020 W-4 Personal Allowances Worksheet. Each allowance reduces taxable wage by one annualised allowance amount.',
   'ACTIVE', true),

  ('W4_LEGACY', '2000-01-01', 'additional_withholding', 'Additional Amount to Withhold', 'DECIMAL',
   'main', NULL, 30, false,
   'additional_withholding', 'AdditionalWithholding',
   NULL,
   'Additional dollar amount to withhold per pay period beyond the computed amount.',
   'ACTIVE', true);


-- =============================================================
-- G_4 — Georgia G-4
-- =============================================================

INSERT INTO form_field_definition
  (form_type_code, effective_from, field_key, display_label, field_type,
   section_key, section_label, display_order, is_required,
   detail_column_name, promotes_to_column,
   enum_values_json, help_text, status_code, is_active)
VALUES
  ('G_4', '2024-01-01', 'filing_status_code', 'Filing Status', 'ENUM',
   'main', NULL, 10, true,
   'filing_status_code', 'FilingStatusCode',
   '["SINGLE","MFJ","MFS","HOH"]',
   'Georgia G-4 filing status. Drives standard deduction amount and bracket set.',
   'ACTIVE', true),

  ('G_4', '2024-01-01', 'allowance_count', 'Dependent Allowances (Section B)', 'INTEGER',
   'main', NULL, 20, true,
   'allowance_count', 'AllowanceCount',
   NULL,
   'Number of dependent allowances claimed on Georgia G-4 Section B. Each allowance reduces Georgia taxable income by the annual allowance amount.',
   'ACTIVE', true),

  ('G_4', '2024-01-01', 'additional_withholding', 'Additional Withholding', 'DECIMAL',
   'main', NULL, 30, false,
   'additional_withholding', 'AdditionalWithholding',
   NULL,
   'Additional Georgia income tax to withhold per pay period.',
   'ACTIVE', true);


-- =============================================================
-- IT_2104 — New York IT-2104
-- =============================================================

INSERT INTO form_field_definition
  (form_type_code, effective_from, field_key, display_label, field_type,
   section_key, section_label, display_order, is_required,
   detail_column_name, promotes_to_column,
   enum_values_json, help_text, status_code, is_active)
VALUES
  ('IT_2104', '2024-01-01', 'filing_status_code', 'Filing Status', 'ENUM',
   'main', NULL, 10, true,
   'filing_status_code', 'FilingStatusCode',
   '["SINGLE","MFJ","MFS","HOH"]',
   'New York IT-2104 filing status. NYS uses its own allowance tables — do not copy from the federal W-4.',
   'ACTIVE', true),

  ('IT_2104', '2024-01-01', 'allowance_count', 'NY State Allowances', 'INTEGER',
   'main', NULL, 20, true,
   'allowance_count', 'AllowanceCount',
   NULL,
   'Number of New York State allowances from IT-2104 line 1. NYS allowance amounts differ from federal.',
   'ACTIVE', true),

  ('IT_2104', '2024-01-01', 'additional_withholding', 'Additional Withholding', 'DECIMAL',
   'main', NULL, 30, false,
   'additional_withholding', 'AdditionalWithholding',
   NULL,
   'Additional New York State income tax to withhold per pay period (IT-2104 line 3).',
   'ACTIVE', true);


-- =============================================================
-- DE_4 — California DE-4
-- =============================================================

INSERT INTO form_field_definition
  (form_type_code, effective_from, field_key, display_label, field_type,
   section_key, section_label, display_order, is_required,
   detail_column_name, promotes_to_column,
   enum_values_json, help_text, status_code, is_active)
VALUES
  ('DE_4', '2024-01-01', 'filing_status_code', 'Filing Status', 'ENUM',
   'main', NULL, 10, true,
   'filing_status_code', 'FilingStatusCode',
   '["SINGLE","MFJ","MFS","HOH"]',
   'California DE-4 filing status. Drives CA income tax bracket set.',
   'ACTIVE', true),

  ('DE_4', '2024-01-01', 'allowance_count', 'Allowances (Worksheet A Total)', 'INTEGER',
   'main', NULL, 20, true,
   'allowance_count', 'AllowanceCount',
   NULL,
   'Total number of withholding allowances from DE-4 Worksheet A. Each allowance reduces CA taxable wages by the annual allowance value.',
   'ACTIVE', true),

  ('DE_4', '2024-01-01', 'additional_withholding', 'Additional Withholding', 'DECIMAL',
   'main', NULL, 30, false,
   'additional_withholding', 'AdditionalWithholding',
   NULL,
   'Additional California income tax to withhold per pay period (DE-4 line 4).',
   'ACTIVE', true);


-- =============================================================
-- TD1 — Canada TD1 (Federal)
-- =============================================================
-- TD1 uses either a standard Claim Code (1–10, looked up from CRA tables)
-- or a custom Total Claim Amount. Claim Code 0 = amount below basic personal;
-- Codes 1–10 map to standard CRA income bands. If the employee has a unique
-- situation they complete the TD1 worksheet and enter a dollar amount instead.

INSERT INTO form_field_definition
  (form_type_code, effective_from, field_key, display_label, field_type,
   section_key, section_label, display_order, is_required,
   detail_column_name, promotes_to_column,
   enum_values_json, help_text, status_code, is_active)
VALUES
  ('TD1', '2024-01-01', 'claim_code', 'Claim Code (1–10)', 'INTEGER',
   'main', NULL, 10, false,
   'claim_code', 'ClaimCode',
   NULL,
   'CRA standard Claim Code 1–10. Code 1 = Basic Personal Amount only; higher codes reflect additional credits. Leave blank if using the custom worksheet amount instead.',
   'ACTIVE', true),

  ('TD1', '2024-01-01', 'total_claim_amount', 'Total Claim Amount (Custom Worksheet)', 'DECIMAL',
   'main', NULL, 20, false,
   'total_claim_amount', 'TotalClaimAmount',
   NULL,
   'Dollar total from the TD1 Personal Tax Credits worksheet. Used when the employee''s credits do not correspond to a standard Claim Code. Mutually exclusive with Claim Code.',
   'ACTIVE', true),

  ('TD1', '2024-01-01', 'additional_withholding', 'Additional Tax to Deduct Per Period', 'DECIMAL',
   'main', NULL, 30, false,
   'additional_withholding', 'AdditionalWithholding',
   NULL,
   'Additional federal income tax the employee wants deducted each pay period, beyond the computed amount.',
   'ACTIVE', true);


-- =============================================================
-- BB_TD4 — Barbados TD4
-- =============================================================

INSERT INTO form_field_definition
  (form_type_code, effective_from, field_key, display_label, field_type,
   section_key, section_label, display_order, is_required,
   detail_column_name, promotes_to_column,
   enum_values_json, help_text, status_code, is_active)
VALUES
  ('BB_TD4', '2024-01-01', 'allowance_count', 'Allowances', 'INTEGER',
   'main', NULL, 10, false,
   'allowance_count', 'AllowanceCount',
   NULL,
   'Number of personal allowances claimed on Barbados TD4. Reduces Barbados taxable income by the annual allowance amount.',
   'ACTIVE', true),

  ('BB_TD4', '2024-01-01', 'additional_withholding', 'Additional Withholding', 'DECIMAL',
   'main', NULL, 20, false,
   'additional_withholding', 'AdditionalWithholding',
   NULL,
   'Additional Barbados income tax to withhold per pay period.',
   'ACTIVE', true);
