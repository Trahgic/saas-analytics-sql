-- LTV by plan: realized (backward-looking) vs. projected (forward-looking).
--
-- Realized LTV = average total amount paid by churned accounts before they left.
-- This is the honest number. It's based on accounts that have already run their
-- full lifecycle. Limitation: it's a lagging indicator and will understate LTV
-- for newer plans that haven't had time to generate long tenures.
--
-- Projected LTV = plan ARPU / monthly churn rate (classic formula).
-- This assumes constant churn, no expansion revenue, and no seasonality.
-- It's useful as a benchmark but treat it as a rough upper bound, not a forecast.
--
-- The gap between realized and projected is usually instructive. If projected
-- is 3x realized, your churn model is overly optimistic.

WITH churned_revenue AS (
    SELECT
        s.account_id,
        p.id                                            AS plan_id,
        p.name                                          AS plan_name,
        SUM(i.amount_paid)                              AS total_paid_cents
    FROM subscriptions s
    JOIN plans p     ON p.id = s.plan_id
    JOIN invoices i  ON i.subscription_id = s.id AND i.status = 'paid'
    WHERE s.status      = 'cancelled'
      AND p.price_monthly > 0
    GROUP BY s.account_id, p.id, p.name
),

-- churn rate estimated from the last 90 days, annualized
plan_churn AS (
    SELECT
        p.id                                            AS plan_id,
        p.name                                          AS plan_name,
        p.price_monthly,
        COUNT(CASE
            WHEN s.status = 'cancelled'
             AND s.cancelled_at >= NOW() - INTERVAL '90 days'
            THEN 1 END)                                 AS cancellations_90d,
        COUNT(CASE
            WHEN s.status IN ('active', 'cancelled')
            THEN 1 END)                                 AS total_ever_active,
        ROUND(
            COUNT(CASE
                WHEN s.status = 'cancelled'
                 AND s.cancelled_at >= NOW() - INTERVAL '90 days'
                THEN 1 END) * 4.0
            / NULLIF(COUNT(CASE WHEN s.status IN ('active','cancelled') THEN 1 END), 0)
        , 4)                                            AS annual_churn_rate
    FROM subscriptions s
    JOIN plans p ON p.id = s.plan_id
    WHERE p.price_monthly > 0
    GROUP BY p.id, p.name, p.price_monthly
)

SELECT
    cr.plan_name,
    COUNT(*)                                            AS churned_accounts_sampled,
    ROUND(AVG(cr.total_paid_cents) / 100.0, 2)         AS avg_realized_ltv_usd,
    ROUND(MAX(cr.total_paid_cents) / 100.0, 2)         AS max_realized_ltv_usd,
    ROUND(pc.annual_churn_rate * 100, 1)                AS annual_churn_pct,
    -- projected LTV: monthly ARPU / monthly churn rate
    -- monthly churn rate = annual / 12
    CASE
        WHEN pc.annual_churn_rate > 0
        THEN ROUND(
            (pc.price_monthly / 100.0) /
            (pc.annual_churn_rate / 12.0)
        , 2)
        ELSE NULL
    END                                                 AS projected_ltv_usd
FROM churned_revenue cr
JOIN plan_churn pc ON pc.plan_id = cr.plan_id
GROUP BY cr.plan_name, pc.annual_churn_rate, pc.price_monthly
ORDER BY avg_realized_ltv_usd DESC NULLS LAST;
