-- 05_reorder_analysis.sql
-- REORDER BEHAVIOR ANALYSIS

USE [InstacartAnalyticsWarehouse];
GO

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize fact + product dimension
SELECT 
    fo.user_id,
    fo.order_id,
    fo.order_number,
    fo.product_id,
    fo.reordered,
    fo.days_since_prior_order,
    dp.product_name
INTO #base
FROM dbo.fact_orders fo
INNER JOIN dbo.dim_products dp
    ON fo.product_id = dp.product_id;

-- Overall reorder rate
SELECT 
    CAST(100.0 * SUM(CAST(reordered AS INT)) / COUNT_BIG(*) AS DECIMAL(5,2)) AS reorder_rate_pct
FROM #base;

-- Reorder rate per product
SELECT
    product_name,
    COUNT_BIG(*) AS total_orders,
    CAST(100.0 * AVG(CAST(reordered AS FLOAT)) AS DECIMAL(5,2)) AS reorder_rate_pct
FROM #base
GROUP BY product_name
HAVING COUNT_BIG(*) > 50
ORDER BY reorder_rate_pct DESC;

-- Reorder probability vs time gap
SELECT
    days_since_prior_order,
    COUNT_BIG(*) AS num_orders,
    CAST(100.0 * AVG(CAST(reordered AS FLOAT)) AS DECIMAL(5,2)) AS reorder_probability_pct
FROM #base
GROUP BY days_since_prior_order
ORDER BY days_since_prior_order;

-- Reorder streak detection
SELECT
    user_id,
    order_id,
    order_number,
    SUM(CAST(reordered AS INT)) OVER (
        PARTITION BY user_id
        ORDER BY order_number
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS recent_reorders
FROM #base
ORDER BY user_id, order_number;

-- Cleanup
DROP TABLE #base;