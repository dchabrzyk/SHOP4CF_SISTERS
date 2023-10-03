-- liquibase formatted sql

-- changeset Skorup:20211214150100-1 rollbackSplitStatements:false

-- Table: public.StepStatistics

CREATE TABLE public."StepStatistics"
(
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId" uuid NOT NULL,
    "TaskId" uuid NOT NULL,
    "StepId" uuid NOT NULL,
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
    CONSTRAINT "StepStatistics_pkey" PRIMARY KEY ("StepId", "ScenarioId"),
    CONSTRAINT "StepStatistics_Scenario" FOREIGN KEY ("ScenarioId")
        REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "StepStatistics_Step" FOREIGN KEY ("StepId", "ScenarioId")
        REFERENCES public."Steps" ("Id", "ScenarioId")
         DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT "StepStatistics_Task" FOREIGN KEY ("ScenarioId", "TaskId")
        REFERENCES public."Tasks" ("ScenarioId", "Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public."StepStatistics"
    OWNER to postgres;

ALTER TABLE public."StepStatistics"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."StepStatistics" TO cdems_user;

GRANT ALL ON TABLE public."StepStatistics" TO postgres;
-- POLICY: StepStatistics_RLS

CREATE POLICY "StepStatistics_RLS"
    ON public."StepStatistics"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY "StepStatistics_RLS" ON public."StepStatistics";
--rollback DROP TABLE public."StepStatistics";
