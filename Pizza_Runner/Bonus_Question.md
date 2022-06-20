
# Bonus Questions

1. If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?

       CREATE TABLE pizza_recipes_new AS
       SELECT * FROM pizza_recipes;

       INSERT INTO pizza_recipes_new (pizza_id, toppings)
       VALUES(3, (SELECT GROUP_CONCAT(topping_id) AS toppings FROM pizza_toppings));

       CREATE TABLE pizza_names_new AS
       SELECT * FROM pizza_names;

       INSERT INTO pizza_names_new (pizza_id, pizza_name)
       VALUES(3, "Supreme");
      
      ![image](https://user-images.githubusercontent.com/104596844/174688257-3f7758f0-2863-404a-b815-3a20e79f8a4a.png)
      
      ![image](https://user-images.githubusercontent.com/104596844/174688282-36b89261-5597-4604-b27d-cad52726f0a1.png)

The recipe table for Supreme pizza was updated to include all the toppings and names was updated for the new addition.
