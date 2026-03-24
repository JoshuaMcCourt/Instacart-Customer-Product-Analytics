-- 03_basket_analysis.sql
-- BASKET SIZE & COMPOSITION 

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize required columns with product attributes
SELECT 
    f.order_id,
    f.user_id,
    f.product_id,
    p.aisle_id,
    p.department_id
INTO #base
FROM dbo.fact_orders f
INNER JOIN dbo.dim_products p
    ON f.product_id = p.product_id;

-- Basket size per order
WITH basket_sizes AS (
    SELECT 
        order_id, 
        COUNT_BIG(product_id) AS basket_size
    FROM #base
    GROUP BY order_id
)
SELECT
    basket_size,
    COUNT_BIG(*) AS num_orders,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_orders
FROM basket_sizes
GROUP BY basket_size
ORDER BY basket_size;

-- Basket statistics: avg, median, max
SELECT TOP 1
    AVG(CAST(basket_size AS FLOAT)) OVER () AS avg_basket,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY basket_size) 
        OVER () AS median_basket,
    MAX(basket_size) OVER () AS max_basket
FROM (
    SELECT order_id, COUNT_BIG(product_id) AS basket_size
    FROM #base
    GROUP BY order_id
) AS order_counts;

-- Heavy vs light shoppers (basket categories)
SELECT
    CASE
        WHEN basket_size <= 5 THEN 'small'
        WHEN basket_size <= 15 THEN 'medium'
        ELSE 'large'
    END AS basket_category,
    COUNT_BIG(*) AS num_orders,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_orders
FROM (
    SELECT order_id, COUNT_BIG(product_id) AS basket_size
    FROM #base
    GROUP BY order_id
) AS order_counts
GROUP BY 
    CASE
        WHEN basket_size <= 5 THEN 'small'
        WHEN basket_size <= 15 THEN 'medium'
        ELSE 'large'
    END
ORDER BY basket_category;

-- Basket diversity per user
SELECT
    f.user_id,
    COUNT(DISTINCT f.product_id) AS unique_products,
    COUNT(DISTINCT p.aisle_id) AS unique_aisles,
    COUNT(DISTINCT p.department_id) AS unique_departments
FROM #base f
INNER JOIN dbo.dim_products p
    ON f.product_id = p.product_id
GROUP BY f.user_id
ORDER BY unique_products DESC;

-- Cleanup
DROP TABLE #base;
