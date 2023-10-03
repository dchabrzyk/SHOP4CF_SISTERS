-- liquibase formatted sql

-- changeset Sko:20230306110000-1
alter table public."ResourceModelInstances"
    add column "ResourceModelInstanceAssignmentType" int;

-- changeset Sko:20230306110000-2
alter table public."TaskModelInstances"
    add column "TaskModelInstanceAssignmentType" int;