-- liquibase formatted sql

-- changeset Lukas:20220926110700-1
CREATE TABLE IF NOT EXISTS public."Tags"
(
    "Id"         uuid                                                NOT NULL DEFAULT uuid_generate_v4(),
    "Name"       character varying(100) COLLATE pg_catalog."default" NOT NULL,
    "TenantId"   character varying(20) COLLATE pg_catalog."default"  NOT NULL,
    "ParentName" character varying(100) COLLATE pg_catalog."default",
    "Emoji"      character varying(100) COLLATE pg_catalog."default",
    "Color"      character varying(10) COLLATE pg_catalog."default",
    "TagType"    int                                                 NOT NULL,
    CONSTRAINT "Tags_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "Tags_uc" UNIQUE ("Name", "TenantId")
) TABLESPACE pg_default;

ALTER TABLE public."Tags"
    OWNER to postgres;

ALTER TABLE public."Tags"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."Tags" TO cdems_user;

GRANT ALL ON TABLE public."Tags" TO postgres;

CREATE POLICY default_tags_org_isolation_policy
    ON public."Tags"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));