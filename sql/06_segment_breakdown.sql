-- 06_segment_breakdown.sql
-- Purpose: compare funnel conversion by segment (device, source, page_speed, city)
-- Data: events_clean joined to users_clean
-- Finding (device): view->cart is similar on all devices (24-28%), 
--                   but checkout->pay is 42.5% on mobile vs 65.7% on desktop
-- Finding (page_speed): slow pages convert at 1.8% vs 3.8% for fast pages; 
--                       slow users drop more at every step (29.8% of visitors)
-- Finding (device + page_speed): both hurt independently. 
--        Mobile checkout->pay is 44.2% vs desktop 68.6% even on fast pages; 
--        slow pages lower it on both devices. Mobile+slow converts at 1.3% vs desktop+fast at 6.0%.
-- Note: tablet/Unknown slow groups have very few payments (25 and 12), so their rates are unreliable.
-- Finding (source): all sources convert at 3.1-3.5%; no meaningful difference.
-- Finding (city): all cities convert at 2.9-3.3%; Hyderabad slightly lower (checkout->pay 46.5%) but likely noise.
-- Conclusion: device and page_speed drive the drop-off; source and city do not.


-- Breaking the funnel down by Device
SELECT device, visits, views, carts, checkouts, payments,
       ROUND(100.0 * carts / views, 1)        AS view_to_cart_pct,
       ROUND(100.0 * payments / checkouts, 1) AS checkout_to_pay_pct,
       ROUND(100.0 * payments / visits, 1)    AS overall_conversion_pct
FROM (
  SELECT u.device,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'visit')           AS visits,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'view_product')    AS views,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'add_to_cart')     AS carts,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'start_checkout')  AS checkouts,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'payment_success') AS payments
  FROM events_clean e
  JOIN users_clean u ON u.user_id = e.user_id
  GROUP BY u.device
) t
ORDER BY visits DESC;

-- Breaking the funnel down by page_speed
SELECT page_speed, visits, views, carts, checkouts, payments,
       ROUND(100.0 * carts / views, 1)        AS view_to_cart_pct,
       ROUND(100.0 * payments / checkouts, 1) AS checkout_to_pay_pct,
       ROUND(100.0 * payments / visits, 1)    AS overall_conversion_pct
FROM (
  SELECT u.page_speed,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'visit')           AS visits,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'view_product')    AS views,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'add_to_cart')     AS carts,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'start_checkout')  AS checkouts,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'payment_success') AS payments
  FROM events_clean e
  JOIN users_clean u ON u.user_id = e.user_id
  GROUP BY u.page_speed
) t
ORDER BY visits DESC;

-- looking at device and page_speed together
SELECT device, page_speed, visits, payments,
       ROUND(100.0 * payments / checkouts, 1) AS checkout_to_pay_pct,
       ROUND(100.0 * payments / visits, 1)    AS overall_conversion_pct
FROM (
  SELECT u.device, u.page_speed,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'visit')           AS visits,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'start_checkout')  AS checkouts,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'payment_success') AS payments
  FROM events_clean e
  JOIN users_clean u ON u.user_id = e.user_id
  GROUP BY u.device, u.page_speed
) t
ORDER BY device, page_speed;

-- Breaking the funnel by source
SELECT source, visits, views, carts, checkouts, payments,
       ROUND(100.0 * carts / views, 1)        AS view_to_cart_pct,
       ROUND(100.0 * payments / checkouts, 1) AS checkout_to_pay_pct,
       ROUND(100.0 * payments / visits, 1)    AS overall_conversion_pct
FROM (
  SELECT u.source,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'visit')           AS visits,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'view_product')    AS views,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'add_to_cart')     AS carts,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'start_checkout')  AS checkouts,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'payment_success') AS payments
  FROM events_clean e
  JOIN users_clean u ON u.user_id = e.user_id
  GROUP BY u.source
) t
ORDER BY visits DESC;

-- Breaking the funnel by city
SELECT city, visits, views, carts, checkouts, payments,
       ROUND(100.0 * carts / views, 1)        AS view_to_cart_pct,
       ROUND(100.0 * payments / checkouts, 1) AS checkout_to_pay_pct,
       ROUND(100.0 * payments / visits, 1)    AS overall_conversion_pct
FROM (
  SELECT u.city,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'visit')           AS visits,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'view_product')    AS views,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'add_to_cart')     AS carts,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'start_checkout')  AS checkouts,
         COUNT(DISTINCT e.user_id) FILTER (WHERE e.event = 'payment_success') AS payments
  FROM events_clean e
  JOIN users_clean u ON u.user_id = e.user_id
  GROUP BY u.city
) t
ORDER BY visits DESC;