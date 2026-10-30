-- Olist 电商分析完整代码 | 适配你已导入的 ecommerce_project
-- 适用 MySQL 8.0+。先执行下面两行，确认版本和数据库。
-- 不需要重导入 CSV。本脚本读取原表，创建/更新 v_oa_ 前缀分析视图。
-- 同名 v_oa_ 视图再次运行时会更新；不会修改原始九张表。
-- 在 Workbench 中建议按“第0步、第1步……”选中代码分段执行。
-- 已有数据的字段名须与原CSV一致；若导入不完整，请先检查第2步行数。
-- 金额按 BRL；GMV=已送达商品金额，不含运费；不是净收入。
-- 用户已确认在本机MySQL完成验证；此处不包含该会话的导出日志。

USE ecommerce_project;
SELECT VERSION() AS mysql_version, DATABASE() AS current_database;

-- 第0步：检查实际表与字段（应为截图中的九张表）。
SHOW TABLES;
SHOW COLUMNS FROM `olist_sellers_dataset`;
SHOW COLUMNS FROM `olist_customers_dataset`;
SHOW COLUMNS FROM `olist_geolocation_dataset`;
SHOW COLUMNS FROM `olist_order_items_dataset`;
SHOW COLUMNS FROM `olist_order_payments_dataset`;
SHOW COLUMNS FROM `olist_orders_dataset`;
SHOW COLUMNS FROM `olist_order_reviews_dataset`;
SHOW COLUMNS FROM `olist_products_dataset`;
SHOW COLUMNS FROM `product_category_name_translation`;

-- 第1步：建立读取视图，处理导入后可能保留的空字符串。
-- 日期格式按原CSV的 YYYY-MM-DD HH:MM:SS 解析。
-- 不改动源表；空金额/评分仍为空值。金额转DECIMAL避免浮点求和误差。

CREATE OR REPLACE VIEW `v_oa_src_sellers` AS
SELECT
    NULLIF(NULLIF(TRIM(CAST(`seller_id` AS CHAR)),''),'NULL') AS `seller_id`,
    NULLIF(NULLIF(TRIM(CAST(`seller_zip_code_prefix` AS CHAR)),''),'NULL') AS `seller_zip_code_prefix`,
    NULLIF(NULLIF(TRIM(CAST(`seller_city` AS CHAR)),''),'NULL') AS `seller_city`,
    NULLIF(NULLIF(TRIM(CAST(`seller_state` AS CHAR)),''),'NULL') AS `seller_state`
FROM `olist_sellers_dataset`;

CREATE OR REPLACE VIEW `v_oa_src_customers` AS
SELECT
    NULLIF(NULLIF(TRIM(CAST(`customer_id` AS CHAR)),''),'NULL') AS `customer_id`,
    NULLIF(NULLIF(TRIM(CAST(`customer_unique_id` AS CHAR)),''),'NULL') AS `customer_unique_id`,
    NULLIF(NULLIF(TRIM(CAST(`customer_zip_code_prefix` AS CHAR)),''),'NULL') AS `customer_zip_code_prefix`,
    NULLIF(NULLIF(TRIM(CAST(`customer_city` AS CHAR)),''),'NULL') AS `customer_city`,
    NULLIF(NULLIF(TRIM(CAST(`customer_state` AS CHAR)),''),'NULL') AS `customer_state`
FROM `olist_customers_dataset`;

CREATE OR REPLACE VIEW `v_oa_src_geolocation` AS
SELECT
    NULLIF(NULLIF(TRIM(CAST(`geolocation_zip_code_prefix` AS CHAR)),''),'NULL') AS `geolocation_zip_code_prefix`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`geolocation_lat` AS CHAR)),''),'NULL') AS DECIMAL(20,15)) AS `geolocation_lat`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`geolocation_lng` AS CHAR)),''),'NULL') AS DECIMAL(20,15)) AS `geolocation_lng`,
    NULLIF(NULLIF(TRIM(CAST(`geolocation_city` AS CHAR)),''),'NULL') AS `geolocation_city`,
    NULLIF(NULLIF(TRIM(CAST(`geolocation_state` AS CHAR)),''),'NULL') AS `geolocation_state`
FROM `olist_geolocation_dataset`;

