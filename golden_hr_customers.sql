Q. https://leetcode.com/problems/find-golden-hour-customers/

A.
# Write your MySQL query statement below
WITH cte_metrics AS (
SELECT *,
COUNT(order_id) OVER(PARTITION BY customer_id) AS total_orders,
ROUND(AVG(order_rating) OVER(PARTITION BY customer_id), 2) AS average_rating,

COUNT(CASE 
        WHEN (TIME(order_timestamp) BETWEEN '11:00' AND '14:00') OR 
             (TIME(order_timestamp) BETWEEN '18:00' AND '21:00')
        THEN 1 
        END) OVER(PARTITION BY customer_id) AS peak_hour_ord_count
FROM restaurant_orders
),

cte_metrics_2 AS(
    SELECT *,
        ROUND(100.0 * (peak_hour_ord_count / total_orders) , 2) AS peak_hour_percentage
    FROM cte_metrics
    GROUP BY customer_id
    HAVING COUNT(order_rating) / COUNT(COALESCE(order_rating,1)) > .5
)

SELECT customer_id, total_orders, peak_hour_percentage, average_rating
FROM cte_metrics_2 
GROUP BY customer_id
HAVING total_orders >= 3 AND peak_hour_percentage >= 60 AND average_rating >= 4
ORDER BY average_rating DESC, customer_id DESC



Input
restaurant_orders =
| order_id | customer_id | order_timestamp     | order_amount | payment_method | order_rating |
| -------- | ----------- | ------------------- | ------------ | -------------- | ------------ |
| 1        | 101         | 2024-03-01 12:30:00 | 25.5         | card           | 5            |
| 2        | 101         | 2024-03-02 19:15:00 | 32           | app            | 4            |
| 3        | 101         | 2024-03-03 13:45:00 | 28.75        | card           | 5            |
| 4        | 101         | 2024-03-04 20:30:00 | 41           | app            | null         |
| 5        | 102         | 2024-03-01 11:30:00 | 18.5         | cash           | 4            |
| 6        | 102         | 2024-03-02 12:00:00 | 22           | card           | 3            |
View more
Output
| customer_id | total_orders | peak_hour_percentage | average_rating |
| ----------- | ------------ | -------------------- | -------------- |
| 103         | 3            | 100                  | 4.67           |
| 101         | 4            | 100                  | 4.67           |
| 105         | 3            | 100                  | 4.33           |
Expected
| customer_id | total_orders | peak_hour_percentage | average_rating |
| ----------- | ------------ | -------------------- | -------------- |
| 103         | 3            | 100                  | 4.67           |
| 101         | 4            | 100                  | 4.67           |
| 105         | 3            | 100                  | 4.33           |