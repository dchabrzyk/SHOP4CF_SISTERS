-- liquibase formatted sql

-- changeset Koza:20210915100500-1
--rollback DROP TRIGGER IF EXISTS trigger_update_task_RootTaskId ON public."Tasks";
--rollback DROP FUNCTION IF EXISTS update_task_RootTaskId;
--rollback ALTER TABLE public."Tasks" DROP CONSTRAINT "Tasks_Tasks_rootTaskId";
--rollback ALTER TABLE public."Tasks" DROP COLUMN "RootTaskId";

alter table public."Tasks" add "RootTaskId" uuid;

alter table public."Tasks"
    add constraint "Tasks_Tasks_rootTaskId"
        foreign key ("ScenarioId", "RootTaskId") references "Tasks" ("ScenarioId", "Id");

CREATE OR REPLACE FUNCTION update_task_RootTaskId() RETURNS TRIGGER AS 
'
DECLARE
    newRootId uuid;
    temprow public."Tasks"%ROWTYPE;
BEGIN
    IF TG_OP = ''INSERT'' THEN
        IF NEW."RootTaskId" IS NULL THEN
            UPDATE public."Tasks" SET "RootTaskId" = NEW."Id" WHERE "Id" = NEW."Id";
        END IF;
        IF NEW."ParentTaskId" IS NOT NULL THEN
            newRootId = (SELECT "RootTaskId" FROM public."Tasks" WHERE "Id" = NEW."ParentTaskId");
            IF (newRootId IS NULL) THEN
                UPDATE public."Tasks" SET "RootTaskId" = NEW."ParentTaskId" WHERE "Id" = NEW."Id";
            ELSE
                UPDATE public."Tasks" SET "RootTaskId" = newRootId WHERE "Id" = NEW."Id";
            END IF;
        END IF;
    END IF;
    IF TG_OP = ''UPDATE'' THEN
        IF OLD."ParentTaskId" IS DISTINCT FROM NEW."ParentTaskId" THEN
            newRootId = (SELECT "RootTaskId" FROM public."Tasks" WHERE "Id" = NEW."ParentTaskId");

            IF (newRootId IS NULL) THEN
                UPDATE public."Tasks" SET "RootTaskId" = NEW."ParentTaskId" WHERE "Id" = NEW."Id";
            ELSE
                UPDATE public."Tasks" SET "RootTaskId" = newRootId WHERE "Id" = NEW."Id";
            END IF;

            -- update children
            FOR temprow IN
                SELECT * FROM public."Tasks" WHERE "RootTaskId" = OLD."RootTaskId" AND "Id" != NEW."Id" AND "ParentTaskId" IS NOT NULL
                LOOP
                    IF (newRootId IS NULL) THEN
                        UPDATE public."Tasks" SET "RootTaskId" = NEW."ParentTaskId" WHERE "Id" = temprow."Id";
                    ELSE
                        UPDATE public."Tasks" SET "RootTaskId" = newRootId WHERE "Id" = temprow."Id";
                    END IF;
                END LOOP;
        END IF;
    END IF;
    RETURN NULL;
END;
' language 'plpgsql';

CREATE TRIGGER trigger_update_task_RootTaskId
    AFTER INSERT OR UPDATE ON public."Tasks"
    FOR EACH ROW EXECUTE PROCEDURE update_task_RootTaskId();