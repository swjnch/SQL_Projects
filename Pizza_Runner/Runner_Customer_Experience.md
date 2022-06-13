# Runner and Customer Experience

USE pizza_runner;

1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

       SELECT 
              WEEK(registration_date) AS week_period,
              COUNT(runner_id) AS total_runners
       FROM runners
       GROUP BY WEEK(registration_date);
       
   ![image](https://user-images.githubusercontent.com/104596844/173263210-d0888e79-3867-4e2c-a12e-64840fd38ee9.png)

MySQL considers Sunday or Monday as the start of a week period.If a week starting with Jan 1st has 4 or more days, Week 1 is started with that week or else the week is numbered as last week of previous year.Hence, the week of Jan 1st have only one registered runner, where the following week has 2 runners.

# What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order
WITH pickup_cte AS(
                  SELECT *,
                        TIME_TO_SEC(TIMEDIFF(pickup_time, order_time))/60  AS runner_time
                  FROM temp_runners
                  JOIN temp_orders
                  USING(order_id)
                  WHERE cancellation = "Delivered")
SELECT runner_id,
       ROUND(AVG(runner_time),2) AS avg_time
FROM pickup_cte
WHERE cancellation = "Delivered"
GROUP BY runner_id;

# Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH pickup_cte AS(
SELECT order_id,
        pickup_time,
        order_time,
        (TIME_TO_SEC(TIMEDIFF(pickup_time, order_time))/60)  AS runner_time
FROM temp_orders
JOIN temp_runners
USING(order_id)
WHERE cancellation = "Delivered")
     SELECT order_id,
			COUNT(order_id) AS total_pizzas,
            ROUND(AVG(runner_time),2) AS avg_time
	 FROM pickup_cte
     GROUP BY order_id;
     
# What was the average distance travelled for each customer
SELECT customer_id,
       ROUND(AVG(distance),2) AS avg_distance
FROM temp_orders
JOIN temp_runners
USING(order_id)
WHERE cancellation = "Delivered"
GROUP BY customer_id;

# What was the difference between the longest and shortest delivery times for all orders
SELECT MAX(duration) - MIN(duration) AS delivery_time_diff
FROM temp_runners
WHERE cancellation = "Delivered";

# What was the average speed for each runner for each delivery and do you notice any trend for these values
SELECT runner_id,
       order_id,
	   ROUND((distance/(duration/60)),2) AS avg_speed
FROM temp_orders
JOIN temp_runners
USING(order_id)
WHERE cancellation = "Delivered"
GROUP BY order_id
ORDER BY runner_id, order_id;

# What is the successful delivery percentage for each runner?
WITH deliver_perc AS(
SELECT runner_id,
       COUNT(order_id) as total_ordered,
       SUM(CASE WHEN cancellation = "Delivered" THEN 1 END) AS total_delivered
FROM temp_runners
GROUP BY runner_id)
                SELECT runner_id,
                       ROUND((total_delivered/total_ordered)* 100) AS prec_delivered
				FROM deliver_perc;
				
      
               
