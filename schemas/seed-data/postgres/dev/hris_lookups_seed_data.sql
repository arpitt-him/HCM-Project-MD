-- =============================================================
-- HRIS Lookup Tables — Seed Data
-- Run after hris_lookkups_schema.sql
-- FK-typed columns (approval_status_id, flsa_classification_id,
-- payroll_impact_type_id, document_type_id) are left NULL because
-- no FK constraints are enforced in the DDL; populate them in a
-- second pass once all tables are loaded if needed.
-- =============================================================

-- -------------------------------------------------------------
-- lkp_person_status
-- -------------------------------------------------------------
INSERT INTO lkp_person_status (code, label, description, allows_employment, sort_order, is_active, is_default) VALUES
  ('ACTIVE',     'Active',     'Person record is active and in good standing',  true,  1, true,  true),
  ('INACTIVE',   'Inactive',   'Person record is inactive',                     false, 2, true,  false),
  ('DECEASED',   'Deceased',   'Person is deceased',                            false, 3, true,  false),
  ('RESTRICTED', 'Restricted', 'Access restricted — legal or compliance hold',  false, 4, true,  false),
  ('ARCHIVED',   'Archived',   'Record archived — no longer employed',          false, 5, true,  false);

-- -------------------------------------------------------------
-- lkp_employee_event_type
-- -------------------------------------------------------------
INSERT INTO lkp_employee_event_type (code, label, description, event_category, is_separation, triggers_onboarding, sort_order, is_active, is_default) VALUES
  ('HIRE',                'Hire',                   'Initial hire event',                                   'ONBOARDING',   false, true,  1,  true, true),
  ('REHIRE',              'Rehire',                  'Re-employment after separation',                       'ONBOARDING',   false, true,  2,  true, false),
  ('TERMINATION',         'Termination',             'Voluntary or involuntary end of employment',           'SEPARATION',   true,  false, 3,  true, false),
  ('RESIGNATION',         'Resignation',             'Voluntary separation initiated by employee',           'SEPARATION',   true,  false, 4,  true, false),
  ('RETIREMENT',          'Retirement',              'Employee retirement',                                  'SEPARATION',   true,  false, 5,  true, false),
  ('TRANSFER',            'Transfer',                'Transfer to new department, location, or role',        'MOVEMENT',     false, false, 6,  true, false),
  ('PROMOTION',           'Promotion',               'Advancement to a higher-level role',                  'MOVEMENT',     false, false, 7,  true, false),
  ('DEMOTION',            'Demotion',                'Movement to a lower-level role',                      'MOVEMENT',     false, false, 8,  true, false),
  ('COMPENSATION_CHANGE', 'Compensation Change',     'Change to base rate, rate type, or pay frequency',    'COMPENSATION', false, false, 9,  true, false),
  ('MANAGER_CHANGE',      'Manager Change',          'Change of reporting manager',                          'MOVEMENT',     false, false, 10, true, false),
  ('LOA_START',           'Leave of Absence Start',  'Employee commences a leave of absence',               'LEAVE',        false, false, 11, true, false),
  ('LOA_RETURN',          'Leave of Absence Return', 'Employee returns from leave of absence',              'LEAVE',        false, false, 12, true, false);

-- -------------------------------------------------------------
-- lkp_employment_type
-- -------------------------------------------------------------
INSERT INTO lkp_employment_type (code, label, description, is_w2, benefits_eligible, sort_order, is_active, is_default) VALUES
  ('EMPLOYEE',   'Employee',   'Regular W-2 employee',               true,  true,  1, true, true),
  ('CONTRACTOR', 'Contractor', '1099 independent contractor',        false, false, 2, true, false),
  ('INTERN',     'Intern',     'Internship — may be paid or unpaid', true,  false, 3, true, false),
  ('SEASONAL',   'Seasonal',   'Seasonal or temporary W-2 worker',  true,  false, 4, true, false),
  ('VOLUNTEER',  'Volunteer',  'Unpaid volunteer',                   false, false, 5, true, false);

