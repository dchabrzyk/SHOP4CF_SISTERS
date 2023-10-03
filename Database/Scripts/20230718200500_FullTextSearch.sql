-- liquibase formatted sql

-- changeset Lukas:20230718200500-1
ALTER TABLE "ModelInstances"
    ADD "Search" tsvector GENERATED ALWAYS AS (
            to_tsvector('simple', "ExternalId") ||
            jsonb_to_tsvector('simple', "Value", '["string", "numeric", "key"]')
        ) STORED;

-- changeset Lukas:20230718200500-2
CREATE INDEX "idx_ModelInstances_search" on "ModelInstances" USING GIN ("Search");

-- changeset Lukas:20230718200500-3
ALTER TABLE "Resources"
    ADD "Search" tsvector GENERATED ALWAYS AS (
            to_tsvector('simple', coalesce("ExternalId", '') || ' ' || "Name" || ' ' || coalesce("ItemName", '') || ' ' || coalesce("Description", '')) ||
            array_to_tsvector("Tags")
        ) STORED;

-- changeset Lukas:20230718200500-4
CREATE INDEX "idx_Resources_search" on "Resources" USING GIN ("Search");
