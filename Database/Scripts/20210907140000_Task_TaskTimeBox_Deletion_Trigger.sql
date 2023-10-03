-- liquibase formatted sql

-- changeset Sko:20210907140000-1
CREATE OR REPLACE FUNCTION empty_time_box_id()
  RETURNS trigger AS
'
BEGIN
	UPDATE "Tasks"
		SET "TaskTimeBoxId"=NULL
   		WHERE "TaskTimeBoxId"=OLD."Id";
		RETURN OLD;
END;
'
LANGUAGE 'plpgsql';

CREATE TRIGGER "TaskUpdateBeforeTimeBoxDeletion" BEFORE DELETE ON "TaskTimeBoxes"
FOR EACH ROW EXECUTE FUNCTION empty_time_box_id();

--rollback DROP TRIGGER "TaskUpdateBeforeTimeBoxDeletion" ON "TaskTimeBoxes"; 
--rollback DROP FUNCTION IF EXISTS empty_time_box_id(); 