-- liquibase formatted sql

-- changeset Sko:20230104140000-1
CREATE OR REPLACE PROCEDURE IncrementSequence(sequenceId uuid, INOUT result bigint)
    LANGUAGE plpgsql AS
'
declare
    sequenceRecord record;
    newCurrent bigint;
    sequenceHash integer;

begin
    --advisory lock prevents others from execution
    --TODO might become a bottleneck

    sequenceHash:= uuid_hash(sequenceId);
    perform pg_advisory_lock(sequenceHash);

    SELECT * INTO sequenceRecord FROM "TrackingUniqueIdentifierSequences" WHERE "Id" = sequenceId;

    if
        sequenceRecord IS NULL
    then
        perform pg_advisory_unlock(sequenceHash);
        raise exception ''Calling IncrementSequence - Sequence with id (%) does not exist'', sequenceId;
    end if;

    --check if increment <> 0
    if
            sequenceRecord."IncrementBy" = 0
    then
        perform pg_advisory_unlock(sequenceHash);
        raise exception ''Calling IncrementSequence - IncrementBy cannot be 0 (sequence with id %)'', sequenceId;
    end if;
    --check if incremented value outside of minvalue-maxvalue range and cycle set to false
    newCurrent:=sequenceRecord."CurrentValue" + sequenceRecord."IncrementBy";
    if
                sequenceRecord."Cycle" = false AND (newCurrent > sequenceRecord."MaxValue" OR newCurrent < sequenceRecord."MinValue")
    then
        perform pg_advisory_unlock(sequenceHash);
        raise exception ''Calling IncrementSequence - current value is not within [MinValue, MaxValue] range while cycle set to false (sequence with id %)'', sequenceId;
    else
        if
                    sequenceRecord."Cycle" = true AND (newCurrent > sequenceRecord."MaxValue" OR newCurrent < sequenceRecord."MinValue")
        then
            if
                    sequenceRecord."IncrementBy" > 0
            then
                newCurrent:= sequenceRecord."MinValue";
            else
                newCurrent:=sequenceRecord."MaxValue";
            end if;
        end if;
    end if;

    UPDATE "TrackingUniqueIdentifierSequences" SET "CurrentValue" = newCurrent WHERE "Id" = sequenceId;
    commit;
    perform pg_advisory_unlock(sequenceHash);
    result:= newCurrent;
end
';