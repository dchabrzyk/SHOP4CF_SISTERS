-- liquibase formatted sql

-- changeset Sko:20211020124000-1
ALTER TABLE public."WorkJournalRecords" ADD COLUMN "EquipmentId" uuid;

--rollback ALTER TABLE public."WorkJournalRecords" DROP COLUMN "EquipmentId";