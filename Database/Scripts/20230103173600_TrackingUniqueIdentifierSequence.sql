-- liquibase formatted sql

-- changeset Sko:20230103173600-1
CREATE TABLE IF NOT EXISTS public."TrackingUniqueIdentifierSequences"
(
    "Id"                uuid NOT NULL DEFAULT uuid_generate_v4(),
    "ExternalId"        character varying(255) COLLATE pg_catalog."default",
    "TenantId"          character varying(20) COLLATE pg_catalog."default"  NOT NULL,
    "Description"       character varying(255) COLLATE pg_catalog."default",
    "ResourceId"        uuid,
    "MinValue"          bigint NOT NULL,
    "MaxValue"          bigint NOT NULL,
    "CurrentValue"      bigint,
    "IncrementBy"       integer NOT NULL,
    "Cycle"             boolean NOT NULL,
    CONSTRAINT "TrackingUniqueIdentifierSequence_pkey" PRIMARY KEY ("Id")
) TABLESPACE pg_default;

ALTER TABLE public."TrackingUniqueIdentifierSequences"
    OWNER to postgres;

ALTER TABLE public."TrackingUniqueIdentifierSequences"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."TrackingUniqueIdentifierSequences" TO cdems_user;

GRANT ALL ON TABLE public."TrackingUniqueIdentifierSequences" TO postgres;

CREATE POLICY default_sequences_unique_identifier_org_isolation_policy
    ON public."TrackingUniqueIdentifierSequences"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));