-- liquibase formatted sql

-- changeset Sko:20230912180000-1
alter table public."CostCatalogueItems"
    ADD COLUMN IF NOT EXISTS "Name"         varchar(255),
    ADD COLUMN IF NOT EXISTS "Manufacturer" varchar(255);