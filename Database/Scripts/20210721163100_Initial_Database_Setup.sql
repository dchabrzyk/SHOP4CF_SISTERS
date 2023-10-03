-- liquibase formatted sql

-- changeset Lukas:1626877828524-1
CREATE TABLE "public"."Resources" ("Id" UUID DEFAULT uuid_generate_v4() NOT NULL, "Name" VARCHAR(255), "ParentId" UUID, "Type" INTEGER DEFAULT 0 NOT NULL, "OrganizationId" CHAR(20) NOT NULL, "ScenarioId" UUID NOT NULL, "ExternalId" VARCHAR(50), CONSTRAINT "Resource_pkey" PRIMARY KEY ("Id", "ScenarioId"));

-- changeset Lukas:1626877828524-2
CREATE POLICY resources_org_isolation_policy
    ON public."Resources"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

-- changeset Lukas:1626877828524-4
CREATE TABLE "public"."Scenarios" ("Id" UUID DEFAULT uuid_generate_v4() NOT NULL, "Name" VARCHAR(100) NOT NULL, "OrganizationId" CHAR(20) NOT NULL, "Status" INTEGER DEFAULT 0 NOT NULL, "UserId" VARCHAR(50) NOT NULL, "CreatedAt" TIMESTAMP WITHOUT TIME ZONE NOT NULL, CONSTRAINT "Scenarios_pkey" PRIMARY KEY ("Id"));

-- changeset Lukas:1626877828524-5
CREATE POLICY scenarios_org_isolation_policy
    ON public."Scenarios"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

-- changeset Lukas:1626877828524-6
CREATE TABLE "public"."ResourceSupply" ("Id" UUID DEFAULT uuid_generate_v4() NOT NULL, "ResourceId" UUID NOT NULL, "ScenarioId" UUID NOT NULL, "Quantity" numeric NOT NULL, "EntryType" INTEGER DEFAULT 0 NOT NULL, "PeriodStart" TIMESTAMP WITHOUT TIME ZONE NOT NULL, "PeriodEnd" TIMESTAMP WITHOUT TIME ZONE NOT NULL, "OrganizationId" CHAR(20) NOT NULL, "EventSource" INTEGER DEFAULT 0 NOT NULL, "EventName" VARCHAR(100) DEFAULT '' NOT NULL, CONSTRAINT "ResourceSupply_pkey" PRIMARY KEY ("Id"));

-- changeset Lukas:1626877828524-7
CREATE INDEX "fki_Resources_Scenarios" ON "public"."Resources"("ScenarioId");

-- changeset Lukas:1626877828524-8
ALTER TABLE "public"."ResourceSupply" ADD CONSTRAINT "ResourceSupply_Resources" FOREIGN KEY ("ScenarioId", "ResourceId") REFERENCES "public"."Resources" ("ScenarioId", "Id") ON UPDATE CASCADE ON DELETE CASCADE;

-- changeset Lukas:1626877828524-9
CREATE POLICY resource_supply_org_isolation_policy
    ON public."ResourceSupply"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

-- changeset Lukas:1626877828524-10
ALTER TABLE "public"."Resources" ADD CONSTRAINT "Resources_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES "public"."Scenarios" ("Id") ON UPDATE CASCADE ON DELETE CASCADE;

-- changeset Lukas:1626877828524-11
ALTER TABLE "public"."Resources" ADD CONSTRAINT "Resource_ExternalId_unique" UNIQUE ("ScenarioId", "ExternalId");

-- changeset Lukas:1626877828524-12
ALTER TABLE "public"."ResourceSupply" ADD CONSTRAINT "ResourceSupply_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES "public"."Scenarios" ("Id") ON UPDATE CASCADE ON DELETE CASCADE;

-- changeset Lukas:1626877828524-13
CREATE INDEX "fki_ResourceSupply_Scenarios" ON "public"."ResourceSupply"("ScenarioId");

-- changeset Lukas:1626877828524-14
CREATE INDEX "fki_ResourceSupply_Resources" ON "public"."ResourceSupply"("ScenarioId", "ResourceId");

-- changeset Lukas:1626877828524-24
CREATE OR REPLACE PROCEDURE public."CreateScenario"("scenarioId" uuid, "scenarioName" character varying, "organizationId" character varying, "userId" character varying, "createdAt" timestamp without time zone, status integer)
 LANGUAGE sql
AS '
INSERT INTO "Scenarios" ("Id", "Name", "Status", "OrganizationId", "UserId", "CreatedAt")
VALUES ("scenarioId", "scenarioName", "status", "organizationId", "userId", "createdAt");

INSERT INTO "Resources"
("Id", "ScenarioId", "OrganizationId", "Name", "ParentId", "Type")
SELECT "Id", "scenarioId", "OrganizationId", "Name", "ParentId", "Type"
FROM "Resources" WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0);

INSERT INTO "ResourceSupply" 
("Id", "ResourceId", "ScenarioId", "Quantity", "EntryType", "PeriodStart", "PeriodEnd", "OrganizationId", "EventSource", "EventName")
SELECT uuid_generate_v4(), "ResourceId", "scenarioId", "Quantity", "EntryType", "PeriodStart", "PeriodEnd", "OrganizationId", "EventSource", "EventName"
FROM "ResourceSupply"
WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0)
';

-- changeset Lukas:1626877828524-25
CREATE OR REPLACE PROCEDURE public."MergeScenarios"("sourceScenarioId" uuid, "destinationScenarioId" uuid)
 LANGUAGE sql
AS '
DELETE FROM "ResourceSupply"
WHERE "ScenarioId" = "destinationScenarioId";

INSERT INTO "ResourceSupply" 
("Id", "ResourceId", "ScenarioId", "Quantity", "EntryType", "PeriodStart", "PeriodEnd", "OrganizationId", "EventSource", "EventName")
SELECT uuid_generate_v4(), "ResourceId", "destinationScenarioId", "Quantity", "EntryType", "PeriodStart", "PeriodEnd", "OrganizationId", "EventSource", "EventName"
FROM "ResourceSupply"
WHERE "ScenarioId" = "sourceScenarioId";
';

