
--1. Create mock tables


--Users table
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY,
    country TEXT,
    registration_date DATE
);

-- Events table
CREATE TABLE events (
    event_id INTEGER PRIMARY KEY,
    user_id INTEGER,
    event_time TIMESTAMP,
    event_type TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);



--2. Insert sample data


INSERT INTO users (user_id, country, registration_date) VALUES
(1, 'Lithuania', '2025-01-05'),
(2, 'Germany',  '2025-01-10'),
(3, 'Lithuania', '2025-02-01'),
(4, 'France',   '2025-02-15');

INSERT INTO events (event_id, user_id, event_time, event_type) VALUES
(101, 1, '2025-03-01 12:00', 'view_item'),
(102, 1, '2025-03-01 12:05', 'add_to_cart'),
(103, 1, '2025-03-01 12:10', 'purchase'),

(104, 2, '2025-03-02 15:00', 'view_item'),
(105, 2, '2025-03-02 15:10', 'view_item'),

(106, 3, '2025-03-03 09:00', 'view_item'),
(107, 3, '2025-03-03 09:05', 'add_to_cart'),
(108, 3, '2025-03-03 09:15', 'purchase'),

(109, 4, '2025-03-04 10:00', 'view_item');



-- 3. Simple analytics query:
--    Conversion rate per country


WITH activity AS (
    SELECT
        u.country,
        e.user_id,
        COUNT(*) FILTER (WHERE e.event_type = 'view_item') AS views,
        COUNT(*) FILTER (WHERE e.event_type = 'add_to_cart') AS carts,
        COUNT(*) FILTER (WHERE e.event_type = 'purchase') AS purchases
    FROM users u
    LEFT JOIN events e ON u.user_id = e.user_id
    GROUP BY u.country, e.user_id
),

metrics AS (
    SELECT
        country,
        COUNT(DISTINCT user_id) AS active_users,
        COUNT(*) FILTER (WHERE purchases > 0) AS buyers
    FROM activity
    GROUP BY country
)

SELECT
    country,
    active_users,
    buyers,
    ROUND(buyers * 1.0 / active_users, 3) AS conversion_rate
FROM metrics
ORDER BY conversion_rate DESC;
