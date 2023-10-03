-- liquibase formatted sql

-- changeset Sko:20230628220000-1
alter table "ModelInstances"
    ADD COLUMN "SchemaType" integer default 0 not null;