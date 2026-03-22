-- one active subscription per account at a time.
-- if an account upgrades, the old subscription gets cancelled_at set and a new
-- row is inserted. this gives you a full history rather than overwriting in place.
--
-- WARNING: the status CHECK constraint is load-bearing. several analysis queries
-- filter on specific statuses. if you add a new value here, audit the views and
-- analysis queries — particularly mrr_snapshot and mrr_movement — before deploying.

CREATE TABLE subscriptions (
    id                      SERIAL          PRIMARY KEY,
    account_id              INTEGER         NOT NULL REFERENCES accounts(id),
    plan_id                 INTEGER         NOT NULL REFERENCES plans(id),
    status                  VARCHAR(30)     NOT NULL DEFAULT 'trialing',
    seats                   INTEGER         NOT NULL DEFAULT 1,
    started_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    current_period_start    TIMESTAMPTZ     NOT NULL,
    current_period_end      TIMESTAMPTZ     NOT NULL,
    cancelled_at            TIMESTAMPTZ,
    trial_end               TIMESTAMPTZ,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_status   CHECK (status IN ('trialing', 'active', 'past_due', 'cancelled', 'paused')),
    CONSTRAINT chk_period   CHECK (current_period_end > current_period_start),
    CONSTRAINT chk_seats    CHECK (seats >= 1)
);

COMMENT ON COLUMN subscriptions.cancelled_at IS 'Set when subscription ends. NULL = still active. Do not use status alone to determine activity.';
COMMENT ON COLUMN subscriptions.seats IS 'Per-seat pricing. MRR = plan.price_monthly * seats.';
