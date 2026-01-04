-- =====================================================
-- STEP 3: DATA CLEANING & STANDARDIZATION
-- Project: Marketing Funnel & Cohort Analysis
-- Source Table: events_raw
-- =====================================================


-- 1. REMOVE RECORDS WITH CRITICAL NULL VALUES
-- These records cannot be used for funnel or cohort analysis
DELETE FROM events_raw
WHERE session_id IS NULL
   OR timestamp IS NULL
   OR event_type IS NULL;


-- 2. STANDARDIZE EVENT TYPES
-- Ensure consistency in funnel stage names
UPDATE events_raw
SET event_type = LOWER(TRIM(event_type));


-- 3. KEEP ONLY FUNNEL-RELEVANT EVENTS
-- Remove noise events not part of the purchase funnel
DELETE FROM events_raw
WHERE event_type NOT IN (
    'view',
    'add_to_cart',
    'checkout',
    'purchase'
);


-- 4. HANDLE NEGATIVE OR INVALID REVENUE VALUES
-- Revenue should not be negative
UPDATE events_raw
SET amount_usd = NULL
WHERE amount_usd < 0;


-- 5. REMOVE DUPLICATE EVENTS (IF ANY)
-- Keep the earliest occurrence per session, event type, and timestamp
DELETE FROM events_raw a
USING events_raw b
WHERE a.event_id > b.event_id
  AND a.session_id = b.session_id
  AND a.event_type = b.event_type
  AND a.timestamp = b.timestamp;


-- 6. ENSURE PURCHASE EVENTS HAVE REVENUE
-- Non-purchase events should not contribute revenue
UPDATE events_raw
SET amount_usd = NULL
WHERE event_type <> 'purchase';


-- 7. OPTIONAL DATA QUALITY CHECKS (SAFE TO RUN)
-- Check remaining row count
SELECT COUNT(*) AS remaining_rows FROM events_raw;

-- Check funnel distribution
SELECT
    event_type,
    COUNT(*) AS event_count
FROM events_raw
GROUP BY event_type
ORDER BY event_count DESC;
