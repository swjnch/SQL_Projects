#### Bonus Question

Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

region
platform
age_band
demographic
customer_type
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

region

         WITH interval_cte AS(
                       SELECT * FROM clean_weekly_sales
                       WHERE (week_number BETWEEN 13 AND 36) AND calendar_year = 2020),
         sales_cte AS(
                   SELECT region,
                          SUM(CASE WHEN week_date <('2020-06-15'::date) THEN sales ELSE 0 END) AS beforeJun15_sales,
                          SUM(CASE WHEN week_date >= ('2020-06-15'::date) THEN sales ELSE 0 END) AS afterJun15_sales
                  FROM interval_cte
                  GROUP BY region)
        SELECT region,
              beforeJun15_sales,
              afterJun15_sales,
              beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
              ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
      FROM sales_cte
      ORDER BY region;
      
 ![image](https://user-images.githubusercontent.com/104596844/184921615-e3a53882-876c-4d1a-b5d7-73eadaea4598.png)

platform

![image](https://user-images.githubusercontent.com/104596844/184921820-b8868830-b691-4ad4-a700-2d6bf34d170d.png)

age_band

![image](https://user-images.githubusercontent.com/104596844/184922079-bc72fd0a-c17b-448a-b0b7-bd9ecb385910.png)

demographic

![image](https://user-images.githubusercontent.com/104596844/184922259-da345c09-f889-4f08-9aae-362175680698.png)

customer_type

![image](https://user-images.githubusercontent.com/104596844/184922448-9a9bc89d-27d1-42b6-bfa9-76e7e574e5dc.png)




