-- liquibase formatted sql

-- changeset Koza:20210809164100-1
ALTER TABLE public."ResourceSupply" ENABLE ROW LEVEL SECURITY;

ALTER TABLE public."Resources" ENABLE ROW LEVEL SECURITY;

ALTER TABLE public."Scenarios" ENABLE ROW LEVEL SECURITY;

--rollback ALTER TABLE public."ResourceSupply" DISABLE ROW LEVEL SECURITY;
--rollback ALTER TABLE public."Resources" DISABLE ROW LEVEL SECURITY;
--rollback ALTER TABLE public."Scenarios" DISABLE ROW LEVEL SECURITY;