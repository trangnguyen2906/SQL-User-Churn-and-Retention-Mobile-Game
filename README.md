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

💡**Product Managers & Growth Teams**: tracking MAU/DAU and user lifecycle

💡**Stakeholders & Executives**: making data-informed decisions on product direction

---

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
| platform      | STRING    | Device OS used at uninstall time    |
| app_version   | STRING    | Version of the app when removed     |

## ⚒️ Main Process

1️⃣ Data Cleaning & Preprocessing  
2️⃣ Exploratory Data Analysis (EDA)  
3️⃣ SQL/ Python Analysis 

- First, explain codes' purpose - what they do

- Then how your query/ code & Insert screenshots of your result

- Finally, explain your observations/ findings from the results  ts findings
  
 _Describe trends, key metrics, and patterns._  

---

## 🔎 Final Conclusion & Recommendations  

👉🏻 Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following:  

📌 Key Takeaways:  
✔️ Recommendation 1  
✔️ Recommendation 2  
✔️ Recommendation 3
