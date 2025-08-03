/*************************************************************************************************
    VIEW NAME      : gold.customer_report

    DESCRIPTION    : This view aggregates customer-level metrics and segments customers 
                     based on their purchase behavior and lifecycle metrics.
                     
    INCLUDES:
         Customer basic details (name, age, country)
         Aggregated sales metrics:
            - Total Spendings
            - Total Purchases (quantity)
            - Total Orders
            - Total Unique Products
         Lifecycle metrics:
            - Life Span (months between first and last order)
            - Recency (months since last order)
         Derived KPIs:
            - Avg Order Value = total_spendings / total_orders
            - Avg Monthly Spendings = total_spendings / life_span
         Categorization:
            - Age Category (Under 20, 20–29, etc.)
            - Customer Segment:
                ▪ VIP     – Active for at least 12 months & spent > 5000
                ▪ Regular – Active ≥ 12 months & spent ≤ 5000
                ▪ New     – Active for < 12 months

    USE CASES:
         Power BI dashboards for customer segmentation
         Marketing targeting (e.g., VIP offers)
         Customer lifecycle management
*************************************************************************************************/

CREATE VIEW gold.customer_report AS 
WITH cte AS (
    SELECT
        f.order_number,
        f.product_key,
        f.order_date,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS full_name,
        c.country,
        DATEDIFF(YEAR, c.birthday, GETDATE()) AS age,
        f.sales,
        f.quantity
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_customers AS c 
        ON f.customer_key = c.customer_key
    WHERE f.order_date IS NOT NULL
),
customer_aggregation AS (
    SELECT 
        customer_key,
        customer_number,
        full_name,
        country,
        age,
        SUM(sales) AS total_spendings,
        SUM(quantity) AS total_purchases,
        COUNT(DISTINCT product_key) AS total_products,
        COUNT(DISTINCT order_number) AS total_orders,
        MAX(order_date) AS last_order,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS life_span
    FROM cte
    GROUP BY 
        customer_key,
        customer_number,
        full_name,
        country,
        age
)
SELECT 
    customer_key,
    customer_number,
    full_name,
    country,
    age,

    -- Age categorization
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 and above'
    END AS age_cat,

    life_span,

    -- Customer segmentation based on duration and spending
    CASE 
        WHEN life_span >= 12 AND total_spendings > 5000 THEN 'VIP'
        WHEN life_span >= 12 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    total_spendings,
    total_purchases,
    total_products,
    total_orders,

    -- Recency in months since last purchase
    DATEDIFF(MONTH, last_order, GETDATE()) AS recency,

    -- Avg spend per order
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE CAST(total_spendings AS FLOAT) / total_orders
    END AS avg_order_value,

    -- Avg monthly spending
    CASE 
        WHEN life_span = 0 THEN total_spendings
        ELSE CAST(total_spendings AS FLOAT) / life_span
    END AS avg_monthly_spendings

FROM customer_aggregation;
