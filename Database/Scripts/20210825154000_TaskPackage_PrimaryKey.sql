-- liquibase formatted sql

-- changeset Lukas:20210825154000-1
--rollback ALTER TABLE public."Tasks" DROP CONSTRAINT "Task_Packages";
--rollback ALTER TABLE public."TaskPackages" DROP CONSTRAINT "TaskPackages_pkey";
--rollback ALTER TABLE public."TaskPackages" ADD CONSTRAINT "TaskPackages_pkey" PRIMARY KEY ("Id");
--rollback ALTER TABLE public."Tasks" ADD CONSTRAINT "Task_Packages" FOREIGN KEY ("TaskPackageId") REFERENCES public."TaskPackages" ("Id") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;
ALTER TABLE public."Tasks"
DROP CONSTRAINT "Task_Packages";

ALTER TABLE public."TaskPackages" DROP CONSTRAINT "TaskPackages_pkey";

ALTER TABLE public."TaskPackages"
    ADD CONSTRAINT "TaskPackages_pkey" PRIMARY KEY ("Id", "ScenarioId");

ALTER TABLE public."Tasks"
    ADD CONSTRAINT "Task_Packages" FOREIGN KEY ("ScenarioId", "TaskPackageId")
    REFERENCES public."TaskPackages" ("ScenarioId", "Id") MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION;

-- changeset Lukas:20210825154000-3
ALTER TABLE public."Tasks"
DROP CONSTRAINT "Tasks_Scenarios",
ADD CONSTRAINT "Tasks_Scenarios" FOREIGN KEY ("ScenarioId")
    REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE;
--rollback ALTER TABLE public."Tasks" DROP CONSTRAINT "Tasks_Scenarios", ADD CONSTRAINT "Tasks_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES public."Scenarios" ("Id") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;

-- changeset Lukas:20210825154000-4
ALTER TABLE public."TaskPackages"
DROP CONSTRAINT "TaskPackages_Scenarios",
ADD CONSTRAINT "TaskPackages_Scenarios" FOREIGN KEY ("ScenarioId")
    REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE;
--rollback ALTER TABLE public."TaskPackages" DROP CONSTRAINT "TaskPackages_Scenarios", ADD CONSTRAINT "TaskPackages_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES public."Scenarios" ("Id") MATCH SIMPLE ON UPDATE NO ACTION ON DELETE NO ACTION;