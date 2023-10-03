-- liquibase formatted sql

-- changeset Sko:20230215140000-1
ALTER TABLE public."ResourceCapacities"
    ADD COLUMN "TrackingUniqueIdentifier" text;

