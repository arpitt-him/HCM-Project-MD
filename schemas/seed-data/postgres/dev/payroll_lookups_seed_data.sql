-- =============================================================
-- Payroll Lookup Tables — Seed Data
-- Run after payroll_lookups_schema.sql and payroll_core_schema.sql
-- Order matters: lkp_result_class must be inserted first because
-- lkp_impact_source_type and lkp_accumulator_family reference it
-- via result_class_id subqueries.
-- =============================================================

-- -------------------------------------------------------------
-- lkp_result_class
-- Top-level classification: EARNING, DEDUCTION, TAX, EMPLOYER_CONTRIBUTION
-- -------------------------------------------------------------
INSERT INTO lkp_result_class (code, label, description, sign_convention, affects_gross_pay, affects_net_pay, sort_order, is_active, is_default) VALUES
  ('EARNING',               'Earning',               'Wages, salary, bonuses, and other compensation paid to the employee',           'POSITIVE', true,  true,  1, true, true),
  ('DEDUCTION',             'Deduction',             'Pre-tax or post-tax amounts withheld from employee gross pay',                   'NEGATIVE', false, true,  2, true, false),
  ('TAX',                   'Tax',                   'Federal, state, or local tax withholding applied to employee pay',               'NEGATIVE', false, true,  3, true, false),
  ('EMPLOYER_CONTRIBUTION', 'Employer Contribution', 'Employer-side contributions (benefits, retirement match) not deducted from pay', 'POSITIVE', false, false, 4, true, false);

-- -------------------------------------------------------------
-- lkp_run_type
-- -------------------------------------------------------------
INSERT INTO lkp_run_type (code, label, description, affects_accumulators, is_reportable, requires_base_run, generates_payments, sort_order, is_active, is_default) VALUES
  ('REGULAR',       'Regular',       'Standard scheduled payroll run',                                         true,  true,  false, true,  1, true, true),
  ('SUPPLEMENTAL',  'Supplemental',  'Off-cycle supplemental pay run (bonuses, commissions, etc.)',            true,  true,  false, true,  2, true, false),
  ('ADJUSTMENT',    'Adjustment',    'Post-close adjustment to a prior regular run',                           true,  true,  true,  true,  3, true, false),
  ('CORRECTION',    'Correction',    'Corrective reprocessing of one or more employee results',                true,  true,  true,  true,  4, true, false),
  ('REPROCESSING',  'Reprocessing',  'Full re-execution of a prior run without changing inputs',               true,  true,  true,  true,  5, true, false),
  ('SIMULATION',    'Simulation',    'What-if run for modelling purposes — no accumulator impact or payments', false, false, false, false, 6, true, false);

-- -------------------------------------------------------------
-- lkp_run_status
-- sequence_order drives lifecycle progression (no default — must be explicit)
-- -------------------------------------------------------------
INSERT INTO lkp_run_status (code, label, description, is_editable, allows_calculation, allows_release, is_error_state, sequence_order, sort_order, is_active, is_default) VALUES
  ('DRAFT',        'Draft',        'Run created but not yet opened for processing',          true,  false, false, false,  1,  1, true, true),
  ('OPEN',         'Open',         'Run is open — inputs can be modified and calc submitted', true,  true,  false, false,  2,  2, true, false),
  ('CALCULATING',  'Calculating',  'Calculation engine is actively running',                 false, false, false, false,  3,  3, true, false),
  ('CALCULATED',   'Calculated',   'Calculation complete — results pending review',          false, false, false, false,  4,  4, true, false),
  ('UNDER_REVIEW', 'Under Review', 'Results are under manager or finance review',            false, false, false, false,  5,  5, true, false),
  ('APPROVED',     'Approved',     'Results approved — ready to release payments',           false, false, true,  false,  6,  6, true, false),
  ('RELEASING',    'Releasing',    'Payment release in progress',                            false, false, false, false,  7,  7, true, false),
  ('RELEASED',     'Released',     'Payments released to bank / disbursement pipeline',      false, false, false, false,  8,  8, true, false),
  ('CLOSED',       'Closed',       'Run fully settled and closed',                           false, false, false, false,  9,  9, true, false),
  ('FAILED',       'Failed',       'Run encountered an unrecoverable processing error',      false, false, false, true,  10, 10, true, false),
  ('CANCELLED',    'Cancelled',    'Run was cancelled before completion',                    false, false, false, false, 11, 11, true, false);

