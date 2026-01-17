
Quest

https://leetcode.com/problems/find-churn-risk-customers/



_-----ANS------
# Write your MySQL query statement below
WITH cte_1 AS (
    SELECT *,
    MAX(monthly_amount) OVER (PARTITION BY user_id) AS max_historical_amount,
    DATEDIFF(MAX(event_date) OVER (PARTITION BY user_id), MIN(event_date) OVER (PARTITION BY user_id)) AS days_as_subscriber,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_date DESC, event_id DESC) AS latest_event_rnk
    FROM subscription_events
    WHERE user_id in (
        SELECT DISTINCT user_id
        FROM subscription_events
        WHERE event_type = 'downgrade'
    )
   
)

SELECT user_id, plan_name as current_plan, monthly_amount as current_monthly_amount, max_historical_amount, days_as_subscriber
FROM cte_1
WHERE event_type != 'cancel' AND (monthly_amount / max_historical_amount) < 0.5 AND days_as_subscriber > 60
ORDER BY days_as_subscriber DESC, user_id ASC



Input
subscription_events =
| event_id | user_id | event_date | event_type | plan_name | monthly_amount |
| -------- | ------- | ---------- | ---------- | --------- | -------------- |
| 1        | 501     | 2024-01-01 | start      | premium   | 29.99          |
| 2        | 501     | 2024-02-15 | downgrade  | standard  | 19.99          |
| 3        | 501     | 2024-03-20 | downgrade  | basic     | 9.99           |
| 4        | 502     | 2024-01-05 | start      | standard  | 19.99          |
| 5        | 502     | 2024-02-10 | upgrade    | premium   | 29.99          |
| 6        | 502     | 2024-03-15 | downgrade  | basic     | 9.99           |
View more
Output
| user_id | current_plan | current_monthly_amount | max_historical_amount | days_as_subscriber |
| ------- | ------------ | ---------------------- | --------------------- | ------------------ |
| 501     | basic        | 9.99                   | 29.99                 | 79                 |
| 502     | basic        | 9.99                   | 29.99                 | 70                 |
Expected
| user_id | current_plan | current_monthly_amount | max_historical_amount | days_as_subscriber |
| ------- | ------------ | ---------------------- | --------------------- | ------------------ |
| 501     | basic        | 9.99                   | 29.99                 | 79                 |
| 502     | basic        | 9.99                   | 29.99                 | 70                 |

