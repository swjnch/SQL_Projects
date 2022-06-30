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


-- What is the percentage of customers who increase their closing balance by more than 5%?
WITH cte AS(
 SELECT *,
        LAG(closing_balance,3) OVER (PARTITION BY customer_id ORDER BY txn_month) previous_balance
 FROM closing_balance),
 percent_cte AS(
 SELECT 
    customer_id, 
    txn_month, 
    closing_balance, 
    previous_balance, 
    ROUND((1.0 * (closing_balance - previous_balance)) / previous_balance,2) AS percentage
  FROM cte  
  WHERE txn_month = '2020-04-30'
  AND closing_balance::TEXT NOT LIKE '-%'
  GROUP BY customer_id, txn_month, closing_balance, previous_balance
  ORDER BY customer_id)
  SELECT * FROM percent_cte 
  WHERE percentage > 5.0
  ORDER BY customer_id;