-- -------------------------------------------------------------
-- lkp_result_set_type
-- -------------------------------------------------------------
INSERT INTO lkp_result_set_type (code, label, description, is_scheduled, is_off_cycle, sort_order, is_active, is_default) VALUES
  ('REGULAR_RUN',     'Regular Run',     'Result set from a standard scheduled payroll run',        true,  false, 1, true, true),
  ('OFF_CYCLE',       'Off-Cycle',       'Result set from an off-cycle or supplemental run',        false, true,  2, true, false),
  ('ADJUSTMENT_RUN',  'Adjustment Run',  'Result set produced by a post-close adjustment run',      false, false, 3, true, false),
  ('CORRECTION_RUN',  'Correction Run',  'Result set produced by a corrective reprocessing run',    false, false, 4, true, false);

-- -------------------------------------------------------------
-- lkp_result_set_status
-- -------------------------------------------------------------
INSERT INTO lkp_result_set_status (code, label, description, is_editable, is_released, sort_order, is_active, is_default) VALUES
  ('PENDING',    'Pending',    'Result set created but calculation not yet started',   true,  false, 1, true, true),
  ('CALCULATED', 'Calculated', 'Calculation complete — results available for review',  false, false, 2, true, false),
  ('APPROVED',   'Approved',   'Results approved by authorized reviewer',              false, false, 3, true, false),
  ('RELEASED',   'Released',   'Payments released for disbursement',                   false, true,  4, true, false),
  ('FINALIZED',  'Finalized',  'Result set fully settled and locked',                  false, true,  5, true, false),
  ('ARCHIVED',   'Archived',   'Result set archived — read-only historical record',    false, true,  6, true, false);

-- -------------------------------------------------------------
-- lkp_employee_result_status
-- -------------------------------------------------------------
INSERT INTO lkp_employee_result_status (code, label, description, is_payable, is_reversible, sort_order, is_active, is_default) VALUES
  ('CALCULATED', 'Calculated', 'Employee result calculated — pending approval',          true,  false, 1, true, true),
  ('APPROVED',   'Approved',   'Employee result approved — payment authorised',           true,  false, 2, true, false),
  ('RELEASED',   'Released',   'Payment released to disbursement pipeline',               true,  true,  3, true, false),
  ('FINALIZED',  'Finalized',  'Payment fully settled and result locked',                 false, true,  4, true, false),
  ('CORRECTED',  'Corrected',  'Original result superseded by a correction',              false, false, 5, true, false),
  ('REVERSED',   'Reversed',   'Result reversed — offsetting entries applied',            false, false, 6, true, false);

-- -------------------------------------------------------------
-- lkp_item_status
-- Status of an individual payroll line item
-- -------------------------------------------------------------
INSERT INTO lkp_item_status (code, label, description, is_active_state, is_reversible, sort_order, is_active, is_default) VALUES
  ('DRAFT',     'Draft',     'Line item created but not yet posted',             true,  false, 1, true, true),
  ('POSTED',    'Posted',    'Line item posted to the employee result',           true,  true,  2, true, false),
  ('VOIDED',    'Voided',    'Line item voided — no longer in effect',            false, false, 3, true, false),
  ('CORRECTED', 'Corrected', 'Line item superseded by a correction entry',        false, false, 4, true, false);

-- -------------------------------------------------------------
-- lkp_payment_method
-- -------------------------------------------------------------
INSERT INTO lkp_payment_method (code, label, description, is_electronic, requires_bank_info, requires_physical_delivery, supports_split_payment, sort_order, is_active, is_default) VALUES
  ('DIRECT_DEPOSIT',  'Direct Deposit',  'ACH transfer to employee bank account',                       true,  true,  false, true,  1, true, true),
  ('PRINTED_CHECK',   'Printed Check',   'Physical check printed and mailed or handed to employee',     false, false, true,  false, 2, true, false),
  ('PAYCARD',         'Pay Card',        'Funds loaded to a prepaid debit card',                        true,  false, false, true,  3, true, false),
  ('CASH',            'Cash',            'Cash payment — manual distribution',                           false, false, true,  false, 4, true, false),
  ('MANUAL_CHECK',    'Manual Check',    'Manually written or issued check outside normal print run',    false, false, true,  false, 5, true, false),
  ('OTHER',           'Other',           'Other or unclassified payment method',                        false, false, false, false, 6, true, false);

