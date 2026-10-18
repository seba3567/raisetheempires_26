CREATE TABLE IF NOT EXISTS saves (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    -- 'acct<zid>' for an account, the cookie sid otherwise. Never the raw zid,
    -- so nothing here can be used to claim another player's save.
    store_id    VARCHAR(255) NOT NULL,
    -- Bumped on every successful write. The compare-and-swap target.
    revision    INT NOT NULL DEFAULT 1,
    -- The empire. msgpack, via the session interface's serializer.
    data        LONGBLOB NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT saves_store_id_unique UNIQUE (store_id),
    CONSTRAINT saves_revision_positive CHECK (revision >= 1),
    INDEX idx_saves_store_id (store_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A snapshot of what a save looked like before a given revision was replaced.
-- `revision` here is the revision the snapshot IS, not the one it displaced, so
-- "restore revision 7" is unambiguous.
CREATE TABLE IF NOT EXISTS save_backups (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    save_id     INT NOT NULL,
    revision    INT NOT NULL,
    reason      VARCHAR(255),
    data        LONGBLOB NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT save_backups_save_fk FOREIGN KEY (save_id)
        REFERENCES saves (id) ON DELETE CASCADE,
    -- The one query that matters: "the newest N snapshots for this save".
    INDEX idx_save_backups_save_revision (save_id, revision)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;