-- liquibase formatted sql


-- changeset Koza:20211020121500-1 rollbackSplitStatements:false
ALTER TABLE "TaskTimeBoxes" DROP CONSTRAINT "TaskTimeBoxes_Scenarios";

ALTER TABLE "TaskTimeBoxes"
    ADD CONSTRAINT "TaskTimeBoxes_Scenarios"
        FOREIGN KEY ("ScenarioId") REFERENCES "Scenarios"
            ON UPDATE CASCADE 
            ON DELETE CASCADE;

--rollback ALTER TABLE "TaskTimeBoxes" DROP CONSTRAINT "TaskTimeBoxes_Scenarios";
--rollback ALTER TABLE "TaskTimeBoxes"
--rollback     ADD CONSTRAINT "TaskTimeBoxes_Scenarios"
--rollback         FOREIGN KEY ("ScenarioId") REFERENCES "Scenarios"
--rollback             ON UPDATE NO ACTION
--rollback             ON DELETE NO ACTION;

-- changeset Koza:20211020121500-2 rollbackSplitStatements:false

CREATE OR REPLACE PROCEDURE public."CreateScenario"(
	"scenarioId" uuid,
	"scenarioName" character varying,
	"organizationId" character varying,
	"userId" character varying,
	"createdAt" timestamp without time zone,
	status integer)
LANGUAGE 'plpgsql'
AS '
DECLARE
	productionScenarioId uuid;
	tempId uuid;
    resourceId uuid;
    taskId uuid;
	stepId uuid;
    stepResourceId uuid;
	
    rRow "Resources"%ROWTYPE;
    ttbRow "TaskTimeBoxes"%ROWTYPE;
    tRow "Tasks"%ROWTYPE;
	tChildRow "Tasks"%ROWTYPE;
	tOldRow "Tasks"%ROWTYPE;
	tsRow "Steps"%ROWTYPE;
	tsjRow "TaskSchedulingJournals"%ROWTYPE;
	tsrRow "StepResources"%ROWTYPE;
	rcRow "ResourceCapacities"%ROWTYPE;
