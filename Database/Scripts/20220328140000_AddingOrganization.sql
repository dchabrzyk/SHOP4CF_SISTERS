-- liquibase formatted sql

-- changeset Skorup:20220328140000-1
CREATE TABLE IF NOT EXISTS public."Organizations"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4
(
),
    "ScenarioId" uuid NOT NULL,
    "ExternalId" character varying
(
    255
) COLLATE pg_catalog."default",
    "TenantId" character varying
(
    20
) COLLATE pg_catalog."default" NOT NULL,
    "Name" character varying
(
    255
) COLLATE pg_catalog."default",
    "Types" integer [],
    CONSTRAINT "Organizations_pkey" PRIMARY KEY
(
    "Id",
    "ScenarioId"
),
    CONSTRAINT "Organizations_Scenarios" FOREIGN KEY
(
    "ScenarioId"
)
    REFERENCES public."Scenarios"
(
    "Id"
) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    )
    TABLESPACE pg_default;

ALTER TABLE public."Organizations"
    OWNER to postgres;

ALTER TABLE public."Organizations"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."Organizations" TO cdems_user;

GRANT
ALL
ON TABLE public."Organizations" TO postgres;

CREATE
POLICY organizations_org_isolation_policy
    ON public."Organizations"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));
