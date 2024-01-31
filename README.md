Data Warehouse Project: DVD Rental Sales

Technology used: SQL and Power BI

Introduction
The primary use case that one deals with in Data Warehousing is to create a central database to support disparate activities within an organization.
Databases like MySQL and PostgreSQL have pragmatic utility when it comes to operations since they have no redundancy and the DDL and DML operations are robust. However, it is too slow when to it comes down to the analytics side of the operations often due to exorbitant number of joins. Data Warehouse is a system that supports analytical processing.

Technical Overview with Example
Data is acquired from myriad sources and is stored in staging tables. Using ETL, the data from these sources are combined to form a dimensional model. Once the dimensional model is in place then we can perform data analysis using a plethora of visualization tools. Dimensional tables have facts and dimensions. These facts and dimensions can be arranged in a star, snowflake, or constellation designs. An example is provided below where ETL operations are performed (using stored procedures in SQL server) to convert the DVD Rental ER model into a star schema (with 1 fact table and 4 dimension tables).   The date dimension is SCD0 and the remaining dimensions are SCD2 since we are interested in maintaining the historical information of movies, customers, and stores.

Business Insights and Visualization Dashboard
A few business problems we are interested to discern from the dimensional model:

1. Top 5 customers with highest sales contribution?
2. Top 5 movies with highest sales?
3. Calculate the variation of sales on a monthly basis?
