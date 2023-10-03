-- liquibase formatted sql

-- changeset Skorup:20220324150000-1
DROP POLICY resource_supply_org_isolation_policy ON public."ResourceCapacities";
ALTER TABLE public."ResourceCapacities" ALTER COLUMN "TenantId" TYPE varchar(20) USING rtrim("TenantId");
CREATE POLICY resource_capacity_org_isolation_policy ON public."ResourceCapacities"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 

-- changeset Skorup:20220324150000-2
DROP POLICY resources_org_isolation_policy ON public."Resources";
ALTER TABLE public."Resources" ALTER COLUMN "TenantId" TYPE varchar(20) USING rtrim("TenantId");
CREATE POLICY resources_org_isolation_policy ON public."Resources"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 

-- changeset Skorup:20220324150000-3
DROP POLICY scenarios_org_isolation_policy ON public."Scenarios";
ALTER TABLE public."Scenarios" ALTER COLUMN "TenantId" TYPE varchar(20) USING rtrim("TenantId");
CREATE POLICY scenarios_org_isolation_policy ON public."Scenarios"
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)) OR "TenantId" IS NULL); 

