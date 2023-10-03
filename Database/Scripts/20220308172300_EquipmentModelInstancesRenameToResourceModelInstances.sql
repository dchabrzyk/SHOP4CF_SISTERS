-- liquibase formatted sql

-- changeset Skorup:20220308172300-1
ALTER TABLE public."EquipmentModelInstances"
    RENAME TO "ResourceModelInstances";

ALTER TABLE public."ResourceModelInstances" DROP CONSTRAINT IF EXISTS "EquipmentModelInstances_pkey";
ALTER TABLE public."ResourceModelInstances" DROP CONSTRAINT IF EXISTS "EquipmentModelInstances_ModelInstances";
ALTER TABLE public."ResourceModelInstances" DROP CONSTRAINT IF EXISTS "EquipmentModelInstances_Resources";

ALTER TABLE public."ResourceModelInstances"
    RENAME COLUMN "EquipmentId" TO "ResourceId";

ALTER TABLE public."ResourceModelInstances"
    ADD CONSTRAINT "ResourceModelInstances_pkey" PRIMARY KEY ("ResourceId", "ModelInstanceId", "ScenarioId");

alter table public."ResourceModelInstances"
    add constraint "ResourceModelInstances_ModelInstances"
        foreign key ("ModelInstanceId", "ScenarioId") references "ModelInstances"
            on update cascade on delete cascade;

alter table public."ResourceModelInstances"
    add constraint "ResourceModelInstances_Resources"
        foreign key ("ResourceId", "ScenarioId") references "Resources"
            on update cascade on delete cascade;

-- changeset Skorup:20220308172300-2
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

    emiRow "ResourceModelInstances"%ROWTYPE;
    miRow "ModelInstances"%ROWTYPE;
    rRow "Resources"%ROWTYPE;
    tRow "Tasks"%ROWTYPE;
    tsRow "Steps"%ROWTYPE;
    stsRow "StepExecutionStatistics"%ROWTYPE;
    sssRow "StepSchedulingStatistics"%ROWTYPE;
    srsRow "StepResourceSpecs"%ROWTYPE;
    srtsRow "StepResourceExecutionStatistics"%ROWTYPE;
    ttbRow "TaskTimeBoxes"%ROWTYPE;
    ttsRow "TaskExecutionStatistics"%ROWTYPE;
    tssRow "TaskSchedulingStatistics"%ROWTYPE;
    rcRow "ResourceCapacities"%ROWTYPE;
BEGIN
    SELECT "Id" INTO productionScenarioId FROM "Scenarios" WHERE "OrganizationId" = "organizationId" AND "Status" = 0;

    -- Scenario
    INSERT INTO "Scenarios" ("Id", "Name", "Status", "OrganizationId", "UserId", "CreatedAt")
    VALUES ("scenarioId", "scenarioName", "status", "organizationId", "userId", "createdAt");

    -- ResourceModelInstances
    FOR emiRow IN SELECT * FROM "ResourceModelInstances" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "ResourceModelInstances" ("EquipmentId", "ModelInstanceId", "ScenarioId")
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

    -- Step Execution Statistics
    FOR stsRow IN SELECT * FROM "StepExecutionStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "StepExecutionStatistics" ("OrganizationId", "ScenarioId", "TaskId", "StepId", "ExecutionStatus", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime") 
            VALUES (stsRow."OrganizationId", "scenarioId", stsRow."TaskId", stsRow."StepId", stsRow."ExecutionStatus", stsRow."ExecutionStart", stsRow."ExecutionEnd", stsRow."ExecutionDuration", stsRow."ExecutionLeadTime", stsRow."SchedulingWaitingTime")
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
    FOR srtsRow IN SELECT * FROM "StepResourceExecutionStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "StepResourceExecutionStatistics" ("OrganizationId", "ScenarioId", "TaskId", "StepId", "ResourceId", "ExecutionStatus", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime", "ExecutionQuantityGood", "ExecutionQuantityScrap", "ExecutionPayload")
            VALUES (srtsRow."OrganizationId", "scenarioId", srtsRow."TaskId", srtsRow."StepId", srtsRow."ResourceId", srtsRow."ExecutionStatus", srtsRow."ExecutionStart", srtsRow."ExecutionEnd", srtsRow."ExecutionDuration", srtsRow."ExecutionLeadTime", srtsRow."ExecutionWaitingTime", srtsRow."ExecutionQuantityGood", srtsRow."ExecutionQuantityScrap", srtsRow."ExecutionPayload")
            ;
        END LOOP;
    
    -- Task time boxes
    FOR ttbRow IN SELECT * FROM "TaskTimeBoxes" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "TaskTimeBoxes" ("Id", "ScenarioId", "ExternalId", "OrganizationId", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name")
            VALUES (ttbRow."Id", "scenarioId", ttbRow."ExternalId", ttbRow."OrganizationId", ttbRow."DateTimeFrom", ttbRow."DateTimeTo", ttbRow."IsDateTimeFromStrict", ttbRow."IsDateTimeToStrict", ttbRow."Name")
            ;
        END LOOP;

    -- Task Execution Statistics
    FOR ttsRow IN SELECT * FROM "TaskExecutionStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "TaskExecutionStatistics" ("OrganizationId", "ScenarioId", "TaskId", "ExecutionStatus", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime") 
            VALUES (ttsRow."OrganizationId", "scenarioId", ttsRow."TaskId", ttsRow."ExecutionStatus", ttsRow."ExecutionStart", ttsRow."ExecutionEnd", ttsRow."ExecutionDuration", ttsRow."ExecutionLeadTime", ttsRow."ExecutionWaitingTime")
            ;
        END LOOP;

    -- Task Scheduling Statistics
    FOR tssRow IN SELECT * FROM "TaskSchedulingStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP            
            INSERT INTO "TaskSchedulingStatistics" ("ScenarioId", "OrganizationId", "TaskId", "SchedulingStatus", "SchedulingStart", "SchedulingEnd", "SchedulingDuration", "SchedulingLeadTime", "SchedulingWaitingTime", "SchedulingBufferDelay")
            VALUES ("scenarioId", tssRow."OrganizationId", tssRow."TaskId", tssRow."SchedulingStatus", tssRow."SchedulingStart", tssRow."SchedulingEnd", tssRow."SchedulingDuration", tssRow."SchedulingLeadTime", tssRow."SchedulingWaitingTime", tssRow."SchedulingBufferDelay")
            ;
        END LOOP;

    -- Step Scheduling Statistics
    FOR sssRow IN SELECT * FROM "StepSchedulingStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "StepSchedulingStatistics" ("OrganizationId", "ScenarioId", "TaskId", "StepId", "SchedulingStatus", "SchedulingStart", "SchedulingEnd", "SchedulingDuration", "SchedulingLeadTime", "SchedulingWaitingTime", "SchedulingBufferDelay") 
            VALUES (sssRow."OrganizationId", "scenarioId", sssRow."TaskId", sssRow."StepId", sssRow."SchedulingStatus", sssRow."SchedulingStart", sssRow."SchedulingEnd", sssRow."SchedulingDuration", sssRow."SchedulingLeadTime", sssRow."SchedulingWaitingTime", sssRow."SchedulingBufferDelay")
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