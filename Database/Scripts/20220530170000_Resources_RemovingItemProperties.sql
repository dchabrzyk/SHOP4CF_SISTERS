-- liquibase formatted sql

-- changeset Sko:20220530170000-1
ALTER TABLE public."Resources"
    DROP COLUMN "ItemRevision";

-- changeset Sko:20220530170000-2

ALTER TABLE public."CustomerOrderLines"
    RENAME "ItemName" TO "Description";

ALTER TABLE public."CustomerOrderLines"
    DROP COLUMN "ItemRevision";

-- changeset Sko:20220530180000-3
ALTER TABLE public."Resources"
    DROP COLUMN "RevisionValidFrom";

ALTER TABLE public."Resources"
    DROP COLUMN "RevisionValidTo";
