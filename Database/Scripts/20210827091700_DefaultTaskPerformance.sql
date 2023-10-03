-- liquibase formatted sql

-- changeset Lukas:20210827091700-1
CREATE TABLE IF NOT EXISTS public."DefaultTaskPerformances"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId" uuid NOT NULL,
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "TaskId" uuid NOT NULL,        
    "ProcessingPhase" character varying(255) COLLATE pg_catalog."default",
    "ProcessingTime" interval,
    "TimePerPiece" interval,
    "TimePerPieceQuantity" numeric,
    CONSTRAINT "DefaultTaskPerformances_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "DefaultTaskPerformances_Scenarios" FOREIGN KEY ("ScenarioId")
    REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
                             ON UPDATE CASCADE
                             ON DELETE CASCADE,
    CONSTRAINT "DefaultTaskPerformances_Tasks" FOREIGN KEY ("TaskId", "ScenarioId")
    REFERENCES public."Tasks" ("Id", "ScenarioId") MATCH SIMPLE
                             ON UPDATE CASCADE
                             ON DELETE CASCADE
    )

    TABLESPACE pg_default;

ALTER TABLE public."DefaultTaskPerformances"
    OWNER to postgres;

ALTER TABLE public."DefaultTaskPerformances"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."DefaultTaskPerformances" TO cdems_user;

GRANT ALL ON TABLE public."DefaultTaskPerformances" TO postgres;

--rollback DROP TABLE public."DefaultTaskPerformances";

-- changeset Lukas:20210827091700-2
CREATE POLICY default_task_performances_org_isolation_policy
    ON public."DefaultTaskPerformances"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY default_task_performances_org_isolation_policy ON public."DefaultTaskPerformances";