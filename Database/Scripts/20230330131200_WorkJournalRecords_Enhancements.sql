-- liquibase formatted sql

-- changeset Lukas:20230330131200-1
alter table public."WorkJournalRecords"
    ADD COLUMN "Tags"                text[],
    ADD COLUMN "PersonName"          varchar(255),
    ADD COLUMN "PersonExternalId"    varchar(255),
    ADD COLUMN "AgreementName"       varchar(255),
    ADD COLUMN "AgreementExternalId" varchar(255),
    ADD COLUMN "EquipmentName"       varchar(255),
    ADD COLUMN "EquipmentExternalId" varchar(255),
    ADD COLUMN "TaskName"            varchar(255),
    ADD COLUMN "TaskExternalId"      varchar(255),
    ADD COLUMN "StepName"            varchar(255),
    ADD COLUMN "StepPosition"        integer,
    ADD COLUMN "ResourceId"          uuid;

-- changeset Lukas:20230330131200-2
alter table public."WorkJournalRecords"
    ADD COLUMN "EventSource" integer default 0 not null;









