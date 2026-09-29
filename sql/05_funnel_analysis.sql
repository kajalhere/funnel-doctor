-- 05_funnel_analysis.sql
-- Purpose: measure how many users reach each funnel step and where they drop off
-- Funnel: visit -> view_product -> add_to_cart -> start_checkout -> payment_success
-- Data: events_clean (duplicates and bots already removed)
-- Method: COUNT(DISTINCT user_id) per step; LAG() compares each step with the previous one
-- Output: users per step, drop-off % from previous step, % of all visitors remaining
-- Finding: 100,000 visitors -> 3,181 payments (3.2%). 
--          Biggest drop: view_product -> add_to_cart (74.6% lost); 
--          start_checkout -> payment loses 48.5%.

-- Count users at each step
SELECT event, COUNT(DISTINCT user_id) AS users
FROM events_clean
GROUP BY event;

-- Funnel with drop-off %
WITH steps AS (
  SELECT event, COUNT(DISTINCT user_id) AS users
  FROM events_clean
  GROUP BY event
),
ordered AS (
  SELECT CASE event
           WHEN 'visit'           THEN 1
           WHEN 'view_product'    THEN 2
           WHEN 'add_to_cart'     THEN 3
           WHEN 'start_checkout'  THEN 4
           WHEN 'payment_success' THEN 5
         END AS step_no,
         event, users
  FROM steps
)
SELECT step_no, event, users,
       ROUND(100.0 * users / LAG(users) OVER (ORDER BY step_no), 1)
         AS pct_of_previous_step,
       ROUND(100.0 - 100.0 * users / LAG(users) OVER (ORDER BY step_no), 1)
         AS drop_off_pct,
       ROUND(100.0 * users / FIRST_VALUE(users) OVER (ORDER BY step_no), 1)
         AS pct_of_all_visitors
FROM ordered
ORDER BY step_no;