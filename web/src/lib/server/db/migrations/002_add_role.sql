-- 002_add_role.sql
--
-- Admins. Kept as text rather than a boolean so more roles can be added later
-- without another migration, and NOT NULL with a default so the existing rows
-- stay valid and the column can be added without a table rewrite.
--
-- "IF NOT EXISTS" is load-bearing, not decoration. The runner records what it has
-- applied in schema_migrations, and when that table does not say this one ran it
-- runs it again -- and a bare ADD COLUMN dies with errno 1060, "Duplicate column
-- name 'role'". That failure is fatal rather than cosmetic: db() clears its
-- cached connection whenever opening fails, so every later request retried the
-- migration and failed the same way, and every page that touched the database
-- answered 500. One missing bookkeeping row locked people out of their accounts.
--
-- MariaDB spells the guard; MySQL does not, and this project is on MariaDB.

ALTER TABLE users ADD COLUMN IF NOT EXISTS role VARCHAR(16) NOT NULL DEFAULT 'player';