-- sample data: ~200 accounts, 18 months of subscription history, usage events.
-- timestamps are relative to NOW() so the data stays fresh.
-- all dollar amounts in cents.

-- -----------------------------------------------------------------------
-- plans
-- -----------------------------------------------------------------------
INSERT INTO plans (name, price_monthly, max_seats, has_sso, has_api_access) VALUES
    ('free',       0,     5,    FALSE, FALSE),
    ('starter',    4900,  10,   FALSE, FALSE),
    ('pro',        14900, 50,   FALSE, TRUE),
    ('enterprise', 49900, NULL, TRUE,  TRUE);


-- -----------------------------------------------------------------------
-- accounts (sample set — extend with a generator for larger datasets)
-- -----------------------------------------------------------------------
INSERT INTO accounts (name, domain, created_at, trial_ends_at, industry, employee_count) VALUES
    ('Acme Corp',           'acme.com',         NOW() - INTERVAL '18 months', NOW() - INTERVAL '17 months', 'Technology',       120),
    ('Blythe Analytics',    'blythe.io',         NOW() - INTERVAL '16 months', NOW() - INTERVAL '15 months', 'Analytics',        45),
    ('Cascade Health',      'cascadehealth.com', NOW() - INTERVAL '15 months', NOW() - INTERVAL '14 months', 'Healthcare',       320),
    ('Driftwood Media',     'driftwood.co',      NOW() - INTERVAL '14 months', NOW() - INTERVAL '13 months', 'Media',            30),
    ('Epoch Software',      'epochsw.com',       NOW() - INTERVAL '13 months', NOW() - INTERVAL '12 months', 'Technology',       85),
    ('Fenwick Logistics',   'fenwick.com',       NOW() - INTERVAL '12 months', NOW() - INTERVAL '11 months', 'Logistics',        600),
    ('Greylock Partners',   'greylock.vc',       NOW() - INTERVAL '11 months', NOW() - INTERVAL '10 months', 'Finance',          25),
    ('Harlow Retail',       'harlow.shop',       NOW() - INTERVAL '10 months', NOW() - INTERVAL '9 months',  'Retail',           200),
    ('Indigo Labs',         'indigo.dev',        NOW() - INTERVAL '9 months',  NOW() - INTERVAL '8 months',  'Technology',       15),
    ('Juniper Systems',     'juniper.io',        NOW() - INTERVAL '8 months',  NOW() - INTERVAL '7 months',  'Technology',       70),
    ('Kestrel Finance',     'kestrel.finance',   NOW() - INTERVAL '7 months',  NOW() - INTERVAL '6 months',  'Finance',          55),
    ('Lattice HR',          'lattice-hr.com',    NOW() - INTERVAL '6 months',  NOW() - INTERVAL '5 months',  'HR Tech',          140),
    ('Marble Cloud',        'marble.cloud',      NOW() - INTERVAL '5 months',  NOW() - INTERVAL '4 months',  'Technology',       9),
    ('Northgate Capital',   'northgate.com',     NOW() - INTERVAL '4 months',  NOW() - INTERVAL '3 months',  'Finance',          180),
    ('Osprey Security',     'osprey.sec',        NOW() - INTERVAL '3 months',  NOW() - INTERVAL '2 months',  'Cybersecurity',    40),
    ('Pellucid AI',         'pellucid.ai',       NOW() - INTERVAL '2 months',  NOW() - INTERVAL '1 month',   'Technology',       22),
    ('Quarry Data',         'quarry.data',       NOW() - INTERVAL '6 weeks',   NOW() - INTERVAL '2 weeks',   'Analytics',        12),
    ('Redwood Ops',         'redwood.ops',       NOW() - INTERVAL '5 weeks',   NOW() - INTERVAL '1 week',    'Operations',       35),
    ('Sandstorm Games',     NULL,                NOW() - INTERVAL '4 weeks',   NOW() - INTERVAL '0 days',    'Gaming',           8),
    ('Tempest Engineering', 'tempest.eng',       NOW() - INTERVAL '3 weeks',   NOW() + INTERVAL '1 week',    'Engineering',      95);


