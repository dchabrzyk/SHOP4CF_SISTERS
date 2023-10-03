-- liquibase formatted sql

-- changeset Sko:20220530010000-1
ALTER TABLE public."Tasks"
    ADD COLUMN "PositionOnParentTask" integer,
    ADD COLUMN "TemplateStatus" integer,
    ADD COLUMN "TemplateValidFrom" timestamp without time zone,
    ADD COLUMN "TemplateValidTo" timestamp without time zone;