CREATE OR REPLACE VIEW `v_oa_src_order_items` AS
SELECT
    NULLIF(NULLIF(TRIM(CAST(`order_id` AS CHAR)),''),'NULL') AS `order_id`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`order_item_id` AS CHAR)),''),'NULL') AS SIGNED) AS `order_item_id`,
    NULLIF(NULLIF(TRIM(CAST(`product_id` AS CHAR)),''),'NULL') AS `product_id`,
    NULLIF(NULLIF(TRIM(CAST(`seller_id` AS CHAR)),''),'NULL') AS `seller_id`,
    STR_TO_DATE(NULLIF(NULLIF(TRIM(CAST(`shipping_limit_date` AS CHAR)),''),'NULL'),'%Y-%m-%d %H:%i:%s') AS `shipping_limit_date`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`price` AS CHAR)),''),'NULL') AS DECIMAL(15,2)) AS `price`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`freight_value` AS CHAR)),''),'NULL') AS DECIMAL(15,2)) AS `freight_value`
FROM `olist_order_items_dataset`;

CREATE OR REPLACE VIEW `v_oa_src_order_payments` AS
SELECT
    NULLIF(NULLIF(TRIM(CAST(`order_id` AS CHAR)),''),'NULL') AS `order_id`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`payment_sequential` AS CHAR)),''),'NULL') AS SIGNED) AS `payment_sequential`,
    NULLIF(NULLIF(TRIM(CAST(`payment_type` AS CHAR)),''),'NULL') AS `payment_type`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`payment_installments` AS CHAR)),''),'NULL') AS SIGNED) AS `payment_installments`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`payment_value` AS CHAR)),''),'NULL') AS DECIMAL(15,2)) AS `payment_value`
FROM `olist_order_payments_dataset`;

CREATE OR REPLACE VIEW `v_oa_src_orders` AS
SELECT
    NULLIF(NULLIF(TRIM(CAST(`order_id` AS CHAR)),''),'NULL') AS `order_id`,
    NULLIF(NULLIF(TRIM(CAST(`customer_id` AS CHAR)),''),'NULL') AS `customer_id`,
    NULLIF(NULLIF(TRIM(CAST(`order_status` AS CHAR)),''),'NULL') AS `order_status`,
    STR_TO_DATE(NULLIF(NULLIF(TRIM(CAST(`order_purchase_timestamp` AS CHAR)),''),'NULL'),'%Y-%m-%d %H:%i:%s') AS `order_purchase_timestamp`,
    STR_TO_DATE(NULLIF(NULLIF(TRIM(CAST(`order_approved_at` AS CHAR)),''),'NULL'),'%Y-%m-%d %H:%i:%s') AS `order_approved_at`,
    STR_TO_DATE(NULLIF(NULLIF(TRIM(CAST(`order_delivered_carrier_date` AS CHAR)),''),'NULL'),'%Y-%m-%d %H:%i:%s') AS `order_delivered_carrier_date`,
    STR_TO_DATE(NULLIF(NULLIF(TRIM(CAST(`order_delivered_customer_date` AS CHAR)),''),'NULL'),'%Y-%m-%d %H:%i:%s') AS `order_delivered_customer_date`,
    STR_TO_DATE(NULLIF(NULLIF(TRIM(CAST(`order_estimated_delivery_date` AS CHAR)),''),'NULL'),'%Y-%m-%d %H:%i:%s') AS `order_estimated_delivery_date`
FROM `olist_orders_dataset`;

CREATE OR REPLACE VIEW `v_oa_src_order_reviews` AS
SELECT
    NULLIF(NULLIF(TRIM(CAST(`review_id` AS CHAR)),''),'NULL') AS `review_id`,
    NULLIF(NULLIF(TRIM(CAST(`order_id` AS CHAR)),''),'NULL') AS `order_id`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`review_score` AS CHAR)),''),'NULL') AS SIGNED) AS `review_score`,
    NULLIF(`review_comment_title`,'') AS `review_comment_title`,
    NULLIF(`review_comment_message`,'') AS `review_comment_message`,
    STR_TO_DATE(NULLIF(NULLIF(TRIM(CAST(`review_creation_date` AS CHAR)),''),'NULL'),'%Y-%m-%d %H:%i:%s') AS `review_creation_date`,
    STR_TO_DATE(NULLIF(NULLIF(TRIM(CAST(`review_answer_timestamp` AS CHAR)),''),'NULL'),'%Y-%m-%d %H:%i:%s') AS `review_answer_timestamp`
FROM `olist_order_reviews_dataset`;

CREATE OR REPLACE VIEW `v_oa_src_products` AS
SELECT
    NULLIF(NULLIF(TRIM(CAST(`product_id` AS CHAR)),''),'NULL') AS `product_id`,
    NULLIF(NULLIF(TRIM(CAST(`product_category_name` AS CHAR)),''),'NULL') AS `product_category_name`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`product_name_lenght` AS CHAR)),''),'NULL') AS SIGNED) AS `product_name_lenght`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`product_description_lenght` AS CHAR)),''),'NULL') AS SIGNED) AS `product_description_lenght`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`product_photos_qty` AS CHAR)),''),'NULL') AS SIGNED) AS `product_photos_qty`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`product_weight_g` AS CHAR)),''),'NULL') AS SIGNED) AS `product_weight_g`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`product_length_cm` AS CHAR)),''),'NULL') AS SIGNED) AS `product_length_cm`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`product_height_cm` AS CHAR)),''),'NULL') AS SIGNED) AS `product_height_cm`,
    CAST(NULLIF(NULLIF(TRIM(CAST(`product_width_cm` AS CHAR)),''),'NULL') AS SIGNED) AS `product_width_cm`
