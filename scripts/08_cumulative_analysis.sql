/*************************************************************************************************
    PURPOSE:
    This script performs cumulative and running total analysis on the sales data:
    
    1. Weekly moving sales (last 7 days)
    2. Yearly running totals and moving average price
    3. Monthly running totals

    DATA SOURCE:
    Table: gold.fact_sales

*************************************************************************************************/


-- ==========================================
-- 📊 Weekly Moving Sum (7-day window)
-- ==========================================
SELECT 
    *,
    SUM(total_sales) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS weekly_sales,
    DATENAME(WEEKDAY, order_date) AS week_day
FROM (
    SELECT 
        order_date,
        SUM(sales) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY order_date
) AS t;



-- ==========================================
-- 📈 Yearly Running Total and Moving Avg Price
-- ==========================================
SELECT 
    year,
    yearly_sales,
    avg_price,
    SUM(yearly_sales) OVER (ORDER BY year) AS yearly_running_sales,
    AVG(avg_price) OVER (ORDER BY year) AS moving_avg_price
FROM (
    SELECT 
        DATEPART(YEAR, order_date) AS year,
        SUM(sales) AS yearly_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATEPART(YEAR, order_date)
) AS t;



-- ==========================================
-- 📅 Monthly Running Total
-- ==========================================
SELECT 
    *,
    SUM(monthly_sales) OVER (
        ORDER BY month_trunc 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_sales_monthly
FROM (
    SELECT 
        DATETRUNC(MONTH, order_date) AS month_trunc,
        SUM(sales) AS monthly_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
) AS t;
