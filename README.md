# Olist Brazilian E-Commerce Analytics

An end-to-end analytics portfolio project exploring Brazilian e-commerce order, customer, product, and delivery data from Olist. The project uses SQL and Python for analysis and Power BI for interactive reporting.

The goal is to turn the raw data into clear, explainable business insights—not just to create charts. Each metric is defined so that its meaning and limitations are clear.

## Project at a glance

- **Business domain:** Brazilian e-commerce
- **Dataset:** Olist Brazilian E-Commerce Public Dataset
- **Period covered:** 2016–2018
- **Tools:** BigQuery SQL, Python (pandas, NumPy), Power BI
- **Report pages:** Executive Overview, Customer Segmentation, Product Category Performance, Sales Trends, Delivery & State Performance, and State Sales Performance

## Business questions

This project explores questions such as:

- How much product sales value was recorded, and how did it change month by month?
- Which product categories had the highest delivered sales and order volumes?
- How were customers distributed across RFM segments?
- How did repeat purchasing and customer retention change across cohorts?
- How often were delivered orders late, on time/early, or missing delivery-date information?
- How did sales and delivery performance vary across Brazilian states?
- How did late-delivery history relate to customer RFM characteristics?

## Power BI report

The report is organized around business questions rather than individual source tables:

| Page | Purpose |
|---|---|
| **Executive Overview** | Summarizes sales, orders, cancellation, delivery timing, leading categories, and monthly sales. |
| **Customer Segmentation** | Explores Recency, Frequency, Monetary value, and customer segments. |
| **Product Category Performance** | Compares category sales, order counts, cancellation rates, and delivery days. |
| **Sales Trends** | Shows monthly delivered orders and product sales, month-over-month growth, and a rolling average. |
| **Delivery & State Performance** | Compares delivery status, late rates, and freight value across states. |
| **State Sales Performance** | Maps and compares delivered product sales and orders by state. |

Add report screenshots to a `screenshots/` folder before publishing, then embed them here. For example:

```markdown
![Executive Overview](screenshots/executive-overview.png)
```

The editable Power BI report is `powerbi/Olist_Brazilian_Ecommerce_Analytics.pbix` if you choose to include it in the repository. Check the file size and GitHub's current file limits first; large PBIX files may need Git LFS or a separate download link.

## Analyses and code

### SQL

The SQL scripts are written for BigQuery and use fully qualified table names. Replace project-specific identifiers with your own before publishing or running them.

| File | Analysis |
|---|---|
| `sql/monthly_sales_trend_growth_analysis.sql` | Monthly delivered product sales, delivered orders, cumulative sales, prior-month sales, month-over-month growth, and a three-month rolling average. |
| `sql/category_performance_analytics.sql` | Delivered sales and orders, canceled orders, cancellation rate, and average delivery days by product category. |
| `sql/delivery_delay_review_analysis.sql` | Delivery timeliness and review comments containing simple Portuguese delay-related keywords. |
| `sql/rfm_segmentation_analysis.sql` | Customer-level Recency, Frequency, Monetary value, scores, and segments, using delivered orders. |
| `sql/cohort_retention_analysis.sql` | Monthly customer cohorts and retention for the first four cohort months. |
| `sql/historical_customer_value_tiers.sql` | Historical delivered product spend, repeat-order behavior, and spend-based tiers. This is not predictive customer lifetime value. |
| `sql/pareto_customer_value_analysis.sql` | Customers ranked by delivered product sales and their cumulative contribution toward 80% of sales. |

### Python

The scripts use pandas and NumPy to analyze the Olist CSV files:

| File | Analysis |
|---|---|
| `python/rfm_segmentation.py` | Calculates customer RFM metrics and assigns customer segments; saves a customer-level CSV used by the delivery analysis. |
| `python/delivery_logistics_analysis.py` | Summarizes customer delivery history and compares RFM metrics for customers with and without late deliveries. Run this after the RFM script. |
| `python/category_performance_analysis.py` | Calculates category-level delivered sales, freight, order counts, cancellation rates, and freight-to-product-sales ratios. |

## Dataset

The project is based on the public [Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). The original public release is commonly listed with the following approximate table sizes:

| Source table | Approximate rows |
|---|---:|
| `olist_customers_dataset` | 99,441 |
| `olist_geolocation_dataset` | 1,000,163 |
| `olist_order_items_dataset` | 112,650 |
| `olist_order_payments_dataset` | 103,886 |
| `olist_order_reviews_dataset` | 99,224 |
| `olist_orders_dataset` | 99,441 |
| `olist_products_dataset` | 32,951 |
| `olist_sellers_dataset` | 3,095 |
| `product_category_name_translation` | 71 |

These are reference counts for the commonly distributed original files, not a guarantee about every downloaded or transformed copy. Verify the actual CSV row counts and table names used in your BigQuery project before publishing. SQL joins, filters, and aggregation change the number of rows in each analysis result.

The analysis uses product prices, order statuses, timestamps, customer identifiers, seller identifiers, product categories, delivery dates, and review data. Raw source data is not included in this repository; download it from the dataset source and follow its current license and usage terms.

