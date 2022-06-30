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

          WITH txn_cte AS(
                        SELECT customer_id,
                               (date_trunc('month', txn_date) + interval '1 month - 1 day') AS txn_month,
                               SUM(CASE WHEN txn_type='deposit' THEN txn_amount ELSE - txn_amount END) AS txn_amt 
                        FROM data_bank.customer_transactions
                        GROUP BY customer_id, txn_month
                        ORDER BY customer_id, txn_month),
           closing_cte AS(
                          SELECT *,
	                               SUM(txn_amt) over(PARTITION BY customer_id ORDER BY txn_month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS closing_balance
                          FROM txn_cte),
           end_month AS(
                       SELECT DISTINCT customer_id,
                              ('2020-01-31'::date + (generate_series(0,3,1) * INTERVAL'1 MONTH')) AS end_month
                       FROM data_bank.customer_transactions
                     ORDER BY customer_id, end_month),
           t1_cte AS(
                    SELECT e.customer_id,
                           e.end_month,
                           ce.txn_amt,
                           ce.closing_balance
                    FROM end_month e
                    LEFT JOIN closing_cte ce
                    ON e.end_month = ce.txn_month
                    AND e.customer_id = ce.customer_id),
          t2_cte AS(
                    SELECT *,
                          count(closing_balance) OVER(PARTITION BY customer_id order by end_month) as _grp
                    FROM t1_cte
                    ORDER BY customer_id),
           t3_cte AS(
                    SELECT *,
                          CASE WHEN txn_amt ISNULL THEN 0 ELSE txn_amt END AS txn_amt_1,
                          FIRST_VALUE(closing_balance) OVER(PARTITION BY customer_id,_grp ORDER BY _grp) AS closing_balance_new
                    FROM t2_cte
                    ORDER BY customer_id)
           SELECT customer_id,
                   end_month AS txn_month,
                   txn_amt_1 AS transaction_balance,
                   closing_balance_new AS closing_balance
           FROM t3_cte;
   
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
