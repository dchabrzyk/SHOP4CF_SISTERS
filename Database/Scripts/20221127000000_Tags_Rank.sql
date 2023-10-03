-- liquibase formatted sql

-- changeset GO:20221127000000-1
ALTER TABLE public."Tags" ADD COLUMN "Rank" integer DEFAULT 0;