-- billing unit. owner_id FK is added in 02_users.sql to break the circular dependency
-- (users.account_id → accounts, accounts.owner_id → users).

CREATE TABLE accounts (
    id              SERIAL          PRIMARY KEY,
    name            VARCHAR(255)    NOT NULL,
    domain          VARCHAR(255)    UNIQUE,              -- used for auto-join on email domain match at signup
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    trial_ends_at   TIMESTAMPTZ,
    industry        VARCHAR(100),
    employee_count  INTEGER,                             -- self-reported; treat as a bucket, not a fact
    owner_id        INTEGER,                             -- FK added in 02_users.sql
    deleted_at      TIMESTAMPTZ
);