FROM `olist_products_dataset`;

CREATE OR REPLACE VIEW `v_oa_src_category_translation` AS
SELECT
    NULLIF(NULLIF(TRIM(CAST(`product_category_name` AS CHAR)),''),'NULL') AS `product_category_name`,
    NULLIF(NULLIF(TRIM(CAST(`product_category_name_english` AS CHAR)),''),'NULL') AS `product_category_name_english`
FROM `product_category_name_translation`;

-- 第2步：检查你导入的行数是否与九份原附件一致。matches_original应为1。
SELECT table_name,actual_rows,expected_rows,CASE WHEN actual_rows=expected_rows THEN 1 ELSE 0 END AS matches_original
FROM (
SELECT 'olist_sellers_dataset' AS table_name,COUNT(*) AS actual_rows,3095 AS expected_rows FROM `olist_sellers_dataset`
UNION ALL
SELECT 'olist_customers_dataset' AS table_name,COUNT(*) AS actual_rows,99441 AS expected_rows FROM `olist_customers_dataset`
UNION ALL
SELECT 'olist_geolocation_dataset' AS table_name,COUNT(*) AS actual_rows,1000163 AS expected_rows FROM `olist_geolocation_dataset`
UNION ALL
SELECT 'olist_order_items_dataset' AS table_name,COUNT(*) AS actual_rows,112650 AS expected_rows FROM `olist_order_items_dataset`
UNION ALL
SELECT 'olist_order_payments_dataset' AS table_name,COUNT(*) AS actual_rows,103886 AS expected_rows FROM `olist_order_payments_dataset`
UNION ALL
SELECT 'olist_orders_dataset' AS table_name,COUNT(*) AS actual_rows,99441 AS expected_rows FROM `olist_orders_dataset`
UNION ALL
SELECT 'olist_order_reviews_dataset' AS table_name,COUNT(*) AS actual_rows,99224 AS expected_rows FROM `olist_order_reviews_dataset`
UNION ALL
SELECT 'olist_products_dataset' AS table_name,COUNT(*) AS actual_rows,32951 AS expected_rows FROM `olist_products_dataset`
UNION ALL
SELECT 'product_category_name_translation' AS table_name,COUNT(*) AS actual_rows,71 AS expected_rows FROM `product_category_name_translation`
) row_checks;

-- 如果任何matches_original为0：先核对导入，不能照搬之前报告的数字。
-- 补充：统计金额/日期解析后的空值，检查导入格式。
SELECT COUNT(*) AS orders_n,
       SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
       SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_purchase_time,
       SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS missing_estimated_time
FROM v_oa_src_orders;
SELECT SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS missing_price,
       SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS missing_freight
FROM v_oa_src_order_items;

-- 第3步：建立订单粒度视图。商品、支付、评价先分别汇总，避免金额膨胀。
-- MySQL 8.0+; run after schema creation and CSV import.
-- One row per order; never directly join item/payment/review detail tables.
CREATE OR REPLACE VIEW v_oa_order_fact AS
SELECT o.*, c.customer_unique_id, c.customer_state,
       COALESCE(i.item_count,0) AS item_count,
       COALESCE(i.item_gmv,0) AS item_gmv,
       COALESCE(i.freight,0) AS freight,
       COALESCE(p.payment_value,0) AS payment_value,
       COALESCE(p.payment_rows,0) AS payment_rows,
       r.avg_review_score, COALESCE(r.review_rows,0) AS review_rows,
       DATEDIFF(o.order_delivered_customer_date,o.order_purchase_timestamp) AS delivery_days,
       CASE WHEN o.order_status='delivered'
             AND o.order_delivered_customer_date IS NOT NULL
            THEN CASE WHEN DATEDIFF(o.order_delivered_customer_date,o.order_estimated_delivery_date)>0
                      THEN 1 ELSE 0 END END AS is_late
FROM v_oa_src_orders o
LEFT JOIN v_oa_src_customers c ON o.customer_id=c.customer_id
LEFT JOIN (SELECT order_id, COUNT(*) AS item_count,
                  SUM(price) AS item_gmv, SUM(freight_value) AS freight
           FROM v_oa_src_order_items GROUP BY order_id) i ON o.order_id=i.order_id
