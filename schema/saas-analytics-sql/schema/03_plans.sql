-- price_monthly is in cents (USD) — same convention used throughout invoices and subscriptions.
-- don't hard-delete plans; set is_active = false so old subscriptions can still reference them.

CREATE TABLE plans (
    id              SERIAL          PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL UNIQUE,
    price_monthly   INTEGER         NOT NULL,            -- cents, USD. 0 = free tier.
    max_seats       INTEGER,                             -- NULL = unlimited
    has_sso         BOOLEAN         NOT NULL DEFAULT FALSE,
    has_api_access  BOOLEAN         NOT NULL DEFAULT FALSE,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_price CHECK (price_monthly >= 0)
);
