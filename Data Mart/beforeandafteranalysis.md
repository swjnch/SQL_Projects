#### Before and After analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

Using this analysis approach - answer the following questions:

1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

First step is to identify the week_number for '2020-06-15' and sort data before and after 4 weeks. Using, the SUM with CASE statement allows to aggregate before and after sales. Using the formula (present_value - past_value) * 100 / past_value the growth or reduction rate is estimated.

              SELECT DISTINCT week_number
              FROM clean_weekly_sales
              WHERE week_date = '2020-06-15';
              
 ![image](https://user-images.githubusercontent.com/104596844/184919663-344f07b6-64f2-4046-ac90-17c4ba8d7812.png)


              WITH interval_cte AS(
                                SELECT * FROM clean_weekly_sales
                                WHERE (week_number BETWEEN 21 AND 28) AND calendar_year = 2020),
             sales_cte AS(
                          SELECT 
                                  SUM(CASE WHEN week_date <('2020-06-15'::date) THEN sales ELSE 0 END) AS beforeJun15_sales,
                                  SUM(CASE WHEN week_date >= ('2020-06-15'::date) THEN sales ELSE 0 END) AS afterJun15_sales
                         FROM interval_cte)
             SELECT beforeJun15_sales,
                    afterJun15_sales,
                    beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
                    ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
             FROM sales_cte;
             
  ![image](https://user-images.githubusercontent.com/104596844/184919868-362d2f65-b2ca-47ca-be04-bc124716d62a.png)
  
   There is a 1.15% of reduction in sales after the implementation of sustainable packing. 

2. What about the entire 12 weeks before and after?

              WITH interval_cte AS(
                                 SELECT * FROM clean_weekly_sales
                                 WHERE (week_number BETWEEN 13 AND 36) AND calendar_year = 2020),
              sales_cte AS(
                            SELECT 
                                 SUM(CASE WHEN week_date <('2020-06-15'::date) THEN sales ELSE 0 END) AS beforeJun15_sales,
                                 SUM(CASE WHEN week_date >= ('2020-06-15'::date) THEN sales ELSE 0 END) AS afterJun15_sales
                            FROM interval_cte)
               SELECT beforeJun15_sales,
                      afterJun15_sales,
                      beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
                      ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
               FROM sales_cte;
               
 ![image](https://user-images.githubusercontent.com/104596844/184920132-e60f4526-e0db-48cd-9327-a59362119fce.png)
 
 The approach is similar to the above problem with different timelines. Within, the 12 week timeframe there is a reduction of 2.14% is total sales.
 

3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

4 week interval

               WITH interval_cte AS(
                               SELECT * FROM clean_weekly_sales
                               WHERE (week_number BETWEEN 21 AND 28) AND calendar_year IN (2020,2019,2018)),
               sales_cte AS(
                           SELECT calendar_year,
                                  SUM(CASE WHEN week_number BETWEEN 21 AND 24 THEN sales ELSE 0 END) AS beforeJun15_sales,
                                  SUM(CASE WHEN week_number BETWEEN 25 AND 28 THEN sales ELSE 0 END) AS afterJun15_sales
                           FROM interval_cte
                           GROUP BY calendar_year)
               SELECT calendar_year,
                      beforeJun15_sales,
                      afterJun15_sales,
                      beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
                      ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
               FROM sales_cte
               ORDER BY calendar_year;
               
![image](https://user-images.githubusercontent.com/104596844/184920699-cc991ca1-49e4-49cd-bbac-893531a89c86.png)

For the 4 week intervals there isn't significant growth in sales for the year 2018 and 2019.

12 week interval

               WITH interval_cte AS(
                             SELECT * FROM clean_weekly_sales
                             WHERE (week_number BETWEEN 13 AND 36) AND calendar_year IN (2020,2019,2018)),
              sales_cte AS(
                         SELECT calendar_year,
                                SUM(CASE WHEN week_number BETWEEN 13 AND 24 THEN sales ELSE 0 END) AS beforeJun15_sales,
                                SUM(CASE WHEN week_number BETWEEN 25 AND 36 THEN sales ELSE 0 END) AS afterJun15_sales
                         FROM interval_cte
                         GROUP BY calendar_year)
               SELECT calendar_year,
                       beforeJun15_sales,
                       afterJun15_sales,
                        beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
                       ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
               FROM sales_cte
               ORDER BY calendar_year;

![image](https://user-images.githubusercontent.com/104596844/184920845-b7efcdc7-37c8-47f8-bbf2-4756f078278b.png)

For the 12 week intervals there is slight decrease in sales for the year 2019 and 2018 has 1.63% growth in sales.












