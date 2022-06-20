# Pricing and Ratings

USE pizza_runner;

1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

          SELECT  
                   SUM(CASE WHEN pizza_id = 1 THEN 12 WHEN pizza_id = 2 THEN 10 END) AS Total_profits
         FROM temp_runners
         JOIN temp_orders USING(order_id)
         WHERE cancellation = "Delivered";
	 
![image](https://user-images.githubusercontent.com/104596844/174685783-6b14da24-d245-4f26-8033-7c2db041b887.png)

Pizza runners had made a total of 138$ for all the pizza delivered

2.What if there was an additional $1 charge for any pizza extras?
   -- Add cheese is $1 extra
  
          WITH cte_recipes AS(
			      SELECT ROW_NUMBER() OVER() AS row_num,
			             order_id,
                                     customer_id,
                                     pizza_id,
                                     (CASE WHEN exclusions IS NULL OR exclusions = "null" THEN "" ELSE exclusion END) AS exclusions,
                                     (CASE WHEN extras IS NULL OR extras = "null" THEN "" ELSE extras END) AS extras,
                                     toppings
                             FROM customer_orders
                             JOIN pizza_recipes USING(pizza_id)
                             JOIN runner_orders USING(order_id)
                             WHERE distance <> "null" and duration <> "null"
                            ),
           extras_cte AS(
                        SELECT row_num,
                               order_id,
                               customer_id,
                               pizza_id,
                                SUBSTRING_INDEX(SUBSTRING_INDEX(cte_recipes.extras, ',', numbers.n), ',', -1) toppings
			FROM
                       (SELECT 1 n UNION ALL SELECT 2)numbers INNER JOIN cte_recipes
                        ON CHAR_LENGTH(cte_recipes.extras)-CHAR_LENGTH(REPLACE(cte_recipes.extras, ',', '')) >= numbers.n-1
                        ORDER BY row_num, pizza_id, n),
           charges_cte AS(
                         SELECT  *,
                                 (CASE WHEN pizza_id = 1 THEN 12 WHEN pizza_id = 2 THEN 10 END) AS total_charges,
                                 SUM(CASE WHEN toppings <> "" THEN 1 END) AS extra_charges
                         FROM extras_cte
                         GROUP BY row_num)
                                          SELECT 
	                                        SUM(CASE WHEN extra_charges IS NULL THEN total_charges
                                                          WHEN extra_charges IS NOT NULL THEN  (total_charges+extra_charges) END) AS total_profit
                                          FROM charges_cte;
					  
![image](https://user-images.githubusercontent.com/104596844/174686816-14693ccf-c766-4f70-b86c-edef830d537d.png)

A total of 142$ was made in profits for the pizza runners if the toppings were charged extra.
 
3.The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
   
          CREATE TABLE ratings_runners AS
          (SELECT * FROM temp_runners
	  WHERE cancellation = "Delivered");

          ALTER TABLE ratings_runners
          ADD COLUMN ratings TINYINT UNSIGNED NULL AFTER cancellation;

          ALTER TABLE ratings_runners
          ADD CONSTRAINT UniqueConstraint CHECK (ratings>0 and ratings<=5);
 
          UPDATE ratings_runners 
          SET ratings = round(1+ rand()*5)

![image](https://user-images.githubusercontent.com/104596844/174687107-8b393369-65a3-44d6-a048-535aa606ac33.png)

4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
   -- customer_id
   -- order_id
   -- runner_id
   -- rating
   -- order_time
   -- pickup_time
   -- Time between order and pickup
   -- Delivery duration
   -- Average speed
   -- Total number of pizzas
   
         CREATE TABLE delivered_table AS(
                                        WITH count_cte AS(
                                                         SELECT order_id,
                                                                 COUNT(pizza_id) AS total_pizzas
			                                 FROM customer_orders
                                                         GROUP BY order_id)
                                                                     SELECT customer_id,
                                                                             order_id,
                                                                             runner_id,
                                                                              ratings,
                                                                              order_time,
                                                                               pickup_time,
                                                                             (TIME_TO_SEC(TIMEDIFF(pickup_time, order_time))/60) AS time_diff,
                                                                             duration,
                                                                            ROUND((distance/(duration/60)),2) AS avg_speed,
                                                                             total_pizzas
                                                                      FROM customer_orders
                                                                      JOIN ratings_runners USING(order_id)
                                                                      JOIN count_cte USING(order_id)
                                                                      WHERE cancellation = "Delivered"
                                                                      GROUP BY customer_id, order_id, runner_id
                                                                      ORDER BY customer_id);
								      
![image](https://user-images.githubusercontent.com/104596844/174687361-0ddae863-1912-4951-bb22-d06841f0053b.png)
   
5.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

        WITH profits_cte AS(
                          SELECT *,
		                  (CASE WHEN pizza_id = 1 THEN 12 ELSE 10 END) AS pizza_cost
                          FROM temp_orders
                          JOIN temp_runners USING (order_id)
                          WHERE cancellation = "Delivered"
                          ORDER BY order_id),
       delivery_cte AS(
                      SELECT order_id,
		             distance,
		             SUM(pizza_cost) AS pizza_cost,
		             round(0.30*distance, 2) AS delivery_cost
                      FROM profits_cte
                      GROUP BY order_id
                      ORDER BY order_id)
                               SELECT SUM(delivery_cost),
                                      SUM(pizza_cost-delivery_cost) AS pizza_runner_revenue
                               FROM delivery_cte;
			       
![image](https://user-images.githubusercontent.com/104596844/174687964-07981a8a-45f2-4816-ac6f-119a3a029212.png)
