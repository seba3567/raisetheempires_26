-- 001_init.sql
--
-- Accounts, friendships and progress for the public web surface.
--
-- MariaDB dialect. The original was written for SQLite, which is why this file
-- was rewritten rather than the old one edited in place: the project moved to
-- one database and the schema moved with it.
--
-- Two changes from the SQLite original, both forced by the engine rather than
-- chosen:
--
-- TEXT date columns become DATETIME. SQLite has no date type and stored them as
-- text, where they sorted and compared as strings; every "last N days" query
-- was a string comparison.
--
-- users.id stays a plain INT PRIMARY KEY with no AUTO_INCREMENT. The id is
-- assigned by the application from a stable source (see ids.ts) precisely so a
-- save cannot be orphaned by a regenerated id, and handing the sequence back to
-- the database would undo that decision.
--
-- `zid` is the game's world identity, handed to the AMF0 gateway as the
-- player's uid. In the Python server it came from the Flask session cookie
-- (crc64(sid) // 2048), which changes if the cookie is regenerated and can
-- silently split an existing save in two. Here it comes from the stable account
-- id instead, so identity survives logout, a password change and cookie
-- rotation.

CREATE TABLE IF NOT EXISTS users (
    id            INT         NOT NULL,
    -- zid handed to the AMF0 gateway as the player's uid.
    zid           BIGINT      NOT NULL,
    username      VARCHAR(64) NOT NULL,
    -- Lower-cased username, so "Ana" and "ana" cannot both register.
    username_key  VARCHAR(64) NOT NULL,
    password_hash TEXT        NOT NULL,
    created_at    DATETIME    NOT NULL,
    last_seen_at  DATETIME    NULL,
    PRIMARY KEY (id),
    UNIQUE KEY users_zid_unique (zid),
    UNIQUE KEY users_username_key_unique (username_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Requested friendships. Symmetric rows: a request creates two rows, one per
-- direction, so a lookup never needs a join or a status column.
--
-- `requested_by` is what makes the pending state readable from either side:
-- both rows carry the same status, so without it there would be no way to tell
-- who asked, and the requester would appear to be the recipient.
CREATE TABLE IF NOT EXISTS friendships (
    user_id      INT         NOT NULL,
    friend_id    INT         NOT NULL,
    status       VARCHAR(16) NOT NULL,
    requested_by INT         NOT NULL,
    created_at   DATETIME    NOT NULL,
    -- Set when status becomes 'accepted'.
    accepted_at  DATETIME    NULL,
    PRIMARY KEY (user_id, friend_id),
    KEY idx_friendships_friend (friend_id),
    CONSTRAINT friendships_user_fk FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT friendships_friend_fk FOREIGN KEY (friend_id)
        REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Progress owned by an account: level, xp and the island name shown in game.
CREATE TABLE IF NOT EXISTS progress (
    user_id    INT          NOT NULL,
    level      INT          NOT NULL DEFAULT 1,
    xp         BIGINT       NOT NULL DEFAULT 0,
    world_name VARCHAR(255) NOT NULL,
    updated_at DATETIME     NOT NULL,
    PRIMARY KEY (user_id),
    CONSTRAINT progress_user_fk FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Append-only record of world events seen from the gateway, so the web surface
-- can show real activity without replaying Python's save blobs.
--
-- `id` is AUTO_INCREMENT here, unlike users.id. Nothing downstream derives
-- meaning from an activity id, and the original "leave it to the column's rowid
-- alias" was SQLite-only -- MariaDB has no equivalent, so the column carries
-- its own sequence.
CREATE TABLE IF NOT EXISTS activity (
    id         INT         NOT NULL AUTO_INCREMENT,
    user_id    INT         NULL,
    kind       VARCHAR(32) NOT NULL,
    detail     TEXT        NULL,
    created_at DATETIME    NOT NULL,
    PRIMARY KEY (id),
    KEY idx_activity_user (user_id, id),
    CONSTRAINT activity_user_fk FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;