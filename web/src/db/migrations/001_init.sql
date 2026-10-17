-- 001_init.sql
--
-- Accounts, friendships and progress for the public web surface.
--
-- Deliberately portable ANSI-ish SQL: no SQLite-only functions, no
-- AUTOINCREMENT magic that Postgres would reject. The id is assigned by the
-- application from a stable source (see src/ids.ts) so a save can never be
-- orphaned by a regenerated id.
--
-- `zid` is the game's world identity. In the Python server it is derived from
-- the Flask session cookie (crc64(sid) // 2048), which means it changes if the
-- cookie is regenerated and can silently split an existing save in two. Here it
-- is derived from the stable account id instead, so identity survives logout,
-- password change and cookie rotation.

CREATE TABLE IF NOT EXISTS users (
    id            INTEGER PRIMARY KEY,
    -- zid handed to the AMF0 gateway as the player's uid.
    zid           INTEGER NOT NULL UNIQUE,
    username      TEXT    NOT NULL,
    -- Lower-cased username, used for uniqueness so "Ana" and "ana" cannot
    -- both register.
    username_key  TEXT    NOT NULL UNIQUE,
    password_hash TEXT    NOT NULL,
    created_at    TEXT    NOT NULL,
    last_seen_at  TEXT
);

-- Requested friendships. Symmetric rows: a request creates two rows, one per
-- direction, so a lookup never needs a join or a status column.
--
-- `requested_by` is what makes the pending state readable from either side.
-- Both rows carry the same status, so without it there is no way to tell who
-- asked, and the requester would appear to be the recipient.
CREATE TABLE IF NOT EXISTS friendships (
    user_id      INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    friend_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status       TEXT    NOT NULL,
    requested_by INTEGER NOT NULL,
    created_at   TEXT    NOT NULL,
    -- Set when status becomes 'accepted'.
    accepted_at  TEXT,
    PRIMARY KEY (user_id, friend_id)
);

CREATE INDEX IF NOT EXISTS idx_friendships_friend ON friendships(friend_id);

-- Progress owned by an account: level, xp and the island name shown in game.
CREATE TABLE IF NOT EXISTS progress (
    user_id      INTEGER PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    level        INTEGER NOT NULL DEFAULT 1,
    xp           INTEGER NOT NULL DEFAULT 0,
    world_name   TEXT    NOT NULL,
    updated_at   TEXT    NOT NULL
);

-- Append-only record of world events seen from the gateway, so the web
-- surface can show real activity without replaying Python's save blobs.
CREATE TABLE IF NOT EXISTS activity (
    id          INTEGER PRIMARY KEY,
    user_id     INTEGER REFERENCES users(id) ON DELETE CASCADE,
    kind        TEXT    NOT NULL,
    detail      TEXT,
    created_at  TEXT    NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_activity_user ON activity(user_id, id);