LEFT JOIN (SELECT order_id, SUM(payment_value) AS payment_value, COUNT(*) AS payment_rows
           FROM v_oa_src_order_payments GROUP BY order_id) p ON o.order_id=p.order_id
LEFT JOIN (SELECT order_id, AVG(1.0*review_score) AS avg_review_score, COUNT(*) AS review_rows
           FROM v_oa_src_order_reviews GROUP BY order_id) r ON o.order_id=r.order_id;

-- Geo coordinates are descriptive centroids, not exact customer locations.
-- Deduplicate exact rows first; reject out-of-global-range coordinates from centroid only.
CREATE OR REPLACE VIEW v_oa_geo_zip AS
SELECT geolocation_zip_code_prefix, AVG(geolocation_lat) AS latitude,
       AVG(geolocation_lng) AS longitude, COUNT(*) AS distinct_location_rows
FROM (SELECT DISTINCT geolocation_zip_code_prefix,geolocation_lat,geolocation_lng,
                      geolocation_city,geolocation_state FROM v_oa_src_geolocation) g
WHERE geolocation_lat BETWEEN -90 AND 90 AND geolocation_lng BETWEEN -180 AND 180
GROUP BY geolocation_zip_code_prefix;


-- 第4步：数据质量检查。部分缺失与重复是原始数据已有问题，不是都必须为0。
-- 当前数据库：ecommerce_project
-- Do not delete records merely because they are missing or repeated at another grain.
-- Q1 Row counts
SELECT 'v_oa_src_orders' AS table_name,COUNT(*) AS rows_n FROM v_oa_src_orders
UNION ALL SELECT 'v_oa_src_customers',COUNT(*) FROM v_oa_src_customers
UNION ALL SELECT 'v_oa_src_order_items',COUNT(*) FROM v_oa_src_order_items
UNION ALL SELECT 'v_oa_src_order_payments',COUNT(*) FROM v_oa_src_order_payments
UNION ALL SELECT 'v_oa_src_order_reviews',COUNT(*) FROM v_oa_src_order_reviews
UNION ALL SELECT 'v_oa_src_products',COUNT(*) FROM v_oa_src_products
UNION ALL SELECT 'v_oa_src_sellers',COUNT(*) FROM v_oa_src_sellers
UNION ALL SELECT 'v_oa_src_geolocation',COUNT(*) FROM v_oa_src_geolocation
UNION ALL SELECT 'v_oa_src_category_translation',COUNT(*) FROM v_oa_src_category_translation;

-- Q2 Core foreign-key integrity; translated category is optional.
SELECT 'orders_customer' AS check_name,COUNT(*) AS orphan_rows FROM v_oa_src_orders o LEFT JOIN v_oa_src_customers c ON o.customer_id=c.customer_id WHERE c.customer_id IS NULL
UNION ALL SELECT 'items_order',COUNT(*) FROM v_oa_src_order_items i LEFT JOIN v_oa_src_orders o ON i.order_id=o.order_id WHERE o.order_id IS NULL
UNION ALL SELECT 'items_product',COUNT(*) FROM v_oa_src_order_items i LEFT JOIN v_oa_src_products p ON i.product_id=p.product_id WHERE p.product_id IS NULL
UNION ALL SELECT 'items_seller',COUNT(*) FROM v_oa_src_order_items i LEFT JOIN v_oa_src_sellers s ON i.seller_id=s.seller_id WHERE s.seller_id IS NULL
UNION ALL SELECT 'payments_order',COUNT(*) FROM v_oa_src_order_payments p LEFT JOIN v_oa_src_orders o ON p.order_id=o.order_id WHERE o.order_id IS NULL
UNION ALL SELECT 'reviews_order',COUNT(*) FROM v_oa_src_order_reviews r LEFT JOIN v_oa_src_orders o ON r.order_id=o.order_id WHERE o.order_id IS NULL
UNION ALL SELECT 'products_translation_nonnull',COUNT(*) FROM v_oa_src_products p LEFT JOIN v_oa_src_category_translation t ON p.product_category_name=t.product_category_name WHERE p.product_category_name IS NOT NULL AND t.product_category_name IS NULL;

