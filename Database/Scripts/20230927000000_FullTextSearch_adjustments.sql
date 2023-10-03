-- liquibase formatted sql

-- changeset GO:20230927000000-1
DROP INDEX IF EXISTS "idx_ModelInstances_search";

-- changeset GO:20230927000000-2
ALTER TABLE "ModelInstances" 
    DROP COLUMN IF EXISTS "Search";

-- changeset GO:20230927000000-3
DROP INDEX IF EXISTS "idx_Resources_search";

-- changeset GO:20230927000000-4
ALTER TABLE "Resources" 
    DROP COLUMN IF EXISTS "Search";

-- changeset GO:20230927000000-5
ALTER TABLE "ModelInstances"
    ADD "Search" tsvector GENERATED ALWAYS AS (
            to_tsvector('simple', "BusinessId") ||
            jsonb_to_tsvector('simple', "Value", '["string", "numeric", "key"]')
        ) STORED;

-- changeset GO:20230927000000-6
CREATE INDEX "idx_ModelInstances_search" on "ModelInstances" USING GIN ("Search");

-- changeset GO:20230927000000-7
ALTER TABLE "Resources"
    ADD "Search" tsvector GENERATED ALWAYS AS (
            to_tsvector('simple', coalesce("BusinessId", '') || ' ' || "Name" || ' ' || coalesce("ItemName", '') || ' ' || coalesce("Description", '')) ||
            array_to_tsvector("Tags")
        ) STORED;

-- changeset GO:20230927000000-8
CREATE INDEX "idx_Resources_search" on "Resources" USING GIN ("Search");
