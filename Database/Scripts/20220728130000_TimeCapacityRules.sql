-- liquibase formatted sql

-- changeset Sco:20220728130000-1
CREATE TABLE "TimeCapacityRules"
(
    "Id"                uuid        NOT NULL DEFAULT uuid_generate_v4(),
    "TenantId"          varchar(20) not null,
    "ScenarioId"        uuid        not null
        constraint "TimeCapacityRules_Scenario"
            references "Scenarios"
            on update cascade on delete cascade,
    "ExternalId"        character varying(255) COLLATE pg_catalog."default",
    "Name"              character varying(255) COLLATE pg_catalog."default",
    "Start"             timestamp,
    "End"               timestamp,
    "Availability"      integer,
    "Recurrence"        text,
    CONSTRAINT "TimeCapacityRules_pkey"
        PRIMARY KEY ("Id", "ScenarioId")
);

ALTER TABLE "TimeCapacityRules"
    owner to postgres;

GRANT DELETE, INSERT, SELECT, UPDATE ON "TimeCapacityRules" TO cdems_user;

CREATE
policy "TimeCapacityRules_RLS" ON "TimeCapacityRules"
    AS permissive
    FOR ALL
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR ("TenantId" IS NULL));