-- Q3 Missingness / anomalies
SELECT 'delivered_no_delivery_date' AS check_name,COUNT(*) AS n FROM v_oa_src_orders WHERE order_status='delivered' AND order_delivered_customer_date IS NULL
UNION ALL SELECT 'orders_no_items',COUNT(*) FROM v_oa_order_fact WHERE item_count=0
UNION ALL SELECT 'orders_no_payment',COUNT(*) FROM v_oa_order_fact WHERE payment_rows=0
UNION ALL SELECT 'orders_no_review',COUNT(*) FROM v_oa_order_fact WHERE review_rows=0
UNION ALL SELECT 'product_no_category',COUNT(*) FROM v_oa_src_products WHERE product_category_name IS NULL
UNION ALL SELECT 'negative_price_or_freight',COUNT(*) FROM v_oa_src_order_items WHERE price<0 OR freight_value<0
UNION ALL SELECT 'zero_payment',COUNT(*) FROM v_oa_src_order_payments WHERE payment_value=0
UNION ALL SELECT 'zero_installments',COUNT(*) FROM v_oa_src_order_payments WHERE payment_installments=0
UNION ALL SELECT 'invalid_review_score',COUNT(*) FROM v_oa_src_order_reviews WHERE review_score NOT BETWEEN 1 AND 5
UNION ALL SELECT 'delivery_before_purchase',COUNT(*) FROM v_oa_src_orders WHERE order_delivered_customer_date<order_purchase_timestamp;

-- Q4 Review ID alone is not a key
SELECT COUNT(*)-COUNT(DISTINCT review_id) AS repeated_review_id_excess FROM v_oa_src_order_reviews;
SELECT COUNT(*) AS orders_with_multiple_reviews FROM (SELECT order_id FROM v_oa_src_order_reviews GROUP BY order_id HAVING COUNT(*)>1) x;
SELECT COUNT(*) AS orders_with_multiple_payments FROM (SELECT order_id FROM v_oa_src_order_payments GROUP BY order_id HAVING COUNT(*)>1) x;

-- Q5 Geolocation is many rows per ZIP; exact duplicates retained in raw table.
SELECT (SELECT COUNT(*) FROM v_oa_src_geolocation)-COUNT(*) AS exact_duplicate_excess
FROM (SELECT DISTINCT geolocation_zip_code_prefix,geolocation_lat,geolocation_lng,geolocation_city,geolocation_state FROM v_oa_src_geolocation) x;
SELECT COUNT(*) AS zipcode_prefixes_with_multiple_states
FROM (SELECT geolocation_zip_code_prefix FROM v_oa_src_geolocation GROUP BY geolocation_zip_code_prefix HAVING COUNT(DISTINCT geolocation_state)>1) x;

-- Q6 Fact grain and GMV conservation: both differences must be zero.
SELECT (SELECT COUNT(*) FROM v_oa_order_fact)-(SELECT COUNT(*) FROM v_oa_src_orders) AS order_count_difference,
       ROUND((SELECT SUM(item_gmv) FROM v_oa_order_fact)-(SELECT SUM(price) FROM v_oa_src_order_items),2) AS item_value_difference;


-- 补充主键/复合键重复检查。duplicate_excess应为0。
SELECT 'olist_orders_dataset' AS table_name, COALESCE(SUM(n-1),0) AS duplicate_excess FROM (SELECT COUNT(*) AS n FROM v_oa_src_orders GROUP BY order_id HAVING COUNT(*)>1) duplicate_groups;
SELECT 'olist_customers_dataset' AS table_name, COALESCE(SUM(n-1),0) AS duplicate_excess FROM (SELECT COUNT(*) AS n FROM v_oa_src_customers GROUP BY customer_id HAVING COUNT(*)>1) duplicate_groups;
SELECT 'olist_products_dataset' AS table_name, COALESCE(SUM(n-1),0) AS duplicate_excess FROM (SELECT COUNT(*) AS n FROM v_oa_src_products GROUP BY product_id HAVING COUNT(*)>1) duplicate_groups;
SELECT 'olist_sellers_dataset' AS table_name, COALESCE(SUM(n-1),0) AS duplicate_excess FROM (SELECT COUNT(*) AS n FROM v_oa_src_sellers GROUP BY seller_id HAVING COUNT(*)>1) duplicate_groups;
SELECT 'olist_order_items_dataset' AS table_name, COALESCE(SUM(n-1),0) AS duplicate_excess FROM (SELECT COUNT(*) AS n FROM v_oa_src_order_items GROUP BY order_id,order_item_id HAVING COUNT(*)>1) duplicate_groups;
SELECT 'olist_order_payments_dataset' AS table_name, COALESCE(SUM(n-1),0) AS duplicate_excess FROM (SELECT COUNT(*) AS n FROM v_oa_src_order_payments GROUP BY order_id,payment_sequential HAVING COUNT(*)>1) duplicate_groups;
SELECT 'olist_order_reviews_dataset' AS table_name, COALESCE(SUM(n-1),0) AS duplicate_excess FROM (SELECT COUNT(*) AS n FROM v_oa_src_order_reviews GROUP BY review_id,order_id HAVING COUNT(*)>1) duplicate_groups;
SELECT 'product_category_name_translation' AS table_name, COALESCE(SUM(n-1),0) AS duplicate_excess FROM (SELECT COUNT(*) AS n FROM v_oa_src_category_translation GROUP BY product_category_name HAVING COUNT(*)>1) duplicate_groups;

