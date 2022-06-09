# Customer Nodes Exploration

1. How many unique nodes are there on the Data Bank system?

                                SELECT COUNT(DISTINCT node_id) AS total_node_count
                                FROM customer_nodes;
                                
![image](https://user-images.githubusercontent.com/104596844/172862404-da03aa08-8048-4df9-9d7a-dc070eb792d8.png)

The dataset contains total of 5 nodes.

2. What is the number of nodes per region?

                               SELECT region_id,
                                      COUNT(node_id) AS total_node_count
                               FROM customer_nodes
                               GROUP BY region_id
                               ORDER BY region_id;
                               
![image](https://user-images.githubusercontent.com/104596844/172863039-f939edb9-1353-4316-a5c3-3aed2130c034.png)

Region 1 has a total of 770 nodes which is the highest of 5 regions

3. How many customers are allocated to each region?
 
                            SELECT region_id,
                                   COUNT(DISTINCT customer_id) AS customer_count
                            FROM customer_nodes
                            GROUP BY region_id;
                            
 ![image](https://user-images.githubusercontent.com/104596844/172863772-31faf76e-e060-41ea-99cc-2bdb82ad9c68.png)

4.  How many days on average are customers reallocated to a different node?

                             WITH avg_days AS(
                                              SELECT *, 
                                                     LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS new_node,
                                                     CASE 
                                                          WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date))- node_id)= 0 THEN NULL
                                                          WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date))- node_id) <> 0
                                                                   THEN (LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date))
                                                          END as new_node_date
				                                      FROM customer_nodes
				                                      WHERE YEAR(end_date) <> 9999)
				                                 SELECT ROUND(AVG(DATEDIFF(new_node_date, start_date))) as AVG_DAYS
                                         FROM avg_days 
                                         WHERE node_id <> new_node;
                                         
![image](https://user-images.githubusercontent.com/104596844/172864828-e9e94ac7-2995-4a4f-9ba6-c6ac7d5842ae.png)

The data is filtered for end_dates that has year "9999", this has to be modified as part of data cleaning process.Using the LEAD function new nodes are matched with the 
previous and start dates for new nodes are assisgned. Finnaly to find the average days data is filtered non matching nodes. On an average it would take around 16 days to be reallocated to a different node.

5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

                                CREATE TEMPORARY TABLE tmp 
                                                          WITH median_ct AS(
					                                    SELECT *, 
							                            LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS                                                                                              new_node,
							                             CASE 
								                          WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY                                                                                                                                   start_date))- node_id)= 0 THEN NULL
								                          WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY                                                                                                                                   start_date))- node_id) <> THEN                                                                                                            (LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date))
								                      END as new_node_date
					                                      FROM customer_nodes
					                                      WHERE YEAR(end_date) <> 9999),
                                                             median_days AS(
                                                                            SELECT *,
                                                                                    DATEDIFF(new_node_date, start_date) AS total_days
			                                                     FROM median_ct
			                                                     WHERE node_id <> new_node
                                                                             ORDER BY DATEDIFF(new_node_date, start_date)
                                                                             )
                                                                             SELECT * FROM median_days;
                                                                   
                                                                   ## Median, 80th percentile and 95th percentile
                                    WITH median_table AS(
                                                         SELECT region_id, 
	                                                        total_days, 
                                                                 count(*) OVER(partition by region_id) as no_of_records,
				                                  row_number() over (partition by region_id order by total_days) as rownum
                                                           FROM temp1)
                                                           SELECT region_id,
				                                  total_days as percentile_values
		                                            FROM median_table
		                                            WHERE rownum in (round(0.50*no_of_records), 
						                             round(0.80*no_of_records), 
						                             round(0.95*no_of_records));
                                                                    
 ![image](https://user-images.githubusercontent.com/104596844/172893044-078569a1-29f3-4f98-a78d-47813696b3f4.png)
 
 Both the temporary table and common table expressions were used to generate median and percentile values.All the 5 regions have a median of 16 days that is similar to the average, which indicates that data is normally distributed and symmetric. Regions 1,2 and 4 have 24 days in the 80th percentile, regions 3 and 5 have 25days and 26days respectively. The 5 regions have 29 days in the 95th percentile.


                                                                     
                                                                     
