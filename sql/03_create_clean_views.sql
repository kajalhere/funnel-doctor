-- 03_create_clean_views.sql
-- Purpose: create cleaned versions of the raw tables as views (raw tables are not changed)
-- events_dedup: removes 7,720 exact duplicate events (same user, event and timestamp)
-- users_clean: fills missing device and city with 'Unknown' so no users are lost
-- Check: events_dedup should return 257,341 rows (265,061 - 7,720)

-- View 1: remove duplicate events 
-- Create a duplicate-free events view
CREATE VIEW events_dedup AS
SELECT user_id, event, event_time
FROM (
  SELECT user_id, event, event_time,
         ROW_NUMBER() OVER (
           PARTITION BY user_id, event, event_time
           ORDER BY user_id
         ) AS rn
  FROM events
) t
WHERE rn = 1;

SELECT COUNT(*) FROM events_dedup;

-- Fill the missing device and city
CREATE VIEW users_clean AS
SELECT user_id,
       COALESCE(device, 'Unknown') AS device,
       COALESCE(city, 'Unknown')   AS city,
       source, page_speed, first_visit
FROM users;


