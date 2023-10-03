-- liquibase formatted sql

-- changeset Koza:20210916104000-1
--rollback alter table public."Resources" drop column "DateTimeFrom";
--rollback alter table public."Resources" drop column "DateTimeTo";
--rollback alter table public."Resources" drop column "VersionNumber";
--rollback alter table public."Resources" drop column "VersionDateTime";
--rollback alter table public."Resources" drop column "AgreementType";
--rollback alter table public."Resources" drop column "IsActive";
--rollback alter table public."Resources" drop column "AgreedFTE";
--rollback alter table public."Resources" drop column "PlannedEffort";
--rollback alter table public."Resources" drop column "RemainingEffort";
alter table public."Resources"
    add "DateTimeFrom" timestamp without time zone not null default now(),
    add "DateTimeTo" timestamp without time zone not null default now(),
    add "VersionNumber" int default 0 not null,
    add "VersionDateTime" timestamp without time zone default now() not null,
    add "AgreementType" int default 0 not null,
    add "IsActive" bool default false not null,
    add "AgreedFTE" numeric default 0 not null,
    add "PlannedEffort" numeric default 0 not null,
    add "RemainingEffort" numeric default 0 not null;

-- changeset Koza:20210916104000-2
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
("Id", "ScenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId", "DateTimeFrom", "DateTimeTo", "VersionNumber", "VersionDateTime", "AgreementType", "IsActive", "AgreedFTE", "PlannedEffort", "RemainingEffort")
SELECT "Id", "scenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId", "DateTimeFrom", "DateTimeTo", "VersionNumber", "VersionDateTime", "AgreementType", "IsActive", "AgreedFTE", "PlannedEffort", "RemainingEffort"
FROM "Resources" WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0);

INSERT INTO "ResourceCapacities"
("Id", "ResourceId", "ScenarioId", "WorkQuantityValue", "WorkQuantityUnit", "ChangeType", "PeriodStart", "PeriodEnd", "OrganizationId", "EntrySource", "Group")
SELECT uuid_generate_v4(), "ResourceId", "scenarioId", "WorkQuantityValue", "WorkQuantityUnit", "ChangeType", "PeriodStart", "PeriodEnd", "OrganizationId", "EntrySource", "Group"
FROM "ResourceCapacities"
WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0)
';