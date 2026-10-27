-- Monthly delivered product sales by purchase month.
-- Revenue is product price only; freight, refunds, and costs are excluded.
-- A calendar spine keeps missing months in the series for valid MoM comparisons.

WITH order_summary AS (
  SELECT
    o.order_id,
    DATE_TRUNC(DATE(o.order_purchase_timestamp), MONTH) AS order_month,
    SUM(i.price) AS delivered_product_revenue
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_items` AS i
    ON o.order_id = i.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY
    o.order_id,
    order_month
),

monthly_summary AS (
  SELECT
    order_month,
    COUNT(DISTINCT order_id) AS delivered_orders,
    SUM(delivered_product_revenue) AS delivered_product_revenue
  FROM order_summary
  GROUP BY order_month
),

calendar_months AS (
  SELECT order_month
  FROM UNNEST(
    GENERATE_DATE_ARRAY(
      (SELECT MIN(order_month) FROM monthly_summary),
      (SELECT MAX(order_month) FROM monthly_summary),
      INTERVAL 1 MONTH
    )
  ) AS order_month
),

monthly_series AS (
  SELECT
    cm.order_month,
    COALESCE(ms.delivered_orders, 0) AS delivered_orders,
    COALESCE(ms.delivered_product_revenue, 0) AS delivered_product_revenue
  FROM calendar_months AS cm
  LEFT JOIN monthly_summary AS ms
    ON cm.order_month = ms.order_month
),

monthly_metrics AS (
  SELECT
    order_month,
    delivered_orders,
    delivered_product_revenue,
    SUM(delivered_product_revenue) OVER (
      ORDER BY order_month
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_delivered_product_revenue,
    LAG(delivered_product_revenue) OVER (
      ORDER BY order_month
    ) AS previous_month_revenue,
    AVG(delivered_product_revenue) OVER (
      ORDER BY order_month
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3_month_average,
    COUNT(*) OVER (
      ORDER BY order_month
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS months_in_rolling_window
  FROM monthly_series
)

SELECT
  order_month,
  delivered_orders,
  ROUND(delivered_product_revenue, 2) AS delivered_product_revenue,
  ROUND(cumulative_delivered_product_revenue, 2) AS cumulative_delivered_product_revenue,
  ROUND(previous_month_revenue, 2) AS previous_month_revenue,
  ROUND(
    100 * SAFE_DIVIDE(
      delivered_product_revenue - previous_month_revenue,
      previous_month_revenue
    ),
    2
  ) AS mom_growth_pct,
  IF(
    months_in_rolling_window = 3,
    ROUND(rolling_3_month_average, 2),
    NULL
  ) AS rolling_3_month_avg
FROM monthly_metrics
ORDER BY order_month;
