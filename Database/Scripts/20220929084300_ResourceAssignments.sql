-- liquibase formatted sql

-- changeset Lukas:20220929084300-1
CREATE TABLE IF NOT EXISTS public."ResourceAssignments"
(
    "Id"             uuid                                               NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId"     uuid                                               NOT NULL,
    "TenantId"       character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "Resource1Id"    uuid                                               NOT NULL,
    "Resource1Type"  int                                                NOT NULL,
    "Resource2Id"    uuid                                               NOT NULL,
    "Resource2Type"  int                                                NOT NULL,
    "AssignmentType" int                                                NOT NULL,
    CONSTRAINT "ResourceAssignments_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "ResourceAssignments_uc" UNIQUE ("ScenarioId", "Resource1Id", "Resource2Id", "AssignmentType"),
    CONSTRAINT "ResourceAssignments_Resources1" FOREIGN KEY ("Resource1Id", "ScenarioId") REFERENCES public."Resources" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "ResourceAssignments_Resources2" FOREIGN KEY ("Resource2Id", "ScenarioId") REFERENCES public."Resources" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
) TABLESPACE pg_default;

ALTER TABLE public."ResourceAssignments"
    OWNER to postgres;

ALTER TABLE public."ResourceAssignments"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."ResourceAssignments" TO cdems_user;

GRANT ALL ON TABLE public."ResourceAssignments" TO postgres;

CREATE POLICY default_resource_assignments_org_isolation_policy
    ON public."ResourceAssignments"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));