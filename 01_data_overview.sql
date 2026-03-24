-- 01_data_overview.sql
-- DATA OVERVIEW & SANITY CHECKS

SET NOCOUNT ON;

-- Ensure clean temp table (idempotent execution)
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize base once
SELECT 
    user_id,
    order_id,
    product_id
INTO #base
FROM dbo.fact_orders;

-- Core cardinality metrics
SELECT
    COUNT_BIG(*) AS total_rows,
    COUNT_BIG(DISTINCT order_id) AS total_orders,
    COUNT_BIG(DISTINCT user_id) AS total_users,
    COUNT_BIG(DISTINCT product_id) AS total_products
FROM #base;

-- Basket size metrics (avg + median)
SELECT TOP 1
    AVG(CAST(cnt AS FLOAT)) OVER () AS avg_products_per_order,
    PERCENTILE_CONT(0.5) 
        WITHIN GROUP (ORDER BY cnt) 
        OVER () AS median_products_per_order
FROM (
    SELECT order_id, COUNT_BIG(*) AS cnt
    FROM #base
    GROUP BY order_id
) AS order_counts;

-- Orders per user distribution
SELECT
    order_count,
    COUNT_BIG(*) AS num_users
FROM (
    SELECT user_id, COUNT_BIG(DISTINCT order_id) AS order_count
    FROM #base
    GROUP BY user_id
) AS user_orders
GROUP BY order_count
ORDER BY order_count;

-- Null checks (data quality)
SELECT
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_users,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_products,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_orders
FROM #base;

-- Cleanup
DROP TABLE #base;
