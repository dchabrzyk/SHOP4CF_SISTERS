-- liquibase formatted sql

-- changeset Sko:20221206100000-1
ALTER TABLE public."Resources"
    ADD COLUMN "InfiniteCapacity" bool DEFAULT false,
    ADD COLUMN "InfiniteCapacityOffset" interval;
