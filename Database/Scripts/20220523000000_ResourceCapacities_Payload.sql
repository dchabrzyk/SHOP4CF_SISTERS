-- liquibase formatted sql

-- changeset Gchegosh:20220523000000-1
ALTER TABLE "ResourceCapacities"
    ALTER COLUMN "EntrySourcePayload" TYPE jsonb USING to_jsonb("EntrySourcePayload");

-- rollback ALTER TABLE "ResourceCapacities" ALTER COLUMN "EntrySourcePayload" TYPE varchar(255) USING cast("EntrySourcePayload" as varchar(255));