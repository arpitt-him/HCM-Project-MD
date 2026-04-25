-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-04-25T15:58:26.716Z

CREATE TYPE "run_type" AS ENUM (
  'REGULAR',
  'ADJUSTMENT',
  'CORRECTION',
  'REPROCESSING',
  'SUPPLEMENTAL',
  'SIMULATION'
);

CREATE TYPE "run_status" AS ENUM (
  'DRAFT',
  'OPEN',
  'CALCULATING',
  'CALCULATED',
  'UNDER_REVIEW',
  'APPROVED',
  'RELEASING',
  'RELEASED',
  'CLOSED',
  'FAILED',
  'CANCELLED'
);

CREATE TYPE "result_set_status" AS ENUM (
  'PENDING',
  'CALCULATED',
  'APPROVED',
  'RELEASED',
  'FINALIZED',
  'ARCHIVED'
);

CREATE TYPE "result_set_type" AS ENUM (
  'REGULAR_RUN',
  'OFF_CYCLE',
  'ADJUSTMENT_RUN',
  'CORRECTION_RUN'
);

CREATE TYPE "employee_result_status" AS ENUM (
  'CALCULATED',
  'APPROVED',
  'RELEASED',
  'FINALIZED',
  'CORRECTED',
  'REVERSED'
);

CREATE TYPE "result_class" AS ENUM (
  'EARNING',
  'DEDUCTION',
  'TAX',
  'EMPLOYER_CONTRIBUTION'
);

CREATE TYPE "item_status" AS ENUM (
  'DRAFT',
  'POSTED',
  'VOIDED',
  'CORRECTED'
);

CREATE TYPE "check_status" AS ENUM (
  'DRAFT',
  'GENERATED',
  'RELEASED',
  'VOIDED',
  'REPLACED',
  'RETURNED'
);

CREATE TYPE "payment_method" AS ENUM (
  'DIRECT_DEPOSIT',
  'PRINTED_CHECK',
  'PAYCARD',
  'CASH',
  'MANUAL_CHECK',
  'OTHER'
);

CREATE TYPE "payment_context" AS ENUM (
  'REGULAR',
  'SUPPLEMENTAL',
  'CORRECTION',
  'FINAL_PAY',
  'OFF_CYCLE'
);

CREATE TYPE "impact_status" AS ENUM (
  'CALCULATED',
  'POSTED',
  'REVERSED',
  'CORRECTED',
  'SUPERSEDED'
);

CREATE TYPE "impact_source_type" AS ENUM (
  'EARNINGS_LINE',
  'DEDUCTION_LINE',
  'TAX_LINE',
  'EMPLOYER_CONTRIBUTION_LINE',
  'CORRECTION_LINE',
  'MANUAL_ADJUSTMENT',
  'OTHER'
);

CREATE TYPE "posting_direction" AS ENUM (
  'INCREASE',
  'DECREASE',
  'NEUTRAL',
  'DERIVED'
);

CREATE TYPE "contribution_type" AS ENUM (
  'STANDARD',
  'REVERSAL',
  'CORRECTION',
  'RESET'
);

CREATE TYPE "accumulator_balance_status" AS ENUM (
  'ACTIVE',
  'RESET',
  'ARCHIVED'
);

CREATE TYPE "accumulator_family" AS ENUM (
  'GROSS_WAGES',
  'PRE_TAX_DEDUCTIONS',
  'POST_TAX_DEDUCTIONS',
  'FEDERAL_TAX_WITHHELD',
  'STATE_TAX_WITHHELD',
  'LOCAL_TAX_WITHHELD',
  'SOCIAL_SECURITY',
  'MEDICARE',
  'EMPLOYER_FICA',
  'FUTA',
  'SUI',
  'EMPLOYER_BENEFIT',
  'RETIREMENT',
  'GARNISHMENT_TOTALS'
);

CREATE TYPE "accumulator_scope_type" AS ENUM (
  'EMPLOYEE',
  'EMPLOYER',
  'EMPLOYEE_JURISDICTION',
  'EMPLOYER_JURISDICTION',
  'CLIENT_JURISDICTION'
);

CREATE TYPE "period_context" AS ENUM (
  'PTD',
  'QTD',
  'YTD',
  'PLAN_YEAR',
  'LTD'
);

