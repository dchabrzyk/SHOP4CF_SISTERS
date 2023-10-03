-- liquibase formatted sql

-- changeset Skorup:20211214150000-1 rollbackSplitStatements:false

-- Table: public.StepResourceStatistics

CREATE TABLE public."StepResourceStatistics"
(
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId" uuid NOT NULL,
    "TaskId" uuid NOT NULL,
	"StepId" uuid NOT NULL,
	"ResourceId" uuid NOT NULL,
    "Status" integer,
    "ExecutionStart" timestamp without time zone,
    "ExecutionEnd" timestamp without time zone,
    "ExecutionDuration" interval,
    "ExecutionLeadTime" interval,
    "ExecutionWaitingTime" interval,
	"ExecutionQuantityGood" numeric,
	"ExecutionQuantityScrap" numeric,
	"ExecutionPayload" jsonb,
    CONSTRAINT "StepResourceStatistics_pkey" PRIMARY KEY ("StepId", "ResourceId", "ScenarioId"),
    CONSTRAINT "StepResourceStatistics_Scenario" FOREIGN KEY ("ScenarioId")
        REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "StepResourceStatistics_Task" FOREIGN KEY ("ScenarioId", "TaskId")
        REFERENCES public."Tasks" ("ScenarioId", "Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	CONSTRAINT "StepResourceStatistics_Step" FOREIGN KEY ("StepId", "ScenarioId")
        REFERENCES public."Steps" ("Id", "ScenarioId")
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	CONSTRAINT "StepResourceStatistics_Resource" FOREIGN KEY ("ScenarioId", "ResourceId")
        REFERENCES public."Resources" ("ScenarioId", "Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public."StepResourceStatistics"
    OWNER to postgres;

ALTER TABLE public."StepResourceStatistics"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."StepResourceStatistics" TO cdems_user;

GRANT ALL ON TABLE public."StepResourceStatistics" TO postgres;
-- POLICY: StepResourceStatistics_RLS

CREATE POLICY "StepResourceStatistics_RLS"
    ON public."StepResourceStatistics"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY "StepResourceStatistics_RLS" ON public."StepResourceStatistics";
--rollback DROP TABLE public."StepResourceStatistics";
