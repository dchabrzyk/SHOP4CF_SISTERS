-- liquibase formatted sql

-- changeset Skorup:20210825145000-1
CREATE TABLE IF NOT EXISTS public."TaskTimeBoxes"
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
    CONSTRAINT "TaskTimeBoxes_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "TaskTimeBoxes_Scenarios" FOREIGN KEY ("ScenarioId")
        REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public."TaskTimeBoxes"
    OWNER to postgres;

ALTER TABLE public."TaskTimeBoxes"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."TaskTimeBoxes" TO cdems_user;

GRANT ALL ON TABLE public."TaskTimeBoxes" TO postgres;

CREATE POLICY task_timeboxes_org_isolation_policy
    ON public."TaskTimeBoxes"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));
--rollback DROP TABLE public."TaskTimeBoxes";
--rollback DROP POLICY task_packages_org_isolation_policy ON public."TaskTimeBoxes";
