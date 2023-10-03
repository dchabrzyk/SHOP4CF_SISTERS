-- liquibase formatted sql

-- changeset Skorup:20220125190000-1

-- Table: public.StepResourceQuantityStatistics

CREATE TABLE public."StepResourceQuantityStatistics"
(
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId" uuid NOT NULL,
    "TaskId" uuid NOT NULL,
	"StepId" uuid NOT NULL,
	"ResourceId" uuid NOT NULL,
    "PlannedQuantity" numeric,
    "RemainingQuantity" numeric,
    "ProducedQuantity" numeric,
    CONSTRAINT "StepResourceQuantityStatistics_pkey" PRIMARY KEY ("StepId", "ResourceId", "ScenarioId"),
    CONSTRAINT "StepResourceQuantityStatistics_Scenario" FOREIGN KEY ("ScenarioId")
        REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "StepResourceQuantityStatistics_Task" FOREIGN KEY ("ScenarioId", "TaskId")
        REFERENCES public."Tasks" ("ScenarioId", "Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	CONSTRAINT "StepResourceQuantityStatistics_Step" FOREIGN KEY ("StepId", "ScenarioId")
        REFERENCES public."Steps" ("Id", "ScenarioId")
        ON UPDATE CASCADE
        ON DELETE CASCADE,
	CONSTRAINT "StepResourceQuantityStatistics_Resource" FOREIGN KEY ("ScenarioId", "ResourceId")
        REFERENCES public."Resources" ("ScenarioId", "Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
)

TABLESPACE pg_default;

ALTER TABLE public."StepResourceQuantityStatistics"
    OWNER to postgres;

ALTER TABLE public."StepResourceQuantityStatistics"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."StepResourceQuantityStatistics" TO cdems_user;

GRANT ALL ON TABLE public."StepResourceQuantityStatistics" TO postgres;
-- POLICY: StepResourceQuantityStatistics_RLS

CREATE POLICY "StepResourceQuantityStatistics_RLS"
    ON public."StepResourceQuantityStatistics"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

