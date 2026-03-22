-- active or trialing subscriptions with their plan details attached.
-- excludes cancelled and paused.
--
-- mrr_cents uses seat-based pricing (plan price × seats).
-- this is wrong if you have account-level flat pricing — adjust accordingly.
--
-- used as a base in: mrr_movement.sql, feature_adoption.sql, ltv_by_plan.sql

CREATE OR REPLACE VIEW active_subscriptions AS
SELECT
    s.id                            AS subscription_id,
    s.account_id,
    s.plan_id,
    s.status,
    s.seats,
    s.started_at,
    s.current_period_start,
    s.current_period_end,
    s.trial_end,
    p.name                          AS plan_name,
    p.price_monthly,
    p.price_monthly * s.seats       AS mrr_cents
FROM subscriptions s
JOIN plans p ON p.id = s.plan_id
WHERE s.status IN ('active', 'trialing')
  AND s.cancelled_at IS NULL;
