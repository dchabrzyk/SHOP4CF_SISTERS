-- liquibase formatted sql

-- changeset Koza:20220208154800-1
alter table "ResourceCapacities"
    drop constraint "ResourceCapacities_StepResourceSpecs";

alter table "StepResourceSpecs"
    drop constraint "StepRequiredResources_pkey";

alter table "StepResourceSpecs"
    add constraint "StepRequiredResources_pkey"
        primary key ("Id", "ScenarioId");

ALTER TABLE public."ResourceCapacities"
    ADD CONSTRAINT "ResourceCapacities_StepResourceSpecs"
        foreign key ("StepResourceSpecId", "ScenarioId") references "StepResourceSpecs" ("Id", "ScenarioId")
            match simple on UPDATE CASCADE on DELETE CASCADE;

-- changeset Koza:20220208154800-2
CREATE OR REPLACE FUNCTION update_task_RootTaskId() RETURNS TRIGGER AS
'
DECLARE
    newRootId uuid;
    temprow public."Tasks"%ROWTYPE;
BEGIN
    IF TG_OP = ''INSERT'' THEN
        IF NEW."RootTaskId" IS NULL THEN
            UPDATE public."Tasks" SET "RootTaskId" = NEW."Id" WHERE "Id" = NEW."Id" AND "ScenarioId" = NEW."ScenarioId";
        END IF;
        IF NEW."ParentTaskId" IS NOT NULL THEN
            newRootId = (SELECT "RootTaskId" FROM public."Tasks" WHERE "Id" = NEW."ParentTaskId" AND "ScenarioId" = NEW."ScenarioId");
            IF (newRootId IS NULL) THEN
                UPDATE public."Tasks" SET "RootTaskId" = NEW."ParentTaskId" WHERE "Id" = NEW."Id" AND "ScenarioId" = NEW."ScenarioId";
            ELSE
                UPDATE public."Tasks" SET "RootTaskId" = newRootId WHERE "Id" = NEW."Id" AND "ScenarioId" = NEW."ScenarioId";
            END IF;
        END IF;
    END IF;
    IF TG_OP = ''UPDATE'' THEN
        IF OLD."ParentTaskId" IS DISTINCT FROM NEW."ParentTaskId" THEN
            newRootId = (SELECT "RootTaskId" FROM public."Tasks" WHERE "Id" = NEW."ParentTaskId" AND "ScenarioId" = NEW."ScenarioId");

            IF (newRootId IS NULL) THEN
                UPDATE public."Tasks" SET "RootTaskId" = NEW."ParentTaskId" WHERE "Id" = NEW."Id" AND "ScenarioId" = NEW."ScenarioId";
            ELSE
                UPDATE public."Tasks" SET "RootTaskId" = newRootId WHERE "Id" = NEW."Id" AND "ScenarioId" = NEW."ScenarioId";
            END IF;

            -- update children
            FOR temprow IN
                SELECT * FROM public."Tasks" WHERE "RootTaskId" = OLD."RootTaskId" AND "Id" != NEW."Id" AND "ParentTaskId" IS NOT NULL AND OLD."ScenarioId" = NEW."ScenarioId"
                LOOP
                    IF (newRootId IS NULL) THEN
                        UPDATE public."Tasks" SET "RootTaskId" = NEW."ParentTaskId" WHERE "Id" = temprow."Id" AND "ScenarioId" = NEW."ScenarioId";
                    ELSE
                        UPDATE public."Tasks" SET "RootTaskId" = newRootId WHERE "Id" = temprow."Id" AND "ScenarioId" = NEW."ScenarioId";
                    END IF;
                END LOOP;
        END IF;
    END IF;
    RETURN NULL;
END;
' language 'plpgsql';