-- -------------------------------------------------------------
-- lkp_employment_status
-- -------------------------------------------------------------
INSERT INTO lkp_employment_status (code, label, description, is_payroll_active, sort_order, is_active, is_default) VALUES
  ('ACTIVE',     'Active',     'Actively employed',                          true,  1, true, true),
  ('ON_LEAVE',   'On Leave',   'On approved leave of absence',               true,  2, true, false),
  ('SUSPENDED',  'Suspended',  'Employment suspended pending investigation',  false, 3, true, false),
  ('TERMINATED', 'Terminated', 'Employment ended',                           false, 4, true, false),
  ('RETIRED',    'Retired',    'Retired — inactive employment record',        false, 5, true, false),
  ('CLOSED',     'Closed',     'Record administratively closed',             false, 6, true, false);

-- -------------------------------------------------------------
-- lkp_full_part_time_status
-- -------------------------------------------------------------
INSERT INTO lkp_full_part_time_status (code, label, description, min_hours_week, max_hours_week, benefits_eligible, sort_order, is_active, is_default) VALUES
  ('FULL_TIME', 'Full Time',      'Regularly scheduled 30+ hours per week',     30.00, null,  true,  1, true, true),
  ('PART_TIME', 'Part Time',      'Regularly scheduled fewer than 30 hours',     0.00, 29.99, false, 2, true, false),
  ('PRN',       'PRN / As Needed','Per diem or as-needed scheduling',             0.00, null,  false, 3, true, false),
  ('ON_CALL',   'On Call',        'On-call scheduling',                           0.00, null,  false, 4, true, false);

-- -------------------------------------------------------------
-- lkp_regular_temporary_status
-- -------------------------------------------------------------
INSERT INTO lkp_regular_temporary_status (code, label, description, has_end_date, sort_order, is_active, is_default) VALUES
  ('REGULAR',       'Regular',       'Regular indefinite employment',        false, 1, true, true),
  ('TEMPORARY',     'Temporary',     'Fixed-term temporary employment',      true,  2, true, false),
  ('SEASONAL',      'Seasonal',      'Seasonal employment with defined end', true,  3, true, false),
  ('PROJECT_BASED', 'Project Based', 'Employment tied to a specific project',true,  4, true, false);

-- -------------------------------------------------------------
-- lkp_flsa_classification
-- -------------------------------------------------------------
INSERT INTO lkp_flsa_classification (code, label, description, overtime_eligible, sort_order, is_active, is_default) VALUES
  ('EXECUTIVE',          'Executive',          'FLSA executive exemption',          false, 1, true, false),
  ('ADMINISTRATIVE',     'Administrative',     'FLSA administrative exemption',     false, 2, true, false),
  ('PROFESSIONAL',       'Professional',       'FLSA professional exemption',       false, 3, true, false),
  ('COMPUTER',           'Computer Employee',  'FLSA computer employee exemption',  false, 4, true, false),
  ('OUTSIDE_SALES',      'Outside Sales',      'FLSA outside sales exemption',      false, 5, true, false),
  ('HIGHLY_COMPENSATED', 'Highly Compensated', 'FLSA highly compensated exemption', false, 6, true, false),
  ('NON_EXEMPT',         'Non-Exempt',         'Subject to FLSA overtime rules',    true,  7, true, true);

-- -------------------------------------------------------------
-- lkp_flsa_status
-- (flsa_classification_id left NULL — no enforced FK constraint)
-- -------------------------------------------------------------
INSERT INTO lkp_flsa_status (code, label, description, flsa_classification_id, overtime_eligible, sort_order, is_active, is_default) VALUES
  ('EXEMPT',          'Exempt',               'Exempt from FLSA overtime requirements', null, false, 1, true, false),
  ('NON_EXEMPT',      'Non-Exempt',           'Subject to FLSA overtime requirements',  null, true,  2, true, true),
  ('EXEMPT_ADMIN',    'Exempt — Admin',       'Administrative exemption',               null, false, 3, true, false),
  ('EXEMPT_PROF',     'Exempt — Professional','Professional exemption',                 null, false, 4, true, false),
  ('EXEMPT_COMPUTER', 'Exempt — Computer',    'Computer employee exemption',            null, false, 5, true, false),
  ('EXEMPT_SALES',    'Exempt — Sales',       'Outside sales exemption',                null, false, 6, true, false),
  ('EXEMPT_HCE',      'Exempt — HCE',         'Highly compensated employee exemption',  null, false, 7, true, false);

