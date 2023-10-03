-- liquibase formatted sql

-- changeset Gchegosh:20220426000000-1
ALTER TABLE "ResourceModelInstances"
    ADD COLUMN "TenantId" character varying(20) COLLATE pg_catalog."default";

-- changeset Gchegosh:20220426000000-2
UPDATE "ResourceModelInstances" rmi
    SET "TenantId" = (SELECT "TenantId" FROM "Resources" r WHERE r."Id" = rmi."ResourceId" AND r."ScenarioId" = rmi."ScenarioId");

-- changeset Gchegosh:20220426000000-3
ALTER TABLE "ResourceModelInstances"
    ALTER COLUMN "TenantId" SET NOT NULL;

-- changeset Gchegosh:20220426000000-4
ALTER TABLE public."ResourceModelInstances"
    ENABLE ROW LEVEL SECURITY;

-- POLICY: ResourceModelInstances_RLS
CREATE POLICY "ResourceModelInstances_RLS"
    ON public."ResourceModelInstances"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL);

