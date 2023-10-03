-- liquibase formatted sql

-- changeset Sko:20221102111200-1
CREATE TABLE IF NOT EXISTS public."AttachmentContent"
(
    "Id"                uuid                                                NOT NULL DEFAULT uuid_generate_v4(),
    "ExternalId"        character varying(50) COLLATE pg_catalog."default"  NOT NULL,
    "TenantId"          character varying(20) COLLATE pg_catalog."default"  NOT NULL,
    "TextAttachment"    text COLLATE pg_catalog."default",
    "BinaryAttachment"  bytea,
    CONSTRAINT "AttachmentContent_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "AttachmentContent_uc" UNIQUE ("ExternalId", "TenantId")
) TABLESPACE pg_default;

ALTER TABLE public."AttachmentContent"
    OWNER to postgres;

ALTER TABLE public."AttachmentContent"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."AttachmentContent" TO cdems_user;

GRANT ALL ON TABLE public."AttachmentContent" TO postgres;

CREATE POLICY default_tags_org_isolation_policy
    ON public."AttachmentContent"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));