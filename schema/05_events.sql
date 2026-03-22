-- product usage events. this is the highest-volume table by far.
-- never run an unbounded query against it — always filter on account_id + created_at.
--
-- properties stores arbitrary event metadata as JSON.
-- on Postgres: change this column to JSONB and add a GIN index for property-level queries.
-- on MySQL:    use the native JSON type.
-- on SQLite:   keep as TEXT and parse in application code or use json_extract().
--
-- user_id is nullable — some events are server-side or come from anonymous sessions
-- before a user authenticates. filter these out for per-user metrics.

CREATE TABLE events (
    id              BIGSERIAL       PRIMARY KEY,
    account_id      INTEGER         NOT NULL REFERENCES accounts(id),
    user_id         INTEGER         REFERENCES users(id),
    event_type      VARCHAR(100)    NOT NULL,
    properties      TEXT,                                -- JSON; see note above re: dialect
    session_id      VARCHAR(100),
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

-- example event_type values (not enforced by DB — enforced at ingest):
--   page_view, feature_used, export_csv, invite_sent, api_key_created,
--   report_created, webhook_created, sso_login, password_reset, plan_upgraded
