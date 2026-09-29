-- 02_data_quality_checks.sql
-- Purpose: profile the raw data before cleaning (read-only, no changes made)
-- Results (Sep 29, 2026): 265,061 events, 102,000 users, 7,720 duplicate rows

-- Size of the raw data
SELECT COUNT(*) AS total_events,
       COUNT(DISTINCT user_id) AS users_with_events
FROM events;

SELECT COUNT(*) AS total_users FROM users;

-- Events per type
SELECT event, COUNT(*) AS n
FROM events
GROUP BY event
ORDER BY n DESC;

-- Missing values
SELECT
  COUNT(*) FILTER (WHERE user_id IS NULL)    AS null_user,
  COUNT(*) FILTER (WHERE event IS NULL)      AS null_event,
  COUNT(*) FILTER (WHERE event_time IS NULL) AS null_time
FROM events;

SELECT
  COUNT(*) FILTER (WHERE device IS NULL)      AS null_device,
  COUNT(*) FILTER (WHERE city IS NULL)        AS null_city,
  COUNT(*) FILTER (WHERE source IS NULL)      AS null_source,
  COUNT(*) FILTER (WHERE page_speed IS NULL)  AS null_speed
FROM users;

-- Count duplicates
SELECT COUNT(*) AS duplicate_rows
FROM (
  SELECT ROW_NUMBER() OVER (
           PARTITION BY user_id, event, event_time
           ORDER BY user_id
         ) AS rn
  FROM events
) t
WHERE rn > 1;