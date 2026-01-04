
-- 1. TOTAL SESSIONS (BASELINE)
SELECT COUNT(DISTINCT session_id) AS total_sessions
FROM funnel_cohort_data;


-- 2. SESSIONS PER FUNNEL STAGE
SELECT
    event_type,
    COUNT(DISTINCT session_id) AS sessions
FROM funnel_cohort_data
GROUP BY event_type
ORDER BY sessions DESC;


-- 3. FUNNEL STEP COUNTS (ORDERED)
SELECT
    funnel_step,
    event_type,
    COUNT(DISTINCT session_id) AS sessions
FROM funnel_cohort_data
GROUP BY funnel_step, event_type
ORDER BY funnel_step;


-- 4. FUNNEL CONVERSION RATE (STAGE-WISE)
WITH stage_counts AS (
    SELECT
        funnel_step,
        COUNT(DISTINCT session_id) AS sessions
    FROM funnel_cohort_data
    GROUP BY funnel_step
)
SELECT
    funnel_step,
    sessions,
    ROUND(
        sessions * 100.0 /
        LAG(sessions) OVER (ORDER BY funnel_step),
        2
    ) AS conversion_rate_pct
FROM stage_counts
ORDER BY funnel_step;


-- 5. FUNNEL DROP-OFF RATE
WITH stage_counts AS (
    SELECT
        funnel_step,
        COUNT(DISTINCT session_id) AS sessions
    FROM funnel_cohort_data
    GROUP BY funnel_step
)
SELECT
    funnel_step,
    ROUND(
        100 -
        (sessions * 100.0 /
        LAG(sessions) OVER (ORDER BY funnel_step)),
        2
    ) AS dropoff_rate_pct
FROM stage_counts
ORDER BY funnel_step;


-- 6. TOTAL PURCHASES
SELECT COUNT(DISTINCT session_id) AS total_purchases
FROM funnel_cohort_data
WHERE event_type = 'purchase';


-- 7. TOTAL REVENUE
SELECT
    ROUND(SUM(amount_usd), 2) AS total_revenue
FROM funnel_cohort_data
WHERE event_type = 'purchase';


-- 8. AVERAGE ORDER VALUE (AOV)
SELECT
    ROUND(AVG(amount_usd), 2) AS avg_order_value
FROM funnel_cohort_data
WHERE event_type = 'purchase';


-- 9. REVENUE BY COHORT MONTH
SELECT
    cohort_month,
    ROUND(SUM(amount_usd), 2) AS revenue
FROM funnel_cohort_data
WHERE event_type = 'purchase'
GROUP BY cohort_month
ORDER BY cohort_month;


-- 10. COHORT SIZE (BASE)
SELECT
    cohort_month,
    COUNT(DISTINCT session_id) AS cohort_size
FROM funnel_cohort_data
GROUP BY cohort_month
ORDER BY cohort_month;


-- 11. COHORT ACTIVITY BY MONTH
SELECT
    cohort_month,
    DATE_TRUNC('month', timestamp) AS activity_month,
    COUNT(DISTINCT session_id) AS active_sessions
FROM funnel_cohort_data
GROUP BY cohort_month, activity_month
ORDER BY cohort_month, activity_month;


-- 12. COHORT RETENTION PERCENTAGE
WITH cohort_base AS (
    SELECT
        cohort_month,
        COUNT(DISTINCT session_id) AS cohort_size
    FROM funnel_cohort_data
    GROUP BY cohort_month
),
activity AS (
    SELECT
        cohort_month,
        DATE_TRUNC('month', timestamp) AS activity_month,
        COUNT(DISTINCT session_id) AS active_sessions
    FROM funnel_cohort_data
    GROUP BY cohort_month, activity_month
)
SELECT
    a.cohort_month,
    a.activity_month,
    ROUND(
        a.active_sessions * 100.0 / c.cohort_size,
        2
    ) AS retention_pct
FROM activity a
JOIN cohort_base c
ON a.cohort_month = c.cohort_month
ORDER BY a.cohort_month, a.activity_month;