-- 第5步：13组业务分析（每个SELECT产生一个结果表）。
-- Each numbered SELECT is exported to the matching results CSV.
-- 01_overview: all-status context and delivered merchandise GMV (BRL, excludes freight).
SELECT COUNT(*) AS all_orders,
       SUM(CASE WHEN order_status='delivered' THEN 1 ELSE 0 END) AS delivered_orders,
       SUM(CASE WHEN order_status='canceled' THEN 1 ELSE 0 END) AS canceled_orders,
       COUNT(DISTINCT customer_unique_id) AS all_buyers,
       ROUND(SUM(item_gmv),2) AS all_status_item_value,
       ROUND(SUM(CASE WHEN order_status='delivered' THEN item_gmv ELSE 0 END),2) AS delivered_gmv,
       ROUND(1.0*SUM(CASE WHEN order_status='delivered' THEN item_gmv ELSE 0 END)/
             NULLIF(SUM(CASE WHEN order_status='delivered' THEN 1 ELSE 0 END),0),2) AS delivered_aov,
       ROUND(SUM(payment_value),2) AS all_recorded_payment_value
FROM v_oa_order_fact;

-- 02_monthly: purchase-month cohort, final delivered status; partial tail months retained and labeled.
WITH calendar AS (
 SELECT '2016-09' AS purchase_month
 UNION ALL SELECT '2016-10'
 UNION ALL SELECT '2016-11'
 UNION ALL SELECT '2016-12'
 UNION ALL SELECT '2017-01'
 UNION ALL SELECT '2017-02'
 UNION ALL SELECT '2017-03'
 UNION ALL SELECT '2017-04'
 UNION ALL SELECT '2017-05'
 UNION ALL SELECT '2017-06'
 UNION ALL SELECT '2017-07'
 UNION ALL SELECT '2017-08'
 UNION ALL SELECT '2017-09'
 UNION ALL SELECT '2017-10'
 UNION ALL SELECT '2017-11'
 UNION ALL SELECT '2017-12'
 UNION ALL SELECT '2018-01'
 UNION ALL SELECT '2018-02'
 UNION ALL SELECT '2018-03'
 UNION ALL SELECT '2018-04'
 UNION ALL SELECT '2018-05'
 UNION ALL SELECT '2018-06'
 UNION ALL SELECT '2018-07'
 UNION ALL SELECT '2018-08'
 UNION ALL SELECT '2018-09'
 UNION ALL SELECT '2018-10'
), observed AS (
 SELECT DATE_FORMAT(order_purchase_timestamp,'%Y-%m') AS purchase_month,
        COUNT(*) AS all_orders,
        SUM(CASE WHEN order_status='delivered' THEN 1 ELSE 0 END) AS delivered_orders,
        SUM(CASE WHEN order_status='delivered' THEN item_gmv ELSE 0 END) AS delivered_gmv
 FROM v_oa_order_fact GROUP BY DATE_FORMAT(order_purchase_timestamp,'%Y-%m')
), m AS (
 SELECT c.purchase_month,COALESCE(o.all_orders,0) AS all_orders,
 COALESCE(o.delivered_orders,0) AS delivered_orders,COALESCE(o.delivered_gmv,0) AS delivered_gmv
 FROM calendar c LEFT JOIN observed o ON c.purchase_month=o.purchase_month
), lagged AS (
 SELECT m.*, LAG(delivered_gmv) OVER(ORDER BY purchase_month) AS previous_gmv FROM m
)
SELECT purchase_month,all_orders,delivered_orders,ROUND(delivered_gmv,2) AS delivered_gmv,
       ROUND(1.0*delivered_gmv/NULLIF(delivered_orders,0),2) AS aov,
       ROUND(100.0*(delivered_gmv-previous_gmv)/NULLIF(previous_gmv,0),2) AS mom_gmv_pct,
       CASE WHEN purchase_month BETWEEN '2017-01' AND '2018-08'
            THEN 'main_window' ELSE 'boundary_month_do_not_infer_decline' END AS window_note
FROM lagged ORDER BY purchase_month;

