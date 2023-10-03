-- liquibase formatted sql

-- changeset Sko:20221122164000-1
ALTER TABLE public."Resources"
    ALTER COLUMN "ExternalId" TYPE varchar(255);

-- changeset Sko:20221122164000-2
ALTER TABLE public."WorkJournalRecords"
    ALTER COLUMN "ExternalId" TYPE varchar(255);