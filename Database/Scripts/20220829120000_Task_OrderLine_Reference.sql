-- liquibase formatted sql

-- changeset Sko:20220829120000-1
ALTER TABLE public."Tasks"
    ADD COLUMN "OrderLineId" uuid;

ALTER TABLE public."Tasks"
    ADD CONSTRAINT "Task_OrderLine" FOREIGN KEY ("ScenarioId", "OrderLineId")
        REFERENCES public."OrderLines" ("ScenarioId", "Id")
        ON UPDATE NO ACTION
        ON DELETE NO ACTION;
