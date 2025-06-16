-- remove_app 

WITH removals AS (
  SELECT
    user_pseudo_id,
    MAX(event_timestamp) AS remove_time,
    platform,
    app_info.version as app_version
  FROM `firebase-public-project.analytics_153293282.events_2018*`
  WHERE event_name = 'app_remove'
  GROUP BY 1,3,4
),


events_after_removal AS (
  SELECT DISTINCT e.user_pseudo_id
  FROM `firebase-public-project.analytics_153293282.events_2018*` e
  JOIN removals r
    ON e.user_pseudo_id = r.user_pseudo_id
  WHERE e.event_timestamp > r.remove_time
)


SELECT
  r.user_pseudo_id AS user_id,
  DATE(TIMESTAMP_MICROS(r.remove_time)) AS remove_date,
  FORMAT_TIME('%H:%M:%S', TIME(TIMESTAMP_MICROS(r.remove_time))) AS remove_time,
  r.platform,
  r.app_version
FROM removals r
LEFT JOIN events_after_removal e
  ON r.user_pseudo_id = e.user_pseudo_id
WHERE e.user_pseudo_id IS NULL
ORDER BY remove_date DESC

-- user_install

WITH installs AS (
  SELECT
    user_pseudo_id AS user_id,
    DATE(TIMESTAMP_MICROS(user_first_touch_timestamp)) AS install_date,
    FORMAT_TIME('%H:%M:%S', TIME(TIMESTAMP_MICROS(user_first_touch_timestamp))) AS install_time,
    REPLACE(REPLACE(traffic_source.source, '(', ''), ')', '') AS source,
    device.category AS device,
    app_info.version AS version,
    REPLACE(app_info.install_source, 'com.android.vending', 'android') AS install_source,
    geo.country AS country,
    SPLIT(app_info.version, '.') AS version_parts
  FROM `firebase-public-project.analytics_153293282.events_2018*`
  WHERE app_info.install_source IS NOT NULL
),
ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY user_id
      ORDER BY
        SAFE_CAST(version_parts[OFFSET(0)] AS INT64) DESC,
        SAFE_CAST(version_parts[OFFSET(1)] AS INT64) DESC,
        SAFE_CAST(version_parts[SAFE_OFFSET(2)] AS INT64) DESC
    ) AS rn
  FROM installs
)
SELECT
  user_id,
  install_date,
  install_time,
  source,
  device,
  version,
  install_source,
  country
FROM ranked
WHERE rn = 1
ORDER BY 2 desc;

-- session_start

SELECT
  user_pseudo_id AS user_id,
  DATE(TIMESTAMP_MICROS(event_timestamp)) AS start_session_date,
  FORMAT_TIME('%H:%M:%S', TIME(TIMESTAMP_MICROS(event_timestamp))) AS start_session_time,
  FORMAT_DATE('%A', DATE(TIMESTAMP_MICROS(event_timestamp))) AS day_of_week,
  platform,
  app_info.version AS version
FROM `firebase-public-project.analytics_153293282.events_2018*`
WHERE event_name = "session_start"
ORDER BY 2
