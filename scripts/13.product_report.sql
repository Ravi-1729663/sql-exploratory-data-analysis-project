-- ================================================================
-- Purpose:
--   To generate a product-level performance report by combining
--   transactional sales data with product attributes.
--
--   The report supports business analysis by providing:
--     - Sales classification (Low, Mid, High performers)
--     - Aggregated sales, quantity, orders, and customer count
--     - Product lifecycle (in months) and sales recency
--     - Revenue efficiency metrics:
--         • Average revenue per unit sold
--         • Average monthly revenue over the product’s active period
--
-- Logic Summary:
--   1. Join the sales fact table with the product dimension.
--   2. Aggregate key metrics by product attributes.
--   3. Derive business indicators and performance segments.
--
-- Use Cases:
--   - Product portfolio analysis
--   - Category performance reviews
--   - Inventory and sales planning
--   - Executive dashboards
-- ================================================================

CREATE VIEW product_report AS

-- Step 1: Create base dataset by joining fact and dimension tables
WITH base_query AS (
    SELECT 
        f.order_number,
        p.product_key,
        p.product_id,
        p.product_name,
        p.category,
        p.subcategory,
        p.product_line,
        f.customer_key,
        p.cost,
        f.sales,
        f.quantity,
        f.order_date
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
),

-- Step 2: Aggregate metrics at the product level
product_aggregate AS (
    SELECT 
        product_id,
        product_name,
        category,
        subcategory,
        product_line,
        SUM(sales) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        MAX(order_date) AS last_order,
        -- Life span is the number of months between first and last sale
        DATEDIFF(month, MIN(order_date), MAX(order_date)) AS life_span
    FROM base_query
    GROUP BY 
        product_id,
        product_name,
        category,
        subcategory,
        product_line
)

-- Step 3: Compute additional metrics and classify product performance
SELECT 
    product_id,
    product_name,
    category,
    subcategory,
    product_line,
    total_sales,
    
    -- Classify product performance based on total sales
    CASE 
        WHEN total_sales < 10000 THEN 'Low-Performer'
        WHEN total_sales >= 50000 THEN 'Mid-Performer'
        ELSE 'High-Performer'
    END AS product_segment,
    
    total_quantity,
    total_orders,
    total_customers,
    life_span,
    
    -- Time since last order
    DATEDIFF(month, last_order, GETDATE()) AS recency,
    
    -- Average revenue per unit sold
    CASE 
        WHEN total_quantity = 0 THEN 0
        ELSE ROUND(CAST(total_sales AS FLOAT) / total_quantity, 2)
    END AS avg_order_revenue,
    
    -- Average monthly revenue over product life span
    CASE 
        WHEN life_span = 0 THEN total_sales
        ELSE ROUND(CAST(total_sales AS FLOAT) / life_span, 2)
    END AS avg_monthly_revenue

FROM product_aggregate;

-- Optional: View data from the created view
SELECT * FROM product_report;
