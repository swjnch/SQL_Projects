## Case Study 2-Pizza Runner :pizza: 

### Introduction
Did you know that over 115 million kilograms of pizza is consumed daily worldwide??? (Well according to Wikipedia anyway…)

Danny was scrolling through his Instagram feed when something really caught his eye - “80s Retro Styling and Pizza Is The Future!”

Danny was sold on the idea, but he knew that pizza alone was not going to help him get seed funding to expand his new Pizza Empire - so he had one more genius idea to combine with it - he was going to Uberize it - and so Pizza Runner was launched!

Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters (otherwise known as Danny’s house) and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers.

### Available Data
Because Danny had a few years of experience as a data scientist - he was very aware that data collection was going to be critical for his business’ growth.

He has prepared for us an entity relationship diagram of his database design but requires further assistance to clean his data and apply some basic calculations so he can better direct his runners and optimise Pizza Runner’s operations.

All datasets exist within the pizza_runner database schema.

Please refer to the [link](https://8weeksqlchallenge.com/case-study-2/) for ER diagrams, datasets and tasks associated with this case study.

#### The highlights of this case study are:

1. The first step in this case study is to replace NULL and "null" with empty string for exclusions, extras, pickup_time, distance, duration from both customer_orders and runners_orders tables.
2. Next step is to trim uneccesary data in the duration and distance columns from runners_orders
3. NULL and "null" in cancellation column of runners_orders is replaced with "Delivered"
4. The data types of pickup_time, distance and duration are altered. In order to implement these changes temporary tables are created for both custom_orders and runners_orders.
5. Pizza Metrics are solved using aggregate functions with joins and date time extraction functions.
6. Runner and Customer experience questions are solved mainly with Common table expressions(CTE), date time extracts, joins and aggregate functions.
7. Ingredient Optimazation section is the challenging part of this case study. The key learning points from this analysis is the use of substring_index to convert comma seperated values to rows and GROUP_CONCAT to change row values to  a single row. 
8. Pricing and ratings involve analysis of profits and extra revenue and adding new column for ratings of each runner using CTE's, groupby, aggregate functions, time conversions and difference.
