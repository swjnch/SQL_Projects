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
             LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date) 
             ELSE '2020-12-31' END) AS payment_date
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






           




       
       




