-- SQL dump generated using DBML (dbml.dbdiagram.io)
-- Database: PostgreSQL
-- Generated at: 2026-04-25T15:58:11.097Z

CREATE TYPE "person_status" AS ENUM (
  'ACTIVE',
  'INACTIVE',
  'DECEASED',
  'RESTRICTED',
  'ARCHIVED'
);

CREATE TYPE "employment_type" AS ENUM (
  'EMPLOYEE',
  'CONTRACTOR',
  'INTERN',
  'SEASONAL'
);

CREATE TYPE "employment_status" AS ENUM (
  'PENDING',
  'ACTIVE',
  'ON_LEAVE',
  'SUSPENDED',
  'TERMINATED',
  'CLOSED'
);

CREATE TYPE "full_part_time_status" AS ENUM (
  'FULL_TIME',
  'PART_TIME'
);

CREATE TYPE "regular_temporary_status" AS ENUM (
  'REGULAR',
  'TEMPORARY',
  'SEASONAL'
);

CREATE TYPE "flsa_status" AS ENUM (
  'EXEMPT',
  'NON_EXEMPT'
);

CREATE TYPE "assignment_type" AS ENUM (
  'PRIMARY',
  'SECONDARY',
  'TEMPORARY',
  'SUPPLEMENTAL',
  'OVERRIDE'
);

CREATE TYPE "assignment_status" AS ENUM (
  'ACTIVE',
  'PENDING',
  'CLOSED',
  'CANCELLED'
);

CREATE TYPE "compensation_rate_type" AS ENUM (
  'HOURLY',
  'SALARY',
  'COMMISSION',
  'CONTRACT',
  'DIFFERENTIAL'
);

CREATE TYPE "compensation_status" AS ENUM (
  'PENDING',
  'ACTIVE',
  'CLOSED',
  'CANCELLED',
  'SUPERSEDED'
);

CREATE TYPE "pay_frequency" AS ENUM (
  'WEEKLY',
  'BIWEEKLY',
  'SEMI_MONTHLY',
  'MONTHLY'
);

CREATE TYPE "approval_status" AS ENUM (
  'PENDING',
  'APPROVED',
  'REJECTED'
);

CREATE TYPE "leave_type" AS ENUM (
  'PTO',
  'VACATION',
  'SICK',
  'PERSONAL',
  'LOA',
  'FMLA',
  'STD',
  'LTD',
  'MILITARY',
  'JURY_DUTY',
  'HOLIDAY'
);

CREATE TYPE "leave_status" AS ENUM (
  'REQUESTED',
  'APPROVED',
  'DENIED',
  'SCHEDULED',
  'ACTIVE',
  'COMPLETED',
  'CANCELLED'
);

CREATE TYPE "payroll_impact_type" AS ENUM (
  'PAID_SUBSTITUTION',
  'UNPAID_SUPPRESSION',
  'DISABILITY_PAY',
  'NO_IMPACT'
);

CREATE TYPE "document_type" AS ENUM (
  'I9',
  'W4',
  'OFFER_LETTER',
  'CONTRACT',
  'CERTIFICATION',
  'LICENSE',
  'IDENTIFICATION',
  'POLICY_ACKNOWLEDGEMENT',
  'PERFORMANCE_REVIEW',
  'OTHER'
);

CREATE TYPE "document_status" AS ENUM (
  'DRAFT',
  'ACTIVE',
  'EXPIRED',
  'SUPERSEDED',
  'ARCHIVED'
);

CREATE TYPE "onboarding_plan_status" AS ENUM (
  'CREATED',
  'IN_PROGRESS',
  'BLOCKING_COMPLETE',
  'COMPLETE',
  'CANCELLED'
);

CREATE TYPE "onboarding_task_type" AS ENUM (
  'DOCUMENT_SUBMISSION',
  'SYSTEM_ACCESS',
  'TRAINING',
  'POLICY_ACKNOWLEDGEMENT',
  'BENEFITS_ENROLLMENT',
  'EQUIPMENT_SETUP',
  'ORIENTATION',
  'OTHER'
);

CREATE TYPE "onboarding_task_status" AS ENUM (
  'NOT_STARTED',
  'IN_PROGRESS',
  'COMPLETE',
  'WAIVED',
  'OVERDUE'
);

CREATE TYPE "org_unit_type" AS ENUM (
  'LEGAL_ENTITY',
  'DIVISION',
  'BUSINESS_UNIT',
  'DEPARTMENT',
  'COST_CENTER',
  'LOCATION',
  'REGION'
);

