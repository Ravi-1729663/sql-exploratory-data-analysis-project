/*************************************************************************************************
    PURPOSE:
    This query performs a **Part-to-Whole Analysis** to understand how much each product 
    category contributes to the overall sales.

    METRIC:
    - total_sales per category
    - overall sales
    - percentage contribution of each category

    TABLES USED:
    - gold.fact_sales
    - gold.dim_products

*************************************************************************************************/

-- ==========================================
-- 📊 Category-wise Contribution to Total Sales
-- ==========================================
SELECT 
    *,
    SUM(total_sales) OVER () AS overall_sales,
    CONCAT(
        ROUND(CAST(total_sales AS FLOAT) / SUM(total_sales) OVER () * 100, 2),
        '%'
    ) AS per_contribution
FROM (
    SELECT 
        p.category,
        SUM(f.sales) AS total_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    GROUP BY p.category
) AS t
ORDER BY total_sales DESC;
