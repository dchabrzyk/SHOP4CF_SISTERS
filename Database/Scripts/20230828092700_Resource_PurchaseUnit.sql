-- liquibase formatted sql

-- changeset Lukas:20230828092700-1
ALTER TABLE public."Resources"
    ADD COLUMN "PurchaseUnit" integer default 1 not null;

-- changeset Lukas:20230828092700-2
ALTER TABLE public."Resources"
    ADD COLUMN "PurchaseConversionRatio" numeric default 1 not null;

-- changeset Lukas:20230828092700-3
ALTER TABLE public."Resources"
    ADD COLUMN "IndivisibleQuantity" numeric default 1 not null;