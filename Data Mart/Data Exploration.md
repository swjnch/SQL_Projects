#### Data Exploration

1. What day of the week is used for each week_date value?

       SELECT DISTINCT(to_char(week_date, 'Day')) AS "day" FROM clean_weekly_sales ;
 ![image](https://user-images.githubusercontent.com/104596844/184898637-b4425fa5-7465-4245-b8f9-101465476c1e.png)
 
3. What range of week numbers are missing from the dataset?
 
 Let's look into the week numbers of the aggregated sales in the dataset.
 
       SELECT DISTINCT(week_number) 
       FROM clean_weekly_sales
       ORDER BY week_number;
 
 Weeks 13-36 are present in the dataset

      WITH series_cte AS(
      SELECT * FROM generate_series(1,52))
      SELECT * FROM series_cte
      WHERE generate_series NOT IN 
      (SELECT DISTINCT(week_number) 
      FROM clean_weekly_sales);
      
  Week numbers in the range 1-12 and 37-52 are not included in the dataset.
 
5. How many total transactions were there for each year in the dataset?
    
         SELECT calendar_year,
                SUM(transactions) AS total_transactions
         FROM clean_weekly_sales
         GROUP BY calendar_year
         ORDER BY calendar_year;
      
![image](https://user-images.githubusercontent.com/104596844/184906048-1d0191de-f029-4273-8cd0-017c379f20a4.png)

7. What is the total sales for each region for each month?
     
       SELECT region,
              TO_CHAR(TO_DATE(month_number::text,'MM'),'Mon') AS Month_name,
              SUM(sales) AS total_sales
       FROM clean_weekly_sales
       GROUP BY region,month_number
       ORDER BY region,month_number; 
       
Refer to monthly_regional_sales.csv

9. What is the total count of transactions for each platform

       SELECT platform,
              SUM(transactions) AS total_transactions
       FROM clean_weekly_sales
       GROUP BY platform
       ORDER BY platform;
       
![image](https://user-images.githubusercontent.com/104596844/184915710-83bb1568-a9f1-4677-aff0-b360e3501f4a.png)
       
11. What is the percentage of sales for Retail vs Shopify for each month?

            SELECT platform,
                   calendar_year,
                  TO_CHAR(TO_DATE(month_number::text,'MM'),'Mon') AS Month_name,
                  SUM(sales) AS total_sales,
                 ROUND(SUM(sales)*100 / SUM(SUM(sales)) OVER(PARTITION BY calendar_year, month_number)::NUMERIC, 2) AS perc_sales
            FROM clean_weekly_sales 
            GROUP BY platform, calendar_year, month_number
            ORDER BY platform, calendar_year, month_number;
            
 Refer to monthly_platform_Sales.csv in repository
 
13. What is the percentage of sales by demographic for each year in the dataset?

           SELECT calendar_year,
                  demographic,
                  SUM(sales) AS total_sales,
                  ROUND(SUM(sales)*100 / SUM(SUM(sales)) OVER(PARTITION BY calendar_year)::NUMERIC, 2) AS perc_sales
           FROM clean_weekly_sales AS ws
           GROUP BY demographic, calendar_year
           ORDER BY demographic, calendar_year;
           
 ![image](https://user-images.githubusercontent.com/104596844/184914189-b93911ff-bc87-4230-8fda-cb83a2239905.png)
 
 In the year 2020 both Couples and Families contributed to the highest percentage of sales. Compartively, Families had greater percentage of sales each year than couples. Also, the unknowm demographics had higher sales compared to Families and couples.

14. Which age_band and demographic values contribute the most to Retail sales?

Demographic

          SELECT demographic,
                 SUM(sales) as total_sales,
                 ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER(), 2) AS perc_sales
           FROM clean_weekly_sales
           WHERE platform = 'Retail'
           GROUP BY demographic
           ORDER BY demographic;
           
![image](https://user-images.githubusercontent.com/104596844/184911678-3b1131f9-76fc-44b5-8deb-cebb88e2da93.png)

Age band

         SELECT age_band,
                SUM(sales) as total_sales,
                ROUND(100 * SUM(sales) / SUM(SUM(sales)) OVER(), 2) AS perc_sales
         FROM clean_weekly_sales
         WHERE platform = 'Retail'
         GROUP BY age_band
         ORDER BY age_band;
         
![image](https://user-images.githubusercontent.com/104596844/184912123-3269d381-b221-4afb-b534-f72a15b31de7.png)

Demographic and Age_band

        SELECT demographic,
               age_band,
               SUM(sales) as total_sales,
               SUM(SUM(sales)) OVER(),
               ROUND(100 * SUM(sales)/SUM(SUM(sales)) OVER(), 2) AS perc_sales
        FROM clean_weekly_sales
        WHERE platform = 'Retail'
        GROUP BY demographic, age_band
        ORDER BY demographic, age_band;
        
![image](https://user-images.githubusercontent.com/104596844/184913151-fbd12c9d-d478-4a26-903f-27b93ba8fd31.png)

In each of the demographics, Retirees have the most retail sales. The primary reason could be the ease of internet usage among Middle age and young adults.

15. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

         SELECT platform,
                calendar_year,
                ROUND(SUM(sales)/SUM(transactions)::NUMERIC,2) AS avg_transactions
        FROM clean_weekly_sales
        GROUP BY platform, calendar_year;
        
![image](https://user-images.githubusercontent.com/104596844/184910730-db397771-82c2-4c9f-bd16-d03cac3e9a8b.png)

