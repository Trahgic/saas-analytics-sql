# notes

things that aren't obvious from the DDL alone and will bite you if you don't know them.

---

## accounts.owner_id circular FK

`accounts.owner_id` references `users`, but `users.account_id` references `accounts`.
That's a real circular dependency. Handled by adding the FK as an `ALTER TABLE` in
`02_users.sql` after the users table exists. If you load schema files out of order,
it breaks. The load order in README.md exists for this reason.

---

## subscriptions: use both status AND cancelled_at, not just one

Don't filter only on `status = 'active'`. An account can have `status = 'active'`
with a future `cancelled_at` set — that's a scheduled cancellation. It's still
active today but ends at a known date.

The correct pattern for "currently active right now":
```sql
WHERE status = 'active' AND cancelled_at IS NULL
```

For "active on a specific date in the past":
```sql
WHERE started_at <= :target_date
  AND (cancelled_at IS NULL OR cancelled_at > :target_date)
```

Several analysis queries depend on this. If you add a query that only filters on
status, you'll silently over-count.

---

## invoices.amount_paid ≠ amount_due

Credits, failed then retried payments, and coupons mean these can diverge. All
revenue and LTV calculations in this project use `amount_paid`, not `amount_due`.

`amount_due` is what we asked for. `amount_paid` is what we collected.
Using `amount_due` for revenue will overstate actual collected revenue, sometimes significantly
if you have a meaningful failed payment rate.

---

## money is stored in cents (integer), not dollars (float)

All price and amount columns in this schema are cents as integers. Division by 100.0
converts to dollars in display queries. Never store dollars as FLOAT or DOUBLE —
floating point precision issues compound badly at scale when summing across millions
of invoices.

```sql
-- correct
ROUND(SUM(amount_paid) / 100.0, 2)  AS amount_usd

-- wrong — float precision will eventually miscount
SUM(amount_paid * 0.01)
```

---

## events table scale

The seed data has ~20 events. In a real deployment this table will be 100-1000x
larger than all other tables combined. A few things that matter because of that:

- Never `SELECT * FROM events` without a `WHERE` on `account_id` AND `created_at`.
  Full table scans here will be slow or timeout.
- The `idx_events_account_time` composite index is the most important index in the
  schema. Don't drop it, and keep it healthy with periodic VACUUM/ANALYZE (Postgres).
- If you add `JSONB` to `events.properties` on Postgres, add a GIN index on it
  before running property-level queries in production. A GIN-less JSONB query at
  scale is just a full scan with extra JSON parsing overhead.

---

## generate_series is Postgres-only

Three files use `generate_series`:
- `analysis/churn_rate.sql`
- `analysis/cohort_retention.sql`
- `seed/sample_data.sql` (for invoice generation)

**MySQL 8+:** use a recursive CTE or join against a pre-built calendar table.
**SQLite:** use a recursive CTE. Example drop-in for a month series:

```sql
WITH RECURSIVE months(m) AS (
    SELECT DATE('2024-01-01')
    UNION ALL
    SELECT DATE(m, '+1 month')
    FROM months
    WHERE m < DATE('now', 'start of month')
)
SELECT m FROM months;
```

This isn't implemented inline to keep the queries readable, but that's the pattern.

---

## free-tier accounts in MRR/churn queries

Free accounts (`price_monthly = 0`) are excluded from all MRR and churn calculations
throughout this project. They inflate account counts while contributing nothing to
revenue churn, which makes the percentage numbers misleading.

If you want to track free-to-paid upgrade rates, run that as a separate query
(see `trial_conversion.sql` for the general shape). Don't mix free accounts into
revenue metrics.

---

## cohort retention includes trialing accounts

`cohort_retention.sql` counts an account as "retained" if it has any subscription
row (including `trialing`) in a given month. If you want paid-only retention, add
a join to `plans` and filter `price_monthly > 0`, the same way `churn_rate.sql` does.

The tradeoff: including trials gives you a fuller picture of early engagement but
makes month-0 retention look artificially high if you have a long trial period.

---

## seed data is ~20 accounts, not 200

The README says "~200 accounts" because a real deployment would extend it.
The seed file has 20 accounts to keep it readable and runnable without a
data generator. For realistic volume testing, use something like `pgbench` or
a Python script with `faker` to generate bulk rows from the same schema.
