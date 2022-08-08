-- Bonus Question
-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

-- region
-- platform
-- age_band
-- demographic
-- customer_type
-- Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

-- region
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

-- platform
WITH interval_cte AS(
SELECT * FROM clean_weekly_sales
WHERE (week_number BETWEEN 13 AND 36) AND calendar_year = 2020),
sales_cte AS(
SELECT platform,
      SUM(CASE WHEN week_date <('2020-06-15'::date) THEN sales ELSE 0 END) AS beforeJun15_sales,
      SUM(CASE WHEN week_date >= ('2020-06-15'::date) THEN sales ELSE 0 END) AS afterJun15_sales
FROM interval_cte
GROUP BY platform)
SELECT platform,
       beforeJun15_sales,
       afterJun15_sales,
       beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
       ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
FROM sales_cte;

-- age_band
WITH interval_cte AS(
SELECT * FROM clean_weekly_sales
WHERE (week_number BETWEEN 13 AND 36) AND calendar_year = 2020),
sales_cte AS(
SELECT age_band,
      SUM(CASE WHEN week_date <('2020-06-15'::date) THEN sales ELSE 0 END) AS beforeJun15_sales,
      SUM(CASE WHEN week_date >= ('2020-06-15'::date) THEN sales ELSE 0 END) AS afterJun15_sales
FROM interval_cte
GROUP BY age_band)
SELECT age_band,
       beforeJun15_sales,
       afterJun15_sales,
       beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
       ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
FROM sales_cte;

-- demographic
WITH interval_cte AS(
SELECT * FROM clean_weekly_sales
WHERE (week_number BETWEEN 13 AND 36) AND calendar_year = 2020),
sales_cte AS(
SELECT demographic,
      SUM(CASE WHEN week_date <('2020-06-15'::date) THEN sales ELSE 0 END) AS beforeJun15_sales,
      SUM(CASE WHEN week_date >= ('2020-06-15'::date) THEN sales ELSE 0 END) AS afterJun15_sales
FROM interval_cte
GROUP BY demographic)
SELECT demographic,
       beforeJun15_sales,
       afterJun15_sales,
       beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
       ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
FROM sales_cte;

-- customer_type
WITH interval_cte AS(
SELECT * FROM clean_weekly_sales
WHERE (week_number BETWEEN 13 AND 36) AND calendar_year = 2020),
sales_cte AS(
SELECT customer_type,
      SUM(CASE WHEN week_date <('2020-06-15'::date) THEN sales ELSE 0 END) AS beforeJun15_sales,
      SUM(CASE WHEN week_date >= ('2020-06-15'::date) THEN sales ELSE 0 END) AS afterJun15_sales
FROM interval_cte
GROUP BY customer_type)
SELECT customer_type,
       beforeJun15_sales,
       afterJun15_sales,
       beforeJun15_sales - afterJun15_sales :: numeric AS sales_difference,
       ROUND((afterJun15_sales - beforeJun15_sales)*100/beforeJun15_sales::numeric,2) AS growth_rate
FROM sales_cte;
