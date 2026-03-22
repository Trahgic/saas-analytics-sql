-- one invoice per billing period per subscription.
-- amounts are in cents (USD), same convention as plans.price_monthly.
--
-- amount_paid can differ from amount_due if there were credits, partial payments,
-- or failed charges. don't assume they're equal when calculating collected revenue.

CREATE TABLE invoices (
    id                      SERIAL          PRIMARY KEY,
    subscription_id         INTEGER         NOT NULL REFERENCES subscriptions(id),
    account_id              INTEGER         NOT NULL REFERENCES accounts(id),  -- denormalized for query convenience
    billing_period_start    TIMESTAMPTZ     NOT NULL,
    billing_period_end      TIMESTAMPTZ     NOT NULL,
    amount_due              INTEGER         NOT NULL,    -- cents
    amount_paid             INTEGER         NOT NULL DEFAULT 0,
    status                  VARCHAR(30)     NOT NULL DEFAULT 'open',
    paid_at                 TIMESTAMPTZ,
    created_at              TIMESTAMPTZ     NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_invoice_status   CHECK (status IN ('open', 'paid', 'void', 'uncollectible')),
    CONSTRAINT chk_amounts          CHECK (amount_due >= 0 AND amount_paid >= 0),
    CONSTRAINT chk_billing_period   CHECK (billing_period_end > billing_period_start)
);

COMMENT ON COLUMN invoices.account_id IS 'Denormalized from subscription for faster invoice-level aggregations.';
COMMENT ON COLUMN invoices.amount_paid IS 'May be less than amount_due due to credits, coupons, or failed payments.';