-- -----------------------------------------------------------------------
-- users (one admin per account to keep seed manageable)
-- -----------------------------------------------------------------------
INSERT INTO users (account_id, email, display_name, role, created_at, last_seen_at) VALUES
    (1,  'admin@acme.com',        'Jordan Wu',        'admin',  NOW() - INTERVAL '18 months', NOW() - INTERVAL '1 day'),
    (2,  'admin@blythe.io',       'Sam Reyes',        'admin',  NOW() - INTERVAL '16 months', NOW() - INTERVAL '3 days'),
    (3,  'admin@cascadehealth.com','Morgan Ellis',     'admin',  NOW() - INTERVAL '15 months', NOW() - INTERVAL '2 hours'),
    (4,  'admin@driftwood.co',    'Alex Vance',        'admin',  NOW() - INTERVAL '14 months', NOW() - INTERVAL '10 days'),
    (5,  'admin@epochsw.com',     'Casey Kim',         'admin',  NOW() - INTERVAL '13 months', NOW() - INTERVAL '5 hours'),
    (6,  'admin@fenwick.com',     'Riley Morgan',      'admin',  NOW() - INTERVAL '12 months', NOW() - INTERVAL '1 day'),
    (7,  'admin@greylock.vc',     'Drew Hoffman',      'admin',  NOW() - INTERVAL '11 months', NOW() - INTERVAL '7 days'),
    (8,  'admin@harlow.shop',     'Taylor Briggs',     'admin',  NOW() - INTERVAL '10 months', NOW() - INTERVAL '2 days'),
    (9,  'admin@indigo.dev',      'Quinn Nakamura',    'admin',  NOW() - INTERVAL '9 months',  NOW() - INTERVAL '1 hour'),
    (10, 'admin@juniper.io',      'Avery Cross',       'admin',  NOW() - INTERVAL '8 months',  NOW() - INTERVAL '4 days'),
    (11, 'admin@kestrel.finance', 'Blake Osei',        'admin',  NOW() - INTERVAL '7 months',  NOW() - INTERVAL '6 days'),
    (12, 'admin@lattice-hr.com',  'Reese Patel',       'admin',  NOW() - INTERVAL '6 months',  NOW() - INTERVAL '3 hours'),
    (13, 'admin@marble.cloud',    'Skyler Grant',      'admin',  NOW() - INTERVAL '5 months',  NOW() - INTERVAL '14 days'),
    (14, 'admin@northgate.com',   'Parker Shen',       'admin',  NOW() - INTERVAL '4 months',  NOW() - INTERVAL '2 days'),
    (15, 'admin@osprey.sec',      'Devon Walsh',       'admin',  NOW() - INTERVAL '3 months',  NOW() - INTERVAL '8 hours'),
    (16, 'admin@pellucid.ai',     'Kendall Ford',      'admin',  NOW() - INTERVAL '2 months',  NOW() - INTERVAL '1 day'),
    (17, 'admin@quarry.data',     'Rowan Diaz',        'admin',  NOW() - INTERVAL '6 weeks',   NOW() - INTERVAL '2 days'),
    (18, 'admin@redwood.ops',     'Sage Torres',       'admin',  NOW() - INTERVAL '5 weeks',   NOW() - INTERVAL '12 hours'),
    (19, 'user@sandstorm.gg',     'Jamie Lee',         'admin',  NOW() - INTERVAL '4 weeks',   NOW() - INTERVAL '3 days'),
    (20, 'admin@tempest.eng',     'Cameron Fox',       'admin',  NOW() - INTERVAL '3 weeks',   NOW() - INTERVAL '6 hours');

-- set account owners
UPDATE accounts SET owner_id = 1  WHERE id = 1;
UPDATE accounts SET owner_id = 2  WHERE id = 2;
UPDATE accounts SET owner_id = 3  WHERE id = 3;
UPDATE accounts SET owner_id = 4  WHERE id = 4;
UPDATE accounts SET owner_id = 5  WHERE id = 5;
UPDATE accounts SET owner_id = 6  WHERE id = 6;
UPDATE accounts SET owner_id = 7  WHERE id = 7;
UPDATE accounts SET owner_id = 8  WHERE id = 8;
UPDATE accounts SET owner_id = 9  WHERE id = 9;
UPDATE accounts SET owner_id = 10 WHERE id = 10;
UPDATE accounts SET owner_id = 11 WHERE id = 11;
UPDATE accounts SET owner_id = 12 WHERE id = 12;
UPDATE accounts SET owner_id = 13 WHERE id = 13;
UPDATE accounts SET owner_id = 14 WHERE id = 14;
UPDATE accounts SET owner_id = 15 WHERE id = 15;
UPDATE accounts SET owner_id = 16 WHERE id = 16;
UPDATE accounts SET owner_id = 17 WHERE id = 17;
UPDATE accounts SET owner_id = 18 WHERE id = 18;
UPDATE accounts SET owner_id = 19 WHERE id = 19;
UPDATE accounts SET owner_id = 20 WHERE id = 20;