CREATE TYPE "org_status" AS ENUM (
  'ACTIVE',
  'INACTIVE',
  'ARCHIVED'
);

CREATE TYPE "work_location_type" AS ENUM (
  'OFFICE',
  'REMOTE',
  'HYBRID'
);

CREATE TYPE "job_status" AS ENUM (
  'ACTIVE',
  'INACTIVE'
);

CREATE TYPE "flsa_classification" AS ENUM (
  'EXEMPT',
  'NON_EXEMPT',
  'INDEPENDENT_CONTRACTOR'
);

CREATE TYPE "eeo_category" AS ENUM (
  'EXEC_SENIOR_OFFICIALS',
  'FIRST_MID_OFFICIALS',
  'PROFESSIONALS',
  'TECHNICIANS',
  'SALES',
  'ADMIN_SUPPORT',
  'CRAFT_WORKERS',
  'OPERATIVES',
  'LABORERS',
  'SERVICE_WORKERS'
);

CREATE TYPE "position_status" AS ENUM (
  'OPEN',
  'FILLED',
  'FROZEN',
  'CLOSED'
);

CREATE TABLE "person" (
  "person_id" uuid PRIMARY KEY NOT NULL,
  "person_number" varchar(50),
  "legal_first_name" varchar(100) NOT NULL,
  "legal_middle_name" varchar(100),
  "legal_last_name" varchar(100) NOT NULL,
  "name_suffix" varchar(20),
  "preferred_name" varchar(100),
  "date_of_birth" date NOT NULL,
  "national_identifier" varchar(500),
  "national_identifier_type" varchar(50),
  "gender" varchar(50),
  "pronouns" varchar(100),
  "citizenship_status" varchar(100),
  "work_authorization_status" varchar(100),
  "work_authorization_exp_date" date,
  "language_preference" varchar(20),
  "marital_status" varchar(50),
  "veteran_status" varchar(50),
  "disability_status" varchar(50),
  "person_status" person_status NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL,
  "last_updated_by" varchar(200) NOT NULL
);

