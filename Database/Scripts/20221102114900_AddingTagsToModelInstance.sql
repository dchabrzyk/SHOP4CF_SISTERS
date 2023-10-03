-- liquibase formatted sql

-- changeset Skorup:20221102114900-1
ALTER TABLE public."ModelInstances"
    ADD COLUMN "Tags" text[];