CREATE TYPE "scope_type" AS ENUM (
  'FULL',
  'CATCH_UP',
  'RETRO',
  'RECOVERY'
);

CREATE TYPE "scope_status" AS ENUM (
  'DRAFT',
  'VALIDATED',
  'READY',
  'RUNNING',
  'COMPLETED',
  'FAILED',
  'CANCELLED'
);

CREATE TYPE "population_method" AS ENUM (
  'EXPLICIT',
  'QUERY',
  'EXCEPTION'
);

CREATE TYPE "funding_status" AS ENUM (
  'FUNDED',
  'PARTIALLY_FUNDED',
  'FAILED'
);

CREATE TYPE "remittance_status" AS ENUM (
  'PREPARED',
  'RELEASED',
  'TRANSMITTED',
  'ACCEPTED',
  'REJECTED'
);

CREATE TYPE "disbursement_status" AS ENUM (
  'PREPARED',
  'RELEASED',
  'SETTLED',
  'RETURNED'
);

CREATE TABLE "payroll_run" (
  "run_id" uuid PRIMARY KEY NOT NULL,
  "payroll_context_id" uuid NOT NULL,
  "period_id" uuid NOT NULL,
  "pay_date" date NOT NULL,
  "run_type" run_type NOT NULL,
  "run_status" run_status NOT NULL,
  "run_description" varchar(500),
  "parent_run_id" uuid,
  "related_run_group_id" uuid,
  "rule_and_config_version_ref" varchar(200),
  "temporal_override_active_flag" boolean DEFAULT false,
  "temporal_override_date" date,
  "initiated_by" uuid NOT NULL,
  "run_start_timestamp" timestamptz,
  "run_end_timestamp" timestamptz,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_updated_by" uuid NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "run_scope" (
  "run_scope_id" uuid PRIMARY KEY NOT NULL,
  "parent_run_id" uuid NOT NULL,
  "payroll_context_id" uuid NOT NULL,
  "scope_type" scope_type NOT NULL,
  "scope_status" scope_status NOT NULL,
  "trigger_reason" varchar(500) NOT NULL,
  "population_method" population_method NOT NULL,
  "population_definition" text NOT NULL,
  "population_count" int NOT NULL,
  "population_resolved_flag" boolean NOT NULL DEFAULT false,
  "resolution_timestamp" timestamptz,
  "exception_derived_flag" boolean DEFAULT false,
  "priority_level" varchar(50) NOT NULL,
  "adjustment_flag" boolean NOT NULL DEFAULT false,
  "execution_start_timestamp" timestamptz,
  "execution_end_timestamp" timestamptz,
  "execution_result" varchar(50),
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "payroll_run_result_set" (
  "payroll_run_result_set_id" uuid PRIMARY KEY NOT NULL,
  "payroll_run_id" uuid NOT NULL,
  "run_scope_id" uuid,
  "source_period_id" uuid NOT NULL,
  "execution_period_id" uuid NOT NULL,
  "parent_payroll_run_result_set_id" uuid,
  "root_payroll_run_result_set_id" uuid,
  "result_set_lineage_sequence" int,
  "correction_reference_id" uuid,
  "result_set_status" result_set_status NOT NULL,
  "result_set_type" result_set_type NOT NULL,
  "execution_start_timestamp" timestamptz,
  "execution_end_timestamp" timestamptz,
  "approval_required_flag" boolean NOT NULL DEFAULT false,
  "approved_by_user_id" uuid,
  "approval_timestamp" timestamptz,
  "finalization_timestamp" timestamptz,
  "created_timestamp" timestamptz NOT NULL,
  "updated_timestamp" timestamptz NOT NULL
);

CREATE TABLE "employee_payroll_result" (
  "employee_payroll_result_id" uuid PRIMARY KEY NOT NULL,
  "payroll_run_result_set_id" uuid NOT NULL,
  "payroll_run_id" uuid NOT NULL,
  "run_scope_id" uuid,
  "employment_id" uuid NOT NULL,
  "person_id" uuid NOT NULL,
  "payroll_context_id" uuid NOT NULL,
  "source_period_id" uuid NOT NULL,
  "execution_period_id" uuid NOT NULL,
  "parent_employee_payroll_result_id" uuid,
  "root_employee_payroll_result_id" uuid,
  "result_lineage_sequence" int,
  "correction_reference_id" uuid,
  "result_status" employee_result_status NOT NULL,
  "pay_period_start_date" date NOT NULL,
  "pay_period_end_date" date NOT NULL,
  "pay_date" date NOT NULL,
  "gross_pay_amount" decimal(18,4) NOT NULL,
  "total_deductions_amount" decimal(18,4) NOT NULL,
  "total_employee_tax_amount" decimal(18,4) NOT NULL,
  "total_employer_contribution_amount" decimal(18,4) NOT NULL,
  "net_pay_amount" decimal(18,4) NOT NULL,
  "created_timestamp" timestamptz NOT NULL,
  "updated_timestamp" timestamptz NOT NULL
);

CREATE TABLE "earnings_result_line" (
  "earnings_result_line_id" uuid PRIMARY KEY NOT NULL,
  "employee_payroll_result_id" uuid NOT NULL,
  "employment_id" uuid NOT NULL,
  "earnings_code" varchar(50) NOT NULL,
  "earnings_description" varchar(200) NOT NULL,
  "quantity" decimal(18,4),
  "rate" decimal(18,4),
  "calculated_amount" decimal(18,4) NOT NULL,
  "jurisdiction_split_flag" boolean NOT NULL DEFAULT false,
  "taxable_flag" boolean NOT NULL,
  "accumulator_impact_flag" boolean NOT NULL DEFAULT false,
  "source_rule_version_id" uuid,
  "correction_flag" boolean NOT NULL DEFAULT false,
  "corrects_line_id" uuid,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "deduction_result_line" (
  "deduction_result_line_id" uuid PRIMARY KEY NOT NULL,
  "employee_payroll_result_id" uuid NOT NULL,
  "employment_id" uuid NOT NULL,
  "deduction_code" varchar(50) NOT NULL,
  "deduction_description" varchar(200) NOT NULL,
  "calculated_amount" decimal(18,4) NOT NULL,
  "pre_tax_flag" boolean NOT NULL,
  "cash_impact_flag" boolean NOT NULL,
  "accumulator_impact_flag" boolean NOT NULL DEFAULT false,
  "source_rule_version_id" uuid,
  "correction_flag" boolean NOT NULL DEFAULT false,
  "corrects_line_id" uuid,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "tax_result_line" (
  "tax_result_line_id" uuid PRIMARY KEY NOT NULL,
  "employee_payroll_result_id" uuid NOT NULL,
  "employment_id" uuid NOT NULL,
  "jurisdiction_id" uuid NOT NULL,
  "tax_code" varchar(50) NOT NULL,
  "tax_description" varchar(200) NOT NULL,
  "taxable_wages_amount" decimal(18,4) NOT NULL,
  "calculated_amount" decimal(18,4) NOT NULL,
  "employer_flag" boolean NOT NULL DEFAULT false,
  "accumulator_impact_flag" boolean NOT NULL DEFAULT false,
  "source_rule_version_id" uuid,
  "correction_flag" boolean NOT NULL DEFAULT false,
  "corrects_line_id" uuid,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "employer_contribution_result_line" (
  "employer_contribution_result_line_id" uuid PRIMARY KEY NOT NULL,
  "employee_payroll_result_id" uuid NOT NULL,
  "employment_id" uuid NOT NULL,
  "contribution_code" varchar(50) NOT NULL,
  "contribution_description" varchar(200) NOT NULL,
  "calculated_amount" decimal(18,4) NOT NULL,
  "accumulator_impact_flag" boolean NOT NULL DEFAULT false,
  "source_rule_version_id" uuid,
  "correction_flag" boolean NOT NULL DEFAULT false,
  "corrects_line_id" uuid,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "payroll_check" (
  "check_id" uuid PRIMARY KEY NOT NULL,
  "check_number" varchar(50) NOT NULL,
  "payroll_run_id" uuid NOT NULL,
  "employment_id" uuid NOT NULL,
  "pay_period_start_date" date NOT NULL,
  "pay_period_end_date" date NOT NULL,
  "check_date" date NOT NULL,
  "payment_date" date NOT NULL,
  "calendar_context_id" uuid NOT NULL,
  "payment_method" payment_method NOT NULL,
  "payment_context" payment_context NOT NULL,
  "check_status" check_status NOT NULL,
  "gross_earnings" decimal(18,4) NOT NULL,
  "total_deductions" decimal(18,4) NOT NULL,
  "total_taxes" decimal(18,4) NOT NULL,
  "net_pay" decimal(18,4) NOT NULL,
  "employer_total_cost" decimal(18,4),
  "void_reason" varchar(500),
  "corrects_check_id" uuid,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "payroll_item" (
  "payroll_item_id" uuid PRIMARY KEY NOT NULL,
  "payroll_run_id" uuid NOT NULL,
  "payroll_check_id" uuid NOT NULL,
  "employment_id" uuid NOT NULL,
  "period_id" uuid NOT NULL,
  "result_class" result_class NOT NULL,
  "code_type" varchar(50) NOT NULL,
  "code" varchar(50) NOT NULL,
  "description" varchar(200) NOT NULL,
  "hours" decimal(18,4),
  "rate" decimal(18,4),
  "amount" decimal(18,4) NOT NULL,
  "taxable_flag" boolean NOT NULL,
  "cash_impact_flag" boolean NOT NULL,
  "accumulator_target" varchar(100),
  "source_rule_version_id" uuid,
  "item_status" item_status NOT NULL,
  "correction_flag" boolean NOT NULL DEFAULT false,
  "corrects_item_id" uuid,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "accumulator_definition" (
  "accumulator_definition_id" uuid PRIMARY KEY NOT NULL,
  "accumulator_family" accumulator_family NOT NULL,
  "accumulator_code" varchar(50) UNIQUE NOT NULL,
  "accumulator_name" varchar(200) NOT NULL,
  "scope_type" accumulator_scope_type NOT NULL,
  "period_context" period_context NOT NULL,
  "reset_type" varchar(50) NOT NULL,
  "carry_forward_flag" boolean NOT NULL DEFAULT false,
  "reporting_flag" boolean NOT NULL DEFAULT true,
  "remittance_flag" boolean NOT NULL DEFAULT false,
  "effective_start_date" date NOT NULL,
  "effective_end_date" date,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_updated_by" uuid NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "accumulator_impact" (
  "accumulator_impact_id" uuid PRIMARY KEY NOT NULL,
  "accumulator_definition_id" uuid NOT NULL,
  "payroll_run_result_set_id" uuid,
  "employee_payroll_result_id" uuid,
  "payroll_run_id" uuid NOT NULL,
  "employment_id" uuid,
  "person_id" uuid,
  "impact_status" impact_status NOT NULL,
  "impact_source_type" impact_source_type NOT NULL,
  "source_object_id" uuid,
  "prior_value" decimal(18,4) NOT NULL,
  "delta_value" decimal(18,4) NOT NULL,
  "new_value" decimal(18,4) NOT NULL,
  "posting_direction" posting_direction NOT NULL,
  "scope_type" accumulator_scope_type NOT NULL,
  "scope_object_id" uuid,
  "jurisdiction_id" uuid,
  "rule_pack_id" uuid,
  "rule_version_id" uuid,
  "retroactive_flag" boolean NOT NULL DEFAULT false,
  "reversal_flag" boolean NOT NULL DEFAULT false,
  "correction_flag" boolean NOT NULL DEFAULT false,
  "prior_accumulator_impact_id" uuid,
  "notes" varchar(500),
  "impact_timestamp" timestamptz NOT NULL,
  "created_timestamp" timestamptz NOT NULL,
  "updated_timestamp" timestamptz NOT NULL
);

CREATE TABLE "accumulator_contribution" (
  "contribution_id" uuid PRIMARY KEY NOT NULL,
  "accumulator_id" uuid NOT NULL,
  "accumulator_impact_id" uuid NOT NULL,
  "accumulator_definition_id" uuid NOT NULL,
  "parent_contribution_id" uuid,
  "root_contribution_id" uuid,
  "contribution_lineage_sequence" int,
  "correction_reference_id" uuid,
  "source_run_id" uuid NOT NULL,
  "source_result_set_id" uuid,
  "source_employee_result_id" uuid,
  "source_period_id" uuid NOT NULL,
  "execution_period_id" uuid NOT NULL,
  "employment_id" uuid,
  "scope_type" accumulator_scope_type NOT NULL,
  "scope_object_id" uuid,
  "contribution_amount" decimal(18,4) NOT NULL,
  "contribution_type" contribution_type NOT NULL,
  "before_value" decimal(18,4),
  "after_value" decimal(18,4),
  "reason_code" varchar(50),
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "accumulator_balance" (
  "accumulator_id" uuid PRIMARY KEY NOT NULL,
  "accumulator_definition_id" uuid NOT NULL,
  "accumulator_family" accumulator_family NOT NULL,
  "scope_type" accumulator_scope_type NOT NULL,
  "participant_id" uuid,
  "employer_id" uuid,
  "jurisdiction_id" uuid,
  "plan_id" uuid,
  "period_context" period_context NOT NULL,
  "calendar_context_id" uuid NOT NULL,
  "current_value" decimal(18,4) NOT NULL,
  "balance_status" accumulator_balance_status NOT NULL,
  "last_updated_run_id" uuid NOT NULL,
  "last_updated_result_set_id" uuid,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "funding_result_set" (
  "funding_result_set_id" uuid PRIMARY KEY NOT NULL,
  "payroll_run_result_set_id" uuid NOT NULL,
  "funding_profile_id" uuid NOT NULL,
  "funding_status" funding_status NOT NULL,
  "funding_amount" decimal(18,4) NOT NULL,
  "funding_timestamp" timestamptz,
  "created_timestamp" timestamptz NOT NULL
);

CREATE TABLE "remittance_result_set" (
  "remittance_result_set_id" uuid PRIMARY KEY NOT NULL,
  "payroll_run_result_set_id" uuid NOT NULL,
  "remittance_profile_id" uuid NOT NULL,
  "total_remittance_amount" decimal(18,4) NOT NULL,
  "remittance_status" remittance_status NOT NULL,
  "transmission_timestamp" timestamptz,
  "created_timestamp" timestamptz NOT NULL
);

CREATE TABLE "disbursement_result_set" (
  "disbursement_result_set_id" uuid PRIMARY KEY NOT NULL,
  "payroll_run_result_set_id" uuid NOT NULL,
  "net_pay_disbursement_id" uuid NOT NULL,
  "disbursement_status" disbursement_status NOT NULL,
  "disbursement_amount" decimal(18,4) NOT NULL,
  "created_timestamp" timestamptz NOT NULL
);

CREATE INDEX ON "payroll_run" ("payroll_context_id");

CREATE INDEX ON "payroll_run" ("period_id");

CREATE INDEX ON "payroll_run" ("run_status");

CREATE INDEX ON "payroll_run" ("parent_run_id");

CREATE INDEX ON "payroll_run" ("payroll_context_id", "period_id", "run_type");

CREATE INDEX ON "run_scope" ("parent_run_id");

CREATE INDEX ON "run_scope" ("scope_status");

CREATE INDEX ON "run_scope" ("scope_type");

CREATE INDEX ON "run_scope" ("payroll_context_id");

CREATE INDEX ON "payroll_run_result_set" ("payroll_run_id");

CREATE INDEX ON "payroll_run_result_set" ("run_scope_id");

CREATE INDEX ON "payroll_run_result_set" ("result_set_status");

CREATE INDEX ON "payroll_run_result_set" ("source_period_id");

CREATE INDEX ON "payroll_run_result_set" ("parent_payroll_run_result_set_id");

CREATE INDEX ON "payroll_run_result_set" ("root_payroll_run_result_set_id");

CREATE INDEX ON "employee_payroll_result" ("payroll_run_result_set_id");

CREATE INDEX ON "employee_payroll_result" ("payroll_run_id");

CREATE INDEX ON "employee_payroll_result" ("employment_id");

CREATE INDEX ON "employee_payroll_result" ("person_id");

CREATE INDEX ON "employee_payroll_result" ("result_status");

CREATE INDEX ON "employee_payroll_result" ("source_period_id");

CREATE INDEX ON "employee_payroll_result" ("parent_employee_payroll_result_id");

CREATE INDEX ON "employee_payroll_result" ("root_employee_payroll_result_id");

CREATE INDEX ON "earnings_result_line" ("employee_payroll_result_id");

CREATE INDEX ON "earnings_result_line" ("employment_id");

CREATE INDEX ON "earnings_result_line" ("earnings_code");

CREATE INDEX ON "deduction_result_line" ("employee_payroll_result_id");

CREATE INDEX ON "deduction_result_line" ("employment_id");

CREATE INDEX ON "deduction_result_line" ("deduction_code");

CREATE INDEX ON "tax_result_line" ("employee_payroll_result_id");

CREATE INDEX ON "tax_result_line" ("employment_id");

CREATE INDEX ON "tax_result_line" ("jurisdiction_id");

CREATE INDEX ON "tax_result_line" ("tax_code");

CREATE INDEX ON "employer_contribution_result_line" ("employee_payroll_result_id");

CREATE INDEX ON "employer_contribution_result_line" ("employment_id");

CREATE INDEX ON "employer_contribution_result_line" ("contribution_code");

CREATE INDEX ON "payroll_check" ("payroll_run_id");

CREATE INDEX ON "payroll_check" ("employment_id");

CREATE INDEX ON "payroll_check" ("check_status");

CREATE INDEX ON "payroll_check" ("check_number");

CREATE INDEX ON "payroll_check" ("corrects_check_id");

CREATE INDEX ON "payroll_item" ("payroll_run_id");

CREATE INDEX ON "payroll_item" ("payroll_check_id");

CREATE INDEX ON "payroll_item" ("employment_id");

CREATE INDEX ON "payroll_item" ("period_id");

CREATE INDEX ON "payroll_item" ("result_class");

CREATE INDEX ON "payroll_item" ("code");

CREATE INDEX ON "payroll_item" ("corrects_item_id");

CREATE INDEX ON "accumulator_definition" ("accumulator_code");

CREATE INDEX ON "accumulator_definition" ("accumulator_family");

CREATE INDEX ON "accumulator_definition" ("scope_type");

CREATE INDEX ON "accumulator_impact" ("accumulator_definition_id");

CREATE INDEX ON "accumulator_impact" ("payroll_run_id");

CREATE INDEX ON "accumulator_impact" ("payroll_run_result_set_id");

CREATE INDEX ON "accumulator_impact" ("employee_payroll_result_id");

CREATE INDEX ON "accumulator_impact" ("employment_id");

CREATE INDEX ON "accumulator_impact" ("impact_status");

CREATE INDEX ON "accumulator_impact" ("prior_accumulator_impact_id");

CREATE INDEX ON "accumulator_contribution" ("accumulator_id");

CREATE INDEX ON "accumulator_contribution" ("accumulator_impact_id");

CREATE INDEX ON "accumulator_contribution" ("accumulator_definition_id");

CREATE INDEX ON "accumulator_contribution" ("source_run_id");

CREATE INDEX ON "accumulator_contribution" ("source_period_id");

CREATE INDEX ON "accumulator_contribution" ("employment_id");

CREATE INDEX ON "accumulator_contribution" ("parent_contribution_id");

CREATE INDEX ON "accumulator_contribution" ("root_contribution_id");

CREATE INDEX ON "accumulator_balance" ("accumulator_definition_id");

CREATE INDEX ON "accumulator_balance" ("scope_type", "participant_id", "period_context", "calendar_context_id");

CREATE INDEX ON "accumulator_balance" ("accumulator_family", "scope_type", "participant_id");

CREATE INDEX ON "accumulator_balance" ("last_updated_run_id");

CREATE INDEX ON "accumulator_balance" ("balance_status");

CREATE INDEX ON "funding_result_set" ("payroll_run_result_set_id");

CREATE INDEX ON "funding_result_set" ("funding_status");

CREATE INDEX ON "remittance_result_set" ("payroll_run_result_set_id");

CREATE INDEX ON "remittance_result_set" ("remittance_status");

CREATE INDEX ON "disbursement_result_set" ("payroll_run_result_set_id");

CREATE INDEX ON "disbursement_result_set" ("disbursement_status");

COMMENT ON COLUMN "payroll_run"."run_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "payroll_run"."payroll_context_id" IS 'The payroll group this run belongs to';

COMMENT ON COLUMN "payroll_run"."period_id" IS 'The payroll calendar period';

COMMENT ON COLUMN "payroll_run"."pay_date" IS 'Inherited from calendar entry; immutable';

COMMENT ON COLUMN "payroll_run"."parent_run_id" IS 'Links correction or rerun to original run';

COMMENT ON COLUMN "payroll_run"."related_run_group_id" IS 'Groups related supplemental or adjustment runs';

COMMENT ON COLUMN "payroll_run"."rule_and_config_version_ref" IS 'Snapshot of configuration version used';

COMMENT ON COLUMN "payroll_run"."temporal_override_date" IS 'Override_Date at initiation time; null if no override';

COMMENT ON COLUMN "run_scope"."run_scope_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "run_scope"."parent_run_id" IS 'References the finalized parent payroll_run';

COMMENT ON COLUMN "run_scope"."population_definition" IS 'Serialized query or explicit list reference';

COMMENT ON COLUMN "run_scope"."priority_level" IS 'STANDARD, CATCH_UP, RECOVERY, EMERGENCY';

COMMENT ON COLUMN "run_scope"."execution_result" IS 'SUCCESS, FAILED';

COMMENT ON COLUMN "payroll_run_result_set"."payroll_run_result_set_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "payroll_run_result_set"."run_scope_id" IS 'Present when result set is from a scoped execution';

COMMENT ON COLUMN "payroll_run_result_set"."source_period_id" IS 'Original payroll period';

COMMENT ON COLUMN "payroll_run_result_set"."execution_period_id" IS 'Period during which execution occurred';

COMMENT ON COLUMN "payroll_run_result_set"."parent_payroll_run_result_set_id" IS 'Prior result set in lineage';

COMMENT ON COLUMN "payroll_run_result_set"."root_payroll_run_result_set_id" IS 'Root result set in lineage chain';

COMMENT ON COLUMN "employee_payroll_result"."employee_payroll_result_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "employee_payroll_result"."employment_id" IS 'Payroll anchor — never person_id';

COMMENT ON COLUMN "employee_payroll_result"."parent_employee_payroll_result_id" IS 'Prior worker-level result in lineage';

COMMENT ON COLUMN "employee_payroll_result"."root_employee_payroll_result_id" IS 'Root worker-level result in lineage chain';

COMMENT ON COLUMN "earnings_result_line"."quantity" IS 'Hours, units, or quantity';

COMMENT ON COLUMN "tax_result_line"."employer_flag" IS 'True for employer-side tax lines';

COMMENT ON COLUMN "payroll_check"."check_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "payroll_check"."check_number" IS 'Human-readable; unique within context';

COMMENT ON COLUMN "payroll_check"."corrects_check_id" IS 'Reference to original if this is a correction check';

COMMENT ON COLUMN "payroll_item"."payroll_item_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "accumulator_definition"."accumulator_definition_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "accumulator_definition"."reset_type" IS 'CALENDAR_YEAR, PLAN_YEAR, QUARTER, NONE, CONDITIONAL';

COMMENT ON COLUMN "accumulator_impact"."accumulator_impact_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "accumulator_impact"."payroll_run_result_set_id" IS 'Present for run-level impacts';

COMMENT ON COLUMN "accumulator_impact"."employee_payroll_result_id" IS 'Present for employee-level impacts';

COMMENT ON COLUMN "accumulator_impact"."source_object_id" IS 'Source result line reference';

COMMENT ON COLUMN "accumulator_impact"."prior_accumulator_impact_id" IS 'Links correction/reversal to original impact';

COMMENT ON COLUMN "accumulator_contribution"."contribution_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "accumulator_contribution"."accumulator_id" IS 'Links to accumulator_balance';

COMMENT ON COLUMN "accumulator_contribution"."accumulator_impact_id" IS 'Source impact that generated this contribution';

COMMENT ON COLUMN "accumulator_contribution"."parent_contribution_id" IS 'Prior contribution in correction chain';

COMMENT ON COLUMN "accumulator_contribution"."root_contribution_id" IS 'Root contribution in lineage chain';

COMMENT ON COLUMN "accumulator_balance"."accumulator_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "accumulator_balance"."participant_id" IS 'Required if scope includes employee';

COMMENT ON COLUMN "accumulator_balance"."employer_id" IS 'Required if scope includes employer';
