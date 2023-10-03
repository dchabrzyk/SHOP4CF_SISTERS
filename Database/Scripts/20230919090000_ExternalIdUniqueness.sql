-- liquibase formatted sql

-- changeset Sko:20230919090000-1
ALTER TABLE "AttachmentContent"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_attachment_content;
ALTER TABLE "AttachmentContent"
    ADD CONSTRAINT uq_externalid_per_tenant_attachment_content UNIQUE ("TenantId", "ExternalId");

-- changeset Sko:20230919090000-2
ALTER TABLE "Contacts"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_contacts;
ALTER TABLE "Contacts"
    ADD CONSTRAINT uq_externalid_per_tenant_contacts UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-3
ALTER TABLE "CostCatalogueItems"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_cost_catalogue_items;
ALTER TABLE "CostCatalogueItems"
    ADD CONSTRAINT uq_externalid_per_tenant_cost_catalogue_items UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-4
ALTER TABLE "ModelInstances"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_model_instances;
ALTER TABLE "ModelInstances"
    ADD CONSTRAINT uq_externalid_per_tenant_model_instances UNIQUE ("TenantId", "ExternalId", "RevisionNumber");

-- changeset Sko:20230919090000-5
ALTER TABLE "Orders"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_orders;
ALTER TABLE "Orders"
    ADD CONSTRAINT uq_externalid_per_tenant_orders UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-6
ALTER TABLE "Organizations"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_organizations;
ALTER TABLE "Organizations"
    ADD CONSTRAINT uq_externalid_per_tenant_organizations UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-7
ALTER TABLE "QuotationLines"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_quotation_lines;
ALTER TABLE "QuotationLines"
    ADD CONSTRAINT uq_externalid_per_tenant_quotation_lines UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-8
ALTER TABLE "Quotations"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_quotations;
ALTER TABLE "Quotations"
    ADD CONSTRAINT uq_externalid_per_tenant_quotations UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-9
ALTER TABLE "Resources"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_resources;
ALTER TABLE "Resources"
    ADD CONSTRAINT uq_externalid_per_tenant_resources UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-10
ALTER TABLE "Tasks"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_tasks;
ALTER TABLE "Tasks"
    ADD CONSTRAINT uq_externalid_per_tenant_tasks UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-11
ALTER TABLE "TaskTimeBoxes"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_task_time_boxes;
ALTER TABLE "TaskTimeBoxes"
    ADD CONSTRAINT uq_externalid_per_tenant_task_time_boxes UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-12
ALTER TABLE "TimeCapacityRules"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_time_capacity_rules;
ALTER TABLE "TimeCapacityRules"
    ADD CONSTRAINT uq_externalid_per_tenant_time_capacity_rules UNIQUE ("TenantId", "ScenarioId", "ExternalId");

-- changeset Sko:20230919090000-13
ALTER TABLE "TrackingUniqueIdentifierSequences"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_time_track_unique_identifier_sequences;
ALTER TABLE "TrackingUniqueIdentifierSequences"
    ADD CONSTRAINT uq_externalid_per_tenant_time_track_unique_identifier_sequences UNIQUE ("TenantId", "ExternalId");

-- changeset Sko:20230919090000-14
ALTER TABLE "WorkJournalRecords"
    DROP CONSTRAINT IF EXISTS uq_externalid_per_tenant_work_journal_records;
ALTER TABLE "WorkJournalRecords"
    ADD CONSTRAINT uq_externalid_per_tenant_work_journal_records UNIQUE ("TenantId", "ExternalId");