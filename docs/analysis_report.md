[English](analysis_report.md) | [简体中文](analysis_report.zh-CN.md)

# Analysis Report

## Metric definitions
GMV is the sum of item prices for orders whose final status is delivered, excluding freight. Average order value is that GMV divided by delivered orders. Monthly trends use the purchase month. Recorded payment amounts and merchandise value have different scopes and must not be used interchangeably.

Buyers are identified using customer_unique_id. A repeat buyer has at least two delivered orders within the observation window. An order is late when its actual delivery date is later than its estimated date; eight delivered orders without an actual delivery timestamp are excluded. Low scores mean an average review score of 2 or less within an order. Orders receive equal weight.

## Data quality
- The geolocation table contains 261,831 excess exact duplicate rows. ZIP prefixes are not unique; deduplicate and aggregate before joining.
- There are 2,961 orders with multiple payment records and 547 with multiple reviews. Aggregate each detail table to order level before joining.
- No orphan rows were found across six core foreign-key relationships. Product category information and translations have missing values.
- There are 775 orders without items, one without a payment, and 768 without reviews; retain them and inspect by status.
- Categories are missing for 610 products; another 13 products belong to two categories without English mappings.
- Among orders with items and payments, 303 have an absolute difference greater than BRL 0.01 between recorded payments and merchandise plus freight. Further business information is needed to explain these differences.

## Findings
1. There are 96,478 delivered orders, with merchandise GMV of BRL 13,221,498.11 and average order value of BRL 137.04.
2. health_beauty, watches_gifts, and bed_bath_table account for 9.33%, 8.82%, and 7.74% of delivered merchandise GMV. These shares do not imply profitability.
3. From May to June 2018, GMV falls from BRL 977,544.69 to BRL 856,077.86 (-12.43%); delivered orders fall from 6,749 to 6,099, and average order value from BRL 144.84 to BRL 140.36.
4. watches_gifts declines by BRL 34,337.41, contributing 28.27% of the net category decline. This is an arithmetic decomposition, not causal attribution.
5. Of 96,470 delivery-eligible orders, 6,534 arrive late (6.77%). Low-score shares for late and on-time groups are 62.36% and 9.23%. Further stratification by region, month, and category is needed.
6. There are 93,358 delivered-order buyers and 2,801 repeat buyers, giving an observed repeat-buyer share of 3.00%.

## Recommendations and next steps
Monitor monthly GMV, orders, average order value, and delivery performance for major categories. Supplement June's changes with traffic, inventory, and campaign information. Investigate delivery patterns by destination and seller, without automatically assigning a multi-seller order's delay to an individual seller.

The dataset lacks traffic events, refunds, costs, and experimental assignments. It cannot demonstrate conversion rates, profit, ROI, or realized business improvements. Boundary months and unequal buyer observation windows affect interpretation.

## Validation
The author confirmed local MySQL validation. Repository result CSVs retain the actual reference outputs generated during project preparation using SQLite with date-function adapters; they are not exports from that MySQL session. GMV was independently checked using exact decimal summation, and repeat buyers using separate grouping. See the README and validation/ for details.
