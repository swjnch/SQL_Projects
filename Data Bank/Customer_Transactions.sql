-- What is the unique count and total amount for each transaction type?
SELECT txn_type,
       COUNT(*) AS count,
       SUM(txn_amount) AS total_amount
FROM data_bank.customer_transactions
GROUP BY txn_type;

-- What is the average total historical deposit counts and amounts for all customers?
WITH deposit_cte AS (
                  SELECT customer_id, 
                         txn_type, 
                         COUNT(*) AS txn_count, 
		                 AVG(txn_amount) AS avg_amount
                  FROM data_bank.customer_transactions
                  GROUP BY customer_id, txn_type
                  ORDER BY customer_id)
                  SELECT ROUND(AVG(txn_count),0) AS avg_deposit, 
                         ROUND(AVG(avg_amount),2) AS avg_amount
                  FROM deposit_cte
                  WHERE txn_type = 'deposit';

-- For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
WITH counts_cte AS(
                 SELECT customer_id,
                        DATE_PART('MONTH', txn_date) AS txn_month,
                        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_total,
                        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_total,
		                SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_total      
                 FROM data_bank.customer_transactions
                 GROUP BY 1,2
                 ORDER BY customer_id)
                 SELECT txn_month,
						COUNT(customer_id) AS total_customers
				 FROM counts_cte
				 WHERE deposit_total >= 2 AND (purchase_total >= 1 OR withdrawal_total >= 1)
                 GROUP BY txn_month
                 ORDER BY txn_month;
                 
-- What is the closing balance for each customer at the end of the month?
-- What is the percentage of customers who increase their closing balance by more than 5%?