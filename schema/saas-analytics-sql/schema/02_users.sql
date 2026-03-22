-- email is unique across the whole system, not per-account. this is what powers
-- the auto-join flow when a signup email matches an existing account's domain.

CREATE TABLE users (
    id              SERIAL          PRIMARY KEY,
    account_id      INTEGER         NOT NULL REFERENCES accounts(id),
    email           VARCHAR(255)    NOT NULL UNIQUE,
    display_name    VARCHAR(255),
    role            VARCHAR(50)     NOT NULL DEFAULT 'member',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    last_seen_at    TIMESTAMPTZ,                         -- updated on each authenticated request
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT chk_role CHECK (role IN ('admin', 'member', 'viewer'))
);

-- close the circular FK now that users exists
ALTER TABLE accounts
    ADD CONSTRAINT fk_accounts_owner
    FOREIGN KEY (owner_id) REFERENCES users(id);
