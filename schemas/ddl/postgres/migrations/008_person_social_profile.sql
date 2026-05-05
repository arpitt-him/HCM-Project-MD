-- Migration 008 — Person Social Profile
-- Adds an optional per-person community profile: one photo and a short bio.
-- Keyed on person_id (not employment_id) so the profile is shared across
-- legal entities.  Photo is stored as a binary blob (bytea on PostgreSQL;
-- map to BLOB / VARBINARY(MAX) on other engines at migration time).
-- Bio text is capped at 1,000 characters.

CREATE TABLE "person_social_profile" (
  "person_id"       uuid          PRIMARY KEY NOT NULL,
  "photo_data"      bytea         NULL,
  "photo_mime_type" varchar(50)   NULL,
  "bio_text"        varchar(1000) NULL,
  "updated_at"      timestamptz   NOT NULL DEFAULT now(),
  CONSTRAINT "fk_psp_person" FOREIGN KEY ("person_id") REFERENCES "person" ("person_id")
);

COMMENT ON TABLE  "person_social_profile"                IS 'Optional employee-supplied community profile — photo and short bio. One row per person, shared across legal entities.';
COMMENT ON COLUMN "person_social_profile"."photo_data"      IS 'Raw image bytes. Max enforced at application layer (2 MB). NULL when no photo uploaded.';
COMMENT ON COLUMN "person_social_profile"."photo_mime_type" IS 'MIME type of the stored photo, e.g. image/jpeg, image/png, image/webp.';
COMMENT ON COLUMN "person_social_profile"."bio_text"        IS 'Employee-written short bio (hobbies, interests). Max 1,000 characters.';
COMMENT ON COLUMN "person_social_profile"."updated_at"      IS 'Timestamp of the most recent save (photo or bio).';
