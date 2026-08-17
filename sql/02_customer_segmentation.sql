WITH customer_summary AS (
  SELECT
    customer_unique_id,
    COUNT(DISTINCT o.order_id) AS order_count,
    SUM(price) AS value,
    SUM(price) / COUNT(DISTINCT o.order_id) AS avg_value,
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date,
    DATE_DIFF(MAX(order_purchase_timestamp), MIN(order_purchase_timestamp), DAY) AS customer_lifetime,
    SAFE_DIVIDE(DATE_DIFF(MAX(order_purchase_timestamp), MIN(order_purchase_timestamp), DAY), COUNT(DISTINCT o.order_id) - 1) AS avg_order_interval
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.customers_dataset` AS c
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
    ON c.customer_id = o.customer_id
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_items` AS i
    ON i.order_id = o.order_id
  WHERE order_status = 'delivered'
  GROUP BY customer_unique_id
),

quart AS (
  SELECT
    customer_unique_id,
    value,
    NTILE(4) OVER (ORDER BY value DESC) AS quartile
  FROM customer_summary
)

SELECT
  cs.customer_unique_id,
  cs.value,
  cs.order_count,
  cs.avg_value,
  DATE(cs.first_order_date) AS first_order_date,
  DATE(cs.last_order_date) AS last_order_date,
  cs.customer_lifetime,
  cs.avg_order_interval,
  CASE
    WHEN q.quartile = 1 THEN 'platinum'
    WHEN q.quartile = 2 THEN 'gold'
    WHEN q.quartile = 3 THEN 'silver'
    ELSE 'bronze'
  END AS customer_segment
FROM customer_summary AS cs
INNER JOIN quart AS q
  ON cs.customer_unique_id = q.customer_unique_id
ORDER BY cs.value DESC;