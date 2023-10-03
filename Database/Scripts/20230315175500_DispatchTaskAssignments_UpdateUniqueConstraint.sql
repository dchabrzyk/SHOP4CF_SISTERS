-- liquibase formatted sql

-- changeset Lukas:20230315175500-1
alter table "DispatchTaskAssignments"
    drop constraint "DispatchTaskAssignments_uc";

-- changeset Lukas:20230315175500-2
alter table "DispatchTaskAssignments"
    add constraint "DispatchTaskAssignments_uc"
        unique ("StepResourceSpecId", "ResourceId", "ShiftInstanceId", "ScenarioId");