-- -------------------------------------------------------------
-- lkp_payment_context
-- tax_method: AGGREGATE, SUPPLEMENTAL_RATE, or FLAT_RATE
-- -------------------------------------------------------------
INSERT INTO lkp_payment_context (code, label, description, is_scheduled, is_off_cycle, is_final, tax_method, sort_order, is_active, is_default) VALUES
  ('REGULAR',       'Regular',       'Standard scheduled pay — aggregate tax method',             true,  false, false, 'AGGREGATE',          1, true, true),
  ('SUPPLEMENTAL',  'Supplemental',  'Supplemental pay (bonus, commission) — supplemental rate',  false, true,  false, 'SUPPLEMENTAL_RATE',  2, true, false),
  ('CORRECTION',    'Correction',    'Corrective payment tied to a prior period',                  false, false, false, 'AGGREGATE',          3, true, false),
  ('FINAL_PAY',     'Final Pay',     'Termination or separation pay — aggregate method',           false, false, true,  'AGGREGATE',          4, true, false),
  ('OFF_CYCLE',     'Off-Cycle',     'Unscheduled off-cycle payment — supplemental rate',          false, true,  false, 'SUPPLEMENTAL_RATE',  5, true, false);

-- -------------------------------------------------------------
-- lkp_check_status
-- -------------------------------------------------------------
INSERT INTO lkp_check_status (code, label, description, is_negotiable, is_reissuable, sort_order, is_active, is_default) VALUES
  ('DRAFT',      'Draft',      'Check record created but not yet generated',         false, false, 1, true, true),
  ('GENERATED',  'Generated',  'Check generated and ready for release',               false, false, 2, true, false),
  ('RELEASED',   'Released',   'Check released — negotiable by payee',               true,  false, 3, true, false),
  ('VOIDED',     'Voided',     'Check voided — not negotiable; replacement eligible', false, true,  4, true, false),
  ('REPLACED',   'Replaced',   'Check replaced by a reissued instrument',             false, false, 5, true, false),
  ('RETURNED',   'Returned',   'Check returned (NSF, undeliverable, etc.)',           false, true,  6, true, false);

-- -------------------------------------------------------------
-- lkp_impact_status
-- -------------------------------------------------------------
INSERT INTO lkp_impact_status (code, label, description, is_active_state, is_reversible, sort_order, is_active, is_default) VALUES
  ('CALCULATED', 'Calculated', 'Impact record calculated — reflected in running totals',  true,  false, 1, true, true),
  ('POSTED',     'Posted',     'Impact committed to accumulator balances',                 true,  true,  2, true, false),
  ('REVERSED',   'Reversed',   'Impact reversed — offsetting record applied',              false, false, 3, true, false),
  ('CORRECTED',  'Corrected',  'Impact superseded by a correction record',                 false, false, 4, true, false),
  ('SUPERSEDED', 'Superseded', 'Impact replaced by a reprocessing run',                    false, false, 5, true, false);

-- -------------------------------------------------------------
-- lkp_impact_source_type
-- result_class_id resolved by subquery; NULL for non-classified types
-- -------------------------------------------------------------
INSERT INTO lkp_impact_source_type (code, label, description, result_class_id, is_system_generated, is_adjustable, sort_order, is_active, is_default) VALUES
  ('EARNINGS_LINE',               'Earnings Line',               'Impact from an employee earnings line item',              (SELECT id FROM lkp_result_class WHERE code = 'EARNING'),               true,  false, 1, true, true),
  ('DEDUCTION_LINE',              'Deduction Line',              'Impact from an employee deduction line item',             (SELECT id FROM lkp_result_class WHERE code = 'DEDUCTION'),             true,  false, 2, true, false),
  ('TAX_LINE',                    'Tax Line',                    'Impact from a tax withholding line item',                 (SELECT id FROM lkp_result_class WHERE code = 'TAX'),                   true,  false, 3, true, false),
  ('EMPLOYER_CONTRIBUTION_LINE',  'Employer Contribution Line',  'Impact from an employer contribution line item',          (SELECT id FROM lkp_result_class WHERE code = 'EMPLOYER_CONTRIBUTION'), true,  false, 4, true, false),
  ('CORRECTION_LINE',             'Correction Line',             'Impact from a corrective adjustment entry',               NULL,                                                                    true,  false, 5, true, false),
  ('MANUAL_ADJUSTMENT',           'Manual Adjustment',           'Manually entered adjustment by payroll administrator',    NULL,                                                                    false, true,  6, true, false),
  ('OTHER',                       'Other',                       'Unclassified impact source',                              NULL,                                                                    false, false, 7, true, false);

