-- Monthly customer retention cohorts based on each customer's first delivered order.
-- Recent cohorts have incomplete observation windows and should not be compared
-- with older cohorts for retention months that have not yet elapsed.

WITH first_order_time AS (
  SELECT
    c.customer_unique_id,
    MIN(o.order_purchase_timestamp) AS first_order_timestamp
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.customers_dataset` AS c
    ON c.customer_id = o.customer_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
),

orders_with_cohort AS (
  SELECT
    c.customer_unique_id,
    DATE_TRUNC(DATE(f.first_order_timestamp), MONTH) AS cohort_month,
    DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
    DATE_DIFF(
      DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH),
      DATE_TRUNC(DATE(f.first_order_timestamp), MONTH),
      MONTH
    ) AS month_number
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.customers_dataset` AS c
    ON c.customer_id = o.customer_id
  JOIN first_order_time AS f
    ON f.customer_unique_id = c.customer_unique_id
  WHERE o.order_status = 'delivered'
),

cohort_activity AS (
  SELECT
    cohort_month,
    month_number,
    COUNT(DISTINCT customer_unique_id) AS active_customers
  FROM orders_with_cohort
  WHERE month_number BETWEEN 0 AND 3
  GROUP BY
    cohort_month,
    month_number
),

cohort_sizes AS (
  SELECT
    cohort_month,
    active_customers AS cohort_size
  FROM cohort_activity
  WHERE month_number = 0
),

data_coverage AS (
  SELECT
    MAX(DATE_TRUNC(DATE(order_purchase_timestamp), MONTH)) AS latest_order_month
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders`
  WHERE order_status = 'delivered'
)

SELECT
  FORMAT_DATE('%Y-%m', cs.cohort_month) AS cohort_month,
  cs.cohort_size,
  MAX(IF(ca.month_number = 0, ca.active_customers, NULL)) AS month_0_customers,
  100.0 AS month_0_retention_pct,
  MAX(IF(ca.month_number = 1, ca.active_customers, NULL)) AS month_1_customers,
  CASE
    WHEN DATE_DIFF(dc.latest_order_month, cs.cohort_month, MONTH) >= 1 THEN
      ROUND(
        100 * SAFE_DIVIDE(
          COALESCE(MAX(IF(ca.month_number = 1, ca.active_customers, NULL)), 0),
          cs.cohort_size
        ),
        2
      )
  END AS month_1_retention_pct,
  MAX(IF(ca.month_number = 2, ca.active_customers, NULL)) AS month_2_customers,
  CASE
    WHEN DATE_DIFF(dc.latest_order_month, cs.cohort_month, MONTH) >= 2 THEN
      ROUND(
        100 * SAFE_DIVIDE(
          COALESCE(MAX(IF(ca.month_number = 2, ca.active_customers, NULL)), 0),
          cs.cohort_size
        ),
        2
      )
  END AS month_2_retention_pct,
  MAX(IF(ca.month_number = 3, ca.active_customers, NULL)) AS month_3_customers,
  CASE
    WHEN DATE_DIFF(dc.latest_order_month, cs.cohort_month, MONTH) >= 3 THEN
      ROUND(
        100 * SAFE_DIVIDE(
          COALESCE(MAX(IF(ca.month_number = 3, ca.active_customers, NULL)), 0),
          cs.cohort_size
        ),
        2
      )
  END AS month_3_retention_pct
FROM cohort_sizes AS cs
JOIN cohort_activity AS ca
  ON ca.cohort_month = cs.cohort_month
CROSS JOIN data_coverage AS dc
GROUP BY
  cs.cohort_month,
  cs.cohort_size,
  dc.latest_order_month
ORDER BY cs.cohort_month;
