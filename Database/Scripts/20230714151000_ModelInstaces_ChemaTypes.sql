-- liquibase formatted sql

-- changeset Lukas:20230714151000-1
alter table "ModelInstances"
    ADD COLUMN "SchemaTypes" integer[] default array [0] not null;

-- changeset Lukas:20230714151000-2
alter table "ModelInstances"
    DROP COLUMN "SchemaType";
