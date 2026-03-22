-- DAU/MAU ratio by account and by aggregate.
-- A proxy for how "sticky" the product is. 
-- DAU/MAU of 0.5+ = daily habit. 0.1-0.2 = occasional use. Below 0.05 = at-risk.
--
-- These benchmarks are rough and product-dependent. A project management tool
-- used in weekly sprints will have lower DAU/MAU than a communication tool.
-- The more useful signal is whether the ratio is trending up or down over time.
--
-- Uses the user_activity_daily view. Requires the events table to be populated.
--
-- "DAU" here = average daily active users over the last 30 days.
-- "MAU" = distinct users active at least once in the last 30 days.
-- This matches how most analytics tools define it.

WITH last_30_days AS (
    SELECT
        account_id,
        user_id,
        activity_date
    FROM user_activity_daily
    WHERE activity_date >= CURRENT_DATE - INTERVAL '30 days'
),

dau_by_day AS (
    -- unique users per day per account
    SELECT
        account_id,
        activity_date,
        COUNT(DISTINCT user_id)     AS dau
    FROM last_30_days
    GROUP BY account_id, activity_date
),

account_metrics AS (
    SELECT
        d.account_id,
        ROUND(AVG(d.dau), 2)        AS avg_dau,
        (
            SELECT COUNT(DISTINCT user_id)
            FROM last_30_days l
            WHERE l.account_id = d.account_id
        )                           AS mau
    FROM dau_by_day d
    GROUP BY d.account_id
)

SELECT
    am.account_id,
    a.name                          AS account_name,
    am.avg_dau,
    am.mau,
    ROUND(am.avg_dau / NULLIF(am.mau, 0), 3)    AS dau_mau_ratio
FROM account_metrics am
JOIN accounts a ON a.id = am.account_id
WHERE a.deleted_at IS NULL
ORDER BY dau_mau_ratio DESC;

-- -----------------------------------------------------------------------
-- aggregate view across all accounts (paste or run separately)
-- -----------------------------------------------------------------------
-- SELECT
--     ROUND(AVG(avg_dau), 2)                      AS overall_avg_dau,
--     SUM(mau)                                    AS overall_mau,
--     ROUND(AVG(avg_dau / NULLIF(mau, 0)), 3)     AS median_dau_mau_ratio
-- FROM account_metrics;
