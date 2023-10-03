-- liquibase formatted sql

-- changeset Skorup:20220329140000-1
CREATE TABLE IF NOT EXISTS public."Contacts"
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
    "Email" character varying
(
    255
) COLLATE pg_catalog."default",
    "Phone" character varying
(
    255
) COLLATE pg_catalog."default",
    "Description" character varying
(
    255
) COLLATE pg_catalog."default",
    "OrganizationId" uuid,
    CONSTRAINT "Contacts_pkey" PRIMARY KEY
(
    "Id",
    "ScenarioId"
),
    CONSTRAINT "Contacts_Scenarios" FOREIGN KEY
(
    "ScenarioId"
)
    REFERENCES public."Scenarios"
(
    "Id"
) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE,
    CONSTRAINT "Contacts_Organization" FOREIGN KEY
(
    "OrganizationId",
    "ScenarioId"
)
    REFERENCES public."Organizations"
(
    "Id",
    "ScenarioId"
) MATCH SIMPLE
    ON UPDATE CASCADE
    ON DELETE CASCADE
    )
    TABLESPACE pg_default;

ALTER TABLE public."Contacts"
    OWNER to postgres;

ALTER TABLE public."Contacts"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."Contacts" TO cdems_user;

GRANT
ALL
ON TABLE public."Contacts" TO postgres;

CREATE
POLICY organizations_org_isolation_policy
    ON public."Contacts"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));
