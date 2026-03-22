-- Cohort retention by signup month.
-- For each cohort (signup month), tracks what % of accounts still have an active
-- subscription N months later. The result is a triangle — recent cohorts have
-- fewer data points because not enough time has passed.
--
-- Output is one row per cohort × period combination.
-- Pivot in your BI tool (Metabase, Looker, Redash, etc.) to get the standard
-- triangle table format. Or use CROSSTAB in Postgres if you want SQL-native pivoting.
--
-- "Active" = has a non-cancelled subscription in that month. Trialing accounts
-- are included here. If you want paid-only retention, add the plan price filter
-- from churn_rate.sql to the subscription_months CTE.
--
-- The LATERAL + generate_series approach is Postgres-only.
-- For MySQL 8+: replace with a recursive CTE or a calendar table join.
-- For SQLite: use a recursive CTE.

WITH cohorts AS (
    SELECT
        a.id                                            AS account_id,
        DATE_TRUNC('month', a.created_at)               AS cohort_month
    FROM accounts a
    WHERE a.deleted_at IS NULL
),

-- expand each subscription into one row per calendar month it was active
subscription_months AS (
    SELECT DISTINCT
        s.account_id,
        DATE_TRUNC('month', m.month)                    AS active_month
    FROM subscriptions s
    CROSS JOIN LATERAL (
        SELECT generate_series(
            DATE_TRUNC('month', s.started_at),
            COALESCE(
                DATE_TRUNC('month', s.cancelled_at) - INTERVAL '1 day',
                DATE_TRUNC('month', NOW())
            ),
            INTERVAL '1 month'
        ) AS month
    ) m
    WHERE s.status IN ('active', 'trialing', 'cancelled')
)

SELECT
    c.cohort_month,
    sm.active_month,
    -- months since signup: 0 = signup month, 1 = one month later, etc.
    (EXTRACT(YEAR  FROM AGE(sm.active_month, c.cohort_month)) * 12 +
     EXTRACT(MONTH FROM AGE(sm.active_month, c.cohort_month)))::INTEGER AS months_since_signup,
    COUNT(DISTINCT c.account_id)                        AS cohort_size,
    COUNT(DISTINCT sm.account_id)                       AS retained,
    ROUND(
        COUNT(DISTINCT sm.account_id) * 100.0 /
        NULLIF(COUNT(DISTINCT c.account_id), 0), 1
    )                                                   AS retention_pct
FROM cohorts c
LEFT JOIN subscription_months sm
    ON  sm.account_id  = c.account_id
    AND sm.active_month >= c.cohort_month
GROUP BY
    c.cohort_month,
    sm.active_month
HAVING sm.active_month IS NOT NULL
ORDER BY
    c.cohort_month,
    sm.active_month;
