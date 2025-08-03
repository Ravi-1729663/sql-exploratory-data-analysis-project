/*******************************************************************************************
Purpose:
    Explore unique dimension values from key dimension tables (`gold.dim_customers` and 
    `gold.dim_products`) to understand available categorical data.

    This helps in:
    - Identifying possible filter values for dashboards or reports.
    - Understanding the diversity and structure of dimension attributes.
********************************************************************************************/

-- Explore unique countries from customer dimension
SELECT DISTINCT country
FROM gold.dim_customers;

-- Explore unique marital statuses from customer dimension
SELECT DISTINCT maritial_status
FROM gold.dim_customers;

-- Explore unique genders from customer dimension
SELECT DISTINCT gender
FROM gold.dim_customers;

-- Explore unique category IDs from product dimension
SELECT DISTINCT category_id
FROM gold.dim_products;

-- Explore unique categories from product dimension
SELECT DISTINCT category
FROM gold.dim_products;

-- Explore unique subcategories from product dimension
SELECT DISTINCT subcategory
FROM gold.dim_products;

-- Explore unique product lines from product dimension
SELECT DISTINCT product_line
FROM gold.dim_products;

-- Explore unique maintenance types from product dimension
SELECT DISTINCT maintenance
FROM gold.dim_products;
