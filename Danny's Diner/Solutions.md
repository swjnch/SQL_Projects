#### Case Study Questions
1. What is the total amount each customer spent at the restaurant?

                     SELECT s.customer_id,
	                          SUM(m.price) as total_amt
                     FROM  sales s
                     join menu m
                     USING(product_id)
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
                                 JOIN menu 
                                USING(product_id)
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
                            JOIN menu m
                            USING (product_id)
                            GROUP BY product_id
                            ORDER BY most_ordered DESC
                            LIMIT 1;
			    
![image](https://user-images.githubusercontent.com/104596844/172215105-1cfef268-c0fb-482a-ae72-cb3718125388.png)

Ramen is the most ordered item on menu.

5. Which item was the most popular for each customer?

                                            WITH most_popular AS(
                                                               SELECT * FROM (
	                                                                      SELECT customer_id,
		                                                                      product_name,
                                                                                      COUNT(product_id) as order_count,
		                                                                      RANK () OVER (partition by customer_id order by COUNT(product_id) desc)                                                                                             ranking
	                                                                       FROM sales
	                                                                      JOIN  menu
                                                                               USING(product_id)
	                                                                    GROUP BY customer_id, product_id
                                                                 )t)
                                                            SELECT customer_id,
		                                                   product_name,
                                                                   order_count
                                                            FROM most_popular
                                                           WHERE ranking=1;
							   
![image](https://user-images.githubusercontent.com/104596844/172216242-2877937e-06f0-40fd-9e2f-c5d99d80ee80.png)

Customer A and C ordered ramen thrice and Customer B order all the items twice from the menu.


8. Which item was purchased first by the customer after they became a member?
9. Which item was purchased just before the customer became a member?
10. What is the total items and amount spent for each member before they became a member?
11. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
12. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