-- -------------------------------------------------------------
-- lkp_eeo_category
-- -------------------------------------------------------------
INSERT INTO lkp_eeo_category (code, label, description, eeo1_category_num, sort_order, is_active, is_default) VALUES
  ('EXEC_SR_OFFICIALS',   'Executive/Senior Officials & Managers', 'EEO-1 Category 1.1', '1.1', 1,  true, false),
  ('FIRST_MID_OFFICIALS', 'First/Mid-Level Officials & Managers',  'EEO-1 Category 1.2', '1.2', 2,  true, false),
  ('PROFESSIONALS',       'Professionals',                          'EEO-1 Category 2',   '2',   3,  true, true),
  ('TECHNICIANS',         'Technicians',                            'EEO-1 Category 3',   '3',   4,  true, false),
  ('SALES_WORKERS',       'Sales Workers',                          'EEO-1 Category 4',   '4',   5,  true, false),
  ('ADMIN_SUPPORT',       'Administrative Support Workers',         'EEO-1 Category 5',   '5',   6,  true, false),
  ('CRAFT_WORKERS',       'Craft Workers',                          'EEO-1 Category 6',   '6',   7,  true, false),
  ('OPERATIVES',          'Operatives',                             'EEO-1 Category 7',   '7',   8,  true, false),
  ('LABORERS_HELPERS',    'Laborers & Helpers',                     'EEO-1 Category 8',   '8',   9,  true, false),
  ('SERVICE_WORKERS',     'Service Workers',                        'EEO-1 Category 9',   '9',   10, true, false);

-- -------------------------------------------------------------
-- lkp_assignment_type
-- -------------------------------------------------------------
INSERT INTO lkp_assignment_type (code, label, description, is_primary, allows_overlap, sort_order, is_active, is_default) VALUES
  ('PRIMARY',   'Primary',   'Primary home assignment',          true,  false, 1, true, true),
  ('SECONDARY', 'Secondary', 'Secondary or additional assignment',false, true,  2, true, false),
  ('ACTING',    'Acting',    'Acting or interim role assignment', false, false, 3, true, false),
  ('INTERIM',   'Interim',   'Interim assignment pending hire',  false, false, 4, true, false);

-- -------------------------------------------------------------
-- lkp_assignment_status
-- -------------------------------------------------------------
INSERT INTO lkp_assignment_status (code, label, description, is_active_state, sort_order, is_active, is_default) VALUES
  ('ACTIVE',    'Active',    'Currently active assignment',       true,  1, true, true),
  ('PENDING',   'Pending',   'Assignment not yet effective',      false, 2, true, false),
  ('SUSPENDED', 'Suspended', 'Assignment temporarily suspended',  false, 3, true, false),
  ('ENDED',     'Ended',     'Assignment has ended',              false, 4, true, false);

-- -------------------------------------------------------------
-- lkp_compensation_rate_type
-- -------------------------------------------------------------
INSERT INTO lkp_compensation_rate_type (code, label, description, is_annualized, unit_of_measure, sort_order, is_active, is_default) VALUES
  ('SALARY',     'Salary',     'Annual salary',                            true,  'YEAR',    1, true, false),
  ('HOURLY',     'Hourly',     'Hourly rate of pay',                       false, 'HOUR',    2, true, true),
  ('DAILY',      'Daily',      'Daily rate of pay',                        false, 'DAY',     3, true, false),
  ('CONTRACT',   'Contract',   'Contract or project-based rate',           false, 'PERIOD',  4, true, false),
  ('COMMISSION', 'Commission', 'Commission-based compensation',             false, 'PERCENT', 5, true, false),
  ('STIPEND',    'Stipend',    'Fixed periodic stipend',                    false, 'PERIOD',  6, true, false);

