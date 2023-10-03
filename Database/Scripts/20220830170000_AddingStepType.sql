-- liquibase formatted sql

-- changeset Skorup:20220830170000-1
ALTER TABLE public."Steps"
    ADD COLUMN "StepType" integer;


