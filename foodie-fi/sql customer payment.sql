USE foodie_fi;

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
             ELSE '2020-12-31' END) AS payment_date,
       RANK() OVER(PARTITION BY customer_id ORDER BY start_date) AS payment_order
FROM foodie_fi.subscriptions
JOIN foodie_fi.plans USING(plan_id)
WHERE date_part('year',start_date) = 2020 AND plan_id <> 0;



           




       
       