-- -------------------------------------------------------------
-- lkp_posting_direction
-- multiplier: +1.0 INCREASE, -1.0 DECREASE, 0.0 NEUTRAL, NULL DERIVED
-- -------------------------------------------------------------
INSERT INTO lkp_posting_direction (code, label, description, multiplier, sort_order, is_active, is_default) VALUES
  ('INCREASE', 'Increase', 'Posting adds to the accumulator balance',                            1.0,  1, true, true),
  ('DECREASE', 'Decrease', 'Posting subtracts from the accumulator balance',                    -1.0,  2, true, false),
  ('NEUTRAL',  'Neutral',  'Posting has no net effect on the accumulator balance',               0.0,  3, true, false),
  ('DERIVED',  'Derived',  'Direction computed at runtime based on result sign (NULL multiplier)', NULL, 4, true, false);

-- -------------------------------------------------------------
-- lkp_contribution_type
-- Nature of an accumulator contribution
-- -------------------------------------------------------------
INSERT INTO lkp_contribution_type (code, label, description, sort_order, is_active, is_default) VALUES
  ('STANDARD',   'Standard',   'Normal accumulator contribution from a payroll result',        1, true, true),
  ('REVERSAL',   'Reversal',   'Offsetting contribution that reverses a prior standard entry', 2, true, false),
  ('CORRECTION', 'Correction', 'Replacement contribution paired with a reversal',              3, true, false),
  ('RESET',      'Reset',      'Period-boundary reset entry (YTD, QTD, etc.)',                 4, true, false);

-- -------------------------------------------------------------
-- lkp_accumulator_family
-- Functional grouping of accumulators — result_class_id via subquery
-- -------------------------------------------------------------
INSERT INTO lkp_accumulator_family (code, label, description, result_class_id, is_tax_related, is_reportable, sort_order, is_active, is_default) VALUES
  ('GROSS_WAGES',           'Gross Wages',           'Total gross wages and salary before any withholding',          (SELECT id FROM lkp_result_class WHERE code = 'EARNING'),    false, true, 1, true, true),
  ('PRE_TAX_DEDUCTIONS',    'Pre-Tax Deductions',    'Employee pre-tax benefit and retirement deductions',           (SELECT id FROM lkp_result_class WHERE code = 'DEDUCTION'),  false, true, 2, true, false),
  ('POST_TAX_DEDUCTIONS',   'Post-Tax Deductions',   'Employee post-tax deductions (garnishments, voluntary, etc.)', (SELECT id FROM lkp_result_class WHERE code = 'DEDUCTION'),  false, true, 3, true, false),
  ('FEDERAL_TAX_WITHHELD',  'Federal Tax Withheld',  'Federal income tax withheld from employee pay',               (SELECT id FROM lkp_result_class WHERE code = 'TAX'),         true,  true, 4, true, false),
  ('SOCIAL_SECURITY',       'Social Security',       'OASDI / Social Security tax withheld and contributed',        (SELECT id FROM lkp_result_class WHERE code = 'TAX'),         true,  true, 5, true, false),
  ('MEDICARE',              'Medicare',              'Medicare / HI tax withheld and contributed',                  (SELECT id FROM lkp_result_class WHERE code = 'TAX'),         true,  true, 6, true, false),
  ('STATE_TAX_WITHHELD',    'State Tax Withheld',    'State income tax withheld from employee pay',                 (SELECT id FROM lkp_result_class WHERE code = 'TAX'),         true,  true, 7, true, false),
  ('RETIREMENT',            'Retirement',            'Employee and employer retirement plan contributions',          (SELECT id FROM lkp_result_class WHERE code = 'DEDUCTION'),  false, true, 8, true, false),
  ('EMPLOYER_TAXES',        'Employer Taxes',        'Employer-side payroll tax contributions (FUTA, SUI, SUTA)',   (SELECT id FROM lkp_result_class WHERE code = 'EMPLOYER_CONTRIBUTION'), true, true, 9, true, false);

