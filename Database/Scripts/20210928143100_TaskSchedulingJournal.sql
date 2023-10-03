-- liquibase formatted sql

-- changeset Lukas:20210928143100-1
CREATE TABLE IF NOT EXISTS public."TaskSchedulingJournals"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId" uuid NOT NULL,
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "TaskId" uuid NOT NULL,
    "Status" int NOT NULL,
    CONSTRAINT "TaskSchedulingJournals_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "TaskSchedulingJournals_Scenarios" FOREIGN KEY ("ScenarioId")
        REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "TaskSchedulingJournals_Tasks" FOREIGN KEY ("TaskId", "ScenarioId")
        REFERENCES public."Tasks" ("Id", "ScenarioId") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

    TABLESPACE pg_default;

ALTER TABLE public."TaskSchedulingJournals"
    OWNER to postgres;

ALTER TABLE public."TaskSchedulingJournals"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."TaskSchedulingJournals" TO cdems_user;

GRANT ALL ON TABLE public."TaskSchedulingJournals" TO postgres;

--rollback DROP TABLE public."TaskSchedulingJournals";

-- changeset Lukas:20210928143100-2

CREATE POLICY task_scheduling_journals_org_isolation_policy
    ON public."TaskSchedulingJournals"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY task_scheduling_journals_org_isolation_policy ON public."TaskSchedulingJournals";

-- changeset Lukas:20210928143100-3
ALTER TABLE "public"."TaskSchedulingJournals" ADD CONSTRAINT "TaskSchedulingJournals_TaskId_ScenarioId_unique" UNIQUE ("TaskId", "ScenarioId");

--rollback ALTER TABLE "public"."TaskSchedulingJournals" DROP CONSTRAINT "TaskSchedulingJournals_TaskId_ScenarioId_unique";