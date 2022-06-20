#### Case Study Questions
1. What is the total amount each customer spent at the restaurant?

       SELECT s.customer_id,
	      SUM(m.price) as total_amt
       FROM  sales s
       JOIN menu m USING(product_id)
       GROUP BY customer_id;

![image](https://user-images.githubusercontent.com/104596844/172214535-6f29c786-f8b2-44c2-b75b-ea7f8d21fc34.png)

Customer A has spent 76$.
Customer B spent 74$.
Customer C spent 36$.

2. How many days has each customer visited the restaurant?
            
        SELECT customer_id,
	       COUNT(DISTINCT order_date) AS days_visited
         FROM sales
         GROUP BY customer_id;
                   
 ![image](https://user-images.githubusercontent.com/104596844/172209697-d6745c10-fe37-4261-a002-637e44e8a7fb.png)

Customer A visted for 4 days.
Customer B visited for 6 days.
Customer C visited for 2 days.

3. What was the first item from the menu purchased by each customer?

       WITH first_ordered AS(
                            SELECT customer_id,
                                    order_date,
		                    product_name,
		                    DENSE_RANK () OVER (partition by customer_id order by order_date) as ranking
                             FROM sales 
                             JOIN menu USING(product_id)
                             )
                              SELECT customer_id, 
		                     product_name
                              FROM first_ordered
                             WHERE ranking = 1
                             GROUP BY customer_id, product_name;
		      
![image](https://user-images.githubusercontent.com/104596844/172213229-27268434-d881-4a4b-b1f8-09d2a0fea570.png)

Customer A ordered sushi and curry on the same day.
Customer B ordered curry.
Customer C ordered ramen

4. What is the most purchased item on the menu and how many times was it purchased by all customers?

         SELECT m.product_name,
	        COUNT(product_id) as most_ordered
         FROM  sales s
         JOIN menu m USING (product_id)
         GROUP BY product_id
         ORDER BY most_ordered DESC
         LIMIT 1;
			    
![image](https://user-images.githubusercontent.com/104596844/172215105-1cfef268-c0fb-482a-ae72-cb3718125388.png)

Ramen is the most ordered item on menu.

5. Which item was the most popular for each customer?

           WITH most_popular AS(
                                SELECT * FROM(
	                                       SELECT customer_id,
		                                      product_name,
                                                      COUNT(product_id) as order_count,
		                                      RANK () OVER (partition by customer_id order by COUNT(product_id) desc) ranking                                                               FROM sales
	                        JOIN  menu USING(product_id)
	                        GROUP BY customer_id, product_id)t)
                                                                  SELECT customer_id,
		                                                          product_name,
                                                                          order_count
                                                                  FROM most_popular
                                                                  WHERE ranking=1;
							   
![image](https://user-images.githubusercontent.com/104596844/172216242-2877937e-06f0-40fd-9e2f-c5d99d80ee80.png)

Customer A and C ordered ramen thrice and Customer B order all the items twice from the menu.

6. Which item was purchased first by the customer after they became a member?

             WITH after_member AS(
                                  SELECT * FROM (
                                                   SELECT *,
                                                           DENSE_RANK () OVER (partition by customer_id order by order_date) ranking
                                                    FROM members
                                                    JOIN sales USING(customer_id)
                                                    JOIN menu USING(product_id)
                                                    WHERE order_date>=join_date
                                                    ORDER BY customer_id)t)
                                                                         SELECT customer_id,
		                                                                product_name,
                                                                                join_date,
                                                                                order_date
                                                                         FROM after_member
                                                                         WHERE ranking=1;                 
							

7. Which item was purchased just before the customer became a member?
                             
              WITH before_member AS(
                                   SELECT * FROM (
                                                   SELECT *, 
                                                          RANK () OVER (partition by customer_id order by order_date DESC) ranking
                                                    FROM members
                                                    JOIN sales USING(customer_id)
                                                    JOIN menu USING(product_id)
                                                    WHERE order_date < join_date
                                                    ORDER BY customer_id)t)
                                                                         SELECT customer_id,
	                                                                        product_name,
                                                                                 join_date,
                                                                                  order_date
                                                                         FROM before_member
                                                                         WHERE ranking=1;
								       
![image](https://user-images.githubusercontent.com/104596844/172222614-51564d71-9d0a-4a6a-88c6-b942ac5a1c0b.png)

Customer A has ordered sushi and curry.Customer B ordered sushi

8. What is the total items and amount spent for each member before they became a member?

               SELECT customer_id,
                      COUNT(product_id) AS total_items,
                       SUM(price) AS total_amt
               FROM menu
               JOIN sales USING(product_id)
               JOIN members USING(customer_id)
               WHERE order_date<join_date
               GROUP BY customer_id
               ORDER BY customer_id;
					    
![image](https://user-images.githubusercontent.com/104596844/172223155-b136b3eb-fd28-48d0-b370-9f6982a6c247.png)

Customer A ordered a total of 2 items that total upto 25$ and Customer B ordered 3 items for 40$.

9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

                  SELECT
	                customer_id,
                        SUM(CASE WHEN product_name = "sushi" THEN (20*price) ELSE (10*price) END) AS points
                 FROM sales
                 JOIN menu
                 USING(product_id)
                 WHERE customer_id IN (SELECT customer_id FROM members)
                GROUP BY customer_id
                ORDER BY customer_id;
		
![image](https://user-images.githubusercontent.com/104596844/172223720-8432f174-c5eb-4b52-ab02-20318c131bed.png)

Customer A has a total of 860 points where as Customer B has 940 points.

10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

                 SELECT customer_id,
	                SUM(CASE
		                WHEN DATEDIFF(order_date,join_date) BETWEEN 0 AND 6 THEN (20*price)
		                WHEN product_name = "sushi" THEN (20*price) ELSE (10*price)
                                                END) AS points
                 FROM members
                 JOIN sales USING(customer_id)
                 JOIN menu USING(product_id)
                 WHERE ORDER_DATE BETWEEN "2021-01-01" AND "2021-01-31"
                 GROUP BY customer_id
                 ORDER BY customer_id;
				     
![image](https://user-images.githubusercontent.com/104596844/172224340-a292abe2-069d-462a-a386-38d82e01104f.png)

Customer A has total of 1370 points where as Customer B has 820 points.

#### Bonus Question 1

                CREATE VIEW join_table AS
                                           SELECT customer_id,
                                                  order_date,
                                                  product_name,
                                                  price,
                                                  (CASE WHEN order_date >= join_date THEN "Y" ELSE "N" END) AS member
                                           FROM sales
                                           JOIN menu USING(product_id)
                                           LEFT JOIN members USING(customer_id);

![image](https://user-images.githubusercontent.com/104596844/172226122-bceb07f4-769c-435e-8c47-ba7faec9edef.png)

#### Bonus Question 2

                  CREATE VIEW ranking AS
                                          SELECT *, 
                                                  (CASE WHEN member = "N" THEN "null" ELSE DENSE_RANK() Over (PARTITION BY customer_id, member ORDER BY order_date)
                                                       END) ranking
                                            FROM join_table;
					       
![image](https://user-images.githubusercontent.com/104596844/172226436-4ab0ba3e-f48a-4f0b-afed-d8744ccb4b91.png)




