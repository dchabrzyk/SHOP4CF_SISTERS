-- liquibase formatted sql

-- changeset Lukas:20230629124200-1
alter table "ModelInstances"
    DROP COLUMN "ScenarioId";

-- changeset Lukas:20230629124200-2
create or replace procedure public."CreateScenario"(IN "scenarioId" uuid, IN "scenarioName" character varying, IN "tenantId" character varying, IN "userId" character varying,
                                                    IN "createdAt" timestamp without time zone, IN status integer)
    language 'plpgsql'
as
'
    DECLARE
        productionScenarioId uuid; emiRow "ResourceModelInstances"%ROWTYPE; miRow "ModelInstances"%ROWTYPE; rRow "Resources"%ROWTYPE; tRow "Tasks"%ROWTYPE; tsRow "Steps"%ROWTYPE; stsRow "StepExecutionStatistics"%ROWTYPE; sssRow "StepSchedulingStatistics"%ROWTYPE; srsRow "StepResourceSpecs"%ROWTYPE; ttbRow "TaskTimeBoxes"%ROWTYPE; ttsRow "TaskExecutionStatistics"%ROWTYPE; tssRow "TaskSchedulingStatistics"%ROWTYPE; rcRow "ResourceCapacities"%ROWTYPE;
BEGIN SELECT "Id"
      INTO productionScenarioId
      FROM "Scenarios"
      WHERE "TenantId" = "tenantId"
        AND "Status" = 0;

    -- Scenario
    INSERT INTO "Scenarios" ("Id", "Name", "Status", "TenantId", "UserId", "CreatedAt")
    VALUES ("scenarioId", "scenarioName", "status", "tenantId", "userId", "createdAt");

    -- ResourceModelInstances
    FOR emiRow IN SELECT *
                  FROM "ResourceModelInstances"
                  WHERE "ScenarioId" = productionScenarioId
                      LOOP
    INSERT INTO "ResourceModelInstances" ("ResourceId", "ModelInstanceId", "ScenarioId")
    VALUES (emiRow."ResourceId", emiRow."ModelInstanceId", "scenarioId");
    END LOOP;

    -- Resources
    FOR rRow IN SELECT *
                FROM "Resources"
                WHERE "ScenarioId" = productionScenarioId
                    LOOP
    -- Resource
    INSERT
        INTO "Resources" ("Id", "ScenarioId", "TenantId", "Name", "ParentId", "Type", "ExternalId", "Color", "IsBase", "DateTimeFrom", "DateTimeTo", "VersionNumber",
                          "VersionDateTime", "ConstraintType", "PeriodAggregationUnit", "IsActive", "AgreedFTE", "PlannedEffort", "RemainingEffort", "Plannable", "SubTypes",
                          "Token", "TrackingType", "MeasurementUnit", "Description")
    VALUES (rRow."Id", "scenarioId", rRow."TenantId", rRow."Name", rRow."ParentId", rRow."Type", rRow."ExternalId", rRow."Color", rRow."IsBase", rRow."DateTimeFrom",
            rRow."DateTimeTo", rRow."VersionNumber", rRow."VersionDateTime", rRow."ConstraintType", rRow."PeriodAggregationUnit", rRow."IsActive", rRow."AgreedFTE",
            rRow."PlannedEffort",
            rRow."RemainingEffort", rRow."Plannable", rRow."SubTypes", rRow."Token", rRow."TrackingType", rRow."MeasurementUnit", rRow."Description");
    END LOOP;

    -- Tasks
    FOR tRow IN SELECT *
                FROM "Tasks"
                WHERE "ScenarioId" = productionScenarioId
                    LOOP
    INSERT INTO "Tasks" ("Id", "ScenarioId", "ExternalId", "TenantId", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name", "Priority",
                         "Type",
                         "TaskTimeBoxId", "ParentTaskId", "RootTaskId", "Wbs")
    VALUES (tRow."Id", "scenarioId", tRow."ExternalId", tRow."TenantId", tRow."DateTimeFrom", tRow."DateTimeTo", tRow."IsDateTimeFromStrict", tRow."IsDateTimeToStrict",
            tRow."Name", tRow."Priority", tRow."Type", tRow."TaskTimeBoxId", null, null, tRow."Wbs");
    END LOOP; FOR tRow IN SELECT *
                          FROM "Tasks"
                          WHERE "ScenarioId" = productionScenarioId
                              LOOP
    UPDATE "Tasks"
    SET "ParentTaskId" = tRow."ParentTaskId",
        "Wbs"          = tRow."Wbs"
    WHERE "ScenarioId" = "scenarioId";
    END LOOP;

    -- Steps
    FOR tsRow IN SELECT *
                 FROM "Steps"
                 WHERE "ScenarioId" = productionScenarioId
                     LOOP
    INSERT INTO "Steps" ("Id", "ScenarioId", "TenantId", "TaskId", "Name", "Position", "ProcessingTime", "QuantityPerTime")
    VALUES (tsRow."Id", "scenarioId", tsRow."TenantId", tsRow."TaskId", tsRow."Name", tsRow."Position", tsRow."ProcessingTime", tsRow."QuantityPerTime");
    END LOOP;

    -- Step Execution Statistics
    FOR stsRow IN SELECT *
                  FROM "StepExecutionStatistics"
                  WHERE "ScenarioId" = productionScenarioId
                      LOOP
    INSERT INTO "StepExecutionStatistics" ("TenantId", "ScenarioId", "TaskId", "StepId", "ExecutionStatus", "ExecutionStart", "ExecutionEnd", "ExecutionDuration",
                                           "ExecutionLeadTime", "ExecutionWaitingTime")
    VALUES (stsRow."TenantId", "scenarioId", stsRow."TaskId", stsRow."StepId", stsRow."ExecutionStatus", stsRow."ExecutionStart", stsRow."ExecutionEnd",
            stsRow."ExecutionDuration",
            stsRow."ExecutionLeadTime", stsRow."SchedulingWaitingTime");
    END LOOP;

    -- Step Resource Specs
    FOR srsRow IN SELECT *
                  FROM "StepResourceSpecs"
                  WHERE "ScenarioId" = productionScenarioId
                      LOOP
    INSERT INTO "StepResourceSpecs" ("Id", "ScenarioId", "TenantId", "StepId", "Quantity", "AssignmentType", "QuantityUnit", "UsageType", "CapabilityRequirements",
                                     "ResourceType", "ProcessingTime", "QuantityPerTime", "ResourceIds")
    VALUES (srsRow."Id", "scenarioId", srsRow."TenantId", srsRow."StepId", srsRow."Quantity", srsRow."AssignmentType", srsRow."QuantityUnit",
            srsRow."UsageType", srsRow."CapabilityRequirements", srsRow."ResourceType", srsRow."ProcessingTime", srsRow."QuantityPerTime", srsRow."ResourceIds");
    END LOOP;

    -- Task time boxes
    FOR ttbRow IN SELECT *
                  FROM "TaskTimeBoxes"
                  WHERE "ScenarioId" = productionScenarioId
                      LOOP
    INSERT INTO "TaskTimeBoxes" ("Id", "ScenarioId", "ExternalId", "TenantId", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name")
    VALUES (ttbRow."Id", "scenarioId", ttbRow."ExternalId", ttbRow."TenantId", ttbRow."DateTimeFrom", ttbRow."DateTimeTo", ttbRow."IsDateTimeFromStrict",
            ttbRow."IsDateTimeToStrict", ttbRow."Name");
    END LOOP;

    -- Task Execution Statistics
    FOR ttsRow IN SELECT *
                  FROM "TaskExecutionStatistics"
                  WHERE "ScenarioId" = productionScenarioId
                      LOOP
    INSERT INTO "TaskExecutionStatistics" ("TenantId", "ScenarioId", "TaskId", "ExecutionStatus", "ExecutionStart", "ExecutionEnd", "ExecutionDuration",
                                           "ExecutionLeadTime",
                                           "ExecutionWaitingTime")
    VALUES (ttsRow."TenantId", "scenarioId", ttsRow."TaskId", ttsRow."ExecutionStatus", ttsRow."ExecutionStart", ttsRow."ExecutionEnd", ttsRow."ExecutionDuration",
            ttsRow."ExecutionLeadTime", ttsRow."ExecutionWaitingTime");
    END LOOP;

    -- Task Scheduling Statistics
    FOR tssRow IN SELECT *
                  FROM "TaskSchedulingStatistics"
                  WHERE "ScenarioId" = productionScenarioId
                      LOOP
    INSERT INTO "TaskSchedulingStatistics" ("ScenarioId", "TenantId", "TaskId", "SchedulingStatus", "SchedulingStart", "SchedulingEnd", "SchedulingDuration",
                                            "SchedulingLeadTime",
                                            "SchedulingWaitingTime", "SchedulingDelay", "RequestedEnd")
    VALUES ("scenarioId", tssRow."TenantId", tssRow."TaskId", tssRow."SchedulingStatus", tssRow."SchedulingStart", tssRow."SchedulingEnd", tssRow."SchedulingDuration",
            tssRow."SchedulingLeadTime", tssRow."SchedulingWaitingTime", tssRow."SchedulingDelay", tssRow."RequestedEnd");
    END LOOP;

    -- Step Scheduling Statistics
    FOR sssRow IN SELECT *
                  FROM "StepSchedulingStatistics"
                  WHERE "ScenarioId" = productionScenarioId
                      LOOP
    INSERT INTO "StepSchedulingStatistics" ("TenantId", "ScenarioId", "TaskId", "StepId", "SchedulingStatus", "SchedulingStart", "SchedulingEnd", "SchedulingDuration",
                                            "SchedulingLeadTime", "SchedulingWaitingTime")
    VALUES (sssRow."TenantId", "scenarioId", sssRow."TaskId", sssRow."StepId", sssRow."SchedulingStatus", sssRow."SchedulingStart", sssRow."SchedulingEnd",
            sssRow."SchedulingDuration", sssRow."SchedulingLeadTime", sssRow."SchedulingWaitingTime");
    END LOOP;

    -- Resource capacities
    FOR rcRow IN SELECT *
                 FROM "ResourceCapacities"
                 WHERE "ScenarioId" = productionScenarioId
                     LOOP
    INSERT
    INTO "ResourceCapacities" ("Id", "ScenarioId", "TenantId", "ResourceId", "TaskId", "StepId", "StepResourceSpecId", "Quantity", "ChangeType", "PeriodStart",
                               "PeriodEnd",
                               "EntrySource", "EntrySourcePayload", "QuantityUnit", "CapacityGroup", "ContextResourceId", "ExternalContextResourceId",
                               "EntrySourcePayloadType")
    VALUES (uuid_generate_v4(), "scenarioId", rcRow."TenantId", rcRow."ResourceId", rcRow."TaskId", rcRow."StepId", rcRow."StepResourceSpecId", rcRow."Quantity",
            rcRow."ChangeType", rcRow."PeriodStart", rcRow."PeriodEnd", rcRow."EntrySource", rcRow."EntrySourcePayload", rcRow."QuantityUnit", rcRow."CapacityGroup",
            rcRow."ContextResourceId", rcRow."ExternalContextResourceId", rcRow."EntrySourcePayloadType");
    END LOOP;

    END;
';