CREATE TABLE "person_address" (
  "person_address_id" uuid PRIMARY KEY NOT NULL,
  "person_id" uuid NOT NULL,
  "address_type" varchar(50) NOT NULL,
  "address_line_1" varchar(200) NOT NULL,
  "address_line_2" varchar(200),
  "city" varchar(100) NOT NULL,
  "state_code" varchar(10) NOT NULL,
  "postal_code" varchar(20) NOT NULL,
  "country_code" varchar(5) NOT NULL,
  "phone_primary" varchar(30),
  "phone_secondary" varchar(30),
  "email_personal" varchar(200),
  "effective_start_date" date NOT NULL,
  "effective_end_date" date,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "person_emergency_contact" (
  "emergency_contact_id" uuid PRIMARY KEY NOT NULL,
  "person_id" uuid NOT NULL,
  "contact_name" varchar(200) NOT NULL,
  "relationship" varchar(100),
  "phone" varchar(30),
  "email" varchar(200),
  "primary_flag" boolean NOT NULL DEFAULT false,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "org_unit" (
  "org_unit_id" uuid PRIMARY KEY NOT NULL,
  "org_unit_type" org_unit_type NOT NULL,
  "org_unit_code" varchar(50) NOT NULL,
  "org_unit_name" varchar(200) NOT NULL,
  "parent_org_unit_id" uuid,
  "org_status" org_status NOT NULL,
  "effective_start_date" date NOT NULL,
  "effective_end_date" date,
  "tax_registration_number" varchar(50),
  "country_code" varchar(5),
  "state_of_incorporation" varchar(10),
  "legal_entity_type" varchar(50),
  "address_line_1" varchar(200),
  "address_line_2" varchar(200),
  "city" varchar(100),
  "state_code" varchar(10),
  "postal_code" varchar(20),
  "locality_code" varchar(50),
  "work_location_type" work_location_type,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_updated_by" uuid NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "job" (
  "job_id" uuid PRIMARY KEY NOT NULL,
  "job_code" varchar(50) UNIQUE NOT NULL,
  "job_title" varchar(200) NOT NULL,
  "job_family" varchar(100),
  "job_level" varchar(50),
  "flsa_classification" flsa_classification NOT NULL,
  "eeo_category" eeo_category NOT NULL,
  "job_status" job_status NOT NULL,
  "effective_start_date" date NOT NULL,
  "effective_end_date" date,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_updated_by" uuid NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "position" (
  "position_id" uuid PRIMARY KEY NOT NULL,
  "job_id" uuid NOT NULL,
  "org_unit_id" uuid NOT NULL,
  "position_title" varchar(200),
  "headcount_budget" int,
  "position_status" position_status NOT NULL,
  "effective_start_date" date NOT NULL,
  "effective_end_date" date,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_updated_by" uuid NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "employment" (
  "employment_id" uuid PRIMARY KEY NOT NULL,
  "person_id" uuid NOT NULL,
  "legal_entity_id" uuid NOT NULL,
  "employer_id" uuid NOT NULL,
  "employee_number" varchar(50) NOT NULL,
  "employment_type" employment_type NOT NULL,
  "employment_start_date" date NOT NULL,
  "employment_end_date" date,
  "original_hire_date" date,
  "termination_date" date,
  "employment_status" employment_status NOT NULL,
  "full_or_part_time_status" full_part_time_status NOT NULL,
  "regular_or_temporary_status" regular_temporary_status NOT NULL,
  "flsa_status" flsa_status NOT NULL,
  "payroll_context_id" uuid NOT NULL,
  "primary_work_location_id" uuid NOT NULL,
  "primary_department_id" uuid NOT NULL,
  "manager_employment_id" uuid,
  "rehire_flag" boolean NOT NULL DEFAULT false,
  "prior_employment_id" uuid,
  "primary_flag" boolean NOT NULL DEFAULT true,
  "payroll_eligibility_flag" boolean NOT NULL DEFAULT true,
  "benefits_eligibility_flag" boolean NOT NULL DEFAULT true,
  "time_tracking_required_flag" boolean NOT NULL DEFAULT false,
  "creation_timestamp" timestamptz NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL,
  "last_updated_by" varchar(200) NOT NULL
);

CREATE TABLE "assignment" (
  "assignment_id" uuid PRIMARY KEY NOT NULL,
  "employment_id" uuid NOT NULL,
  "job_id" uuid NOT NULL,
  "position_id" uuid,
  "department_id" uuid NOT NULL,
  "location_id" uuid NOT NULL,
  "payroll_context_id" uuid NOT NULL,
  "plan_id" uuid,
  "assignment_type" assignment_type NOT NULL,
  "assignment_status" assignment_status NOT NULL,
  "assignment_priority" int,
  "assignment_start_date" date NOT NULL,
  "assignment_end_date" date,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_updated_by" uuid NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "compensation_record" (
  "compensation_id" uuid PRIMARY KEY NOT NULL,
  "employment_id" uuid NOT NULL,
  "rate_type" compensation_rate_type NOT NULL,
  "base_rate" decimal(18,4) NOT NULL,
  "rate_currency" varchar(5) NOT NULL DEFAULT 'USD',
  "annual_equivalent" decimal(18,4),
  "pay_frequency" pay_frequency NOT NULL,
  "effective_start_date" date NOT NULL,
  "effective_end_date" date,
  "compensation_status" compensation_status NOT NULL,
  "change_reason_code" varchar(50) NOT NULL,
  "approval_status" approval_status NOT NULL,
  "approved_by" uuid,
  "approval_timestamp" timestamptz,
  "primary_rate_flag" boolean NOT NULL DEFAULT false,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_updated_by" uuid NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "leave_request" (
  "leave_request_id" uuid PRIMARY KEY NOT NULL,
  "employment_id" uuid NOT NULL,
  "leave_type" leave_type NOT NULL,
  "request_date" date NOT NULL,
  "leave_start_date" date NOT NULL,
  "leave_end_date" date NOT NULL,
  "actual_return_date" date,
  "leave_status" leave_status NOT NULL,
  "leave_reason_code" varchar(50) NOT NULL,
  "payroll_impact_type" payroll_impact_type NOT NULL,
  "leave_balance_impact" decimal(10,4),
  "approved_by" uuid,
  "approval_timestamp" timestamptz,
  "hr_contact_id" uuid,
  "fmla_eligible_flag" boolean DEFAULT false,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_updated_by" uuid NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "document" (
  "document_id" uuid PRIMARY KEY NOT NULL,
  "person_id" uuid NOT NULL,
  "employment_id" uuid,
  "document_type" document_type NOT NULL,
  "document_name" varchar(200) NOT NULL,
  "document_version" int NOT NULL DEFAULT 1,
  "document_status" document_status NOT NULL,
  "effective_date" date NOT NULL,
  "expiration_date" date,
  "storage_reference" varchar(500) NOT NULL,
  "file_format" varchar(20) NOT NULL,
  "upload_date" timestamptz NOT NULL,
  "uploaded_by" uuid NOT NULL,
  "verified_by" uuid,
  "verification_date" timestamptz,
  "superseded_by_document_id" uuid,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE TABLE "onboarding_plan" (
  "onboarding_plan_id" uuid PRIMARY KEY NOT NULL,
  "employment_id" uuid NOT NULL,
  "plan_template_id" uuid,
  "plan_status" onboarding_plan_status NOT NULL,
  "target_start_date" date NOT NULL,
  "completion_date" date,
  "assigned_hr_contact_id" uuid,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL,
  "last_updated_by" uuid NOT NULL,
  "last_update_timestamp" timestamptz NOT NULL
);

CREATE TABLE "onboarding_task" (
  "task_id" uuid PRIMARY KEY NOT NULL,
  "onboarding_plan_id" uuid NOT NULL,
  "task_type" onboarding_task_type NOT NULL,
  "task_name" varchar(200) NOT NULL,
  "task_owner_role" varchar(100) NOT NULL,
  "task_owner_user_id" uuid,
  "due_date" date NOT NULL,
  "completion_date" date,
  "task_status" onboarding_task_status NOT NULL,
  "blocking_flag" boolean NOT NULL DEFAULT false,
  "waiver_reason" varchar(500),
  "waived_by" uuid,
  "created_by" uuid NOT NULL,
  "creation_timestamp" timestamptz NOT NULL
);

CREATE INDEX ON "person" ("person_number");

CREATE INDEX ON "person" ("person_status");

CREATE INDEX ON "person" ("legal_last_name", "legal_first_name");

CREATE INDEX ON "person_address" ("person_id");

CREATE INDEX ON "person_address" ("person_id", "address_type", "effective_start_date");

CREATE INDEX ON "person_emergency_contact" ("person_id");

CREATE INDEX ON "org_unit" ("org_unit_type");

CREATE INDEX ON "org_unit" ("org_status");

CREATE INDEX ON "org_unit" ("parent_org_unit_id");

CREATE INDEX ON "org_unit" ("org_unit_code");

CREATE INDEX ON "job" ("job_code");

CREATE INDEX ON "job" ("job_status");

CREATE INDEX ON "job" ("flsa_classification");

CREATE INDEX ON "position" ("job_id");

CREATE INDEX ON "position" ("org_unit_id");

CREATE INDEX ON "position" ("position_status");

CREATE INDEX ON "employment" ("person_id");

CREATE INDEX ON "employment" ("legal_entity_id");

CREATE INDEX ON "employment" ("employment_status");

CREATE INDEX ON "employment" ("employee_number");

CREATE INDEX ON "employment" ("manager_employment_id");

CREATE INDEX ON "employment" ("prior_employment_id");

CREATE INDEX ON "employment" ("payroll_context_id");

CREATE INDEX ON "employment" ("primary_work_location_id");

CREATE INDEX ON "employment" ("primary_department_id");

CREATE INDEX ON "assignment" ("employment_id");

CREATE INDEX ON "assignment" ("job_id");

CREATE INDEX ON "assignment" ("position_id");

CREATE INDEX ON "assignment" ("location_id");

CREATE INDEX ON "assignment" ("department_id");

CREATE INDEX ON "assignment" ("assignment_status");

CREATE INDEX ON "assignment" ("assignment_type");

CREATE INDEX ON "assignment" ("employment_id", "assignment_type", "assignment_start_date");

CREATE INDEX ON "compensation_record" ("employment_id");

CREATE INDEX ON "compensation_record" ("compensation_status");

CREATE INDEX ON "compensation_record" ("effective_start_date");

CREATE INDEX ON "compensation_record" ("employment_id", "rate_type", "effective_start_date");

CREATE INDEX ON "compensation_record" ("primary_rate_flag");

CREATE INDEX ON "leave_request" ("employment_id");

CREATE INDEX ON "leave_request" ("leave_status");

CREATE INDEX ON "leave_request" ("leave_type");

CREATE INDEX ON "leave_request" ("leave_start_date");

CREATE INDEX ON "leave_request" ("employment_id", "leave_start_date", "leave_end_date");

CREATE INDEX ON "document" ("person_id");

CREATE INDEX ON "document" ("employment_id");

CREATE INDEX ON "document" ("document_type");

CREATE INDEX ON "document" ("document_status");

CREATE INDEX ON "document" ("expiration_date");

CREATE INDEX ON "document" ("superseded_by_document_id");

CREATE INDEX ON "onboarding_plan" ("employment_id");

CREATE INDEX ON "onboarding_plan" ("plan_status");

CREATE INDEX ON "onboarding_task" ("onboarding_plan_id");

CREATE INDEX ON "onboarding_task" ("task_status");

CREATE INDEX ON "onboarding_task" ("blocking_flag");

CREATE INDEX ON "onboarding_task" ("onboarding_plan_id", "blocking_flag", "task_status");

COMMENT ON COLUMN "person"."person_id" IS 'System-generated. Immutable. Enduring human identity key.';

COMMENT ON COLUMN "person"."person_number" IS 'Optional human-facing or integration-facing identifier';

COMMENT ON COLUMN "person"."national_identifier" IS 'Encrypted at rest. SSN for US. Access-controlled.';

COMMENT ON COLUMN "person"."national_identifier_type" IS 'SSN, SIN, NIN, etc.';

COMMENT ON COLUMN "person"."gender" IS 'Self-identified; controlled vocabulary';

COMMENT ON COLUMN "person"."pronouns" IS 'Self-identified';

COMMENT ON COLUMN "person_address"."address_type" IS 'PRIMARY, MAILING, PRIOR';

COMMENT ON COLUMN "person_address"."state_code" IS 'ISO 3166-2';

COMMENT ON COLUMN "person_address"."country_code" IS 'ISO 3166-1 alpha-2';

COMMENT ON COLUMN "org_unit"."org_unit_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "org_unit"."parent_org_unit_id" IS 'Null for root nodes; must not create cycles';

COMMENT ON COLUMN "org_unit"."tax_registration_number" IS 'EIN for US legal entities';

COMMENT ON COLUMN "org_unit"."country_code" IS 'ISO 3166-1 alpha-2; required for legal entities';

COMMENT ON COLUMN "org_unit"."legal_entity_type" IS 'CORPORATION, LLC, PARTNERSHIP, etc.';

COMMENT ON COLUMN "org_unit"."state_code" IS 'US state code; drives tax jurisdiction';

COMMENT ON COLUMN "org_unit"."locality_code" IS 'Local tax jurisdiction code';

COMMENT ON COLUMN "job"."job_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "position"."position_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "position"."position_title" IS 'Override title; if null, inherits from job_title';

COMMENT ON COLUMN "employment"."employment_id" IS 'System-generated. Immutable. Payroll anchor.';

COMMENT ON COLUMN "employment"."legal_entity_id" IS 'Org unit of type LEGAL_ENTITY';

COMMENT ON COLUMN "employment"."employer_id" IS 'Same as legal_entity_id in standard deployments';

COMMENT ON COLUMN "employment"."primary_work_location_id" IS 'References org_unit of type LOCATION';

COMMENT ON COLUMN "employment"."primary_department_id" IS 'References org_unit of type DEPARTMENT';

COMMENT ON COLUMN "employment"."manager_employment_id" IS 'Direct manager; self-referencing';

COMMENT ON COLUMN "employment"."prior_employment_id" IS 'Prior episode on rehire';

COMMENT ON COLUMN "employment"."primary_flag" IS 'True if primary when concurrent employments exist';

COMMENT ON COLUMN "assignment"."assignment_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "assignment"."employment_id" IS 'Payroll anchor — never person_id';

COMMENT ON COLUMN "assignment"."position_id" IS 'Null if position management not in use';

COMMENT ON COLUMN "assignment"."department_id" IS 'References org_unit';

COMMENT ON COLUMN "assignment"."location_id" IS 'References org_unit of type LOCATION; drives tax jurisdiction';

COMMENT ON COLUMN "compensation_record"."compensation_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "compensation_record"."employment_id" IS 'Payroll anchor';

COMMENT ON COLUMN "compensation_record"."rate_currency" IS 'ISO 4217';

COMMENT ON COLUMN "compensation_record"."annual_equivalent" IS 'System-calculated';

COMMENT ON COLUMN "leave_request"."leave_request_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "leave_request"."leave_balance_impact" IS 'Hours or days deducted from balance';

COMMENT ON COLUMN "document"."document_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "document"."person_id" IS 'Always associated with a Person';

COMMENT ON COLUMN "document"."employment_id" IS 'Null for person-level documents';

COMMENT ON COLUMN "document"."storage_reference" IS 'Secure reference to stored file';

COMMENT ON COLUMN "onboarding_plan"."onboarding_plan_id" IS 'System-generated. Immutable.';

COMMENT ON COLUMN "onboarding_task"."task_id" IS 'System-generated. Immutable.';
