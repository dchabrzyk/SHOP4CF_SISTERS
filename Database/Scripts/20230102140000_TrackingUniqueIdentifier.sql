-- liquibase formatted sql

-- changeset Sko:20230102140000-1
CREATE TABLE IF NOT EXISTS public."TrackingUniqueIdentifiers"
(
    "Id"                uuid                                                NOT NULL DEFAULT uuid_generate_v4(),
    "TrackingNumber"    character varying(200) COLLATE pg_catalog."default"  NOT NULL,
    "Type"              integer NOT NULL,
    "TenantId"          character varying(20) COLLATE pg_catalog."default"  NOT NULL,
    "Description"       character varying(500) COLLATE pg_catalog."default",
    "Active"            boolean,
    CONSTRAINT "TrackingUniqueIdentifiers_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "TrackingUniqueIdentifiers_uc" UNIQUE ("TrackingNumber", "TenantId")
) TABLESPACE pg_default;

ALTER TABLE public."TrackingUniqueIdentifiers"
    OWNER to postgres;

ALTER TABLE public."TrackingUniqueIdentifiers"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."TrackingUniqueIdentifiers" TO cdems_user;

GRANT ALL ON TABLE public."TrackingUniqueIdentifiers" TO postgres;

CREATE POLICY default_tracking_unique_identifier_org_isolation_policy
    ON public."TrackingUniqueIdentifiers"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));