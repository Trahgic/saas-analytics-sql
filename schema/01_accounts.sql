-- accounts are the billing unit. in a B2B PLG product this maps to an org;
-- in a sales-led motion it maps to a customer/company.
--
-- owner_id is a FK back to users, but users.account_id references accounts,
-- so we have a circular dependency. handle it by adding the FK as an ALTER
-- after users is created (see 02_users.sql).

CREATE TABLE accounts (
    id              SERIAL          PRIMARY KEY,
    name            VARCHAR(255)    NOT NULL,
    domain          VARCHAR(255)    UNIQUE,              -- used for auto-join on email match at signup
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    trial_ends_at   TIMESTAMPTZ,
    industry        VARCHAR(100),
    employee_count  INTEGER,                             -- self-reported dropdown at signup, not verified
    owner_id        INTEGER,                             -- FK added in 02_users.sql
    deleted_at      TIMESTAMPTZ                          -- soft delete; exclude in most queries
);

COMMENT ON COLUMN accounts.employee_count IS 'Self-reported at signup. Treat as a rough bucket, not a fact.';
COMMENT ON COLUMN accounts.domain IS 'Used for SSO matching and auto-join flows. Not always set.';
