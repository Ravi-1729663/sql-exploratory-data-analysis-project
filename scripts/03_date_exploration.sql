/*******************************************************************************************
Purpose:
    Explore date-related ranges and age statistics from sales and customer data, including:
    - Range of order dates (min, max, and duration in months)
    - Age range of customers based on their birthdays
*******************************************************************************************/

-- Get the earliest and latest order dates, and calculate the range in months
SELECT 
    MIN(order_date) AS min_order_date,
    MAX(order_date) AS max_order_date,
    DATEDIFF(month, MIN(order_date), MAX(order_date)) AS order_range_months
FROM gold.fact_sales;

-- Find the youngest and oldest customers by birthday and calculate their ages in years
SELECT 
    MAX(birthday) AS youngest_birthday,
    MIN(birthday) AS oldest_birthday,
    DATEDIFF(year, MAX(birthday), GETDATE()) AS youngest_age,
    DATEDIFF(year, MIN(birthday), GETDATE()) AS oldest_age
FROM gold.dim_customers;
