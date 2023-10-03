-- liquibase formatted sql

-- changeset Sko:20220628140000-1
create table "StepModelInstances"
(
    "StepId"      uuid        not null,
    "ModelInstanceId" uuid        not null,
    "ScenarioId"      uuid        not null,
    "TenantId"        varchar(20) not null,
    primary key ("StepId", "ModelInstanceId", "ScenarioId"),
    constraint "StepModelInstances_ModelInstances"
        foreign key ("ModelInstanceId", "ScenarioId") references "ModelInstances"
            on update cascade on delete cascade,
    constraint "StepModelInstances_Steps"
        foreign key ("StepId", "ScenarioId") references "Steps"
            on update cascade on delete cascade
);

alter table "StepModelInstances"
    owner to postgres;

create unique index "StepModelInstances_uc"
    on "StepModelInstances" ("StepId", "ModelInstanceId", "ScenarioId");

create policy "StepModelInstances_RLS" on "StepModelInstances"
    as permissive
    for all
    using ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR ("TenantId" IS NULL));

grant delete, insert, select, update on "StepModelInstances" to cdems_user;