-- -------------------------------------------------------------
-- lkp_approval_status
-- (inserted before tables that reference it)
-- -------------------------------------------------------------
INSERT INTO lkp_approval_status (code, label, description, is_approved_state, sort_order, is_active, is_default) VALUES
  ('DRAFT',     'Draft',     'Not yet submitted for approval', false, 1, true, true),
  ('PENDING',   'Pending',   'Awaiting approval',              false, 2, true, false),
  ('APPROVED',  'Approved',  'Approved',                       true,  3, true, false),
  ('REJECTED',  'Rejected',  'Rejected — requires revision',   false, 4, true, false),
  ('CANCELLED', 'Cancelled', 'Cancelled by submitter',         false, 5, true, false),
  ('ESCALATED', 'Escalated', 'Escalated to higher authority',  false, 6, true, false);

-- -------------------------------------------------------------
-- lkp_compensation_status
-- -------------------------------------------------------------
INSERT INTO lkp_compensation_status (code, label, description, approval_status_id, is_payable, sort_order, is_active, is_default) VALUES
  ('PROPOSED', 'Proposed', 'Proposed — pending approval',   null, false, 1, true, false),
  ('APPROVED', 'Approved', 'Approved — not yet effective',  null, false, 2, true, false),
  ('ACTIVE',   'Active',   'Effective and payable',         null, true,  3, true, true),
  ('FROZEN',   'Frozen',   'Temporarily frozen',            null, false, 4, true, false),
  ('ENDED',    'Ended',    'Superseded or expired',         null, false, 5, true, false);

-- -------------------------------------------------------------
-- lkp_pay_frequency
-- -------------------------------------------------------------
INSERT INTO lkp_pay_frequency (code, label, description, periods_per_year, sort_order, is_active, is_default) VALUES
  ('WEEKLY',       'Weekly',       '52 pay periods per year', 52, 1, true, false),
  ('BIWEEKLY',     'Biweekly',     '26 pay periods per year', 26, 2, true, true),
  ('SEMI_MONTHLY', 'Semi-Monthly', '24 pay periods per year', 24, 3, true, false),
  ('MONTHLY',      'Monthly',      '12 pay periods per year', 12, 4, true, false),
  ('QUARTERLY',    'Quarterly',    '4 pay periods per year',   4, 5, true, false),
  ('ANNUAL',       'Annual',       '1 pay period per year',    1, 6, true, false);

-- -------------------------------------------------------------
-- lkp_payroll_impact_type
-- -------------------------------------------------------------
INSERT INTO lkp_payroll_impact_type (code, label, description, affects_gross_pay, pay_percentage, sort_order, is_active, is_default) VALUES
  ('PAID',           'Paid',           'Full pay maintained',               true,  100.00, 1, true, true),
  ('UNPAID',         'Unpaid',         'No pay during period',              true,    0.00, 2, true, false),
  ('PARTIAL_PAY',    'Partial Pay',    'Reduced pay — 50% default',         true,   50.00, 3, true, false),
  ('REDUCED_RATE',   'Reduced Rate',   'Pay at a negotiated reduced rate',  true,   null,  4, true, false),
  ('COMPANY_FUNDED', 'Company Funded', 'Company-funded leave benefit',      false,  null,  5, true, false),
  ('STATE_FUNDED',   'State Funded',   'State disability or leave benefit', false,  null,  6, true, false);

