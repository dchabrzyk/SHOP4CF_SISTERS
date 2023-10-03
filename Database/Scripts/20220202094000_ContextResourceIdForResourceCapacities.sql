-- liquibase formatted sql

-- changeset Koza:20220202094000-1
ALTER TABLE public."ResourceCapacities"
    ADD COLUMN "ContextResourceId" uuid;
ALTER TABLE public."ResourceCapacities"
    ADD COLUMN "ExternalContextResourceId" character varying(255) COLLATE pg_catalog."default";

CREATE OR REPLACE FUNCTION update_context_resource_id() RETURNS TRIGGER AS
'
BEGIN
    IF TG_OP = ''DELETE'' THEN
        UPDATE public."ResourceCapacities" SET "ContextResourceId" = NULL WHERE "ContextResourceId" = OLD."Id" AND "ScenarioId" = OLD."ScenarioId";
        RETURN OLD;
    END IF;
    RETURN NULL;    
END;
' language 'plpgsql';

DROP TRIGGER IF EXISTS trigger_update_context_resource_id ON public."Resources";

ALTER FUNCTION update_context_resource_id() OWNER TO postgres;

CREATE TRIGGER trigger_update_context_resource_id
    AFTER DELETE
    ON "Resources"
    FOR EACH ROW
EXECUTE PROCEDURE update_context_resource_id();

--rollback DROP TRIGGER IF EXISTS trigger_update_context_resource_id ON public."Resources";
--rollback drop function update_context_resource_id;
--rollback alter table "ResourceCapacities" drop column "ContextResourceId";
--rollback alter table "ResourceCapacities" drop column "ExternalContextResourceId";
