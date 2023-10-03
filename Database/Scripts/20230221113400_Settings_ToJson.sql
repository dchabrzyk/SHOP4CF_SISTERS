-- liquibase formatted sql

-- changeset Lukas:20230221113400-1
alter table public."Settings"
    alter column "Value" type json using "Value"::json;