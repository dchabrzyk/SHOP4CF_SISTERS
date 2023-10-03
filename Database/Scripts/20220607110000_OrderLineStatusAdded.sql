-- liquibase formatted sql

-- changeset Sko:20220607110000-1
ALTER TABLE public."OrderLines"
    ADD COLUMN "Status" integer;

