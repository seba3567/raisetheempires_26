-- Save storage.
--
-- MariaDB only. There was a SQLite schema here too until the move; the file
-- kept the plain name so the path in save_store.py did not have to move.
--
-- What this replaces
-- ------------------
-- One table, `sessions`, holding flask-session rows. The backup history lived
-- *inside* the payload, as a chain of nested copies, which is why one row could
-- reach 3 MB and why every request paid to decode the whole history to read the
-- current save.
--
-- The shape now
-- -------------
-- `saves` is the live save. One row per store id -- `acct<zid>` when the player
-- is signed in, the cookie sid otherwise. UNIQUE is what makes "one empire per
-- account" a property of the database rather than a convention somebody has to
-- remember.
--
-- `revision` is the optimistic lock. Every read gets the revision it saw, and
-- every write states the revision it expects. Two requests that both read
-- revision 7 cannot both write 8: the second matches no rows and is told so.
-- That was the lost update -- get_saves(), mutate in Python, overwrite the whole
-- row -- and it is the reason this column exists.
--
-- `uid` is the game's own player id, copied out of user_object.userInfo.player.uid
-- on every write. The game addresses *other* players by it -- an invasion, a
-- pillage, the neighbour list -- so without this column each of those calls had
-- to deserialise every empire in the database to compare one number.
--
-- `save_backups` is the history, in its own table. Keeping it out of `saves` is
-- the whole point of the rebuild: the row a request reads and writes is now the
-- size of the empire rather than the size of the empire times ten. Backups are
-- append-only and never touched by a normal request.
--
-- The payloads are opaque blobs on purpose. Nothing here tries to model the
-- empire's shape -- world objects, fleets and quests are the game's own data,
-- and a schema that has to be migrated every time the 2012 game settings change
-- would be a worse problem than the one it solves. What the store guarantees is
-- atomicity, versioning and history, which is what it can actually own.

CREATE TABLE IF NOT EXISTS saves (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    -- 'acct<zid>' for an account, the cookie sid otherwise. Never the raw zid,
    -- so nothing here can be used to claim another player's save.
    store_id    VARCHAR(255) NOT NULL,
    -- Bumped on every successful write. The compare-and-swap target.
    revision    INT NOT NULL DEFAULT 1,
    -- The game's player id, copied from the payload. Nullable: it is read out of
    -- the payload, and a row with no empire in it yet has none.
    uid         BIGINT NULL,
    -- The empire. msgpack, via the session interface's serializer.
    data        LONGBLOB NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT saves_store_id_unique UNIQUE (store_id),
    CONSTRAINT saves_revision_positive CHECK (revision >= 1),
    INDEX idx_saves_store_id (store_id),
    INDEX idx_saves_uid (uid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A snapshot of what a save looked like before a given revision was replaced.
-- `revision` here is the revision the snapshot IS, not the one it displaced, so
-- "restore revision 7" is unambiguous.
CREATE TABLE IF NOT EXISTS save_backups (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    save_id     INT NOT NULL,
    revision    INT NOT NULL,
    -- Why the snapshot exists: 'before Level 50', 'manual edit', whatever
    -- create_backup was called with. NULL for a snapshot taken because the row
    -- was about to be overwritten with no note attached.
    reason      VARCHAR(255),
    data        LONGBLOB NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT save_backups_save_fk FOREIGN KEY (save_id)
        REFERENCES saves (id) ON DELETE CASCADE,
    -- The one query that matters: "the newest N snapshots for this save".
    INDEX idx_save_backups_save_revision (save_id, revision)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;