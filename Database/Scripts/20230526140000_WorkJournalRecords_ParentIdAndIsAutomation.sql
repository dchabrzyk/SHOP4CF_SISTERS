-- liquibase formatted sql

-- changeset Lukas:20230526140000-1
alter table public."WorkJournalRecords"
    ADD COLUMN "ParentId"     uuid,
    ADD COLUMN "IsAutomation" boolean NOT NULL DEFAULT False;










