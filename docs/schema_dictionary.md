# 九表数据字典
类型为 pandas 推断；MySQL 类型设计另见 01_schema.sql。空值按 CSV 空字段解析规则统计。

## sellers（3,095 行）
| 字段 | 推断类型 | 缺失行数 |
|---|---|---:|
| seller_id | str | 0 |
| seller_zip_code_prefix | int64 | 0 |
| seller_city | str | 0 |
| seller_state | str | 0 |
完全重复行超额：0。

## customers（99,441 行）
| 字段 | 推断类型 | 缺失行数 |
|---|---|---:|
| customer_id | str | 0 |
| customer_unique_id | str | 0 |
| customer_zip_code_prefix | int64 | 0 |
| customer_city | str | 0 |
| customer_state | str | 0 |
完全重复行超额：0。

## geolocation（1,000,163 行）
| 字段 | 推断类型 | 缺失行数 |
|---|---|---:|
| geolocation_zip_code_prefix | int64 | 0 |
| geolocation_lat | float64 | 0 |
| geolocation_lng | float64 | 0 |
| geolocation_city | str | 0 |
| geolocation_state | str | 0 |
完全重复行超额：261,831。

## order_items（112,650 行）
| 字段 | 推断类型 | 缺失行数 |
|---|---|---:|
| order_id | str | 0 |
| order_item_id | int64 | 0 |
| product_id | str | 0 |
| seller_id | str | 0 |
| shipping_limit_date | str | 0 |
| price | float64 | 0 |
| freight_value | float64 | 0 |
完全重复行超额：0。

## order_payments（103,886 行）
| 字段 | 推断类型 | 缺失行数 |
|---|---|---:|
| order_id | str | 0 |
| payment_sequential | int64 | 0 |
| payment_type | str | 0 |
| payment_installments | int64 | 0 |
| payment_value | float64 | 0 |
完全重复行超额：0。

## orders（99,441 行）
| 字段 | 推断类型 | 缺失行数 |
|---|---|---:|
| order_id | str | 0 |
| customer_id | str | 0 |
| order_status | str | 0 |
| order_purchase_timestamp | str | 0 |
| order_approved_at | str | 160 |
| order_delivered_carrier_date | str | 1,783 |
| order_delivered_customer_date | str | 2,965 |
| order_estimated_delivery_date | str | 0 |
完全重复行超额：0。

## order_reviews（99,224 行）
| 字段 | 推断类型 | 缺失行数 |
|---|---|---:|
| review_id | str | 0 |
| order_id | str | 0 |
| review_score | int64 | 0 |
| review_comment_title | str | 87,656 |
| review_comment_message | str | 58,247 |
| review_creation_date | str | 0 |
| review_answer_timestamp | str | 0 |
完全重复行超额：0。

## products（32,951 行）
| 字段 | 推断类型 | 缺失行数 |
|---|---|---:|
| product_id | str | 0 |
| product_category_name | str | 610 |
| product_name_lenght | float64 | 610 |
| product_description_lenght | float64 | 610 |
| product_photos_qty | float64 | 610 |
| product_weight_g | float64 | 2 |
| product_length_cm | float64 | 2 |
| product_height_cm | float64 | 2 |
| product_width_cm | float64 | 2 |
完全重复行超额：0。

## category_translation（71 行）
| 字段 | 推断类型 | 缺失行数 |
|---|---|---:|
| product_category_name | str | 0 |
| product_category_name_english | str | 0 |
完全重复行超额：0。