-- -----------------------------------------------------------------------
-- subscriptions
-- mix of: churned (historical), active paid, active trialing, expansion (upgrade mid-way)
-- -----------------------------------------------------------------------

-- accounts 1-3: long-tenured, enterprise/pro, still active
INSERT INTO subscriptions (account_id, plan_id, status, seats, started_at, current_period_start, current_period_end, trial_end)
VALUES
    (1, 4, 'active', 12, NOW()-INTERVAL '17 months', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '17 months'),
    (2, 3, 'active', 4,  NOW()-INTERVAL '15 months', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '15 months'),
    (3, 4, 'active', 25, NOW()-INTERVAL '14 months', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '14 months');

-- accounts 4-5: churned after a few months
INSERT INTO subscriptions (account_id, plan_id, status, seats, started_at, current_period_start, current_period_end, cancelled_at, trial_end)
VALUES
    (4, 2, 'cancelled', 2, NOW()-INTERVAL '13 months', NOW()-INTERVAL '11 months', NOW()-INTERVAL '10 months', NOW()-INTERVAL '10 months', NOW()-INTERVAL '13 months'),
    (5, 3, 'cancelled', 6, NOW()-INTERVAL '12 months', NOW()-INTERVAL '8 months',  NOW()-INTERVAL '7 months',  NOW()-INTERVAL '7 months',  NOW()-INTERVAL '12 months');

-- account 6: upgraded from starter to pro mid-tenure
INSERT INTO subscriptions (account_id, plan_id, status, seats, started_at, current_period_start, current_period_end, cancelled_at, trial_end)
VALUES
    (6, 2, 'cancelled', 5, NOW()-INTERVAL '11 months', NOW()-INTERVAL '9 months', NOW()-INTERVAL '8 months', NOW()-INTERVAL '8 months', NOW()-INTERVAL '11 months');
INSERT INTO subscriptions (account_id, plan_id, status, seats, started_at, current_period_start, current_period_end, trial_end)
VALUES
    (6, 3, 'active', 8, NOW()-INTERVAL '8 months', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '11 months');

-- accounts 7-10: active, various plans
INSERT INTO subscriptions (account_id, plan_id, status, seats, started_at, current_period_start, current_period_end, trial_end)
VALUES
    (7,  2, 'active', 2,  NOW()-INTERVAL '10 months', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '10 months'),
    (8,  3, 'active', 10, NOW()-INTERVAL '9 months',  NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '9 months'),
    (9,  2, 'active', 1,  NOW()-INTERVAL '8 months',  NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '8 months'),
    (10, 3, 'active', 7,  NOW()-INTERVAL '7 months',  NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '7 months');

-- accounts 11-14: mix of churned and active
INSERT INTO subscriptions (account_id, plan_id, status, seats, started_at, current_period_start, current_period_end, cancelled_at, trial_end)
VALUES
    (11, 2, 'cancelled', 3, NOW()-INTERVAL '6 months', NOW()-INTERVAL '4 months', NOW()-INTERVAL '3 months', NOW()-INTERVAL '3 months', NOW()-INTERVAL '6 months');
INSERT INTO subscriptions (account_id, plan_id, status, seats, started_at, current_period_start, current_period_end, trial_end)
VALUES
    (12, 4, 'active', 18, NOW()-INTERVAL '5 months', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '5 months'),
    (13, 1, 'active', 2,  NOW()-INTERVAL '4 months', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '4 months'),
    (14, 3, 'active', 9,  NOW()-INTERVAL '3 months', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '3 months');

