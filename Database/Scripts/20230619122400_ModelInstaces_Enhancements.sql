-- liquibase formatted sql

-- changeset Lukas:20230619122400-1
alter table public."ModelInstances"
    RENAME COLUMN "Schema" TO "SchemaId";

-- changeset Lukas:20230619122400-2
alter table public."ModelInstances"
    RENAME COLUMN "Version" TO "SchemaVersion";

-- changeset Lukas:20230619122400-3
alter table public."ModelInstances"
    ADD COLUMN "CreatedBy"  varchar(255),
    ADD COLUMN "CreatedAt"  timestamp,
    ADD COLUMN "ModifiedBy" varchar(255),
    ADD COLUMN "ModifiedAt" timestamp;

-- changeset Lukas:20230619122400-4
alter table public."ModelInstances"
    ADD COLUMN "RevisionNumber" integer default 1  not null,
    ADD COLUMN "Status"         integer default 10 not null;