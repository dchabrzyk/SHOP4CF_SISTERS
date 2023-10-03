-- liquibase formatted sql

-- changeset Skorup:20210818121000-1
CREATE TABLE IF NOT EXISTS public."TaskPackages"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId" uuid NOT NULL,
    "ExternalId" character varying(255) COLLATE pg_catalog."default",
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "DateTimeFrom" timestamp without time zone,
    "DateTimeTo" timestamp without time zone,
    "IsDateTimeFromStrict" boolean,
    "IsDateTimeToStrict" boolean,
    "Name" character varying(255) COLLATE pg_catalog."default",
    CONSTRAINT "TaskPackages_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "TaskPackages_Scenarios" FOREIGN KEY ("ScenarioId")
        REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public."TaskPackages"
    OWNER to postgres;

ALTER TABLE public."TaskPackages"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."TaskPackages" TO cdems_user;

GRANT ALL ON TABLE public."TaskPackages" TO postgres;

--rollback DROP TABLE public."TaskPackages";

-- changeset Skorup:20210818121000-2
CREATE POLICY task_packages_org_isolation_policy
    ON public."TaskPackages"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY task_packages_org_isolation_policy ON public."TaskPackages";
