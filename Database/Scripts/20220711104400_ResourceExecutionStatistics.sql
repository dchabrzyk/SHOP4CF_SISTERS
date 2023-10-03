-- liquibase formatted sql

-- changeset Koza:20220711104400-1
CREATE TABLE "ResourceExecutionStatistics"
(
    "TenantId"          varchar(20) not null,
    "ScenarioId"        uuid        not null
        constraint "ResourceExecutionStatistics_Scenario"
            references "Scenarios"
            on update cascade on delete cascade,
    "ResourceId"        uuid        not null,
    "ExecutionStatus"   integer,
    "ExecutionStart"    timestamp,
    "ExecutionEnd"      timestamp,
    "ExecutionDuration" interval,
    CONSTRAINT "ResourceExecutionStatistics_pkey"
        PRIMARY KEY ("ResourceId", "ScenarioId"),
    CONSTRAINT "ResourceExecutionStatistics_Resource"
        FOREIGN KEY ("ResourceId", "ScenarioId") REFERENCES "Resources"
            ON UPDATE CASCADE ON DELETE CASCADE
);

ALTER TABLE "ResourceExecutionStatistics"
    owner to postgres;

GRANT DELETE, INSERT, SELECT, UPDATE ON "ResourceExecutionStatistics" TO cdems_user;

CREATE
policy "ResourceExecutionStatistics_RLS" ON "ResourceExecutionStatistics"
    AS permissive
    FOR ALL
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR ("TenantId" IS NULL));
