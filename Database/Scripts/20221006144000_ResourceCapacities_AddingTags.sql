-- liquibase formatted sql

-- changeset Lukas:20221006144000-1
ALTER TABLE public."ResourceCapacities"
    ADD COLUMN "Tags" text[];

