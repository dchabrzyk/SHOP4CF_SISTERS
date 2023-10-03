-- liquibase formatted sql

-- changeset Sko:20230812170000-1
CREATE TABLE IF NOT EXISTS public."Quotations"
(
    "Id"             uuid                                               NOT NULL DEFAULT uuid_generate_v4(),
    "ScenarioId"     uuid                                               NOT NULL,
    "TenantId"       character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ExternalId"     character varying(255) COLLATE pg_catalog."default",
    "OrderLineId"    uuid                                               NOT NULL,
    "Description"    character varying(4000) COLLATE pg_catalog."default",
    "RevisionNumber" integer                                            NOT NULL,
    "QuotationType"  integer,
    "CreatedBy"      character varying(255) COLLATE pg_catalog."default",
    "CreatedAt"      timestamp without time zone,
    "ModifiedBy"     character varying(255) COLLATE pg_catalog."default",
    "ModifiedAt"     timestamp without time zone,
    CONSTRAINT "Quotation_pkey" PRIMARY KEY ("Id", "ScenarioId"),
    CONSTRAINT "Quotation_Scenarios" FOREIGN KEY ("ScenarioId") REFERENCES public."Scenarios" ("Id") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "Quotation_OrderLines" FOREIGN KEY ("OrderLineId", "ScenarioId") REFERENCES public."OrderLines" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
)
    TABLESPACE pg_default;

ALTER TABLE public."Quotations"
    OWNER to postgres;

ALTER TABLE public."Quotations"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."Quotations" TO cdems_user;

GRANT ALL ON TABLE public."Quotations" TO postgres;

CREATE POLICY default_quotation_org_isolation_policy
    ON public."Quotations"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));

-- changeset Sko:20230812170000-2
CREATE TABLE IF NOT EXISTS public."QuotationLines"
(
    "Id"              uuid                                               NOT NULL DEFAULT uuid_generate_v4(),
    "QuotationId"     uuid                                               NOT NULL,
    "ScenarioId"      uuid                                               NOT NULL,
    "TenantId"        character varying(20) COLLATE pg_catalog."default" NOT NULL,
    "ExternalId"      character varying(255) COLLATE pg_catalog."default",
    "ResourceId"      uuid                                               NOT NULL,
    "Price"           numeric,
    "Quantity"        numeric,
    "QuantityUnit"    integer,
    "MeasurementUnit" integer,
    "CurrencyCode"    integer,
    "TaskName"        character varying(255) COLLATE pg_catalog."default",
    "StepName"        character varying(255) COLLATE pg_catalog."default",
    "StepType"        integer,
    "Wbs"             character varying(255) COLLATE pg_catalog."default",
    "CreatedBy"       character varying(255) COLLATE pg_catalog."default",
    "CreatedAt"       timestamp without time zone,
    "ModifiedBy"      character varying(255) COLLATE pg_catalog."default",
    "ModifiedAt"      timestamp without time zone,
    CONSTRAINT "QuotationLine_pkey" PRIMARY KEY ("Id", "QuotationId", "ScenarioId"),
    CONSTRAINT "QuotationLine_Quotations" FOREIGN KEY ("QuotationId", "ScenarioId") REFERENCES public."Quotations" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT "QuotationLine_Resources" FOREIGN KEY ("ResourceId", "ScenarioId") REFERENCES public."Resources" ("Id", "ScenarioId") MATCH SIMPLE ON UPDATE CASCADE ON DELETE CASCADE
)
    TABLESPACE pg_default;

ALTER TABLE public."QuotationLines"
    OWNER to postgres;

ALTER TABLE public."QuotationLines"
    ENABLE ROW LEVEL SECURITY;

GRANT DELETE, INSERT, SELECT, UPDATE ON TABLE public."QuotationLines" TO cdems_user;

GRANT ALL ON TABLE public."QuotationLines" TO postgres;

CREATE POLICY default_quotation_line_org_isolation_policy
    ON public."QuotationLines"
    AS PERMISSIVE
    FOR ALL
    TO public
    USING ((("TenantId")::text = current_setting('app.current_tenant'::text)));
