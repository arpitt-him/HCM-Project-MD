-- Migration 009 — Benefits Minimum Module
-- Creates: deduction_code, benefit_deduction_election, benefit_configuration_audit_log

CREATE TABLE deduction_code (
    code_id                     uuid            NOT NULL DEFAULT gen_random_uuid(),
    code                        varchar(30)     NOT NULL,
    description                 varchar(200)    NOT NULL,
    tax_treatment               varchar(10)     NOT NULL,   -- PRE_TAX | POST_TAX
    status                      varchar(20)     NOT NULL DEFAULT 'ACTIVE',  -- ACTIVE | INACTIVE
    effective_start_date        date            NOT NULL,
    effective_end_date          date,
    created_at                  timestamptz     NOT NULL DEFAULT now(),
    updated_at                  timestamptz     NOT NULL DEFAULT now(),
    CONSTRAINT pk_deduction_code PRIMARY KEY (code_id),
    CONSTRAINT uq_deduction_code_code UNIQUE (code),
    CONSTRAINT ck_deduction_code_tax_treatment CHECK (tax_treatment IN ('PRE_TAX','POST_TAX')),
    CONSTRAINT ck_deduction_code_status CHECK (status IN ('ACTIVE','INACTIVE'))
);

CREATE TABLE benefit_deduction_election (
    election_id                 uuid            NOT NULL DEFAULT gen_random_uuid(),
    employment_id               uuid            NOT NULL,
    deduction_code              varchar(30)     NOT NULL,
    tax_treatment               varchar(10)     NOT NULL,
    employee_amount             numeric(12,4)   NOT NULL,
    employer_contribution_amount numeric(12,4),
    effective_start_date        date            NOT NULL,
    effective_end_date          date,
    status                      varchar(20)     NOT NULL,  -- PENDING | ACTIVE | SUSPENDED | SUPERSEDED | TERMINATED
    source                      varchar(10)     NOT NULL,  -- MANUAL | IMPORT | API
    created_by                  varchar(200)    NOT NULL,
    created_at                  timestamptz     NOT NULL DEFAULT now(),
    updated_at                  timestamptz     NOT NULL DEFAULT now(),
    election_version_id         uuid            NOT NULL DEFAULT gen_random_uuid(),
    original_election_id        uuid,
    parent_election_id          uuid,
    correction_type             varchar(30),               -- AMOUNT_CHANGE | DATE_CHANGE | TERMINATION | REINSTATEMENT
    source_event_id             uuid,
    CONSTRAINT pk_benefit_deduction_election PRIMARY KEY (election_id),
    CONSTRAINT ck_election_status CHECK (status IN ('PENDING','ACTIVE','SUSPENDED','SUPERSEDED','TERMINATED')),
    CONSTRAINT ck_election_source CHECK (source IN ('MANUAL','IMPORT','API')),
    CONSTRAINT ck_election_tax_treatment CHECK (tax_treatment IN ('PRE_TAX','POST_TAX'))
);

CREATE INDEX ix_benefit_election_employment_id ON benefit_deduction_election (employment_id);
CREATE INDEX ix_benefit_election_status ON benefit_deduction_election (status);
CREATE INDEX ix_benefit_election_effective ON benefit_deduction_election (effective_start_date, effective_end_date);

CREATE TABLE benefit_configuration_audit_log (
    log_id          uuid            NOT NULL DEFAULT gen_random_uuid(),
    entity_type     varchar(100)    NOT NULL,
    entity_id       uuid            NOT NULL,
    action          varchar(30)     NOT NULL,
    changed_by      varchar(200)    NOT NULL,
    changed_at      timestamptz     NOT NULL DEFAULT now(),
    before_value    text,
    after_value     text,
    CONSTRAINT pk_benefit_configuration_audit_log PRIMARY KEY (log_id)
);
