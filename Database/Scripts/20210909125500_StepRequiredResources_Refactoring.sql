-- liquibase formatted sql

-- changeset Lukas:20210909125500-1
ALTER TABLE "TaskRequiredResources"
    RENAME TO "StepRequiredResources";

--rollback ALTER TABLE "StepRequiredResources" RENAME TO "TaskRequiredResources";

-- changeset Lukas:20210909125500-2
ALTER TABLE public."StepRequiredResources"
    DROP CONSTRAINT "TaskRequiredResources_Tasks";

--rollback ALTER TABLE "StepRequiredResources" ADD CONSTRAINT "TaskRequiredResources_Tasks" FOREIGN KEY ("TaskId", "ScenarioId") REFERENCES public."Tasks" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

-- changeset Lukas:20210909125500-3
ALTER TABLE public."StepRequiredResources"
    RENAME COLUMN "TaskId" TO "StepId";

--rollback ALTER TABLE public."StepRequiredResources" RENAME COLUMN "StepId" TO "TaskId";

-- changeset Lukas:20210909125500-4
ALTER TABLE public."StepRequiredResources"
    ADD CONSTRAINT "StepRequiredResources_Steps" FOREIGN KEY ("StepId") REFERENCES public."Steps" ("Id") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

--rollback ALTER TABLE public."StepRequiredResources" DROP CONSTRAINT "StepRequiredResources_Steps";

-- changeset Lukas:20210909125500-5
ALTER TABLE public."StepRequiredResources"
    DROP COLUMN "AssignedProcessingPhase";

--rollback ALTER TABLE public."StepRequiredResources" ADD COLUMN "AssignedProcessingPhase" character varying(255) COLLATE pg_catalog."default";

-- changeset Lukas:20210909125500-6
ALTER TABLE public."StepRequiredResources"
DROP COLUMN "IsRelativePerformance";

--rollback ALTER TABLE public."StepRequiredResources" ADD COLUMN "IsRelativePerformance" boolean;

-- changeset Lukas:20210909125500-7
ALTER TABLE public."StepRequiredResources"
    RENAME CONSTRAINT "TaskRequiredResources_pkey" TO "StepRequiredResources_pkey";

--rollback ALTER TABLE public."StepRequiredResources" RENAME CONSTRAINT "StepRequiredResources_pkey" TO "TaskRequiredResources_pkey";

-- changeset Lukas:20210909125500-8
ALTER TABLE public."StepRequiredResources"
    RENAME CONSTRAINT "TaskRequiredResources_Scenarios" TO "StepRequiredResources_Scenarios";

--rollback ALTER TABLE public."StepRequiredResources" RENAME CONSTRAINT "StepRequiredResources_Scenarios" TO "TaskRequiredResources_Scenarios";

-- changeset Lukas:20210909125500-9
ALTER TABLE public."StepRequiredResources"
    RENAME CONSTRAINT "TaskRequiredResources_Resources" TO "StepRequiredResources_Resources";

--rollback ALTER TABLE public."StepRequiredResources" RENAME CONSTRAINT "StepRequiredResources_Resources" TO "TaskRequiredResources_Resources";