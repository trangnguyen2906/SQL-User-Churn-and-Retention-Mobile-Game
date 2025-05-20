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
--correct

-- Query 2:
SELECT 
  trafficSource.source
  , COALESCE(SUM(totals.bounces), 0) AS num_bounce

  , SUM(totals.visits) AS total_visit
  , ROUND(COALESCE(SUM(totals.bounces), 0) / SUM(totals.visits) * 100, 3) AS bounce_rate
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
WHERE _table_suffix BETWEEN '0701' AND '0731'
GROUP BY 1
ORDER BY 1 DESC;

--tuỳ trường hợp mình cân nhắc xem có nên dùng coalesce sum như trên k,
--đôi khi nó null thì cứ để nó null
-->
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
--correct

--  Query 4: 
WITH classify AS ( -- Phân loại khách hàng thuộc loại nào
  SELECT 
      FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS year_month
    , fullVisitorId
    , CASE
        WHEN totals.transactions >= 1 AND product.productRevenue IS NOT NULL THEN 'purchase'
        WHEN totals.transactions IS NULL OR product.productRevenue IS NULL THEN 'non-purchase'
      END AS classify_visiter
    , SUM(totals.pageviews) AS total_view
  FROM `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`
    , UNNEST(hits) AS hits
    , UNNEST(hits.product) AS product
  WHERE _table_suffix BETWEEN '0601' AND '0731'
  GROUP BY 1, 2, 3
  ORDER BY 1, 2, 3
),
pageview_unq_user AS ( -- Tính pageview và count unique user dựa trên mỗi loại
  SELECT 
      year_month
    , COUNT(DISTINCT CASE WHEN classify_visiter = 'purchase' THEN fullVisitorId END) AS unique_users_purchase
    , COUNT(DISTINCT CASE WHEN classify_visiter = 'non-purchase' THEN fullVisitorId END) AS unique_users_non_purchase
    , SUM(CASE WHEN classify_visiter = 'purchase' THEN total_view ELSE 0 END) AS total_pageview_purchase
    , SUM(CASE WHEN classify_visiter = 'non-purchase' THEN total_view ELSE 0 END) AS total_pageview_non_purchase
  FROM classify
  GROUP BY 1
)
SELECT -- Tính avg pageview
      year_month
    , ROUND(total_pageview_purchase / unique_users_purchase, 3) AS avg_pageviews_purchase
    , ROUND(total_pageview_non_purchase / unique_users_non_purchase, 3) AS avg_pageviews_non_purchase
FROM pageview_unq_user
ORDER BY 1;

--để phân loại kh thì tốt nhất mình tách ra thành các cte
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

--câu 4 này lưu ý là mình nên dùng full join/left join, bởi vì trong câu này, phạm vi chỉ từ tháng 6-7, nên chắc chắc sẽ có pur và nonpur của cả 2 tháng
--mình inner join thì vô tình nó sẽ ra đúng. nhưng nếu đề bài là 1 khoảng thời gian dài hơn, 2-3 năm chẳng hạn, thì có tháng chỉ có nonpur mà k có pur
--thì khi đó inner join nó sẽ làm mình bị mất data, thay vì hiện số của nonpur và pur thì nó để trống


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
--correct

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

--correct

-- Query 8:
WITH product_events AS (
  SELECT 
    FORMAT_DATE('%Y%m', PARSE_DATE('%Y%m%d', date)) AS year_month
    ,hits.eCommerceAction.action_type AS action_type
    ,COUNT(*) AS num_events
  FROM 
    `bigquery-public-data.google_analytics_sample.ga_sessions_2017*`,
    UNNEST(hits) AS hits,
    UNNEST(hits.product) AS product
  WHERE _table_suffix BETWEEN '0101' AND '0331'
    AND (
        hits.eCommerceAction.action_type IN ('2', '3')
        OR (hits.eCommerceAction.action_type = '6' AND product.productRevenue IS NOT NULL)
    )
  GROUP BY 1,2
  ORDER BY 1,2
),
num_view_add_purchase AS (
  SELECT 
    year_month
    ,SUM(CASE WHEN action_type = '2' THEN num_events ELSE 0 END) AS num_product_view
    ,SUM(CASE WHEN action_type = '3' THEN num_events ELSE 0 END) AS num_addtocart
    ,SUM(CASE WHEN action_type = '6' THEN num_events ELSE 0 END) AS num_purchase
  FROM product_events
  GROUP BY 1
  ORDER BY 1
)
SELECT 
  *
  ,ROUND(num_addtocart / num_product_view * 100.0, 2) AS add_to_cart_rate
  ,ROUND(num_purchase / num_product_view * 100.0, 2) AS purchase_rate
FROM num_view_add_purchase;

--điều kiện ở cte product_events của e hơi khó nhìn
--nên là cách trình bày của anh cho dễ nhìn hơn

--Cách 1:dùng CTE
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

--bài này k nên inner join, vì nếu như bảng purchase k có data thì sẽ k mapping đc vs bảng productview, từ đó kết quả sẽ k có luôn, mình nên dùng left join
--lấy số product_view làm gốc, nên mình sẽ left join ra 2 bảng còn lại

--Cách 2: bài này mình có thể dùng count(case when) hoặc sum(case when)

with product_data as(
select
    format_date('%Y%m', parse_date('%Y%m%d',date)) as month,
    count(CASE WHEN eCommerceAction.action_type = '2' THEN product.v2ProductName END) as num_product_view,
    count(CASE WHEN eCommerceAction.action_type = '3' THEN product.v2ProductName END) as num_add_to_cart,
    count(CASE WHEN eCommerceAction.action_type = '6' and product.productRevenue is not null THEN product.v2ProductName END) as num_purchase
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
,UNNEST(hits) as hits
,UNNEST (hits.product) as product
where _table_suffix between '20170101' and '20170331'
and eCommerceAction.action_type in ('2','3','6')
group by month
order by month
)

select
    *,
    round(num_add_to_cart/num_product_view * 100, 2) as add_to_cart_rate,
    round(num_purchase/num_product_view * 100, 2) as purchase_rate
from product_data;


--- good---