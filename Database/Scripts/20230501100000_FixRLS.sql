-- liquibase formatted sql

-- changeset Sko:20230501100000-1

ALTER TABLE public."ResourceExecutionStatistics"
    ENABLE ROW LEVEL SECURITY;

ALTER TABLE public."ResourceTimeCapacityRules"
    ENABLE ROW LEVEL SECURITY;

ALTER TABLE public."TaskModelInstances"
    ENABLE ROW LEVEL SECURITY;

ALTER TABLE public."TimeCapacityRules"
    ENABLE ROW LEVEL SECURITY;

