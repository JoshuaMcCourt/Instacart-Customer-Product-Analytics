-- 06_user_behaviour.sql
-- USER SEGMENTATION & BEHAVIOUR

USE [InstacartAnalyticsWarehouse];
GO

SET NOCOUNT ON;

-- Ensure clean temp table
IF OBJECT_ID('tempdb..#base') IS NOT NULL
    DROP TABLE #base;

-- Materialize only required columns
SELECT 
    user_id,
    order_id,
    product_id,
    days_since_prior_order,
    reordered
INTO #base
FROM dbo.fact_orders;

-- Core user metrics
SELECT
    user_id,
    COUNT_BIG(DISTINCT order_id) AS total_orders,
    COUNT_BIG(product_id) AS total_items,
    CAST(AVG(CAST(days_since_prior_order AS FLOAT)) AS DECIMAL(10,2)) AS avg_days_between_orders,
    CAST(100.0 * AVG(CAST(reordered AS FLOAT)) AS DECIMAL(5,2)) AS reorder_rate_pct
FROM #base
GROUP BY user_id
ORDER BY total_orders DESC;

-- User segmentation distribution (dimension table)
SELECT
    user_segment,
    COUNT_BIG(*) AS num_users,
    CAST(100.0 * COUNT_BIG(*) / SUM(COUNT_BIG(*)) OVER () AS DECIMAL(5,2)) AS pct_users
FROM dbo.dim_users
GROUP BY user_segment
ORDER BY num_users DESC;

-- Power users (top 5% by total_orders)
-- SQL Server requires OVER() for PERCENTILE_CONT
WITH threshold AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.95) 
        WITHIN GROUP (ORDER BY total_orders) 
        OVER () AS cutoff
    FROM dbo.dim_users
)
SELECT du.*
FROM dbo.dim_users du
CROSS JOIN threshold t
WHERE du.total_orders >= t.cutoff
ORDER BY du.total_orders DESC;

-- Habitual users (always reorder)
SELECT
    user_id,
    total_orders,
    reorder_rate
FROM dbo.dim_users
WHERE reorder_rate = 1
ORDER BY total_orders DESC;

-- High-value engaged users (improved business signal)
SELECT TOP 20
    user_id,
    total_orders,
    total_items,
    reorder_rate
FROM dbo.dim_users
WHERE total_orders >= 10
  AND reorder_rate >= 0.7
ORDER BY total_orders DESC;

-- Cleanup
DROP TABLE #base;
