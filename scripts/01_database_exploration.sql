/*******************************************************************************************
Purpose:
    Perform initial database exploration for data warehouse understanding. 
    This includes:
    - Listing all available tables.
    - Exploring column metadata for key tables: dim_products, dim_customers, and fact_sales.
********************************************************************************************/

-- List all tables in the current database
SELECT * 
FROM INFORMATION_SCHEMA.TABLES;

-- View column details for the 'dim_products' table
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products';

-- View column details for the 'dim_customers' table
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- View column details for the 'fact_sales' table
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'fact_sales';
