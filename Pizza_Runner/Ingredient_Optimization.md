## Ingredient Optimisation

USE pizza_runner;

1. What are the standard ingredients for each pizza?

        CREATE TEMPORARY TABLE toppings_list
                                    SELECT pizza_recipes.pizza_id,
                                           SUBSTRING_INDEX(SUBSTRING_INDEX(pizza_recipes.toppings, ',', numbers.n), ',', -1) toppings
                                    FROM
                                         (SELECT 1 n UNION ALL
                                          SELECT 2 UNION ALL SELECT 3 UNION ALL
                                          SELECT 4 UNION ALL SELECT 5 UNION ALL
                                          SELECT 6 UNION ALL SELECT 7 UNION ALL
                                          SELECT 8 UNION ALL SELECT 9) numbers INNER JOIN pizza_recipes
                                   ON CHAR_LENGTH(pizza_recipes.toppings)-CHAR_LENGTH(REPLACE(pizza_recipes.toppings, ',', ''))>=numbers.n-1
                                   ORDER BY pizza_id, n;
                                   
        SELECT pizza_name,
               GROUP_CONCAT(topping_name) AS toppings_list
        FROM toppings_list
        JOIN pizza_toppings
        ON toppings_list.toppings = pizza_toppings.topping_id
        JOIN pizza_names USING(pizza_id)
        GROUP BY pizza_name
        ORDER BY pizza_id;

## Reference - https://stackoverflow.com/questions/17942508/sql-split-values-to-multiple-rows

# What was the most commonly added extra?
WITH extras_cte AS(
SELECT order_id,
       pizza_id,
       SUBSTRING_INDEX(SUBSTRING_INDEX(temp_orders.extras, ',', numbers.n), ',', -1) extras
       FROM
  (SELECT 1 n UNION ALL SELECT 2)numbers INNER JOIN temp_orders
  ON CHAR_LENGTH(temp_orders.extras)
     -CHAR_LENGTH(REPLACE(temp_orders.extras, ',', ''))>=numbers.n-1
WHERE extras <> ""
ORDER BY pizza_id, n)
        SELECT topping_name,
               COUNT(topping_id) AS total_count
        FROM extras_cte
        JOIN pizza_toppings
        ON extras_cte.extras = pizza_toppings.topping_id
        GROUP BY topping_name;

# What was the most common exclusion?
WITH exclusions_cte AS(
SELECT order_id,
       pizza_id,
       SUBSTRING_INDEX(SUBSTRING_INDEX(temp_orders.exclusions, ',', numbers.n), ',', -1) exclusions
       FROM
  (SELECT 1 n UNION ALL SELECT 2)numbers INNER JOIN temp_orders
  ON CHAR_LENGTH(temp_orders.exclusions)
     -CHAR_LENGTH(REPLACE(temp_orders.exclusions, ',', ''))>=numbers.n-1
WHERE exclusions <> ""
ORDER BY pizza_id, n)
        SELECT topping_name,
               COUNT(topping_id) AS total_count
        FROM exclusions_cte
        JOIN pizza_toppings
        ON exclusions_cte.exclusions = pizza_toppings.topping_id
        GROUP BY topping_name;
        
# Generate an order item for each record in the customers_orders table in the format of one of the following:
   ## Meat Lovers
   ## Meat Lovers - Exclude Beef
   ## Meat Lovers - Extra Bacon
   ## Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH substring_cte AS(
SELECT *,
	   substring_index(exclusions, ',', 1) as exclusion_first,
       substring_index(exclusions, ',', -1) as exclusion_second,
       substring_index(extras, ',', 1) as extras_first,
       substring_index(extras, ',', -1) as extras_second
FROM temp_orders
JOIN pizza_names
USING(pizza_id)
),
toppings_cte AS(
SELECT sc.order_id,
       sc.pizza_id,
       sc.customer_id,
       sc.pizza_name,
       p1.topping_name AS exclusion_1,
       p2.topping_name AS exclusion_2,
       p3.topping_name AS extras_1,
       p4.topping_name AS extras_2
FROM substring_cte sc
LEFT JOIN pizza_toppings p1 ON sc.exclusion_first = p1.topping_id
LEFT JOIN pizza_toppings p2 ON sc.exclusion_second = p2.topping_id
LEFT JOIN pizza_toppings p3 ON sc.extras_first = p3.topping_id
LEFT JOIN pizza_toppings p4 ON sc.extras_second = p4.topping_id)
SELECT customer_id,
       order_id,
       pizza_id,
       (CASE WHEN exclusion_1 IS NULL AND exclusion_2 IS NULL AND extras_1 IS NULL AND extras_2 IS NULL 
             THEN pizza_name
			 WHEN exclusion_1 = exclusion_2 AND extras_1 IS NULL AND extras_2 IS NULL 
             THEN CONCAT(pizza_name," - "," Exclude ", exclusion_1)
	         WHEN extras_1 = extras_2 AND exclusion_1 IS NULL AND exclusion_2 IS NULL 
             THEN CONCAT(pizza_name," - "," Extra ", extras_1)
             WHEN exclusion_1 <> exclusion_2 AND extras_1 <> extras_2 
             THEN CONCAT(pizza_name," - "," Exclude ", exclusion_1," , ", exclusion_2, " - ", " Extra ", extras_1," , ", extras_2)
			 WHEN exclusion_1 = exclusion_2 AND extras_1 <> extras_2 
             THEN CONCAT(pizza_name," - "," Exclude ", exclusion_1, " - ", " Extra ", extras_1," , ", extras_2)
             WHEN exclusion_1 <> exclusion_2 AND extras_1 = extras_2 
             THEN CONCAT(pizza_name," - "," Exclude ", exclusion_1," , ", exclusion_2, " - ", " Extra ", extras_1)
       END) AS customized_order
 FROM toppings_cte;

# Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
# For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
WITH cte_recipes AS(
					SELECT order_id,
                           customer_id,
                           pizza_id,
                          (CASE WHEN exclusions IS NULL OR exclusions = "null" THEN "" ELSE exclusions
                          END) AS exclusions,
                          (CASE WHEN extras IS NULL OR extras = "null" THEN "" ELSE extras
                           END) AS extras,
                           toppings,
                           ROW_NUMBER() OVER() AS row_num
                    FROM customer_orders
                    JOIN pizza_recipes USING(pizza_id)
                   ),
toppings_cte AS(
               SELECT row_num,
                      order_id,
                      customer_id,
                      pizza_id,
                      SUBSTRING_INDEX(SUBSTRING_INDEX(cte_recipes.toppings, ',', numbers.n), ',', -1) toppings
			  FROM
                     (SELECT 1 n UNION ALL
                      SELECT 2 UNION ALL SELECT 3 UNION ALL
                      SELECT 4 UNION ALL SELECT 5 UNION ALL
                      SELECT 6 UNION ALL SELECT 7 UNION ALL
					  SELECT 8 UNION ALL SELECT 9) numbers 
			 INNER JOIN cte_recipes
             ON CHAR_LENGTH(cte_recipes.toppings)-CHAR_LENGTH(REPLACE(cte_recipes.toppings, ',', ''))>=numbers.n-1
             ORDER BY row_num, pizza_id, n),
exclusions_cte AS(
                  SELECT row_num,
                         order_id,
                         customer_id,
                         pizza_id,
                         SUBSTRING_INDEX(SUBSTRING_INDEX(cte_recipes.exclusions, ',', numbers.n), ',', -1) toppings
				  FROM
                       (SELECT 1 n UNION ALL SELECT 2) numbers INNER JOIN cte_recipes
                  ON CHAR_LENGTH(cte_recipes.exclusions)-CHAR_LENGTH(REPLACE(cte_recipes.exclusions, ',', '')) >= numbers.n-1
                  ORDER BY row_num, pizza_id, n),
extras_cte AS(
                SELECT row_num,
                       order_id,
                       customer_id,
                       pizza_id,
                       SUBSTRING_INDEX(SUBSTRING_INDEX(cte_recipes.extras, ',', numbers.n), ',', -1) toppings
				FROM
                       (SELECT 1 n UNION ALL SELECT 2)numbers INNER JOIN cte_recipes
               ON CHAR_LENGTH(cte_recipes.extras)-CHAR_LENGTH(REPLACE(cte_recipes.extras, ',', '')) >= numbers.n-1
               ORDER BY row_num, pizza_id, n),
ingredients_cte AS(
                SELECT * FROM toppings_cte
                WHERE toppings NOT IN(SELECT toppings FROM exclusions_cte)
                UNION ALL 
                SELECT * FROM extras_cte
                ORDER BY row_num),
frequency_cte AS(
                SELECT row_num,
                       order_id,
                       customer_id,
                       pizza_id,
                       t1.toppings,
                       t2.topping_name,
                       COUNT(t2.topping_name) AS frequency
                FROM ingredients_cte t1
                JOIN pizza_toppings t2
				ON t1.toppings=t2.topping_id
                GROUP BY 1, 2, t2.topping_name
               ORDER BY 1,2),
ingredient_cte AS(
                   SELECT *,
						CASE WHEN frequency = 1 THEN topping_name ELSE CONCAT(frequency, 'x ', topping_name)
                        END AS ingredient_count
                   FROM frequency_cte
                   JOIN pizza_names
                   USING(pizza_id)),
recipe_cte AS(
              SELECT *,
                     GROUP_CONCAT(ingredient_count ORDER BY topping_name) AS recipe
			 FROM ingredient_cte
             GROUP BY row_num, order_id, pizza_id)
SELECT order_id,
       pizza_id,
       customer_id,
       CONCAT(pizza_name, " : ", recipe) AS ingredients_list
FROM recipe_cte;

# What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
