-- liquibase formatted sql

-- changeset Sko:20230730120000-1
CREATE TABLE IF NOT EXISTS public."CostCatalogueItems"
(
    "Id"                   uuid                                               NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId"           uuid                                               NOT NULL,
    "TenantId"             character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ExternalId"           character varying(255) COLLATE pg_catalog."default",
    "ValidFrom"            timestamp without time zone,
    "ValidTo"              timestamp without time zone,
    "PricePerQuantity"     numeric,
    "CurrencyCode"         integer,
    "Tags"                 text[],
    "MeasurementUnit"      integer                                                     default 0,
    "QuantityPerPrice"     numeric,
    "QuantityPerPriceUnit" integer,
    "PackSize"             numeric,
    "OrderableUnit"        integer                                                     default 0,
    "MinimumOrderQuantity" numeric,
    "ProviderId"           uuid,
    "ResourceId"           uuid                                               NOT NULL,
    "LeadTime"             INTERVAL,
    CONSTRAINT "CostCatalogueItems_pkey" PRIMARY KEY ("Id", "ScenarioId"),
    CONSTRAINT "CostCatalogueItems_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES public."Scenarios" ("Id") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "CostCatalogueItems_Organizations" FOREIGN KEY ("ProviderId", "ScenarioId") REFERENCES public."Organizations" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
)
    TABLESPACE pg_default;

ALTER TABLE public."CostCatalogueItems"
    OWNER to postgres;

ALTER TABLE public."CostCatalogueItems"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."CostCatalogueItems" TO cdems_user;

GRANT ALL ON TABLE public."CostCatalogueItems" TO postgres;

CREATE POLICY default_cost_catalogue_items_org_isolation_policy
    ON public."CostCatalogueItems"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));

   
