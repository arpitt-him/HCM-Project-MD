-- Migration 007: Platform audit event table
-- Engine-agnostic ANSI SQL (applied to allworkhris_dev with PostgreSQL)

CREATE TABLE IF NOT EXISTS platform_audit_event (
    audit_event_id      UUID          NOT NULL,
    tenant_id           UUID          NOT NULL,
    event_timestamp     TIMESTAMP WITH TIME ZONE NOT NULL,
    event_type          VARCHAR(50)   NOT NULL,
    module_name         VARCHAR(30)   NULL,
    entity_type         VARCHAR(100)  NOT NULL,
    entity_id           UUID          NULL,
    parent_entity_type  VARCHAR(100)  NULL,
    parent_entity_id    UUID          NULL,
    actor_user_id       UUID          NOT NULL,
    actor_display_name  VARCHAR(200)  NULL,
    change_summary      VARCHAR(500)  NULL,
    before_state_json   TEXT          NULL,
    after_state_json    TEXT          NULL,
    outcome             VARCHAR(20)   NOT NULL,
    failure_reason      VARCHAR(500)  NULL,
    ip_address          VARCHAR(45)   NULL,
    session_id          VARCHAR(200)  NULL,
    CONSTRAINT pk_platform_audit_event PRIMARY KEY (audit_event_id)
);

CREATE INDEX IF NOT EXISTS ix_pae_tenant_id
    ON platform_audit_event (tenant_id);

CREATE INDEX IF NOT EXISTS ix_pae_event_timestamp
    ON platform_audit_event (event_timestamp);

CREATE INDEX IF NOT EXISTS ix_pae_actor_user_id
    ON platform_audit_event (actor_user_id);

CREATE INDEX IF NOT EXISTS ix_pae_entity
    ON platform_audit_event (entity_type, entity_id);

CREATE INDEX IF NOT EXISTS ix_pae_tenant_timestamp
    ON platform_audit_event (tenant_id, event_timestamp);

CREATE INDEX IF NOT EXISTS ix_pae_tenant_entity
    ON platform_audit_event (tenant_id, entity_type, entity_id);
