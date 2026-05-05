-- =============================================================
-- AllWorkHRIS — Reference Data Seed Script
-- Run against allworkhris_dev to enable hire workflow testing
-- =============================================================

-- Legal Entity
INSERT INTO org_unit (
    org_unit_id, org_unit_type, org_unit_code, org_unit_name,
    parent_org_unit_id, org_status, effective_start_date,
    country_code, state_of_incorporation, legal_entity_type,
    created_by, creation_timestamp, last_updated_by, last_update_timestamp
) VALUES (
    '10000000-0000-0000-0000-000000000001',
    'LEGAL_ENTITY',
    'LE-001',
    'AllWork Demo Company LLC',
    NULL,
    'ACTIVE',
    '2024-01-01',
    'US',
    'DE',
    'LLC',
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    '00000000-0000-0000-0000-000000000001',
    NOW()
);

-- Division
INSERT INTO org_unit (
    org_unit_id, org_unit_type, org_unit_code, org_unit_name,
    parent_org_unit_id, org_status, effective_start_date,
    created_by, creation_timestamp, last_updated_by, last_update_timestamp
) VALUES (
    '10000000-0000-0000-0000-000000000002',
    'DIVISION',
    'DIV-OPS',
    'Operations',
    '10000000-0000-0000-0000-000000000001',
    'ACTIVE',
    '2024-01-01',
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    '00000000-0000-0000-0000-000000000001',
    NOW()
);

-- Department
INSERT INTO org_unit (
    org_unit_id, org_unit_type, org_unit_code, org_unit_name,
    parent_org_unit_id, org_status, effective_start_date,
    created_by, creation_timestamp, last_updated_by, last_update_timestamp
) VALUES (
    '10000000-0000-0000-0000-000000000003',
    'DEPARTMENT',
    'DEPT-HR',
    'Human Resources',
    '10000000-0000-0000-0000-000000000002',
    'ACTIVE',
    '2024-01-01',
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    '00000000-0000-0000-0000-000000000001',
    NOW()
);

-- Location
INSERT INTO org_unit (
    org_unit_id, org_unit_type, org_unit_code, org_unit_name,
    parent_org_unit_id, org_status, effective_start_date,
    work_location_type, address_line_1, city, state_code, postal_code,
    created_by, creation_timestamp, last_updated_by, last_update_timestamp
) VALUES (
    '10000000-0000-0000-0000-000000000004',
    'LOCATION',
    'LOC-HQ',
    'Headquarters',
    '10000000-0000-0000-0000-000000000001',
    'ACTIVE',
    '2024-01-01',
    'OFFICE',
    '123 Main Street',
    'Atlanta',
    'GA',
    '30301',
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    '00000000-0000-0000-0000-000000000001',
    NOW()
);

-- Job
INSERT INTO job (
    job_id, job_code, job_title, job_family, job_level,
    flsa_classification, eeo_category, job_status,
    effective_start_date,
    created_by, creation_timestamp, last_updated_by, last_update_timestamp
) VALUES (
    '20000000-0000-0000-0000-000000000001',
    'JOB-HR-MGR',
    'HR Manager',
    'Human Resources',
    'Manager',
    'EXEMPT',
    'FIRST_MID_OFFICIALS',
    'ACTIVE',
    '2024-01-01',
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    '00000000-0000-0000-0000-000000000001',
    NOW()
);

INSERT INTO job (
    job_id, job_code, job_title, job_family, job_level,
    flsa_classification, eeo_category, job_status,
    effective_start_date,
    created_by, creation_timestamp, last_updated_by, last_update_timestamp
) VALUES (
    '20000000-0000-0000-0000-000000000002',
    'JOB-SW-ENG',
    'Software Engineer',
    'Technology',
    'Individual Contributor',
    'EXEMPT',
    'PROFESSIONALS',
    'ACTIVE',
    '2024-01-01',
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    '00000000-0000-0000-0000-000000000001',
    NOW()
);

INSERT INTO job (
    job_id, job_code, job_title, job_family, job_level,
    flsa_classification, eeo_category, job_status,
    effective_start_date,
    created_by, creation_timestamp, last_updated_by, last_update_timestamp
) VALUES (
    '20000000-0000-0000-0000-000000000003',
    'JOB-PAYROLL',
    'Payroll Specialist',
    'Finance',
    'Individual Contributor',
    'NON_EXEMPT',
    'ADMIN_SUPPORT',
    'ACTIVE',
    '2024-01-01',
    '00000000-0000-0000-0000-000000000001',
    NOW(),
    '00000000-0000-0000-0000-000000000001',
    NOW()
);
