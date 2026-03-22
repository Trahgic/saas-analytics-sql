-- Monthly churn rate broken into two numbers: account churn and revenue churn.
-- They tell different stories and you want both.
--
-- Account churn = % of accounts that cancelled in the month.
-- Revenue churn = % of MRR lost from cancellations (churned MRR / starting MRR).
--
-- A company with a few large churned accounts and many small retained ones will
-- show low account churn but high revenue churn. That's the one to worry about.
--
-- Free accounts are excluded (price_monthly = 0). They don't contribute to MRR
-- and including them inflates account count while deflating churn %, which is
-- misleading for anything revenue-related.

WITH paid_subscriptions AS (
    SELECT
        s.*,
        p.price_monthly * s.seats                       AS mrr_cents,
        DATE_TRUNC('month', s.started_at)               AS started_month,
        DATE_TRUNC('month', s.cancelled_at)             AS cancelled_month
    FROM subscriptions s
    JOIN plans p ON p.id = s.plan_id
    WHERE p.price_monthly > 0
),

-- for each calendar month, build a snapshot of:
--   - accounts that were active at the start of the month
--   - which ones cancelled during that month
monthly AS (
    SELECT
        DATE_TRUNC('month', cal.month)                  AS report_month,
        COUNT(DISTINCT ps.account_id)                   AS active_at_start,
        COUNT(DISTINCT CASE
            WHEN ps.cancelled_month = DATE_TRUNC('month', cal.month)
            THEN ps.account_id END)                     AS churned_accounts,
        SUM(ps.mrr_cents)                               AS mrr_at_start,
        SUM(CASE
            WHEN ps.cancelled_month = DATE_TRUNC('month', cal.month)
            THEN ps.mrr_cents ELSE 0 END)               AS churned_mrr
    FROM paid_subscriptions ps
    -- cross join to a calendar to get one row per month
    JOIN (
        SELECT generate_series(
            DATE_TRUNC('month', (SELECT MIN(started_at) FROM subscriptions)),
            DATE_TRUNC('month', NOW()),
            INTERVAL '1 month'
        ) AS month
    ) cal
        ON ps.started_month <= DATE_TRUNC('month', cal.month)
       AND (ps.cancelled_at IS NULL OR ps.cancelled_month >= DATE_TRUNC('month', cal.month))
    GROUP BY cal.month
    -- NOTE: generate_series is Postgres-specific.
    -- MySQL equivalent: join against a numbers/calendar table.
    -- SQLite equivalent: use a recursive CTE to generate months.
)

SELECT
    report_month,
    active_at_start,
    churned_accounts,
    ROUND(
        churned_accounts * 100.0 / NULLIF(active_at_start, 0), 2
    )                                                   AS account_churn_pct,
    ROUND(mrr_at_start / 100.0, 2)                      AS mrr_usd,
    ROUND(churned_mrr / 100.0, 2)                       AS churned_mrr_usd,
    ROUND(
        churned_mrr * 100.0 / NULLIF(mrr_at_start, 0), 2
    )                                                   AS revenue_churn_pct
FROM monthly
ORDER BY report_month DESC;
