INSERT INTO document (
	document_id, person_id, employment_id, document_type_id,
	document_name, document_version, document_status_id,
	effective_date, expiration_date, storage_reference, file_format,
	upload_date, uploaded_by, legal_hold_flag, created_by, creation_timestamp)
SELECT
	gen_random_uuid(),
	e.person_id,
	e.employment_id,
	dt.id,
	dt.label || ' - ' || p.legal_last_name,
	1,
	(SELECT id FROM lkp_document_status WHERE code = 'ACTIVE'),
	'2024-01-01',
	exp_date,
	'seed/' || gen_random_uuid() || '.pdf',
	'PDF',
	now(),
	e.employment_id,
	false,
	e.employment_id,
	now()
FROM (
	VALUES
		('2fa99263-f1c3-4dc5-ad19-c5bb43e385fe'::uuid, 'I9',            '2024-06-15'::date),
		('2fa99263-f1c3-4dc5-ad19-c5bb43e385fe'::uuid, 'LICENSE',       '2025-03-01'::date),
		('e6649321-15e7-4b01-a93e-0d5a4264516e'::uuid, 'CERTIFICATION', '2026-05-10'::date),
		('e6649321-15e7-4b01-a93e-0d5a4264516e'::uuid, 'W4',            '2026-06-15'::date),
		('33e78e14-5358-4042-9127-dc9a37c9b3a3'::uuid, 'I9',            '2025-12-01'::date),
		('33e78e14-5358-4042-9127-dc9a37c9b3a3'::uuid, 'NDA',           '2026-07-20'::date),
		('cb7ec800-2242-4f8e-9714-09f904564622'::uuid, 'LICENSE',       '2024-11-30'::date),
		('cb7ec800-2242-4f8e-9714-09f904564622'::uuid, 'CERTIFICATION', '2026-05-25'::date),
		('28509d67-271f-4934-9155-17e6a2068683'::uuid, 'CONTRACT',      '2024-04-01'::date),
		('28509d67-271f-4934-9155-17e6a2068683'::uuid, 'POLICY_ACK',    '2026-06-30'::date)
) AS seed(emp_id, doc_code, exp_date)
JOIN employment e ON e.employment_id = seed.emp_id
JOIN person p ON p.person_id = e.person_id
JOIN lkp_document_type dt ON dt.code = seed.doc_code;

-- Note: gen_random_uuid() is PostgreSQL-specific. If you need this to work on other providers, replace it with explicit UUID literals.