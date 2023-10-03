-- liquibase formatted sql

-- changeset Sko:20220519160000-1
ALTER TABLE public."Tasks"
    ADD COLUMN "IsTemplate" boolean default false,
    ADD COLUMN "TemplateRootTaskId" uuid,
    ADD COLUMN "TemplateTaskId" uuid,
    ADD COLUMN "ResourceId" uuid,
    ADD COLUMN "RevisionNumber" integer;
    
ALTER TABLE public."Tasks"
    ADD CONSTRAINT "TemplateRootTaskId_Task" FOREIGN KEY ("ScenarioId", "TemplateRootTaskId")
    REFERENCES public."Tasks" ("ScenarioId", "Id")
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
    
ALTER TABLE public."Tasks"
    ADD CONSTRAINT "TemplateTaskId_Task" FOREIGN KEY ("ScenarioId", "TemplateTaskId")
    REFERENCES public."Tasks" ("ScenarioId", "Id")
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;
    
ALTER TABLE public."Tasks"
    ADD CONSTRAINT "ResourceId_Task" FOREIGN KEY ("ScenarioId", "ResourceId")
    REFERENCES public."Resources" ("ScenarioId", "Id")
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    NOT VALID;

