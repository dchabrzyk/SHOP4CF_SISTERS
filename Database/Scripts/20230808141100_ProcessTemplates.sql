-- liquibase formatted sql

-- changeset Lukas:20230808141100-1
create table public."ProcessTemplates"
(
    "Id"             uuid default uuid_generate_v4() not null constraint "ProcessTemplates_pkey"     primary key,
    "TenantId"       varchar(20)                     not null,
    "Name"           varchar(255)                    not null,
    "CreatedBy"      varchar(255)                    not null,
    "CreatedAt"      timestamp                       not null,
    "ModifiedBy"     varchar(255)                    not null,
    "ModifiedAt"     timestamp                       not null,
    "Segments"       jsonb                           not null,
    "Status"         integer   default 0             not null
);

alter table public."ProcessTemplates"
    owner to postgres;

create policy process_templates_org_isolation_policy
    on public."ProcessTemplates"
    as permissive
    for all
    to public
    using ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR ("TenantId" IS NULL));

ALTER TABLE public."ProcessTemplates"
    ENABLE ROW LEVEL SECURITY;


grant delete, insert, select, update on public."ProcessTemplates" to cdems_user;

