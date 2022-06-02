USE dannys_diner;

# What is the total amount each customer spent at the restaurant?
SELECT s.customer_id,
	   SUM(m.price) as total_amt
FROM  sales s
join menu m
USING(product_id)
GROUP BY customer_id;

# How many days has each customer visited the restaurant?
SELECT customer_id,
	    COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY customer_id;

# What was the first item from the menu purchased by each customer?
WITH first_ordered AS(
    SELECT customer_id,
           order_date,
		   product_name,
		   DENSE_RANK () OVER (partition by customer_id order by order_date) as ranking
FROM sales 
JOIN menu 
USING(product_id)
)
SELECT customer_id, product_name
FROM first_ordered
WHERE ranking = 1
GROUP BY customer_id, product_name;

# What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name,
	   COUNT(product_id) as most_ordered
FROM  sales s
JOIN menu m
USING (product_id)
GROUP BY product_id
ORDER BY most_ordered DESC
LIMIT 1;

# Which item was the most popular for each customer?
WITH most_popular AS(
    SELECT * FROM (
	SELECT
		customer_id,
		product_name,
        COUNT(product_id) as order_count,
		RANK () OVER (partition by customer_id order by COUNT(product_id) desc) ranking
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

# Which item was purchased first by the customer after they became a member?
WITH after_member AS(
   SELECT * FROM (
SELECT *,
       DENSE_RANK () OVER (partition by customer_id order by order_date) ranking
FROM members
JOIN sales
USING(customer_id)
JOIN menu
USING(product_id)
WHERE order_date>=join_date
ORDER BY customer_id)t)
SELECT customer_id,
		product_name,
        join_date,
        order_date
FROM after_member
WHERE ranking=1;

# Which item was purchased just before the customer became a member?
WITH before_member AS(
   SELECT * FROM (
SELECT *, 
       RANK () OVER (partition by customer_id order by order_date DESC) ranking
FROM members
JOIN sales
USING(customer_id)
JOIN menu
USING(product_id)
WHERE order_date < join_date
ORDER BY customer_id)t)
SELECT customer_id,
	    product_name,
        join_date,
        order_date
FROM before_member
WHERE ranking=1;

# What is the total items and amount spent for each member before they became a member?
SELECT customer_id,
       COUNT(product_id) AS total_items,
       SUM(price) AS total_amt
FROM menu
JOIN sales
USING(product_id)
JOIN members
USING(customer_id)
WHERE order_date<join_date
GROUP BY customer_id
ORDER BY customer_id;

# If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT
	   customer_id,
       SUM(CASE
          WHEN product_name = "sushi" THEN (20*price)
          ELSE (10*price)
       END) AS points
FROM sales
JOIN menu
USING(product_id)
WHERE customer_id IN (SELECT customer_id FROM members)
GROUP BY customer_id
ORDER BY customer_id;

# In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
SELECT customer_id,
	   SUM(CASE
          WHEN DATEDIFF(order_date,join_date) BETWEEN 0 AND 6 THEN (20*price)
		  WHEN product_name = "sushi" THEN (20*price)
          ELSE (10*price)
          END) AS points
FROM members
JOIN sales
USING(customer_id)
JOIN menu
USING(product_id)
WHERE ORDER_DATE BETWEEN "2021-01-01" AND "2021-01-31"
GROUP BY customer_id
ORDER BY customer_id;

# BONUS QUESTION 1
CREATE VIEW join_table AS
SELECT customer_id,
       order_date,
       product_name,
       price,
       (CASE
          WHEN order_date >= join_date THEN "Y"
          ELSE "N"
          END) AS member
FROM sales
JOIN menu
USING(product_id)
LEFT JOIN members
USING(customer_id);

#BONUS QUESTION 2
CREATE VIEW ranking AS
SELECT *, 
		(CASE
           WHEN member = "N" THEN "null"
           ELSE DENSE_RANK() Over (PARTITION BY customer_id, member ORDER BY order_date)
          END) ranking
FROM join_table;