-- liquibase formatted sql

-- changeset Lukas:20220928143000-1
ALTER TABLE public."Resources"
    ADD COLUMN "Tags" text[];

-- changeset Lukas:20220928143000-2
ALTER TABLE public."Resources"
    ADD COLUMN "ConstraintType" int;