-- -------------------------------------------------------------
-- lkp_leave_type
-- (payroll_impact_type_id left NULL — populate in second pass)
-- -------------------------------------------------------------
INSERT INTO lkp_leave_type (code, label, description, payroll_impact_type_id, is_accrued, is_protected, requires_documentation, max_days_per_year, sort_order, is_active, is_default) VALUES
  ('VACATION',    'Vacation',            'Accrued vacation leave',                     null, true,  false, false, null, 1,  true, true),
  ('SICK',        'Sick Leave',          'Accrued sick leave',                         null, true,  false, false, null, 2,  true, false),
  ('PTO',         'PTO',                 'Paid time off (combined accrual)',            null, true,  false, false, null, 3,  true, false),
  ('PERSONAL',    'Personal Leave',      'Personal days',                              null, false, false, false, 3,    4,  true, false),
  ('FMLA',        'FMLA',                'Family and Medical Leave Act leave',         null, false, true,  true,  60,   5,  true, false),
  ('BEREAVEMENT', 'Bereavement',         'Bereavement leave',                          null, false, false, true,  5,    6,  true, false),
  ('JURY_DUTY',   'Jury Duty',           'Court-ordered jury service',                 null, false, true,  true,  null, 7,  true, false),
  ('MILITARY',    'Military Leave',      'USERRA-protected military service leave',     null, false, true,  true,  null, 8,  true, false),
  ('STD',         'Short-Term Disability','Short-term disability leave',               null, false, true,  true,  null, 9,  true, false),
  ('LTD',         'Long-Term Disability', 'Long-term disability leave',                null, false, true,  true,  null, 10, true, false),
  ('UNPAID',      'Unpaid Leave',         'Unpaid personal leave of absence',          null, false, false, true,  null, 11, true, false);

-- -------------------------------------------------------------
-- lkp_leave_status
-- -------------------------------------------------------------
INSERT INTO lkp_leave_status (code, label, description, approval_status_id, is_on_leave, sort_order, is_active, is_default) VALUES
  ('REQUESTED',   'Requested',   'Leave request submitted',              null, false, 1, true, true),
  ('APPROVED',    'Approved',    'Leave approved — not yet started',     null, false, 2, true, false),
  ('IN_PROGRESS', 'In Progress', 'Employee currently on leave',          null, true,  3, true, false),
  ('COMPLETED',   'Completed',   'Leave period ended, employee returned', null, false, 4, true, false),
  ('DENIED',      'Denied',      'Leave request denied',                 null, false, 5, true, false),
  ('CANCELLED',   'Cancelled',   'Leave cancelled before start',         null, false, 6, true, false);

-- -------------------------------------------------------------
-- lkp_document_type
-- -------------------------------------------------------------
INSERT INTO lkp_document_type (code, label, description, requires_signature, retention_days, is_employee_visible, sort_order, is_active, is_default) VALUES
  ('OFFER_LETTER',       'Offer Letter',           'Employment offer letter',              true,  2555, true,  1,  true, false),
  ('I9',                 'Form I-9',               'Employment eligibility verification',  false, 2555, true,  2,  true, false),
  ('W4',                 'Form W-4',               'Employee withholding certificate',     false, 2555, true,  3,  true, false),
  ('NDA',                'Non-Disclosure Agreement','Confidentiality agreement',           true,  3650, false, 4,  true, false),
  ('PERFORMANCE_REVIEW', 'Performance Review',     'Annual performance evaluation',        false, 1825, true,  5,  true, false),
  ('POLICY_ACK',         'Policy Acknowledgment',  'Policy receipt acknowledgment',        true,  1825, true,  6,  true, false),
  ('CONTRACT',           'Employment Contract',    'Formal employment contract',            true,  3650, true,  7,  true, false),
  ('CERTIFICATION',      'Certification',          'Professional certification document',  false, 1095, true,  8,  true, false),
  ('LICENSE',            'License',                'Professional license document',        false, 1095, true,  9,  true, false),
  ('OTHER',              'Other',                  'Other HR document',                    false, 1095, true,  10, true, true);

-- -------------------------------------------------------------
-- lkp_document_status
-- -------------------------------------------------------------
INSERT INTO lkp_document_status (code, label, description, approval_status_id, is_valid, sort_order, is_active, is_default) VALUES
  ('DRAFT',             'Draft',            'Document is in draft',           null, false, 1, true, true),
  ('PENDING_SIGNATURE', 'Pending Signature','Awaiting signature',             null, false, 2, true, false),
  ('SIGNED',            'Signed',           'Fully executed document',        null, true,  3, true, false),
  ('ACTIVE',            'Active',           'Active and valid document',      null, true,  4, true, false),
  ('EXPIRED',           'Expired',          'Document has expired',           null, false, 5, true, false),
  ('ARCHIVED',          'Archived',         'Document archived',              null, false, 6, true, false),
  ('VOIDED',            'Voided',           'Document voided',                null, false, 7, true, false),
  ('SUPERSEDED',        'Superseded',       'Replaced by a newer version',    null, false, 8, true, false);

