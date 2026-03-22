-- highest-volume table. always filter on account_id + created_at — never unbounded.
--
-- properties dialect note: Postgres → JSONB + GIN index. MySQL → JSON type. SQLite → TEXT + json_extract().
-- user_id is nullable for server-side and pre-auth events.

CREATE TABLE events (
    id              BIGSERIAL       PRIMARY KEY,
    account_id      INTEGER         NOT NULL REFERENCES accounts(id),
    user_id         INTEGER         REFERENCES users(id),
    event_type      VARCHAR(100)    NOT NULL,
    properties      TEXT,
    session_id      VARCHAR(100),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);