-- 03_categories: GMV on delivered item rows; order count is non-additive across categories.
WITH x AS (
 SELECT COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category,
        COUNT(*) AS item_rows,COUNT(DISTINCT i.order_id) AS category_orders,SUM(i.price) AS gmv
 FROM v_oa_src_order_items i JOIN v_oa_src_orders o ON i.order_id=o.order_id
 LEFT JOIN v_oa_src_products p ON i.product_id=p.product_id
 LEFT JOIN v_oa_src_category_translation t ON p.product_category_name=t.product_category_name
 WHERE o.order_status='delivered'
 GROUP BY COALESCE(t.product_category_name_english,p.product_category_name,'unknown')
)
SELECT category,item_rows,category_orders,ROUND(gmv,2) AS delivered_gmv,
       ROUND(100.0*gmv/SUM(gmv) OVER(),2) AS gmv_share_pct
FROM x ORDER BY gmv DESC;

-- 04_repeat: observed-window buyer repeat share, not fixed-horizon retention.
WITH b AS (
 SELECT customer_unique_id,COUNT(*) AS delivered_order_count,SUM(item_gmv) AS gmv
 FROM v_oa_order_fact WHERE order_status='delivered' GROUP BY customer_unique_id
)
SELECT COUNT(*) AS delivered_buyers,
       SUM(CASE WHEN delivered_order_count>=2 THEN 1 ELSE 0 END) AS repeat_buyers,
       ROUND(100.0*SUM(CASE WHEN delivered_order_count>=2 THEN 1 ELSE 0 END)/COUNT(*),2) AS repeat_buyer_pct,
       ROUND(1.0*SUM(delivered_order_count)/COUNT(*),4) AS orders_per_buyer
FROM b;

-- 05_delivery_review: calendar-date late flag; order-weighted mean of within-order mean scores.
SELECT is_late,COUNT(*) AS eligible_orders,
       ROUND(AVG(1.0*delivery_days),2) AS avg_delivery_days,
       COUNT(avg_review_score) AS reviewed_orders,
       ROUND(AVG(avg_review_score),3) AS avg_order_review_score,
       SUM(CASE WHEN avg_review_score<=2 THEN 1 ELSE 0 END) AS low_score_orders,
       ROUND(100.0*SUM(CASE WHEN avg_review_score<=2 THEN 1 ELSE 0 END)/
             NULLIF(COUNT(avg_review_score),0),2) AS low_score_pct
FROM v_oa_order_fact WHERE order_status='delivered' AND is_late IS NOT NULL
GROUP BY is_late ORDER BY is_late;

-- 06_states: destination state, delivered order basis.
SELECT customer_state,COUNT(*) AS delivered_orders,ROUND(SUM(item_gmv),2) AS delivered_gmv,
       SUM(CASE WHEN is_late IS NOT NULL THEN 1 ELSE 0 END) AS delivery_eligible,
       SUM(COALESCE(is_late,0)) AS late_orders,
       ROUND(100.0*SUM(COALESCE(is_late,0))/
             NULLIF(SUM(CASE WHEN is_late IS NOT NULL THEN 1 ELSE 0 END),0),2) AS late_pct
FROM v_oa_order_fact WHERE order_status='delivered'
GROUP BY customer_state ORDER BY delivered_gmv DESC;

-- 07_status: snapshot status is not a historical conversion funnel.
SELECT order_status,COUNT(*) AS orders,ROUND(SUM(item_gmv),2) AS item_value,
       SUM(CASE WHEN item_count=0 THEN 1 ELSE 0 END) AS no_item_orders,
       SUM(CASE WHEN payment_rows=0 THEN 1 ELSE 0 END) AS no_payment_orders
FROM v_oa_order_fact GROUP BY order_status ORDER BY orders DESC;

-- 08_reconciliation: missing payment excluded from difference comparison and reported separately.
SELECT COUNT(*) AS orders_with_items,
       SUM(CASE WHEN payment_rows=0 THEN 1 ELSE 0 END) AS missing_payment_orders,
       SUM(CASE WHEN payment_rows>0 AND ABS(ROUND(payment_value-item_gmv-freight,2))>0.01
                THEN 1 ELSE 0 END) AS difference_above_one_cent_orders,
       ROUND(SUM(CASE WHEN payment_rows>0 THEN payment_value-item_gmv-freight ELSE 0 END),2) AS net_difference,
       ROUND(MAX(CASE WHEN payment_rows>0 THEN ABS(payment_value-item_gmv-freight) END),2) AS max_abs_difference
FROM v_oa_order_fact WHERE item_count>0;

-- 09_join_inflation: deliberately unsafe detail join, for comparison only.
SELECT ROUND(SUM(i.price),2) AS unsafe_delivered_gmv
FROM v_oa_src_orders o JOIN v_oa_src_order_items i ON o.order_id=i.order_id
JOIN v_oa_src_order_payments p ON o.order_id=p.order_id
LEFT JOIN v_oa_src_order_reviews r ON o.order_id=r.order_id
WHERE o.order_status='delivered';

