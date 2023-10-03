-- liquibase formatted sql

-- changeset Skorup:20230111190000-1

-- Table: public.TrackingUniqueIdentifierTaskAssignments

CREATE TABLE public."TrackingUniqueIdentifierTaskAssignments"
(
    "Id"             uuid                                               NOT NULL DEFAULT uuid_generate_v4(),
    "TenantId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId"     uuid                                               NOT NULL,
    "TaskId"         uuid                                               NOT NULL,
    "TrackingUniqueIdentifierId" uuid NOT NULL,
    "ConnectionType" integer,
    CONSTRAINT "TrackingUniqueIdentifierTaskAssignments_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "TrackingUniqueIdentifierTaskAssignments_Task" FOREIGN KEY ("ScenarioId", "TaskId")
        REFERENCES public."Tasks" ("ScenarioId", "Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "TrackingUniqueIdentifierTaskAssignmentsTrackingUniqueIdentifier" FOREIGN KEY ("TrackingUniqueIdentifierId")
        REFERENCES public."TrackingUniqueIdentifiers" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
) TABLESPACE pg_default;

ALTER TABLE public."TrackingUniqueIdentifierTaskAssignments"
    OWNER to postgres;

ALTER TABLE public."TrackingUniqueIdentifierTaskAssignments"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."TrackingUniqueIdentifierTaskAssignments" TO cdems_user;

GRANT
ALL
ON TABLE public."TrackingUniqueIdentifierTaskAssignments" TO postgres;
-- POLICY: TrackingUniqueIdentifierTaskAssignments_RLS

CREATE
POLICY "TrackingUniqueIdentifierTaskAssignments_RLS"
    ON public."TrackingUniqueIdentifierTaskAssignments"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));