BEGIN
	CREATE TEMP TABLE "IdMappings" ("OldId" uuid NOT NULL, "NewId" uuid NOT NULL);
	
	SELECT "Id" INTO productionScenarioId FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0;

	-- Scenario
	INSERT INTO "Scenarios" ("Id", "Name", "Status", "OrganizationId", "UserId", "CreatedAt")
	VALUES ("scenarioId", "scenarioName", "status", "organizationId", "userId", "createdAt");

	-- Task time boxes
	FOR ttbRow IN SELECT * FROM "TaskTimeBoxes" WHERE "ScenarioId" = productionScenarioId
	LOOP
		-- create copy
		WITH inserted_row AS (
			INSERT INTO "TaskTimeBoxes" ("Id", "ScenarioId", "ExternalId", "OrganizationId", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name")
			VALUES (uuid_generate_v4(), "scenarioId", ttbRow."ExternalId", ttbRow."OrganizationId", ttbRow."DateTimeFrom", ttbRow."DateTimeTo", ttbRow."IsDateTimeFromStrict", ttbRow."IsDateTimeToStrict", ttbRow."Name")
			RETURNING "Id"
		)
		INSERT INTO "IdMappings" ("OldId", "NewId")
		SELECT ttbRow."Id", "Id" FROM inserted_row;
	END LOOP;
	
	
	-- Tasks
	FOR tRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId AND "ParentTaskId" IS NULL
	LOOP
		tempId := null;
		SELECT "NewId" INTO tempId FROM "IdMappings" WHERE "OldId" = tRow."TaskTimeBoxId";

		-- create copy 
		WITH inserted_row AS (
			INSERT INTO "Tasks" ("Id", "ScenarioId", "ExternalId", "OrganizationId", "PlannedCycles", "PlannedScrapCycles", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name", "Priority", "Type", "TaskTimeBoxId", "ParentTaskId", "RootTaskId", "RemainingCycles")
			VALUES (uuid_generate_v4(), "scenarioId", tRow."ExternalId", tRow."OrganizationId", tRow."PlannedCycles", tRow."PlannedScrapCycles", tRow."DateTimeFrom", tRow."DateTimeTo", tRow."IsDateTimeFromStrict", tRow."IsDateTimeToStrict", tRow."Name", tRow."Priority", tRow."Type", tempId, null, null, tRow."RemainingCycles")
			RETURNING "Id"
		)
		INSERT INTO "IdMappings" ("OldId", "NewId")
		SELECT tRow."Id", "Id" FROM inserted_row;
		
		-- All task children
		FOR tChildRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId AND "RootTaskId" = tRow."Id" AND "ParentTaskId" IS NOT NULL
		LOOP
			tempId := null;
			SELECT "NewId" INTO tempId FROM "IdMappings" WHERE "OldId" = tChildRow."TaskTimeBoxId";

			-- create copy
			WITH inserted_row AS (
				INSERT INTO "Tasks" ("Id", "ScenarioId", "ExternalId", "OrganizationId", "PlannedCycles", "PlannedScrapCycles", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name", "Priority", "Type", "TaskTimeBoxId", "ParentTaskId", "RootTaskId", "RemainingCycles")
				VALUES (uuid_generate_v4(), "scenarioId", tChildRow."ExternalId", tChildRow."OrganizationId", tChildRow."PlannedCycles", tChildRow."PlannedScrapCycles", tChildRow."DateTimeFrom", tChildRow."DateTimeTo", tChildRow."IsDateTimeFromStrict", tChildRow."IsDateTimeToStrict", tChildRow."Name", tChildRow."Priority", tChildRow."Type", tempId, null, null, tChildRow."RemainingCycles")
				RETURNING "Id"
			)
			INSERT INTO "IdMappings" ("OldId", "NewId")
			SELECT tChildRow."Id", "Id" FROM inserted_row;
		END LOOP;
	END LOOP;
	-- update Task child/parent structure
	FOR tRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId AND "ParentTaskId" IS NOT NULL
	LOOP
		tempId := null;
		SELECT "NewId" FROM "IdMappings" WHERE "OldId" = tRow."ParentTaskId" INTO tempId;
		UPDATE "Tasks" SET "ParentTaskId" = tempId WHERE "Id" = (SELECT "NewId" FROM "IdMappings" WHERE "OldId" = tRow."Id");
	END LOOP;
	
	-- Task Steps
	FOR tsRow IN SELECT * FROM "Steps" WHERE "ScenarioId" = productionScenarioId
	LOOP
		tempId := null;
		SELECT "NewId" INTO tempId FROM "IdMappings" WHERE "OldId" = tsRow."TaskId";
		
		-- create copy
		WITH inserted_row AS (
			INSERT INTO "Steps" ("Id", "ScenarioId", "OrganizationId", "TaskId", "Name", "Position", "ProcessingTime", "TimePerCycle", "TimePerCycleQuantity")
			VALUES (uuid_generate_v4(), "scenarioId", tsRow."OrganizationId", tempId, tsRow."Name", tsRow."Position", tsRow."ProcessingTime", tsRow."TimePerCycle", tsRow."TimePerCycleQuantity")
			RETURNING "Id"
		)
		INSERT INTO "IdMappings" ("OldId", "NewId")
		SELECT tsRow."Id", "Id" FROM inserted_row;
	END LOOP;
	
	-- Task Scheduling Journal
	FOR tsjRow IN SELECT * FROM "TaskSchedulingJournals" WHERE "ScenarioId" = productionScenarioId
	LOOP
		tempId := null;
		SELECT "NewId" INTO tempId FROM "IdMappings" WHERE "OldId" = tsjRow."TaskId";
		
		-- create copy
		WITH inserted_row AS (
			INSERT INTO "TaskSchedulingJournals" ("Id", "ScenarioId", "OrganizationId", "TaskId", "Status")
			VALUES (uuid_generate_v4(), "scenarioId", tsjRow."OrganizationId", tempId, tsjRow."Status")
			RETURNING "Id"
		)
		INSERT INTO "IdMappings" ("OldId", "NewId")
		SELECT tsjRow."Id", "Id" FROM inserted_row;
	END LOOP;

	-- Resources
	FOR rRow IN SELECT * FROM "Resources" WHERE "ScenarioId" = productionScenarioId
	LOOP
		-- Resource
		WITH inserted_row AS (
			INSERT INTO "Resources" ("Id", "ScenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId", "Color", "IsBase", "DateTimeFrom", "DateTimeTo", "VersionNumber", "VersionDateTime", "AgreementType", "IsActive", "PlannedEffort", "RemainingEffort")
			VALUES (uuid_generate_v4(), "scenarioId", rRow."OrganizationId", rRow."Name", rRow."ParentId", rRow."Type", rRow."ExternalId", rRow."Color", rRow."IsBase", rRow."DateTimeFrom", rRow."DateTimeTo", rRow."VersionNumber", rRow."VersionDateTime", rRow."AgreementType", rRow."IsActive", rRow."PlannedEffort", rRow."RemainingEffort")
			RETURNING "Id"
		)
		INSERT INTO "IdMappings" ("OldId", "NewId")
		SELECT rRow."Id", "Id" FROM inserted_row;

	END LOOP;
	
	-- Task Step resources
	FOR tsrRow IN SELECT * FROM "StepResources" WHERE "ScenarioId" = productionScenarioId
	LOOP
		stepId := null;
		resourceId := null;
		
		SELECT "NewId" INTO stepId FROM "IdMappings" WHERE "OldId" = tsrRow."StepId";
		SELECT "NewId" INTO resourceId FROM "IdMappings" WHERE "OldId" = tsrRow."ResourceId";
		
		-- create copy
		WITH inserted_row AS (
			INSERT INTO "StepResources" ("Id", "ScenarioId", "OrganizationId", "StepId", "ResourceId", "FixedQuantityValue", "UseChildrenAsAlternatives", "AlternativesCategory", "FixedQuantityUnit", "QuantityPerCycleValue", "QuantityPerCycleUnit", "UsageType")
			VALUES (uuid_generate_v4(), "scenarioId", tsrRow."OrganizationId", stepId, resourceId, tsrRow."FixedQuantityValue", tsrRow."UseChildrenAsAlternatives", tsrRow."AlternativesCategory", tsrRow."FixedQuantityUnit", tsrRow."QuantityPerCycleValue", tsrRow."QuantityPerCycleUnit", tsrRow."UsageType")
			RETURNING "Id"
		)
		INSERT INTO "IdMappings" ("OldId", "NewId")
		SELECT tsrRow."Id", "Id" FROM inserted_row;
	END LOOP;
	
	-- Resource capacities
	FOR rcRow IN SELECT * FROM "ResourceCapacities" WHERE "ScenarioId" = productionScenarioId
	LOOP
		resourceId := null;
		taskId := null;
		stepId := null;
		stepResourceId := null;
		
		SELECT "NewId" INTO resourceId FROM "IdMappings" WHERE "OldId" = rcRow."ResourceId";
		SELECT "NewId" INTO taskId FROM "IdMappings" WHERE "OldId" = rcRow."TaskId";
		SELECT "NewId" INTO stepId FROM "IdMappings" WHERE "OldId" = rcRow."StepId";
		SELECT "NewId" INTO stepResourceId FROM "IdMappings" WHERE "OldId" = rcRow."StepResourceId";
		
		-- create copy
		WITH inserted_row AS (
			INSERT INTO "ResourceCapacities" ("Id", "ScenarioId", "OrganizationId", "ResourceId", "TaskId", "StepId", "StepResourceId", "WorkQuantityValue", "ChangeType", "PeriodStart", "PeriodEnd", "EntrySource", "WorkQuantityUnit", "Group")
			VALUES (uuid_generate_v4(), "scenarioId", rcRow."OrganizationId", resourceId, taskId, stepId, stepResourceId, rcRow."WorkQuantityValue", rcRow."ChangeType", rcRow."PeriodStart", rcRow."PeriodEnd", rcRow."EntrySource", rcRow."WorkQuantityUnit", rcRow."Group")
			RETURNING "Id"
		)
		INSERT INTO "IdMappings" ("OldId", "NewId")
		SELECT rcRow."Id", "Id" FROM inserted_row;
	END LOOP;
END;
';

--rollback CREATE OR REPLACE PROCEDURE public."CreateScenario"(
--rollback     "scenarioId" uuid,
--rollback     "scenarioName" character varying,
--rollback     "organizationId" character varying,
--rollback     "userId" character varying,
--rollback     "createdAt" timestamp without time zone,
--rollback     status integer)
--rollback     LANGUAGE 'sql'
--rollback AS '
--rollback     INSERT INTO "Scenarios" ("Id", "Name", "Status", "OrganizationId", "UserId", "CreatedAt")
--rollback     VALUES ("scenarioId", "scenarioName", "status", "organizationId", "userId", "createdAt");
--rollback 
--rollback     INSERT INTO "Resources"
--rollback     ("Id", "ScenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId", "DateTimeFrom", "DateTimeTo", "VersionNumber", "VersionDateTime", "AgreementType", "IsActive", "AgreedFTE", "PlannedEffort", "RemainingEffort")
--rollback     SELECT "Id", "scenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId", "DateTimeFrom", "DateTimeTo", "VersionNumber", "VersionDateTime", "AgreementType", "IsActive", "AgreedFTE", "PlannedEffort", "RemainingEffort"
--rollback     FROM "Resources" WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0);
--rollback 
--rollback     INSERT INTO "ResourceCapacities"
--rollback     ("Id", "ResourceId", "ScenarioId", "WorkQuantityValue", "WorkQuantityUnit", "ChangeType", "PeriodStart", "PeriodEnd", "OrganizationId", "EntrySource", "Group")
--rollback     SELECT uuid_generate_v4(), "ResourceId", "scenarioId", "WorkQuantityValue", "WorkQuantityUnit", "ChangeType", "PeriodStart", "PeriodEnd", "OrganizationId", "EntrySource", "Group"
--rollback     FROM "ResourceCapacities"
--rollback     WHERE "ScenarioId" IN (SELECT "Id" FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0)
--rollback ';