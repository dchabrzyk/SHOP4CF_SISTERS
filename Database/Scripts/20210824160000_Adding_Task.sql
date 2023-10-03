-- liquibase formatted sql

-- changeset Skorup:20210824160000-1
CREATE TABLE IF NOT EXISTS public."Tasks"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId" uuid NOT NULL,
    "ExternalId" character varying(255) COLLATE pg_catalog."default",
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "PlannedQuantity" numeric,
    "PlannedScrapQuantity" numeric,
    "DateTimeFrom" timestamp without time zone,
    "DateTimeTo" timestamp without time zone,
    "IsDateTimeFromStrict" boolean,
    "IsDateTimeToStrict" boolean,
    "Name" character varying(255) COLLATE pg_catalog."default",
    "Priority" integer,
    "Type" integer,
    "TaskPackageId" uuid,
    CONSTRAINT "Tasks_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "Tasks_Scenarios" FOREIGN KEY ("ScenarioId")
		REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "Task_Packages" FOREIGN KEY ("TaskPackageId")
        REFERENCES public."TaskPackages" ("Id") MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)

TABLESPACE pg_default;

ALTER TABLE public."Tasks"
    OWNER to postgres;

ALTER TABLE public."Tasks"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."Tasks" TO cdems_user;

GRANT ALL ON TABLE public."Tasks" TO postgres;

--rollback DROP TABLE public."Tasks";

-- changeset Skorup:20210824160000-2
CREATE POLICY tasks_org_isolation_policy
    ON public."Tasks"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY tasks_org_isolation_policy ON public."Tasks";

-- changeset Skorup:20210824160000-3

ALTER TABLE public."Tasks" DROP CONSTRAINT "Tasks_pkey";

ALTER TABLE public."Tasks"
    ADD CONSTRAINT "Tasks_pkey" PRIMARY KEY ("Id", "ScenarioId");

--rollback ALTER TABLE public."Tasks" DROP CONSTRAINT "Tasks_pkey"; ALTER TABLE public."Tasks" ADD CONSTRAINT "Tasks_pkey" PRIMARY KEY ("Id");

