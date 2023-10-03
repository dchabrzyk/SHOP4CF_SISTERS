-- liquibase formatted sql

-- changeset Koza:20211027100000-1 rollbackSplitStatements:false

CREATE TABLE IF NOT EXISTS public."EquipmentModelInstances"
(
    "EquipmentId" uuid NOT NULL,
    "ModelInstanceId" uuid NOT NULL,
    "ScenarioId" uuid NOT NULL,
    CONSTRAINT "EquipmentModelInstances_pkey" PRIMARY KEY ("EquipmentId", "ModelInstanceId", "ScenarioId")
) TABLESPACE pg_default;

CREATE UNIQUE INDEX "EquipmentModelInstances_uc" ON public."EquipmentModelInstances" ("EquipmentId" ASC NULLS LAST, "ModelInstanceId" ASC NULLS LAST, "ScenarioId" ASC NULLS LAST);

ALTER TABLE "public"."EquipmentModelInstances" ADD CONSTRAINT "EquipmentModelInstances_Resources" FOREIGN KEY ("EquipmentId", "ScenarioId") REFERENCES "public"."Resources" ("Id", "ScenarioId") ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE "public"."EquipmentModelInstances" ADD CONSTRAINT "EquipmentModelInstances_ModelInstances" FOREIGN KEY ("ModelInstanceId", "ScenarioId") REFERENCES "public"."ModelInstances" ("Id", "ScenarioId") ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE public."EquipmentModelInstances" OWNER to postgres;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."EquipmentModelInstances" TO cdems_user;

GRANT ALL ON TABLE public."EquipmentModelInstances" TO postgres;

--rollback DROP TABLE public."EquipmentModelInstances";