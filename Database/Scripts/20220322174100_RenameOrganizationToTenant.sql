-- liquibase formatted sql

-- changeset Skorup:20220322174100-1
ALTER TABLE public."ModelInstances"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY model_instances_org_isolation_policy ON public."ModelInstances"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-2
ALTER TABLE public."ResourceCapacities"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY resource_supply_org_isolation_policy ON public."ResourceCapacities"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-3
ALTER TABLE public."ResourceTaskAssignments"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "ResourceTaskAssignments_RLS" ON public."ResourceTaskAssignments"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-4
ALTER TABLE public."Resources"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "resources_org_isolation_policy" ON public."Resources"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-5
ALTER TABLE public."Scenarios"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "scenarios_org_isolation_policy" ON public."Scenarios"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-6
ALTER TABLE public."Settings"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY settings_org_isolation_policy ON public."Settings"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-7
ALTER TABLE public."StepExecutionStatistics"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "StepStatistics_RLS" ON public."StepExecutionStatistics"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-8
ALTER TABLE public."StepResourceExecutionStatistics"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "StepResourceStatistics_RLS" ON public."StepResourceExecutionStatistics"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-9
ALTER TABLE public."StepResourceQuantityStatistics"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "StepResourceQuantityStatistics_RLS" ON public."StepResourceQuantityStatistics"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-10
ALTER TABLE public."StepResourceSpecs"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "task_required_resources_org_isolation_policy" ON public."StepResourceSpecs"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-11
ALTER TABLE public."StepSchedulingStatistics"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "StepSchedulingStatistics_RLS" ON public."StepSchedulingStatistics"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-12
ALTER TABLE public."Steps"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "default_steps_org_isolation_policy" ON public."Steps"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-13
ALTER TABLE public."TaskExecutionStatistics"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "TaskStatistics_RLS" ON public."TaskExecutionStatistics"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-14
ALTER TABLE public."TaskSchedulingStatistics"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "task_scheduling_journals_org_isolation_policy" ON public."TaskSchedulingStatistics"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-15
ALTER TABLE public."TaskTimeBoxes"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "task_timeboxes_org_isolation_policy" ON public."TaskTimeBoxes"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-16
ALTER TABLE public."Tasks"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "tasks_org_isolation_policy" ON public."Tasks"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 
-- changeset Skorup:20220322174100-17
ALTER TABLE public."WorkJournalRecords"
    RENAME COLUMN "OrganizationId" TO "TenantId";
ALTER
POLICY "work_journal_records_org_isolation_policy" ON public."WorkJournalRecords"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL);
-- changeset Skorup:20220322174100-18
DROP PROCEDURE "CreateScenario"(uuid, character varying, character varying, character varying, timestamp without time zone, integer);

