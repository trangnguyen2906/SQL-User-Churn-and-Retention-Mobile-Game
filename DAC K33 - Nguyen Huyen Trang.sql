-- Query 1: 
SELECT 
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS year_month
  , SUM(totals.visits) AS total_visit
  , SUM(totals.pageviews) AS total_pageview
  , SUM(totals.transactions) AS total_trans 
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN '0101' AND '0331'
GROUP BY year_month
ORDER BY year_month;

-- Query 2:
SELECT
    trafficSource.source as source,
    sum(totals.visits) as total_visits,
    sum(totals.Bounces) as total_no_of_bounces,
    (sum(totals.Bounces)/sum(totals.visits))* 100.00 as bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
GROUP BY source
ORDER BY total_visits DESC;


-- Query 3:
SELECT 
  'Month' AS time_type
  , FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS time
  , trafficSource.source AS source
  , ROUND(SUM(product.productRevenue) / 1000000, 5) AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
WHERE _table_suffix BETWEEN '0601' AND '0630'
    AND product.productRevenue IS NOT NULL
GROUP BY 2,3

UNION ALL

SELECT 
  'Week' AS time_type
  , FORMAT_DATE('%Y%V', PARSE_DATE('%Y%m%d', date)) AS time
  , trafficSource.source AS source
  , ROUND(SUM(product.productRevenue) / 1000000, 5) AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
WHERE _table_suffix BETWEEN '0601' AND '0630'
    AND product.productRevenue IS NOT NULL
GROUP BY 2, 3
ORDER BY 4 DESC, 3 DESC;

--  Query 4: 
with 
purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      (sum(totals.pageviews)/count(distinct fullvisitorid)) as avg_pageviews_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions>=1
  and product.productRevenue is not null
  group by month
),

non_purchaser_data as(
  select
      format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
      sum(totals.pageviews)/count(distinct fullvisitorid) as avg_pageviews_non_purchase,
  from `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
      ,unnest(hits) hits
    ,unnest(product) product
  where _table_suffix between '0601' and '0731'
  and totals.transactions is null
  and product.productRevenue is null
  group by month
)

select
    pd.*,
    avg_pageviews_non_purchase
from purchaser_data pd
full join non_purchaser_data using(month)
order by pd.month;

-- Query 5:
WITH total_trans_per_user AS ( -- Tính mỗi user có tổng bao nhiêu transactions
  SELECT 
      FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS year_month
    , fullVisitorId
    , SUM(CASE WHEN totals.transactions >= 1 AND product.productRevenue IS NOT NULL THEN totals.transactions END) AS total_trans
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    , UNNEST(hits) AS hits
    , UNNEST(hits.product) AS product
  WHERE _table_suffix BETWEEN '0701' AND '0731' 
      AND product.productRevenue IS NOT NULL
  GROUP BY 1, 2
)
SELECT 
      year_month
    , SUM(total_trans) / COUNT(DISTINCT fullVisitorId) AS Avg_total_transactions_per_user
FROM total_trans_per_user
GROUP BY 1;

--mình nên filter các data cần lấy hơn là sum case when như trên
select
    format_date("%Y%m",parse_date("%Y%m%d",date)) as month,
    sum(totals.transactions)/count(distinct fullvisitorid) as Avg_total_transactions_per_user
from `bigquery-public-data.google_analytics_sample.ga_sessions_201707*`
    ,unnest (hits) hits,
    unnest(product) product
where  totals.transactions>=1
and product.productRevenue is not null
group by month;

-- Query 6:
SELECT 
  FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS year_month
  , ROUND((SUM(product.productRevenue) / 1000000) / SUM(totals.visits), 2) AS avg_revenue_by_user_per_visit
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  ,UNNEST(hits) AS hits
  ,UNNEST(hits.product) AS product
WHERE _table_suffix BETWEEN '0701' AND '0731' 
  AND product.productRevenue IS NOT NULL
  AND totals.transactions IS NOT NULL
GROUP BY 1;

-- Query 7:
WITH customers_with_VintageHenley AS ( -- Các user đã mua sản phẩm Vintage Henley
  SELECT 
    fullVisitorId
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    , UNNEST(hits) AS hits
    , UNNEST(hits.product) AS product
  WHERE _table_suffix BETWEEN '0701' AND '0731'
    AND product.productRevenue IS NOT NULL
    AND product.v2ProductName = "YouTube Men's Vintage Henley"
  ORDER BY fullVisitorId
)
SELECT -- Lấy tên sản phẩm khác và số lượng mà các user mua Vintage Henley cũng mua (trừ Vintage Henley)
  product.v2ProductName AS other_purchased_products
  , SUM(product.productQuantity) AS Quantity
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) AS product
WHERE _table_suffix BETWEEN '0701' AND '0731'
  AND product.productRevenue IS NOT NULL
  AND fullVisitorId IN (SELECT fullVisitorId FROM customers_with_VintageHenley)
  AND product.v2ProductName != "YouTube Men's Vintage Henley" -- Exclude Vintage Henley
GROUP BY 1
ORDER BY 2 DESC;

-- Query 8:
with
product_view as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_product_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '2'
  GROUP BY 1
),

add_to_cart as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_addtocart
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '3'
  GROUP BY 1
),

purchase as(
  SELECT
    format_date("%Y%m", parse_date("%Y%m%d", date)) as month,
    count(product.productSKU) as num_purchase
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
  , UNNEST(hits) AS hits
  , UNNEST(hits.product) as product
  WHERE _TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
  AND hits.eCommerceAction.action_type = '6'
  and product.productRevenue is not null   --phải thêm điều kiện này để đảm bảo có revenue
  group by 1
)

select
    pv.*,
    num_addtocart,
    num_purchase,
    round(num_addtocart*100/num_product_view,2) as add_to_cart_rate,
    round(num_purchase*100/num_product_view,2) as purchase_rate
from product_view pv
left join add_to_cart a on pv.month = a.month
left join purchase p on pv.month = p.month
order by pv.month;
