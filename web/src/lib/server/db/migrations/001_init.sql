-- 001_init.sql
--
-- Accounts, friendships and progress for the public web surface.
-- PostgreSQL 18.
--
-- `zid` is the game's world identity, handed to the AMF0 gateway as the
-- player's uid. Here it comes from the stable account id so identity survives
-- logout, a password change and cookie rotation.

CREATE TABLE IF NOT EXISTS users (
    id            SERIAL       PRIMARY KEY,
    -- zid handed to the AMF0 gateway as the player's uid.
    zid           BIGINT       NOT NULL UNIQUE,
    username      VARCHAR(64)  NOT NULL,
    -- Lower-cased username, so "Ana" and "ana" cannot both register.
    username_key  VARCHAR(64)  NOT NULL UNIQUE,
    password_hash TEXT         NOT NULL,
    created_at    TIMESTAMP    NOT NULL,
    last_seen_at  TIMESTAMP    NULL
);

-- Requested friendships. Symmetric rows: a request creates two rows, one per
-- direction, so a lookup never needs a join or a status column.
--
-- `requested_by` is what makes the pending state readable from either side:
-- both rows carry the same status, so without it there would be no way to tell
-- who asked, and the requester would appear to be the recipient.
CREATE TABLE IF NOT EXISTS friendships (
    user_id      INT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    friend_id    INT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    status       VARCHAR(16)  NOT NULL,
    requested_by INT          NOT NULL,
    created_at   TIMESTAMP    NOT NULL,
    -- Set when status becomes 'accepted'.
    accepted_at  TIMESTAMP    NULL,
    PRIMARY KEY (user_id, friend_id)
);
CREATE INDEX IF NOT EXISTS idx_friendships_friend ON friendships (friend_id);

-- Progress owned by an account: level, xp and the island name shown in game.
CREATE TABLE IF NOT EXISTS progress (
    user_id    INT          PRIMARY KEY REFERENCES users (id) ON DELETE CASCADE,
    level      INT          NOT NULL DEFAULT 1,
    xp         BIGINT       NOT NULL DEFAULT 0,
    world_name VARCHAR(255) NOT NULL,
    updated_at TIMESTAMP    NOT NULL
);

-- Append-only record of world events seen from the gateway, so the web surface
-- can show real activity without replaying Python's save blobs.
CREATE TABLE IF NOT EXISTS activity (
    id         SERIAL       PRIMARY KEY,
    user_id    INT          NULL REFERENCES users (id) ON DELETE CASCADE,
    kind       VARCHAR(32)  NOT NULL,
    detail     TEXT         NULL,
    created_at TIMESTAMP    NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_activity_user ON activity (user_id, id);
