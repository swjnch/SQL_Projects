## Pizza Metrics 

1. How many pizzas were ordered?

                             SELECT COUNT(*) AS total_pizzas
                             FROM temp_orders;

![image](https://user-images.githubusercontent.com/104596844/172402407-12e3de69-f389-49dc-8c35-f897dcbf1c13.png)

A total of 14 pizzas were ordered.

2. How many unique customer orders were made?

                            SELECT customer_id,
                                   COUNT(pizza_id) AS total_pizzas,
                                   COUNT(DISTINCT pizza_id) AS unique_orders
                            FROM temp_orders
                            GROUP BY customer_id;
                            
![image](https://user-images.githubusercontent.com/104596844/172403353-ca197899-052e-4458-9732-af41b4207923.png)

Customers 101, 102, 103 had 2 unique orders. Customers 104 and 105 have one unique order each.

3. How many successful orders were delivered by each runner?

                            SELECT runner_id,
                                   COUNT(order_id) orders_delivered
                            FROM temp_runners
                            WHERE cancellation = "Delivered"
                            GROUP BY runner_id;
                            
 ![image](https://user-images.githubusercontent.com/104596844/172404695-edc3d579-7b00-430f-bf5f-95d096949cb4.png)

Runner 1 delivered a total of 4 orders, runner 2 delivered 3 orders and runner 3 delivered one order.
                            
4. How many of each type of pizza was delivered?

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
                         
![image](https://user-images.githubusercontent.com/104596844/172405590-40020811-7274-47e0-aed0-01ef133497b1.png)

A total of 9 Meatlovers pizza were delivered and 3 vegeterian pizzas were delivered.

5. How many Vegetarian and Meatlovers were ordered by each customer?

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
                          
![image](https://user-images.githubusercontent.com/104596844/172406504-b685f0ec-c785-41b4-9dfa-0a0e437a2423.png)

All the customers except 104 ordered single vegeterain pizzas. 

6. What was the maximum number of pizzas delivered in a single order?

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
                          
![image](https://user-images.githubusercontent.com/104596844/172407579-6fa84235-30be-41e6-9459-5ea3e80bae79.png)

A maximum of 3 orders were delivered in a single order for order_id 4.

7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
                          
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
                           
![image](https://user-images.githubusercontent.com/104596844/172408742-1d5fa3d5-77cb-4410-9575-86d1c76d3e39.png)

Customer 103 had maximum number of changes included with the order.

8. How many pizzas were delivered that had both exclusions and extras?

                           WITH extras_pizza AS(
                                        SELECT customer_id,
	                                             SUM(CASE WHEN exclusions <> "" AND extras <> "" THEN 1 ELSE 0 END) AS total_extras
                                        FROM temp_orders
                                        JOIN
                                        temp_runners
                                        USING(order_id)
                                        WHERE cancellation = "Delivered"
                                        GROUP BY customer_id)
                                                        SELECT * FROM extras_pizza
                                                        WHERE total_extras > 0;
                                                        
 ![image](https://user-images.githubusercontent.com/104596844/172410330-ffae36ba-5e46-4478-8226-64f71dc4554d.png)
 
 Only one delivered pizza has both exclusions and extras.

9. What was the total volume of pizzas ordered for each hour of the day?
                        
			SELECT HOUR(order_time) AS hour_of_day,
                               COUNT(order_id) AS total_pizzas
                        FROM temp_orders
                        GROUP BY HOUR(order_time)
                        ORDER BY HOUR(order_time);
			
![image](https://user-images.githubusercontent.com/104596844/173192451-d14988c9-564e-457b-8769-0e5f89e95a15.png)

High volume of pizzas were ordered around 13(1.00 pm), 18(6.00 pm), 21(9.00 pm) and 23(11.00 pm). 

10. What was the volume of orders for each day of the week?

                     SELECT DAYNAME(order_time) AS hour_of_day,
	                    COUNT(order_id) AS total_pizzas
                     FROM temp_orders
                     GROUP BY DAYNAME(order_time)
                     ORDER BY DAY(order_time);
		     
![image](https://user-images.githubusercontent.com/104596844/173192620-5ee6815a-851b-4d66-8ea7-d20bfe5da758.png)

High volumes of pizzas were ordered during Wednesday and Saturday.

