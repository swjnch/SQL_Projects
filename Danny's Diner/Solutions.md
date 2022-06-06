#### Case Study Questions
1. What is the total amount each customer spent at the restaurant?

                     SELECT s.customer_id,
	                          SUM(m.price) as total_amt
                     FROM  sales s
                     join menu m
                     USING(product_id)
                     GROUP BY customer_id;

![image](https://user-images.githubusercontent.com/104596844/172208501-60448c83-d94f-4cd0-8b5c-9dcd4f06baba.png)

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

4. What was the first item from the menu purchased by each customer?
5. What is the most purchased item on the menu and how many times was it purchased by all customers?
6. Which item was the most popular for each customer?
7. Which item was purchased first by the customer after they became a member?
8. Which item was purchased just before the customer became a member?
9. What is the total items and amount spent for each member before they became a member?
10. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
11. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