-- 10_may_june_categories: arithmetic contribution, not causal attribution.
WITH c AS (
 SELECT COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category,
 SUM(CASE WHEN DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m')='2018-05' THEN i.price ELSE 0 END) AS may_gmv,
 SUM(CASE WHEN DATE_FORMAT(o.order_purchase_timestamp,'%Y-%m')='2018-06' THEN i.price ELSE 0 END) AS june_gmv
 FROM v_oa_src_order_items i JOIN v_oa_src_orders o ON i.order_id=o.order_id
 LEFT JOIN v_oa_src_products p ON i.product_id=p.product_id
 LEFT JOIN v_oa_src_category_translation t ON p.product_category_name=t.product_category_name
 WHERE o.order_status='delivered' AND o.order_purchase_timestamp>='2018-05-01'
       AND o.order_purchase_timestamp<'2018-07-01'
 GROUP BY COALESCE(t.product_category_name_english,p.product_category_name,'unknown')
)
SELECT category,ROUND(may_gmv,2) AS may_gmv,ROUND(june_gmv,2) AS june_gmv,
       ROUND(june_gmv-may_gmv,2) AS gmv_change,
       ROUND(100.0*(june_gmv-may_gmv)/NULLIF(SUM(june_gmv-may_gmv) OVER(),0),2) AS net_decline_contribution_pct
FROM c ORDER BY gmv_change;

-- 11_products: top v_oa_src_products, delivered item GMV.
SELECT i.product_id,COALESCE(t.product_category_name_english,p.product_category_name,'unknown') AS category,
 COUNT(*) AS item_rows,COUNT(DISTINCT i.order_id) AS orders,ROUND(SUM(i.price),2) AS gmv
FROM v_oa_src_order_items i JOIN v_oa_src_orders o ON i.order_id=o.order_id
LEFT JOIN v_oa_src_products p ON i.product_id=p.product_id
LEFT JOIN v_oa_src_category_translation t ON p.product_category_name=t.product_category_name
WHERE o.order_status='delivered'
GROUP BY i.product_id,COALESCE(t.product_category_name_english,p.product_category_name,'unknown')
ORDER BY gmv DESC LIMIT 20;

-- 12_sellers: delivered seller-order pairs; denominators require >=100 delivered v_oa_src_orders.
WITH s AS (
 SELECT DISTINCT i.seller_id,o.order_id,o.item_gmv,o.is_late
 FROM v_oa_src_order_items i JOIN v_oa_order_fact o ON i.order_id=o.order_id WHERE o.order_status='delivered'
)
SELECT seller_id,COUNT(*) AS delivered_orders,SUM(COALESCE(is_late,0)) AS late_orders,
 SUM(CASE WHEN is_late IS NOT NULL THEN 1 ELSE 0 END) AS eligible_orders,
 ROUND(100.0*SUM(COALESCE(is_late,0))/NULLIF(SUM(CASE WHEN is_late IS NOT NULL THEN 1 ELSE 0 END),0),2) AS late_pct
FROM s GROUP BY seller_id HAVING COUNT(*)>=100 ORDER BY late_pct DESC;

-- 13_daily: daily delivered-cohort GMV; flag high days for investigation, no campaign attribution.
SELECT DATE(order_purchase_timestamp) AS purchase_date,COUNT(*) AS orders,
       ROUND(SUM(item_gmv),2) AS gmv
FROM v_oa_order_fact WHERE order_status='delivered'
GROUP BY DATE(order_purchase_timestamp) ORDER BY gmv DESC LIMIT 20;


-- 第6步：最终核对。若数据完整，应看到下面的参考值：
-- all_orders=99441; delivered_orders=96478;
-- delivered_gmv=13221498.11; delivered_aov=137.04;
-- delivered_buyers=93358; repeat_buyers=2801; repeat_buyer_pct=3.00。
-- 晚到可判断订单96470，晚到6534，晚到率约6.77%。
-- 此处为你自己的实际结果；不使用参考值覆盖查询输出。
SELECT COUNT(*) AS eligible_orders,SUM(is_late) AS late_orders,
       ROUND(100.0*SUM(is_late)/NULLIF(COUNT(*),0),2) AS late_pct
FROM v_oa_order_fact WHERE is_late IS NOT NULL;

-- 给他人查看项目：保存本SQL，并将第5步关键结果导出为CSV。
-- 不能只交参考数字；应附自己的运行结果。没有流量/成本/退款事件，
-- 不计算转化漏斗、ROI、利润或退款率；复购是观察期买家占比。
