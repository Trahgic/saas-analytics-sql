-- Feature adoption: % of active paid accounts that used each feature in the last 30 days.
--
-- "Feature" is mapped from event_type. Update the CASE block below to match
-- whatever your product's event taxonomy looks like. event_types not in the
-- CASE list are ignored (catch-all maps to NULL, then filtered out).
--
-- 30-day window is rolling from NOW(). For a fixed period (e.g., last full month),
-- swap the WHERE clause: created_at >= '2024-10-01' AND created_at < '2024-11-01'.
--
-- This counts accounts, not users. An account that had 10 people use CSV export
-- still shows as 1 in accounts_used. Switch to COUNT(DISTINCT user_id) if you want
-- user-level adoption instead.

WITH paid_accounts AS (
    SELECT DISTINCT s.account_id
    FROM subscriptions s
    JOIN plans p ON p.id = s.plan_id
    WHERE s.status       = 'active'
      AND p.price_monthly > 0
      AND s.cancelled_at IS NULL
),

feature_usage AS (
    SELECT
        e.account_id,
        CASE e.event_type
            WHEN 'export_csv'       THEN 'CSV Export'
            WHEN 'invite_sent'      THEN 'Team Invite'
            WHEN 'api_key_created'  THEN 'API Access'
            WHEN 'report_created'   THEN 'Custom Reports'
            WHEN 'webhook_created'  THEN 'Webhooks'
            WHEN 'sso_login'        THEN 'SSO Login'
            ELSE NULL
        END AS feature_name
    FROM events e
    WHERE e.created_at >= NOW() - INTERVAL '30 days'
      AND e.account_id IN (SELECT account_id FROM paid_accounts)
)

SELECT
    fu.feature_name,
    COUNT(DISTINCT fu.account_id)                       AS accounts_used,
    (SELECT COUNT(*) FROM paid_accounts)                AS total_paid_accounts,
    ROUND(
        COUNT(DISTINCT fu.account_id) * 100.0 /
        NULLIF((SELECT COUNT(*) FROM paid_accounts), 0), 1
    )                                                   AS adoption_pct
FROM feature_usage fu
WHERE fu.feature_name IS NOT NULL
GROUP BY fu.feature_name
ORDER BY adoption_pct DESC;
