-- liquibase formatted sql

-- changeset Sko:20230110110000-1
ALTER TABLE public."TrackingUniqueIdentifiers" DROP CONSTRAINT "TrackingUniqueIdentifiers_uc";