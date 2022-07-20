### Case Study 5 - Data Mart :shopping_cart:

#### Introduction
Data Mart is Danny’s latest venture and after running international operations for his online supermarket that specialises in fresh produce - Danny is asking for your support to analyse his sales performance.

In June 2020 - large scale supply changes were made at Data Mart. All Data Mart products now use sustainable packaging methods in every single step from the farm all the way to the customer.

Danny needs your help to quantify the impact of this change on the sales performance for Data Mart and it’s separate business areas.

#### Available Data
For this case study there is only a single table: data_mart.weekly_sales

The Entity Relationship Diagram is shown below:

![image](https://user-images.githubusercontent.com/104596844/180080483-c2b88f7b-34fe-4fc2-9bdc-45628cbedefa.png)

#### Column Dictionary
The columns are pretty self-explanatory based on the column names but here are some further details about the dataset:

1. Data Mart has international operations using a multi-region strategy
2. Data Mart has both, a retail and online platform in the form of a Shopify store front to serve their customers
3. Customer <b>segment</b> and <b>customer_type</b> data relates to personal age and demographics information that is shared with Data Mart
4. <b>transactions</b> is the count of unique purchases made through Data Mart and sales is the actual dollar amount of purchases
5. Each record in the dataset is related to a specific aggregated slice of the underlying <b>sales</b> data rolled up into a week_date value which represents the start of the sales week.

