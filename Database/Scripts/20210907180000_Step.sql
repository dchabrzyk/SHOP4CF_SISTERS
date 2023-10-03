-- liquibase formatted sql

-- changeset Sko:20210907180000-1
CREATE TABLE IF NOT EXISTS public."Steps"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId" uuid NOT NULL,
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "TaskId" uuid NOT NULL,        
    "Name" character varying(255) COLLATE pg_catalog."default",
    "Position" integer,
    "ProcessingTime" interval,
    "TimePerPiece" interval,
    "TimePerPieceQuantity" numeric,
    CONSTRAINT "Steps_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "Steps_Scenarios" FOREIGN KEY ("ScenarioId")
    REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
                             ON UPDATE CASCADE
                             ON DELETE CASCADE,
    CONSTRAINT "Steps_Tasks" FOREIGN KEY ("TaskId", "ScenarioId")
    REFERENCES public."Tasks" ("Id", "ScenarioId") MATCH SIMPLE
                             ON UPDATE CASCADE
                             ON DELETE CASCADE
    )

    TABLESPACE pg_default;

ALTER TABLE public."Steps"
    OWNER to postgres;

ALTER TABLE public."Steps"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."Steps" TO cdems_user;

GRANT ALL ON TABLE public."Steps" TO postgres;

CREATE POLICY default_steps_org_isolation_policy
    ON public."Steps"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

DROP POLICY default_task_performances_org_isolation_policy ON public."DefaultTaskPerformances";
DROP TABLE public."DefaultTaskPerformances";

--rollback DROP POLICY steps_org_isolation_policy ON public."Steps";
--rollback DROP TABLE public."Steps";

--rollback CREATE TABLE IF NOT EXISTS public."DefaultTaskPerformances"("Id" uuid NOT NULL DEFAULT uuid_generate_v4(),"ScenarioId" uuid NOT NULL,"OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,"TaskId" uuid NOT NULL,"ProcessingPhase" character varying(255) COLLATE pg_catalog."default", "ProcessingTime" interval, "TimePerPiece" interval, "TimePerPieceQuantity" numeric, CONSTRAINT "DefaultTaskPerformances_pkey" PRIMARY KEY ("Id"), CONSTRAINT "DefaultTaskPerformances_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES public."Scenarios" ("Id") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE, CONSTRAINT "DefaultTaskPerformances_Tasks" FOREIGN KEY ("TaskId", "ScenarioId") REFERENCES public."Tasks" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE) TABLESPACE pg_default;

--rollback ALTER TABLE public."DefaultTaskPerformances" OWNER to postgres;

--rollback ALTER TABLE public."DefaultTaskPerformances" ENABLE ROW LEVEL SECURITY;

--rollback GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."DefaultTaskPerformances" TO cdems_user;

--rollback GRANT ALL ON TABLE public."DefaultTaskPerformances" TO postgres;

--rollback CREATE POLICY default_task_performances_org_isolation_policy ON public."DefaultTaskPerformances" AS PERMISSIVE FOR ALL TO public
   
