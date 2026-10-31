-- 005_gifts.sql
--
-- Real friend gift inbox and history.
-- PostgreSQL 18.

CREATE TABLE IF NOT EXISTS gifts (
    id          SERIAL       PRIMARY KEY,
    sender_id   INT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    receiver_id INT          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    gift_type   VARCHAR(32)  NOT NULL DEFAULT 'energy',
    claimed     BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    claimed_at  TIMESTAMP    NULL
);

CREATE INDEX IF NOT EXISTS idx_gifts_receiver ON gifts (receiver_id, claimed);
