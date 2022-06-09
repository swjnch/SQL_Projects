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
							                                                                          LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date) AS new_node,
							                                                                          CASE 
								                                                                            WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date))- node_id)= 0 THEN NULL
								                                                                            WHEN ((LEAD(node_id,1) OVER (PARTITION BY customer_id ORDER BY start_date))- node_id) <> 0
								                                                                                 THEN (LEAD(start_date,1) OVER (PARTITION BY customer_id ORDER BY start_date))
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
                                                                   
                                                                   ## Median
                                                                   SET @ROWINDEX:= -1;
                                                                   SELECT AVG(N.total_days) AS MEDIAN_VALUE
                                                                          FROM (SELECT @ROWINDEX:= @ROWINDEX+1 AS rowindex,
                                                                                        total_days AS total_days
	                                                                              FROM tmp
                                                                                ORDER BY total_days) AS N
                                                                    WHERE N.ROWINDEX IN (FLOOR(@ROWINDEX/2), CEIL(@ROWINDEX/2));
                                                                    
 ![image](https://user-images.githubusercontent.com/104596844/172869241-97efe997-e1e9-4ffc-bc7a-5872711933a6.png)

                                                                    
                                                                    ## 95th percentile
                                                                    SELECT * FROM 
                                                                                (SELECT total_days,  
                                                                                        @row_num :=@row_num + 1 AS row_num FROM tmp, 
                                                                                        (SELECT @row_num:=0) counter 
                                                                                         ORDER BY total_days) N
                                                                    WHERE N.row_num = ROUND (.95* @row_num); 
                                                                    
 ![image](https://user-images.githubusercontent.com/104596844/172869402-80e92279-33e7-443f-84e0-12209cbf3446.png)
  
                                                                    ## 80th percentile
                                                                    SELECT * FROM 
                                                                               (SELECT total_days,  
                                                                                       @row_num :=@row_num + 1 AS row_num FROM tmp, 
                                                                                       (SELECT @row_num:=0) counter 
                                                                                       ORDER BY total_days) N
                                                                     WHERE N.row_num = ROUND (.80 * @row_num);
                                                                     
  ![image](https://user-images.githubusercontent.com/104596844/172869573-56a2bc04-9774-4d27-9aa7-b685ca637763.png)

                                                                     
                                                                     
