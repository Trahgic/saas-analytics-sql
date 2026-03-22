-- daily unique active users per account.
-- DAU = distinct users who fired at least one event on a given calendar day.
-- server-side events (user_id IS NULL) are excluded.
--
-- used in analysis/dau_mau.sql to compute the engagement ratio.
-- if you want event-weighted activity instead of binary active/inactive,
-- swap COUNT(*) for the event_count column.

CREATE OR REPLACE VIEW user_activity_daily AS
SELECT
    account_id,
    user_id,
    DATE(created_at)    AS activity_date,
    COUNT(*)            AS event_count
FROM events
WHERE user_id IS NOT NULL
GROUP BY account_id, user_id, DATE(created_at);
