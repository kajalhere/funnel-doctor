-- 04_bot_detection.sql
-- Purpose: find bot-like users by behavior and build final clean views
-- Finding: real users have 1-5 events; about 2,000 users have 20-60 events (none between 6 and 19)
-- Rule: users with more than 10 events (after removing duplicates) are flagged as bots
-- bot_users: list of flagged users (expected: 2,000)
-- events_clean / users_clean: exclude bots (expected: 100,000 users)

-- Look for bot behavior
SELECT user_id, COUNT(*) AS n_events
FROM events_dedup
GROUP BY user_id
ORDER BY n_events DESC
LIMIT 20;

SELECT n_events, COUNT(*) AS users
FROM (
  SELECT user_id, COUNT(*) AS n_events
  FROM events_dedup
  GROUP BY user_id
) t
GROUP BY n_events
ORDER BY n_events;

-- Flag the bots
CREATE VIEW bot_users AS
SELECT user_id
FROM events_dedup
GROUP BY user_id
HAVING COUNT(*) > 10;

SELECT COUNT(*) FROM bot_users;

-- Build the final clean views
CREATE VIEW events_clean AS
SELECT *
FROM events_dedup
WHERE user_id NOT IN (SELECT user_id FROM bot_users);

CREATE OR REPLACE VIEW users_clean AS
SELECT user_id,
       COALESCE(device, 'Unknown') AS device,
       COALESCE(city, 'Unknown')   AS city,
       source, page_speed, first_visit
FROM users
WHERE user_id NOT IN (SELECT user_id FROM bot_users);

-- Check the final result
SELECT COUNT(*) AS clean_events,
       COUNT(DISTINCT user_id) AS clean_users
FROM events_clean;

SELECT COUNT(*) FROM users_clean;