-- changeset Koza:20220208154800-3
CREATE
OR REPLACE PROCEDURE public."CreateScenario"(
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

    emiRow "EquipmentModelInstances"%ROWTYPE;
    miRow "ModelInstances"%ROWTYPE;
    rRow "Resources"%ROWTYPE;
    tRow "Tasks"%ROWTYPE;
    tsRow "Steps"%ROWTYPE;
    stsRow "StepTimeStatistics"%ROWTYPE;
    srsRow "StepResourceSpecs"%ROWTYPE;
    srtsRow "StepResourceTimeStatistics"%ROWTYPE;
    ttbRow "TaskTimeBoxes"%ROWTYPE;
    ttsRow "TaskTimeStatistics"%ROWTYPE;
    tsjRow "TaskSchedulingJournals"%ROWTYPE;
    rcRow "ResourceCapacities"%ROWTYPE;
BEGIN
    SELECT "Id" INTO productionScenarioId FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0;

    -- Scenario
    INSERT INTO "Scenarios" ("Id", "Name", "Status", "OrganizationId", "UserId", "CreatedAt")
    VALUES ("scenarioId", "scenarioName", "status", "organizationId", "userId", "createdAt");

    -- EquipmentModelInstances
    FOR emiRow IN SELECT * FROM "EquipmentModelInstances" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "EquipmentModelInstances" ("EquipmentId", "ModelInstanceId", "ScenarioId")
            VALUES (emiRow."EquipmentId", emiRow."ModelInstanceId", "scenarioId")
            ;
        END LOOP;

    -- ModelInstances
    FOR miRow IN SELECT * FROM "ModelInstances" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "ModelInstances" ("Id", "ScenarioId", "OrganizationId", "Schema", "Version", "Value", "ExternalId")
            VALUES (miRow."Id", "scenarioId", miRow."OrganizationId", miRow."Schema", miRow."Version", miRow."Value", miRow."ExternalId")
            ;
        END LOOP;

    -- Resources
    FOR rRow IN SELECT * FROM "Resources" WHERE "ScenarioId" = productionScenarioId
        LOOP
            -- Resource
            INSERT INTO "Resources" ("Id", "ScenarioId", "OrganizationId", "Name", "ParentId", "Type", "ExternalId", "Color", "IsBase", "DateTimeFrom", "DateTimeTo", "VersionNumber", "VersionDateTime", "AgreementType", "IsActive", "AgreedFTE", "PlannedEffort", "RemainingEffort")
            VALUES (rRow."Id", "scenarioId", rRow."OrganizationId", rRow."Name", rRow."ParentId", rRow."Type", rRow."ExternalId", rRow."Color", rRow."IsBase", rRow."DateTimeFrom", rRow."DateTimeTo", rRow."VersionNumber", rRow."VersionDateTime", rRow."AgreementType", rRow."IsActive", rRow."AgreedFTE", rRow."PlannedEffort", rRow."RemainingEffort")
            ;
        END LOOP;

    -- Tasks
    FOR tRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "Tasks" ("Id", "ScenarioId", "ExternalId", "OrganizationId", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name", "Priority", "Type", "TaskTimeBoxId", "ParentTaskId", "RootTaskId")
            VALUES (tRow."Id", "scenarioId", tRow."ExternalId", tRow."OrganizationId", tRow."DateTimeFrom", tRow."DateTimeTo", tRow."IsDateTimeFromStrict", tRow."IsDateTimeToStrict", tRow."Name", tRow."Priority", tRow."Type", tRow."TaskTimeBoxId", null, null)
            ;
        END LOOP;
    FOR tRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId
        LOOP
            UPDATE "Tasks" SET "ParentTaskId" = tRow."ParentTaskId" WHERE "ScenarioId" = "scenarioId";
        END LOOP;

    -- Steps
    FOR tsRow IN SELECT * FROM "Steps" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "Steps" ("Id", "ScenarioId", "OrganizationId", "TaskId", "Name", "Position", "ProcessingTime", "QuantityPerTime")
            VALUES (tsRow."Id", "scenarioId", tsRow."OrganizationId", tsRow."TaskId", tsRow."Name", tsRow."Position", tsRow."ProcessingTime", tsRow."QuantityPerTime")
            ;
        END LOOP;

    -- Step Time Statistics
    FOR stsRow IN SELECT * FROM "StepTimeStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "StepTimeStatistics" ("OrganizationId", "ScenarioId", "TaskId", "StepId", "Status", "SchedulingStart", "SchedulingEnd", "SchedulingDuration", "SchedulingLeadTime", "SchedulingWaitingTime", "SchedulingBufferDelay", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime") 
            VALUES (stsRow."OrganizationId", "scenarioId", stsRow."TaskId", stsRow."StepId", stsRow."ResourceId", stsRow."SchedulingStart", stsRow."SchedulingEnd", stsRow."SchedulingDuration", stsRow."SchedulingLeadTime", stsRow."SchedulingWaitingTime", stsRow."SchedulingBufferDelay", stsRow."ExecutionStart", stsRow."ExecutionEnd", stsRow."ExecutionDuration", stsRow."ExecutionLeadTime", stsRow."SchedulingWaitingTime")
            ;
        END LOOP;

    -- Step Resource Specs
    FOR srsRow IN SELECT * FROM "StepResourceSpecs" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "StepResourceSpecs" ("Id", "ScenarioId", "OrganizationId", "StepId", "ResourceId", "QuantityValue", "AssignmentType", "AlternativesCategory", "QuantityUnit", "UsageType", "CapabilityRequirements", "ResourceType", "ProcessingTime", "QuantityPerTime")
            VALUES (srsRow."Id", "scenarioId", srsRow."OrganizationId", srsRow."StepId", srsRow."ResourceId", srsRow."QuantityValue", srsRow."AssignmentType", srsRow."AlternativesCategory", srsRow."QuantityUnit", srsRow."UsageType", srsRow."CapabilityRequirements", srsRow."ResourceType", srsRow."ProcessingTime", srsRow."QuantityPerTime")
            ;
        END LOOP;

    -- Step Resource Time Statistics
    FOR srtsRow IN SELECT * FROM "StepResourceTimeStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "StepResourceTimeStatistics" ("OrganizationId", "ScenarioId", "TaskId", "StepId", "ResourceId", "Status", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime", "ExecutionQuantityGood", "ExecutionQuantityScrap", "ExecutionPayload")
            VALUES (srtsRow."OrganizationId", "scenarioId", srtsRow."TaskId", srtsRow."StepId", srtsRow."ResourceId", srtsRow."Status", srtsRow."ExecutionStart", srtsRow."ExecutionEnd", srtsRow."ExecutionDuration", srtsRow."ExecutionLeadTime", srtsRow."ExecutionWaitingTime", srtsRow."ExecutionQuantityGood", srtsRow."ExecutionQuantityScrap", srtsRow."ExecutionPayload")
            ;
        END LOOP;
    
    -- Task time boxes
    FOR ttbRow IN SELECT * FROM "TaskTimeBoxes" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "TaskTimeBoxes" ("Id", "ScenarioId", "ExternalId", "OrganizationId", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name")
            VALUES (ttbRow."Id", "scenarioId", ttbRow."ExternalId", ttbRow."OrganizationId", ttbRow."DateTimeFrom", ttbRow."DateTimeTo", ttbRow."IsDateTimeFromStrict", ttbRow."IsDateTimeToStrict", ttbRow."Name")
            ;
        END LOOP;

    -- Task Time Statistics
    FOR ttsRow IN SELECT * FROM "TaskTimeStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "TaskTimeStatistics" ("OrganizationId", "ScenarioId", "TaskId", "Status", "SchedulingStart", "SchedulingEnd", "SchedulingDuration", "SchedulingLeadTime", "SchedulingWaitingTime", "SchedulingBufferDelay", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime") 
            VALUES (ttsRow."OrganizationId", "scenarioId", ttsRow."TaskId", ttsRow."Status", ttsRow."SchedulingStart", ttsRow."SchedulingEnd", ttsRow."SchedulingDuration", ttsRow."SchedulingLeadTime", ttsRow."SchedulingWaitingTime", ttsRow."SchedulingBufferDelay", ttsRow."ExecutionStart", ttsRow."ExecutionEnd", ttsRow."ExecutionDuration", ttsRow."ExecutionLeadTime", ttsRow."ExecutionWaitingTime")
            ;
        END LOOP;

    -- Task Scheduling Journal
    FOR tsjRow IN SELECT * FROM "TaskSchedulingJournals" WHERE "ScenarioId" = productionScenarioId
        LOOP
            -- NOTE: new id!
            INSERT INTO "TaskSchedulingJournals" ("Id", "ScenarioId", "OrganizationId", "TaskId", "Status")
            VALUES (uuid_generate_v4(), "scenarioId", tsjRow."OrganizationId", tsjRow."TaskId", tsjRow."Status")
            ;
        END LOOP;

    -- Resource capacities
    FOR rcRow IN SELECT * FROM "ResourceCapacities" WHERE "ScenarioId" = productionScenarioId
        LOOP
            -- NOTE: new id!
            INSERT INTO "ResourceCapacities" ("Id", "ScenarioId", "OrganizationId", "ResourceId", "TaskId", "StepId", "StepResourceSpecId", "WorkQuantityValue", "ChangeType", "PeriodStart", "PeriodEnd", "EntrySource", "EntrySourcePayload", "WorkQuantityUnit", "Group", "ContextResourceId", "ExternalContextResourceId")
            VALUES (uuid_generate_v4(), "scenarioId", rcRow."OrganizationId", rcRow."ResourceId", rcRow."TaskId", rcRow."StepId", rcRow."StepResourceSpecId", rcRow."WorkQuantityValue", rcRow."ChangeType", rcRow."PeriodStart", rcRow."PeriodEnd", rcRow."EntrySource", rcRow."EntrySourcePayload", rcRow."WorkQuantityUnit", rcRow."Group", rcRow."ContextResourceId", rcRow."ExternalContextResourceId")
            ;
        END LOOP;

END;
';