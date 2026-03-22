-- one invoice per billing period per subscription. all amounts in cents.
-- account_id is denormalized from subscription for faster invoice-level aggregations.
-- amount_paid can differ from amount_due due to credits or failed charges — use
-- amount_paid for any revenue calculation.

CREATE TABLE invoices (
    id                      SERIAL          PRIMARY KEY,
    subscription_id         INTEGER         NOT NULL REFERENCES subscriptions(id),
    account_id              INTEGER         NOT NULL REFERENCES accounts(id),
    billing_period_start    TIMESTAMPTZ     NOT NULL,
    billing_period_end      TIMESTAMPTZ     NOT NULL,
    amount_due              INTEGER         NOT NULL,
    amount_paid             INTEGER         NOT NULL DEFAULT 0,
    status                  VARCHAR(30)     NOT NULL DEFAULT 'open',
    paid_at                 TIMESTAMPTZ,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_invoice_status   CHECK (status IN ('open', 'paid', 'void', 'uncollectible')),
    CONSTRAINT chk_amounts          CHECK (amount_due >= 0 AND amount_paid >= 0),
    CONSTRAINT chk_billing_period   CHECK (billing_period_end > billing_period_start)
);
