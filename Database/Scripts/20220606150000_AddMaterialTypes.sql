-- liquibase formatted sql

-- changeset Sko:20220606150000-1

ALTER TABLE public."Resources"
    ADD COLUMN "MaterialTypes" integer [];