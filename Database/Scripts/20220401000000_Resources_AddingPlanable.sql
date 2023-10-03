-- liquibase formatted sql

-- changeset Gchegosh:20220401000000-1
ALTER TABLE public."Resources"
    ADD COLUMN "Planable" BOOLEAN DEFAULT false;
-- changeset Gchegosh:20220401000000-2
UPDATE public."Resources" R1
SET "Planable" = true
WHERE NOT EXISTS(SELECT "Id" FROM "Resources" R2 WHERE R2."ParentId" = R1."Id");
