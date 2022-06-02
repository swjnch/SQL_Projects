USE foodie_fi;

# How many customers has Foodie-Fi ever had?
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM subscriptions;

# What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT MONTH(start_date) AS  start_month,
       plan_name,
	   COUNT(plan_id) AS count
FROM
plans
JOIN
subscriptions 
USING(plan_id)
WHERE plan_id = 0
GROUP BY MONTH(start_date)
ORDER BY start_month;

# What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT  plan_name,
        COUNT(plan_id) as count
FROM
plans
JOIN
subscriptions 
USING(plan_id)
WHERE start_date > "2020-12-31"
GROUP BY plan_id
ORDER BY count;

# What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT  COUNT(customer_id) AS customer_count,
        ROUND(COUNT(customer_id)/
             (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100 , 1) AS churn_percentage 
FROM
plans
JOIN
subscriptions 
USING(plan_id)
WHERE plan_id = 4;

# How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH churn_data AS(
 SELECT 
  *, 
  RANK () OVER (partition by customer_id order by plan_id ) ranking
FROM subscriptions
JOIN
plans 
USING(plan_id))
SELECT COUNT(customer_id) AS total_customers_churned,
	   ROUND(COUNT(customer_id)/
             (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100) AS perc_churn_initial_trail
FROM churn_data
WHERE plan_id = 4 AND ranking = 2;

# What is the number and percentage of customer plans after their initial free trial?
WITH after_trail_cte AS (
SELECT 
  *, 
  RANK () OVER (partition by customer_id order by plan_id ) ranking
FROM subscriptions
JOIN
plans 
USING(plan_id))
SELECT 
  plan_id,
  plan_name,
  COUNT(*) AS conversions,
  ROUND(100 * COUNT(*)/ 
                       (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS perc_plans
FROM after_trail_cte
WHERE ranking = 2
GROUP BY plan_id
ORDER BY plan_id;

# What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH ct_plans AS (
    SELECT
      *,
      RANK() OVER(PARTITION BY customer_id ORDER BY start_date DESC) AS ranking
    FROM
      subscriptions 
      JOIN plans USING(plan_id)
    WHERE
      start_date <= '2020-12-31')      
SELECT
  plan_name,
  COUNT(*) AS conversions,
  ROUND(100 * COUNT(*)/ 
                       (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS perc_plans
FROM ct_plans
WHERE ranking = 1
GROUP BY plan_id
ORDER BY conversions DESC;
       
# How many customers have upgraded to an annual plan in 2020?
SELECT  plan_name,
        COUNT(*) AS total_number
FROM
subscriptions 
JOIN plans USING(plan_id)
WHERE start_date BETWEEN "2020-01-01" AND "2020-12-31" AND (plan_id=3);

# How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
WITH trail_date AS (
    SELECT customer_id,
		   start_date
    FROM subscriptions 
    WHERE plan_id = 0
),
upgrade_data AS (
    SELECT customer_id, 
           start_date as upgrade_date
    FROM subscriptions 
	WHERE plan_id = 3
)
SELECT ROUND(AVG(DATEDIFF(upgrade_date, start_date)),2) as AVG_DAYS
FROM trail_date 
JOIN 
upgrade_data
ON trail_date.customer_id=upgrade_data.customer_id;

# Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
WITH trail_date AS (
    SELECT plan_id,
           customer_id,
           start_date,
           plan_name
    FROM subscriptions 
    JOIN plans
    USING(plan_id)
    WHERE plan_id = 0
),
upgrade_data AS (
    SELECT plan_id AS plan_id_upgrade,
           customer_id,
           start_date as upgrade_date,
           plan_name as plan_name_upgrade
    FROM subscriptions 
    JOIN plans 
    USING(plan_id)
	WHERE plan_id = 3
),
grouped_data AS(
SELECT *,
      DATEDIFF(upgrade_date, start_date) AS date_diff,
      CASE 
      WHEN DATEDIFF(upgrade_date, start_date) < 31 THEN "0-30 days"
	  WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 31 AND 60 THEN "31-60 days"
	  WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 61 AND 90 THEN "61-90 days"
      WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 91 AND 120 THEN "91-120 days"
      WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 121 AND 150 THEN "121-150 days"
      WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 151 AND 180 THEN "151-180 days"
      WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 181 AND 210 THEN "181-210 days"
      WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 211 AND 240 THEN "211-240 days"
      WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 241 AND 270 THEN "241-270 days"
      WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 271 AND 300 THEN "271-300 days"
      WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 301 AND 330 THEN "301-330 days"
      WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 331 AND 360 THEN "331-360 days"
      WHEN DATEDIFF(upgrade_date, start_date) > 360 THEN "360 + days"
      END AS grouped_dates
FROM trail_date 
JOIN 
upgrade_data
USING(customer_id))

SELECT 
      plan_name_upgrade,
      grouped_dates,
      COUNT(*) AS total_customers, 
      ROUND(AVG(date_diff),2) AS AVERAGE
FROM grouped_data
GROUP BY grouped_dates
ORDER BY 
CASE
    WHEN grouped_dates = '0-30 days' THEN 1
    WHEN grouped_dates = '31-60 days' THEN 2
    WHEN grouped_dates = '61-90 days' THEN 3
    WHEN grouped_dates = '91-120 days' THEN 4
    WHEN grouped_dates = '121-150 days' THEN 5
    WHEN grouped_dates = '151-180 days' THEN 6
    WHEN grouped_dates = '181-210 days' THEN 7
    WHEN grouped_dates = '211-240 days' THEN 8
    WHEN grouped_dates = '241-270 days' THEN 9
    WHEN grouped_dates = '271-300 days' THEN 10
    WHEN grouped_dates = '301-330 days' THEN 11
    WHEN grouped_dates = '331-360 days' THEN 12
    WHEN grouped_dates = '360+ days' THEN 13
  END;

# How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH ct AS(
SELECT *,
	RANK () OVER (partition by customer_id order by start_date) ranking FROM 
subscriptions
JOIN
plans
USING(plan_id)
WHERE plan_id = 1 OR plan_id=2
ORDER BY customer_id)
SELECT * FROM ct
WHERE plan_id=1 AND ranking = 2;
