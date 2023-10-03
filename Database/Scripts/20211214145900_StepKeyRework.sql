-- liquibase formatted sql

-- changeset Skorup:20211214145900-1 rollbackSplitStatements:false

ALTER TABLE public."ResourceCapacities"
DROP CONSTRAINT "ResourceCapacities_Steps";

ALTER TABLE public."StepResources"
DROP CONSTRAINT "StepRequiredResources_Steps";

ALTER TABLE public."Steps"
DROP CONSTRAINT "Steps_pkey";

ALTER TABLE public."Steps"
ADD PRIMARY KEY ("Id", "ScenarioId");

ALTER TABLE public."StepResources"
    ADD CONSTRAINT "StepRequiredResources_Steps" FOREIGN KEY ("StepId", "ScenarioId") REFERENCES "Steps" ("Id", "ScenarioId");
	
ALTER TABLE public."ResourceCapacities"
    ADD CONSTRAINT "ResourceCapacities_Steps" FOREIGN KEY ("StepId", "ScenarioId") REFERENCES "Steps" ("Id", "ScenarioId");
