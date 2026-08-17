WITH summary AS (
  SELECT
    o.order_id,
    r.review_score,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    DATE_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY) AS delivery_day,
    r.review_comment_message
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
  JOIN `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_reviews` AS r
    ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
)

SELECT
  CASE
    WHEN delivery_day <= 0 THEN 'fast_delivery'
    ELSE 'late_delivery'
  END AS delivery_status,
  CASE
    WHEN CONTAINS_SUBSTR(review_comment_message, 'atras')
      OR CONTAINS_SUBSTR(review_comment_message, 'demor') THEN 'delay_complaint'
    ELSE 'no_delay_complaint'
  END AS text_status,
  COUNT(DISTINCT order_id) AS total_order,
  ROUND(AVG(review_score), 2) AS avg_review_score
FROM summary
GROUP BY
  delivery_status,
  text_status
ORDER BY delivery_status;