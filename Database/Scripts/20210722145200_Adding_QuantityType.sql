-- liquibase formatted sql

-- changeset Lukas:20210722145200-1
ALTER TABLE public."ResourceSupply"
    ADD COLUMN "QuantityType" int NOT NULL DEFAULT 0;