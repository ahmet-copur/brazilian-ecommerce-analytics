-- RFM segmentation using delivered orders only.
-- Monetary value is product price; freight is excluded.
-- The analysis reference date is one day after the latest delivered purchase.

WITH order_summary AS (
  SELECT
    c.customer_unique_id,
    o.order_id,
    MAX(o.order_purchase_timestamp) AS purchase_timestamp,
    SUM(i.price) AS order_value
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

analysis_date AS (
  SELECT
    DATE_ADD(DATE(MAX(purchase_timestamp)), INTERVAL 1 DAY) AS reference_date
  FROM order_summary
),

customer_rfm AS (
  SELECT
    os.customer_unique_id,
    DATE_DIFF(
      ad.reference_date,
      DATE(MAX(os.purchase_timestamp)),
      DAY
    ) AS recency_days,
    COUNT(DISTINCT os.order_id) AS frequency,
    ROUND(SUM(os.order_value), 2) AS monetary
  FROM order_summary AS os
  CROSS JOIN analysis_date AS ad
  GROUP BY
    os.customer_unique_id,
    ad.reference_date
),

rfm_scores AS (
  SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    NTILE(4) OVER (ORDER BY recency_days DESC) AS recency_score,
    NTILE(4) OVER (ORDER BY frequency ASC) AS frequency_score,
    NTILE(4) OVER (ORDER BY monetary ASC) AS monetary_score
  FROM customer_rfm
)

SELECT
  customer_unique_id,
  recency_days,
  frequency,
  monetary,
  recency_score,
  frequency_score,
  monetary_score,
  CONCAT(
    CAST(recency_score AS STRING),
    CAST(frequency_score AS STRING),
    CAST(monetary_score AS STRING)
  ) AS rfm_score,
  CASE
    WHEN recency_score >= 3 AND frequency_score >= 3 AND monetary_score >= 3
      THEN 'champions'
    WHEN frequency_score >= 3 AND recency_score >= 2
      THEN 'loyal customers'
    WHEN recency_score >= 3 AND frequency_score <= 2
      THEN 'recent customers'
    WHEN recency_score <= 2 AND frequency_score >= 3
      THEN 'at risk'
    ELSE 'others'
  END AS customer_segment
FROM rfm_scores
ORDER BY recency_score DESC, frequency_score DESC, monetary_score DESC;
