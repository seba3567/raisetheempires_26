-- 004_clans.sql
--
-- Shared clan and alliance persistence for multiplayer.
-- PostgreSQL 18.

CREATE TABLE IF NOT EXISTS clans (
    id          SERIAL       PRIMARY KEY,
    name        VARCHAR(64)  NOT NULL,
    crest       VARCHAR(32)  NOT NULL DEFAULT 'crest_01',
    level       INT          NOT NULL DEFAULT 1,
    xp          BIGINT       NOT NULL DEFAULT 0,
    health      INT          NOT NULL DEFAULT 100,
    max_health  INT          NOT NULL DEFAULT 100,
    slots       INT          NOT NULL DEFAULT 10,
    leader_id   INT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS clan_members (
    clan_id    INT         NOT NULL REFERENCES clans (id) ON DELETE CASCADE,
    user_id    INT         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    role       VARCHAR(16) NOT NULL DEFAULT 'member',
    joined_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (clan_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_clan_members_user ON clan_members (user_id);

CREATE TABLE IF NOT EXISTS clan_messages (
    id         SERIAL      PRIMARY KEY,
    clan_id    INT         NOT NULL REFERENCES clans (id) ON DELETE CASCADE,
    user_id    INT         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    message    TEXT        NOT NULL,
    created_at TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_clan_messages_clan ON clan_messages (clan_id, id);
