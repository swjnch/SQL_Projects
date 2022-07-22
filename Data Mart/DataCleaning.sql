-- Data Cleansing Steps

-- In a single query, perform the following operations and generate a new table in the data_mart schema named clean_weekly_sales:
-- Convert the week_date to a DATE format
-- Add a week_number as the second column for each week_date value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
-- Add a month_number with the calendar month for each week_date value as the 3rd column
-- Add a calendar_year column as the 4th column containing either 2018, 2019 or 2020 values
-- Add a new column called age_band after the original segment column using the following mapping on the number inside the segment value
-- Add a new demographic column using the following mapping for the first letter in the segment values:
-- Ensure all null string values with an "unknown" string value in the original segment column as well as the new age_band and demographic columns
-- Generate a new avg_transaction column as the sales value divided by transactions rounded to 2 decimal places for each record

CREATE TABLE data_mart.clean_weekly_sales AS
SELECT TO_DATE(week_date, 'DD-MM-YY') AS week_date,
       DATE_PART('week',to_date(week_date, 'DD-MM-YY')) AS week_number,
       DATE_PART('month',to_date(week_date, 'DD-MM-YY')) AS month_number,
       DATE_PART('year',to_date(week_date, 'DD-MM-YY')) AS calendar_year,
       CASE WHEN segment='null' THEN 'Unknown' ELSE segment END AS segment,
       CASE WHEN segment LIKE '%1' THEN 'Young Adults'
            WHEN segment LIKE '%2' THEN 'Middle Aged'
            WHEN segment LIKE '%3' OR segment LIKE '%4' THEN 'Retirees'
            WHEN segment='null' THEN 'Unknown'
            END AS age_band,
       CASE WHEN segment LIKE 'C%' THEN 'Couples'
            WHEN segment LIKE 'F%' THEN 'Families'
            WHEN segment='null' THEN 'Unknown'
       END AS demographic,
       region,
       platform,
       customer_type,
       transactions,
       sales,
       ROUND((sales/transactions),2) AS avg_transactions
FROM  data_mart.weekly_sales;