-- liquibase formatted sql

-- changeset Lukas:20220301130800-1
ALTER TABLE public."StepTimeStatistics"
    RENAME COLUMN "Status" TO "ExecutionStatus";


-- changeset Lukas:20220301130800-2
ALTER TABLE public."StepResourceTimeStatistics"
    RENAME COLUMN "Status" TO "ExecutionStatus";

-- changeset Lukas:20220301130800-3
ALTER TABLE public."TaskTimeStatistics"
    RENAME COLUMN "Status" TO "ExecutionStatus";

-- changeset Lukas:20220301130800-4
ALTER TABLE public."StepTimeStatistics"
    ADD COLUMN "SchedulingStatus" INT;

-- changeset Lukas:20220301130800-5
ALTER TABLE public."TaskTimeStatistics"
    ADD COLUMN "SchedulingStatus" INT;

-- changeset Lukas:20220301130800-6
ALTER TABLE public."TaskSchedulingJournals"
    RENAME TO "TaskSchedulingStatistics";

-- changeset Lukas:20220301130800-7
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
    tssRow "TaskSchedulingStatistics"%ROWTYPE;
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
    FOR tssRow IN SELECT * FROM "TaskSchedulingStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            -- NOTE: new id!
            INSERT INTO "TaskSchedulingStatistics" ("Id", "ScenarioId", "OrganizationId", "TaskId", "Status")
            VALUES (uuid_generate_v4(), "scenarioId", tssRow."OrganizationId", tssRow."TaskId", tssRow."Status")
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

-- changeset Lukas:20220301130800-8
ALTER TABLE public."StepResourceTimeStatistics"
    RENAME TO "StepResourceExecutionStatistics";

-- changeset Lukas:20220301130800-9
ALTER TABLE public."StepTimeStatistics"
    RENAME TO "StepExecutionStatistics";

-- changeset Lukas:20220301130800-10
ALTER TABLE public."StepExecutionStatistics"
DROP
COLUMN "SchedulingStatus",
    DROP
COLUMN "SchedulingStart",
    DROP
COLUMN "SchedulingEnd",
    DROP
COLUMN "SchedulingDuration",
    DROP
COLUMN "SchedulingLeadTime",
    DROP
COLUMN "SchedulingWaitingTime",
    DROP
COLUMN "SchedulingBufferDelay";

-- changeset Lukas:20220301130800-11
ALTER TABLE public."TaskTimeStatistics"
    RENAME TO "TaskExecutionStatistics";

-- changeset Lukas:20220301130800-12
ALTER TABLE public."TaskExecutionStatistics"
DROP
COLUMN "SchedulingStatus",
DROP
COLUMN "SchedulingStart",
    DROP
COLUMN "SchedulingEnd",
    DROP
COLUMN "SchedulingDuration",
    DROP
COLUMN "SchedulingLeadTime",
    DROP
COLUMN "SchedulingWaitingTime",
    DROP
COLUMN "SchedulingBufferDelay";

-- changeset Lukas:20220301130800-13
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
    stsRow "StepExecutionStatistics"%ROWTYPE;
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

    -- Task Time Statistics
    FOR ttsRow IN SELECT * FROM "TaskExecutionStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            INSERT INTO "TaskExecutionStatistics" ("OrganizationId", "ScenarioId", "TaskId", "ExecutionStatus", "ExecutionStart", "ExecutionEnd", "ExecutionDuration", "ExecutionLeadTime", "ExecutionWaitingTime") 
            VALUES (ttsRow."OrganizationId", "scenarioId", ttsRow."TaskId", ttsRow."ExecutionStatus", ttsRow."ExecutionStart", ttsRow."ExecutionEnd", ttsRow."ExecutionDuration", ttsRow."ExecutionLeadTime", ttsRow."ExecutionWaitingTime")
            ;
        END LOOP;

    -- Task Scheduling Journal
    FOR tssRow IN SELECT * FROM "TaskSchedulingStatistics" WHERE "ScenarioId" = productionScenarioId
        LOOP
            -- NOTE: new id!
            INSERT INTO "TaskSchedulingStatistics" ("Id", "ScenarioId", "OrganizationId", "TaskId", "SchedulingStatus")
            VALUES (uuid_generate_v4(), "scenarioId", tssRow."OrganizationId", tssRow."TaskId", tssRow."SchedulingStatus")
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

