WITH customer_value AS (
  SELECT
    c.customer_unique_id,
    SUM(i.price) AS delivered_product_value
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.customers_dataset` AS c
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
    ON c.customer_id = o.customer_id
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_items` AS i
    ON i.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
),

customer_cumulative AS (
  SELECT
    customer_unique_id,
    delivered_product_value,
    SUM(delivered_product_value) OVER (
      ORDER BY delivered_product_value DESC, customer_unique_id
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_value,
    SUM(delivered_product_value) OVER (
      ORDER BY delivered_product_value DESC, customer_unique_id
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
    ) AS value_before_customer,
    SUM(delivered_product_value) OVER () AS total_delivered_product_value
  FROM customer_value
)

SELECT
  cv.customer_unique_id,
  ROUND(cv.delivered_product_value, 2) AS delivered_product_value,
  ROUND(cv.cumulative_value, 2) AS cumulative_value,
  ROUND(
    100 * SAFE_DIVIDE(
      cv.cumulative_value,
      cv.total_delivered_product_value
    ),
    2
  ) AS cumulative_revenue_pct
FROM customer_cumulative AS cv
WHERE COALESCE(cv.value_before_customer, 0)
  < 0.8 * cv.total_delivered_product_value
ORDER BY
  cv.delivered_product_value DESC,
  cv.customer_unique_id;