-- -------------------------------------------------------------
-- lkp_onboarding_plan_status
-- -------------------------------------------------------------
INSERT INTO lkp_onboarding_plan_status (code, label, description, sort_order, is_active, is_default) VALUES
  ('NOT_STARTED',       'Not Started',       'Plan created but not begun',                     1, true, true),
  ('IN_PROGRESS',       'In Progress',       'Onboarding tasks underway',                      2, true, false),
  ('BLOCKING_COMPLETE', 'Blocking Complete', 'All blocking tasks done, non-blocking remain',   3, true, false),
  ('COMPLETED',         'Completed',         'All tasks completed',                             4, true, false),
  ('ON_HOLD',           'On Hold',           'Plan paused',                                    5, true, false),
  ('CANCELLED',         'Cancelled',         'Onboarding plan cancelled',                      6, true, false);

-- -------------------------------------------------------------
-- lkp_onboarding_task_type
-- (document_type_id left NULL — populate in second pass)
-- -------------------------------------------------------------
INSERT INTO lkp_onboarding_task_type (code, label, description, document_type_id, default_due_days, is_employee_action, is_blocking, sort_order, is_active, is_default) VALUES
  ('DOCUMENT_SUBMISSION', 'Document Submission',  'Employee submits required document',    null, 3,  true,  true,  1, true, false),
  ('TRAINING',            'Training',             'Required training completion',           null, 30, true,  false, 2, true, false),
  ('EQUIPMENT_SETUP',     'Equipment Setup',      'IT equipment provisioning',             null, 1,  false, true,  3, true, false),
  ('SYSTEM_ACCESS',       'System Access',        'Account and system access setup',       null, 1,  false, true,  4, true, false),
  ('ORIENTATION',         'Orientation',          'New hire orientation session',          null, 3,  true,  false, 5, true, false),
  ('MENTOR_ASSIGNMENT',   'Mentor Assignment',    'Onboarding buddy/mentor pairing',       null, 1,  false, false, 6, true, false),
  ('BENEFITS_ENROLLMENT', 'Benefits Enrollment',  'Benefits election and enrollment',      null, 30, true,  false, 7, true, false),
  ('POLICY_ACK',          'Policy Acknowledgment','Policy review and acknowledgment',      null, 5,  true,  false, 8, true, true);

-- -------------------------------------------------------------
-- lkp_onboarding_task_status
-- -------------------------------------------------------------
INSERT INTO lkp_onboarding_task_status (code, label, description, approval_status_id, is_complete_state, sort_order, is_active, is_default) VALUES
  ('PENDING',     'Pending',     'Task not yet started',                null, false, 1, true, true),
  ('IN_PROGRESS', 'In Progress', 'Task started but not completed',      null, false, 2, true, false),
  ('COMPLETED',   'Completed',   'Task successfully completed',         null, true,  3, true, false),
  ('SKIPPED',     'Skipped',     'Task skipped — not applicable',       null, true,  4, true, false),
  ('OVERDUE',     'Overdue',     'Task past due date and not complete', null, false, 5, true, false),
  ('BLOCKED',     'Blocked',     'Task blocked by dependency',          null, false, 6, true, false),
  ('WAIVED',      'Waived',      'Task waived by HR',                   null, true,  7, true, false);

