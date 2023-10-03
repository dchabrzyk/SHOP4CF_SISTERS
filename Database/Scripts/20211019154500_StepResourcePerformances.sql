-- liquibase formatted sql

-- changeset Sko:20211019154500-1
CREATE TABLE public."StepResourcePerformances"
(
    "Id" uuid NOT NULL,
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "TaskId" uuid,
    "StepId" uuid,
    "ResourceId" uuid,
    "PeriodStart" timestamp without time zone,
    "PeriodEnd" timestamp without time zone,
    "PerformanceStatus" integer,
    "ProcessingTime" interval,
    "PerformancePayload" jsonb,
    CONSTRAINT "StepResourcePerformances_pkey" PRIMARY KEY ("Id")
)

TABLESPACE pg_default;

ALTER TABLE public."StepResourcePerformances"
    OWNER to postgres;

ALTER TABLE public."StepResourcePerformances"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."StepResourcePerformances" TO cdems_user;

GRANT ALL ON TABLE public."StepResourcePerformances" TO postgres;


--rollback DROP TABLE public."StepResourcePerformances";

-- changeset Sko:20211019154500-2
CREATE POLICY work_step_resource_performances_org_isolation_policy
    ON public."StepResourcePerformances"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY work_step_resource_performances_org_isolation_policy ON public."StepResourcePerformances";