-- liquibase formatted sql

-- changeset Lukas:20210723104300-1
ALTER TABLE public."ResourceSupply"
    RENAME "Quantity" TO "WorkQuantityValue";

-- changeset Lukas:20210723104300-2
ALTER TABLE public."ResourceSupply"
    RENAME "QuantityType" TO "WorkQuantityUnit";

-- changeset Lukas:20210723104300-3
CREATE OR REPLACE PROCEDURE public."CreateScenario"(IN "scenarioId" uuid, IN "scenarioName" character varying, IN "organizationId" character varying, IN "userId" character varying, IN "createdAt" timestamp without time zone, IN status integer)
    LANGUAGE sql
    
AS '
INSERT INTO "Scenarios" ("Id", "Name", "Status", "OrganizationId", "UserId", "CreatedAt")
VALUES ("scenarioId", "scenarioName", "status", "organizationId", "userId", "createdAt");

INSERT INTO "Resources"
("Id", "ScenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId")
SELECT "Id", "scenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId"
FROM "Resources" WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0);

INSERT INTO "ResourceSupply"
("Id", "ResourceId", "ScenarioId", "WorkQuantityValue", "WorkQuantityUnit", "EntryType", "PeriodStart", "PeriodEnd", "OrganizationId", "EventSource", "EventName")
SELECT uuid_generate_v4(), "ResourceId", "scenarioId", "WorkQuantityValue", "WorkQuantityUnit", "EntryType", "PeriodStart", "PeriodEnd", "OrganizationId", "EventSource", "EventName"
FROM "ResourceSupply"
WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0)
';

-- changeset Lukas:20210723104300-4
CREATE OR REPLACE PROCEDURE public."MergeScenarios"("sourceScenarioId" uuid, "destinationScenarioId" uuid)
 LANGUAGE sql
AS '
DELETE FROM "ResourceSupply"
WHERE "ScenarioId" = "destinationScenarioId";

INSERT INTO "ResourceSupply" 
("Id", "ResourceId", "ScenarioId", "WorkQuantityValue", "WorkQuantityUnit", "EntryType", "PeriodStart", "PeriodEnd", "OrganizationId", "EventSource", "EventName")
SELECT uuid_generate_v4(), "ResourceId", "destinationScenarioId", "WorkQuantityValue", "WorkQuantityUnit", "EntryType", "PeriodStart", "PeriodEnd", "OrganizationId", "EventSource", "EventName"
FROM "ResourceSupply"
WHERE "ScenarioId" = "sourceScenarioId";
';