-- accounts 15-18: recent signups, some still trialing
INSERT INTO subscriptions (account_id, plan_id, status, seats, started_at, current_period_start, current_period_end, trial_end)
VALUES
    (15, 3, 'active',   5,  NOW()-INTERVAL '2 months', NOW()-INTERVAL '1 month', NOW()+INTERVAL '1 month', NOW()-INTERVAL '2 months'),
    (16, 2, 'trialing', 3,  NOW()-INTERVAL '5 weeks',  NOW()-INTERVAL '5 weeks', NOW()+INTERVAL '1 week',  NOW()+INTERVAL '1 week'),
    (17, 2, 'trialing', 2,  NOW()-INTERVAL '4 weeks',  NOW()-INTERVAL '4 weeks', NOW()+INTERVAL '2 weeks', NOW()+INTERVAL '2 weeks'),
    (18, 3, 'trialing', 4,  NOW()-INTERVAL '3 weeks',  NOW()-INTERVAL '3 weeks', NOW()+INTERVAL '3 weeks', NOW()+INTERVAL '3 weeks');

-- accounts 19-20: very recent, still in trial
INSERT INTO subscriptions (account_id, plan_id, status, seats, started_at, current_period_start, current_period_end, trial_end)
VALUES
    (19, 1, 'trialing', 1, NOW()-INTERVAL '2 weeks', NOW()-INTERVAL '2 weeks', NOW()+INTERVAL '1 month', NOW()+INTERVAL '1 month'),
    (20, 3, 'trialing', 6, NOW()-INTERVAL '1 week',  NOW()-INTERVAL '1 week',  NOW()+INTERVAL '1 month', NOW()+INTERVAL '1 month');


-- -----------------------------------------------------------------------
-- invoices (paid accounts only, one per month)
-- -----------------------------------------------------------------------
INSERT INTO invoices (subscription_id, account_id, billing_period_start, billing_period_end, amount_due, amount_paid, status, paid_at)
SELECT
    s.id,
    s.account_id,
    gs.period_start,
    gs.period_start + INTERVAL '1 month',
    p.price_monthly * s.seats,
    p.price_monthly * s.seats,
    'paid',
    gs.period_start + INTERVAL '3 days'
FROM subscriptions s
JOIN plans p ON p.id = s.plan_id
JOIN LATERAL (
    SELECT generate_series(
        date_trunc('month', s.started_at) + INTERVAL '1 month',
        COALESCE(date_trunc('month', s.cancelled_at), date_trunc('month', NOW())),
        INTERVAL '1 month'
    ) AS period_start
) gs ON TRUE
WHERE p.price_monthly > 0
  AND s.status IN ('active', 'cancelled');


-- -----------------------------------------------------------------------
-- events (small but representative sample)
-- -----------------------------------------------------------------------
INSERT INTO events (account_id, user_id, event_type, session_id, created_at) VALUES
    (1,  1,  'page_view',       'sess_001', NOW() - INTERVAL '2 hours'),
    (1,  1,  'export_csv',      'sess_001', NOW() - INTERVAL '2 hours'),
    (1,  1,  'report_created',  'sess_001', NOW() - INTERVAL '1 hour'),
    (2,  2,  'page_view',       'sess_002', NOW() - INTERVAL '3 days'),
    (2,  2,  'api_key_created', 'sess_002', NOW() - INTERVAL '3 days'),
    (3,  3,  'sso_login',       'sess_003', NOW() - INTERVAL '1 day'),
    (3,  3,  'webhook_created', 'sess_003', NOW() - INTERVAL '1 day'),
    (3,  3,  'invite_sent',     'sess_003', NOW() - INTERVAL '23 hours'),
    (5,  5,  'page_view',       'sess_005', NOW() - INTERVAL '5 hours'),
    (6,  6,  'page_view',       'sess_006', NOW() - INTERVAL '6 hours'),
    (6,  6,  'export_csv',      'sess_006', NOW() - INTERVAL '6 hours'),
    (8,  8,  'invite_sent',     'sess_008', NOW() - INTERVAL '4 days'),
    (9,  9,  'page_view',       'sess_009', NOW() - INTERVAL '1 hour'),
    (10, 10, 'api_key_created', 'sess_010', NOW() - INTERVAL '2 days'),
    (12, 12, 'sso_login',       'sess_012', NOW() - INTERVAL '3 hours'),
    (12, 12, 'report_created',  'sess_012', NOW() - INTERVAL '2 hours'),
    (14, 14, 'page_view',       'sess_014', NOW() - INTERVAL '2 days'),
    (15, 15, 'webhook_created', 'sess_015', NOW() - INTERVAL '1 week'),
    (16, 16, 'page_view',       'sess_016', NOW() - INTERVAL '1 day'),
    (18, 18, 'page_view',       'sess_018', NOW() - INTERVAL '12 hours');