-- -------------------------------------------------------------
-- lkp_accumulator_scope_type
-- Dimensional scope of an accumulator
-- -------------------------------------------------------------
INSERT INTO lkp_accumulator_scope_type (code, label, description, requires_participant, requires_employer, requires_jurisdiction, sort_order, is_active, is_default) VALUES
  ('EMPLOYEE',              'Employee',              'Accumulator scoped to a single employee',                      true,  false, false, 1, true, true),
  ('EMPLOYER',              'Employer',              'Accumulator scoped to the employer entity',                    false, true,  false, 2, true, false),
  ('EMPLOYEE_JURISDICTION', 'Employee + Jurisdiction','Employee accumulator further scoped by tax jurisdiction',     true,  false, true,  3, true, false),
  ('EMPLOYER_JURISDICTION', 'Employer + Jurisdiction','Employer accumulator further scoped by tax jurisdiction',    false, true,  true,  4, true, false),
  ('CLIENT_JURISDICTION',   'Client + Jurisdiction', 'Client-level accumulator scoped by tax jurisdiction',         false, true,  true,  5, true, false);

-- -------------------------------------------------------------
-- lkp_accumulator_balance_status
-- -------------------------------------------------------------
INSERT INTO lkp_accumulator_balance_status (code, label, description, is_active_state, sort_order, is_active, is_default) VALUES
  ('ACTIVE',   'Active',   'Balance is current and in use for accumulation',              true,  1, true, true),
  ('RESET',    'Reset',    'Balance was reset at a period boundary (YTD, QTD, etc.)',     false, 2, true, false),
  ('ARCHIVED', 'Archived', 'Balance archived — historical reference only',                false, 3, true, false);

-- -------------------------------------------------------------
-- lkp_period_context
-- abbreviation and reset_frequency are NOT NULL
-- -------------------------------------------------------------
INSERT INTO lkp_period_context (code, label, description, abbreviation, reset_frequency, reset_boundary, sort_order, is_active, is_default) VALUES
  ('PTD',       'Period-to-Date',    'Accumulator balance for the current pay period',      'PTD', 'PER_PAY',    'PAY_PERIOD_END',  1, true, true),
  ('QTD',       'Quarter-to-Date',   'Accumulator balance for the current calendar quarter', 'QTD', 'QUARTERLY',  'QUARTER_END',     2, true, false),
  ('YTD',       'Year-to-Date',      'Accumulator balance for the current calendar year',   'YTD', 'ANNUALLY',   'YEAR_END',        3, true, false),
  ('PLAN_YEAR', 'Plan Year-to-Date', 'Accumulator balance for the current benefit plan year','PY',  'PLAN_YEAR',  'PLAN_YEAR_END',   4, true, false),
  ('LTD',       'Lifetime-to-Date',  'Cumulative accumulator balance — never reset',        'LTD', 'NEVER',      NULL,              5, true, false);

-- -------------------------------------------------------------
-- lkp_scope_type
-- Scope of a payroll calculation pass
-- -------------------------------------------------------------
INSERT INTO lkp_scope_type (code, label, description, is_retroactive, requires_date_range, affects_prior_periods, sort_order, is_active, is_default) VALUES
  ('FULL',      'Full',      'Full calculation of all active employees in the run',                false, false, false, 1, true, true),
  ('CATCH_UP',  'Catch-Up',  'Catch-up calculation for employees missed in the base run',         false, false, false, 2, true, false),
  ('RETRO',     'Retro',     'Retroactive recalculation covering one or more prior periods',       true,  true,  true,  3, true, false),
  ('RECOVERY',  'Recovery',  'Recovery calculation for errors in a prior run — no period impact',  true,  true,  false, 4, true, false);

