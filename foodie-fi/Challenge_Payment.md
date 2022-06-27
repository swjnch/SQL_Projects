

##### The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments

       USE foodie_fi;

       WITH payments_cte AS(
               SELECT customer_id,
                      plan_id,
                      plan_name,
                      start_date,
                      price,
	             (CASE 
                          WHEN plan_id = 4 THEN NULL
                          WHEN plan_id = 3 THEN start_date
                          WHEN LEAD(plan_name,1) OVER (PARTITION BY customer_id ORDER BY start_date) IS NOT NULL THEN 
                               LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date) ELSE '2020-12-31' END) AS payment_date
               FROM foodie_fi.subscriptions
               JOIN foodie_fi.plans USING(plan_id)
               WHERE date_part('year',start_date) = 2020 AND plan_id <> 0),
       series_cte as(
               SELECT customer_id,
                      plan_id,
                      plan_name,
                      generate_series(start_date, payment_date, interval '1 month'+'1 second') AS payment_date,
                      price as amount      
                FROM payments_cte)
                SELECT customer_id,
                       plan_id, 
                       plan_name,
                       payment_date:: date :: varchar,
                       (CASE WHEN LAG(plan_id) OVER (PARTITION BY customer_id ORDER BY payment_date) != plan_id
                             AND DATE_PART('day', payment_date - LAG(payment_date) OVER (PARTITION BY customer_id ORDER BY payment_date)) < 30 
                            THEN (amount - LAG(amount) OVER (PARTITION BY customer_id ORDER BY payment_date)) ELSE amount END) AS amount,
                       RANK() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order 
              FROM series_cte;
	      
	 ![image](https://user-images.githubusercontent.com/104596844/175841695-5d940b63-5ebd-44f2-9b7f-9f1a6d98b212.png)


