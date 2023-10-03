-- liquibase formatted sql

-- changeset Lukas:20211125092400-1

-- DROP INDEX public.settings_key_cntx_cntxval_profile_uindex;

DELETE FROM "Settings"
WHERE "OrganizationId" IS NULL;

CREATE UNIQUE INDEX settings_key_cntx_cntxval_profile_uindex
    ON public."Settings" USING btree
        ("Key" COLLATE pg_catalog."default" ASC NULLS LAST, "Context" ASC NULLS LAST, "ContextValue" COLLATE pg_catalog."default" ASC NULLS LAST, "Profile" COLLATE pg_catalog."default" ASC NULLS LAST) 
    WHERE "OrganizationId" IS NULL;