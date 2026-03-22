-- current MRR by plan.
-- free plan has price_monthly = 0 so it shows up with $0 MRR, which is intentional —
-- you can see free account volume without it inflating the revenue number.
--
-- this is a snapshot of right now. for historical MRR, see analysis/mrr_movement.sql.

CREATE OR REPLACE VIEW mrr_snapshot AS
SELECT
    p.name                                          AS plan_name,
    COUNT(DISTINCT s.account_id)                    AS account_count,
    SUM(s.seats)                                    AS total_seats,
    SUM(p.price_monthly * s.seats)                  AS mrr_cents,
    ROUND(SUM(p.price_monthly * s.seats) / 100.0, 2) AS mrr_usd
FROM subscriptions s
JOIN plans p ON p.id = s.plan_id
WHERE s.status = 'active'
  AND s.cancelled_at IS NULL
GROUP BY p.id, p.name, p.price_monthly
ORDER BY mrr_cents DESC;
