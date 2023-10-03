-- liquibase formatted sql

-- changeset Lukas:20230227081000-1
alter table "StepResourceSpecs"
    add "UsageTypeDetails" integer default 0 not null;

-- changeset Lukas:20230227081000-2
alter table "StepResourceSpecs"
    add "ThresholdQuantity" numeric default 0 not null;