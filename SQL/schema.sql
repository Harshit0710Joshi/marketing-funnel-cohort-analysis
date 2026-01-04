DROP TABLE IF EXISTS events_raw;

CREATE TABLE events_raw (
    event_id BIGINT,
    session_id TEXT,
    timestamp TIMESTAMP,
    event_type TEXT,
    product_id BIGINT,
    qty INTEGER,
    cart_size INTEGER,
    payment TEXT,
    discount_pct NUMERIC(5,2),
    amount_usd NUMERIC(10,2)
);

DELETE FROM events_raw
WHERE session_id IS NULL
   OR timestamp IS NULL
   OR event_type IS NULL;

UPDATE events_raw
SET event_type = LOWER(TRIM(event_type));

DELETE FROM events_raw
WHERE event_type NOT IN ('view', 'add_to_cart', 'checkout', 'purchase');

CREATE OR REPLACE VIEW clean_events AS
SELECT
    session_id,
    timestamp,
    event_type,
    amount_usd,
    discount_pct
FROM events_raw;

CREATE OR REPLACE VIEW funnel_events AS
SELECT
    session_id,
    timestamp,
    event_type,
    CASE
        WHEN event_type = 'view' THEN 1
        WHEN event_type = 'add_to_cart' THEN 2
        WHEN event_type = 'checkout' THEN 3
        WHEN event_type = 'purchase' THEN 4
    END AS funnel_step,
    amount_usd
FROM clean_events;

CREATE OR REPLACE VIEW session_cohorts AS
SELECT
    session_id,
    DATE_TRUNC('month', MIN(timestamp)) AS cohort_month
FROM clean_events
GROUP BY session_id;

CREATE OR REPLACE VIEW funnel_cohort_data AS
SELECT
    f.session_id,
    f.timestamp,
    f.event_type,
    f.funnel_step,
    c.cohort_month,
    f.amount_usd
FROM funnel_events f
JOIN session_cohorts c
ON f.session_id = c.session_id;