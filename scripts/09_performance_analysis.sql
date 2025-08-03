/*************************************************************************************************
    PURPOSE:
    This script analyzes sales performance across multiple time frames:
    
    1. Daily sales performance vs overall average
    2. Monthly sales & quantity performance with previous month comparison
    3. Year-over-year (YoY) performance of each product, analyzed using:
       - Average vs actual
       - Previous year comparison

    DATA SOURCES:
    - gold.fact_sales
    - gold.dim_products

*************************************************************************************************/


-- =======================================================
-- 📅 DAILY SALES PERFORMANCE WITH OVERALL AVERAGE
-- =======================================================
SELECT 
    DISTINCT order_date,
    SUM(sales) OVER (PARTITION BY order_date) AS daywise_sales,
    AVG(sales) OVER () AS overall_average,
    SUM(sales) OVER (PARTITION BY order_date) - AVG(sales) OVER () AS sales_diff
FROM gold.fact_sales
WHERE order_date IS NOT NULL
ORDER BY order_date;


-- =======================================================
-- 📆 MONTHLY SALES & QUANTITY PERFORMANCE (MoM)
-- =======================================================
SELECT 
    *,
    LAG(total_sales, 1) OVER (ORDER BY monthly) AS prev_month_sale,
    LAG(total_quantity, 1) OVER (ORDER BY monthly) AS prev_month_qty,
    total_sales - LAG(total_sales, 1) OVER (ORDER BY monthly) AS monthly_sales_diff,
    total_quantity - LAG(total_quantity, 1) OVER (ORDER BY monthly) AS monthly_quantity_diff
FROM (
    SELECT 
        DATETRUNC(MONTH, order_date) AS monthly,
        SUM(sales) AS total_sales,
        SUM(quantity) AS total_quantity
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) t;



-- ==========================================================================================
-- 📈 YEAR-OVER-YEAR (YoY) PERFORMANCE BY PRODUCT TYPE (AVG VS ACTUAL & PREV YEAR COMPARE)
-- ==========================================================================================

CREATE PROCEDURE YOY
AS
BEGIN
    WITH CTE AS (
        SELECT 
            YEAR(f.order_date) AS year,
            p.produc_name AS product_name,
            SUM(f.sales) AS total_sales,
            SUM(f.quantity) AS total_quantity
        FROM gold.fact_sales AS f
        LEFT JOIN gold.dim_products AS p
            ON f.product_key = p.product_key
        WHERE f.order_date IS NOT NULL
        GROUP BY YEAR(f.order_date), p.produc_name
    )

    SELECT 
        *,
        -- Sales performance vs average
        CASE 
            WHEN avg_sales_diff > 0 THEN 'Above Avg'
            WHEN avg_sales_diff < 0 THEN 'Below Avg'
            ELSE 'No Change'
        END AS avg_sales_change,

        -- Sales performance vs previous year
        CASE 
            WHEN py_sales_diff > 0 THEN 'Above Prev'
            WHEN py_sales_diff < 0 THEN 'Below Prev'
            ELSE 'No Change'
        END AS py_sales_change,

        -- Quantity performance vs average
        CASE 
            WHEN avg_qty_diff > 0 THEN 'Above Avg'
            WHEN avg_qty_diff < 0 THEN 'Below Avg'
            ELSE 'No Change'
        END AS avg_qty_change,

        -- Quantity performance vs previous year
        CASE 
            WHEN py_qty_diff > 0 THEN 'Above Prev'
            WHEN py_qty_diff < 0 THEN 'Below Prev'
            ELSE 'No Change'
        END AS py_qty_change

    FROM (
        SELECT 
            *,
            AVG(total_sales) OVER (PARTITION BY product_name) AS avg_sales,
            LAG(total_sales) OVER (PARTITION BY product_name ORDER BY year) AS prev_year_sales,
            total_sales - AVG(total_sales) OVER (PARTITION BY product_name) AS avg_sales_diff,
            total_sales - LAG(total_sales) OVER (PARTITION BY product_name ORDER BY year) AS py_sales_diff,

            AVG(total_quantity) OVER (PARTITION BY product_name) AS avg_quantity,
            LAG(total_quantity) OVER (PARTITION BY product_name ORDER BY year) AS prev_year_quantity,
            total_quantity - AVG(total_quantity) OVER (PARTITION BY product_name) AS avg_qty_diff,
            total_quantity - LAG(total_quantity) OVER (PARTITION BY product_name ORDER BY year) AS py_qty_diff
        FROM CTE
    ) AS t
    ORDER BY product_name, year;
END;

-- ✅ Execute the YOY analysis procedure
EXEC YOY;
