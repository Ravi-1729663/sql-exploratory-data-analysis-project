/*******************************************************************************************
Purpose:
    Explore key business measures from the data warehouse, including:
    - Total and average sales
    - Quantity sold
    - Unique counts of products, customers, and orders
    - Consolidated KPI report using UNION
    - Final data quality check (moved to the end logically)
*******************************************************************************************/

-- Total sales
SELECT 
    SUM(sales) AS total_sales
FROM gold.fact_sales;

-- Average selling price
SELECT 
    AVG(sales) AS average_sales
FROM gold.fact_sales;

-- Total quantity of items sold
SELECT 
    SUM(quantity) AS items_sold
FROM gold.fact_sales;

-- Count of unique products sold
SELECT 
    COUNT(DISTINCT product_key) AS total_products
FROM gold.fact_sales;

-- Product counts from product dimension
SELECT 
    COUNT(product_name) AS total_products,
    COUNT(DISTINCT product_name) AS unique_products,
    COUNT(DISTINCT product_id) AS unique_product_ids
FROM gold.dim_products;

-- Total orders (including duplicates vs distinct)
SELECT 
    COUNT(order_number) AS total_orders_count,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- Total number of customers
SELECT 
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(customer_id) AS total_customers_raw
FROM gold.dim_customers;

-- Customers who placed at least one order
SELECT 
    COUNT(DISTINCT customer_key) AS customers_placed_orders
FROM gold.fact_sales;

-- Consolidated KPI report
SELECT 'Total Sales' AS measure_name, SUM(sales) AS measure_value FROM gold.fact_sales

UNION ALL
SELECT 'Average Sales', AVG(sales) FROM gold.fact_sales

UNION ALL
SELECT 'Total Quantity Sold', SUM(quantity) FROM gold.fact_sales

UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales

UNION ALL
SELECT 'No. of Customers', COUNT(customer_id) FROM gold.dim_customers

UNION ALL
SELECT 'No. of Customers Who Ordered', COUNT(DISTINCT customer_key) FROM gold.fact_sales

UNION ALL
SELECT 'No. of Products', COUNT(product_name) FROM gold.dim_products

UNION ALL
SELECT 'No. of Products Ordered', COUNT(DISTINCT product_key) FROM gold.fact_sales

UNION ALL
SELECT 'No. of Categories', COUNT(DISTINCT category) FROM gold.dim_products

UNION ALL
SELECT 'No. of Subcategories', COUNT(DISTINCT subcategory) FROM gold.dim_products;

--------------------------------------------------------------------------------
-- Data Quality Checks (moved to end for logical flow)
--------------------------------------------------------------------------------

-- Invalid or missing sales
SELECT sales
FROM gold.fact_sales
WHERE sales < 0 OR sales IS NULL;

-- Invalid or missing quantity
SELECT quantity
FROM gold.fact_sales
WHERE quantity < 0 OR quantity IS NULL;

-- Invalid or missing price
SELECT price
FROM gold.fact_sales
WHERE price < 0 OR price IS NULL;

-- Missing order dates
SELECT DISTINCT order_date
FROM gold.fact_sales
WHERE order_date IS NULL;

-- Invalid or missing product cost
SELECT cost
FROM gold.dim_products
WHERE cost < 0 OR cost IS NULL;
