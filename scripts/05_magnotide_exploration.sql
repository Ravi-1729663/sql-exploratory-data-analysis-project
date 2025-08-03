/*******************************************************************************************
Purpose:
    Explore the magnitude of data across customer and product dimensions, including:
    - Data quality adjustments
    - Aggregations by demographic and product attributes
    - Customer order and sales behavior
    - Category-wise pricing and sales distribution
    - Geographic distribution of sold items
*******************************************************************************************/

-- Update invalid category to 'Others' where category_id is 'CO_PE'
UPDATE gold.dim_products
SET category = 'Others'
WHERE category_id = 'CO_PE';

-- Total number of customers by country
SELECT 
    country,
    COUNT(*) AS total_customers
FROM gold.dim_customers
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_customers DESC;

-- Total number of customers by gender
SELECT 
    gender,
    COUNT(*) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Total number of customers by marital status
SELECT 
    maritial_status,
    COUNT(*) AS total_customers
FROM gold.dim_customers
GROUP BY maritial_status
ORDER BY total_customers DESC;

-- Total number of products by category
SELECT 
    category,
    COUNT(*) AS total_products
FROM gold.dim_products
WHERE category IS NOT NULL
GROUP BY category
ORDER BY total_products DESC;

-- Total number of products by subcategory
SELECT 
    subcategory,
    COUNT(*) AS total_products
FROM gold.dim_products
WHERE subcategory IS NOT NULL
GROUP BY subcategory
ORDER BY total_products DESC;

-- Total number of products by product line
SELECT 
    product_line,
    COUNT(*) AS total_products
FROM gold.dim_products
GROUP BY product_line
ORDER BY total_products DESC;

-- Average cost per category
SELECT 
    category,
    ISNULL(AVG(cost), 0) AS average_price
FROM gold.dim_products
WHERE category IS NOT NULL
GROUP BY category
ORDER BY average_price DESC;

-- Total number of orders per customer
SELECT 
    c.customer_key,
    c.first_name + ' ' + c.last_name AS full_name,
    COUNT(order_number) AS total_orders
FROM gold.fact_sales AS s
    RIGHT JOIN gold.dim_customers AS c
    ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name + ' ' + c.last_name
ORDER BY total_orders DESC;

-- Total sales per customer
SELECT 
    c.customer_key,
    c.first_name + ' ' + c.last_name AS full_name,
    ISNULL(SUM(sales), 0) AS total_sales
FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_customers AS c
    ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name + ' ' + c.last_name
ORDER BY total_sales DESC;

-- Total sales by category
SELECT 
    p.category,
    SUM(sales) AS total_sale
FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
    ON f.product_key = p.product_key
GROUP BY p.category
ORDER BY total_sale DESC;

-- Distribution of sold items across countries using window functions
SELECT DISTINCT
    c.country,
    SUM(quantity) OVER(PARTITION BY c.country) AS country_quantity,
    SUM(quantity) OVER() AS overall_quantity,
    CONCAT(
        ROUND(
            CAST(SUM(quantity) OVER(PARTITION BY c.country) AS FLOAT) / 
            SUM(quantity) OVER() * 100, 
        2), ' %') AS contribution
FROM gold.fact_sales AS s
    LEFT JOIN gold.dim_customers AS c
    ON s.customer_key = c.customer_key;

-- Distribution of sold items across countries using grouped subquery
SELECT 
    country,
    CONCAT(
        ROUND(CAST(country_quantity AS FLOAT) / SUM(country_quantity) OVER() * 100, 3),
        ' %') AS contribution
FROM (
    SELECT 
        c.country,
        SUM(quantity) AS country_quantity
    FROM gold.fact_sales AS s
        LEFT JOIN gold.dim_customers AS c
        ON s.customer_key = c.customer_key
    GROUP BY c.country
) AS t
ORDER BY country_quantity DESC;
