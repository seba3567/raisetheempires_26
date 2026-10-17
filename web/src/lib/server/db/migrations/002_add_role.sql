-- 002_add_role.sql
--
-- Admins. Kept as text rather than a boolean so more roles can be added later
-- without another migration, and NOT NULL with a default so the existing rows
-- stay valid and the column can be added without a table rewrite.

ALTER TABLE users ADD COLUMN role TEXT NOT NULL DEFAULT 'player';