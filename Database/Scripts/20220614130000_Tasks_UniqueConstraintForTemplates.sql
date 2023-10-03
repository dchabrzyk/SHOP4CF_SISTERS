-- liquibase formatted sql

-- changeset Sko:20220614130000-1
ALTER TABLE public."Tasks"
    ADD CONSTRAINT task_template_unique_by_resource_and_revision UNIQUE ("RevisionNumber", "ResourceId", "ScenarioId");

