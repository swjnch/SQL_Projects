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

2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order

       WITH pickup_cte AS(
                  SELECT *,
                        TIME_TO_SEC(TIMEDIFF(pickup_time, order_time))/60  AS runner_time
                  FROM temp_runners
                  JOIN temp_orders
                  USING(order_id)
                  WHERE cancellation = "Delivered"
		  )
                   SELECT runner_id,
                          ROUND(AVG(runner_time),2) AS avg_time
                   FROM pickup_cte
                   WHERE cancellation = "Delivered"
                   GROUP BY runner_id;
		   
![image](https://user-images.githubusercontent.com/104596844/173264130-b2c48b62-6f26-40ae-9748-123b37faec0a.png)

In order to convert the time difference between pickup time and order time to minutes, the results was divided by 60. Runner_id 3 has the least average time of 10.47 minutes where as Runner_id 2 has the highest average.

3.Is there any relationship between the number of pizzas and how long the order takes to prepare?

       WITH pickup_cte AS(
                    SELECT order_id,
                           pickup_time,
                           order_time,
                           (TIME_TO_SEC(TIMEDIFF(pickup_time, order_time))/60)  AS runner_time
                    FROM temp_orders
                    JOIN temp_runners
                    USING(order_id)
                    WHERE cancellation = "Delivered"
		    )
                      SELECT order_id,
			      COUNT(order_id) AS total_pizzas,
                              ROUND(AVG(runner_time),2) AS avg_time
	             FROM pickup_cte
                     GROUP BY order_id;
		     
![image](https://user-images.githubusercontent.com/104596844/173264648-dcce43ad-dab9-45ac-b632-26e021624543.png)

As we can see from the result an order of 3 pizzas took about an average of 29 minutes and an order of 1 pizza had an average of 10 minutes preparation time. The only exception here is the order_id 8 with only 1 pizza took about 20 minutes. The more pizzas included in the order the preparation time would increase. 
     
4. What was the average distance travelled for each customer

        SELECT customer_id,
               ROUND(AVG(distance),2) AS avg_distance
       FROM temp_orders
       JOIN temp_runners
       USING(order_id)
       WHERE cancellation = "Delivered"
       GROUP BY customer_id;
       
![image](https://user-images.githubusercontent.com/104596844/173265070-337a5e0b-144c-493d-b8c2-f3743eeafad9.png)

The distance travelled for customer 105(25 km) is the maximum average distance. 

5.What was the difference between the longest and shortest delivery times for all orders
  
       SELECT 
             MAX(duration) - MIN(duration) AS delivery_time_diff
       FROM temp_runners
       WHERE cancellation = "Delivered";
       
![image](https://user-images.githubusercontent.com/104596844/173265269-59492586-4395-4391-9101-e7752eb950d9.png)

30 minutes is the time difference between longest and shortest delivery times.

6. What was the average speed for each runner for each delivery and do you notice any trend for these values

             SELECT runner_id,
                    order_id,
	            ROUND((distance/(duration/60)),2) AS avg_speed
            FROM temp_runners
            WHERE cancellation = "Delivered"
            GROUP BY order_id
            ORDER BY runner_id, order_id;
	    
![image](https://user-images.githubusercontent.com/104596844/173265627-c50c8618-0d04-41eb-a3f7-19dc5c706c32.png)

Average speed = (Distance travelled/Total time) km/hr

Runner_id 2 average speed ranges from 35km/hr to 93km/hr which has lot of fluctuation. 

7. What is the successful delivery percentage for each runner?

         WITH deliver_perc AS(
                     SELECT runner_id,
                            COUNT(order_id) as total_ordered,
                            SUM(CASE WHEN cancellation = "Delivered" THEN 1 END) AS total_delivered
                   FROM temp_runners
                   GROUP BY runner_id)
                                SELECT runner_id,
                                ROUND((total_delivered/total_ordered)* 100) AS prec_delivered
				FROM deliver_perc;
				
![image](https://user-images.githubusercontent.com/104596844/173266454-8c4b0133-fe40-4f1d-9fbb-97d712cbe318.png)

To calculate the delivery percentage, orders that are delivered successfully were divided total orders for each runner. Runner 1 delivered 100% of the orders he recieved, where 2 and 3 delivered 75% and 50% respectively due to restaurant and customer cancellations.
				
      
               
