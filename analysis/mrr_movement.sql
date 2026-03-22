-- MRR movement for a target month.
-- Categories: new, expansion, contraction, churned, reactivation.
-- Net new MRR = new + expansion - contraction - churned.
--
-- This is the standard SaaS MRR waterfall. Running this every month gives you
-- a breakdown of *why* MRR changed, which is more useful than just the delta.
--
-- Usage: replace the date literals to target a different month.
--   :current_month_start = first day of the month you want to analyze
--   :prior_month_start   = first day of the previous month
--
-- Known limitation: accounts with multiple plan changes within a single month
-- will only show their net position (prior vs. end of month). intra-month
-- upgrades followed by churn in the same month will appear as churned, not
-- as new+churned. good enough for monthly reporting; not for daily.

WITH prior_mrr AS (
    SELECT
        s.account_id,
        SUM(p.price_monthly * s.seats)  AS mrr_cents
    FROM subscriptions s
    JOIN plans p ON p.id = s.plan_id
    WHERE s.status IN ('active')
      AND s.started_at        <  '2024-10-01'
      AND (s.cancelled_at IS NULL OR s.cancelled_at >= '2024-10-01')
    GROUP BY s.account_id
),

current_mrr AS (
    SELECT
        s.account_id,
        SUM(p.price_monthly * s.seats)  AS mrr_cents
    FROM subscriptions s
    JOIN plans p ON p.id = s.plan_id
    WHERE s.status IN ('active')
      AND s.started_at        <  '2024-11-01'
      AND (s.cancelled_at IS NULL OR s.cancelled_at >= '2024-11-01')
    GROUP BY s.account_id
),

movement AS (
    SELECT
        COALESCE(c.account_id, p.account_id)            AS account_id,
        COALESCE(p.mrr_cents, 0)                        AS prior_mrr,
        COALESCE(c.mrr_cents, 0)                        AS current_mrr,
        COALESCE(c.mrr_cents, 0) - COALESCE(p.mrr_cents, 0) AS delta
    FROM current_mrr c
    FULL OUTER JOIN prior_mrr p ON p.account_id = c.account_id
)

SELECT
    account_id,
    prior_mrr,
    current_mrr,
    delta,
    CASE
        WHEN prior_mrr  = 0 AND current_mrr  > 0   THEN 'new'
        WHEN prior_mrr  > 0 AND current_mrr  = 0   THEN 'churned'
        WHEN delta > 0                              THEN 'expansion'
        WHEN delta < 0                              THEN 'contraction'
        ELSE                                             'flat'
    END AS movement_type
FROM movement
ORDER BY movement_type, delta DESC;

-- -----------------------------------------------------------------------
-- summary roll-up (paste below the detail query or use as a CTE)
-- -----------------------------------------------------------------------
-- SELECT
--     movement_type,
--     COUNT(*)                            AS account_count,
--     SUM(delta)                          AS net_mrr_cents,
--     ROUND(SUM(delta) / 100.0, 2)        AS net_mrr_usd
-- FROM ( ... above query ... ) m
-- GROUP BY movement_type
-- ORDER BY net_mrr_cents DESC;
