-- Migration 006: payroll_run_exception table
-- Records employees excluded from a payroll run, with a reason code.
-- This is the queryable complement to the Serilog warning written by PayrollRunJob.

CREATE TABLE payroll_run_exception (
    run_exception_id  UUID         NOT NULL DEFAULT gen_random_uuid(),
    run_id            UUID         NOT NULL,
    employment_id     UUID         NOT NULL,
    exception_code    VARCHAR(50)  NOT NULL,
    exception_message VARCHAR(500) NULL,
    created_timestamp TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_payroll_run_exception PRIMARY KEY (run_exception_id),
    CONSTRAINT fk_pre_run FOREIGN KEY (run_id) REFERENCES payroll_run (run_id)
);

CREATE INDEX ix_pre_run_id          ON payroll_run_exception (run_id);
CREATE INDEX ix_pre_run_employment   ON payroll_run_exception (run_id, employment_id);
CREATE INDEX ix_pre_exception_code   ON payroll_run_exception (exception_code);
