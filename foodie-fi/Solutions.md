## Data Analysis Questions 

USE foodie_fi;

1. How many customers has Foodie-Fi ever had?

             SELECT COUNT(DISTINCT customer_id) AS total_customers
             FROM subscriptions;
                                    
![image](https://user-images.githubusercontent.com/104596844/172413888-82db175e-7eff-47d6-8a62-fccb2057ed21.png)

Foodie-Fi has a total of 1000 customers.

2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

                            SELECT MONTH(start_date) AS  start_month,
                                   plan_name,
	                           COUNT(plan_id) AS count
                            FROM plans
                            JOIN subscriptions USING(plan_id)
                            WHERE plan_id = 0
                            GROUP BY MONTH(start_date)
                            ORDER BY start_month;

![image](https://user-images.githubusercontent.com/104596844/172414552-9d34b2b8-7cfd-41cf-87f0-5f130b6d6d79.png)

The month of March has highest number(94) of trial plan subscriptions.

3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
                                  
                                 SELECT  plan_name,
                                          COUNT(plan_id) as count
                                 FROM plans
                                 JOIN subscriptions USING(plan_id)
                                 WHERE YEAR(start_date) > 2020
                                 GROUP BY plan_id
                                 ORDER BY count;
                                 
 ![image](https://user-images.githubusercontent.com/104596844/172416336-276c0eba-e43b-4aad-8186-0fbfd5f9dc73.png)

Basic Monthly plans has a total of 8 subscribers, pro monthly has 60 subscribers, pro annual has 63 subscribers and there a total of 71 customers that churned.

4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

                              SELECT  COUNT(customer_id) AS customer_count,
                                      ROUND(COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100 , 1) AS churn_percentage 
                              FROM plans
                              JOIN subscriptions USING(plan_id)
                              WHERE plan_id = 4;
                              
![image](https://user-images.githubusercontent.com/104596844/172417176-9527d2b6-588e-4c8d-926a-c26bc224d1a1.png)

Churned percentage rate is 30.7%.

5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

                                 WITH churn_data AS(
                                                    SELECT *, 
                                                           RANK () OVER (partition by customer_id order by plan_id ) ranking
                                                     FROM subscriptions
                                                     JOIN plans USING(plan_id))
                                      SELECT COUNT(customer_id) AS total_customers_churned,
	                                     ROUND(COUNT(customer_id)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions) * 100) AS perc_churn_initial_trail
                                              FROM churn_data
                                              WHERE plan_id = 4 AND ranking = 2;
                                              
 ![image](https://user-images.githubusercontent.com/104596844/172418313-c801361a-9d15-4e6e-a731-ae38f6fb1b5e.png)

92 customers(9%) have churned after there initial trail period.

6. What is the number and percentage of customer plans after their initial free trial?

                           WITH after_trail_cte AS (
                                                   SELECT *, 
                                                         RANK () OVER (partition by customer_id order by plan_id ) ranking
                                                    FROM subscriptions
                                                    JOIN plans USING(plan_id))
                                                     SELECT plan_id,
                                                            plan_name,
                                                             COUNT(*) AS conversions,
                                                             ROUND(100 * COUNT(*)/ (SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS perc_plans
                                                      FROM after_trail_cte
                                                      WHERE ranking = 2
                                                      GROUP BY plan_id
                                                      ORDER BY plan_id;

![image](https://user-images.githubusercontent.com/104596844/172419131-6e56325a-d8bb-4451-ae91-6ceb5c7abedf.png)

There are more number of basic monthly customers(54.6%) subscribed after the initial trail compared to others.

7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

                                 WITH ct_plans AS (
                                                     SELECT *,
                                                            RANK() OVER(PARTITION BY customer_id ORDER BY start_date DESC) AS ranking
                                                     FROM subscriptions 
                                                     JOIN plans USING(plan_id)
                                                     WHERE YEAR(start_date) <= 2020)      
                                                     SELECT plan_name,
                                                            COUNT(*) AS conversions,
                                                            ROUND(100 * COUNT(*)/(SELECT COUNT(DISTINCT customer_id) FROM subscriptions),1) AS perc_plans
                                                     FROM ct_plans
                                                     WHERE ranking = 1
                                                     GROUP BY plan_id
                                                     ORDER BY conversions DESC;
                                                     
 ![image](https://user-images.githubusercontent.com/104596844/172420316-f8c56556-4c24-47d6-bf16-321678de5524.png)

By end of 2020 there are 32.6% of pro monthly subscribers and only 1.9% of trail subcriptions.
       
8. How many customers have upgraded to an annual plan in 2020?

                                        SELECT  plan_name,
                                                COUNT(*) AS total_number
                                        FROM
                                        subscriptions 
                                        JOIN plans USING(plan_id)
                                        WHERE YEAR(start_date) = 2020  AND (plan_id=3);
					
![image](https://user-images.githubusercontent.com/104596844/172437940-213810f2-ba2e-42df-8f19-d3df32b3d006.png)

195 customers have upgraded to pro annual in 2020

9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

                                      WITH trail_date AS (
                                                       SELECT customer_id,
		                                              start_date
                                                       FROM subscriptions 
                                                       WHERE plan_id = 0),
                                     upgrade_data AS (
                                                    SELECT customer_id, 
                                                           start_date as upgrade_date
                                                    FROM subscriptions 
	                                            WHERE plan_id = 3)
                                                    SELECT ROUND(AVG(DATEDIFF(upgrade_date, start_date)),0) as AVG_DAYS
                                                     FROM trail_date 
                                                     JOIN upgrade_data ON trail_date.customer_id=upgrade_data.customer_id;
						   
![image](https://user-images.githubusercontent.com/104596844/172438748-717f8621-4811-416d-8538-62415b76fb0a.png)

On average it would take 105 days to upgrade to annual plan.

10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

                                         WITH trail_date AS (
                                                             SELECT plan_id,
                                                                    customer_id,
                                                                    start_date,
                                                                    plan_name
                                                              FROM subscriptions 
                                                              JOIN plans USING(plan_id)
                                                             WHERE plan_id = 0),
                                          upgrade_data AS (
                                                            SELECT plan_id AS plan_id_upgrade,
                                                                   customer_id,
                                                                  start_date as upgrade_date,
                                                                  plan_name as plan_name_upgrade
                                                           FROM subscriptions 
                                                           JOIN plans USING(plan_id)
	                                                   WHERE plan_id = 3
                                                           ),
                                            grouped_data AS(
                                                              SELECT *,
                                                                     DATEDIFF(upgrade_date, start_date) AS date_diff,
                                                                     CASE 
                                                                          WHEN DATEDIFF(upgrade_date, start_date) < 31 THEN "0-30 days"
	                                                                  WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 31 AND 60 THEN "31-60 days"
	                                                                  WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 61 AND 90 THEN "61-90 days"
									  WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 91 AND 120 THEN "91-120 days"
                                                                          WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 121 AND 150 THEN "121-150 days"
                                                                          WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 151 AND 180 THEN "151-180 days"
                                                                          WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 181 AND 210 THEN "181-210 days"
                                                                          WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 211 AND 240 THEN "211-240 days"
                                                                          WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 241 AND 270 THEN "241-270 days"
                                                                          WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 271 AND 300 THEN "271-300 days"
                                                                          WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 301 AND 330 THEN "301-330 days"
                                                                          WHEN DATEDIFF(upgrade_date, start_date) BETWEEN 331 AND 360 THEN "331-360 days"
                                                                          WHEN DATEDIFF(upgrade_date, start_date) > 360 THEN "360 + days"
                                                                   END AS grouped_dates
                                                                   FROM trail_date 
                                                                   JOIN upgrade_data USING(customer_id))
								      SELECT plan_name_upgrade,
                                                                             grouped_dates,
                                                                             COUNT(*) AS total_customers
                                                                   FROM grouped_data
                                                                   GROUP BY grouped_dates
                                                                   ORDER BY 
                                                                            CASE
                                                                                 WHEN grouped_dates = '0-30 days' THEN 1
                                                                                 WHEN grouped_dates = '31-60 days' THEN 2
                                                                                 WHEN grouped_dates = '61-90 days' THEN 3
                                                                                 WHEN grouped_dates = '91-120 days' THEN 4
                                                                                 WHEN grouped_dates = '121-150 days' THEN 5
                                                                                 WHEN grouped_dates = '151-180 days' THEN 6
                                                                                 WHEN grouped_dates = '181-210 days' THEN 7
                                                                                 WHEN grouped_dates = '211-240 days' THEN 8
                                                                                 WHEN grouped_dates = '241-270 days' THEN 9
                                                                                 WHEN grouped_dates = '271-300 days' THEN 10
                                                                                 WHEN grouped_dates = '301-330 days' THEN 11
                                                                                 WHEN grouped_dates = '331-360 days' THEN 12
                                                                                 WHEN grouped_dates = '360+ days' THEN 13
                                                                                 END;
										 
![image](https://user-images.githubusercontent.com/104596844/172442089-6ca9d8df-b5ee-4e37-a1d8-a43c3ee48e13.png)

There are more customers upgraded betweeen 0-30 days(49 customers)

11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

                                         WITH ct AS(
                                                      SELECT *,
	                                                     RANK () OVER (partition by customer_id order by start_date) ranking FROM 
                                                      subscriptions
                                                      JOIN plans USING(plan_id)
                                                      WHERE (plan_id = 1 OR plan_id=2) AND start_date BETWEEN "2020-01-01" AND "2020-12-31"
                                                      ORDER BY customer_id)
                                                       SELECT COUNT(customer_id) AS count FROM ct
                                                       WHERE plan_id=1 AND ranking = 2;
							
![image](https://user-images.githubusercontent.com/104596844/172442565-c1942883-026c-408d-8383-7570f425c18a.png)

None of the customers downgraded from pro monthly to a basic monthly plan in 2020
							
© 2022 GitHub, Inc.
Terms
Privacy
Security
Status
Doc
