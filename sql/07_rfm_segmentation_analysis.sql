WITH order_summary AS (
  SELECT
    c.customer_unique_id,
    o.order_id,
    MAX(o.order_purchase_timestamp) AS last_purchase_date,
    SUM(i.price) AS value
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.customers_dataset` AS c
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
    ON c.customer_id = o.customer_id
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_items` AS i
    ON i.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY
    c.customer_unique_id,
    o.order_id
),

last_order_date AS (
  SELECT
    MAX(order_purchase_timestamp) AS last_order
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders`
),

last_check AS (
  SELECT
    os.customer_unique_id,
    DATE_DIFF(MIN(l.last_order), MAX(os.last_purchase_date), DAY) AS recency_days,
    COUNT(DISTINCT os.order_id) AS frequency,
    ROUND(SUM(os.value), 2) AS monetary
  FROM order_summary AS os
  CROSS JOIN last_order_date AS l
  GROUP BY os.customer_unique_id
)

SELECT
  customer_unique_id,
  recency_days,
  frequency,
  monetary,
  NTILE(4) OVER (ORDER BY monetary) AS monetary_quartile
FROM last_check
ORDER BY monetary_quartile;