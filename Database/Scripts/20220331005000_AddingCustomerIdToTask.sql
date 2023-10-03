-- liquibase formatted sql

-- changeset Skorup:20220331005000-1
ALTER TABLE public."Tasks"
    ADD COLUMN "CustomerId" uuid;

ALTER TABLE public."Tasks"
    ADD CONSTRAINT Tasks_Organization FOREIGN KEY ("CustomerId", "ScenarioId")
        REFERENCES public."Organizations" ("Id", "ScenarioId") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE;

