-- liquibase formatted sql

-- changeset Lukas:20210826153600-1
CREATE TABLE IF NOT EXISTS public."TaskRequiredResources"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId" uuid NOT NULL,
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "TaskId" uuid NOT NULL,
    "ResourceId" uuid NOT NULL,
    "Quantity" numeric NOT NULL,
    "UseChildrenAsAlternatives" boolean,
    "IsRelativePerformance" boolean,
    "AssignedProcessingPhase" character varying(255) COLLATE pg_catalog."default",
    "AlternativesCategory" character varying(100) COLLATE pg_catalog."default",
    CONSTRAINT "TaskRequiredResources_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "TaskRequiredResources_Scenarios" FOREIGN KEY ("ScenarioId")
    REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
                             ON UPDATE CASCADE
                             ON DELETE CASCADE,
    CONSTRAINT "TaskRequiredResources_Tasks" FOREIGN KEY ("TaskId", "ScenarioId")
    REFERENCES public."Tasks" ("Id", "ScenarioId") MATCH SIMPLE
                             ON UPDATE CASCADE
                             ON DELETE CASCADE,
    CONSTRAINT "TaskRequiredResources_Resources" FOREIGN KEY ("ResourceId", "ScenarioId")
    REFERENCES public."Resources" ("Id", "ScenarioId") MATCH SIMPLE
                             ON UPDATE NO ACTION
                             ON DELETE NO ACTION
    )

    TABLESPACE pg_default;

ALTER TABLE public."TaskRequiredResources"
    OWNER to postgres;

ALTER TABLE public."TaskRequiredResources"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."TaskRequiredResources" TO cdems_user;

GRANT ALL ON TABLE public."TaskRequiredResources" TO postgres;

--rollback DROP TABLE public."TaskRequiredResources";

-- changeset Lukas:20210826153600-2
CREATE POLICY task_required_resources_org_isolation_policy
    ON public."TaskRequiredResources"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY task_required_resources_org_isolation_policy ON public."TaskRequiredResources";