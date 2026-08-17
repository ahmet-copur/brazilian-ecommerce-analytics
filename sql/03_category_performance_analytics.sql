WITH order_base AS (
  SELECT
    o.order_id,
    t.string_field_1 AS category_name,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    SUM(i.price) AS order_value
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_items` AS i
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
    ON i.order_id = o.order_id
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.products` AS p
    ON i.product_id = p.product_id
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.product_category_name_translation` AS t
    ON p.product_category_name = t.string_field_0
  GROUP BY
    o.order_id,
    t.string_field_1,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date
)

SELECT
  category_name,
  COUNT(DISTINCT order_id) AS total_orders,
  ROUND(SUM(order_value), 2) AS total_revenue,
  COUNT(DISTINCT CASE WHEN order_status = 'canceled' THEN order_id END) AS canceled_orders,
  ROUND(
    100.0 * COUNT(DISTINCT CASE WHEN order_status = 'canceled' THEN order_id END)
    / NULLIF(COUNT(DISTINCT order_id), 0),
    2
  ) AS cancel_rate_pct,
  ROUND(
    AVG(DATE_DIFF(DATE(order_delivered_customer_date), DATE(order_purchase_timestamp), DAY)),
    1
  ) AS avg_delivery_days
FROM order_base
WHERE order_status IN ('delivered', 'canceled') -- Sadece anlamlı durumları dahil et
GROUP BY category_name
ORDER BY total_revenue DESC;