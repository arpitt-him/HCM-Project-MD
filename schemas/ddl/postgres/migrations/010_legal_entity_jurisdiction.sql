-- Migration: legal_entity_jurisdiction
-- Creates the linking table between legal entities and applicable tax jurisdictions.
-- Run against: allworkhris_dev

CREATE TABLE IF NOT EXISTS legal_entity_jurisdiction (
    legal_entity_id  uuid     NOT NULL,
    jurisdiction_id  integer  NOT NULL,
    CONSTRAINT pk_legal_entity_jurisdiction PRIMARY KEY (legal_entity_id, jurisdiction_id)
);

-- AllWork Demo Company LLC: US Federal, Georgia, New York, California
INSERT INTO legal_entity_jurisdiction (legal_entity_id, jurisdiction_id)
SELECT CAST('10000000-0000-0000-0000-000000000001' AS uuid), jurisdiction_id
FROM tax_jurisdiction
WHERE jurisdiction_code IN ('US-FED', 'US-GA', 'US-NY', 'US-CA');

-- Acme Manufacturing Inc.: US Federal, Georgia
INSERT INTO legal_entity_jurisdiction (legal_entity_id, jurisdiction_id)
SELECT CAST('367fbf4b-8fbd-4587-ae72-610904099fa7' AS uuid), jurisdiction_id
FROM tax_jurisdiction
WHERE jurisdiction_code IN ('US-FED', 'US-GA');

-- Cogent Technology: US Federal
INSERT INTO legal_entity_jurisdiction (legal_entity_id, jurisdiction_id)
SELECT CAST('e0d0f3ea-d51c-4d39-bfbb-298fabce7ee7' AS uuid), jurisdiction_id
FROM tax_jurisdiction
WHERE jurisdiction_code IN ('US-FED');
