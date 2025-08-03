/*******************************************************************************************
Purpose:
    Perform ranking analysis on sales and orders data, including:
    - Ranking countries by total sales
    - Top and bottom performers (products, customers) by quantity, revenue, and orders
    - Use of RANK() and DENSE_RANK() window functions for ranking with ties
*******************************************************************************************/

-- Rank countries by total sales
SELECT 
    c.country,
    SUM(sales) AS country_sales,
    RANK() OVER (ORDER BY SUM(sales) DESC) AS rk
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c ON s.customer_key = c.customer_key
GROUP BY c.country;

-- Declare and set top N for top products by quantity
DECLARE @top INT = 5;

SELECT * 
FROM (
    SELECT 
        p.product_name,
        SUM(s.quantity) AS total_quantity,
        RANK() OVER (ORDER BY SUM(s.quantity) DESC) AS rk
    FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_products AS p ON s.product_key = p.product_key
    GROUP BY p.product_name
) AS t
WHERE rk <= @top;

-- Declare and set bottom N for customers with least orders
DECLARE @bottom INT = 3;

SELECT *
FROM (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        COUNT(DISTINCT order_number) AS total_orders,
        RANK() OVER (ORDER BY COUNT(order_number)) AS rk
    FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_customers AS c ON s.customer_key = c.customer_key
    GROUP BY c.customer_id, c.first_name, c.last_name
) AS t
WHERE rk <= @bottom;

-- Top 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(sales) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- Bottom 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(sales) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;

-- Top 10 subcategories by revenue (using DENSE_RANK to handle ties)
SELECT 
    subcategory,
    total_revenue
FROM (
    SELECT 
        p.subcategory,
        SUM(sales) AS total_revenue,
        DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS rk
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p ON f.product_key = p.product_key
    GROUP BY p.subcategory
) AS t
WHERE rk <= 10;

-- Top 10 customers by revenue (using DENSE_RANK)
SELECT 
    customer_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    total_revenue
FROM (
    SELECT  
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(sales) AS total_revenue,
        DENSE_RANK() OVER (ORDER BY SUM(sales) DESC) AS rk
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c ON f.customer_key = c.customer_key
    GROUP BY c.customer_id, c.first_name, c.last_name
) AS t
WHERE rk <= 10;

-- Top 3 customers by number of orders
SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_orders DESC;
