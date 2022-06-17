USE foodie_fi;

with ct as(
SELECT *,
        RANK () OVER (partition by customer_id order by plan_id) AS ranking,
        (CASE 
           WHEN plan_id IN (1,2,3) AND 
				(RANK () OVER (partition by customer_id order by plan_id))=1 THEN 1 END) payment_order,
        LEAD(plan_name,1) OVER (PARTITION BY customer_id ORDER BY start_date) nextplan,
        LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date) enddate
FROM 
subscriptions
JOIN
plans
USING(plan_id)
WHERE year(start_date) = 2020 AND plan_id <> 0)
SELECT *,
         CASE
          WHEN plan_id = 3 AND nextplan IS NULL THEN start_date
          WHEN plan_id = 4 THEN NULL
          WHEN enddate IS NOT NULL THEN enddate ELSE '2020-12-31' END AS payment_date
FROM ct;



           




       
       




