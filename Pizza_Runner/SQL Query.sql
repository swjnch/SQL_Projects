                          # Pizza Metrics
                          
# How many pizzas were ordered?
SELECT COUNT(*) AS total_pizzas
FROM temp_orders;

# How many unique customer orders were made?
SELECT customer_id,
      COUNT(pizza_id) AS total_pizzas,
      COUNT(DISTINCT pizza_id) AS unique_orders
FROM temp_orders
GROUP BY customer_id;

# How many successful orders were delivered by each runner?
SELECT runner_id,
       COUNT(order_id) orders_delivered
FROM temp_runners
WHERE cancellation = "Delivered"
GROUP BY runner_id;

# How many of each type of pizza was delivered?
SELECT pizza_name,
       COUNT(pizza_id) AS total_deilvered
FROM temp_orders
JOIN
temp_runners
USING(ORDER_ID)
JOIN 
pizza_names
USING(pizza_id)
WHERE cancellation = "Delivered"
GROUP BY pizza_id;

# How many Vegetarian and Meatlovers were ordered by each customer?
SELECT customer_id, 
       pizza_name,
       count(pizza_id) AS pizza_orders			 
FROM temp_orders
JOIN
temp_runners
USING(ORDER_ID)
JOIN 
pizza_names
USING(pizza_id)
GROUP BY customer_id, pizza_id
ORDER BY customer_id;

# What was the maximum number of pizzas delivered in a single order?
SELECT order_id,
       count(pizza_id) AS max_order
FROM temp_orders
JOIN
temp_runners
USING(order_id)
WHERE cancellation = "Delivered"
GROUP BY order_id
ORDER BY count(pizza_id) DESC
LIMIT 1;

# For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT customer_id,
       SUM(CASE 
                WHEN exclusions = "" AND extras = "" THEN 1 ELSE 0 END) AS no_changes, 
	   SUM(CASE 
                WHEN exclusions <> "" OR extras <> "" THEN 1 ELSE 0 END) AS atleast_1_change
FROM temp_orders
JOIN
temp_runners
USING(order_id)
WHERE cancellation = "Delivered"
GROUP BY customer_id;

# How many pizzas were delivered that had both exclusions and extras?
WITH extras_pizza AS(
SELECT customer_id,
	   SUM(CASE 
                WHEN exclusions <> "" AND extras <> "" THEN 1 ELSE 0 END) AS total_extras
FROM temp_orders
JOIN
temp_runners
USING(order_id)
WHERE cancellation = "Delivered"
GROUP BY customer_id)

SELECT * FROM extras_pizza
WHERE total_extras > 0;

# What was the total volume of pizzas ordered for each hour of the day?


# What was the volume of orders for each day of the week?
                                
                                # Runner and Customer Experience
How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
Is there any relationship between the number of pizzas and how long the order takes to prepare?
What was the average distance travelled for each customer?
What was the difference between the longest and shortest delivery times for all orders?
What was the average speed for each runner for each delivery and do you notice any trend for these values?
What is the successful delivery percentage for each runner?

								#Ingredient Optimisation
What are the standard ingredients for each pizza?
What was the most commonly added extra?
What was the most common exclusion?
Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

                                             