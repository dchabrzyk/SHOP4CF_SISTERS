-- liquibase formatted sql

-- changeset Skorup:20220125100000-1
ALTER TABLE public."StepResourceStatistics" RENAME TO "StepResourceTimeStatistics";

-- changeset Skorup:20220125100000-2
ALTER TABLE public."StepStatistics" RENAME TO "StepTimeStatistics";

-- changeset Skorup:20220125100000-3
ALTER TABLE public."TaskStatistics" RENAME TO "TaskTimeStatistics";

