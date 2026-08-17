WITH summary_list AS (
  SELECT
    o.order_id,
    DATE(o.order_purchase_timestamp) AS order_date,
    SUM(i.price) AS revenue
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_items` AS i
    ON o.order_id = i.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY
    o.order_id,
    order_date
),

monthly_summary AS (
  SELECT
    DATE_TRUNC(order_date, MONTH) AS year_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(revenue), 2) AS monthly_revenue
  FROM summary_list
  GROUP BY year_month
),

final_check AS (
  SELECT
    year_month,
    total_orders,
    monthly_revenue,
    ROUND(
      SUM(monthly_revenue) OVER (
        ORDER BY year_month
      ),
      2
    ) AS running_total_revenue,
    LAG(monthly_revenue) OVER (
      ORDER BY year_month
    ) AS previous_month_revenue
  FROM monthly_summary
)

SELECT
  year_month,
  total_orders,
  monthly_revenue,
  running_total_revenue,
  previous_month_revenue,
  ROUND(
    SAFE_DIVIDE(
      monthly_revenue - previous_month_revenue,
      previous_month_revenue
    ) * 100,
    2
  ) AS mom_growth_pct,
  ROUND(
    AVG(monthly_revenue) OVER (
      ORDER BY year_month
      ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ),
    2
  ) AS rolling_3_month_avg
FROM final_check
ORDER BY year_month;