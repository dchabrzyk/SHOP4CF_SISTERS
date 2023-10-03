-- liquibase formatted sql

-- changeset Sko:20230829120000-1
alter table public."QuotationLines"
    DROP COLUMN IF EXISTS "QuantityUnit";