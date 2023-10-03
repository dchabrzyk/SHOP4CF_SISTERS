-- liquibase formatted sql

-- changeset Sko:20220601160000-1

ALTER TABLE public."CustomerOrders" RENAME TO "Orders";

ALTER TABLE public."Orders"
    ADD COLUMN "OrderType" integer NOT NULL;

ALTER TABLE public."Orders"
    RENAME CONSTRAINT "CustomerOrders_pkey" TO "Orders_pkey";

ALTER TABLE public."Orders"
    RENAME CONSTRAINT "CustomerOrders_Scenarios" TO "Orders_Scenarios";

ALTER TABLE public."Orders"
    RENAME CONSTRAINT "CustomerOrders_Organizations" TO "Orders_Organizations";

ALTER POLICY "default_customer_orders_org_isolation_policy" ON public."Orders"
    RENAME TO "default_orders_org_isolation_policy";

-- changeset Sko:20220601160000-2

ALTER TABLE public."CustomerOrderLines" RENAME TO "OrderLines";

ALTER TABLE public."OrderLines"
    RENAME COLUMN "CustomerOrderId" TO "OrderId";

ALTER TABLE public."OrderLines"
    RENAME CONSTRAINT "CustomerOrderLines_pkey" TO "OrderLines_pkey";

ALTER TABLE public."OrderLines"
    RENAME CONSTRAINT "CustomerOrderLines_Scenarios" TO "OrderLines_Scenarios";

ALTER TABLE public."OrderLines"
    RENAME CONSTRAINT "CustomerOrderLines_CustomerOrders" TO "OrderLines_Orders";

ALTER TABLE public."OrderLines"
    RENAME CONSTRAINT "CustomerOrderLines_Resources" TO "OrderLines_Resources";

ALTER POLICY "customer_order_lines_org_isolation_policy" ON public."OrderLines"
    RENAME TO "order_lines_org_isolation_policy";