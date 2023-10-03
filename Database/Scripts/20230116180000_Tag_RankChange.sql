-- liquibase formatted sql

-- changeset Lukas:20230116180000-1
ALTER TABLE public."Tags"
    ALTER COLUMN "Rank" TYPE numeric;