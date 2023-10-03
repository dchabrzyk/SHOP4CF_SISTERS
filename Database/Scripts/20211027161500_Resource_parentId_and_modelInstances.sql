-- liquibase formatted sql

-- changeset Koza:20211027161500-1 rollbackSplitStatements:false

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
	miRow "ModelInstances"%ROWTYPE;
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
	-- Resource parent id
	FOR rRow IN SELECT * FROM "Resources" WHERE "ScenarioId" = productionScenarioId
	LOOP
		SELECT "NewId" INTO tempId FROM "IdMappings" WHERE "OldId" = rRow."Id";
		SELECT "NewId" INTO resourceId FROM "IdMappings" WHERE "OldId" = rRow."ParentId";
		UPDATE "Resources" SET "ParentId" = resourceId WHERE "Id" = tempId;
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
			INSERT INTO "StepResources" ("Id", "ScenarioId", "OrganizationId", "StepId", "ResourceId", "FixedQuantityValue", "UseChildrenAsAlternatives", "AlternativesCategory", "FixedQuantityUnit", "QuantityPerCycleValue", "QuantityPerCycleUnit", "UsageType", "RequiredCapabilities")
			VALUES (uuid_generate_v4(), "scenarioId", tsrRow."OrganizationId", stepId, resourceId, tsrRow."FixedQuantityValue", tsrRow."UseChildrenAsAlternatives", tsrRow."AlternativesCategory", tsrRow."FixedQuantityUnit", tsrRow."QuantityPerCycleValue", tsrRow."QuantityPerCycleUnit", tsrRow."UsageType", tsrRow."RequiredCapabilities")
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
	
	-- Model instances
	FOR miRow IN SELECT * FROM "ModelInstances" WHERE "ScenarioId" = productionScenarioId
	LOOP
		WITH inserted_row AS (
			INSERT INTO "ModelInstances" ("Id", "ScenarioId", "OrganizationId", "Schema", "Version", "Value")
			VALUES (uuid_generate_v4(), "scenarioId", rRow."OrganizationId", "Schema", "Version", "Value")
			RETURNING "Id"
		)
		INSERT INTO "IdMappings" ("OldId", "NewId")
		SELECT miRow."Id", "Id" FROM inserted_row;

	END LOOP;
END;
';

