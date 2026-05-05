-- Phase 4.10: Onboarding Blocking Task Gate
-- Adds blocking_tasks_cleared to payroll_profile.
-- New hires start FALSE; the OnboardingBlockingTasksCompletePayload handler sets it TRUE.
-- Existing profiles are backfilled to TRUE — they predate the gate and are already payable.

ALTER TABLE payroll_profile
    ADD COLUMN IF NOT EXISTS blocking_tasks_cleared BOOLEAN NOT NULL DEFAULT FALSE;

-- Backfill: every profile that existed before this migration is considered cleared
UPDATE payroll_profile
SET blocking_tasks_cleared = TRUE
WHERE blocking_tasks_cleared = FALSE;

COMMENT ON COLUMN payroll_profile.blocking_tasks_cleared IS
    'Set TRUE when OnboardingBlockingTasksCompletePayload received for this employment. '
    'Employees with FALSE are excluded from payroll run population.';
