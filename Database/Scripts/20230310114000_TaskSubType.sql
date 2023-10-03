-- liquibase formatted sql

-- changeset Lukas:20230310114000-1
alter table "Tasks"
    add "TaskSubType" integer default 0 not null;