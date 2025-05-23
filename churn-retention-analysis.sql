-- DAU
SELECT 
  EXTRACT(MONTH FROM start_session_date) AS month,
  COUNT(DISTINCT user_id) AS MAU
FROM `sqlfinal-447808.game_dataset.session_start`
GROUP BY month
ORDER BY month ASC

-- MAU
SELECT 
  EXTRACT(MONTH FROM start_session_date) AS month,
  COUNT(DISTINCT user_id) AS MAU
FROM `sqlfinal-447808.game_dataset.session_start`
GROUP BY month
ORDER BY month ASC

-- daily_install
SELECT 
  install_date,
  COUNT(DISTINCT user_id) AS daily_install
FROM `sqlfinal-447808.game_dataset.user_install`
WHERE install_date BETWEEN '2018-06-12' AND '2018-10-03'
GROUP BY install_date
ORDER BY install_date ASC

-- monthly_install
SELECT 
  EXTRACT(MONTH FROM install_date) AS month,
  COUNT(DISTINCT user_id) AS monthly_install
FROM `sqlfinal-447808.game_dataset.user_install`
WHERE install_date BETWEEN '2018-06-12' AND '2018-10-03'
GROUP BY month
ORDER BY month ASC

-- Retention after 14 days tháng 6
WITH installs AS (
  SELECT
    user_id,
    install_date
  FROM `sqlfinal-447808.game_dataset.user_install`
  WHERE install_date BETWEEN '2018-06-12' AND '2018-06-30'
),
daily_install AS (
  SELECT
    install_date,
    COUNT(DISTINCT user_id) AS num_installer
  FROM installs
  GROUP BY install_date
),
sessions AS (
  SELECT
    user_id,
    start_session_date
  FROM `sqlfinal-447808.game_dataset.session_start`
  WHERE start_session_date BETWEEN '2018-06-12' AND '2018-07-14'
),
day_after AS (
  SELECT DISTINCT
    i.user_id,
    i.install_date,
    DATE_DIFF(s.start_session_date, i.install_date, DAY) AS days_after_install
  FROM installs i
  JOIN sessions s ON i.user_id = s.user_id
  WHERE s.start_session_date >= i.install_date
),
retention_raw AS (
  SELECT
    install_date,
    days_after_install,
    COUNT(DISTINCT user_id) AS active_users
  FROM day_after
  GROUP BY install_date, days_after_install
)

SELECT
  r.install_date,
  r.days_after_install,
  r.active_users,
  c.num_installer,
  ROUND(100 * r.active_users / c.num_installer, 1) AS retention_rate
FROM retention_raw r
JOIN daily_install c ON r.install_date = c.install_date
WHERE r.days_after_install <= 14
ORDER BY r.install_date, r.days_after_install

--- retention rate 2 week AVG
WITH installs AS (
  SELECT
    user_id,
    install_date
  FROM `sqlfinal-447808.game_dataset.user_install`
  WHERE install_date BETWEEN '2018-06-12' AND '2018-09-20'
),
daily_install AS (
  SELECT
    install_date,
    COUNT(DISTINCT user_id) AS num_installer
  FROM installs
  GROUP BY install_date
),
sessions AS (
  SELECT
    user_id,
    start_session_date
  FROM `sqlfinal-447808.game_dataset.session_start`
  WHERE start_session_date BETWEEN '2018-06-12' AND '2018-10-03'
),
day_after AS (
  SELECT DISTINCT
    i.user_id,
    i.install_date,
    DATE_DIFF(s.start_session_date, i.install_date, DAY) AS days_after_install
  FROM installs i
  JOIN sessions s ON i.user_id = s.user_id
  WHERE s.start_session_date >= i.install_date
),
retention_raw AS (
  SELECT
    install_date,
    days_after_install,
    COUNT(DISTINCT user_id) AS active_users
  FROM day_after
  GROUP BY install_date, days_after_install
),
retention_joined AS (
  SELECT
    r.install_date,
    r.days_after_install,
    r.active_users,
    d.num_installer,
    100 * r.active_users / d.num_installer AS retention_rate
  FROM retention_raw r
  JOIN daily_install d ON r.install_date = d.install_date
  WHERE r.days_after_install <= 14
)
SELECT
  days_after_install,
  ROUND(AVG(retention_rate), 2) AS avg_retention_rate
