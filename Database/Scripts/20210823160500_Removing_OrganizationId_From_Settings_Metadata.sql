-- liquibase formatted sql

-- changeset Koza:20210823160500-1
--rollback DROP INDEX IF EXISTS public.settingsmetadata_key_uindex;
--rollback ALTER TABLE IF EXISTS public."SettingsMetadata" ADD COLUMN "OrganizationId" character varying(20);
--rollback CREATE UNIQUE INDEX settingsmetadata_key_orgid_uindex ON public."SettingsMetadata" USING btree ("Key" ASC NULLS LAST, "OrganizationId" ASC NULLS LAST) TABLESPACE pg_default;
--rollback CREATE POLICY settingsmetadata_org_isolation_policy ON public."SettingsMetadata" AS PERMISSIVE FOR ALL TO public USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)) OR "OrganizationId" IS NULL);
--rollback ALTER TABLE IF EXISTS public."SettingsMetadata" ENABLE ROW LEVEL SECURITY;

ALTER TABLE IF EXISTS public."SettingsMetadata" DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS settingsmetadata_org_isolation_policy ON public."SettingsMetadata";
DROP INDEX IF EXISTS public.settingsmetadata_key_orgid_uindex;
ALTER TABLE IF EXISTS public."SettingsMetadata" DROP COLUMN "OrganizationId";
CREATE UNIQUE INDEX settingsmetadata_key_uindex
    ON public."SettingsMetadata" USING btree
    ("Key" ASC NULLS LAST)
    TABLESPACE pg_default;