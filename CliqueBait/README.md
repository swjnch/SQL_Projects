### Case Study 6 - Clique Bait :shrimp::lobster::crab:	:computer_mouse:

#### Introduction

Clique Bait is not like your regular online seafood store - the founder and CEO Danny, was also a part of a digital data analytics team and wanted to expand his knowledge into the seafood industry!

In this case study - you are required to support Danny’s vision and analyse his dataset and come up with creative solutions to calculate funnel fallout rates for the Clique Bait online store.

#### Available Data

For this case study there is a total of 5 datasets which are needed to combine to solve all of the questions.

##### Users
Customers who visit the Clique Bait website are tagged via their cookie_id.

![image](https://user-images.githubusercontent.com/104596844/185420462-1e361160-2c15-43b6-a971-c54849d377ff.png)

##### Events
Customer visits are logged in the events table at a cookie_id level and the event_type and page_id values can be used to join onto relevant satellite tables to obtain further information about each event.

The sequence_number is used to order the events within each visit.

![image](https://user-images.githubusercontent.com/104596844/185420321-b3285280-dcc6-4874-8ac7-fb3379b01031.png)


##### Event Identifier
The event_identifier table shows the types of events which are captured by Clique Bait’s digital data systems.

![image](https://user-images.githubusercontent.com/104596844/185420155-8e184bfe-949c-4112-b432-d78a677c2b4e.png)

##### Campaign Identifier
This table shows information for the 3 campaigns that Clique Bait has ran on their website so far in 2020.

![image](https://user-images.githubusercontent.com/104596844/185419860-67e3fb50-1383-4926-badd-7a692e14133c.png)![image](https://user-images.githubusercontent.com/104596844/185419965-e931c009-7aeb-4f91-a223-6b3c7d3bfb79.png)

##### Page Hierarchy
This table lists all of the pages on the Clique Bait website which are tagged and have data passing through from user interaction events.

![image](https://user-images.githubusercontent.com/104596844/185419596-1d55695b-97f5-41c9-b9bd-ba1c9a9faae7.png)







