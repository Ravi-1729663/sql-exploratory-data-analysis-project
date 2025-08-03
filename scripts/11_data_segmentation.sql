/*************************************************************************************************
    PURPOSE:
    Segment customers into:
    - VIP:     Active ≥12 months AND spending > ₹5000
    - Regular: Active ≥12 months AND spending ≤ ₹5000
    - New:     Less than 12 months activity

    BASED ON:
    - Lifetime span of activity (first to last purchase)
    - Total sales across their order history
*************************************************************************************************/

WITH CTE AS (
    SELECT 
        customer_key,
        CONCAT(first_name, ' ', last_name) AS full_name,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span,
        SUM(sales) AS total_spendings,
        CASE 
            WHEN DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) >= 12 AND SUM(sales) > 5000 THEN 'VIP'
            WHEN DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) >= 12 THEN 'REGULAR'
            ELSE 'NEW'
        END AS customer_segment
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c ON f.customer_key = c.customer_key
    WHERE order_date IS NOT NULL
    GROUP BY 
        customer_key, 
        first_name, 
        last_name
)

SELECT 
    customer_segment,
    COUNT(*) AS total_customers
FROM CTE
GROUP BY customer_segment
ORDER BY total_customers DESC;

/*************************************************************************************************
    PURPOSE:
    Segment products into cost ranges and count how many products fall into each segment.
*************************************************************************************************/

SELECT 
    cost_category,
    COUNT(*) AS No_of_products
FROM (
    SELECT 
        product_key,
        produc_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'Below ₹100'
            WHEN cost BETWEEN 100 AND 500 THEN '₹100 - ₹500'
            WHEN cost BETWEEN 501 AND 1000 THEN '₹501 - ₹1000'
            ELSE 'Above ₹1000'
        END AS cost_category
    FROM gold.dim_products
) AS t
GROUP BY cost_category
ORDER BY No_of_products DESC;

