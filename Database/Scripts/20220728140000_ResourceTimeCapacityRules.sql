-- liquibase formatted sql

-- changeset Sko:20220728140000-1
create table "ResourceTimeCapacityRules"
(
    "ResourceId"            uuid        not null,
    "TimeCapacityRuleId"    uuid        not null,
    "ScenarioId"            uuid        not null,
    "TenantId"              varchar(20) not null,
    primary key ("ResourceId", "TimeCapacityRuleId", "ScenarioId"),
    constraint "ResourceTimeCapacityRules_TimeCapacityRules"
        foreign key ("TimeCapacityRuleId", "ScenarioId") references "TimeCapacityRules"
            on update cascade on delete cascade,
    constraint "ResourceTimeCapacityRules_Resources"
        foreign key ("ResourceId", "ScenarioId") references "Resources"
            on update cascade on delete cascade
);

alter table "ResourceTimeCapacityRules"
    owner to postgres;

create unique index "ResourceTimeCapacityRules_uc"
    on "ResourceTimeCapacityRules" ("ResourceId", "TimeCapacityRuleId", "ScenarioId");

create policy "ResourceTimeCapacityRules_RLS" on "ResourceTimeCapacityRules"
    as permissive
    for all
    using ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR ("TenantId" IS NULL));

grant delete, insert, select, update on "ResourceTimeCapacityRules" to cdems_user;



