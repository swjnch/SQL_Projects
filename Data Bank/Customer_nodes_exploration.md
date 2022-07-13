#### Customer Nodes Exploration

1. How many unique nodes are there on the Data Bank system?

          SELECT COUNT(DISTINCT node_id) AS total_node_count
          FROM data_bank.customer_nodes;
	  
![image](https://user-images.githubusercontent.com/104596844/176970603-13d42a6d-0e53-498f-ae49-d82b1a8e2e4b.png)

There are a total of 5 nodes. 

2.What is the number of nodes per region?

          SELECT region_id,
	         region_name,
                 COUNT(node_id) AS total_node_count
          FROM data_bank.customer_nodes
	  JOIN data_bank.regions USING(region_id)
          GROUP BY region_id,region_name
          ORDER BY region_id;
	  
![image](https://user-images.githubusercontent.com/104596844/176970970-c07c7076-7727-406f-85fd-6691b23eab9c.png)


3.How many customers are allocated to each region?

        SELECT region_id,
	       region_name,
               COUNT(DISTINCT customer_id) AS customer_count
        FROM data_bank.customer_nodes
	JOIN data_bank.regions USING(region_id)
        GROUP BY region_id,region_name;
	
![image](https://user-images.githubusercontent.com/104596844/176971213-5921e253-d17a-4edb-9ea2-a0799c79c0bf.png)

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
		 
![image](https://user-images.githubusercontent.com/104596844/176971317-ba655dd7-ba5b-4bd8-b88d-143d3fe510ed.png)
                                 
5.What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

                 CREATE TEMPORARY TABLE tmp AS
                 WITH median_ct AS(
				   SELECT *, 
					 LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS new_node,
					 CASE 
				         WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date))- node_id)= 0 THEN NULL
				         WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date)) - node_id<> 0
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
				
##### Median

![image](https://user-images.githubusercontent.com/104596844/176972197-fbfa7e8a-6c48-42d7-bec9-4b8ad1ec9038.png)

##### 80th Percentile

![image](https://user-images.githubusercontent.com/104596844/176972255-637868ae-770a-4b61-bf3e-088f5aa3c834.png)

##### 95th Percentile

![image](https://user-images.githubusercontent.com/104596844/176972318-cfbe13d9-dcd2-460e-879a-3e9b2f4a34c8.png)
                    
              
                    
