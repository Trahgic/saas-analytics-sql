-- one active subscription per account at a time. upgrades/downgrades create a new row
-- with the old one getting cancelled_at set — keeps full history without overwriting.
--
-- don't filter on status alone to determine "active". pair it with cancelled_at IS NULL.
-- a scheduled cancellation has status = 'active' but cancelled_at set to a future date.
-- see notes.md for details.

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
