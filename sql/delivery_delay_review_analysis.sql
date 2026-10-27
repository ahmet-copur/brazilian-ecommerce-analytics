-- Delivery timing and review keyword analysis.
-- This is a simple Portuguese delay-keyword flag, not sentiment analysis or NLP.

WITH reviews_by_order AS (
  SELECT
    order_id,
    AVG(review_score) AS avg_review_score,
    STRING_AGG(review_comment_message, ' ') AS review_comments
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.order_reviews`
  GROUP BY order_id
),

order_delivery AS (
  SELECT
    o.order_id,
    r.avg_review_score,
    r.review_comments,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    CASE
      WHEN o.order_delivered_customer_date IS NULL
        OR o.order_estimated_delivery_date IS NULL
        THEN NULL
      ELSE DATE_DIFF(
        DATE(o.order_delivered_customer_date),
        DATE(o.order_estimated_delivery_date),
        DAY
      )
    END AS delivery_variance_days
  FROM `project-0fcb1613-a88d-45ad-a2e.brazilian_ecommerce.orders` AS o
  LEFT JOIN reviews_by_order AS r
    ON o.order_id = r.order_id
  WHERE o.order_status = 'delivered'
),

classified_orders AS (
  SELECT
    order_id,
    avg_review_score,
    CASE
      WHEN delivery_variance_days IS NULL THEN 'unknown'
      WHEN delivery_variance_days <= 0 THEN 'on_time_or_early'
      ELSE 'late'
    END AS delivery_status,
    CASE
      WHEN review_comments IS NULL OR TRIM(review_comments) = '' THEN 'no_comment'
      WHEN CONTAINS_SUBSTR(LOWER(review_comments), 'atras')
        OR CONTAINS_SUBSTR(LOWER(review_comments), 'demor')
        THEN 'delay_keyword_detected'
      ELSE 'no_delay_keyword_detected'
    END AS review_delay_keyword_status
  FROM order_delivery
)

SELECT
  delivery_status,
  review_delay_keyword_status,
  COUNT(*) AS order_count,
  ROUND(AVG(avg_review_score), 2) AS avg_review_score
FROM classified_orders
GROUP BY
  delivery_status,
  review_delay_keyword_status
ORDER BY
  delivery_status,
  review_delay_keyword_status;
