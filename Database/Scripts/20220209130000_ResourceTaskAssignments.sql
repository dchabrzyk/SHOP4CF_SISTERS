-- liquibase formatted sql

-- changeset Skorup:20220209130000-1

-- Table: public.ResourceTaskAssignment

CREATE TABLE public."ResourceTaskAssignments"
(
    "Id"             uuid                                               NOT NULL DEFAULT uuid_generate_v4(),
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId"     uuid                                               NOT NULL,
    "TaskId"         uuid                                               NOT NULL,
    "ResourceId"     uuid                                               NOT NULL,
    "ConnectionType" integer,
    CONSTRAINT "ResourceTaskAssignments_pkey" PRIMARY KEY ("Id", "ScenarioId"),
    CONSTRAINT "ResourceTaskAssignments_Scenarios" FOREIGN KEY ("ScenarioId")
        REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "ResourceTaskAssignments_Task" FOREIGN KEY ("ScenarioId", "TaskId")
        REFERENCES public."Tasks" ("ScenarioId", "Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "ResourceTaskAssignments_Resource" FOREIGN KEY ("ScenarioId", "ResourceId")
        REFERENCES public."Resources" ("ScenarioId", "Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
) TABLESPACE pg_default;

ALTER TABLE public."ResourceTaskAssignments"
    OWNER to postgres;

ALTER TABLE public."ResourceTaskAssignments"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."ResourceTaskAssignments" TO cdems_user;

GRANT
ALL
ON TABLE public."ResourceTaskAssignments" TO postgres;
-- POLICY: ResourceTaskAssignments_RLS

CREATE
POLICY "ResourceTaskAssignments_RLS"
    ON public."ResourceTaskAssignments"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

