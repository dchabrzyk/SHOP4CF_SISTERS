-- liquibase formatted sql

-- changeset Sko:20210901160000-1
ALTER TABLE public."TaskTimeBoxes"
DROP CONSTRAINT "TaskTimeBoxes_pkey";

ALTER TABLE public."TaskTimeBoxes"
    ADD CONSTRAINT "TaskTimeBoxes_pkey" PRIMARY KEY ("Id", "ScenarioId");

ALTER TABLE public."Tasks"
    ADD COLUMN "TaskTimeBoxId" uuid;
ALTER TABLE public."Tasks"
    ADD CONSTRAINT "Task_TimeBoxes" FOREIGN KEY ("ScenarioId", "TaskTimeBoxId")
    REFERENCES public."TaskTimeBoxes" ("ScenarioId", "Id")
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

--rollback ALTER TABLE public."Tasks" DROP CONSTRAINT "Task_TimeBoxes"; 
--rollback ALTER TABLE public."Tasks" DROP COLUMN "TaskTimeBoxId";
--rollback ALTER TABLE public."TaskTimeBoxes" DROP CONSTRAINT "TaskTimeBoxes_pkey";
--rollback ALTER TABLE public."TaskTimeBoxes" ADD CONSTRAINT "TaskTimeBoxes_pkey" PRIMARY KEY ("Id");