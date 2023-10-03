-- liquibase formatted sql

-- changeset Sko:20230404140000-1
alter table "AttachmentContent"
    alter column "ExternalId" SET DATA TYPE varchar(255);
