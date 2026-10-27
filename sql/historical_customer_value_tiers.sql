-- Historical customer value and spend-based tiers, not predictive customer
-- lifetime value (CLV) or a behavioral loyalty measure. Monetary value is
-- delivered product price; freight and costs are excluded. NTILE can split
-- customers with tied spend values.

WITH customer_summary AS (
  SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS delivered_order_count,
    SUM(i.price) AS delivered_product_value,
    SAFE_DIVIDE(
      SUM(i.price),
      COUNT(DISTINCT o.order_id)
    ) AS avg_delivered_order_value,
    MIN(o.order_purchase_timestamp) AS first_delivered_purchase,
    MAX(o.order_purchase_timestamp) AS last_delivered_purchase,
    DATE_DIFF(
      DATE(MAX(o.order_purchase_timestamp)),
      DATE(MIN(o.order_purchase_timestamp)),
      DAY
    ) AS observed_customer_lifetime_days,
    SAFE_DIVIDE(
      DATE_DIFF(
        DATE(MAX(o.order_purchase_timestamp)),
        DATE(MIN(o.order_purchase_timestamp)),
        DAY
      ),
      COUNT(DISTINCT o.order_id) - 1
    ) AS avg_days_between_delivered_orders
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.customers_dataset` AS c
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
    ON c.customer_id = o.customer_id
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_items` AS i
    ON i.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
),

customer_tiers AS (
  SELECT
    customer_unique_id,
    NTILE(4) OVER (ORDER BY delivered_product_value DESC) AS spend_quartile
  FROM customer_summary
)

SELECT
  cs.customer_unique_id,
  ROUND(cs.delivered_product_value, 2) AS delivered_product_value,
  cs.delivered_order_count,
  ROUND(cs.avg_delivered_order_value, 2) AS avg_delivered_order_value,
  DATE(cs.first_delivered_purchase) AS first_delivered_purchase_date,
  DATE(cs.last_delivered_purchase) AS last_delivered_purchase_date,
  cs.observed_customer_lifetime_days,
  ROUND(cs.avg_days_between_delivered_orders, 1) AS avg_days_between_delivered_orders,
  ct.spend_quartile,
  CASE ct.spend_quartile
    WHEN 1 THEN 'platinum'
    WHEN 2 THEN 'gold'
    WHEN 3 THEN 'silver'
    ELSE 'bronze'
  END AS spend_tier
FROM customer_summary AS cs
JOIN customer_tiers AS ct
  ON cs.customer_unique_id = ct.customer_unique_id
ORDER BY cs.delivered_product_value DESC;
