-- liquibase formatted sql

-- changeset Sko:20210906140000-1
ALTER TABLE public."Tasks" DROP CONSTRAINT IF EXISTS "Task_Packages";
DROP TABLE IF EXISTS "TaskPackages";

ALTER TABLE public."Tasks" DROP COLUMN "TaskPackageId";

ALTER TABLE public."Tasks" ADD COLUMN "ParentTaskId" uuid;

ALTER TABLE public."Tasks"
    ADD CONSTRAINT "Task_Task" FOREIGN KEY ("ScenarioId", "ParentTaskId")
    REFERENCES public."Tasks" ("ScenarioId", "Id")
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;


--rollback ALTER TABLE public."Tasks" DROP CONSTRAINT IF EXISTS "Task_Task";
--rollback ALTER TABLE public."Tasks" DROP COLUMN "ParentTaskId";
--rollback ALTER TABLE public."Tasks" ADD COLUMN "TaskPackageId" uuid;

--rollback CREATE TABLE IF NOT EXISTS public."TaskPackages" ( "Id" uuid NOT NULL DEFAULT uuid_generate_v4(), "ScenarioId" uuid NOT NULL, "ExternalId" character varying(255) COLLATE pg_catalog."default", "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL, "DateTimeFrom" timestamp without time zone, "DateTimeTo" timestamp without time zone, "IsDateTimeFromStrict" boolean, "IsDateTimeToStrict" boolean, "Name" character varying(255) COLLATE pg_catalog."default", CONSTRAINT "TaskPackages_pkey" PRIMARY KEY ("Id"), CONSTRAINT "TaskPackages_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES public."Scenarios" ("Id") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION TABLESPACE pg_default;

--rollback ALTER TABLE public."TaskPackages" OWNER to postgres;

--rollback ALTER TABLE public."TaskPackages" ENABLE ROW LEVEL SECURITY;

--rollback GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."TaskPackages" TO cdems_user;

--rollback GRANT ALL ON TABLE public."TaskPackages" TO postgres;

--rollback CREATE POLICY task_packages_org_isolation_policy ON public."TaskPackages" AS PERMISSIVE FOR ALL TO public USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback ALTER TABLE public."Tasks" ADD CONSTRAINT "Task_Packages" FOREIGN KEY ("TaskPackageId") REFERENCES public."TaskPackages" ("Id") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;