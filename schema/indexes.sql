-- indexes chosen based on the query patterns in views/ and analysis/.
-- not comprehensive — add more as you identify slow queries with EXPLAIN ANALYZE.
--
-- events is the hot table. the composite index on (account_id, created_at DESC) is
-- critical — nearly every events query filters on both. don't drop it.

-- core FK lookups
CREATE INDEX idx_users_account          ON users(account_id);
CREATE INDEX idx_subs_account           ON subscriptions(account_id);
CREATE INDEX idx_subs_plan              ON subscriptions(plan_id);
CREATE INDEX idx_subs_status            ON subscriptions(status);
CREATE INDEX idx_invoices_account       ON invoices(account_id);
CREATE INDEX idx_invoices_subscription  ON invoices(subscription_id);

-- MRR/churn queries filter cancelled_at frequently
CREATE INDEX idx_subs_cancelled         ON subscriptions(cancelled_at)
    WHERE cancelled_at IS NOT NULL;

-- events: always filter account + time window first
CREATE INDEX idx_events_account_time    ON events(account_id, created_at DESC);
CREATE INDEX idx_events_user_time       ON events(user_id, created_at DESC)
    WHERE user_id IS NOT NULL;
CREATE INDEX idx_events_type            ON events(event_type);

-- soft-delete filters
CREATE INDEX idx_accounts_active        ON accounts(id) WHERE deleted_at IS NULL;
CREATE INDEX idx_users_active           ON users(id)    WHERE deleted_at IS NULL;

-- NOTE: if you add JSONB to events.properties on Postgres, add a GIN index:
-- CREATE INDEX idx_events_properties ON events USING GIN (properties);
