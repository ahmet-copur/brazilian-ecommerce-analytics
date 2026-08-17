WITH first_order_time AS (
  SELECT
    customer_unique_id,
    MIN(order_purchase_timestamp) AS first_order_date
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.customers_dataset` AS c
    ON c.customer_id = o.customer_id
  WHERE order_status = 'delivered'
  GROUP BY customer_unique_id
),

all_orders_with_cohort AS (
  SELECT
    c1.customer_unique_id,
    order_purchase_timestamp,
    first_order_date,
    DATE_DIFF(DATE(order_purchase_timestamp), DATE(first_order_date), MONTH) AS month_diff
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o1
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.customers_dataset` AS c1
    ON c1.customer_id = o1.customer_id
  JOIN first_order_time AS f
    ON f.customer_unique_id = c1.customer_unique_id
  WHERE order_status = 'delivered'
)

SELECT
  FORMAT_DATE('%Y-%m', first_order_date) AS cohort_month,
  COUNT(DISTINCT customer_unique_id) AS cohort_size,
  COUNT(DISTINCT CASE WHEN month_diff = 1 THEN customer_unique_id END) AS month_1_retained,
  COUNT(DISTINCT CASE WHEN month_diff = 2 THEN customer_unique_id END) AS month_2_retained,
  COUNT(DISTINCT CASE WHEN month_diff = 3 THEN customer_unique_id END) AS month_3_retained
FROM all_orders_with_cohort
GROUP BY cohort_month
ORDER BY cohort_month ASC;