FROM retention_joined
GROUP BY days_after_install
ORDER BY days_after_install;

-- retention rate by Month
WITH installs AS (
  SELECT
    user_id,
    install_date,
    FORMAT_DATE('%Y-%m', install_date) AS install_month
  FROM `sqlfinal-447808.game_dataset.user_install`
  WHERE install_date BETWEEN '2018-06-01' AND '2018-10-31'
),
daily_install AS (
  SELECT
    install_month,
    COUNT(DISTINCT user_id) AS num_installer
  FROM installs
  GROUP BY install_month
),
sessions AS (
  SELECT
    user_id,
    start_session_date,
    FORMAT_DATE('%Y-%m', start_session_date) AS session_month
  FROM `sqlfinal-447808.game_dataset.session_start`
  WHERE start_session_date BETWEEN '2018-06-01' AND '2018-12-31'
),
month_diff AS (
  SELECT DISTINCT
    i.user_id,
    i.install_month,
    s.session_month,
    DATE_DIFF(PARSE_DATE('%Y-%m', s.session_month), PARSE_DATE('%Y-%m', i.install_month), MONTH) AS months_after_install
  FROM installs i
  JOIN sessions s ON i.user_id = s.user_id
  WHERE s.start_session_date >= i.install_date
),
retention_raw AS (
  SELECT
    install_month,
    months_after_install,
    COUNT(DISTINCT user_id) AS active_users
  FROM month_diff
  GROUP BY install_month, months_after_install
)

SELECT
  r.install_month,
  r.months_after_install,
  r.active_users,
  c.num_installer,
  ROUND(100 * r.active_users / c.num_installer, 1) AS retention_rate
FROM retention_raw r
JOIN daily_install c ON r.install_month = c.install_month
WHERE r.months_after_install <= 4
ORDER BY r.install_month, r.months_after_install

--- churn after 3-7-14-30 days of từng tháng
WITH installs AS (
  SELECT
    user_id,
    install_date
  FROM `sqlfinal-447808.game_dataset.user_install`
  WHERE install_date BETWEEN '2018-08-01' AND '2018-08-30'
),
daily_install AS (
  SELECT
    install_date,
    COUNT(DISTINCT user_id) AS total_users
  FROM installs
  GROUP BY install_date
),
sessions AS (
  SELECT
    user_id,
    start_session_date
  FROM `sqlfinal-447808.game_dataset.session_start`
  WHERE start_session_date BETWEEN '2018-08-01' AND '2018-10-01'
),
day_x_active AS (
  SELECT
    i.install_date,
    MIN(DATE_DIFF(s.start_session_date, i.install_date, DAY)) AS first_session_after_install,
    i.user_id
  FROM installs i
  JOIN sessions s ON i.user_id = s.user_id
  WHERE s.start_session_date >= i.install_date
  GROUP BY i.install_date, i.user_id
),
retention_summary AS (
  SELECT
    i.install_date,
    COUNT(DISTINCT CASE WHEN d.first_session_after_install >= 3 THEN d.user_id END) AS active_day_3,
    COUNT(DISTINCT CASE WHEN d.first_session_after_install >= 7 THEN d.user_id END) AS active_day_7,
    COUNT(DISTINCT CASE WHEN d.first_session_after_install >= 14 THEN d.user_id END) AS active_day_14,
    COUNT(DISTINCT CASE WHEN d.first_session_after_install >= 30 THEN d.user_id END) AS active_day_30
  FROM installs i
  LEFT JOIN day_x_active d ON i.user_id = d.user_id AND i.install_date = d.install_date
  GROUP BY i.install_date
)

