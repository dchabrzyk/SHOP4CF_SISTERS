-- liquibase formatted sql

-- changeset Lukas:20210931143500-1
CREATE TABLE IF NOT EXISTS public."WorkJournalRecords"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "OrganizationId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "TaskId" uuid,
    "TaskPackageId" uuid,
    "PersonId" uuid,
    "AgreementId" uuid,
    "EventType" character varying(150) COLLATE pg_catalog."default" NOT NULL,
    "EventStart" timestamp without time zone NOT NULL,
    "Cancelled" boolean NOT NULL DEFAULT false,
    "EventPayload" jsonb,
    CONSTRAINT "WorkJournalRecords_pkey" PRIMARY KEY ("Id")   
) TABLESPACE pg_default;

ALTER TABLE public."WorkJournalRecords"
    OWNER to postgres;

ALTER TABLE public."WorkJournalRecords"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."WorkJournalRecords" TO cdems_user;

GRANT ALL ON TABLE public."WorkJournalRecords" TO postgres;

--rollback DROP TABLE public."WorkJournalRecords";

-- changeset Lukas:20210931143500-2
CREATE POLICY work_journal_records_org_isolation_policy
    ON public."WorkJournalRecords"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

--rollback DROP POLICY work_journal_records_org_isolation_policy ON public."WorkJournalRecords";

-- changeset Lukas:20210931143500-3
ALTER TABLE public."WorkJournalRecords"
    ALTER COLUMN "EventType" TYPE INT
    USING "EventType"::integer;

--rollback ALTER TABLE public."WorkJournalRecords" ALTER COLUMN "EventType" TYPE character varying(150) COLLATE pg_catalog."default" NOT NULL;

-- changeset Lukas:20210931143500-4
ALTER TABLE public."WorkJournalRecords"
    RENAME COLUMN "TaskPackageId" TO "StepId";

--rollback ALTER TABLE public."WorkJournalRecords" RENAME COLUMN "StepId" TO "TaskPackageId";

-- changeset Lukas:20210931143500-5
ALTER TABLE public."WorkJournalRecords"
    ADD COLUMN "ExternalId" character varying(150) COLLATE pg_catalog."default";

--rollback ALTER TABLE public."WorkJournalRecords" DROP COLUMN "ExternalId";