--rollback CREATE OR REPLACE PROCEDURE public."CreateScenario"(
--rollback 	"scenarioId" uuid,
--rollback 	"scenarioName" character varying,
--rollback 	"organizationId" character varying,
--rollback 	"userId" character varying,
--rollback 	"createdAt" timestamp without time zone,
--rollback 	status integer)
--rollback LANGUAGE 'plpgsql'
--rollback AS '
--rollback DECLARE
--rollback 	productionScenarioId uuid;
--rollback 	tempId uuid;
--rollback     resourceId uuid;
--rollback     taskId uuid;
--rollback 	stepId uuid;
--rollback     stepResourceId uuid;
--rollback 	
--rollback     rRow "Resources"%ROWTYPE;
--rollback     ttbRow "TaskTimeBoxes"%ROWTYPE;
--rollback     tRow "Tasks"%ROWTYPE;
--rollback 	tChildRow "Tasks"%ROWTYPE;
--rollback 	tOldRow "Tasks"%ROWTYPE;
--rollback 	tsRow "Steps"%ROWTYPE;
--rollback 	tsjRow "TaskSchedulingJournals"%ROWTYPE;
--rollback 	tsrRow "StepResources"%ROWTYPE;
--rollback 	rcRow "ResourceCapacities"%ROWTYPE;
--rollback BEGIN
--rollback 	CREATE TEMP TABLE "IdMappings" ("OldId" uuid NOT NULL, "NewId" uuid NOT NULL);
--rollback 	
--rollback 	SELECT "Id" INTO productionScenarioId FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0;
--rollback 
--rollback 	-- Scenario
--rollback 	INSERT INTO "Scenarios" ("Id", "Name", "Status", "OrganizationId", "UserId", "CreatedAt")
--rollback 	VALUES ("scenarioId", "scenarioName", "status", "organizationId", "userId", "createdAt");
--rollback 
--rollback 	-- Task time boxes
--rollback 	FOR ttbRow IN SELECT * FROM "TaskTimeBoxes" WHERE "ScenarioId" = productionScenarioId
--rollback 	LOOP
--rollback 		-- create copy
--rollback 		WITH inserted_row AS (
--rollback 			INSERT INTO "TaskTimeBoxes" ("Id", "ScenarioId", "ExternalId", "OrganizationId", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name")
--rollback 			VALUES (uuid_generate_v4(), "scenarioId", ttbRow."ExternalId", ttbRow."OrganizationId", ttbRow."DateTimeFrom", ttbRow."DateTimeTo", ttbRow."IsDateTimeFromStrict", ttbRow."IsDateTimeToStrict", ttbRow."Name")
--rollback 			RETURNING "Id"
--rollback 		)
--rollback 		INSERT INTO "IdMappings" ("OldId", "NewId")
--rollback 		SELECT ttbRow."Id", "Id" FROM inserted_row;
--rollback 	END LOOP;
--rollback 	
--rollback 	
--rollback 	-- Tasks
--rollback 	FOR tRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId AND "ParentTaskId" IS NULL
--rollback 	LOOP
--rollback 		tempId := null;
--rollback 		SELECT "NewId" INTO tempId FROM "IdMappings" WHERE "OldId" = tRow."TaskTimeBoxId";
--rollback 
--rollback 		-- create copy 
--rollback 		WITH inserted_row AS (
--rollback 			INSERT INTO "Tasks" ("Id", "ScenarioId", "ExternalId", "OrganizationId", "PlannedCycles", "PlannedScrapCycles", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name", "Priority", "Type", "TaskTimeBoxId", "ParentTaskId", "RootTaskId", "RemainingCycles")
--rollback 			VALUES (uuid_generate_v4(), "scenarioId", tRow."ExternalId", tRow."OrganizationId", tRow."PlannedCycles", tRow."PlannedScrapCycles", tRow."DateTimeFrom", tRow."DateTimeTo", tRow."IsDateTimeFromStrict", tRow."IsDateTimeToStrict", tRow."Name", tRow."Priority", tRow."Type", tempId, null, null, tRow."RemainingCycles")
--rollback 			RETURNING "Id"
--rollback 		)
--rollback 		INSERT INTO "IdMappings" ("OldId", "NewId")
--rollback 		SELECT tRow."Id", "Id" FROM inserted_row;
--rollback 		
--rollback 		-- All task children
--rollback 		FOR tChildRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId AND "RootTaskId" = tRow."Id" AND "ParentTaskId" IS NOT NULL
--rollback 		LOOP
--rollback 			tempId := null;
--rollback 			SELECT "NewId" INTO tempId FROM "IdMappings" WHERE "OldId" = tChildRow."TaskTimeBoxId";
--rollback 
--rollback 			-- create copy
--rollback 			WITH inserted_row AS (
--rollback 				INSERT INTO "Tasks" ("Id", "ScenarioId", "ExternalId", "OrganizationId", "PlannedCycles", "PlannedScrapCycles", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name", "Priority", "Type", "TaskTimeBoxId", "ParentTaskId", "RootTaskId", "RemainingCycles")
--rollback 				VALUES (uuid_generate_v4(), "scenarioId", tChildRow."ExternalId", tChildRow."OrganizationId", tChildRow."PlannedCycles", tChildRow."PlannedScrapCycles", tChildRow."DateTimeFrom", tChildRow."DateTimeTo", tChildRow."IsDateTimeFromStrict", tChildRow."IsDateTimeToStrict", tChildRow."Name", tChildRow."Priority", tChildRow."Type", tempId, null, null, tChildRow."RemainingCycles")
--rollback 				RETURNING "Id"
--rollback 			)
--rollback 			INSERT INTO "IdMappings" ("OldId", "NewId")
--rollback 			SELECT tChildRow."Id", "Id" FROM inserted_row;
--rollback 		END LOOP;
--rollback 	END LOOP;
--rollback 	-- update Task child/parent structure
--rollback 	FOR tRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId AND "ParentTaskId" IS NOT NULL
--rollback 	LOOP
--rollback 		tempId := null;
--rollback 		SELECT "NewId" FROM "IdMappings" WHERE "OldId" = tRow."ParentTaskId" INTO tempId;
--rollback 		UPDATE "Tasks" SET "ParentTaskId" = tempId WHERE "Id" = (SELECT "NewId" FROM "IdMappings" WHERE "OldId" = tRow."Id");
--rollback 	END LOOP;
--rollback 	
--rollback 	-- Task Steps
--rollback 	FOR tsRow IN SELECT * FROM "Steps" WHERE "ScenarioId" = productionScenarioId
--rollback 	LOOP
--rollback 		tempId := null;
--rollback 		SELECT "NewId" INTO tempId FROM "IdMappings" WHERE "OldId" = tsRow."TaskId";
--rollback 		
--rollback 		-- create copy
--rollback 		WITH inserted_row AS (
--rollback 			INSERT INTO "Steps" ("Id", "ScenarioId", "OrganizationId", "TaskId", "Name", "Position", "ProcessingTime", "TimePerCycle", "TimePerCycleQuantity")
--rollback 			VALUES (uuid_generate_v4(), "scenarioId", tsRow."OrganizationId", tempId, tsRow."Name", tsRow."Position", tsRow."ProcessingTime", tsRow."TimePerCycle", tsRow."TimePerCycleQuantity")
--rollback 			RETURNING "Id"
--rollback 		)
--rollback 		INSERT INTO "IdMappings" ("OldId", "NewId")
--rollback 		SELECT tsRow."Id", "Id" FROM inserted_row;
--rollback 	END LOOP;
--rollback 	
--rollback 	-- Task Scheduling Journal
--rollback 	FOR tsjRow IN SELECT * FROM "TaskSchedulingJournals" WHERE "ScenarioId" = productionScenarioId
--rollback 	LOOP
--rollback 		tempId := null;
--rollback 		SELECT "NewId" INTO tempId FROM "IdMappings" WHERE "OldId" = tsjRow."TaskId";
--rollback 		
--rollback 		-- create copy
--rollback 		WITH inserted_row AS (
--rollback 			INSERT INTO "TaskSchedulingJournals" ("Id", "ScenarioId", "OrganizationId", "TaskId", "Status")
--rollback 			VALUES (uuid_generate_v4(), "scenarioId", tsjRow."OrganizationId", tempId, tsjRow."Status")
--rollback 			RETURNING "Id"
--rollback 		)
--rollback 		INSERT INTO "IdMappings" ("OldId", "NewId")
--rollback 		SELECT tsjRow."Id", "Id" FROM inserted_row;
--rollback 	END LOOP;
--rollback 
--rollback 	-- Resources
--rollback 	FOR rRow IN SELECT * FROM "Resources" WHERE "ScenarioId" = productionScenarioId
--rollback 	LOOP
--rollback 		-- Resource
--rollback 		WITH inserted_row AS (
--rollback 			INSERT INTO "Resources" ("Id", "ScenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId", "Color", "IsBase", "DateTimeFrom", "DateTimeTo", "VersionNumber", "VersionDateTime", "AgreementType", "IsActive", "PlannedEffort", "RemainingEffort")
--rollback 			VALUES (uuid_generate_v4(), "scenarioId", rRow."OrganizationId", rRow."Name", rRow."ParentId", rRow."Type", rRow."ExternalId", rRow."Color", rRow."IsBase", rRow."DateTimeFrom", rRow."DateTimeTo", rRow."VersionNumber", rRow."VersionDateTime", rRow."AgreementType", rRow."IsActive", rRow."PlannedEffort", rRow."RemainingEffort")
--rollback 			RETURNING "Id"
--rollback 		)
--rollback 		INSERT INTO "IdMappings" ("OldId", "NewId")
--rollback 		SELECT rRow."Id", "Id" FROM inserted_row;
--rollback 
--rollback 	END LOOP;
--rollback 	
--rollback 	-- Task Step resources
--rollback 	FOR tsrRow IN SELECT * FROM "StepResources" WHERE "ScenarioId" = productionScenarioId
--rollback 	LOOP
--rollback 		stepId := null;
--rollback 		resourceId := null;
--rollback 		
--rollback 		SELECT "NewId" INTO stepId FROM "IdMappings" WHERE "OldId" = tsrRow."StepId";
--rollback 		SELECT "NewId" INTO resourceId FROM "IdMappings" WHERE "OldId" = tsrRow."ResourceId";
--rollback 		
--rollback 		-- create copy
--rollback 		WITH inserted_row AS (
--rollback 			INSERT INTO "StepResources" ("Id", "ScenarioId", "OrganizationId", "StepId", "ResourceId", "FixedQuantityValue", "UseChildrenAsAlternatives", "AlternativesCategory", "FixedQuantityUnit", "QuantityPerCycleValue", "QuantityPerCycleUnit", "UsageType", "RequiredCapabilities")
--rollback 			VALUES (uuid_generate_v4(), "scenarioId", tsrRow."OrganizationId", stepId, resourceId, tsrRow."FixedQuantityValue", tsrRow."UseChildrenAsAlternatives", tsrRow."AlternativesCategory", tsrRow."FixedQuantityUnit", tsrRow."QuantityPerCycleValue", tsrRow."QuantityPerCycleUnit", tsrRow."UsageType", tsrRow."RequiredCapabilities")
--rollback 			RETURNING "Id"
--rollback 		)
--rollback 		INSERT INTO "IdMappings" ("OldId", "NewId")
--rollback 		SELECT tsrRow."Id", "Id" FROM inserted_row;
--rollback 	END LOOP;
--rollback 	
--rollback 	-- Resource capacities
--rollback 	FOR rcRow IN SELECT * FROM "ResourceCapacities" WHERE "ScenarioId" = productionScenarioId
--rollback 	LOOP
--rollback 		resourceId := null;
--rollback 		taskId := null;
--rollback 		stepId := null;
--rollback 		stepResourceId := null;
--rollback 		
--rollback 		SELECT "NewId" INTO resourceId FROM "IdMappings" WHERE "OldId" = rcRow."ResourceId";
--rollback 		SELECT "NewId" INTO taskId FROM "IdMappings" WHERE "OldId" = rcRow."TaskId";
--rollback 		SELECT "NewId" INTO stepId FROM "IdMappings" WHERE "OldId" = rcRow."StepId";
--rollback 		SELECT "NewId" INTO stepResourceId FROM "IdMappings" WHERE "OldId" = rcRow."StepResourceId";
--rollback 		
--rollback 		-- create copy
--rollback 		WITH inserted_row AS (
--rollback 			INSERT INTO "ResourceCapacities" ("Id", "ScenarioId", "OrganizationId", "ResourceId", "TaskId", "StepId", "StepResourceId", "WorkQuantityValue", "ChangeType", "PeriodStart", "PeriodEnd", "EntrySource", "WorkQuantityUnit", "Group")
--rollback 			VALUES (uuid_generate_v4(), "scenarioId", rcRow."OrganizationId", resourceId, taskId, stepId, stepResourceId, rcRow."WorkQuantityValue", rcRow."ChangeType", rcRow."PeriodStart", rcRow."PeriodEnd", rcRow."EntrySource", rcRow."WorkQuantityUnit", rcRow."Group")
--rollback 			RETURNING "Id"
--rollback 		)
--rollback 		INSERT INTO "IdMappings" ("OldId", "NewId")
--rollback 		SELECT rcRow."Id", "Id" FROM inserted_row;
--rollback 	END LOOP;
--rollback END;
--rollback ';
