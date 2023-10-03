-- liquibase formatted sql

-- changeset Skorup:20220913150000-1
ALTER TABLE public."Tasks"
    DROP COLUMN IF EXISTS "CustomerId";