SELECT
  r.install_date,
  d.total_users,
  ROUND(100 - 100 * r.active_day_3 / d.total_users, 1) AS churn_day_3,
  ROUND(100 - 100 * r.active_day_7 / d.total_users, 1) AS churn_day_7,
  ROUND(100 - 100 * r.active_day_14 / d.total_users, 1) AS churn_day_14,
  ROUND(100 - 100 * r.active_day_30 / d.total_users, 1) AS churn_day_30
FROM retention_summary r
JOIN daily_install d ON r.install_date = d.install_date
ORDER BY r.install_date;

--- average churn theo month 
WITH installs AS (
  SELECT
    user_id,
    install_date,
    FORMAT_DATE('%Y-%m', install_date) AS install_month
  FROM `sqlfinal-447808.game_dataset.user_install`
  WHERE install_date BETWEEN '2018-06-01' AND '2018-08-30'
),

monthly_install_count AS (
  SELECT
    install_month,
    COUNT(DISTINCT user_id) AS total_users
  FROM installs
  GROUP BY install_month
),

sessions AS (
  SELECT
    user_id,
    start_session_date
  FROM `sqlfinal-447808.game_dataset.session_start`
  WHERE start_session_date BETWEEN '2018-06-01' AND '2018-10-03'
),

first_activity_diff AS (
  SELECT
    i.user_id,
    i.install_date,
    FORMAT_DATE('%Y-%m', i.install_date) AS install_month,
    MIN(DATE_DIFF(s.start_session_date, i.install_date, DAY)) AS first_session_after_install
  FROM installs i
  JOIN sessions s ON i.user_id = s.user_id
  WHERE s.start_session_date >= i.install_date
  GROUP BY i.user_id, i.install_date
),

monthly_churn_calc AS (
  SELECT
    i.install_month,
    COUNT(DISTINCT CASE WHEN f.first_session_after_install >= 3 THEN f.user_id END) AS active_day_3,
    COUNT(DISTINCT CASE WHEN f.first_session_after_install >= 7 THEN f.user_id END) AS active_day_7,
    COUNT(DISTINCT CASE WHEN f.first_session_after_install >= 14 THEN f.user_id END) AS active_day_14,
    COUNT(DISTINCT CASE WHEN f.first_session_after_install >= 30 THEN f.user_id END) AS active_day_30
  FROM installs i
  LEFT JOIN first_activity_diff f
    ON i.user_id = f.user_id AND i.install_date = f.install_date
  GROUP BY i.install_month
)

SELECT
  m.install_month,
  i.total_users,
  ROUND(100 - 100 * m.active_day_3 / i.total_users, 1) AS churn_day_3,
  ROUND(100 - 100 * m.active_day_7 / i.total_users, 1) AS churn_day_7,
  ROUND(100 - 100 * m.active_day_14 / i.total_users, 1) AS churn_day_14,
  ROUND(100 - 100 * m.active_day_30 / i.total_users, 1) AS churn_day_30
FROM monthly_churn_calc m
JOIN monthly_install_count i ON m.install_month = i.install_month
ORDER BY m.install_month;


