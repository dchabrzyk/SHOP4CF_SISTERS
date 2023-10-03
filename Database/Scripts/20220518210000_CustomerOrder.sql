-- liquibase formatted sql

-- changeset Sko:20220518210000-1
CREATE TABLE IF NOT EXISTS public."CustomerOrders"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId" uuid NOT NULL,
    "TenantId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "OrganizationId" uuid NOT NULL, 
    "Description" character varying(255) COLLATE pg_catalog."default",
    "ExternalId" character varying(255) COLLATE pg_catalog."default",
    "IssueDate" timestamp without time zone,
    CONSTRAINT "CustomerOrders_pkey" PRIMARY KEY ( "Id", "ScenarioId"),
    CONSTRAINT "CustomerOrders_Scenarios" FOREIGN KEY ( "ScenarioId" ) REFERENCES public."Scenarios" ("Id") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "CustomerOrders_Organizations" FOREIGN KEY ( "OrganizationId", "ScenarioId" ) REFERENCES public."Organizations" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
)
TABLESPACE pg_default;

ALTER TABLE public."CustomerOrders"
    OWNER to postgres;

ALTER TABLE public."CustomerOrders"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."CustomerOrders" TO cdems_user;

GRANT ALL ON TABLE public."CustomerOrders" TO postgres;

CREATE POLICY default_customer_orders_org_isolation_policy
    ON public."CustomerOrders"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));

-- changeset Sko:20220518210000-2
CREATE TABLE IF NOT EXISTS public."CustomerOrderLines"
(
    "Id" uuid NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId" uuid NOT NULL,
    "TenantId" character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "CustomerOrderId" uuid NOT NULL,
    "Position" integer,
    "ItemId" uuid NOT NULL,
    "ItemName" character varying(255) COLLATE pg_catalog."default",
    "ItemRevision" character varying(255) COLLATE pg_catalog."default",
    "Quantity" numeric NOT NULL,
    "QuantityUnit" integer default 0 NOT NULL,
    "DeliveryDate" timestamp without time zone,
    CONSTRAINT "CustomerOrderLines_pkey" PRIMARY KEY ("Id", "ScenarioId" ),
    CONSTRAINT "CustomerOrderLines_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES public."Scenarios" ("Id") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "CustomerOrderLines_CustomerOrders" FOREIGN KEY ("CustomerOrderId", "ScenarioId") REFERENCES public."CustomerOrders" ("Id", "ScenarioId") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT "CustomerOrderLines_Resources" FOREIGN KEY ("ItemId", "ScenarioId") REFERENCES public."Resources" ("Id", "ScenarioId") MATCH SIMPLE
        ON UPDATE CASCADE
        ON DELETE CASCADE 
)
    TABLESPACE pg_default;

ALTER TABLE public."CustomerOrderLines"
    OWNER to postgres;

ALTER TABLE public."CustomerOrderLines"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."CustomerOrderLines" TO cdems_user;

GRANT
    ALL
    ON TABLE public."CustomerOrderLines" TO postgres;

CREATE
    POLICY customer_order_lines_org_isolation_policy
    ON public."CustomerOrderLines"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));
   
