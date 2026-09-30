-- 07_cohort_analysis.sql
-- Purpose: check return behavior and conversion stability by weekly signup cohort
-- Data: users_clean and events_clean (first_visit from 2026-07-01 to 2026-08-29)
-- Finding 1: only 842 of 100,000 users (0.8%) are active on more than one day, 
--          so retention analysis is limited (synthetic data has almost no repeat visits)
-- Finding 2: return rate is 0.77-0.89% in every weekly cohort; 
--            conversion is stable at 2.9-3.3% across cohorts (no time trend).
-- Note: first (2026-06-29) and last (2026-08-24) cohorts are partial weeks,so they have fewer users.

SELECT MIN(first_visit) AS first_date, MAX(first_visit) AS last_date
FROM users_clean;

SELECT COUNT(*) FILTER (WHERE active_days > 1) AS multi_day_users,
       COUNT(*) AS total_users
FROM (
  SELECT user_id, COUNT(DISTINCT event_time::date) AS active_days
  FROM events_clean
  GROUP BY user_id
) t;

SELECT DATE_TRUNC('week', u.first_visit)::date AS cohort_week,
       COUNT(*) AS users,
       COUNT(*) FILTER (WHERE r.active_days > 1) AS returning_users,
       ROUND(100.0 * COUNT(*) FILTER (WHERE r.active_days > 1) / COUNT(*), 2) AS return_pct,
       COUNT(*) FILTER (WHERE p.user_id IS NOT NULL) AS payers,
       ROUND(100.0 * COUNT(*) FILTER (WHERE p.user_id IS NOT NULL) / COUNT(*), 1) AS conversion_pct
FROM users_clean u
LEFT JOIN (
  SELECT user_id, COUNT(DISTINCT event_time::date) AS active_days
  FROM events_clean
  GROUP BY user_id
) r ON r.user_id = u.user_id
LEFT JOIN (
  SELECT DISTINCT user_id
  FROM events_clean
  WHERE event = 'payment_success'
) p ON p.user_id = u.user_id
GROUP BY 1
ORDER BY 1;