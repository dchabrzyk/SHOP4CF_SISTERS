-- liquibase formatted sql

-- changeset Lukas:20220927134000-1
ALTER TABLE public."Tasks"
    ADD COLUMN "Tags" text[];