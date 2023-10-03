-- liquibase formatted sql

-- changeset GO:20230306000000-1
ALTER TABLE "Resources"
    ALTER COLUMN "DateTimeFrom" SET DEFAULT NULL;

-- changeset GO:20230306000000-2
ALTER TABLE "Resources"
    ALTER COLUMN "DateTimeTo" SET DEFAULT NULL;

-- changeset GO:20230306000000-3
ALTER TABLE  "Resources" 
    ALTER COLUMN "DateTimeFrom" DROP NOT NULL;

-- changeset GO:20230306000000-4
ALTER TABLE  "Resources" 
    ALTER COLUMN "DateTimeTo" DROP NOT NULL;