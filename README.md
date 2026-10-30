[English](README.md) | [简体中文](README.zh-CN.md)

# Olist E-commerce Sales and Delivery Analysis

Analyze nine public Olist datasets using MySQL to examine sales trends, product categories, repeat purchases, delivery performance, and customer reviews, while preventing double counting across tables.

## Business questions
1. What are delivered merchandise GMV, order volume, and average order value?
2. Which categories contribute to monthly GMV changes? How do order volume and average order value change?
3. How do review scores differ between late and on-time deliveries?
4. What share of buyers make repeat purchases within the observation window, and what data quality issues affect the analysis?

## Data and tools
- Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce).
- Nine CSVs with 99,441 orders and 112,650 order items; purchases span September 2016 to October 2018.
- MySQL 8.0+: CTEs, window functions, conditional aggregation, and joins.
- Python: raw-data audits, exact decimal GMV checks, and independent repeat-buyer checks.
- A public-data portfolio project, with no claim of employment or production deployment.

## Key results

| Metric | Result |
|---|---:|
| Total orders | 99,441 |
| Delivered orders | 96,478 |
| Delivered merchandise GMV | BRL 13,221,498.11 |
| Delivered average order value | BRL 137.04 |
| Observed repeat-buyer share | 3.00% |
| Late-delivery rate among eligible orders | 6.77% |
| June 2018 month-over-month GMV change | -12.43% |

Low-score shares are 62.36% for late deliveries and 9.23% for on-time deliveries. This is an association, not evidence of causation.

## Approach
- Aggregate items, payments, and reviews separately to one row per order before joining.
- Use customer_unique_id to identify buyers across orders.
- Define GMV as the sum of item prices for orders with final status delivered. Exclude freight; this is not profit or net revenue.
- Check missing values, duplicates, foreign-key coverage, and payment reconciliation.
- Decompose May–June 2018 GMV changes into order-volume and average-order-value effects, and calculate category contributions to the net change.

## Repository structure
- sql/ecommerce_analysis.sql: one SQL script for ecommerce_project and the original CSV table names.
- results/: outputs for 13 analysis queries and data quality checks.
- docs/analysis_report.md: English report; docs/analysis_report.zh-CN.md: Chinese report.
- docs/schema_dictionary.md: field names, inferred types, and missing-value counts (Chinese).
- validation/: input hashes, audit details, and independent local validation records.

## How to run
1. Create ecommerce_project in MySQL 8.0+ and import the nine original CSVs into tables named after the files, without the .csv extension.
2. Open sql/ecommerce_analysis.sql in MySQL Workbench.
3. Execute Steps 0–6 in sequence. All matches_original values in Step 2 should equal 1.
4. Step 5 produces 13 analysis outputs. Compare your results with results/.
5. Source tables remain unchanged; the script creates or replaces views prefixed with v_oa_.

The shared SQL script contains Chinese guidance and English query comments. Both README versions use the same SQL and result files.

## Validation and output provenance
- The project author confirmed successful validation in their local MySQL environment. That session's logs and screenshots are not included.
- The CSVs in results/ were calculated from the original data during project preparation using SQLite with DATE_FORMAT and DATEDIFF adapters. They are not direct exports of the author's MySQL session.
- validation/verification.json records that independent local check. Its mysql_server_execution=false describes that check, not the author's subsequent MySQL validation.
- Exact decimal GMV checks, independent repeat-buyer checks, order-grain checks, and category-total reconciliation passed.
- AI assisted with SQL development and documentation.

## Limitations
The data lacks impressions, clicks, refund events, costs, and experimental assignments. It cannot support a complete conversion funnel, refund rates, profit, ROI, or experimental causal claims. Observed repeat purchasing is not fixed-horizon retention. Sparse September–October 2018 records should not be interpreted as a sudden business decline. Amounts are interpreted as BRL; the CSVs contain no separate currency field.

Raw data is not redistributed here. Obtain it from the source and follow its original license. No new license is granted for the source data.
