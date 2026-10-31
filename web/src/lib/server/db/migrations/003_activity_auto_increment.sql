-- 003_activity_auto_increment.sql
--
-- In PostgreSQL 18, activity.id is a SERIAL column with an associated sequence.
-- This ensures the sequence is attached if it was missing.

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_depend d ON d.objid = c.oid
        WHERE c.relkind = 'S' AND d.refobjid = 'activity'::regclass
    ) THEN
        CREATE SEQUENCE IF NOT EXISTS activity_id_seq;
        ALTER TABLE activity ALTER COLUMN id SET DEFAULT nextval('activity_id_seq');
        ALTER SEQUENCE activity_id_seq OWNED BY activity.id;
    END IF;
END $$;
