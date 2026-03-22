-- pricing tiers. price_monthly is stored in cents (USD) to avoid float precision issues.
-- any arithmetic on money in this schema uses integer cents throughout.
--
-- is_active lets you retire a plan without deleting it — old subscriptions
-- can still reference inactive plans. don't hard-delete plans.

CREATE TABLE plans (
    id              SERIAL          PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL UNIQUE,
    price_monthly   INTEGER         NOT NULL,            -- cents, USD. 0 = free tier.
    max_seats       INTEGER,                             -- NULL means unlimited
    has_sso         BOOLEAN         NOT NULL DEFAULT FALSE,
    has_api_access  BOOLEAN         NOT NULL DEFAULT FALSE,
    is_active       BOOLEAN         NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_price CHECK (price_monthly >= 0)
);

-- expected rows after seed:
-- free       | 0
-- starter    | 4900   ($49/mo)
-- pro        | 14900  ($149/mo)
-- enterprise | 49900  ($499/mo)
