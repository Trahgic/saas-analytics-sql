-- Trial-to-paid conversion rate by signup cohort.
-- "Converted" = account moved from trialing to active on a plan with price > 0.
-- Grouped by signup month so you can track whether conversion is trending up or down.
--
-- Only includes accounts that actually had a trial (trial_ends_at IS NOT NULL).
-- Accounts created directly on a paid plan are excluded — they weren't trialing.
--
-- Very recent cohorts (last 14 days) show artificially low conversion because
-- most trials haven't expired yet. The WHERE clause below excludes them by default.
-- Remove or adjust it if you want to see in-flight trials.

WITH trialed AS (
    SELECT
        a.id                                            AS account_id,
        DATE_TRUNC('month', a.created_at)               AS signup_month,
        a.trial_ends_at
    FROM accounts a
    WHERE a.trial_ends_at IS NOT NULL
      AND a.deleted_at    IS NULL
      -- exclude cohorts too recent for the trial to have ended
      AND a.trial_ends_at < NOW()
),

converted AS (
    -- an account converted if it has any active paid subscription
    SELECT DISTINCT s.account_id
    FROM subscriptions s
    JOIN plans p ON p.id = s.plan_id
    WHERE s.status       = 'active'
      AND p.price_monthly > 0
)

SELECT
    t.signup_month,
    COUNT(DISTINCT t.account_id)                        AS trialed,
    COUNT(DISTINCT c.account_id)                        AS converted,
    COUNT(DISTINCT t.account_id)
        - COUNT(DISTINCT c.account_id)                  AS dropped_off,
    ROUND(
        COUNT(DISTINCT c.account_id) * 100.0 /
        NULLIF(COUNT(DISTINCT t.account_id), 0), 1
    )                                                   AS conversion_pct
FROM trialed t
LEFT JOIN converted c ON c.account_id = t.account_id
GROUP BY t.signup_month
ORDER BY t.signup_month DESC;
