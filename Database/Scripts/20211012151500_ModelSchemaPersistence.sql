-- liquibase formatted sql

-- changeset Koza:20211012151500-1
CREATE TABLE IF NOT EXISTS public."ModelInstances"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId" uuid NOT NULL,
    "Schema" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Version" character varying(255) COLLATE pg_catalog."default" NOT NULL,
    "Value" jsonb NOT NULL,
    CONSTRAINT "ModelInstances_pkey" PRIMARY KEY ("Id", "ScenarioId")
) TABLESPACE pg_default;

ALTER TABLE "public"."ModelInstances" ADD CONSTRAINT "ModelInstances_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES "public"."Scenarios" ("Id") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE public."ModelInstances" OWNER to postgres;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."ModelInstances" TO cdems_user;

GRANT ALL ON TABLE public."ModelInstances" TO postgres;

ALTER TABLE public."ModelInstances" ENABLE ROW LEVEL SECURITY;

CREATE POLICY model_instances_org_isolation_policy
    ON public."ModelInstances"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY model_instances_org_isolation_policy ON public."ModelInstances";
--rollback DROP TABLE public."ModelInstances";