-- liquibase formatted sql

-- changeset Lukas:20210924161800-1
ALTER TABLE "StepRequiredResources"
    RENAME TO "StepResources";

--rollback ALTER TABLE "StepResources" RENAME TO "StepRequiredResources";

-- changeset Lukas:20210924161800-2
ALTER TABLE public."ResourceCapacities"
    RENAME COLUMN "StepRequiredResourceId" TO "StepResourceId";

--rollback ALTER TABLE public."ResourceCapacities" RENAME COLUMN "StepResourceId" TO "StepRequiredResourceId";

-- changeset Lukas:20210924161800-3
ALTER TABLE public."ResourceCapacities"
    RENAME CONSTRAINT "ResourceCapacities_StepRequiredResources" TO "ResourceCapacities_StepResources";

--rollback ALTER TABLE public."ResourceCapacities" RENAME CONSTRAINT "ResourceCapacities_StepResources" TO "ResourceCapacities_StepRequiredResources";

-- changeset Lukas:20210924161800-4
ALTER TABLE public."StepResources"
    ALTER COLUMN "Quantity" DROP NOT NULL;

--rollback ALTER TABLE public."StepResources" ALTER COLUMN "Quantity" SET NOT NULL;

-- changeset Lukas:20210924161800-5
ALTER TABLE public."StepResources"
    RENAME COLUMN "Quantity" TO "FixedQuantityValue";

--rollback ALTER TABLE public."StepResources" RENAME COLUMN "FixedQuantityValue" TO "Quantity";

-- changeset Lukas:20210924161800-6
ALTER TABLE public."StepResources"
    ADD COLUMN "FixedQuantityUnit" INT;

UPDATE "StepResources"
SET "FixedQuantityUnit" = 0;

--rollback ALTER TABLE public."StepResources" DROP COLUMN "FixedQuantityUnit";

-- changeset Lukas:20210924161800-7
ALTER TABLE public."StepResources"
    ADD COLUMN "QuantityPerCycleValue" NUMERIC;

--rollback ALTER TABLE public."StepResources" DROP COLUMN "QuantityPerCycleValue";

-- changeset Lukas:20210924161800-8
ALTER TABLE public."StepResources"
    ADD COLUMN "QuantityPerCycleUnit" INT;

--rollback ALTER TABLE public."StepResources" DROP COLUMN "QuantityPerCycleUnit";

-- changeset Lukas:20210924161800-9
ALTER TABLE public."StepResources"
    ADD COLUMN "UsageType" INT DEFAULT 0;

--rollback ALTER TABLE public."StepResources" DROP COLUMN "UsageType";

-- changeset Lukas:20210924161800-10
ALTER TABLE public."Steps"
    RENAME COLUMN "TimePerPiece" TO "TimePerCycle";

--rollback ALTER TABLE public."Steps" RENAME COLUMN "TimePerCycle" TO "TimePerPiece";

-- changeset Lukas:20210924161800-11
ALTER TABLE public."Steps"
    RENAME COLUMN "TimePerPieceQuantity" TO "TimePerCycleQuantity";

--rollback ALTER TABLE public."Steps" RENAME COLUMN "TimePerCycleQuantity" TO "TimePerPieceQuantity";

-- changeset Lukas:20210924161800-12
ALTER TABLE public."Tasks"
    RENAME COLUMN "PlannedQuantity" TO "PlannedCycles";

--rollback ALTER TABLE public."Tasks" RENAME COLUMN "PlannedCycles" TO "PlannedQuantity";

-- changeset Lukas:20210924161800-13
ALTER TABLE public."Tasks"
    RENAME COLUMN "PlannedScrapQuantity" TO "PlannedScrapCycles";

--rollback ALTER TABLE public."Tasks" RENAME COLUMN "PlannedScrapCycles" TO "PlannedScrapQuantity";

-- changeset Lukas:20210924161800-14
ALTER TABLE public."Tasks"
    ADD COLUMN "RemainingCycles" numeric;

--rollback ALTER TABLE public."Tasks" DROP COLUMN "RemainingCycles";