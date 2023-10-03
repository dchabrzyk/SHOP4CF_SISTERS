-- liquibase formatted sql

-- changeset Lukas:20230127144100-1
CREATE TABLE IF NOT EXISTS public."ShiftInstances"
(
    "Id"                 uuid                                               NOT NULL DEFAULT uuid_generate_v4(),
    "TenantId"           character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId"         uuid                                               NOT NULL,
    "TimeCapacityRuleId" uuid                                               NOT NULL,
    "PeriodStart"        timestamp without time zone                        NOT NULL,
    "PeriodEnd"          timestamp without time zone                        NOT NULL,
    CONSTRAINT "ShiftInstances_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "ShiftInstances_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES "Scenarios" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "ShiftInstances_TimeCapacityRules" FOREIGN KEY ("TimeCapacityRuleId", "ScenarioId") REFERENCES "TimeCapacityRules" ON UPDATE NO ACTION ON DELETE NO ACTION,
    CONSTRAINT "ShiftInstances_uc" UNIQUE ("PeriodStart", "TimeCapacityRuleId", "ScenarioId")
) TABLESPACE pg_default;

ALTER TABLE public."ShiftInstances"
    OWNER to postgres;

ALTER TABLE public."ShiftInstances"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."ShiftInstances" TO cdems_user;

GRANT ALL ON TABLE public."ShiftInstances" TO postgres;

CREATE POLICY default_shift_instances_org_isolation_policy
    ON public."ShiftInstances"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));

-- changeset Lukas:20230127144100-2
CREATE TABLE IF NOT EXISTS public."DispatchTaskAssignments"
(
    "Id"                 uuid                                               NOT NULL DEFAULT uuid_generate_v4(),
    "TenantId"           character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ScenarioId"         uuid                                               NOT NULL,
    "ShiftInstanceId"    uuid                                               NOT NULL,
    "TaskId"             uuid                                               NOT NULL,
    "StepId"             uuid                                               NOT NULL,
    "StepResourceSpecId" uuid                                               NOT NULL,
    "ResourceId"         uuid                                               NOT NULL,
    "Quantity"           numeric                                            NOT NULL,
    "QuantityUnit"       integer                                            NOT NULL,
    CONSTRAINT "DispatchTaskAssignments_pkey" PRIMARY KEY ("Id"),
    CONSTRAINT "DispatchTaskAssignments_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES "Scenarios" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "DispatchTaskAssignments_ShiftInstances" FOREIGN KEY ("ShiftInstanceId") REFERENCES "ShiftInstances" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "DispatchTaskAssignments_Tasks" FOREIGN KEY ("TaskId", "ScenarioId") REFERENCES "Tasks" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "DispatchTaskAssignments_Steps" FOREIGN KEY ("StepId", "ScenarioId") REFERENCES "Steps" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "DispatchTaskAssignments_StepResourceSpecs" FOREIGN KEY ("StepResourceSpecId", "ScenarioId") REFERENCES "StepResourceSpecs" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "DispatchTaskAssignments_Resources" FOREIGN KEY ("ResourceId", "ScenarioId") REFERENCES "Resources" ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "DispatchTaskAssignments_uc" UNIQUE ("StepResourceSpecId", "ResourceId", "ScenarioId")
) TABLESPACE pg_default;

ALTER TABLE public."DispatchTaskAssignments"
    OWNER to postgres;

ALTER TABLE public."DispatchTaskAssignments"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."DispatchTaskAssignments" TO cdems_user;

GRANT ALL ON TABLE public."DispatchTaskAssignments" TO postgres;

CREATE POLICY default_dispatch_task_assignment_org_isolation_policy
    ON public."DispatchTaskAssignments"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));