-- -------------------------------------------------------------
-- lkp_org_unit_type
-- -------------------------------------------------------------
INSERT INTO lkp_org_unit_type (code, label, description, allows_children, sort_order, is_active, is_default) VALUES
  ('LEGAL_ENTITY',  'Legal Entity',  'Incorporated legal entity',          true,  1, true, false),
  ('COMPANY',       'Company',       'Operating company or subsidiary',    true,  2, true, false),
  ('DIVISION',      'Division',      'Major business division',            true,  3, true, false),
  ('BUSINESS_UNIT', 'Business Unit', 'Strategic business unit',            true,  4, true, false),
  ('DEPARTMENT',    'Department',    'Functional department',              true,  5, true, true),
  ('TEAM',          'Team',          'Working team within a department',   false, 6, true, false),
  ('COST_CENTER',   'Cost Center',   'Financial cost center',              false, 7, true, false),
  ('LOCATION',      'Location',      'Physical or virtual work location',  false, 8, true, false),
  ('REGION',        'Region',        'Geographic region',                  true,  9, true, false);

-- -------------------------------------------------------------
-- lkp_org_status
-- -------------------------------------------------------------
INSERT INTO lkp_org_status (code, label, description, is_operational, sort_order, is_active, is_default) VALUES
  ('ACTIVE',             'Active',             'Org unit is active and operational', true,  1, true, true),
  ('INACTIVE',           'Inactive',           'Org unit is inactive',               false, 2, true, false),
  ('PENDING_ACTIVATION', 'Pending Activation', 'Created but not yet active',         false, 3, true, false),
  ('MERGED',             'Merged',             'Merged into another org unit',       false, 4, true, false),
  ('DISSOLVED',          'Dissolved',          'Org unit has been dissolved',        false, 5, true, false),
  ('ARCHIVED',           'Archived',           'Archived — historical record only',  false, 6, true, false);

-- -------------------------------------------------------------
-- lkp_work_location_type
-- -------------------------------------------------------------
INSERT INTO lkp_work_location_type (code, label, description, is_on_site, requires_address, sort_order, is_active, is_default) VALUES
  ('OFFICE',      'Office',      'Traditional office location',               true,  true,  1, true, true),
  ('REMOTE',      'Remote',      'Full remote — no physical reporting',        false, false, 2, true, false),
  ('HYBRID',      'Hybrid',      'Combination of office and remote',           true,  true,  3, true, false),
  ('FIELD',       'Field',       'Field-based work (sales, service, etc.)',    true,  false, 4, true, false),
  ('CLIENT_SITE', 'Client Site', 'On-site at client premises',                true,  true,  5, true, false),
  ('WAREHOUSE',   'Warehouse',   'Warehouse or distribution center',           true,  true,  6, true, false);

-- -------------------------------------------------------------
-- lkp_job_status
-- -------------------------------------------------------------
INSERT INTO lkp_job_status (code, label, description, is_hirable, sort_order, is_active, is_default) VALUES
  ('ACTIVE',           'Active',           'Job is active and open for hiring',     true,  1, true, true),
  ('FROZEN',           'Frozen',           'Job frozen — no new hires',             false, 2, true, false),
  ('UNDER_REVIEW',     'Under Review',     'Job definition under review',           false, 3, true, false),
  ('PENDING_APPROVAL', 'Pending Approval', 'Awaiting approval to activate',         false, 4, true, false),
  ('INACTIVE',         'Inactive',         'Job inactive — not available for hire', false, 5, true, false),
  ('ABOLISHED',        'Abolished',        'Job title abolished',                   false, 6, true, false);

-- -------------------------------------------------------------
-- lkp_position_status
-- -------------------------------------------------------------
INSERT INTO lkp_position_status (code, label, description, is_fillable, is_occupied, sort_order, is_active, is_default) VALUES
  ('OPEN',           'Open',           'Position is open and fillable',    true,  false, 1, true, true),
  ('FILLED',         'Filled',         'Position is currently occupied',   false, true,  2, true, false),
  ('FROZEN',         'Frozen',         'Position frozen — no hiring',      false, false, 3, true, false),
  ('ABOLISHED',      'Abolished',      'Position permanently eliminated',  false, false, 4, true, false),
  ('PENDING_BUDGET', 'Pending Budget', 'Awaiting budget approval',         false, false, 5, true, false);
