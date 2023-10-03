-- liquibase formatted sql

-- changeset Sko:20230930160000-1
ALTER TABLE public."Tasks"
    ADD CONSTRAINT uq_businessid_per_tenant_tasks2 UNIQUE ("TenantId", "ScenarioId", "BusinessId", "RevisionNumber");

ALTER TABLE public."Tasks"
    DROP CONSTRAINT uq_businessid_per_tenant_tasks;

ALTER TABLE public."Tasks"
    RENAME CONSTRAINT uq_businessid_per_tenant_tasks2 TO uq_businessid_per_tenant_tasks;
