-- liquibase formatted sql

-- changeset Lukas:20210802151000-1
ALTER TABLE public."Resources"
    ADD COLUMN "IsBase" boolean NOT NULL DEFAULT False;