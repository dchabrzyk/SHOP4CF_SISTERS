-- liquibase formatted sql

-- changeset Lukas:20210909174500-1
ALTER TABLE "ResourceSupply"
    RENAME TO "ResourceCapacities";

--rollback ALTER TABLE "ResourceCapacities" RENAME TO "ResourceSupply";

-- changeset Lukas:20210909174500-2
ALTER TABLE public."ResourceCapacities"
    RENAME COLUMN "EntryType" TO "ChangeType";

--rollback ALTER TABLE public."ResourceCapacities" RENAME COLUMN "ChangeType" TO "EntryType";

-- changeset Lukas:20210909174500-3
ALTER TABLE public."ResourceCapacities"
    RENAME COLUMN "EventSource" TO "EntrySource";

--rollback ALTER TABLE public."ResourceCapacities" RENAME COLUMN "EntrySource" TO "EventSource";

-- changeset Lukas:20210909174500-4
ALTER TABLE public."ResourceCapacities"
    ADD COLUMN "Group" integer NOT NULL DEFAULT 0;

--rollback ALTER TABLE public."Group" DROP COLUMN "Group";

-- changeset Lukas:20210909174500-5
ALTER TABLE public."ResourceCapacities"
    DROP COLUMN "EventName";

--rollback ALTER TABLE public."Group" ADD COLUMN "EventName" character varying(100) COLLATE pg_catalog."default" NOT NULL DEFAULT ''::character varying;

-- changeset Lukas:20210909174500-6

CREATE OR REPLACE PROCEDURE public."CreateScenario"(
	"scenarioId" uuid,
	"scenarioName" character varying,
	"organizationId" character varying,
	"userId" character varying,
	"createdAt" timestamp without time zone,
	status integer)
LANGUAGE 'sql'
AS '
INSERT INTO "Scenarios" ("Id", "Name", "Status", "OrganizationId", "UserId", "CreatedAt")
VALUES ("scenarioId", "scenarioName", "status", "organizationId", "userId", "createdAt");

INSERT INTO "Resources"
("Id", "ScenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId")
SELECT "Id", "scenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId"
FROM "Resources" WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0);

INSERT INTO "ResourceCapacities"
("Id", "ResourceId", "ScenarioId", "WorkQuantityValue", "WorkQuantityUnit", "ChangeType", "PeriodStart", "PeriodEnd", "OrganizationId", "EntrySource", "Group")
SELECT uuid_generate_v4(), "ResourceId", "scenarioId", "WorkQuantityValue", "WorkQuantityUnit", "ChangeType", "PeriodStart", "PeriodEnd", "OrganizationId", "EntrySource", "Group"
FROM "ResourceCapacities"
WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0)
';

-- changeset Lukas:20210909174500-7

CREATE OR REPLACE PROCEDURE public."MergeScenarios"(
	"sourceScenarioId" uuid,
	"destinationScenarioId" uuid)
LANGUAGE 'sql'
AS '
DELETE FROM "ResourceCapacities"
WHERE "ScenarioId" = "destinationScenarioId";

INSERT INTO "ResourceCapacities"
("Id", "ResourceId", "ScenarioId", "WorkQuantityValue", "WorkQuantityUnit", "ChangeType", "PeriodStart", "PeriodEnd", "OrganizationId", "EntrySource", "Group")
SELECT uuid_generate_v4(), "ResourceId", "destinationScenarioId", "WorkQuantityValue", "WorkQuantityUnit", "ChangeType", "PeriodStart", "PeriodEnd", "OrganizationId", "EntrySource", "Group"
FROM "ResourceCapacities"
WHERE "ScenarioId" = "sourceScenarioId";
';