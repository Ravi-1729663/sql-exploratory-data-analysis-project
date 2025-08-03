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
