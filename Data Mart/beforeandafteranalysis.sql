-- Before and After analysis

-- This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time.

-- Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect.

-- We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before

-- Using this analysis approach - answer the following questions:

-- What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
SELECT 
  DISTINCT week_number
FROM clean_weekly_sales
WHERE week_date = '2020-06-15';

WITH interval_cte AS(
SELECT * FROM clean_weekly_sales
WHERE (week_number BETWEEN 21 AND 28) AND calendar_year = 2020),
sales_cte AS(
SELECT 
      SUM(CASE WHEN week_date <('2020-06-15'::date) THEN sales ELSE 0 END) AS beforeJun15_sales,
      SUM(CASE WHEN week_date >= ('2020-06-15'::date) THEN sales ELSE 0 END) AS afterJun15_sales
FROM interval_cte)
SELECT 
       beforeJun15_sales,
       afterJun15_sales,
       beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
       ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
FROM sales_cte;

-- What about the entire 12 weeks before and after?
WITH interval_cte AS(
SELECT * FROM clean_weekly_sales
WHERE (week_number BETWEEN 13 AND 36) AND calendar_year = 2020),
sales_cte AS(
SELECT 
      SUM(CASE WHEN week_date <('2020-06-15'::date) THEN sales ELSE 0 END) AS beforeJun15_sales,
      SUM(CASE WHEN week_date >= ('2020-06-15'::date) THEN sales ELSE 0 END) AS afterJun15_sales
FROM interval_cte)
SELECT 
       beforeJun15_sales,
       afterJun15_sales,
       beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
       ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
FROM sales_cte;

-- How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
-- 4 week interval
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

--12 week interval
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










