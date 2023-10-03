-- liquibase formatted sql

-- changeset Skorup:20211214150200-1 rollbackSplitStatements:false

-- Table: public.TaskStatistics

CREATE TABLE public."TaskStatistics"
(
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId" uuid NOT NULL,
    "TaskId" uuid NOT NULL,
    "Status" integer,
    "SchedulingStart" timestamp without time zone,
    "SchedulingEnd" timestamp without time zone,
    "SchedulingDuration" interval,
    "SchedulingLeadTime" interval,
    "SchedulingWaitingTime" interval,
    "SchedulingBufferDelay" interval,
    "ExecutionStart" timestamp without time zone,
    "ExecutionEnd" timestamp without time zone,
    "ExecutionDuration" interval,
    "ExecutionLeadTime" interval,
    "ExecutionWaitingTime" interval,
    CONSTRAINT "TaskStatistics_pkey" PRIMARY KEY ("TaskId", "ScenarioId"),
    CONSTRAINT "TaskStatistics_Scenario" FOREIGN KEY ("ScenarioId")
        REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "TaskStatistics_Task" FOREIGN KEY ("ScenarioId", "TaskId")
        REFERENCES public."Tasks" ("ScenarioId", "Id")
        DEFERRABLE INITIALLY DEFERRED
)

TABLESPACE pg_default;

ALTER TABLE public."TaskStatistics"
    OWNER to postgres;

ALTER TABLE public."TaskStatistics"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."TaskStatistics" TO cdems_user;

GRANT ALL ON TABLE public."TaskStatistics" TO postgres;
-- POLICY: TaskStatistics_RLS

CREATE POLICY "TaskStatistics_RLS"
    ON public."TaskStatistics"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY "TaskStatistics_RLS" ON public."TaskStatistics";
--rollback DROP TABLE public."TaskStatistics";
