-- liquibase formatted sql

-- changeset Sko:20220519150000-1
ALTER TABLE public."Resources"
    ADD COLUMN "ItemName" character varying (255),
    ADD COLUMN "ItemRevision" character varying (255),
    ADD COLUMN "RevisionValidFrom" timestamp without time zone,
    ADD COLUMN "RevisionValidTo" timestamp without time zone;
