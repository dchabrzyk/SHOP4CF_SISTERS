-- liquibase formatted sql

-- changeset Lukas:20210729150000-1
ALTER TABLE public."Resources"
    ADD COLUMN "Color" VARCHAR(10);