-- liquibase formatted sql

-- changeset Sko:20220602010000-1
ALTER TABLE public."Tasks"
    DROP COLUMN "IsTemplate";

