-- liquibase formatted sql

-- changeset Lukas:20210931143500-1
ALTER TABLE public."ResourceCapacities"
    ADD COLUMN "TaskId" uuid;

--rollback ALTER TABLE public."ResourceCapacities" DROP COLUMN "TaskId";

-- changeset Lukas:20210931143500-2
ALTER TABLE public."ResourceCapacities"
    ADD COLUMN "StepId" uuid;

--rollback ALTER TABLE public."ResourceCapacities" DROP COLUMN "StepId";

-- changeset Lukas:20210931143500-3
ALTER TABLE public."ResourceCapacities"
    ADD COLUMN "StepRequiredResourceId" uuid;

--rollback ALTER TABLE public."ResourceCapacities" DROP COLUMN "StepRequiredResourceId";

-- changeset Lukas:20210931143500-4
ALTER TABLE public."ResourceCapacities"
    ADD CONSTRAINT "ResourceCapacities_Tasks" FOREIGN KEY ("TaskId", "ScenarioId") REFERENCES public."Tasks" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

--rollback ALTER TABLE public."ResourceCapacities" DROP CONSTRAINT "ResourceCapacities_Tasks";

-- changeset Lukas:20210931143500-5
ALTER TABLE public."ResourceCapacities"
    ADD CONSTRAINT "ResourceCapacities_Steps" FOREIGN KEY ("StepId") REFERENCES public."Steps" ("Id") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

--rollback ALTER TABLE public."ResourceCapacities" DROP CONSTRAINT "ResourceCapacities_Steps";

-- changeset Lukas:20210931143500-6
ALTER TABLE public."ResourceCapacities"
    ADD CONSTRAINT "ResourceCapacities_StepRequiredResources" FOREIGN KEY ("StepRequiredResourceId") REFERENCES public."StepRequiredResources" ("Id") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE;

--rollback ALTER TABLE public."ResourceCapacities" DROP CONSTRAINT "ResourceCapacities_StepRequiredResources";