-- changeset Lukas:20220301130800-14
ALTER TABLE public."TaskSchedulingStatistics"
    RENAME COLUMN "Status" TO "SchedulingStatus";


-- changeset Lukas:20220301130800-15
-- Table: public.StepStatistics

CREATE TABLE public."StepSchedulingStatistics"
(
    "OrganizationId"        character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId"            uuid                                               NOT NULL,
    "TaskId"                uuid                                               NOT NULL,
    "StepId"                uuid                                               NOT NULL,
    "SchedulingStatus"      integer,
    "SchedulingStart"       timestamp without time zone,
    "SchedulingEnd"         timestamp without time zone,
    "SchedulingDuration"    interval,
    "SchedulingLeadTime"    interval,
    "SchedulingWaitingTime" interval,
    "SchedulingBufferDelay" interval,
    CONSTRAINT "StepSchedulingStatistics_pkey" PRIMARY KEY ("StepId", "ScenarioId"),
    CONSTRAINT "StepSchedulingStatistics_Scenario" FOREIGN KEY ("ScenarioId")
        REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "StepSchedulingStatistics_Step" FOREIGN KEY ("StepId", "ScenarioId")
        REFERENCES public."Steps" ("Id", "ScenarioId")
        DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT "StepSchedulingStatistics_Task" FOREIGN KEY ("ScenarioId", "TaskId")
        REFERENCES public."Tasks" ("ScenarioId", "Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE
) TABLESPACE pg_default;

ALTER TABLE public."StepSchedulingStatistics"
    OWNER to postgres;

ALTER TABLE public."StepSchedulingStatistics"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."StepSchedulingStatistics" TO cdems_user;

GRANT
ALL
ON TABLE public."StepSchedulingStatistics" TO postgres;
-- POLICY: StepStatistics_RLS

CREATE
POLICY "StepSchedulingStatistics_RLS"
    ON public."StepSchedulingStatistics"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("OrganizationId")::text = current_setting('app.current_organization'::text)));

-- changeset Lukas:20220301130800-16
ALTER TABLE public."TaskSchedulingStatistics"
DROP
CONSTRAINT "TaskSchedulingJournals_pkey";

-- changeset Lukas:20220301130800-17
ALTER TABLE public."TaskSchedulingStatistics"
DROP
CONSTRAINT "TaskSchedulingJournals_TaskId_ScenarioId_unique";

-- changeset Lukas:20220301130800-18
ALTER TABLE public."TaskSchedulingStatistics"
DROP
COLUMN "Id";

-- changeset Lukas:20220301130800-19
ALTER TABLE public."TaskSchedulingStatistics"
    ADD PRIMARY KEY ("TaskId", "ScenarioId");

-- changeset Lukas:20220301130800-20
ALTER TABLE public."TaskSchedulingStatistics"
    ADD COLUMN "SchedulingStart" timestamp without time zone,
ADD COLUMN "SchedulingEnd"         timestamp without time zone,
ADD COLUMN "SchedulingDuration"    interval,
ADD COLUMN "SchedulingLeadTime"    interval,
ADD COLUMN "SchedulingWaitingTime" interval,
ADD COLUMN "SchedulingBufferDelay" interval;

-- changeset Lukas:20220301130800-21
ALTER TABLE public."StepSchedulingStatistics"
DROP
CONSTRAINT "StepSchedulingStatistics_Task";

-- changeset Lukas:20220301130800-22
ALTER TABLE public."StepSchedulingStatistics"
    ADD CONSTRAINT "StepSchedulingStatistics_TaskSchedulingStatistics" FOREIGN KEY ("ScenarioId", "TaskId")
        REFERENCES public."TaskSchedulingStatistics" ("ScenarioId", "TaskId") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE;

-- changeset Lukas:20220301130800-23
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