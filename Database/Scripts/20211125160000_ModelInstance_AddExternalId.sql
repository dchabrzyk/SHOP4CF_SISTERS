-- liquibase formatted sql

-- changeset Lukas:20211125160000-1

ALTER TABLE public."ModelInstances"
    ADD COLUMN "ExternalId" character varying(255) COLLATE pg_catalog."default";

--rollback ALTER TABLE public."ModelInstances" DROP COLUMN "ExternalId";