-- liquibase formatted sql

-- changeset Sko:20230328160000-1
create table public."AggregatedResourceCapacities"
(
    "Id"            uuid default uuid_generate_v4() not null
        constraint "AggregatedResourceCapacities_pkey"
            primary key,
    "ResourceId"    uuid                            not null,
    "ScenarioId"    uuid                            not null
        constraint "AggregatedResourceCapacities_Scenarios"
            references public."Scenarios"
            on update cascade on delete cascade,
    "Quantity"      numeric                         not null,
    "QuantityUnit"  numeric,
    "CapacityGroup" numeric,
    "PeriodStart"   timestamp                       not null,
    "PeriodEnd"     timestamp                       not null,
    "TenantId"      varchar(20)                     not null,
    constraint "AggregatedResourceCapacities_Resources"
        foreign key ("ScenarioId", "ResourceId") references public."Resources" ("ScenarioId", "Id")
            on update cascade on delete cascade
);

alter table public."AggregatedResourceCapacities"
    owner to postgres;

create index "fki_AggregatedResourceCapacities_Scenarios"
    on public."AggregatedResourceCapacities" ("ScenarioId");

create index "fki_AggregatedResourceCapacities_Resources"
    on public."AggregatedResourceCapacities" ("ScenarioId", "ResourceId");

create policy aggregated_resource_capacity_org_isolation_policy
    on public."AggregatedResourceCapacities"
    as permissive
    for all
    to public
    using ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR ("TenantId" IS NULL));

ALTER TABLE public."AggregatedResourceCapacities"
    ENABLE ROW LEVEL SECURITY;


grant delete, insert, select, update on public."AggregatedResourceCapacities" to cdems_user;

