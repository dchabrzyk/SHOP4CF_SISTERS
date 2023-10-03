-- liquibase formatted sql

-- changeset Lukas:20230519165200-1
alter table "StepExecutionStatistics"
    add "LastResourceId" uuid;

-- changeset Lukas:20230519165200-2
alter table "StepExecutionStatistics"
    add constraint "StepExecutionStatistics_Resources_Id_ScenarioId_fk"
        foreign key ("LastResourceId", "ScenarioId") references "Resources" ("Id", "ScenarioId") on update cascade on delete cascade;

-- changeset Lukas:20230519165200-3
alter table "TaskExecutionStatistics"
    add "LastResourceId" uuid;

-- changeset Lukas:20230519165200-4
alter table "TaskExecutionStatistics"
    add constraint "TaskExecutionStatistics_Resources_Id_ScenarioId_fk"
        foreign key ("LastResourceId", "ScenarioId") references "Resources" ("Id", "ScenarioId") on update cascade on delete cascade;