-- 
WITH installs AS (
  SELECT
    user_id,
    install_date
  FROM `sqlfinal-447808.game_dataset.user_install`
  WHERE install_date BETWEEN '2018-06-12' AND '2018-06-30'
),
daily_install AS (
  SELECT
    install_date,
    COUNT(DISTINCT user_id) AS total_users
  FROM installs
  GROUP BY install_date
),
sessions AS (
  SELECT
    user_id,
    start_session_date
  FROM `sqlfinal-447808.game_dataset.session_start`
  WHERE start_session_date BETWEEN '2018-06-12' AND '2018-10-01'
),
day_x_active AS (
  SELECT
    i.install_date,
    MIN(DATE_DIFF(s.start_session_date, i.install_date, DAY)) AS first_session_after_install,
    i.user_id
  FROM installs i
  JOIN sessions s ON i.user_id = s.user_id
  WHERE s.start_session_date >= i.install_date
  GROUP BY i.install_date, i.user_id
),
retention_summary AS (
  SELECT
    i.install_date,
    COUNT(DISTINCT CASE WHEN d.first_session_after_install >= 3 THEN d.user_id END) AS active_day_3,
    COUNT(DISTINCT CASE WHEN d.first_session_after_install >= 7 THEN d.user_id END) AS active_day_7,
    COUNT(DISTINCT CASE WHEN d.first_session_after_install >= 14 THEN d.user_id END) AS active_day_14,
    COUNT(DISTINCT CASE WHEN d.first_session_after_install >= 30 THEN d.user_id END) AS active_day_30
  FROM installs i
  LEFT JOIN day_x_active d ON i.user_id = d.user_id AND i.install_date = d.install_date
  GROUP BY i.install_date
)

SELECT
  r.install_date,
  d.total_users,
  ROUND(100 - 100 * r.active_day_3 / d.total_users, 1) AS churn_day_3,
  ROUND(100 - 100 * r.active_day_7 / d.total_users, 1) AS churn_day_7,
  ROUND(100 - 100 * r.active_day_14 / d.total_users, 1) AS churn_day_14,
  ROUND(100 - 100 * r.active_day_30 / d.total_users, 1) AS churn_day_30
FROM retention_summary r
JOIN daily_install d ON r.install_date = d.install_date
ORDER BY r.install_date;


-- remove app 
SELECT
  app_version,
  platform,
  COUNT(*) AS num_remove
FROM `sqlfinal-447808.game_dataset.remove_app`
GROUP BY 1,2
ORDER BY 3 DESC


-- lần cuối chơi trước khi remove cách bao lâu 
WITH last_session AS (
  SELECT
    user_id,
    MAX(start_session_date) AS last_play_date
  FROM `sqlfinal-447808.game_dataset.session_start`
  GROUP BY user_id
),

removal_summary AS (
  SELECT
    r.user_id,
    r.remove_date,
    l.last_play_date,
    DATE_DIFF(r.remove_date, l.last_play_date, DAY) AS days_after_last_play
  FROM `sqlfinal-447808.game_dataset.remove_app` r
  LEFT JOIN last_session l ON r.user_id = l.user_id
  WHERE l.last_play_date IS NOT NULL
)

SELECT
  days_after_last_play,
  COUNT(*) AS num_remove
FROM removal_summary
GROUP BY days_after_last_play
ORDER BY 2 desc
limit 15;

-- churn sau 1 ngày là khá nhiều, check xem trung bình chơi bn level thì bỏ app
WITH user_first_last_day AS (
  SELECT
    user_pseudo_id,
    DATE(TIMESTAMP_MICROS(MIN(user_first_touch_timestamp))) AS first_day,
    DATE(TIMESTAMP_MICROS(MAX(event_timestamp))) AS last_day
  FROM `firebase-public-project.analytics_153293282.events_2018*`
  GROUP BY user_pseudo_id
),

churned_users AS (
  SELECT
    ufl.user_pseudo_id
  FROM user_first_last_day ufl
  WHERE DATE_DIFF(ufl.last_day, ufl.first_day, DAY) <= 1
),

level_events AS (
  SELECT
    e.user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_2018*` e
  WHERE e.event_name IN ('level_complete', 'level_complete_quickplay')
),
churn_total_complete as (
SELECT
  le.user_pseudo_id,
  COUNT(*) AS total_level_completions
FROM level_events le
JOIN churned_users cu
  ON le.user_pseudo_id = cu.user_pseudo_id
where le.user_pseudo_id not in ('669A7F5B42DA742CA6BD9734ADEF09D4')
GROUP BY le.user_pseudo_id
ORDER BY total_level_completions DESC
)
select avg(total_level_completions)
from churn_total_complete
