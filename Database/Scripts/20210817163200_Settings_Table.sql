-- liquibase formatted sql

-- changeset Koza:20210817163200-1
CREATE TABLE IF NOT EXISTS public."Settings"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "Key" character varying(255) NOT NULL,
    "Context" integer NOT NULL,
    "Profile" character varying(255) NOT NULL DEFAULT ''::character varying,
    "ContextValue" character varying(255) NOT NULL DEFAULT ''::character varying,
    "Value" jsonb NOT NULL,
    "OrganizationId" character varying(20),
    CONSTRAINT settings_pk PRIMARY KEY ("Id")
);
--rollback DROP TABLE IF EXISTS public."Settings";

-- changeset Koza:20210817163200-2
CREATE UNIQUE INDEX settings_key_orgid_cntx_cntxval_profile_uindex
    ON public."Settings" USING btree
        ("Key" ASC NULLS LAST, "OrganizationId" ASC NULLS LAST, "Context" ASC NULLS LAST, "ContextValue" ASC NULLS LAST, "Profile" ASC NULLS LAST)
    TABLESPACE pg_default;
--rollback DROP INDEX public.settings_key_orgid_cntx_cntxval_profile_uindex;

-- changeset Koza:20210817163200-3
CREATE POLICY settings_org_isolation_policy
    ON public."Settings"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)) OR "OrganizationId" IS NULL);
--rollback DROP POLICY settings_org_isolation_policy ON public."Settings";

-- changeset Koza:20210817163200-4
ALTER TABLE public."Settings"
    ENABLE ROW LEVEL SECURITY;
--rollback ALTER TABLE public."Settings" DISABLE ROW LEVEL SECURITY;

-- changeset Koza:20210817163200-5
CREATE TABLE IF NOT EXISTS public."SettingsMetadata"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "Key" character varying(255) NOT NULL,
    "Value" jsonb NOT NULL,
    "OrganizationId" character varying(20),
    CONSTRAINT settingsmetadata_pk PRIMARY KEY ("Id")
);
--rollback DROP TABLE IF EXISTS public."SettingsMetadata";

-- changeset Koza:20210817163200-6
CREATE UNIQUE INDEX settingsmetadata_key_orgid_uindex
    ON public."SettingsMetadata" USING btree
        ("Key" ASC NULLS LAST, "OrganizationId" ASC NULLS LAST)
    TABLESPACE pg_default;
--rollback DROP INDEX public.settingsmetadata_key_orgid_uindex;

-- changeset Koza:20210817163200-7
CREATE POLICY settingsmetadata_org_isolation_policy
    ON public."SettingsMetadata"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)) OR "OrganizationId" IS NULL)
;
--rollback DROP POLICY settingsmetadata_org_isolation_policy ON public."SettingsMetadata";

-- changeset Koza:20210817163200-8
ALTER TABLE public."SettingsMetadata"
    ENABLE ROW LEVEL SECURITY;
--rollback ALTER TABLE public."SettingsMetadata" DISABLE ROW LEVEL SECURITY;