## Metric definitions

- **Delivered product sales:** Sum of `price` for items in delivered orders. Freight is excluded. This is sales value, not profit.
- **Freight value:** Sum of `freight_value`; it is reported separately from product sales.
- **Delivered orders:** Distinct delivered orders within the analysis grouping. A multi-category or multi-seller order may appear in more than one group, so grouped counts should not be added as if they were company-wide unique orders.
- **Cancellation rate by category:** Canceled orders divided by all orders associated with products in that category. Categories may overlap when an order contains products from multiple categories.
- **Delivery status:** A delivered order is `late` when its customer delivery date is after its estimated delivery date; otherwise it is `on time or early`. Missing dates are `unknown` and should not be included in the known-date late-rate denominator.
- **Month-over-month growth:** `(current month sales - previous month sales) / previous month sales`. It is undefined when previous-month sales are zero; such values should remain blank rather than being presented as a meaningful percentage.
- **RFM:** Recency is days since the customer's latest delivered purchase relative to the analysis reference date; Frequency is distinct delivered orders; Monetary is delivered item price, excluding freight.
- **Historical customer value:** Observed delivered product sales in the dataset period. It is not a forecast of future spend or profit.

## Important methodology note

The SQL and Python RFM scripts currently use different scoring designs: SQL uses four score groups and a smaller set of segment rules, while Python uses five score groups and a more detailed segment set. Their segment counts and labels are therefore not expected to match exactly. Treat them as separate implementations unless the scoring and segment rules are deliberately aligned.

Likewise, percentage fields calculated in SQL or Python may be expressed on a 0–100 scale (for example, `6.77`) rather than as a ratio (for example, `0.0677`). Check the output scale before applying Power BI percentage formatting to avoid multiplying a percentage by 100 twice.

The review-comment check is a basic keyword flag for Portuguese words related to delays. It is not sentiment analysis, a full language model, or proof that a review is about delivery.

## Running the Python scripts

Install the required packages:

```bash
python -m pip install pandas numpy
```

Before running a script, update its `data_folder` and output-folder paths to locations on your computer. The scripts intentionally do not download data automatically.

Run the analyses from the repository root:

```bash
python python/rfm_segmentation.py
python python/delivery_logistics_analysis.py
python python/category_performance_analysis.py
```

Run the RFM script before the delivery script because the latter reads the RFM output CSV. The category analysis is independent. Output CSVs are generated locally and should not be committed unless they are intentionally included and contain no restricted or sensitive data.

## Repository structure

```text
olist-ecommerce-analytics/
├── README.md
├── sql/
│   ├── category_performance_analytics.sql
│   ├── cohort_retention_analysis.sql
│   ├── delivery_delay_review_analysis.sql
│   ├── historical_customer_value_tiers.sql
│   ├── monthly_sales_trend_growth_analysis.sql
│   ├── pareto_customer_value_analysis.sql
│   └── rfm_segmentation_analysis.sql
├── python/
│   ├── category_performance_analysis.py
│   ├── delivery_logistics_analysis.py
│   └── rfm_segmentation.py
├── powerbi/
│   └── Olist_Brazilian_Ecommerce_Analytics.pbix
└── screenshots/
    └── [report page screenshots]
```

This structure is a suggested organization. Keep only files that are actually present in the repository and update the paths in this README if your folder names differ.

## Current findings

The current Power BI report indicates:

- Approximately **R$13.22M** in delivered product sales, with freight excluded.
- Approximately **96.48K delivered orders** and an overall cancellation rate displayed around **0.63%**.
- **Health & beauty**, **watches & gifts**, and **bed bath table** are among the leading categories by delivered product sales in the category summary.
- **São Paulo** is the leading state by delivered product sales in the state analysis.
- The report's delivery summary shows a late rate around **6.77%**, calculated among orders with known delivery dates.

These values are transcribed from the current report and should be rechecked against the final PBIX and query outputs before publication. Display rounding, filters, and metric definitions can affect the shown values. They are descriptive results for this dataset, not causal conclusions about the business.

## Limitations

- The dataset represents a historical period (2016–2018), not current e-commerce activity.
- Product sales use item price and exclude freight, discounts, costs, refunds, and profit calculations unless stated otherwise.
- Missing delivery dates are kept distinct as unknown; excluding them from rates can affect comparisons.
- State comparisons can reflect differences in order volume. A high rate in a low-volume state should be interpreted alongside its order count.
- Category and seller groupings can include the same order in multiple groups.
- Customer segments and spend tiers depend on the scoring rules and reference date selected.

## Before publishing

- Replace any project-specific BigQuery IDs and local computer paths.
- Confirm that dataset redistribution and any included screenshots or report files comply with the dataset license and applicable privacy requirements.
- Verify row counts, KPI values, percentage formats, and report page names against the final files.
- Add final Power BI screenshots and ensure all links and repository paths in this README match the committed structure.
- Do not commit credentials, private customer information, or machine-specific configuration files.

**Business Perspective**

This project is informed by 10 years of retail experience. That background helped shape the business questions explored in the analysis, including product performance, customer behavior, sales trends, and delivery operations.
