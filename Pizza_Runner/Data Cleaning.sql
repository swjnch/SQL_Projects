                           # Data Cleaning and Transformation
 
 USE pizza_runner;
 
 #CUSTOMER_ORDERS TABLE
 CREATE temporary table temp_orders
 SELECT order_id,
        customer_id,
        pizza_id,
        (CASE
           WHEN exclusions IS NULL OR exclusions = "null" THEN ""
           ELSE exclusions
           END) AS exclusions,
		(CASE
           WHEN extras IS NULL OR exclusions = "null" THEN ""
           ELSE extras
           END) AS extras,
        order_time
FROM customer_orders;
SELECT * FROM temp_orders;

# RUNNER_ORDERS TABLE
CREATE temporary table temp_runners
SELECT order_id,
       runner_id,
	 (CASE
           WHEN pickup_time = "null" OR pickup_time IS NULL OR pickup_time = "" THEN "0000-00-00 00:00:00" 
           ELSE pickup_time
           END) AS pickup_time,
	  (CASE
           WHEN distance = "null" OR distance IS NULL OR distance = "" THEN 0
           WHEN distance LIKE "%km" THEN TRIM(TRAILING 'km' FROM distance)
           ELSE distance
           END) AS distance,
      (CASE
           WHEN duration = "null" OR duration IS NULL OR duration = "" THEN 0
           WHEN duration LIKE "%mins" THEN TRIM(TRAILING 'mins' FROM duration)
           WHEN duration LIKE "%minute" THEN TRIM(TRAILING 'minute' FROM duration)
           WHEN duration LIKE "%minutes" THEN TRIM(TRAILING 'minutes' FROM duration)
           ELSE duration
           END) AS duration,
	  (CASE
           WHEN cancellation = "null" OR cancellation IS NULL OR cancellation = "" THEN "Delivered"
           ELSE cancellation
           END) AS cancellation
FROM runner_orders;
SELECT * FROM temp_runners;

UPDATE temp_runners
  SET pickup_time = STR_TO_DATE(pickup_time, "%Y-%m-%d %H:%i:%s");

ALTER TABLE temp_runners 
  MODIFY COLUMN pickup_time DATETIME NOT NULL,  
  MODIFY COLUMN distance DECIMAL(4,2) NOT NULL,
  MODIFY COLUMN duration INT NOT NULL;
  
  