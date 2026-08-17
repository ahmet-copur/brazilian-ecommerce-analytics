WITH customer_value AS (
  SELECT
    c.customer_unique_id,
    SUM(i.price) AS value
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.customers_dataset` AS c
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
    ON c.customer_id = o.customer_id
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_items` AS i
    ON i.order_id = o.order_id
  WHERE o.order_status = 'delivered'
  GROUP BY c.customer_unique_id
),

cumulative AS (
  SELECT
    customer_unique_id,
    value AS total_spent,
    ROUND(SUM(value) OVER (ORDER BY value DESC), 2) AS cumulative_spent,
    ROUND(SUM(value) OVER (ORDER BY value DESC) / SUM(value) OVER () * 100.0, 2) AS cumulative_pct,
    ROW_NUMBER() OVER (ORDER BY value DESC) AS row_num,
    COUNT(*) OVER () AS customer_count
  FROM customer_value
)

SELECT
  customer_unique_id,
  total_spent,
  cumulative_spent,
  cumulative_pct
FROM cumulative
WHERE row_num <= 0.2 * customer_count
ORDER BY total_spent DESC;