CREATE
OR REPLACE PROCEDURE public."CreateScenario"(
    "scenarioId" uuid,
    "scenarioName" character varying,
    "tenantId" character varying,
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
    SELECT "Id" INTO productionScenarioId FROM "Scenarios" WHERE "TenantId" = "tenantId" AND "Status" = 0;

    -- Scenario
    INSERT INTO "Scenarios" ("Id", "Name", "Status", "TenantId", "UserId", "CreatedAt")
    VALUES ("scenarioId", "scenarioName", "status", "tenantId", "userId", "createdAt");

    -- ResourceModelInstances
    FOR emiRow IN SELECT * FROM "ResourceModelInstances" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "ResourceModelInstances" ("ResourceId", "ModelInstanceId", "ScenarioId")
    VALUES (emiRow."ResourceId", emiRow."ModelInstanceId", "scenarioId")
    ;
    END LOOP;

    -- ModelInstances
    FOR miRow IN SELECT * FROM "ModelInstances" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "ModelInstances" ("Id", "ScenarioId", "TenantId", "Schema", "Version", "Value", "ExternalId")
    VALUES (miRow."Id", "scenarioId", miRow."TenantId", miRow."Schema", miRow."Version", miRow."Value", miRow."ExternalId")
    ;
    END LOOP;

    -- Resources
    FOR rRow IN SELECT * FROM "Resources" WHERE "ScenarioId" = productionScenarioId
    LOOP
    -- Resource
    INSERT INTO "Resources" ("Id", "ScenarioId", "TenantId", "Name", "ParentId", "Type", "ExternalId", "Color", "IsBase", "DateTimeFrom", "DateTimeTo", "VersionNumber", "VersionDateTime", "AgreementType", "IsActive", "AgreedFTE", "PlannedEffort", "RemainingEffort")
    VALUES (rRow."Id", "scenarioId", rRow."TenantId", rRow."Name", rRow."ParentId", rRow."Type", rRow."ExternalId", rRow."Color", rRow."IsBase", rRow."DateTimeFrom", rRow."DateTimeTo", rRow."VersionNumber", rRow."VersionDateTime", rRow."AgreementType", rRow."IsActive", rRow."AgreedFTE", rRow."PlannedEffort", rRow."RemainingEffort")
    ;
    END LOOP;

    -- Tasks
    FOR tRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "Tasks" ("Id", "ScenarioId", "ExternalId", "TenantId", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name", "Priority", "Type", "TaskTimeBoxId", "ParentTaskId", "RootTaskId")
    VALUES (tRow."Id", "scenarioId", tRow."ExternalId", tRow."TenantId", tRow."DateTimeFrom", tRow."DateTimeTo", tRow."IsDateTimeFromStrict", tRow."IsDateTimeToStrict", tRow."Name", tRow."Priority", tRow."Type", tRow."TaskTimeBoxId", null, null)
    ;
    END LOOP;
    FOR tRow IN SELECT * FROM "Tasks" WHERE "ScenarioId" = productionScenarioId
    LOOP
    UPDATE "Tasks" SET "ParentTaskId" = tRow."ParentTaskId" WHERE "ScenarioId" = "scenarioId";
    END LOOP;

    -- Steps
    FOR tsRow IN SELECT * FROM "Steps" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "Steps" ("Id", "ScenarioId", "TenantId", "TaskId", "Name", "Position", "ProcessingTime", "QuantityPerTime")
    VALUES (tsRow."Id", "scenarioId", tsRow."TenantId", tsRow."TaskId", tsRow."Name", tsRow."Position", tsRow."ProcessingTime", tsRow."QuantityPerTime")
    ;
    END LOOP;

    -- Step Execution Statistics
    FOR stsRow IN SELECT * FROM "StepExecutionStatistics" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "StepExecutionStatistics" ("TenantId", "ScenarioId", "TaskId", "StepId", "ExecutionStatus", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime")
    VALUES (stsRow."TenantId", "scenarioId", stsRow."TaskId", stsRow."StepId", stsRow."ExecutionStatus", stsRow."ExecutionStart", stsRow."ExecutionEnd", stsRow."ExecutionDuration", stsRow."ExecutionLeadTime", stsRow."SchedulingWaitingTime")
    ;
    END LOOP;

    -- Step Resource Specs
    FOR srsRow IN SELECT * FROM "StepResourceSpecs" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "StepResourceSpecs" ("Id", "ScenarioId", "TenantId", "StepId", "ResourceId", "QuantityValue", "AssignmentType", "AlternativesCategory", "QuantityUnit", "UsageType", "CapabilityRequirements", "ResourceType", "ProcessingTime", "QuantityPerTime")
    VALUES (srsRow."Id", "scenarioId", srsRow."TenantId", srsRow."StepId", srsRow."ResourceId", srsRow."QuantityValue", srsRow."AssignmentType", srsRow."AlternativesCategory", srsRow."QuantityUnit", srsRow."UsageType", srsRow."CapabilityRequirements", srsRow."ResourceType", srsRow."ProcessingTime", srsRow."QuantityPerTime")
    ;
    END LOOP;

    -- Step Resource Time Statistics
    FOR srtsRow IN SELECT * FROM "StepResourceExecutionStatistics" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "StepResourceExecutionStatistics" ("TenantId", "ScenarioId", "TaskId", "StepId", "ResourceId", "ExecutionStatus", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime", "ExecutionQuantityGood", "ExecutionQuantityScrap", "ExecutionPayload")
    VALUES (srtsRow."TenantId", "scenarioId", srtsRow."TaskId", srtsRow."StepId", srtsRow."ResourceId", srtsRow."ExecutionStatus", srtsRow."ExecutionStart", srtsRow."ExecutionEnd", srtsRow."ExecutionDuration", srtsRow."ExecutionLeadTime", srtsRow."ExecutionWaitingTime", srtsRow."ExecutionQuantityGood", srtsRow."ExecutionQuantityScrap", srtsRow."ExecutionPayload")
    ;
    END LOOP;

    -- Task time boxes
    FOR ttbRow IN SELECT * FROM "TaskTimeBoxes" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "TaskTimeBoxes" ("Id", "ScenarioId", "ExternalId", "TenantId", "DateTimeFrom", "DateTimeTo", "IsDateTimeFromStrict", "IsDateTimeToStrict", "Name")
    VALUES (ttbRow."Id", "scenarioId", ttbRow."ExternalId", ttbRow."TenantId", ttbRow."DateTimeFrom", ttbRow."DateTimeTo", ttbRow."IsDateTimeFromStrict", ttbRow."IsDateTimeToStrict", ttbRow."Name")
    ;
    END LOOP;

    -- Task Execution Statistics
    FOR ttsRow IN SELECT * FROM "TaskExecutionStatistics" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "TaskExecutionStatistics" ("TenantId", "ScenarioId", "TaskId", "ExecutionStatus", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime")
    VALUES (ttsRow."TenantId", "scenarioId", ttsRow."TaskId", ttsRow."ExecutionStatus", ttsRow."ExecutionStart", ttsRow."ExecutionEnd", ttsRow."ExecutionDuration", ttsRow."ExecutionLeadTime", ttsRow."ExecutionWaitingTime")
    ;
    END LOOP;

    -- Task Scheduling Statistics
    FOR tssRow IN SELECT * FROM "TaskSchedulingStatistics" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "TaskSchedulingStatistics" ("ScenarioId", "TenantId", "TaskId", "SchedulingStatus", "SchedulingStart", "SchedulingEnd", "SchedulingDuration", "SchedulingLeadTime", "SchedulingWaitingTime", "SchedulingBufferDelay")
    VALUES ("scenarioId", tssRow."TenantId", tssRow."TaskId", tssRow."SchedulingStatus", tssRow."SchedulingStart", tssRow."SchedulingEnd", tssRow."SchedulingDuration", tssRow."SchedulingLeadTime", tssRow."SchedulingWaitingTime", tssRow."SchedulingBufferDelay")
    ;
    END LOOP;

    -- Step Scheduling Statistics
    FOR sssRow IN SELECT * FROM "StepSchedulingStatistics" WHERE "ScenarioId" = productionScenarioId
    LOOP
    INSERT INTO "StepSchedulingStatistics" ("TenantId", "ScenarioId", "TaskId", "StepId", "SchedulingStatus", "SchedulingStart", "SchedulingEnd", "SchedulingDuration", "SchedulingLeadTime", "SchedulingWaitingTime", "SchedulingBufferDelay")
    VALUES (sssRow."TenantId", "scenarioId", sssRow."TaskId", sssRow."StepId", sssRow."SchedulingStatus", sssRow."SchedulingStart", sssRow."SchedulingEnd", sssRow."SchedulingDuration", sssRow."SchedulingLeadTime", sssRow."SchedulingWaitingTime", sssRow."SchedulingBufferDelay")
    ;
    END LOOP;

    -- Resource capacities
    FOR rcRow IN SELECT * FROM "ResourceCapacities" WHERE "ScenarioId" = productionScenarioId
    LOOP
    -- NOTE: new id!
    INSERT INTO "ResourceCapacities" ("Id", "ScenarioId", "TenantId", "ResourceId", "TaskId", "StepId", "StepResourceSpecId", "WorkQuantityValue", "ChangeType", "PeriodStart", "PeriodEnd", "EntrySource", "EntrySourcePayload", "WorkQuantityUnit", "Group", "ContextResourceId", "ExternalContextResourceId")
    VALUES (uuid_generate_v4(), "scenarioId", rcRow."TenantId", rcRow."ResourceId", rcRow."TaskId", rcRow."StepId", rcRow."StepResourceSpecId", rcRow."WorkQuantityValue", rcRow."ChangeType", rcRow."PeriodStart", rcRow."PeriodEnd", rcRow."EntrySource", rcRow."EntrySourcePayload", rcRow."WorkQuantityUnit", rcRow."Group", rcRow."ContextResourceId", rcRow."ExternalContextResourceId")
    ;
    END LOOP;

    END;
';
-- changeset Skorup:20220322174100-19
CREATE
OR REPLACE PROCEDURE public."MergeScenarios"(
    "sourceScenarioId" uuid,
    "destinationScenarioId" uuid)
    LANGUAGE 'plpgsql'
AS
'
BEGIN
    DELETE
    FROM "ResourceCapacities"
    WHERE "ScenarioId" = "destinationScenarioId";

    INSERT INTO "ResourceCapacities"
    ("Id", "ResourceId", "ScenarioId", "WorkQuantityValue", "WorkQuantityUnit", "ChangeType", "PeriodStart", "PeriodEnd", "TenantId", "EntrySource", "Group")
    SELECT uuid_generate_v4(),
           "ResourceId",
           "destinationScenarioId",
           "WorkQuantityValue",
           "WorkQuantityUnit",
           "ChangeType",
           "PeriodStart",
           "PeriodEnd",
           "TenantId",
           "EntrySource",
           "Group"
    FROM "ResourceCapacities"
    WHERE "ScenarioId" = "sourceScenarioId";
END
';


