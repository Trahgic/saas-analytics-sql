# saas-analytics-sql

SQL analytics layer for a multi-tenant B2B SaaS product. Schema covers accounts, users, subscriptions, billing, and product usage events. Analysis covers the metrics that actually come up in SaaS — MRR movement, cohort retention, trial conversion, feature adoption, LTV.

Written in standard SQL. Tested against PostgreSQL 15. Most queries run in MySQL 8+ and SQLite with minor adjustments noted inline where dialects diverge.

---

## Structure

```
schema/      table definitions + indexes
seed/        sample data for local testing (~200 accounts, 18 months of history)
views/       reusable views used as bases in analysis queries
analysis/    the actual metric queries
notes.md     data model gotchas worth knowing before extending this
```

## Running locally (Postgres)

```bash
# create the database
createdb saas_analytics

# load schema in order — some files have FK dependencies
psql saas_analytics -f schema/01_accounts.sql
psql saas_analytics -f schema/02_users.sql
psql saas_analytics -f schema/03_plans.sql
psql saas_analytics -f schema/04_subscriptions.sql
psql saas_analytics -f schema/05_events.sql
psql saas_analytics -f schema/06_invoices.sql
psql saas_analytics -f schema/indexes.sql

# load sample data
psql saas_analytics -f seed/sample_data.sql

# create views
psql saas_analytics -f views/active_subscriptions.sql
psql saas_analytics -f views/mrr_snapshot.sql
psql saas_analytics -f views/user_activity_daily.sql
```

## Metrics covered

| Query | File |
|---|---|
| MRR snapshot by plan | `views/mrr_snapshot.sql` |
| MRR movement (new / expansion / contraction / churn) | `analysis/mrr_movement.sql` |
| Monthly account + revenue churn rate | `analysis/churn_rate.sql` |
| Cohort retention by signup month | `analysis/cohort_retention.sql` |
| Trial-to-paid conversion by cohort | `analysis/trial_conversion.sql` |
| Feature adoption (last 30 days) | `analysis/feature_adoption.sql` |
| LTV by plan (realized vs. projected) | `analysis/ltv_by_plan.sql` |
| DAU/MAU engagement ratio | `analysis/dau_mau.sql` |

## A note on LTV

`ltv_by_plan.sql` shows both backward-looking realized LTV (actual revenue from churned accounts) and forward-projected LTV (ARPU / monthly churn rate). The gap between the two is usually instructive.

---

See `notes.md` for known edge cases and schema decisions that aren't obvious from the DDL alone.
