-- Funnel Doctor: raw tables (run this while connected to the funnel_doctor database)
-- No primary key or NOT NULL rules on purpose: the raw data has duplicates and missing values,
-- and we clean it later in SQL.

DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id     INTEGER,
    device      TEXT,
    city        TEXT,
    source      TEXT,
    page_speed  TEXT,
    first_visit TIMESTAMP
);

CREATE TABLE events (
    user_id     INTEGER,
    event       TEXT,
    event_time  TIMESTAMP
);

-- After importing the CSV files, run these checks:
-- SELECT COUNT(*) FROM users;    -- expect 102000
-- SELECT COUNT(*) FROM events;   -- expect 265061
-- SELECT COUNT(*) FROM users WHERE city IS NULL;   -- expect 4059
-- SELECT COUNT(*) FROM users WHERE device IS NULL; -- expect 4028