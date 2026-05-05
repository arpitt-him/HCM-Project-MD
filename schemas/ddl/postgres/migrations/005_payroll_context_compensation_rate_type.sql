-- Phase 4: Add compensation_rate_type_id to payroll_context.
-- Nullable — existing contexts are unaffected. No FK constraint: resolved at the
-- application layer via ILookupCache to avoid a hard cross-module schema dependency.

ALTER TABLE payroll_context
    ADD COLUMN IF NOT EXISTS compensation_rate_type_id INTEGER NULL;

COMMENT ON COLUMN payroll_context.compensation_rate_type_id IS
    'FK → lkp_compensation_rate_type.id (SALARY, HOURLY, etc.). '
    'Classifies the compensation basis for employees in this pay group.';
