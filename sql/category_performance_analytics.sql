-- Category performance analytics
-- Revenue is delivered product value (price only); freight and costs are excluded.
-- Cancellation rate uses all orders with categorized products as its denominator.

WITH order_base AS (
  SELECT
    o.order_id,
    COALESCE(
      NULLIF(t.string_field_1, ''),
      NULLIF(p.product_category_name, ''),
      'uncategorized'
    ) AS category_name,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    SUM(i.price) AS order_value
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_items` AS i
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
    ON i.order_id = o.order_id
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.products` AS p
    ON i.product_id = p.product_id
  LEFT JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.product_category_name_translation` AS t
    ON p.product_category_name = t.string_field_0
  GROUP BY
    o.order_id,
    category_name,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date
)

SELECT
  category_name,
  COUNT(DISTINCT order_id) AS total_orders,
  COUNT(DISTINCT IF(order_status = 'delivered', order_id, NULL)) AS delivered_orders,
  COUNT(DISTINCT IF(order_status = 'canceled', order_id, NULL)) AS canceled_orders,
  ROUND(
    100 * SAFE_DIVIDE(
      COUNT(DISTINCT IF(order_status = 'canceled', order_id, NULL)),
      COUNT(DISTINCT order_id)
    ),
    2
  ) AS cancellation_rate_pct,
  ROUND(
    SUM(IF(order_status = 'delivered', order_value, 0)),
    2
  ) AS delivered_product_revenue,
  ROUND(
    AVG(
      IF(
        order_status = 'delivered'
          AND order_delivered_customer_date IS NOT NULL
          AND DATE(order_delivered_customer_date) >= DATE(order_purchase_timestamp),
        DATE_DIFF(
          DATE(order_delivered_customer_date),
          DATE(order_purchase_timestamp),
          DAY
        ),
        NULL
      )
    ),
    1
  ) AS avg_delivery_days
FROM order_base
GROUP BY category_name
ORDER BY delivered_product_revenue DESC;
