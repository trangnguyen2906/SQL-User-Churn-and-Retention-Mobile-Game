# 📊 Analyze User Churn & Retention of Flood It! Using SQL & Python


## 📄 **Table of Contents**
1. [📌 Background & Overview](#background--overview)  
2. [📂 Dataset Description & Data Structure](#dataset-description--data-structure)  
3. [🔍 Final Conclusion & Recommendations](#final-conclusion--recommendations)  


## 📌 **Background & Overview**

### Objective:
### 📖 What is this project about? What Business Question will it solve?

This project analyzes user behavior using data from the **Flood-It freemium mobile game**, available via the **Firebase public dataset on Google BigQuery**.

The primary focus is to explore:
- 📉 Churn Rate: What percentage of users stop playing after 1, 3, 7, 14, or 30 days?

- 🔁 Retention Rate: How many users return after their install date?

- ⚠️ Drop-off Points: At what point in the user journey do most players abandon the game?

- 📊 MAU & DAU: What do monthly and daily active user trends tell us about engagement?

- 🧠 Possible Reasons Behind Churn: Do uninstall patterns, short session durations, or low level completions precede user drop-off?
  
🎯 The goal is to **identify critical user behaviors** that can guide strategies to **reduce churn** and **enhance retention** in mobile games.

### 👤 Who is this project for?  
💡**Data Analysts & Business Analysts**: looking to quantify and understand churn

💡**Game Designers & Developers**: aiming to improve retention through data

💡**Stakeholders & Executives**: making data-informed decisions on product direction



## 📂 **Dataset Description & Data Structure** 

### 📌 Data Source  
- **Source:** Google BigQuery – Public Firebase Analytics Dataset
  - **Table:** firebase-public-project.analytics_153293282.events_2018*

- **Size:** **5.7M rows** covering in-app event logs across **114 days** from 12/06 to 03/10 in 2018

- **Format:**
  - .sql (queried directly via BigQuery)
  - .csv (for visualization via GG Colab)

### 📊 Data Structure & Relationships  

#### 1️⃣ Tables Used:  
⚠️ The original dataset is not clean and complex. Thus, I create a dataset called game_dataset for simpler analysis, which contains:

**user_install:** install events

**session_start:** session activity

**remove_app:** uninstall behavior

These are **view tables** created to isolate and query relevant user lifecycle events efficiently.  

#### 2️⃣ Table Schema & Data Snapshot  

**Table 1: user_install**

| Column Name | Data Type | Description |  
|-------------|----------|-------------|  
| user_id     | STRING   | Unique identifier for each user |  
| install_date        | DATE     | Date of installation |  
| source    | STRING     | how user install the app |  
| device       | STRING    | device that installed the app |  
| version       | STRING    | app version |
| install_source       | STRING    | Install method/source (e.g., Play Store) |
| country       | STRING    | 	Country of the user |



**Table 2: session_start**
| Column Name         | Data Type | Description                          |
|---------------------|-----------|--------------------------------------|
| user_id             | STRING    | Unique identifier for each user      |
| start_session_date  | DATE      | Date the session started             |
| start_session_time  | STRING    | Time the session started             |
| day_of_week         | STRING    | Day of the week when session occurred|
| platform            | STRING    | OS used during the session           |
| version             | STRING    | App version used in that session     |


**Table 3: remove_app**
| Column Name   | Data Type | Description                         |
|---------------|-----------|-------------------------------------|
| user_id       | STRING    | Unique identifier for each user     |
| remove_date   | DATE      | Date the app was uninstalled        |
| remove_time   | STRING    | Time of uninstall                   |
| platform      | STRING    | Device used at uninstall time    |
| app_version   | STRING    | Version of the app when removed     |

## ⚒️ Main Process

## 1️⃣ Data Cleaning & Preprocessing 

- Created simplified views (user_install, session_start, remove_app) from raw Firebase event data for efficient querying.

- Removed/Replaced inappropriate, incomplete, duplicate, null values
<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1EjmHyZ7W1Gi_glXbd6HmLGixCmwKRoZ8" width="45%" />
  <img src="https://drive.google.com/uc?export=view&id=1M4EptsCSuQLvuBrPhcHNJ3Vq5EL-l4LP" width="45%" />
</p>
<p align="center"><em>Figure 1: user_install view and remove_app view (right)</em></p>

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1-pxxzcfHvq5Wjj1kthoBxJNvLZPKlN6q" width="50%" />
</p>
<p align="center"><em>Figure 2: session_start view</em></p>

## 2️⃣ SQL/ Python Analysis

### 🔍 Retention Analysis
> In mobile games, retention measures how well a game keeps players coming back over time. It reflects product stickiness, onboarding success, and long-term engagement. This section focuses on calculating retention-related metrics using SQL with visualizations.

#### 🟡 **Active Users (DAU & MAU):** How many unique users open the app daily (DAU) and monthly (MAU).
  
```
-- Daily Active Users --
  SELECT 
    EXTRACT(MONTH FROM start_session_date) AS month,
    COUNT(DISTINCT user_id) AS MAU
  FROM `sqlfinal-447808.game_dataset.session_start`
  GROUP BY month
  ORDER BY month ASC
```

```
-- Monthly Active Users --
  SELECT 
    EXTRACT(MONTH FROM start_session_date) AS month,
    COUNT(DISTINCT user_id) AS MAU
  FROM `sqlfinal-447808.game_dataset.session_start`
  GROUP BY month
  ORDER BY month ASC
```
<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1MbCBFhaAy6kqYTbhMv4mI2-mVBYkAu40" />
</p>
<p align="center"><em>Figure 1: Daily Active Users Over Time</em></p>

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1B2X7QXdkDb10GxfA8CINrGiohGHUgjM6" />
</p>
<p align="center"><em>Figure 2: Average DAU by Day of Week</em></p>

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1HTgD8GLMnDbKNMvAOjEGbSCbGYgy64Gy" />
</p>
<p align="center"><em>Figure 3: Monthly Active Users Output (MAU Table)</em></p>
</details>

#### 💡 Observation:
- 📈 **Engagement Spikes:** A clear **surge** in daily usage occurred between **late June and early July**, with DAU **peaking** above **750 users**, likely tied to promotions or new feature releases. Post-spike, the DAU **stabilizes between 350–500 users.**
- 📅 **Consistent Weekday Activity:** DAU remains relatively **steady** across **weekdays**, suggesting stable engagement from the user base even outside weekends.
- 📊 **Monthly Active Users (MAU):** Although MAU increased from 3,876 (June) to 5,244 (September), June with only ~2 weeks of data still had nearly as many users as July (4,131) and more than August (3,906), suggesting **weaker engagement or user quality in July and August.**

<details>
 <summary>🟡 <strong>Daily & Monthly Install:</strong> The number of new installs each day.</summary>
   
> 🎯Analyze acquisition trends and evaluate campaign effectiveness.

> 🎯Supports cohort-based retention analysis and seasonal comparisons.

```
-- daily_install --
SELECT 
  install_date,
  COUNT(DISTINCT user_id) AS daily_install
FROM `sqlfinal-447808.game_dataset.user_install`
WHERE install_date BETWEEN '2018-06-12' AND '2018-10-03'
GROUP BY install_date
ORDER BY install_date ASC

-- monthly_install --
SELECT 
  EXTRACT(MONTH FROM install_date) AS month,
  COUNT(DISTINCT user_id) AS monthly_install
FROM `sqlfinal-447808.game_dataset.user_install`
WHERE install_date BETWEEN '2018-06-12' AND '2018-10-03'
GROUP BY month
ORDER BY month ASC
```
<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1mCOB2ohDncytcraGmJjKApzhiX5yW7Q6" />
</p>
<p align="center"><em>Figure 4: Daily Active Users (DAU) and Daily New Installs Over Time</em></p>

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=18Slq-1Wl4Sn4Jiq9IR1iLRdbPEN9Sz40" />
</p>
<p align="center"><em>Figure 5: Monthly Install Totals</em></p>
</details>

#### 💡 Observation:
- 📊 **High MAU in July–August ≠ High Engagement:** Despite relatively high MAU in July (4,131) and August (3,906), the DAU trend shows declining daily activity after early July, stabilizing between 350–500 users. 
- ⚠️ This suggests that although many users installed the app, **few returned daily**, pointing to weaker stickiness or engagement in those months.

<details>
 <summary>🟡 <strong>Cohort-Based Retention Analysis</strong> </summary>

<details>  
<summary> 🎯 <strong>Retention After 14 Days</strong> </summary>
  
> Track the percentage of June (or other months) users returning on each day after installation (D1 to D14).
This shows short-term engagement quality after onboarding.

```
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
```
<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1Dq2Ro_2jHbj9hhQzjKyyA0BB86Cs58l6" />
</p>
<p align="center"><em>Figure 6: 14-Day Retention Heatmap for Users Who Installed in June</em></p>

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1xbW5g1lUMrudUxCsBXK_d05cTNfQBCbM" />
</p>
<p align="center"><em>Figure 7: Average Retention Rate per Day After Install (All Users)</em></p>

</details>

#### 💡 Observation:
- 📉 **Sharp Drop After Day 1:** Retention drops steeply from **67.65% on Day 0** to 16.72% on Day 1, and falls **below 10% by Day 3**, indicating early user churn is a **key issue.**
- 📊 **Low Long-Term Retention:** From **Day 7 onward**, retention rates stay consistently **below 6.5%**, suggesting limited long-term engagement.
- 🔁 **Consistent Pattern Across Months:** Similar 14-day retention patterns were observed in other months, confirming this early drop-off is not unique to June but a recurring trend in user behavior.



<details>  
 <summary> 🎯 <strong>Monthly Cohort Retention (Over 4 Months)</strong> </summary>
  
> Measure long-term retention for monthly cohorts (e.g., June–October). This provides insight into user lifetime engagement trends.
> 
```
-- Retention rate by Month --
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
```
<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1Y-AN70Q3lDigxQu198rkIWjIlm6fERVg" />
</p>
<p align="center"><em>Figure 8: Monthly Retention Rate by Install Cohort</em></p>

</details>

#### 💡 Observation:
- 📉 **Sharp Drop After Month 0:** Most cohorts show a big drop from install month to Month 1. For example, June drops from **64.8% to 26.4%**, and August drops from **75.0% to 24.1%**, confirming early churn as a persistent issue.
- ⚠️ Retention data for **September and October** is **incomplete** due to the dataset ending on **October 3**, so long-term trends for these cohorts are not fully available.

</details>

#### 🔍 **Churn Analysis**
> Churn is defined as **users who do not return after a certain number of days since installation.** This helps identify early **user drop-off** and guide retention strategy improvements.

<details>
<summary>🟡 <strong>Churn Rates After 3, 7, 14, 30 Days</strong></summary>
  
```
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
ORDER BY r.install_date;**
```
<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1-vBAQhzuTHqB0z0XDbtVxkhNPwz0wdOP" width="60%"/>

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1kcEI4o0tH8F0tJIQnb6kZi8--bqp0i43" width="60%"/>

</details>

#### 💡 Observation:
- 📉 **Massive Early Churn:** **Over 86 percent of users churn** **within the first 3 days**, and by **Day 30**, churn exceeds **95 percent** in August, revealing severe early drop-off
- 🔁 **June Retained Slightly Better:** June had the lowest Day 30 churn at 91.3 percent, slightly better than July at 90.7 percent and August at 95.4 percent, suggesting stronger user engagement early on

<details>
<summary>🟡 <strong>Possible Reason for churn/removove app</strong></summary>

> ❓Which **app versions** and **platforms** have the highest uninstall counts?
```
SELECT
  app_version,
  platform,
  COUNT(*) AS num_remove
FROM `sqlfinal-447808.game_dataset.remove_app`
GROUP BY 1,2
ORDER BY 3 DESC
```

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1drlOft_PI4UUtKe3rBf9NzCXHu4Lull_" alt="App Removal by Version" />
</p>
<p align="center"><em>Figure: Number of App Removals by App Version & Platform </em></p>

#### 💡 Observation:
- ❌ **Version 2.62 accounts for the majority of uninstalls with 1,684 removals**, far exceeding all other versions. This may indicate serious usability or performance issues in that specific release.
- 📱 **All uninstalls occurred on Android**, suggesting that any churn mitigation efforts should focus on Android-specific debugging and optimization.


> ❓**How long** users wait after their **last session before uninstalling the app**? (Indicates whether churn is immediate or delayed and may reflect disengagement periods.)

```
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
```

<p align="center">
  <img src="https://drive.google.com/uc?export=view&id=1014n8UmJMOS3uHFUWlvlzYGt3SSlF6ot" alt="Days After Last Play Before Removal" />
</p>
<p align="center"><em>Figure: Days Between Last Play and App Removal</em></p

#### 💡 Observation:

- ⏱️ **Immediate Uninstalls Are Most Common:** The highest uninstall count (549 users) occurred on the same day as their last session, showing many users **quit immediately after playing.**
- 📆 **80 percent uninstalled within 3 days:** A majority of users removed the app within just 1 to 3 days after their last session, indicating rapid disengagement following final use.                                                                           

> ❓**How many levels** **on average** users complete before uninstalling within a day.
```
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

-- Output: 5.3 -- 
```

#### 💡 Observation:
🎮 Users who uninstall within a day complete an average of **5.3 levels** before leaving, indicating that early churn often occurs after only limited gameplay experience.

</details>

---


## 🔎 Final Conclusion & Recommendations  

👉🏻 Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following:  

📌 Key Takeaways:  
✔️ Recommendation 1  
✔️ Recommendation 2  
✔️ Recommendation 3
