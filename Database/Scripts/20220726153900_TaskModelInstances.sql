-- liquibase formatted sql

-- changeset Lukas:20220726153900-1
DROP TABLE "StepModelInstances";

-- changeset Lukas:20220726153900-2
CREATE TABLE IF NOT EXISTS "TaskModelInstances"
(
    "Id"                 uuid        NOT NULL DEFAULT uuid_generate_v4(),
    "TaskId"             uuid        not null,
    "StepId"             uuid        null,
    "StepResourceSpecId" uuid        null,
    "ModelInstanceId"    uuid        not null,
    "ScenarioId"         uuid        not null,
    "TenantId"           varchar(20) not null,
    CONSTRAINT "TaskModelInstances_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "TaskModelInstances_ModelInstances" FOREIGN KEY ("ModelInstanceId", "ScenarioId") REFERENCES "ModelInstances" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "TaskModelInstances_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES "Scenarios" ("Id") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "TaskModelInstances_Tasks" FOREIGN KEY ("TaskId", "ScenarioId") REFERENCES "Tasks" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "TaskModelInstances_Steps" FOREIGN KEY ("StepId", "ScenarioId") REFERENCES "Steps" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "TaskModelInstances_StepResourceSpecs" FOREIGN KEY ("StepResourceSpecId", "ScenarioId") REFERENCES "StepResourceSpecs" ON UPDATE CASCADE ON DELETE CASCADE
);

alter table "TaskModelInstances"
    owner to postgres;

create policy "TaskModelInstances_RLS" on "TaskModelInstances"
    as permissive
    for all
    using ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR ("TenantId" IS NULL));

grant delete, insert, select, update on "TaskModelInstances" to cdems_user;

-- changeset Lukas:20220726153900-3
DROP TABLE "TaskModelInstances";

-- changeset Lukas:20220726153900-4
CREATE TABLE IF NOT EXISTS "TaskModelInstances"
(
    "Id"                 uuid        NOT NULL DEFAULT uuid_generate_v4(),
    "TaskId"             uuid        not null,
    "StepId"             uuid        null,
    "StepResourceSpecId" uuid        null,
    "ModelInstanceId"    uuid        not null,
    "ScenarioId"         uuid        not null,
    "TenantId"           varchar(20) not null,
    CONSTRAINT "TaskModelInstances_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "TaskModelInstances_ModelInstances" FOREIGN KEY ("ModelInstanceId", "ScenarioId") REFERENCES "ModelInstances" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "TaskModelInstances_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES "Scenarios" ("Id") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "TaskModelInstances_Tasks" FOREIGN KEY ("TaskId", "ScenarioId") REFERENCES "Tasks" ("Id", "ScenarioId") ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "TaskModelInstances_Steps" FOREIGN KEY ("StepId", "ScenarioId") REFERENCES "Steps" ("Id", "ScenarioId") ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "TaskModelInstances_StepResourceSpecs" FOREIGN KEY ("StepResourceSpecId", "ScenarioId") REFERENCES "StepResourceSpecs" ("Id", "ScenarioId") ON UPDATE CASCADE ON DELETE CASCADE
);

alter table "TaskModelInstances"
    owner to postgres;

create policy "TaskModelInstances_RLS" on "TaskModelInstances"
    as permissive
    for all
    using ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR ("TenantId" IS NULL));

grant delete, insert, select, update on "TaskModelInstances" to cdems_user;