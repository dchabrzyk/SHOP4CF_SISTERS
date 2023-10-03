-- liquibase formatted sql

-- changeset Sko:20230130120000-1
CREATE MATERIALIZED VIEW IF NOT EXISTS "ResourceCapacities_MaterializedView"
AS
SELECT * FROM "ResourceCapacities"
WITH DATA;

CREATE UNIQUE INDEX "ResourceCapacities_MaterializedView_Index" ON "ResourceCapacities_MaterializedView" ("Id", "TenantId");

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."ResourceCapacities_MaterializedView" TO cdems_user;

GRANT ALL ON TABLE public."ResourceCapacities_MaterializedView" TO postgres;


CREATE OR REPLACE FUNCTION Refresh_ResourceCapacities_MaterializedView()
    RETURNS void
    SECURITY DEFINER
AS
'
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY "ResourceCapacities_MaterializedView";
    RETURN;
END
'
LANGUAGE plpgsql;
