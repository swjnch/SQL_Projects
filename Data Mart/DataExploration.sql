-- Data Exploration

-- What day of the week is used for each week_date value?
SELECT DISTINCT(to_char(week_date, 'Day')) AS "day" FROM clean_weekly_sales ;

-- What range of week numbers are missing from the dataset?
SELECT DISTINCT(week_number) 
 FROM clean_weekly_sales;

WITH series_cte AS(
SELECT * FROM generate_series(1,52))
SELECT * FROM series_cte
WHERE generate_series NOT IN 
(SELECT DISTINCT(week_number) 
 FROM clean_weekly_sales);

-- How many total transactions were there for each year in the dataset?
SELECT calendar_year,
       SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;

-- What is the total sales for each region for each month?
SELECT  region,
        TO_CHAR(TO_DATE(month_number::text,'MM'),'Mon') AS Month_name,
        SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region,month_number
ORDER BY region,month_number;    

-- What is the total count of transactions for each platform?
SELECT platform,
       SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform
ORDER BY platform;

-- What is the percentage of sales for Retail vs Shopify for each month?
WITH sales_cte AS(
SELECT calendar_year,
       month_number,
       SUM(sales) AS total_sales
FROM clean_weekly_sales AS ws
GROUP BY calendar_year, month_number
ORDER BY calendar_year, month_number),
platform_sales AS(
SELECT platform,
       calendar_year,
       month_number,                                                            
       SUM(sales) AS platform_sales
FROM clean_weekly_sales AS ws1
GROUP BY platform, calendar_year, month_number
ORDER BY platform, calendar_year, month_number)
SELECT platform,
       ps.calendar_year,
       TO_CHAR(TO_DATE(ps.month_number::text,'MM'),'Mon') AS Month_name,
       ROUND(platform_sales * 100/total_sales::NUMERIC,2)  AS perc_sales
FROM sales_cte sc
JOIN platform_sales ps
ON sc.calendar_year=ps.calendar_year
AND sc.month_number=ps.month_number;

-- What is the percentage of sales by demographic for each year in the dataset?
WITH sales_cte AS(
SELECT calendar_year,
       SUM(sales) AS yearly_sales
FROM clean_weekly_sales AS ws
GROUP BY calendar_year
ORDER BY calendar_year),
demographic_sales AS(
SELECT demographic,
       calendar_year,                                                           
       SUM(sales) AS demographic_sales
FROM clean_weekly_sales 
GROUP BY demographic, calendar_year
ORDER BY demographic, calendar_year)
SELECT demographic,
       ds.calendar_year,
       ROUND(demographic_sales * 100/yearly_sales::NUMERIC,1)  AS perc_sales
FROM sales_cte sc
JOIN demographic_sales ds
ON sc.calendar_year=ds.calendar_year;

-- Which age_band and demographic values contribute the most to Retail sales?
-- Demographic
SELECT demographic,
       SUM(sales) as total_sales,
       ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER(), 2) AS perc_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY demographic
ORDER BY demographic;

-- Age band
SELECT age_band,
       SUM(sales) as total_sales,
       ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER(), 2) AS perc_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band
ORDER BY age_band;

-- Demographic and Age_band
SELECT demographic,
       age_band,
       SUM(sales) as total_sales,
       SUM(SUM(sales)) OVER(),
       ROUND(100 * SUM(sales)/SUM(SUM(sales)) OVER(), 2) AS perc_sales
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY demographic, age_band
ORDER BY demographic, age_band;

-- Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
SELECT platform,
       calendar_year,
       ROUND(SUM(sales)/SUM(transactions)::NUMERIC,2) AS avg_transactions
FROM clean_weekly_sales
GROUP BY platform, calendar_year;