#### Data Exploration

1. What day of the week is used for each week_date value?

       SELECT DISTINCT(to_char(week_date, 'Day')) AS "day" FROM clean_weekly_sales ;
 ![image](https://user-images.githubusercontent.com/104596844/184898637-b4425fa5-7465-4245-b8f9-101465476c1e.png)
 
3. What range of week numbers are missing from the dataset?
       
       SELECT DISTINCT(week_number) 
       FROM clean_weekly_sales
       ORDER BY week_number;
 ![image](https://user-images.githubusercontent.com/104596844/184899752-bac4ce48-a0d9-4912-87ca-09b8bde2357b.png)
 
![image](https://user-images.githubusercontent.com/104596844/184900208-925ab32d-d7f3-494e-9993-c586af2fc1c9.png)

      WITH series_cte AS(
      SELECT * FROM generate_series(1,52))
      SELECT * FROM series_cte
      WHERE generate_series NOT IN 
      (SELECT DISTINCT(week_number) 
      FROM clean_weekly_sales);
      
 ![image](https://user-images.githubusercontent.com/104596844/184901652-71ec06d8-2d21-453a-b28c-3861948b6170.png)

![image](https://user-images.githubusercontent.com/104596844/184901833-427f4711-0f34-46a9-93db-7343d8a7db84.png)



 
5. How many total transactions were there for each year in the dataset?
6. What is the total sales for each region for each month?
7. What is the total count of transactions for each platform
8. What is the percentage of sales for Retail vs Shopify for each month?
9. What is the percentage of sales by demographic for each year in the dataset?
10. Which age_band and demographic values contribute the most to Retail sales?
11. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