-- -------------------------------------------------------------
-- lkp_scope_status
-- Lifecycle of a processing scope / batch
-- -------------------------------------------------------------
INSERT INTO lkp_scope_status (code, label, description, is_runnable, is_editable, is_error_state, sort_order, is_active, is_default) VALUES
  ('DRAFT',      'Draft',      'Scope defined but not yet validated',                     false, true,  false, 1, true, true),
  ('VALIDATED',  'Validated',  'Scope parameters validated — ready to mark ready',        false, true,  false, 2, true, false),
  ('READY',      'Ready',      'Scope locked and ready to submit for processing',          true,  false, false, 3, true, false),
  ('RUNNING',    'Running',    'Scope is actively being processed by the calc engine',    false, false, false, 4, true, false),
  ('COMPLETED',  'Completed',  'Scope processing completed successfully',                  false, false, false, 5, true, false),
  ('FAILED',     'Failed',     'Scope encountered an unrecoverable processing error',      false, false, true,  6, true, false),
  ('CANCELLED',  'Cancelled',  'Scope was cancelled before processing',                   false, false, false, 7, true, false);

-- -------------------------------------------------------------
-- lkp_population_method
-- How the employee population for a run is determined
-- -------------------------------------------------------------
INSERT INTO lkp_population_method (code, label, description, is_dynamic, supports_preview, supports_override, sort_order, is_active, is_default) VALUES
  ('EXPLICIT',   'Explicit',   'Population is a fixed list of employment IDs specified at run setup',  false, true,  true,  1, true, true),
  ('QUERY',      'Query',      'Population resolved dynamically at runtime from payroll context rules', true,  true,  false, 2, true, false),
  ('EXCEPTION',  'Exception',  'Population is the set of employees with unresolved exceptions',         true,  false, false, 3, true, false);

-- -------------------------------------------------------------
-- lkp_funding_status
-- Whether employer bank draw succeeded
-- -------------------------------------------------------------
INSERT INTO lkp_funding_status (code, label, description, is_complete, allows_disbursement, is_error_state, sort_order, is_active, is_default) VALUES
  ('FUNDED',            'Funded',            'Full funding draw confirmed by bank',                      true,  true,  false, 1, true, true),
  ('PARTIALLY_FUNDED',  'Partially Funded',  'Partial funding received — some disbursements may proceed', false, true,  false, 2, true, false),
  ('FAILED',            'Failed',            'Funding draw failed — disbursement blocked',                false, false, true,  3, true, false);

-- -------------------------------------------------------------
-- lkp_remittance_status
-- Status of a tax or benefit remittance to an agency/vendor
-- -------------------------------------------------------------
INSERT INTO lkp_remittance_status (code, label, description, is_transmitted, is_accepted, is_error_state, sort_order, is_active, is_default) VALUES
  ('PREPARED',     'Prepared',     'Remittance file prepared — not yet released',          false, false, false, 1, true, true),
  ('RELEASED',     'Released',     'Remittance released for transmission',                 false, false, false, 2, true, false),
  ('TRANSMITTED',  'Transmitted',  'Remittance transmitted to receiving agency or vendor', true,  false, false, 3, true, false),
  ('ACCEPTED',     'Accepted',     'Receiving party confirmed receipt and acceptance',      true,  true,  false, 4, true, false),
  ('REJECTED',     'Rejected',     'Receiving party rejected the remittance',              true,  false, true,  5, true, false);

-- -------------------------------------------------------------
-- lkp_disbursement_status
-- Status of an employee payment through bank settlement
-- -------------------------------------------------------------
INSERT INTO lkp_disbursement_status (code, label, description, is_released, is_settled, is_error_state, sort_order, is_active, is_default) VALUES
  ('PREPARED',  'Prepared',  'Disbursement record created — not yet released to bank',    false, false, false, 1, true, true),
  ('RELEASED',  'Released',  'Funds released to ACH/banking pipeline',                    true,  false, false, 2, true, false),
  ('SETTLED',   'Settled',   'Transfer fully settled — funds available to employee',       true,  true,  false, 3, true, false),
  ('RETURNED',  'Returned',  'ACH return received (NSF, invalid account, etc.)',           true,  false, true,  4, true, false);
