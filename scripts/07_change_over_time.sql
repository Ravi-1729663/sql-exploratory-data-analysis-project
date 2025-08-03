/*************************************************************************************************
    PURPOSE:
    This report analyzes the sales data across various time periods: daily, monthly, quarterly,
    and yearly. It provides insights into revenue trends, customer count, and sold quantities.
    
    DATA SOURCE:
    Table: gold.fact_sales

    KEY METRICS:
    - Total sales (revenue)
    - Distinct customers
    - Quantity sold
*************************************************************************************************/


-- ===============================
-- 📅 Daily Sales Report
-- ===============================
SELECT 
    order_date,
    SUM(sales) AS daywise_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY order_date;


-- ===============================
-- 📆 Monthly Sales Report (Simple)
-- ===============================
SELECT 
    DATETRUNC(MONTH, order_date) AS month_no,
    DATENAME(MONTH, order_date) AS month_name,
    SUM(sales) AS monthly_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    DATETRUNC(MONTH, order_date),
    DATENAME(MONTH, order_date)
ORDER BY 
    DATETRUNC(MONTH, order_date);


-- ===============================
-- 📊 Quarterly Sales Report (Simple)
-- ===============================
SELECT 
    DATETRUNC(QUARTER, order_date) AS quarter,
    SUM(sales) AS quarterly_sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(QUARTER, order_date)
ORDER BY DATETRUNC(QUARTER, order_date);


-- ===============================
-- 📅 Yearly Sales Summary
-- ===============================
SELECT 
    YEAR(order_date) AS year,
    SUM(sales) AS yearly_sales,
    COUNT(DISTINCT customer_key) AS yearly_customers,
    SUM(quantity) AS yearly_sold_units
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY year;


-- ===============================
-- 📆 Monthly Detailed Report
-- ===============================
SELECT 
    FORMAT(order_date, 'yyyy-MM') AS month,
    DATENAME(MONTH, order_date) AS month_name,
    SUM(sales) AS monthly_sales,
    COUNT(DISTINCT customer_key) AS monthly_customers,
    SUM(quantity) AS monthly_sold_units
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    FORMAT(order_date, 'yyyy-MM'),
    DATENAME(MONTH, order_date)
ORDER BY FORMAT(order_date, 'yyyy-MM');


-- ===============================
-- 📊 Quarterly Detailed Report
-- ===============================
SELECT 
    YEAR(order_date) AS year,
    CONCAT('Q', DATEPART(QUARTER, order_date)) AS quarter,
    SUM(sales) AS quarterly_sales,
    COUNT(DISTINCT customer_key) AS quarterly_customers,
    SUM(quantity) AS quarterly_sold_units
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    YEAR(order_date),
    CONCAT('Q', DATEPART(QUARTER, order_date))
ORDER BY year;


-- ===============================
-- 📈 Quarterly Pivot Report (Sales by Quarter)
-- ===============================
WITH cte AS (
    SELECT 
        YEAR(order_date) AS year,
        DATEPART(QUARTER, order_date) AS quarter,
        SUM(sales) AS quarterly_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY 
        YEAR(order_date),
        DATEPART(QUARTER, order_date)
)

SELECT  
    year,
    SUM(CASE WHEN quarter = 1 THEN quarterly_sales ELSE 0 END) AS Q1,
    SUM(CASE WHEN quarter = 2 THEN quarterly_sales ELSE 0 END) AS Q2,
    SUM(CASE WHEN quarter = 3 THEN quarterly_sales ELSE 0 END) AS Q3,
    SUM(CASE WHEN quarter = 4 THEN quarterly_sales ELSE 0 END) AS Q4
FROM cte
GROUP BY year
ORDER BY year;
