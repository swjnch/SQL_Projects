#### Customer Nodes Exploration

1. How many unique nodes are there on the Data Bank system?

          SELECT COUNT(DISTINCT node_id) AS total_node_count
          FROM data_bank.customer_nodes;

2.What is the number of nodes per region?

          SELECT region_id,
                 COUNT(node_id) AS total_node_count
          FROM data_bank.customer_nodes
          GROUP BY region_id
          ORDER BY region_id;

3.How many customers are allocated to each region?

        SELECT region_id,
               COUNT(DISTINCT customer_id) AS customer_count
        FROM data_bank.customer_nodes
        GROUP BY region_id;

4. How many days on average are customers reallocated to a different node?

         WITH avg_days AS(
                 SELECT *, 
                       LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS new_node,
                        CASE 
                             WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date))- node_id)= 0 THEN NULL
                             WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date))- node_id) <> 0
                                  THEN (LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date))
                                  END as new_node_date
		              FROM data_bank.customer_nodes
		              WHERE EXTRACT(YEAR FROM end_date) <> 9999)       
		             SELECT ROUND(AVG((new_node_date - start_date))) as AVG_DAYS
                 FROM avg_days 
                 WHERE node_id <> new_node;
                                 
5.What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

                 CREATE TEMPORARY TABLE tmp AS
                 WITH median_ct AS(
				   SELECT *, 
					 LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS new_node,
					 CASE 
				         WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date))- node_id)= 0 THEN NULL
				         WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date))node_id<> 0
					       THEN (LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date))
				         END as new_node_date
				  FROM data_bank.customer_nodes
				  WHERE EXTRACT(YEAR FROM end_date) <> 9999),
                      days_cte AS(
                                  SELECT *,
                                        (new_node_date - start_date) AS total_days
			          FROM median_ct
			          WHERE node_id <> new_node
                                  ORDER BY region_id, (new_node_date - start_date)
                                  )
                                 SELECT * FROM days_cte;
                   
                 WITH median_table AS(
                                 SELECT region_id, 
	                                total_days, 
                                        count(*) OVER(partition by region_id) as no_of_records,
				        row_number() over (partition by region_id order by total_days) as rownum
                                  FROM tmp)
                                 SELECT region_id,
                                        region_name,
				         total_days as percentile_values
		                 FROM median_table
                                 JOIN data_bank.regions USING(region_id)
		                 WHERE rownum in (round(0.50*no_of_records));
				 
	         WITH median_table AS(
                                SELECT region_id, 
	                               total_days, 
                                       count(*) OVER(partition by region_id) as no_of_records,
				       row_number() over (partition by region_id order by total_days) as rownum
                                FROM tmp)
                                SELECT region_id,
                                       region_name,
				       total_days as percentile_values
		                FROM median_table
                                JOIN data_bank.regions USING(region_id)
		                WHERE rownum in (round(0.80*no_of_records));
				
		WITH median_table AS(
                                SELECT region_id, 
	                               total_days, 
                                       count(*) OVER(partition by region_id) as no_of_records,
				       row_number() over (partition by region_id order by total_days) as rownum
                                FROM tmp)
                                SELECT region_id,
                                       region_name,
				       total_days as percentile_values
		                FROM median_table
                                JOIN data_bank.regions USING(region_id)
		                WHERE rownum in (round(0.95*no_of_records));
                    
                    
                    
                    
 
