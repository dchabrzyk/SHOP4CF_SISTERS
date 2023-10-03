-- liquibase formatted sql

-- changeset Lukas:20230628110900-1
alter table "ResourceModelInstances"
    drop constraint "ResourceModelInstances_ModelInstances";

-- changeset Lukas:20230628110900-2
alter table "TaskModelInstances"
    drop constraint "TaskModelInstances_ModelInstances";

-- changeset Lukas:20230628110900-3
alter table "ModelInstances"
    drop constraint "ModelInstances_pkey";

-- changeset Lukas:20230628110900-4
alter table "ModelInstances"
    add primary key ("Id", "RevisionNumber");

-- changeset Lukas:20230628110900-5
alter table "ModelInstances"
    drop constraint "ModelInstances_Scenarios";

-- changeset Lukas:20230628110900-6
alter table "TaskModelInstances"
    drop column "TaskModelInstanceAssignmentType";

-- changeset Lukas:20230628110900-7
alter table "TaskModelInstances"
    ADD COLUMN "RevisionNumber" integer default 1 not null;

-- changeset Lukas:20230628110900-8
alter table "TaskModelInstances"
    add constraint "TaskModelInstances_ModelInstances"
        foreign key ("ModelInstanceId", "RevisionNumber") references "ModelInstances";

-- changeset Lukas:20230628110900-9
alter table "ResourceModelInstances"
    drop column "ResourceModelInstanceAssignmentType";

-- changeset Lukas:20230628110900-10
drop index "EquipmentModelInstances_uc";
