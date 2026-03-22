-- users belong to exactly one account.
-- email is unique across the whole system, not per-account. this matters for
-- the auto-join flow — if a user signs up with an email that matches an existing
-- account's domain, they get routed to that account instead of creating a new one.

CREATE TABLE users (
    id              SERIAL          PRIMARY KEY,
    account_id      INTEGER         NOT NULL REFERENCES accounts(id),
    email           VARCHAR(255)    NOT NULL UNIQUE,
    display_name    VARCHAR(255),
    role            VARCHAR(50)     NOT NULL DEFAULT 'member',
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    last_seen_at    TIMESTAMPTZ,
    deleted_at      TIMESTAMPTZ,

    CONSTRAINT chk_role CHECK (role IN ('admin', 'member', 'viewer'))
);

-- now we can close the loop on accounts.owner_id
ALTER TABLE accounts
    ADD CONSTRAINT fk_accounts_owner
    FOREIGN KEY (owner_id) REFERENCES users(id);

COMMENT ON COLUMN users.role IS 'admin = billing + settings access; viewer = read-only dashboards';
COMMENT ON COLUMN users.last_seen_at IS 'Updated on each authenticated request. Useful for dormant user detection.';
