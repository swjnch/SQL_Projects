To test out a few different hypotheses - the Data Bank team wants to run an experiment where different groups of customers would be allocated data using 3 different options:

- Option 1: data is allocated based off the amount of money at the end of the previous month
- Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days
- Option 3: data is updated real-time

For this multi-part challenge question - you have been requested to generate the following data elements to help the Data Bank team estimate how much data will need to be provisioned for each option:

- running customer balance column that includes the impact each transaction

          WITH txn_cte AS(
                      SELECT customer_id,
                             txn_date,
                             SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE - txn_amount END) AS txn_amt 
                     FROM data_bank.customer_transactions
                     GROUP BY customer_id, txn_date
                    ORDER BY customer_id, txn_date),
          balance_cte AS(
                      SELECT *,
	                         SUM(txn_amt) over(PARTITION BY customer_id ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance
                      FROM txn_cte)
          SELECT * FROM balance_cte;

- customer balance at the end of each month

          CREATE TEMPORARY TABLE closing_balance AS(
                                         WITH txn_cte AS(
                                                      SELECT customer_id,
                                                             (date_trunc('month', txn_date) + interval '1 month - 1 day') AS txn_month,
                                                             SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE - txn_amount END) AS txn_amt 
                                                       FROM data_bank.customer_transactions
                                                       GROUP BY customer_id, txn_month
                                                       ORDER BY customer_id, txn_month),
                                         closing_cte AS(
                                                         SELECT *,
	                                                       SUM(txn_amt) over(PARTITION BY customer_id
	                                                       ORDER BY txn_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
                                                         FROM txn_cte),
                                         end_month AS(
                                                        SELECT DISTINCT customer_id,
                                                               ('2020-01-31'::date + (generate_series(0,3,1) * INTERVAL'1 MONTH')) AS end_month
                                                        FROM data_bank.customer_transactions
                                                       ORDER BY customer_id, end_month),
                                         balance_cte AS(
                                                        SELECT e.customer_id,
                                                               e.end_month,
                                                               ce.txn_amt,
                                                               ce.closing_balance
                                                        FROM end_month e
                                                        LEFT JOIN closing_cte ce
                                                        ON e.end_month = ce.txn_month
                                                       AND e.customer_id = ce.customer_id),
                                         apr_cte AS(                 
                                                     SELECT * FROM balance_cte
                                                     WHERE DATE_PART('MONTH', end_month) IN (1,2,3) OR closing_balance IS NOT NULL),
                                         mar_cte AS(
                                                     SELECT *,
                                                           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY end_month DESC) row_num
                                                     FROM apr_cte),
                                         mar_cte2 AS(
                                                    SELECT * FROM mar_cte
                                                    WHERE row_num IN (2,3,4) OR closing_balance IS NOT NULL),
                                        feb_cte AS(
                                                    SELECT *,
                                                           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY end_month DESC) row_num1
                                                    FROM mar_cte2),
                                        feb_cte2 AS(
                                                  SELECT * FROM feb_cte
                                                   WHERE row_num1 <> 1 OR closing_balance IS NOT NULL),
                                        count_cte AS(
                                                  SELECT customer_id,
                                                         end_month AS txn_month,
                                                         txn_amt AS transaction_balance,
                                                         closing_balance,
                                                         count(closing_balance) OVER(PARTITION BY customer_id order by end_month) as _grp
                                                  FROM feb_cte2
                                                  ORDER BY customer_id, txn_month),
                                        final_cte AS(
                                                   SELECT customer_id,
                                                          txn_month,
                                                          CASE WHEN transaction_balance ISNULL THEN 0 ELSE transaction_balance END AS transaction_balance,
                                                          FIRST_VALUE(closing_balance) OVER(PARTITION BY customer_id,_grp ORDER BY _grp) AS closing_balance
                                                   FROM count_cte
                                                   ORDER BY customer_id, txn_month)
                                                   SELECT * FROM final_cte);
						   
				         SELECT * FROM closing_balance;

   
- minimum, average and maximum values of the running balance for each customer

          WITH txn_cte AS(
                SELECT customer_id,
                       txn_date,
                       SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE - txn_amount END) AS txn_amt 
               FROM data_bank.customer_transactions
               GROUP BY customer_id, txn_date
              ORDER BY customer_id, txn_date),
          balance_cte AS(
                SELECT *,
                       SUM(txn_amt) over(PARTITION BY customer_id ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance
                FROM txn_cte)
           SELECT customer_id,
                  MIN(txn_amt) AS MIN_BALANCE,
                  MAX(txn_amt) AS MAX_BALANCE,
                  ROUND(AVG(txn_amt),2) AS AVG_BALANCE
            FROM balance_cte
            GROUP BY customer_id
            ORDER BY customer_id;

Using all of the data available - how much data would have been required for each option on a monthly basis?

##### Option 1: data is allocated based off the amount of money at the end of the previous month

           SELECT txn_month,
                  SUM(CASE WHEN closing_balance >= 0 THEN closing_balance END) AS total_amount
           FROM closing_balance
           GROUP BY txn_month
           ORDER BY txn_month;
	   
![image](https://user-images.githubusercontent.com/104596844/176984746-8b89abfc-d09a-4bf6-bb23-84f9e300ac02.png)


##### Option 2: data is allocated on the average amount of money kept in the account in the previous 30 days

           SELECT txn_month,
                  ROUND(avg(CASE WHEN closing_balance >= 0 THEN closing_balance END),2) AS avg_amt 
           FROM closing_balance
           GROUP BY txn_month
	   ORDER BY txn_nonth;
 
 ![image](https://user-images.githubusercontent.com/104596844/176984844-9c9ecf09-84e3-4531-8b09-40e18f25a8aa.png)
         
##### Option 3: data is updated real-time

           WITH txn_cte AS(
                       SELECT customer_id,
                              txn_date,
                              SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE - txn_amount END) AS txn_amt 
                       FROM data_bank.customer_transactions
                       GROUP BY customer_id, txn_date
                       ORDER BY customer_id, txn_date),
          balance_cte AS(
                       SELECT *,
                             SUM(txn_amt) over(PARTITION BY customer_id ORDER BY txn_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance
                        FROM txn_cte)
          SELECT txn_date,
                SUM(balance) AS total_amount
          FROM balance_cte
          GROUP BY txn_date
          ORDER BY txn_date;



