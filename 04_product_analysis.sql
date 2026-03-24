-- 04_product_analysis.sql
-- PRODUCT PERFORMANCE & STRUCTURE 

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize fact + product dimension
SELECT 
    fo.product_id,
    dp.product_name,
    dp.department_id,
    dp.department_name,
    dp.aisle_id,
    dp.aisle_name
INTO #base
FROM dbo.fact_orders fo
INNER JOIN dbo.dim_products dp
    ON fo.product_id = dp.product_id;

-- Top selling products
SELECT TOP 20
    product_name,
    COUNT_BIG(*) AS total_orders,
    DENSE_RANK() OVER (ORDER BY COUNT_BIG(*) DESC) AS rank
FROM #base
GROUP BY product_name
ORDER BY total_orders DESC;

-- Product popularity distribution
SELECT
    product_id,
    COUNT_BIG(*) AS purchase_count,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_of_total
FROM #base
GROUP BY product_id
ORDER BY purchase_count DESC;

-- Department-level sales
SELECT
    department_name,
    COUNT_BIG(*) AS total_sales,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_sales
FROM #base
GROUP BY department_name
ORDER BY total_sales DESC;

-- Aisle-level ranking
SELECT
    aisle_name,
    COUNT_BIG(*) AS total_sales,
    RANK() OVER (ORDER BY COUNT_BIG(*) DESC) AS aisle_rank,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_sales
FROM #base
GROUP BY aisle_name
ORDER BY aisle_rank;

-- Cleanup
DROP TABLE #base;
